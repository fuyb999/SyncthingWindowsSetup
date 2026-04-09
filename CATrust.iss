; GenericCATrust.iss - Generic Root CA Trust Setup

; Trust-only Windows installer for a local root CA certificate.
; This setup imports the bundled root CA certificate into the Windows
; LocalMachine\Root certificate store and does not install application files.

#if Ver < EncodeVer(6,3,3,0)
#error This script requires Inno Setup 6.3.3 or later
#endif

#define AppName "Root CA Trust Installer"
#define AppPublisher "Local CA Tools"
#define AppURL "https://localhost/"
#define IniFileName "SetupVersion.ini"
#define SetupVersion ReadIni(AddBackslash(SourcePath) + IniFileName, "Setup", "Version")
#define CaCertSourceFileName "syncthing-local-ca-cert.pem"
#define CaCertImportFileName "syncthing-local-ca-cert.cer"

[Setup]
AppName={#AppName}
AppVersion={#SetupVersion}
AppVerName={#AppName}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
MinVersion=6.1
ArchitecturesInstallIn64BitMode=x64compatible
CreateAppDir=no
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableWelcomePage=yes
AllowNoIcons=yes
PrivilegesRequired=admin
Uninstallable=no
OutputDir=.
OutputBaseFilename=ca-trust-setup
Compression=lzma2/max
SolidCompression=yes
LZMAUseSeparateProcess=yes
WizardStyle=classic
ShowLanguageDialog=no
LanguageDetectionMethod=none
VersionInfoProductName={#AppName}
VersionInfoCompany={#AppPublisher}
VersionInfoVersion={#SetupVersion}

[Messages]
SetupWindowTitle=CA Trust Setup

[Languages]
Name: "zhHans"; MessagesFile: "ChineseSimplified.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
en.ImportRootCaFailed=Failed to import the root CA certificate into the Windows trusted root store.
en.ImportRootCaFailedWithDetail=Failed to import the root CA certificate into the Windows trusted root store.%n%n%1
en.ImportRootCaToolMissing=The built-in Windows certificate tool certutil.exe was not found.
zhHans.ImportRootCaFailed=无法将根 CA 证书导入到 Windows 受信任的根证书存储。
zhHans.ImportRootCaFailedWithDetail=无法将根 CA 证书导入到 Windows 受信任的根证书存储。%n%n%1
zhHans.ImportRootCaToolMissing=未找到 Windows 内置证书工具 certutil.exe。

[Files]
Source: "certs\{#CaCertSourceFileName}"; DestName: "{#CaCertImportFileName}"; Flags: dontcopy

[Code]

var
  ExecOutputFirstLine: string;

procedure OnExecAndLogOutput(const S: String; const Error, FirstLine: Boolean);
begin
  if (not Error) and (ExecOutputFirstLine = '') and (Trim(S) <> '') then
    ExecOutputFirstLine := S;
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
  OK := ExecAndLogOutput(FileName,
    Params,
    '',
    ShowCmd,
    ewWaitUntilTerminated,
    result,
    @OnExecAndLogOutput);
  Log(Format('ExecEx: "%s" %s', [FileName, Params]));
  if OK then
    Log(Format('ExecEx exit code: %s', [IntToStr(result)]))
  else
    Log(Format('ExecEx failed: %s (%s)', [SysErrorMessage(result), IntToStr(result)]));
end;

function ImportRootCaCertificate(): Integer;
var
  FileName, Params: string;
begin
  result := -1;
  FileName := ExpandConstant('{sys}\certutil.exe');
  if not FileExists(FileName) then
    exit;

  ExtractTemporaryFile('{#CaCertImportFileName}');
  Params := '-f -addstore Root "' + ExpandConstant('{tmp}\{#CaCertImportFileName}') + '"';
  result := ExecEx(FileName, Params, true);
end;

function PrepareToInstall(var NeedsRestart: Boolean): string;
var
  ResultCode: Integer;
begin
  result := '';
  NeedsRestart := false;
  ExecOutputFirstLine := '';
  ResultCode := ImportRootCaCertificate();
  if ResultCode = -1 then
  begin
    result := CustomMessage('ImportRootCaToolMissing');
    exit;
  end;
  if ResultCode <> 0 then
  begin
    if ExecOutputFirstLine <> '' then
      result := FmtMessage(CustomMessage('ImportRootCaFailedWithDetail'), [ExecOutputFirstLine])
    else
      result := CustomMessage('ImportRootCaFailed');
  end;
end;
