; Script Inno Setup — installeur MultiDigi (F4LPS)
; Installe dans le dossier utilisateur (AppData\Local) : aucun droit
; administrateur requis, et le programme peut écrire ses réglages/caches/
; traces à côté de l'exécutable sans problème de permission.

#define MyAppName "MultiDigi"
#define MyAppVersion "8.4.5"
#define MyAppPublisher "F4LPS"
#define MyAppURL "https://github.com/f4lps/multidigi"
#define MyAppExeName "MultiDigi.exe"

[Setup]
AppId={{B7B2B9D0-6B8B-4B7B-9C1E-F4LPSMULTIDIGI}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={localappdata}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=..\installer\Output
OutputBaseFilename=MultiDigi_Setup_{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile=multidigi.ico

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "Créer une icône sur le Bureau"; GroupDescription: "Icônes supplémentaires :"

[Files]
Source: "..\dist\MultiDigi\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Désinstaller {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Lancer {#MyAppName}"; Flags: nowait postinstall skipifsilent
