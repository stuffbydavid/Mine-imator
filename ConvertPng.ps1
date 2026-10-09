# Usage: .\ConvertPng.ps1 [folder]
# Recursively converts incompatible PNGs in the given directory to a GameMaker-friendly format.
# If no path is given, AppData\Mine_imator\Minecraft_unzip is used.

[CmdletBinding(SupportsShouldProcess = $true)]
param([Parameter(Position = 0)][string] $InputPath)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($InputPath)) {
    $InputPath = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Mine_imator\Minecraft_unzip'
}


$root = (Resolve-Path -LiteralPath $InputPath).ProviderPath
if (-not (Test-Path -LiteralPath $root -PathType Container)) {
    throw "Not a directory: $root"
}

Write-Host "Processing $InputPath"

Add-Type -AssemblyName System.Drawing

function Get-PngFormat {
    param([string] $File)

    $stream = [System.IO.File]::OpenRead($File)
    try {
        $header = New-Object byte[] 29
        $read = 0
        while ($read -lt $header.Length) {
            $count = $stream.Read($header, $read, $header.Length - $read)
            if ($count -eq 0) {
                throw 'PNG header is incomplete'
            }
            $read += $count
        }

        $signature = [byte[]] @(137, 80, 78, 71, 13, 10, 26, 10)
        for ($i = 0; $i -lt $signature.Length; $i++) {
            if ($header[$i] -ne $signature[$i]) {
                throw 'Invalid PNG signature'
            }
        }
        if ($header[8] -ne 0 -or $header[9] -ne 0 -or $header[10] -ne 0 -or $header[11] -ne 13 -or
            [System.Text.Encoding]::ASCII.GetString($header, 12, 4) -ne 'IHDR') {
            throw 'Invalid PNG IHDR'
        }

        return [PSCustomObject] @{ BitDepth = $header[24]; ColorType = $header[25]; Interlace = $header[28] }
    }
    finally {
        $stream.Dispose()
    }
}

$converted = 0
$skipped = 0
$failed = 0

foreach ($file in Get-ChildItem -LiteralPath $root -Filter '*.png' -File -Recurse) {
    $temporary = $null
    $backup = $null
    $replaced = $false
    $source = $null
    $bitmap = $null
    $graphics = $null

    try {
        $format = Get-PngFormat $file.FullName
        if ($format.ColorType -eq 6 -and $format.BitDepth -in @(8, 16) -and $format.Interlace -eq 0) {
            $skipped++
            continue
        }
        if (-not $PSCmdlet.ShouldProcess($file.FullName, 'Convert to RGBA PNG')) {
            continue
        }

        $temporary = Join-Path $file.DirectoryName ('.gm-png-' + [Guid]::NewGuid().ToString('N') + '.png')
        $source = [System.Drawing.Image]::FromFile($file.FullName)
        $bitmap = New-Object System.Drawing.Bitmap -ArgumentList $source.Width, $source.Height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $graphics.DrawImageUnscaled($source, 0, 0)
        $graphics.Dispose()
        $graphics = $null
        $bitmap.Save($temporary, [System.Drawing.Imaging.ImageFormat]::Png)
        $bitmap.Dispose()
        $bitmap = $null
        $source.Dispose()
        $source = $null

        $output = Get-PngFormat $temporary
        if ($output.BitDepth -ne 8 -or $output.ColorType -ne 6 -or $output.Interlace -ne 0) {
            throw 'PNG encoder did not produce noninterlaced RGBA8'
        }

        $backup = Join-Path $file.DirectoryName ('.gm-png-backup-' + [Guid]::NewGuid().ToString('N') + '.png')
        [System.IO.File]::Replace($temporary, $file.FullName, $backup)
        $replaced = $true
        $converted++
    }
    catch {
        $failed++
        Write-Warning "$($file.FullName): $($_.Exception.Message)"
    }
    finally {
        if ($graphics -ne $null) { $graphics.Dispose() }
        if ($bitmap -ne $null) { $bitmap.Dispose() }
        if ($source -ne $null) { $source.Dispose() }
        if ($temporary -ne $null -and (Test-Path -LiteralPath $temporary)) {
            Remove-Item -LiteralPath $temporary
        }
        if ($replaced -and $backup -ne $null -and (Test-Path -LiteralPath $backup)) {
            try {
                Remove-Item -LiteralPath $backup
            }
            catch {
                Write-Warning "Could not remove backup ${backup}: $($_.Exception.Message)"
            }
        }
    }
}

Write-Host "Converted $converted PNGs, skipped $skipped compatible PNGs, failed $failed PNGs"
if ($failed -gt 0) {
    throw "$failed PNGs could not be converted"
}