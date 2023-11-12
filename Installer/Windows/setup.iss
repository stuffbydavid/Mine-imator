#define AppName "Mine-imator"
#define AppVersion "2.0.2"
#define AppYear "2023"
#define AppURL "https://www.mineimator.com"
#define AppPublisher "David Andrei"
#define AppPublisherURL "https://www.stuffbydavid.com"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)

AppId={{EF61A1AA-5F85-4E94-ACC6-D5650A312AE6}}
AppName={#AppName}
AppVersion={#AppVersion}
ApPVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppPublisherURL}
AppContact={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
AppCopyright=(c){#AppYear} {#AppPublisher}
DefaultDirName={%USERPROFILE}\{#AppName}
DefaultGroupName={#AppName}
OutputDir=.
OutputBaseFilename=installer
LicenseFile=license.txt
SetupIconFile=icon.ico
WizardImageFile=install.bmp
Compression=lzma
SolidCompression=yes
AllowNoIcons=yes
DisableDirPage=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#AppName}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppName}.exe"
Name: "{commondesktop}\{#AppName}"; Filename: "{app}\{#AppName}.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppName}.exe"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
Filename: {cmd}; Parameters: "/C Move ""{app}\unins000.exe"" ""{app}\Uninstall {#AppName}.exe"""; StatusMsg: Installing {#AppName}...; Flags: RunHidden WaitUntilTerminated
Filename: {cmd}; Parameters: "/C Move ""{app}\unins000.dat"" ""{app}\Uninstall {#AppName}.dat"""; StatusMsg: Installing {#AppName}...; Flags: RunHidden WaitUntilTerminated
Filename: {cmd}; Parameters: "/C Move ""{app}\unins000.msg"" ""{app}\Uninstall {#AppName}.msg"""; StatusMsg: Installing {#AppName}...; Flags: RunHidden WaitUntilTerminated
