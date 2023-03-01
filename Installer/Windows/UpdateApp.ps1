# Paths
$version = $args[0];
$buildDir = $Env:DEV_DIR + "/Projects/MiCpp";
$outDir = ((Get-Item (Get-Location)).parent.parent.FullName) + "\Builds";
$outZip = "$outDir\Mine-imator $version.zip"
$outZip32 = "$outDir\Mine-imator $version x86.zip"
$outInstaller = "$outDir\Mine-imator $version installer.exe"
$outInstaller32 = "$outDir\Mine-imator $version x86 installer.exe"
$winRar = "C:\Program Files\WinRAR\WinRar.exe";
$innoSetup = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe";

# Update setup with version
((Get-Content -path "setup.iss") | % { $_ -Replace '#define AppVersion ".*"', "#define AppVersion ""$version""" }) |  Out-File "setup.iss" -Encoding ASCII;

# 64-bit zip and installer
Copy-Item ($buildDir + "\Release\Mine-imator.exe") -Destination "Mine-imator\Mine-imator.exe" -force;
Copy-Item ("vcomp140_x64.dll") -Destination "Mine-imator\vcomp140.dll" -force;
New-Item "Mine-imator\Projects" -Type Directory;
if (Test-Path -Path $outZip) {
    Remove-Item $outZip;
}
&$winRar a -rzip $outZip "Mine-imator";
Get-Process WinRar | Wait-Process;
&$winRar rn $outZip "Mine-imator" "Mine-imator $version";
Get-Process WinRar | Wait-Process;
Remove-Item "Mine-imator\Projects";
&$innoSetup setup.iss;
Move-item -Path "installer.exe" $outInstaller -force;

# 32-bit zip and installer
Copy-Item ($buildDir + "\Release-Win32\Mine-imator.exe") -Destination "Mine-imator\Mine-imator.exe" -force;
Copy-Item ("vcomp140_x86.dll") -Destination "Mine-imator\vcomp140.dll" -force;
New-Item "Mine-imator\Projects" -Type Directory;
if (Test-Path -Path $outZip32) {
    Remove-Item $outZip32;
}
&$winRar a -rzip $outZip32 "Mine-imator";
Get-Process WinRar | Wait-Process;
&$winRar rn $outZip32 "Mine-imator" "Mine-imator $version";
Get-Process WinRar | Wait-Process;
Remove-Item "Mine-imator\Projects";
&$innoSetup setup.iss;
Move-item -Path "installer.exe" $outInstaller32 -force;