; SimpitLauncher Inno Setup script
; Requires Inno Setup 6: https://jrsoftware.org/isinfo.php
; Prefer: powershell -ExecutionPolicy Bypass -File .\scripts\package.ps1
; which injects MyAppVersion (YYYYMMDD-<git hash>) and PublishDir.

#ifndef MyAppVersion
  #define MyAppVersion "0.0.0-dev"
#endif
#ifndef PublishDir
  #define PublishDir "..\artifacts\publish\win-x64"
#endif

#define MyAppName "Simpit Launcher"
#define MyAppPublisher "Stuart"
#define MyAppExeName "SimpitLauncher.exe"

[Setup]
AppId={{B8D4F9A2-5C3E-4F0B-8D2A-9E7C6B3F1A44}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\artifacts\installer
OutputBaseFilename=SimpitLauncherSetup-{#MyAppVersion}
SetupIconFile=..\Assets\AppIcon.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "{#PublishDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent
