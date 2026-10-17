$ErrorActionPreference = "Stop"

Push-Location $PSScriptRoot
try {
	& (Join-Path $PSScriptRoot "Mine-imator.exe") --gfx OpenGL @args
	exit $LASTEXITCODE
}
finally {
	Pop-Location
}
