#define AppName "LeoMoon CPU-V"
#define AppExeName "LeoMoon CPU-V.exe"
#define AppId "{{86F463A8-97B6-4083-85A7-B2C8F6E8F5AD}"

#ifndef AppVersion
  #error AppVersion must be passed with /DAppVersion.
#endif
#ifndef AppFileVersion
  #error AppFileVersion must be passed with /DAppFileVersion.
#endif
#ifndef StageDir
  #error StageDir must be passed with /DStageDir.
#endif
#ifndef OutputDir
  #error OutputDir must be passed with /DOutputDir.
#endif

[Setup]
AppId={#AppId}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
VersionInfoVersion={#AppFileVersion}
VersionInfoTextVersion={#AppFileVersion}
VersionInfoProductVersion={#AppFileVersion}
VersionInfoProductTextVersion={#AppFileVersion}
AppPublisher=LeoMoon Studios Inc.
DefaultDirName={localappdata}\Programs\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
MinVersion=6.2
OutputDir={#OutputDir}
OutputBaseFilename=leomoon-cpu-v-{#AppVersion}-windows-x86-setup
Compression=lzma2/ultra64
SolidCompression=yes
CloseApplications=no
RestartApplications=no
UsePreviousTasks=no
UninstallDisplayIcon={app}\{#AppExeName}
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#StageDir}\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon
