# Usage: ./Setup.ps1 [Qt|OpenSSL|FFmpeg|Libzip|OpenAL|VisualStudio|Release] [x64|x86]
#   Qt|OpenSSL|FFmpeg|Libzip|OpenAL:
#       Unzips or downloads external libraries into DEV_DIR, then builds them
#   VisualStudio:
#       Generates and opens a Visual Studio 2022/2026 solution
#   Release:
#       Creates a release build and install folder for publishing
#   x64|x86:
#       Sets the target architecture, defaults to system architecture

param(
    [Parameter(Position = 0)][string] $Action = "Qt",
    [Parameter(Position = 1)][string] $Architecture
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not $Architecture) {
    $Architecture = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
}

$jobs = 8 # Parallel threads when building

if (-not $env:DEV_DIR) {
    throw "DEV_DIR is not set. Example: setx DEV_DIR C:\Dev"
}

$actionKey = $Action.ToLowerInvariant()
$validActions = @("qt", "openssl", "ffmpeg", "libzip", "openal", "visualstudio", "release")
if ($actionKey -notin $validActions) {
    throw "Unknown action '$Action'. Use Qt, OpenSSL, FFmpeg, Libzip, OpenAL, VisualStudio or Release."
}

$architectureKey = $Architecture.ToLowerInvariant()
if ($architectureKey -notin @("x64", "x86")) {
    throw "Unknown architecture '$Architecture'. Use x64 or x86."
}

if ($architectureKey -eq "x64") {
    $cmakeArchitecture = "x64"
    $architectureSuffix = ""
    $outputFolderName = "Win64"
} else {
    $cmakeArchitecture = "Win32"
    $architectureSuffix = "-Win32"
    $outputFolderName = "Win32"
}

$buildVsDirectory = Join-Path $PSScriptRoot "build-vs${architectureSuffix}"
$buildReleaseDirectory = Join-Path $PSScriptRoot "build-release${architectureSuffix}"
$cppProjectDirectory = Join-Path $PSScriptRoot "CppProject"
$externalDirectory = Join-Path $cppProjectDirectory "External"
$sourceArchiveDirectory = Join-Path $externalDirectory "Sources"
$outputDirectory = Join-Path $externalDirectory $outputFolderName

$qtVersion = "5.15.19"
$qtRef = "v${qtVersion}-lts-lgpl"
$qtFolderName = "${qtVersion}${architectureSuffix}"
$ffmpegVersion = "5.1.10"
$x264Revision = "0480cb05"
$libzipVersion = "1.11.4"
$openAlVersion = "1.24.3"
$openSslVersion = "3.0.21"
$jomVersion = "1.1.7"

$devDirectory = [System.IO.Path]::GetFullPath($env:DEV_DIR)
if (-not (Test-Path -LiteralPath $devDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $devDirectory -Force | Out-Null
}
$qtDirectory = Join-Path $devDirectory "Qt\$qtFolderName"
$qtSourceDirectory = Join-Path $qtDirectory "qt5"
$qtBuildDirectory = Join-Path $qtDirectory "build"
$qtInstallDirectory = Join-Path $qtDirectory "install"
$jomExecutable = Join-Path $devDirectory "Jom\jom.exe"
$jomArchiveName = "jom_$($jomVersion.Replace('.', '_')).zip"
$jomArchive = Join-Path $externalDirectory $jomArchiveName

. (Join-Path $PSScriptRoot "WinUtils.ps1")

$cmake = Get-VisualStudioCMake
$cmakeGenerator = Get-VisualStudioGenerator

function Get-SafeSourceTarget {
    param([Parameter(Mandatory = $true)][string] $RelativePath)

    $allowedRelativePaths = @(
        "FFmpeg\ffmpeg-$ffmpegVersion",
        "x264\x264-master",
        "Libzip\libzip-$libzipVersion",
        "OpenAL\openal-soft-$openAlVersion",
        "OpenSSL\openssl-$openSslVersion"
    )
    if ($allowedRelativePaths -notcontains $RelativePath) {
        throw "Unexpected source directory request: $RelativePath"
    }

    $target = [System.IO.Path]::GetFullPath((Join-Path $devDirectory $RelativePath))
    $devPrefix = $devDirectory.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar

    if (-not $target.StartsWith($devPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to replace unexpected source directory: $target"
    }

    return $target
}

function Ensure-SourceArchive {
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments = $true)]
        [string[]] $Libraries
    )

    foreach ($library in $Libraries) {
        $sources = switch ($library.ToLowerInvariant()) {
            "openssl" {
                @{
                    Archive = "openssl-$openSslVersion.tar.gz"
                    Destination = Join-Path $devDirectory "OpenSSL"
                    RelativePath = "OpenSSL\openssl-$openSslVersion"
                    Marker = "Configure"
                }
            }
            "ffmpeg" {
                @{
                    Archive = "ffmpeg-$ffmpegVersion.tar.xz"
                    Destination = Join-Path $devDirectory "FFmpeg"
                    RelativePath = "FFmpeg\ffmpeg-$ffmpegVersion"
                    Marker = "configure"
                }
                @{
                    Archive = "x264-master-$x264Revision.tar.bz2"
                    Destination = Join-Path $devDirectory "x264"
                    RelativePath = "x264\x264-master"
                    Marker = "configure"
                }
            }
            "libzip" {
                @{
                    Archive = "libzip-$libzipVersion.tar.gz"
                    Destination = Join-Path $devDirectory "Libzip"
                    RelativePath = "Libzip\libzip-$libzipVersion"
                    Marker = "CMakeLists.txt"
                }
            }
            "openal" {
                @{
                    Archive = "openal-soft-$openAlVersion.tar.bz2"
                    Destination = Join-Path $devDirectory "OpenAL"
                    RelativePath = "OpenAL\openal-soft-$openAlVersion"
                    Marker = "CMakeLists.txt"
                }
            }
            default { throw "Unknown source library: $library" }
        }

        foreach ($source in $sources) {
            $targetDirectory = Get-SafeSourceTarget -RelativePath $source.RelativePath
            $resolvedParent = [System.IO.Path]::GetFullPath($source.Destination)
            $expectedParent = [System.IO.Path]::GetFullPath((Split-Path -Parent $targetDirectory))
            if (-not $resolvedParent.Equals($expectedParent, [System.StringComparison]::OrdinalIgnoreCase)) {
                throw "Archive destination does not match the expected source parent: $resolvedParent"
            }

            if (Test-Path -LiteralPath $targetDirectory -PathType Container) {
                Write-Host "Source directory already exists: $targetDirectory"
            } else {
                if (Test-Path -LiteralPath $targetDirectory) {
                    throw "The expected source directory is occupied by a non-directory path: $targetDirectory"
                }

                $archivePath = Join-Path $sourceArchiveDirectory $source.Archive
                New-Item -ItemType Directory -Path $resolvedParent -Force | Out-Null

                Write-Host "Extracting $($source.Archive) into $resolvedParent"
                Push-Location -LiteralPath $resolvedParent
                try {
                    & $cmake -E tar xf $archivePath
                    $extractionExitCode = $LASTEXITCODE
                }
                finally {
                    Pop-Location
                }
                if ($extractionExitCode -ne 0) {
                    throw "Extraction of $($source.Archive) failed with exit code $extractionExitCode."
                }
                if (-not (Test-Path -LiteralPath $targetDirectory -PathType Container)) {
                    throw "$($source.Archive) did not create the expected directory $targetDirectory."
                }
            }

            Require-File `
                -Path (Join-Path $targetDirectory $source.Marker) `
                -Description "$($source.Archive) source marker"
        }
    }
}

function Remove-BuildDirectory {
    param([Parameter(Mandatory = $true)][string] $Path)

    $resolvedPath = [System.IO.Path]::GetFullPath($Path)
    $isUnderKnownLibrary = @("Qt", "OpenSSL", "FFmpeg", "x264", "Libzip", "OpenAL") |
        ForEach-Object { [System.IO.Path]::GetFullPath((Join-Path $devDirectory $_)) } |
        Where-Object {
            $resolvedPath.StartsWith(
                $_ + [System.IO.Path]::DirectorySeparatorChar,
                [System.StringComparison]::OrdinalIgnoreCase
            )
        }
    if (-not $isUnderKnownLibrary) {
        throw "Refusing to remove unexpected build directory: $resolvedPath"
    }
    if (Test-Path -LiteralPath $resolvedPath) {
        Write-Host "Removing build directory $resolvedPath"
        Remove-Item -LiteralPath $resolvedPath -Recurse -Force
    }
}

function Remove-CMakeCache {
    param([Parameter(Mandatory = $true)][string] $SourceDirectory)

    $allowedSourceDirectories = @(
        (Join-Path $devDirectory "Libzip\libzip-$libzipVersion"),
        (Join-Path $devDirectory "OpenAL\openal-soft-$openAlVersion")
    ) | ForEach-Object { [System.IO.Path]::GetFullPath($_) }
    $resolvedSourceDirectory = [System.IO.Path]::GetFullPath($SourceDirectory)
    if ($allowedSourceDirectories -notcontains $resolvedSourceDirectory) {
        throw "Refusing to remove CMake cache files from unexpected source directory: $resolvedSourceDirectory"
    }

    foreach ($name in @("CMakeCache.txt", "CMakeFiles")) {
        $cachePath = Join-Path $resolvedSourceDirectory $name
        if (Test-Path -LiteralPath $cachePath) {
            Write-Host "Removing generated CMake cache path $cachePath"
            Remove-Item -LiteralPath $cachePath -Recurse -Force
        }
    }
}

function Copy-BuiltFile {
    param(
        [Parameter(Mandatory = $true)][string] $Source
    )

    Require-File -Path $Source -Description "Built library"
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
    Copy-Item -LiteralPath $Source -Destination $outputDirectory -Force
    Write-Host "Copied $(Split-Path -Leaf $Source) to $outputDirectory"
}

function Ensure-Jom {
    $jomDirectory = [System.IO.Path]::GetFullPath((Split-Path -Parent $jomExecutable))
    $expectedJomDirectory = [System.IO.Path]::GetFullPath((Join-Path $devDirectory "Jom"))
    if (-not $jomDirectory.Equals($expectedJomDirectory, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to extract Jom into unexpected directory: $jomDirectory"
    }

    if (Test-Path -LiteralPath $jomDirectory -PathType Container) {
        Require-File -Path $jomExecutable -Description "Jom executable"
        Write-Host "Reusing existing Jom directory $jomDirectory"
        return
    }
    if (Test-Path -LiteralPath $jomDirectory) {
        throw "The Jom destination is occupied by a non-directory path: $jomDirectory"
    }

    Write-Host "Extracting jom into $jomDirectory"
    try {
        Expand-Archive -LiteralPath $jomArchive -DestinationPath $jomDirectory
        Require-File -Path $jomExecutable -Description "Extracted Jom executable"
    }
    catch {
        if (Test-Path -LiteralPath $jomDirectory -PathType Container) {
            Remove-Item -LiteralPath $jomDirectory -Recurse -Force
        }
        throw
    }
}

function Invoke-MsysBash {
    param(
        [Parameter(Mandatory = $true)][string] $WorkingDirectory,
        [Parameter(Mandatory = $true)][string] $Command
    )

    $bashExecutable = Join-Path $devDirectory "msys64\usr\bin\bash.exe"
    Require-File -Path $bashExecutable -Description "MSYS2 Bash"
    if ($WorkingDirectory.Contains("'")) {
        throw "MSYS2 build paths containing an apostrophe are not supported: $WorkingDirectory"
    }
    $msysWorkingDirectory = $WorkingDirectory.Replace('\', '/')
    $normalizedCommand = $Command.Replace("`r`n", "`n").Replace("`r", "`n")
    # Keep the active MSVC tools ahead of MSYS2. MSYS2 also ships link.exe,
    # which must not shadow Visual Studio's linker.
    $bashCommand =
        "set -e; export PATH=`"`$PATH:/usr/bin:/bin`"; " +
        "cd '$msysWorkingDirectory'; $normalizedCommand"

    $bashCommand | & $bashExecutable -s
    if ($LASTEXITCODE -ne 0) {
        throw "MSYS2 build failed with exit code $LASTEXITCODE."
    }
}

function Build-FFmpeg {
    $ffmpegDirectory = Get-SafeSourceTarget -RelativePath "FFmpeg\ffmpeg-$ffmpegVersion"
    Invoke-MsysBash -WorkingDirectory $ffmpegDirectory -Command @'
for tool in make nasm pkgconf; do
    command -v "$tool" >/dev/null 2>&1 || { echo "Required MSYS2 command not found: $tool" >&2; exit 1; }
done
'@

    $ffmpegBuildDirectory = Join-Path $ffmpegDirectory "build${architectureSuffix}"
    $ffmpegInstallDirectory = Join-Path $ffmpegDirectory "install${architectureSuffix}"
    $x264Directory = Get-SafeSourceTarget -RelativePath "x264\x264-master"
    $x264BuildDirectory = Join-Path $x264Directory "build${architectureSuffix}"
    $x264InstallDirectory = Join-Path $x264Directory "install${architectureSuffix}"
    
    Remove-BuildDirectory -Path $ffmpegBuildDirectory
    Remove-BuildDirectory -Path $ffmpegInstallDirectory
    Remove-BuildDirectory -Path $x264BuildDirectory
    Remove-BuildDirectory -Path $x264InstallDirectory

    Import-VisualStudioEnvironment -TargetArchitecture $architectureKey
    New-Item -ItemType Directory -Path $ffmpegBuildDirectory | Out-Null
    New-Item -ItemType Directory -Path $x264BuildDirectory | Out-Null

    $x264Command = (@'
CC=cl ../configure --prefix="$PWD/../{0}" --enable-static --disable-cli
make -j{1}
make install
'@) -f "install${architectureSuffix}", $jobs
    Invoke-MsysBash -WorkingDirectory $x264BuildDirectory -Command $x264Command
    
    if ($architectureKey -eq "x64") {
        $ffmpegArchitecture = "x86_64"
    } else {
        $ffmpegArchitecture = "x86_32"
    }

    $ffmpegCommand = (@'
export PKG_CONFIG_PATH="$PWD/../../../x264/x264-master/{0}/lib/pkgconfig"
../configure \
--toolchain=msvc \
--arch={2} \
--prefix="$PWD/../{1}" \
--disable-autodetect \
--disable-debug \
--disable-everything \
--disable-programs \
--disable-avdevice \
--disable-avfilter \
--disable-postproc \
--disable-network \
--disable-doc \
--disable-htmlpages \
--enable-protocol=file \
--enable-parser='vorbis,opus,flac,mpegaudio,aac*,h264' \
--enable-decoder='mp3,vorbis,opus,flac,wma*,pcm*,mpeg4,aac*' \
--enable-demuxer='mp3,wav,ogg,flac,xwma,asf,aac,m*' \
--enable-encoder='libx264,wma*,aac*,msmpeg4v*' \
--enable-muxer='mp4,mov,asf,h264' \
--enable-libx264 \
--enable-gpl \
--extra-ldflags="-LIBPATH:../../../x264/x264-master/{0}/lib" \
--extra-cflags="-I../../../x264/x264-master/{0}/include"
make -j{3}
make -j1 install
'@) -f "install${architectureSuffix}", "install${architectureSuffix}", $ffmpegArchitecture, $jobs
    Invoke-MsysBash -WorkingDirectory $ffmpegBuildDirectory -Command $ffmpegCommand

    foreach ($name in @("libavcodec.a", "libavformat.a", "libavutil.a", "libswresample.a", "libswscale.a")) {
        Copy-BuiltFile `
            -Source (Join-Path $ffmpegInstallDirectory "lib\$name")
    }
    Copy-BuiltFile `
        -Source (Join-Path $x264InstallDirectory "lib\libx264.lib")
}

function Build-Libzip {
    $qtCoreLibrary = Join-Path $qtInstallDirectory "lib\Qt5Core.lib"
    Require-File -Path $qtCoreLibrary -Description "Qt Core static library"

    $libzipDirectory = Get-SafeSourceTarget -RelativePath "Libzip\libzip-$libzipVersion"
    $buildDirectory = Join-Path $libzipDirectory "build${architectureSuffix}"

    Remove-CMakeCache -SourceDirectory $libzipDirectory
    Remove-BuildDirectory -Path $buildDirectory

    Import-VisualStudioEnvironment -TargetArchitecture $architectureKey

    & $cmake `
        -S $libzipDirectory -B $buildDirectory `
        -G $cmakeGenerator -A $cmakeArchitecture `
        -DCMAKE_POLICY_DEFAULT_CMP0091=NEW -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded `
        "-DZLIB_INCLUDE_DIR=$qtInstallDirectory\include\QtZlib" `
        "-DCMAKE_C_STANDARD_INCLUDE_DIRECTORIES=$qtInstallDirectory\include;$qtInstallDirectory\include\QtCore" `
        "-DZLIB_LIBRARY=$qtCoreLibrary" `
        -DENABLE_BZIP2=OFF -DENABLE_LZMA=OFF -DENABLE_ZSTD=OFF `
        -DBUILD_DOC=OFF -DBUILD_EXAMPLES=OFF -DBUILD_OSSFUZZ=OFF -DBUILD_REGRESS=OFF `
        -DBUILD_SHARED_LIBS=OFF -DBUILD_TOOLS=OFF
    if ($LASTEXITCODE -ne 0) {
        throw "Libzip configuration failed for $($cmakeArchitecture)."
    }

    & $cmake --build $buildDirectory --parallel $jobs --config Release
    if ($LASTEXITCODE -ne 0) {
        throw "Libzip build failed for $($cmakeArchitecture)."
    }

    Copy-BuiltFile -Source (Join-Path $buildDirectory "lib\Release\zip.lib")
}

function Build-OpenAL {
    $openAlDirectory = Get-SafeSourceTarget -RelativePath "OpenAL\openal-soft-$openAlVersion"
    $buildDirectory = Join-Path $openAlDirectory "build${architectureSuffix}"

    Remove-CMakeCache -SourceDirectory $openAlDirectory
    Remove-BuildDirectory -Path $buildDirectory

    Import-VisualStudioEnvironment -TargetArchitecture $architectureKey

    & $cmake `
        -S $openAlDirectory -B $buildDirectory `
        -G $cmakeGenerator -A $cmakeArchitecture `
        -DCMAKE_POLICY_DEFAULT_CMP0091=NEW -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded `
        -DLIBTYPE=STATIC -DALSOFT_EXAMPLES=OFF -DALSOFT_UTILS=OFF -DALSOFT_EAX=OFF `
        -DALSOFT_EMBED_HRTF_DATA=OFF
    if ($LASTEXITCODE -ne 0) {
        throw "OpenAL Soft configuration failed for $($cmakeArchitecture)."
    }

    & $cmake --build $buildDirectory --parallel $jobs --config Release
    if ($LASTEXITCODE -ne 0) {
        throw "OpenAL Soft build failed for $($cmakeArchitecture)."
    }

    Copy-BuiltFile -Source (Join-Path $buildDirectory "Release\OpenAL32.lib")
}

function Invoke-OpenSSLTarget {
    param(
        [Parameter(Mandatory = $true)][string] $BuildTarget
    )

    $openSslDirectory = Get-SafeSourceTarget -RelativePath "OpenSSL\openssl-$openSslVersion"
    $buildDirectory = Join-Path $openSslDirectory "build${architectureSuffix}"
    $installDirectory = Join-Path $openSslDirectory "install${architectureSuffix}"
    
    if ($architectureKey -eq "x64") {
        $configureTarget = "VC-WIN64A"
    } else {
        $configureTarget = "VC-WIN32"
    }

    Remove-BuildDirectory -Path $buildDirectory
    New-Item -ItemType Directory -Path $buildDirectory | Out-Null

    $previousTerm = $env:TERM
    $env:TERM = "ansi"
    Push-Location $buildDirectory
    try {
        $configureArguments = @(
            $configureTarget,
            "no-asm",
            "no-shared",
            "no-module",
            "no-tests",
            "no-makedepend",
            "--prefix=$installDirectory",
            "--openssldir=$(Join-Path $installDirectory 'ssl')",
            "--libdir=lib"
        )
        & perl.exe (Join-Path $openSslDirectory "Configure") @configureArguments
        if ($LASTEXITCODE -ne 0) {
            throw "OpenSSL configuration failed for $Architecture with exit code $LASTEXITCODE."
        }

        & nmake.exe $BuildTarget
        if ($LASTEXITCODE -ne 0) {
            throw "OpenSSL target '$BuildTarget' failed for $Architecture with exit code $LASTEXITCODE."
        }
    }
    finally {
        Pop-Location
        if ($null -eq $previousTerm) {
            Remove-Item Env:TERM -ErrorAction SilentlyContinue
        } else {
            $env:TERM = $previousTerm
        }
    }
}

function Build-OpenSSL {
    $openSslDirectory = Get-SafeSourceTarget -RelativePath "OpenSSL\openssl-$openSslVersion"
    $installDirectory = Join-Path $openSslDirectory "install${architectureSuffix}"
    
    Remove-BuildDirectory -Path $installDirectory

    Import-VisualStudioEnvironment -TargetArchitecture $architectureKey

    foreach ($commandName in @("cl.exe", "lib.exe", "nmake.exe", "perl.exe", "rc.exe")) {
        Require-Command -Name $commandName
    }
    
    # install_dev builds and installs only the static libraries and headers.
    Invoke-OpenSSLTarget -BuildTarget "install_dev" `

    foreach ($name in @("libssl.lib", "libcrypto.lib")) {
        Copy-BuiltFile -Source (Join-Path $installDirectory "lib\$name")
    }

    $includeDirectory = Join-Path $installDirectory "include\openssl"
    Require-File `
        -Path (Join-Path $includeDirectory "ssl.h") `
        -Description "Installed OpenSSL headers"
}

function Build-Qt {
    Ensure-Jom
    Import-VisualStudioEnvironment -TargetArchitecture $architectureKey

    foreach ($commandName in @("cl.exe", "git.exe", "perl.exe", "nmake.exe")) {
        if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
            throw "$commandName was not found. Ensure Git and Strawberry Perl are installed and on PATH."
        }
    }

    if ($env:VSCMD_ARG_TGT_ARCH -ne $architectureKey) {
        throw "The active MSVC compiler does not target $architectureKey."
    }

    # Generate OpenSSL's platform-specific public headers without rebuilding its libraries.
    Invoke-OpenSSLTarget -BuildTarget "build_generated"

    $openSslDirectory = Get-SafeSourceTarget -RelativePath "OpenSSL\openssl-$openSslVersion"
    $openSslGeneratedIncludeDirectory = Join-Path $openSslDirectory  "build${architectureSuffix}\include"
    $openSslSourceIncludeDirectory = Join-Path $openSslDirectory "include"
    $openSslInstallDirectory = Join-Path $openSslDirectory "install${architectureSuffix}"

    Require-File `
        -Path (Join-Path $openSslGeneratedIncludeDirectory "openssl\ssl.h") `
        -Description "Generated OpenSSL headers"
    Require-File `
        -Path (Join-Path $openSslSourceIncludeDirectory "openssl\e_os2.h") `
        -Description "OpenSSL source headers"
    Require-File `
        -Path (Join-Path $outputDirectory "libssl.lib") `
        -Description "OpenSSL static library"
    Require-File `
        -Path (Join-Path $outputDirectory "libcrypto.lib") `
        -Description "OpenSSL crypto static library"

    $qtParentDirectory = Split-Path -Parent $qtDirectory
    New-Item -ItemType Directory -Path $qtParentDirectory -Force | Out-Null

    # The destination is derived from DEV_DIR and a fixed folder name.
    if (-not $qtDirectory.StartsWith(
        $qtParentDirectory + [System.IO.Path]::DirectorySeparatorChar,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        throw "Unexpected Qt directory: $qtDirectory"
    }
    New-Item -ItemType Directory -Path $qtDirectory -Force | Out-Null

    if (-not (Test-Path -LiteralPath $qtSourceDirectory -PathType Container)) {
        Write-Host "Cloning Qt $qtRef for $Architecture into $qtSourceDirectory"
        & git.exe clone --branch $qtRef --depth 1 https://code.qt.io/qt/qt5.git $qtSourceDirectory
        if ($LASTEXITCODE -ne 0) { throw "Qt clone failed with exit code $LASTEXITCODE." }
    } else {
        Require-File -Path (Join-Path $qtSourceDirectory ".git\HEAD") -Description "Existing Qt Git checkout"
        $currentQtCommit = (& git.exe -C $qtSourceDirectory rev-parse HEAD).Trim()
        if ($LASTEXITCODE -ne 0) { throw "Could not identify the existing Qt checkout." }
        $requestedQtCommit = (& git.exe -C $qtSourceDirectory rev-parse "$qtRef^{commit}").Trim()
        if ($LASTEXITCODE -ne 0) { throw "The existing Qt checkout does not contain $qtRef." }
        if ($currentQtCommit -ne $requestedQtCommit) {
            throw "Existing Qt source is at $currentQtCommit, not $qtRef ($requestedQtCommit). " +
                "Move it aside or select the matching qtRef; it will not be deleted automatically."
        }
        Write-Host "Reusing existing Qt source directory $qtSourceDirectory"
    }

    $qtBaseConfigure = Join-Path $qtSourceDirectory "qtbase\configure"
    if (-not (Test-Path -LiteralPath $qtBaseConfigure -PathType Leaf)) {
        Push-Location $qtSourceDirectory
        try {
            # Project uses Qt Widgets, Gui, Network, and OpenGL classes, all supplied by QtBase
            & perl.exe init-repository --module-subset=qtbase
            if ($LASTEXITCODE -ne 0) { throw "QtBase initialization failed with exit code $LASTEXITCODE." }
        }
        finally {
            Pop-Location
        }
    }

    Remove-BuildDirectory -Path $qtBuildDirectory
    Remove-BuildDirectory -Path $qtInstallDirectory
    New-Item -ItemType Directory -Path $qtBuildDirectory | Out-Null

    Push-Location $qtBuildDirectory
    try {
        $openSslLibraries =
            "$outputDirectory\libssl.lib " +
            "$outputDirectory\libcrypto.lib"
        $configureArguments = @(
            "-platform", "win32-msvc",
            "-prefix", $qtInstallDirectory,
            "-opensource", "-confirm-license",
            "-release", "-static", "-static-runtime",
            "-opengl", "desktop",
            "-openssl-linked",
            "-I$openSslGeneratedIncludeDirectory",
            "-I$openSslSourceIncludeDirectory",
            "OPENSSL_LIBS=-lWs2_32 -lGdi32 -lAdvapi32 -lCrypt32 -lUser32",
            "OPENSSL_LIBS_DEBUG=$openSslLibraries",
            "OPENSSL_LIBS_RELEASE=$openSslLibraries",
            "-qt-libpng", "-qt-libjpeg", "-qt-zlib", "-qt-harfbuzz", "-qt-pcre", "-qt-doubleconversion",
            "-no-feature-textmarkdownreader", "-no-feature-textmarkdownwriter", "-no-feature-bearermanagement",
            "-no-libinput", "-no-libmd4c", "-no-icu",
            "-nomake", "tests", "-nomake", "examples", "-nomake", "tools"
        )

        & (Join-Path $qtSourceDirectory "configure.bat") @configureArguments
        if ($LASTEXITCODE -ne 0) { throw "Qt configuration failed with exit code $LASTEXITCODE." }

        # Only QtBase was initialized, so the normal build target is already limited
        # to QtBase. `jom module-qtbase` would build it too, but not install it.
        & $jomExecutable
        if ($LASTEXITCODE -ne 0) { throw "Qt build failed with exit code $LASTEXITCODE." }
        & $jomExecutable install
        if ($LASTEXITCODE -ne 0) { throw "Qt installation failed with exit code $LASTEXITCODE." }
    }
    finally {
        Pop-Location
    }

    Write-Host "Qt $qtRef for $Architecture was installed to $qtInstallDirectory"
}

switch ($actionKey) {
    "qt" {
        Ensure-SourceArchive "OpenSSL" "FFmpeg" "OpenAL" "Libzip"
        Build-Qt
    }
    "openssl" {
        Ensure-SourceArchive "OpenSSL"
        Build-OpenSSL
    }
    "ffmpeg" {
        Ensure-SourceArchive "FFmpeg"
        Build-FFmpeg
    }
    "libzip" {
        Ensure-SourceArchive "Libzip"
        Build-Libzip
    }
    "openal" {
        Ensure-SourceArchive "OpenAL"
        Build-OpenAL
    }
    "visualstudio" {
        & $cmake `
            -S $cppProjectDirectory -B $buildVsDirectory `
            -G $cmakeGenerator -A $cmakeArchitecture
        if ($LASTEXITCODE -ne 0) {
            throw "Visual Studio generation failed for $($cmakeArchitecture)."
        }

        $solution = Get-ChildItem -LiteralPath $buildVsDirectory -File |
            Where-Object { $_.Extension -in @(".sln", ".slnx") } |
            Select-Object -First 1

        if ($null -eq $solution) {
            throw "No Visual Studio solution was generated in $buildVsDirectory."
        }
        $devenv = Join-Path (Get-VisualStudioDirectory) "Common7\IDE\devenv.exe"
        Start-Process -FilePath $devenv -ArgumentList "`"$($solution.FullName)`""
    }
    "release" {
        & $cmake `
            -S $cppProjectDirectory -B $buildReleaseDirectory `
            -G $cmakeGenerator -A $cmakeArchitecture
        if ($LASTEXITCODE -ne 0) {
            throw "Release build generation failed for $($cmakeArchitecture)."
        }
        & $cmake `
            --build $buildReleaseDirectory `
            --parallel $jobs `
            --config Release
        if ($LASTEXITCODE -ne 0) {
            throw "Release build failed for $($cmakeArchitecture)."
        }
        & $cmake `
            --install $buildReleaseDirectory `
            --config Release
        if ($LASTEXITCODE -ne 0) {
            throw "Install failed for $($cmakeArchitecture)."
        }
    }
}
