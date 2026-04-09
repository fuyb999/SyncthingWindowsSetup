; Syncthing.iss - Syncthing Windows Setup
; Written by Bill Stewart (bstewart AT iname.com) for Syncthing

; Windows Inno Setup installer for Syncthing (https://syncthing.net/)
; * see LICENSE for license
; * See README.md for documentation
; * See building.md for build/localization info

#if Ver < EncodeVer(6,3,3,0)
#error This script requires Inno Setup 6.3.3 or later
#endif

#define UninstallIfSetupVersionOlderThan "1.27.11"
#define AppID "{1EEA2B6F-FD76-47D7-B74C-03E14CF043F9}"
#define UnzipPattern "*/syncthing.exe */AUTHORS.txt */README.txt */LICENSE.txt"
#define AppName "Syncthing"
#define AppPublisher "Syncthing Foundation"
#define AppURL "https://syncthing.net/"
#define IniFileName "SetupVersion.ini"
#define SetupVersion ReadIni(AddBackslash(SourcePath) + IniFileName, "Setup", "Version")
#define ServiceName "syncthing"
#define ServiceShutdownTimeout "10000"
#define DefaultAutoUpgradeInterval "12"
#define DefaultListenAddress "127.0.0.1"
#define DefaultListenPort "18384"
#define DefaultServiceAccountUserName "SyncthingServiceAcct"
#define ConfigurationPageName "ConfigurationPage"
#define ScriptNameRestartSyncthing "RestartSyncthing.js"
#define ScriptNameSetSyncthingConfig "SetSyncthingConfig.js"
#define ScriptNameSyncthingFirewallRule "SyncthingFirewallRule.js"
#define ScriptNameSyncthingLogonTask "SyncthingLogonTask.js"
#define HttpsCertToolName "sthttpscert.exe"
#define HttpsCaCertFileName "syncthing-local-ca-cert.pem"
#define HttpsCaKeyFileName "syncthing-local-ca-key.pem"
#define OfflineZipNameX86 "syncthing-windows-386.zip"
#define OfflineZipNameX64 "syncthing-windows-amd64.zip"
#define OfflineZipNameArm64 "syncthing-windows-arm64.zip"
#define OfflineDir AddBackslash(AddBackslash(SourcePath) + "offline")
#define HaveOfflineZipX86 FileExists(OfflineDir + OfflineZipNameX86)
#define HaveOfflineZipX64 FileExists(OfflineDir + OfflineZipNameX64)
#define HaveOfflineZipArm64 FileExists(OfflineDir + OfflineZipNameArm64)
#if HaveOfflineZipX86
  #define BundledZipNameForX86 OfflineZipNameX86
#else
  #define BundledZipNameForX86 ""
#endif
#if HaveOfflineZipX64
  #define BundledZipNameForX64 OfflineZipNameX64
#else
  #define BundledZipNameForX64 ""
#endif
#if HaveOfflineZipArm64
  #define BundledZipNameForArm64 OfflineZipNameArm64
#else
  #define BundledZipNameForArm64 ""
#endif
#define DefaultCloudURL ""

[Setup]
AppId={{#AppID}
AppName={#AppName}
AppVerName={#AppName}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
MinVersion=6.1
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=no
CloseApplicationsFilter=*.exe
RestartApplications=yes
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableWelcomePage=yes
AllowNoIcons=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=commandline
OutputDir=.
OutputBaseFilename=syncthing-windows-setup
Compression=lzma2/max
SolidCompression=yes
LZMADictionarySize=131072
LZMANumFastBytes=273
LZMAUseSeparateProcess=yes
UsePreviousTasks=yes
WizardStyle=modern
WizardSizePercent=120
UninstallFilesDir={app}\uninstall
UninstallDisplayIcon={app}\syncthing.ico
UninstallDisplayName={code:GetUninstallDisplayName}
ShowLanguageDialog=no
LanguageDetectionMethod=none
VersionInfoProductName={#AppName}
VersionInfoCompany={#AppPublisher}
VersionInfoVersion={#SetupVersion}

[Messages]
SetupWindowTitle=Syncthing Windows Setup

[Languages]
Name: "zhHans"; MessagesFile: "ChineseSimplified.isl,Messages-zh-Hans.isl"
Name: "en"; MessagesFile: "compiler:Default.isl,Messages-en.isl"

; See building.md file for localization details
#define protected
#define LocalizationFile AddBackslash(SourcePath) + "Localization.ini"
#define NumLanguages 2
#dim    Languages[NumLanguages]
#define Languages[0] "zhHans"
#define Languages[1] "en"

[Files]
; Preprocessor localization
#define i 0
#sub LocalizeFiles
#define Language Languages[i]
#define ScriptNameSetConfig    ReadIni(LocalizationFile, Language, "ScriptNameSetSyncthingConfig")
#define ScriptNameFirewallRule ReadIni(LocalizationFile, Language, "ScriptNameSyncthingFirewallRule")
#define ScriptNameLogonTask    ReadIni(LocalizationFile, Language, "ScriptNameSyncthingLogonTask")
Source: "{#ScriptNameFirewallRule}"; DestDir: "{app}"; DestName: "{#ScriptNameSyncthingFirewallRule}"; Languages: "{#Language}"
Source: "{#ScriptNameSetConfig}"; DestDir: "{app}"; DestName: "{#ScriptNameSetSyncthingConfig}"; Languages: "{#Language}"
Source: "{#ScriptNameLogonTask}"; DestDir: "{app}"; DestName: "{#ScriptNameSyncthingLogonTask}"; Languages: "{#Language}"; Check: not IsAdminInstallMode()
#endsub
#for { i = 0; i < NumLanguages; i++ } LocalizeFiles

; Installer-only
; Support automatic uninstall of older versions
Source: "UninsIS.dll"; Flags: dontcopy
; Process checking
Source: "ProcessCheck.dll"; Flags: dontcopy
; unzip utility for validating and extracting Syncthing
Source: "unzip.exe"; Flags: dontcopy
; current-user restart helper
Source: "{#ScriptNameRestartSyncthing}"; DestDir: "{app}"; Check: not IsAdminInstallMode()
; GUI HTTPS certificate signing
Source: "certs\{#HttpsCaCertFileName}"; DestName: "{#HttpsCaCertFileName}"; Flags: dontcopy
Source: "certs\{#HttpsCaKeyFileName}"; DestName: "{#HttpsCaKeyFileName}"; Flags: dontcopy
Source: "binaries\i386\{#HttpsCertToolName}"; DestName: "{#HttpsCertToolName}"; Flags: dontcopy; Check: not IsX64Compatible()
Source: "binaries\x86_64\{#HttpsCertToolName}"; DestName: "{#HttpsCertToolName}"; Flags: dontcopy; Check: IsX64Compatible()
; Bundled offline installation zip files
Source: "offline\{#OfflineZipNameX86}"; Flags: dontcopy skipifsourcedoesntexist
Source: "offline\{#OfflineZipNameX64}"; Flags: dontcopy skipifsourcedoesntexist
Source: "offline\{#OfflineZipNameArm64}"; Flags: dontcopy skipifsourcedoesntexist

; Setup version INI file
Source: "{#IniFileName}"; DestDir: "{app}"

; shawl license
Source: "shawl-license.txt"; DestDir: "{app}"; Check: IsAdminInstallMode()

; Icon
Source: "syncthing.ico"; DestDir: "{app}"
; x86compatible binaries
Source: "binaries\i386\asmt.exe";    DestDir: "{app}"; Check: (not IsX64Compatible()) and IsAdminInstallMode()
Source: "binaries\i386\ErrInfo.exe"; DestDir: "{app}"; Check: (not IsX64Compatible()) and IsAdminInstallMode()
Source: "binaries\i386\ServMan.exe"; DestDir: "{app}"; Check: (not IsX64Compatible()) and IsAdminInstallMode()
Source: "binaries\i386\shawl.exe";   DestDir: "{app}"; Check: (not IsX64Compatible()) and IsAdminInstallMode()
Source: "binaries\i386\stctl.exe";   DestDir: "{app}"; Check: (not IsX64Compatible()) and (not IsAdminInstallMode())
; x64compatible binaries
Source: "binaries\x86_64\asmt.exe";    DestDir: "{app}"; Check: IsX64Compatible() and IsAdminInstallMode(); Flags: solidbreak
Source: "binaries\x86_64\ErrInfo.exe"; DestDir: "{app}"; Check: IsX64Compatible() and IsAdminInstallMode()
Source: "binaries\x86_64\ServMan.exe"; DestDir: "{app}"; Check: IsX64Compatible() and IsAdminInstallMode()
Source: "binaries\x86_64\shawl.exe";   DestDir: "{app}"; Check: IsX64Compatible() and IsAdminInstallMode()
Source: "binaries\x86_64\stctl.exe";   DestDir: "{app}"; Check: IsX64Compatible() and (not IsAdminInstallMode())

[Dirs]
Name: "{autoappdata}\{#AppName}"; Attribs: notcontentindexed; Check: IsAdminInstallMode()

; When to use cscript.exe vs. wscript.exe:
; * Use cscript.exe for hidden scripts (so error doesn't block execution)
; * Use wscript.exe for interactive scripts

[Icons]
; Non-admin and admin icons
Name: "{group}\{cm:ShortcutNameConfigurationPage}"; \
  Filename: "{app}\{#ConfigurationPageName}.url"; \
  Comment: "{cm:ShortcutNameConfigurationPageComment}"; \
  IconFilename: "{app}\syncthing.ico"
Name: "{autodesktop}\{cm:ShortcutNameConfigurationPage}"; \
  Filename: "{app}\{#ConfigurationPageName}.url"; \
  Comment: "{cm:ShortcutNameConfigurationPageComment}"; \
  IconFilename: "{app}\syncthing.ico"; \
  Tasks: desktopicon
; Non-admin icons
Name: "{group}\{cm:ShortcutNameStartSyncthing}"; \
  Filename: "{app}\stctl.exe"; \
  Parameters: "{code:GetStartShortcutParameters}"; \
  Comment: "{cm:ShortcutNameStartSyncthingComment}"; \
  Check: not IsAdminInstallMode()
Name: "{group}\{cm:ShortcutNameRestartSyncthing}"; \
  Filename: "{sys}\wscript.exe"; \
  Parameters: """{app}\{#ScriptNameRestartSyncthing}"" {code:GetRestartShortcutParameters}"; \
  Comment: "{cm:ShortcutNameRestartSyncthingComment}"; \
  Check: not IsAdminInstallMode()
Name: "{autodesktop}\{cm:ShortcutNameRestartSyncthing}"; \
  Filename: "{sys}\wscript.exe"; \
  Parameters: """{app}\{#ScriptNameRestartSyncthing}"" {code:GetRestartShortcutParameters}"; \
  Comment: "{cm:ShortcutNameRestartSyncthingComment}"; \
  Tasks: desktopicon; \
  Check: not IsAdminInstallMode()
Name: "{group}\{cm:ShortcutNameStopSyncthing}"; \
  Filename: "{app}\stctl.exe"; \
  Parameters: "--stop"; \
  Comment: "{cm:ShortcutNameStopSyncthingComment}"; \
  Check: not IsAdminInstallMode()

[INI]
Filename: "{app}\{#ConfigurationPageName}.url"; \
  Section: "InternetShortcut"; \
  Key: "URL"; \
  String: "{code:GetConfigurationPageURL}"
Filename: "{app}\{#ConfigurationPageName}.url"; \
  Section: "InternetShortcut"; \
  Key: "IconFile"; \
  String: "{app}\syncthing.ico"
Filename: "{app}\{#ConfigurationPageName}.url"; \
  Section: "InternetShortcut"; \
  Key: "IconIndex"; \
  String: "0"

[Tasks]
; Admin
Name: startatboot; \
  Description: "{cm:TasksStartAtBoot}"; \
  Check: IsAdminInstallMode()
Name: startserviceafterinstall; \
  Description: "{cm:TasksStartServiceAfterInstall}"; \
  Check: IsAdminInstallMode()
; Non-admin
Name: startatlogon; \
  Description: "{cm:TasksStartAtLogon}"; \
  Check: not IsAdminInstallMode(); \
  Flags: checkablealone
Name: startatlogon\acpoweronly; \
  Description: "{cm:TasksStartAtLogon_ACPowerOnly}"; \
  Check: not IsAdminInstallMode(); \
  Flags: dontinheritcheck unchecked
Name: startafterinstall; \
  Description: "{cm:TasksStartAfterInstall}"; \
  Check: not IsAdminInstallMode()
Name: desktopicon; \
  Description: "{cm:TasksCreateDesktopIcon}"

[Run]
; Admin: Add firewall rule silently
Filename: "{sys}\cscript.exe"; \
  Parameters: """{app}\{#ScriptNameSyncthingFirewallRule}"" /create /elevated /silent"; \
  Flags: runhidden; \
  StatusMsg: "{cm:RunStatusMsg}"; \
  Check: IsAdminInstallMode()
; Non-admin: Prompt to add firewall rule
Filename: "{sys}\wscript.exe"; \
  Parameters: """{app}\{#ScriptNameSyncthingFirewallRule}"" /create"; \
  StatusMsg: "{cm:RunStatusMsg}"; \
  Check: (not IsAdminInstallMode()) and (not FirewallRuleExists()) and (not WizardSilent())
; postinstall
Filename: "{app}\{#ConfigurationPageName}.url"; \
  Description: "{cm:RunPostInstallOpenConfigPage}"; \
  Flags: shellexec postinstall skipifsilent; \
  Check: ShouldOpenConfigPagePostInstall()

[UninstallRun]
; Admin: remove firewall rule
Filename: "{sys}\cscript.exe"; \
  Parameters: """{app}\{#ScriptNameSyncthingFirewallRule}"" /remove /elevated /silent"; \
  Flags: runhidden; \
  RunOnceId: removefwrule; \
  Check: IsAdminInstallMode()
; Non-admin: remove logon task
Filename: "{sys}\cscript.exe"; \
  Parameters: """{app}\{#ScriptNameSyncthingLogonTask}"" /remove /silent"; \
  Flags: runhidden; \
  RunOnceId: removelogontask; \
  Check: not IsAdminInstallMode()

[UninstallDelete]
Type: files; Name: "{app}\{#ConfigurationPageName}.url"
Type: files; Name: "{app}\syncthing.exe.old"
Type: files; Name: "{app}\syncthing.exe"
Type: files; Name: "{app}\AUTHORS.txt"
Type: files; Name: "{app}\README.txt"
Type: files; Name: "{app}\LICENSE.txt"

[Code]

// General notes about offline installation:
// * Setup never downloads Syncthing during installation
// * ZipFilePath gets set by:
//   a. /zipfilepath= command line parameter, or
//   b. bundled offline zip compiled into Setup, or
//   c. Wizard file selection page
// * Install only proceeds if zip file tests ok (i.e., unzip -t returns 0)

const
  ERROR_MORE_DATA               = 234;
  ERROR_SERVICE_ALREADY_RUNNING = 1056;
  ERROR_SERVICE_NOT_ACTIVE      = 1062;

type
  TInstallType = (InstallTypeNotInstalled, InstallTypeAdmin, InstallTypeNonAdmin);

// Global variables
var
  ConfigPage0: TInputQueryWizardPage;
  FilePage0: TInputFileWizardPage;
  // Configuration page values
  AutoUpgradeInterval, ListenAddress, ListenPort, CloudURL: string;
  ServiceAccountUserName, ExecOutputFirstLine, ZipFilePath, BundledZipFileName: string;
  SkipZipFilePage, UsingBundledZip: Boolean;

// Windows API functions
function GetUserNameExW(NameFormat: Integer; lpNameBuffer: string; var nSize: DWORD): Boolean;
  external 'GetUserNameExW@secur32.dll stdcall setuponly';

// UninsIS.dll functions
function DLLCompareVersionStrings(Version1, Version2: string): Integer;
  external 'CompareVersionStrings@files:UninsIS.dll stdcall setuponly';
function DLLIsISPackageInstalled(AppId: string; Is64BitInstallMode, IsAdminInstallMode: DWORD): DWORD;
  external 'IsISPackageInstalled@files:UninsIS.dll stdcall setuponly';
function DLLUninstallISPackage(AppId: string; Is64BitInstallMode, IsAdminInstallMode: DWORD): DWORD;
  external 'UninstallISPackage@files:UninsIS.dll stdcall setuponly';

// ProcessCheck.dll functions
function DLLFindProcess(PathName: string; var Found: DWORD): DWORD;
  external 'FindProcess@files:ProcessCheck.dll stdcall setuponly';

function GetFullUserName(): string;
var
  NumChars: DWORD;
  OutStr: string;
begin
  result := '';
  try
    NumChars := 0;
    // NameFormat = 2: NameSamCompatible (i.e., authority\username)
    // First call: GetUserNameExW should return false and DLLGetLastError()
    // should return ERROR_MORE_DATA (234); NumChars will contain # chars
    // needed, including null terminator
    if (not GetUserNameExW(2, '', NumChars)) and (DLLGetLastError() = ERROR_MORE_DATA) then
    begin
      SetLength(OutStr, NumChars);
      if GetUserNameExW(2, OutStr, NumChars) then
        // Omit null terminator from result
        result := Copy(OutStr, 1, NumChars);
    end;
  except
  end;
end;

function IsSyncthingRunning(): Boolean;
var
  PathName: string;
  Found: DWORD;
begin
  Sleep(500);
  result := false;
  PathName := ExpandConstant('{app}\syncthing.exe');
  if DLLFindProcess(PathName, Found) = 0 then
  begin
    result := Found = 1;
    if result then
      Log(FmtMessage(CustomMessage('ProcessCheckSucceededRunning'), [PathName]))
    else
      Log(FmtMessage(CustomMessage('ProcessCheckSucceededNotRunning'), [PathName]));
  end
  else
    Log(CustomMessage('ProcessCheckFailed'));
end;

// UninsIS.dll - Returns installation type
function IsISPackageInstalled(): TInstallType;
begin
  if DLLIsISPackageInstalled('{#AppID}',  // AppId
    DWORD(Is64BitInstallMode()),          // Is64BitInstallMode
    1) = 1 then                           // IsAdminInstallMode
  begin
    result := InstallTypeAdmin;
    Log(CustomMessage('InstallTypeAdmin'));
  end
  else if DLLIsIsPackageInstalled('{#AppID}',  // AppId
    DWORD(Is64BitInstallMode()),               // Is64BitInstallMode
    0) = 1 then                                // IsAdminInstallMode
  begin
    result := InstallTypeNonAdmin;
    Log(CustomMessage('InstallTypeNonAdmin'));
  end
  else
  begin
    result := InstallTypeNotInstalled;
    Log(CustomMessage('InstallTypeNotInstalled'));
  end;
end;

// UninsIS.dll - Returns:
// < 0 if Version1 < Version2
// 0   if Version1 = Version2
// > 0 if Version1 > Version2
function CompareVersionStrings(const Version1, Version2: string): Integer;
begin
  result := DLLCompareVersionStrings(Version1, Version2);
end;

// UninsIS.dll - Returns 0 for success, non-zero for failure
function UninstallISPackage(): DWORD;
begin
  result := DLLUninstallISPackage('{#AppID}',  // AppId
    DWORD(Is64BitInstallMode()),               // Is64BitInstallMode
    DWORD(IsAdminInstallMode()));              // IsAdminInstallMode
end;

function ParamStrExists(const Param: string): Boolean;
var
  I: Integer;
begin
  result := false;
  for I := 1 to ParamCount do
  begin
    result := CompareText(Param, ParamStr(I)) = 0;
    if result then
      exit;
  end;
end;

function ShowPostInstallCheckbox(): Boolean;
begin
  result := not ParamStrExists('/noconfigpage');
end;

function ShouldOpenConfigPagePostInstall(): Boolean;
begin
  result := ShowPostInstallCheckbox() and
    (((not IsAdminInstallMode()) and WizardIsTaskSelected('startafterinstall')) or
     (IsAdminInstallMode() and WizardIsTaskSelected('startserviceafterinstall')) or
     IsSyncthingRunning());
end;

function IsDomainController(): Boolean;
var
  VersionInfo: TWindowsVersion;
begin
  GetWindowsVersionEx(VersionInfo);
  result := VersionInfo.ProductType = VER_NT_DOMAIN_CONTROLLER;
end;

function IsWshJsScriptRegistrationValid(): Boolean;
var
  Value: string;
begin
  result := RegQueryStringValue(HKEY_CLASSES_ROOT, '.js', '', Value);
  if result then
    result := SameText(Value, 'JSFile');
end;

procedure OnExecAndLogOutput(const S: String; const Error, FirstLine: Boolean);
begin
  if (not Error) and (ExecOutputFirstLine = '') and (Trim(S) <> '') then
    ExecOutputFirstLine := S;  // Store first line of non-empty output
end;

function ExecEx(const FileName, Params: string; const Hide: Boolean): Integer;
var
  ShowCmd: Integer;
  OK: Boolean;
begin
  if Hide then
    ShowCmd := SW_HIDE
  else
    ShowCmd := SW_SHOWNORMAL;
  OK := ExecAndLogOutput(FileName,  // Filename
    Params,                         // Params
    '',                             // WorkingDir
    ShowCmd,                        // ShowCmd
    ewWaitUntilTerminated,          // TExecWait
    result,                         // ResultCode
    @OnExecAndLogOutput);           // TOnLog
  Log(Format('ExecEx: "%s" %s', [FileName, Params]));
  if OK then
    Log(Format('ExecEx exit code: %s', [IntToStr(result)]))
  else
    Log(Format('ExecEx failed: %s (%s)', [SysErrorMessage(result), IntToStr(result)]));
end;

function TestZipFile(const ZipFilePath: string): Boolean;
begin
  result := ExecEx(ExpandConstant('{tmp}\unzip.exe'),
    ExpandConstant(Format('-t "%s" {#UnzipPattern}', [ZipFilePath])), true) = 0;
end;

function GetBundledZipFileName(): string;
begin
  result := '';
  case ProcessorArchitecture() of
    paX86, paUnknown: result := '{#BundledZipNameForX86}';
    paX64: result := '{#BundledZipNameForX64}';
    paArm64: result := '{#BundledZipNameForArm64}';
  end;
end;

function TryUseBundledZip(): Boolean;
var
  CandidateZipPath: string;
begin
  result := false;
  UsingBundledZip := false;
  BundledZipFileName := GetBundledZipFileName();
  if BundledZipFileName = '' then
    exit;
  try
    ExtractTemporaryFile(BundledZipFileName);
    CandidateZipPath := ExpandConstant('{tmp}\') + BundledZipFileName;
    if FileExists(CandidateZipPath) and TestZipFile(CandidateZipPath) then
    begin
      ZipFilePath := CandidateZipPath;
      UsingBundledZip := true;
      Log(FmtMessage(CustomMessage('BundledZipFound'), [BundledZipFileName]));
      result := true;
    end
    else
      Log(FmtMessage(CustomMessage('BundledZipNotValid'), [BundledZipFileName]));
  except
    Log(FmtMessage(CustomMessage('BundledZipNotFound'), [BundledZipFileName]));
  end;
  if not result then
    ZipFilePath := '';
end;

function QuoteValue(const Value: string): string;
begin
  result := '"' + Value + '"';
end;

function GetStartSyncthingParameters(const Quiet: Boolean): string;
begin
  result := '--start';
  if Quiet then
    result := result + ' -q';
  if Trim(CloudURL) <> '' then
    result := result + ' -- --cloud-url ' + QuoteValue(CloudURL);
end;

// Param parameter is required
function GetStartShortcutParameters(Param: string): string;
begin
  result := GetStartSyncthingParameters(false);
end;

// Param parameter is required
function GetRestartShortcutParameters(Param: string): string;
begin
  result := '/lang:' + QuoteValue(ActiveLanguage());
  if Trim(CloudURL) <> '' then
    result := result + ' /cloudurl:' + QuoteValue(CloudURL);
end;

function GetLogonTaskParameters(const BaseParams: string): string;
begin
  result := BaseParams;
  if Trim(CloudURL) <> '' then
    result := result + ' /cloudurl:' + QuoteValue(CloudURL);
end;

function InitializeSetup(): Boolean;
var
  Msg: string;
begin
  if IsAdminInstallMode() then
  begin
    ServiceAccountUserName := GetPreviousData('ServiceAccountUserName',
      Trim(ExpandConstant('{param:serviceaccountusername|{#DefaultServiceAccountUserName}}')));
    result := not IsDomainController();
    if not result then
    begin
      Msg := CustomMessage('InitializeSetupError0');
      Log(Msg);
      if not WizardSilent() then
        MsgBox(Msg, mbCriticalError, MB_OK);
      exit;
    end;
  end;
  result := IsWshJsScriptRegistrationValid();
  if not result then
  begin
    Msg := CustomMessage('InitializeSetupError1');
    Log(Msg);
    if not WizardSilent() then
      MsgBox(Msg, mbCriticalError, MB_OK);
    exit;
  end;
  // /currentuser is the default, so abort Setup if admin install detected
  // and tell user to restart Setup using /allusers option
  if (not IsAdminInstallMode()) and (IsISPackageInstalled() = InstallTypeAdmin) and (not ParamStrExists('/allowcurrentuser')) then
  begin
    result := false;
    Msg := CustomMessage('InitializeSetupError2');
    Log(Msg);
    if not WizardSilent() then
      MsgBox(Msg, mbCriticalError, MB_OK);
    exit;
  end;
  ExecOutputFirstLine := '';
  // Custom command line parameters
  AutoUpgradeInterval := GetPreviousData('AutoUpgradeInterval',
    Trim(ExpandConstant('{param:autoupgradeinterval|{#DefaultAutoUpgradeInterval}}')));
  ListenAddress := GetPreviousData('ListenAddress',
    Trim(ExpandConstant('{param:listenaddress|{#DefaultListenAddress}}')));
  ListenPort := GetPreviousData('ListenPort',
    Trim(ExpandConstant('{param:listenport|{#DefaultListenPort}}')));
  CloudURL := GetPreviousData('CloudURL',
    Trim(ExpandConstant('{param:cloudurl|{#DefaultCloudURL}}')));
  ExtractTemporaryFile('unzip.exe');
  SkipZipFilePage := false;
  UsingBundledZip := false;
  BundledZipFileName := '';
  ZipFilePath := Trim(ExpandConstant('{param:zipfilepath}'));
  if ZipFilePath <> '' then
  begin
    // Assume installer directory if no path specifed with zip file name
    if Pos('\', ZipFilePath) = 0 then
      ZipFilePath := ExpandConstant('{src}\') + ZipFilePath;
    if FileExists(ZipFilePath) then
    begin
      Log(CustomMessage('ZipFilePathFound'));
      if TestZipFile(ZipFilePath) then
        SkipZipFilePage := true
      else
        Log(CustomMessage('ZipFileNotValid'));
    end
    else
      Log(CustomMessage('ZipFilePathNotFound'));
  end
  else if TryUseBundledZip() then
  begin
    SkipZipFilePage := true;
  end
  else
  begin
    Msg := CustomMessage('InitializeSetupWarning0');
    Log(Msg);
  end;
end;

procedure InitializeWizard();
begin
  // Custom file page(s)
  FilePage0 := CreateInputFilePage(wpWelcome,
    CustomMessage('FilePage0Caption'),
    CustomMessage('FilePage0Description'),
    CustomMessage('FilePage0SubCaption'));
  FilePage0.Add(CustomMessage('FilePage0Prompt'), CustomMessage('FilePage0Filter'), '.zip');
  if ZipFilePath <> '' then
    FilePage0.Values[0] := ZipFilePath;
  // Custom configuration page(s)
  ConfigPage0 := CreateInputQueryPage(wpSelectProgramGroup,
    CustomMessage('ConfigPage0Caption'),
    CustomMessage('ConfigPage0Description'),
    CustomMessage('ConfigPage0SubCaption'));
  ConfigPage0.Add(FmtMessage(CustomMessage('ConfigPage0Item0'), ['{#DefaultAutoUpgradeInterval}']), false);
  ConfigPage0.Add(FmtMessage(CustomMessage('ConfigPage0Item1'), ['{#DefaultListenAddress}']), false);
  ConfigPage0.Add(FmtMessage(CustomMessage('ConfigPage0Item2'), ['{#DefaultListenPort}']), false);
  ConfigPage0.Add(CustomMessage('ConfigPage0Item4'), false);
  ConfigPage0.Values[0] := AutoUpgradeInterval;
  ConfigPage0.Values[1] := ListenAddress;
  ConfigPage0.Values[2] := ListenPort;
  ConfigPage0.Values[3] := CloudURL;
end;

function InitializeUninstall(): Boolean;
begin
  result := true;
  if IsAdminInstallMode() then
  begin
    ServiceAccountUserName := GetPreviousData('ServiceAccountUserName', '{#DefaultServiceAccountUserName}');
  end;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  SetPreviousData(PreviousDataKey, 'AutoUpgradeInterval', AutoUpgradeInterval);
  SetPreviousData(PreviousDataKey, 'ListenAddress', ListenAddress);
  SetPreviousData(PreviousDataKey, 'ListenPort', ListenPort);
  SetPreviousData(PreviousDataKey, 'CloudURL', CloudURL);
  if IsAdminInstallMode() then
  begin
    SetPreviousData(PreviousDataKey, 'ServiceAccountUserName', ServiceAccountUserName);
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  result := false;
  if PageID = FilePage0.ID then
    result := SkipZipFilePage;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  UpgradeInterval, Port: Integer;
begin
  result := true;
  if CurPageID = FilePage0.ID then
  begin
    result := Trim(FilePage0.Values[0]) <> '';
    if not result then
    begin
      Log(CustomMessage('FilePage0Item0Empty'));
      if not WizardSilent() then
        MsgBox(CustomMessage('FilePage0Item0Empty'), mbError, MB_OK);
      WizardForm.ActiveControl := FilePage0.Edits[0];
      FilePage0.Values[0] := '';
      exit;
    end;
    result := FileExists(FilePage0.Values[0]);
    if not result then
    begin
      Log(CustomMessage('ZipFilePathNotFound'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ZipFilePathNotFound'), mbError, MB_OK);
      WizardForm.ActiveControl := FilePage0.Edits[0];
      FilePage0.Edits[0].SelectAll();
      exit;
    end;
    result := TestZipFile(FilePage0.Values[0]);
    if not result then
    begin
      Log(CustomMessage('ZipFileNotValid'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ZipFileNotValid'), mbError, MB_OK);
      FilePage0.Edits[0].SelectAll();
      exit;
    end;
    // Update global based on page
    ZipFilePath := Trim(FilePage0.Values[0]);
    UsingBundledZip := false;
    BundledZipFileName := '';
    SkipZipFilePage := true;
  end
  else if CurPageID = ConfigPage0.ID then
  begin
    //-------------------------------------------------------------------------
    // 0 - Validate auto upgrade interval (>= 0 and <= 65535)
    UpgradeInterval := StrToIntDef(Trim(ConfigPage0.Values[0]), -1);
    result := (UpgradeInterval >= 0) and (UpgradeInterval <= 65535);
    if not result then
    begin
      Log(CustomMessage('ConfigPage0Item0NotValid'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ConfigPage0Item0NotValid'), mbError, MB_OK);
      WizardForm.ActiveControl := ConfigPage0.Edits[0];
      ConfigPage0.Values[0] := '{#DefaultAutoUpgradeInterval}';
      ConfigPage0.Edits[0].SelectAll();
      exit;
    end;
    // Update global based on page
    AutoUpgradeInterval := Trim(ConfigPage0.Values[0]);
    //-------------------------------------------------------------------------
    // 1 - Validate listen address (not empty)
    result := Trim(ConfigPage0.Values[1]) <> '';
    if not result then
    begin
      Log(CustomMessage('ConfigPage0Item1Empty'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ConfigPage0Item1Empty'), mbError, MB_OK);
      WizardForm.ActiveControl := ConfigPage0.Edits[1];
      ConfigPage0.Values[1] := '{#DefaultListenAddress}';
      ConfigPage0.Edits[1].SelectAll();
      exit;
    end;
    // Update global based on page
    ListenAddress := Trim(ConfigPage0.Values[1]);
    //-------------------------------------------------------------------------
    // 2 - Validate listen port (>= 1024 and <= 65535)
    Port := StrToIntDef(Trim(ConfigPage0.Values[2]), -1);
    result := (Port >= 1024) and (Port <= 65535);
    if not result then
    begin
      Log(CustomMessage('ConfigPage0Item2NotValid'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ConfigPage0Item2NotValid'), mbError, MB_OK);
      WizardForm.ActiveControl := ConfigPage0.Edits[2];
      ConfigPage0.Values[2] := '{#DefaultListenPort}';
      ConfigPage0.Edits[2].SelectAll();
      exit;
    end;
    // Update global based on page
    ListenPort := Trim(ConfigPage0.Values[2]);
    //-------------------------------------------------------------------------
    // 3 - Optional cloud drive URL
    CloudURL := Trim(ConfigPage0.Values[3]);
  end;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo,
  MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: string): string;
var
  Info: string;
begin
  Info := '';
  Info := Info + CustomMessage('ReadyMemoZipFileInfo') + NewLine + Space;
  if UsingBundledZip then
    Info := Info + FmtMessage(CustomMessage('ReadyMemoZipFileBundled'), [BundledZipFileName])
  else
    Info := Info + ZipFilePath;
  // Show installation mode
  if Info <> '' then
    Info := Info + NewLine + NewLine;
  Info := Info + CustomMessage('ReadyMemoInstallSettings') + NewLine + Space;
  Info := Info + CustomMessage('ReadyMemoInstallOffline');
  Info := Info + NewLine + Space;
  if IsAdminInstallMode() then
    Info := Info + CustomMessage('ReadyMemoInstallAdmin') + NewLine + Space
      + FmtMessage(CustomMessage('ReadyMemoInstallAdminServiceAccountUserName'), [ServiceAccountUserName])
  else
    Info := Info + FmtMessage(CustomMessage('ReadyMemoInstallCurrentUser'), [GetFullUserName()]);
  if MemoUserInfoInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoUserInfoInfo;
  end;
  if MemoDirInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoDirInfo;
  end;
  if MemoTypeInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoTypeInfo;
  end;
  if MemoComponentsInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoComponentsInfo;
  end;
  if MemoGroupInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoGroupInfo;
  end;
  if Info <> '' then
    Info := Info + NewLine + NewLine;
  Info := Info + CustomMessage('ReadyMemoConfigInfo') + NewLine + Space;
  if StrToInt(AutoUpgradeInterval) <> 0 then
    Info := Info + FmtMessage(CustomMessage('ReadyMemoConfigItem0Enabled'), [AutoUpgradeInterval])
  else
    Info := Info + CustomMessage('ReadyMemoConfigItem0Disabled');
  Info := Info + NewLine;
  Info := Info + Space + CustomMessage('ReadyMemoConfigItem1') + ' ' + ListenAddress + NewLine
    + Space + CustomMessage('ReadyMemoConfigItem2') + ' ' + ListenPort;
  Info := Info + NewLine;
  if CloudURL <> '' then
    Info := Info + Space + FmtMessage(CustomMessage('ReadyMemoConfigItem4Set'), [CloudURL])
  else
    Info := Info + Space + CustomMessage('ReadyMemoConfigItem4Empty');
  if MemoTasksInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoTasksInfo;
  end;
  result := Info;
end;

// Param parameter is required
function GetListenAddress(Param: string): string;
begin
  if (Trim(ListenAddress) = '0.0.0.0') or (Trim(ListenAddress) = '::') then
    result := '127.0.0.1'
  else
    result := ListenAddress;
end;

// Param parameter is required
function GetListenPort(Param: string): string;
begin
  result := ListenPort;
end;

function IsUnreservedURLByte(const B: Byte): Boolean;
begin
  result := ((B >= Ord('A')) and (B <= Ord('Z'))) or
    ((B >= Ord('a')) and (B <= Ord('z'))) or
    ((B >= Ord('0')) and (B <= Ord('9'))) or
    (B = Ord('-')) or (B = Ord('.')) or (B = Ord('_')) or (B = Ord('~'));
end;

function NibbleToHex(const N: Integer): Char;
begin
  if N < 10 then
    result := Chr(Ord('0') + N)
  else
    result := Chr(Ord('A') + N - 10);
end;

function ByteToHex(const B: Integer): string;
begin
  result := NibbleToHex(B div 16) + NibbleToHex(B mod 16);
end;

function UrlEncode(const Value: string): string;
var
  I: Integer;
  Bytes: AnsiString;
  B: Integer;
begin
  Bytes := Utf8Encode(Value);
  result := '';
  for I := 1 to Length(Bytes) do
  begin
    B := Ord(Bytes[I]);
    if IsUnreservedURLByte(B) then
      result := result + Chr(B)
    else
      result := result + '%' + ByteToHex(B);
  end;
end;

// Param parameter is required
function GetConfigurationPageURL(Param: string): string;
begin
  result := 'https://' + GetListenAddress('') + ':' + GetListenPort('');
  if Trim(CloudURL) <> '' then
    result := result + '?cloud-url=' + UrlEncode(CloudURL);
end;

function GetSyncthingConfigPath(): string;
begin
  if IsAdminInstallMode() then
    result := ExpandConstant('{commonappdata}\{#AppName}')
  else
    result := ExpandConstant('{localappdata}\{#AppName}');
end;

function GenerateGuiHttpsCertificate(): Integer;
var
  FileName, Params: string;
begin
  ExtractTemporaryFile('{#HttpsCertToolName}');
  ExtractTemporaryFile('{#HttpsCaCertFileName}');
  ExtractTemporaryFile('{#HttpsCaKeyFileName}');
  FileName := ExpandConstant('{tmp}\{#HttpsCertToolName}');
  Params := '--config-dir "' + GetSyncthingConfigPath() + '"'
    + ' --listen-address "' + ListenAddress + '"'
    + ' --ca-cert "' + ExpandConstant('{tmp}\{#HttpsCaCertFileName}') + '"'
    + ' --ca-key "' + ExpandConstant('{tmp}\{#HttpsCaKeyFileName}') + '"';
  result := ExecEx(FileName, Params, true);
end;

function ImportRootCaCertificate(): Integer;
var
  FileName, Params: string;
begin
  ExtractTemporaryFile('{#HttpsCaCertFileName}');
  FileName := ExpandConstant('{sys}\certutil.exe');
  if IsAdminInstallMode() then
    Params := '-f -addstore Root "' + ExpandConstant('{tmp}\{#HttpsCaCertFileName}') + '"'
  else
    Params := '-user -f -addstore Root "' + ExpandConstant('{tmp}\{#HttpsCaCertFileName}') + '"';
  result := ExecEx(FileName, Params, true);
end;

// Param parameter is required
function GetUninstallDisplayName(Param: string): string;
begin
  result := ExpandConstant('{#AppName} ');
  if not IsAdminInstallMode() then
    result := result + CustomMessage('UninstallDisplayNamePerUserSuffix')
  else
    result := result + CustomMessage('UninstallDisplayNameServiceSuffix');
end;

function ServiceExists(): Boolean;
var
  FileName, Params: string;
begin
  FileName := ExpandConstant('{app}\ServMan.exe');
  Params := '--exists "{#ServiceName}"';
  result := ExecEx(FileName, Params, true) = 0;
end;

function ServiceRunning(): Boolean;
var
  FileName, Params: string;
begin
  FileName := ExpandConstant('{app}\ServMan.exe');
  Params := '--state "{#ServiceName}"';
  // ServMan --state exit code 904 = running
  result := ExecEx(FileName, Params, true) = 904;
end;

function StopService(): Boolean;
var
  FileName, Params: string;
  Status: Integer;
begin
  FileName := ExpandConstant('{app}\ServMan.exe');
  Params := '--stop "{#ServiceName}"';
  Status := ExecEx(FileName, Params, true);
  result := (Status = 0) or (Status = ERROR_SERVICE_NOT_ACTIVE);
end;

function StartService(): Boolean;
var
  FileName, Params: string;
  Status: Integer;
begin
  FileName := ExpandConstant('{app}\ServMan.exe');
  Params := '--start "{#ServiceName}"';
  Status := ExecEx(FileName, Params, true);
  result := (Status = 0) or (Status = ERROR_SERVICE_ALREADY_RUNNING);
end;

function FirewallRuleExists(): Boolean;
begin
  result := ExecEx(ExpandConstant('{sys}\cscript.exe'),
    ExpandConstant('"{app}\{#ScriptNameSyncthingFirewallRule}" /test'),
    true) = 0;
end;

function LogonTaskExists(): Boolean;
begin
  result := ExecEx(ExpandConstant('{sys}\cscript.exe'),
    ExpandConstant('"{app}\{#ScriptNameSyncthingLogonTask}" /test'),
    true) = 0;
end;

function InstallOrResetService(): Integer;
var
  FileName, Params: string;
begin
  FileName := ExpandConstant('{app}\asmt.exe');
  Params := ExpandConstant('--init'
    + ' --account="' + ServiceAccountUserName + '"'
    + ' --accountdescription="{cm:ServiceAccountDescription}"'
    + ' --name="{#ServiceName}"'
    + ' --displayname="{cm:ServiceDisplayName}"'
    + ' --description="{cm:ServiceDescription}"'
    + ' --commandline="""{app}\shawl.exe"" run --cwd ""{app}"" --no-log --priority below-normal --restart-if 3,4 --stop-timeout {#ServiceShutdownTimeout} --'
    + ' ""{app}\syncthing.exe"" --home ""{autoappdata}\{#AppName}"" --no-browser --no-restart"'
    + ' --starttype=');
  if WizardIsTaskSelected('startatboot') then
    Params := Params + 'DelayedAuto'
  else
    Params := Params + 'Demand';
  result := ExecEx(FileName, Params, true);
end;

function SetAppDataDirectoryPermissions(): Integer;
var
  TargetPath, FileName, Params: string;
begin
  // icacls to reset permissions
  TargetPath := ExpandConstant('{autoappdata}\{#AppName}');
  FileName := ExpandConstant('{sys}\icacls.exe');
  Params := '"' + TargetPath + '" /reset /t';
  ExecEx(FileName, Params, true);
  // Grant only SYSTEM, Administrators, and service account
  Params := '"' + TargetPath + '" /inheritance:r'
    + ' /grant "*S-1-5-18:(OI)(CI)F"'      // S-1-5-18 = SYSTEM
    + ' /grant "*S-1-5-32-544:(OI)(CI)F"'  // S-1-5-32-544 = Administrators
    + ' /grant "' + ServiceAccountUserName + ':(OI)(CI)M"';
  result := ExecEx(FileName, Params, true);
  // attrib to set app data directory and files to "not content indexed"
  // (strangely, "+i" means "not content indexed")
  FileName := ExpandConstant('{sys}\attrib.exe');
  Params := '+i "' + TargetPath + '"';
  ExecEx(FileName, Params, true);
  Params := '+i "' + TargetPath + '\*" /s /d';
  ExecEx(FileName, Params, true);
end;

function SetAppDirectoryPermissions(): Integer;
var
  TargetPath, FileName, Params: string;
begin
  TargetPath := ExpandConstant('{app}');
  // Reset permissions
  FileName := ExpandConstant('{sys}\icacls.exe');
  Params := '"' + TargetPath + '" /reset /t';
  ExecEx(FileName, Params, true);
  // Grant permissions to service account
  Params := '"' + TargetPath + '" /grant "' + ServiceAccountUserName + ':(OI)(CI)M"';
  result := ExecEx(FileName, Params, true);
end;

function SetupConfiguration(): Integer;
var
  FileName, Params: string;
begin
  FileName := ExpandConstant('{sys}\cscript.exe');
  Params := ExpandConstant('"{app}\{#ScriptNameSetSyncthingConfig}"');
  if IsAdminInstallMode() then
    Params := Params + ' /service'
  else
    Params := Params + ' /currentuser';
  Params := Params + ' /autoupgradeinterval:' + AutoUpgradeInterval
    + ' /guiaddress:"' + ListenAddress + ':' + ListenPort + '"';
  if WizardSilent() then
    Params := Params + ' /silent';
  result := ExecEx(FileName, Params, true);
end;

function DisableServiceAccountAndRemoveService(): Integer;
var
  FileName, Params: string;
begin
  FileName := ExpandConstant('{app}\asmt.exe');
  Params := ExpandConstant('--remove'
    + ' --name="{#ServiceName}"'
    + ' --account="' + ServiceAccountUserName + '"');
  result := ExecEx(FileName, Params, true);
end;

function JoinPath(Path1, Path2: string): string;
begin
  // Remove trailing '\' from Path1
  while Path1[Length(Path1)] = '\' do
    Path1 := Copy(Path1, 1, Length(Path1) - 1);
  // Remove leading '\' from Path2
  while Path2[1] = '\' do
    Path2 := Copy(Path2, 2, Length(Path2) - 1);
  // Concatenate with '\' separator
  result := Path1 + '\' + Path2;
end;

function PrepareToInstall(var NeedsRestart: Boolean): string;
var
  InstalledSetupVersion: string;
begin
  result := '';
  if IsISPackageInstalled() <> InstallTypeNotInstalled then
  begin
    InstalledSetupVersion := GetIniString('Setup', 'Version', '', ExpandConstant('{app}\{#IniFileName}'));
    if (InstalledSetupVersion = '') or
      (CompareVersionStrings(InstalledSetupVersion, '{#UninstallIfSetupVersionOlderThan}') < 0) then
    begin
      // Uninstall if:
      // Package is installed AND
      //   Can't get setup version from SetupVersion.ini, OR
      //   Version in SetupVersion.ini is older than {#UninstallIfVersionOlderThan}
      Log(CustomMessage('PrepareToInstallUninstallNeeded'));
      if UninstallISPackage() = 0 then
        Log(CustomMessage('PrepareToInstallUninstallSucceeded'))
      else
      begin
        result := CustomMessage('PrepareToInstallErrorMessage0');
        exit;
      end
    end
    else if CompareVersionStrings(InstalledSetupVersion, '{#SetupVersion}') > 0 then
    begin
      // Installed version > installing version = downgrade
      result := FmtMessage(CustomMessage('PrepareToInstallErrorMessage1'), [InstalledSetupVersion, '{#SetupVersion}']);
      exit;
    end;
    if not IsAdminInstallMode() then
    begin
      if IsSyncthingRunning() then
        ExecEx(ExpandConstant('{app}\stctl.exe'), '--stop -q', true);
    end
    else
    begin
      if ServiceRunning() then
        StopService();
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  Version, Params, FileName: string;
begin
  if CurStep = ssPostInstall then
  begin
    ExecEx(ExpandConstant('{tmp}\unzip.exe'),
      ExpandConstant(Format('-jo -d "{app}" "%s" {#UnzipPattern}', [ZipFilePath])), true);
    if GetVersionNumbersString(ExpandConstant('{app}\syncthing.exe'), Version) then
    begin
      Log(FmtMessage(CustomMessage('InstalledVersion'), [Version]));
      SetIniString('InstalledVersion', 'Version', Version, ExpandConstant('{app}\{#IniFileName}'));
    end;
    if IsAdminInstallMode() then
    begin
      InstallOrResetService();
      SetAppDirectoryPermissions();
      SetAppDataDirectoryPermissions();
    end
    else
    begin
      if WizardIsTaskSelected('startatlogon') then
      begin
        Params := '/create /silent';
        if WizardIsTaskSelected('startatlogon\acpoweronly') then
          Params := Params + ' /startonacpoweronly';
      end
      else
      begin
        Params := '/remove /silent';
      end;
      ExecEx(ExpandConstant('{sys}\cscript.exe'),
        ExpandConstant('"{app}\{#ScriptNameSyncthingLogonTask}" ') + GetLogonTaskParameters(Params),
        true);
    end;
    SetupConfiguration();
    if GenerateGuiHttpsCertificate() <> 0 then
      Log('Failed to generate GUI HTTPS certificate; leaving existing Syncthing HTTPS certificate in place');
    if ImportRootCaCertificate() <> 0 then
      Log('Failed to import Syncthing GUI root certificate into the Windows trust store');
    if WizardIsTaskSelected('startafterinstall') then
    begin
      ExecEx(ExpandConstant('{app}\stctl.exe'), GetStartSyncthingParameters(true), true);
    end
    else if WizardIsTaskSelected('startserviceafterinstall') then
    begin
      if ServiceExists() and (not ServiceRunning()) then
        StartService();
    end;
    if not WizardIsTaskSelected('desktopicon') then
    begin
      FileName := ExpandConstant('{autodesktop}\{cm:ShortcutNameConfigurationPage}.lnk');
      if FileExists(FileName) then
      begin
        if DeleteFile(FileName) then
          Log(FmtMessage(CustomMessage('FileDeleteSucceeded'), [FileName]))
        else
          Log(FmtMessage(CustomMessage('FileDeleteFailed'), [FileName]));
      end;
      FileName := ExpandConstant('{autodesktop}\{cm:ShortcutNameRestartSyncthing}.lnk');
      if FileExists(FileName) then
      begin
        if DeleteFile(FileName) then
          Log(FmtMessage(CustomMessage('FileDeleteSucceeded'), [FileName]))
        else
          Log(FmtMessage(CustomMessage('FileDeleteFailed'), [FileName]));
      end;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    if IsAdminInstallMode() then
    begin
      if ServiceRunning() then
        StopService();
      DisableServiceAccountAndRemoveService();
    end
    else
    begin
      ExecEx(ExpandConstant('{app}\stctl.exe'), '--stop -q', true);
      if not UninstallSilent() then
      begin
        if FirewallRuleExists() then
        begin
          // Prompt to remove Windows Firewall rule
          ExecEx(ExpandConstant('{sys}\wscript.exe'),
            ExpandConstant('"{app}\{#ScriptNameSyncthingFirewallRule}" /remove'),
            false);
        end;
      end;
    end;
  end;
end;

procedure DeinitializeUninstall();
var
  AppDir: string;
begin
  // Try to remove {app} at uninstall if it still exists
  AppDir := ExpandConstant('{app}');
  if DirExists(AppDir) then
  begin
    if RemoveDir(AppDir) then
      Log(FmtMessage(CustomMessage('DeinitializeUninstallAppDirRemoveSucceeded'), [AppDir]))
    else
      Log(FmtMessage(CustomMessage('DeinitializeUninstallAppDirRemoveFailed'), [AppDir]));
  end;
end;
