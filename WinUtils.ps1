$initialEnvironment = @{}
Get-ChildItem Env: | ForEach-Object { $initialEnvironment[$_.Name] = $_.Value }

$script:visualStudioInstallation = $null

function Get-VisualStudioInstallation {
    if ($null -ne $script:visualStudioInstallation) {
        return $script:visualStudioInstallation
    }

    $vsWhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
    if (-not (Test-Path -LiteralPath $vsWhere -PathType Leaf)) {
        throw "vswhere.exe was not found. Install Visual Studio 2022 or 2026 with the Desktop development with C++ workload."
    }

    $installationJson = (& $vsWhere `
        -latest `
        -version "[17.0,19.0)" `
        -products * `
        -requires `
            Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
            Microsoft.VisualStudio.Component.VC.CMake.Project `
        -format json) -join "`n"
    if ($LASTEXITCODE -ne 0 -or -not $installationJson) {
        throw "Visual Studio 2022 or 2026 with the x86/x64 C++ tools and C++ CMake tools for Windows was not found."
    }

    try {
        $installation = @($installationJson | ConvertFrom-Json)[0]
    }
    catch {
        throw "Could not read the Visual Studio installation reported by vswhere.exe."
    }
    if ($null -eq $installation -or -not $installation.installationPath -or -not $installation.installationVersion) {
        throw "vswhere.exe did not return a usable Visual Studio 2022 or 2026 installation."
    }

    $majorVersion = [int]$installation.installationVersion.Split('.')[0]
    if ($majorVersion -notin @(17, 18)) {
        throw "Unsupported Visual Studio version $($installation.installationVersion). Use Visual Studio 2022 or 2026."
    }

    $script:visualStudioInstallation = [PSCustomObject]@{
        Directory = $installation.installationPath
        MajorVersion = $majorVersion
        Year = if ($majorVersion -eq 18) { "2026" } else { "2022" }
    }
    return $script:visualStudioInstallation
}

function Get-VisualStudioDirectory {
    return (Get-VisualStudioInstallation).Directory
}

function Get-VisualStudioGenerator {
    $installation = Get-VisualStudioInstallation
    return "Visual Studio $($installation.MajorVersion) $($installation.Year)"
}

function Get-VisualStudioCMake {
    $visualStudioDirectory = Get-VisualStudioDirectory
    $cmakeExecutable = Join-Path $visualStudioDirectory `
        "Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
    Require-File -Path $cmakeExecutable -Description "Visual Studio bundled CMake"
    return $cmakeExecutable
}

function Import-VisualStudioEnvironment {
    param([Parameter(Mandatory = $true)][string] $TargetArchitecture)

    # Start each x64/x86 import from the environment that launched this script.
    # This prevents the first toolchain from leaking into the second build.
    Get-ChildItem Env: | ForEach-Object {
        if (-not $initialEnvironment.ContainsKey($_.Name)) {
            Remove-Item -LiteralPath "Env:$($_.Name)"
        }
    }
    foreach ($entry in $initialEnvironment.GetEnumerator()) {
        Set-Item -LiteralPath "Env:$($entry.Key)" -Value $entry.Value
    }

    $visualStudioDirectory = Get-VisualStudioDirectory

    $developerCommand = Join-Path $visualStudioDirectory "Common7\Tools\VsDevCmd.bat"
    if (-not (Test-Path -LiteralPath $developerCommand -PathType Leaf)) {
        throw "Visual Studio developer command file was not found at $developerCommand."
    }

    $cleanEnvironmentCommand = if ($env:VSCMD_VER -and $env:__VSCMD_PREINIT_PATH) {
        "`"$developerCommand`" -no_logo -clean_env && "
    } else {
        ""
    }
    $environmentCommand =
        $cleanEnvironmentCommand + "`"$developerCommand`" -no_logo -arch=$TargetArchitecture -host_arch=x64 && set"
    $environmentLines = & $env:ComSpec /s /c $environmentCommand
    if ($LASTEXITCODE -ne 0) {
        throw "Visual Studio environment initialization failed with exit code $LASTEXITCODE."
    }

    foreach ($line in $environmentLines) {
        if ($line -match '^([^=]+)=(.*)$') {
            Set-Item -LiteralPath "Env:$($Matches[1])" -Value $Matches[2]
        }
    }

    if ($env:VSCMD_ARG_TGT_ARCH -ne $TargetArchitecture -or -not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
        throw "Visual Studio did not initialize the $TargetArchitecture Native Tools environment."
    }
}

function Require-Command {
    param([Parameter(Mandatory = $true)][string] $Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $Name"
    }
}

function Require-File {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][string] $Description
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Description was not found at $Path."
    }
}
