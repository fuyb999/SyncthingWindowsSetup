#preproc ispp

; File encoding: UTF-8 with byte-order marker (BOM)

[Messages]
PrivilegesRequiredOverrideTitle=选择安装模式
PrivilegesRequiredOverrideInstruction=请选择安装模式
PrivilegesRequiredOverrideText1=%1 可以为所有用户安装为 Windows 服务（需要管理员权限），或者仅为当前用户安装。
PrivilegesRequiredOverrideText2=%1 可以仅为当前用户安装，或者为所有用户安装为 Windows 服务（需要管理员权限）。
PrivilegesRequiredOverrideAllUsers=为所有用户安装为 Windows 服务(&A)
PrivilegesRequiredOverrideAllUsersRecommended=为所有用户安装为 Windows 服务（推荐）(&A)
PrivilegesRequiredOverrideCurrentUser=仅为当前用户安装(&C)
PrivilegesRequiredOverrideCurrentUserRecommended=仅为当前用户安装（推荐）(&C)
FinishedLabel=[name] 已安装到您的计算机。

[CustomMessages]
; Uninstall display
UninstallDisplayNamePerUserSuffix=（当前用户）
UninstallDisplayNameServiceSuffix=（服务）
; Service account
ServiceAccountDescription=Syncthing 服务账户
; Service
ServiceDisplayName=Syncthing 服务
ServiceDescription=Syncthing 可在两台或多台计算机之间安全地实时同步文件。
; [Icons]
ShortcutNameConfigurationPage=Syncthing 配置页面
ShortcutNameConfigurationPageComment=打开 Syncthing 配置网页。
ShortcutNameStartSyncthing=启动 Syncthing
ShortcutNameStartSyncthingComment=启动 Syncthing。
ShortcutNameStopSyncthing=停止 Syncthing
ShortcutNameStopSyncthingComment=停止 Syncthing。
; [Tasks]
TasksStartAtBoot=系统启动时自动启动 Syncthing 服务(&A)
TasksStartServiceAfterInstall=安装完成后启动 Syncthing 服务(&I)
TasksStartAtLogon=登录时自动启动 Syncthing(&A)
TasksStartAtLogon_ACPowerOnly=仅在计算机接通交流电时自动启动(&T)
TasksStartAfterInstall=安装完成后启动 Syncthing(&I)
TasksCreateDesktopIcon=为 Syncthing 配置页面创建桌面快捷方式(&D)
; [Run]
RunStatusMsg=正在完成安装任务...
RunPostInstallOpenConfigPage=打开 Syncthing 配置页面(&O)
; Initialization
InitializeSetupError0=安装初始化错误：域控制器上不允许为所有用户安装。%n%n安装程序即将退出。
InitializeSetupError1=安装初始化错误：WSH 脚本注册无效。%n%n要修复此问题，请参阅文档中的“安装初始化错误”部分。%n%n安装程序即将退出。
InitializeSetupError2=安装初始化错误：检测到管理员安装。%n%n安装程序检测到当前系统中已经存在管理员安装版本。如需重新安装，请使用 /ALLUSERS 命令行参数重新启动安装程序。%n%n安装程序即将退出。
InitializeSetupWarning0=警告：未找到内置的 Syncthing 离线 zip 文件。安装程序将提示您选择本地 zip 文件。
; Memo pages
MemoPage0Caption=许可
MemoPage0Description=请查看以下许可信息。
MemoPage0SubCaption=准备好继续安装后，请单击“下一步”。
; File pages
FilePage0Caption=选择安装 zip 文件
FilePage0Description=安装程序应使用哪个 zip 文件来安装 Syncthing？
FilePage0SubCaption=指定安装 zip 文件的位置，然后单击“下一步”。
FilePage0Prompt=Syncthing 安装 zip 文件(&I)：
FilePage0Filter=Zip 文件 (*.zip)|*.zip|所有文件 (*)|*
; File page errors
FilePage0Item0Empty=必须指定 Syncthing zip 文件的路径。
; Configuration pages
ConfigPage0Caption=选择配置设置
ConfigPage0Description=安装程序应如何配置 Syncthing？
ConfigPage0SubCaption=指定 Syncthing 配置设置，然后单击“下一步”。
ConfigPage0Item0=自动升级检查间隔（小时，0 表示禁用，默认 %1）(&U)：
ConfigPage0Item1=GUI 配置页面监听地址（默认 %1）(&A)：
ConfigPage0Item2=GUI 配置页面监听端口（默认 %1）(&P)：
ConfigPage0Item3=是否启用中继（'false' 或 'true'，默认 '%1'）(&R)：
ConfigPage0Item4=网盘地址（可选）(&C)：
; Configuration page errors
ConfigPage0Item0NotValid=自动升级间隔必须在 0 到 65535 之间。
ConfigPage0Item1Empty=必须指定监听地址。
ConfigPage0Item2NotValid=监听端口必须在 1024 到 65535 之间。
ConfigPage0Item3NotValid=中继值必须为 'false' 或 'true'。
; Download pages
DownloadPageAbortedByUser=下载已中止。
; Ready memo page
ReadyMemoZipFileInfo=安装 zip 文件位置：
ReadyMemoZipFileBundled=内置离线 zip 文件（%1）
ReadyMemoInstallSettings=安装设置：
ReadyMemoInstallOffline=离线安装（使用内置或本地安装 zip 文件）
ReadyMemoInstallAdmin=为所有用户安装为 Windows 服务
ReadyMemoInstallAdminServiceAccountUserName=服务账户用户名：%1
ReadyMemoInstallCurrentUser=为当前用户安装（%1）
ReadyMemoConfigInfo=配置设置：
ReadyMemoConfigItem0Disabled=已禁用自动升级
ReadyMemoConfigItem0Enabled=每 %1 小时检查一次自动升级
ReadyMemoConfigItem1=GUI 配置页面监听地址为
ReadyMemoConfigItem2=GUI 配置页面监听端口为
ReadyMemoConfigItem3Disabled=已禁用中继
ReadyMemoConfigItem3Enabled=已启用中继
ReadyMemoConfigItem4Set=网盘地址为 %1
ReadyMemoConfigItem4Empty=未设置网盘地址
; Preparing to Install page
PrepareToInstallUninstallNeeded=安装程序检测到需要卸载当前已安装的版本。
PrepareToInstallUninstallSucceeded=安装程序已成功卸载当前已安装的版本。
; Preparing to Install errors
PrepareToInstallErrorMessage0=安装程序无法卸载当前系统中已安装的版本。若要升级，必须先卸载旧版本，然后才能安装此版本。
PrepareToInstallErrorMessage1=安装程序检测到已安装版本（%1）新于当前版本（%2）。若要降级，请先卸载已安装版本，然后再安装此版本。
; DeinitializeUninstall
DeinitializeUninstallAppDirRemoveSucceeded=已删除目录：%1
DeinitializeUninstallAppDirRemoveFailed=删除目录失败：%1
; Misc.
RunCommandMessage=运行命令："%1" %2
ProcessCheckSucceededRunning=ProcessCheck.dll 中的 FindProcess 函数执行成功；“%1” 正在运行
ProcessCheckSucceededNotRunning=ProcessCheck.dll 中的 FindProcess 函数执行成功；“%1” 未在运行
ProcessCheckFailed=ProcessCheck.dll 中的 FindProcess 函数执行失败
InstallTypeNotInstalled=未检测到已安装的软件包。
InstallTypeAdmin=检测到该软件包以管理员安装模式安装。
InstallTypeNonAdmin=检测到该软件包以非管理员安装模式安装。
BundledZipFound=找到内置离线 zip 文件：%1
BundledZipNotFound=未找到内置离线 zip 文件：%1
BundledZipNotValid=内置离线 zip 文件无效：%1
ZipFilePathFound=已找到指定的 zip 文件。
ZipFilePathNotFound=未找到指定的 zip 文件。
ZipFileNotValid=指定的 zip 文件无效。
InstalledVersion=已成功安装版本 %1
FileDeleteSucceeded=已删除文件：%1
FileDeleteFailed=删除文件失败：%1
