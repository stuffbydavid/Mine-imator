; 1. Put the program files in the "Mine-imator" folder, be careful not to run it!
; 2. Create empty "Projects" and "Skins" folders (Git doesn't support this...)
; 3. Compile the installer
; 4. .zip the Mine-imator folder
; 5. Upload the generated Mine-imator installer.exe and Mine-imator.zip

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{EF61A1AA-5F85-4E94-ACC6-D5650A312AE6}}
AppName=Mine-imator
AppVersion=1.2.6
ApPVerName=Mine-imator 1.2.6
AppPublisher=David Norgren
AppPublisherURL=https://www.stuffbydavid.com
AppContact=https://www.mineimator.com
AppSupportURL=https://www.mineimator.com
AppUpdatesURL=https://www.mineimator.com
AppCopyright=(c)2020 David Norgren
DefaultDirName={%USERPROFILE}\Mine-imator
DefaultGroupName=Mine-imator
OutputDir=.
OutputBaseFilename=Mine-imator installer
LicenseFile=license.txt
SetupIconFile=mineimator.ico   
WizardImageFile=install.bmp
Compression=lzma
SolidCompression=yes                                          
AllowNoIcons=yes
DisableDirPage=auto

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "Mine-imator\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\Mine-imator"; Filename: "{app}\Mine-imator.exe"
Name: "{group}\{cm:UninstallProgram,Mine-imator}"; Filename: "{app}\Uninstall Mine-imator.exe"
Name: "{commondesktop}\Mine-imator"; Filename: "{app}\Mine-imator.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Mine-imator.exe"; Description: "{cm:LaunchProgram,Mine-imator}"; Flags: nowait postinstall skipifsilent

