// SyncthingLogonTask.js
// Written by Bill Stewart (bstewart AT iname.com) for Syncthing

// Notes:
// * Adds a scheduled task to start Syncthing at logon
// * Removes the scheduled task
// * Tests whether the scheduled task exists

// BEGIN LOCALIZATION
var MSG_DLG_TITLE            = "Syncthing";
var MSG_QUERY_CREATE         = "\u8981\u521b\u5efa\u4e00\u4e2a\u5728\u767b\u5f55\u65f6\u542f\u52a8 Syncthing \u7684\u8ba1\u5212\u4efb\u52a1\u5417\uff1f";
var MSG_QUERY_REMOVE         = "\u8981\u5220\u9664\u5728\u767b\u5f55\u65f6\u542f\u52a8 Syncthing \u7684\u8ba1\u5212\u4efb\u52a1\u5417\uff1f";
var MSG_TASK_NAME            = "\u767b\u5f55\u65f6\u542f\u52a8 Syncthing";
var MSG_ERROR_DESC_NOT_FOUND = "(\u672a\u627e\u5230\u9519\u8bef\u63cf\u8ff0)";
// END LOCALIZATION

// Global Windows API constants
var SW_HIDE              = 0;
var ERROR_FILE_NOT_FOUND = 2;
var ERROR_ACCESS_DENIED  = 5;
// Global message box constants
var MB_YESNO        = 0x04;
var MB_ICONERROR    = 0x10;
var MB_ICONQUESTION = 0x20;
var IDYES           = 6;
// Global FileSystemObject object constants
var ForReading      = 1;
var SystemFolder    = 1;
var TemporaryFolder = 2;
// Global Task Scheduler object constants
var TASK_ACTION_EXEC             = 0;
var TASK_LOGON_INTERACTIVE_TOKEN = 3;
var TASK_TRIGGER_LOGON           = 9;
var TASK_CREATE_OR_UPDATE        = 6;
// Global Task Scheduler objects
var TaskService = new ActiveXObject("Schedule.Service");
TaskService.Connect();
var TaskFolder = TaskService.GetFolder("\\");
// Global objects
var Args       = WScript.Arguments;
var FSO        = new ActiveXObject("Scripting.FileSystemObject");
var WshNetwork = new ActiveXObject("WScript.Network");
var WshShell   = new ActiveXObject("WScript.Shell");
// Global variables
var ScriptPath = WScript.ScriptFullName.substring(0,WScript.ScriptFullName.length - WScript.ScriptName.length);

function trim(s) {
  return s.replace(/(^\s*)|(\s*$)/g, "");
}

function quoteArg(value) {
  return '"' + value.replace(/"/g,'\\"') + '"';
}

function getErrorDescription(errorCode) {
  // convert to unsigned if signed
  if ( errorCode < 0 ) {
    errorCode += Math.pow(2,32);
  }

  if ( errorCode.toString(0x10) == "800a0046" ) {
    errorCode = ERROR_ACCESS_DENIED;
  }

  // Get temporary file name
  do
    var tempName = FSO.BuildPath(FSO.GetSpecialFolder(TemporaryFolder),
      FSO.GetTempName());
  while ( FSO.FileExists(tempName) );

  // Construct command line
  var command = FSO.BuildPath(FSO.GetSpecialFolder(SystemFolder),"cmd.exe") +
    " /c " + FSO.BuildPath(ScriptPath,"ErrInfo.exe -m -n ") +
    errorCode.toString() + " > \"" + tempName + "\"";

  // Run command (output in temporary file)
  var exitCode = WshShell.Run(command,SW_HIDE,true);
  if ( exitCode == 3871 ) {
    errorDescription = MSG_ERROR_DESC_NOT_FOUND;
  }
  else {
    try {
      var textStream = FSO.OpenTextFile(tempName,ForReading);
      var errorDescription = trim(textStream.ReadAll());
    }
    catch(err) {
      errorDescription = MSG_ERROR_DESC_NOT_FOUND;
    }
    finally {
      textStream.Close();
      FSO.DeleteFile(tempName);
    }
  }

  if ( errorCode == 0 ) {
    return errorDescription;
  }
  else {
    return "Error " + errorCode.toString() +
      " [0x" + errorCode.toString(0x10).toUpperCase() + "]: " +
      errorDescription;
  }
}

function taskExists(taskName) {
  var result = false;
  try {
    TaskFolder.GetTask(taskName);
    result = true;
  }
  catch(err) {
  }
  return result;
}

function createOrUpdateLogonTask(taskName,programName,programArgs,startOnACPowerOnly) {
  var result = 0;
  var taskDefinition = TaskService.NewTask(0);  // 0 parameter required
  var execAction = taskDefinition.Actions.Create(TASK_ACTION_EXEC);
  execAction.Path = programName;
  execAction.Arguments = programArgs;
  taskDefinition.Principal.LogonType = TASK_LOGON_INTERACTIVE_TOKEN;
  taskDefinition.Settings.DisallowStartIfOnBatteries = startOnACPowerOnly;
  var trigger = taskDefinition.Triggers.Create(TASK_TRIGGER_LOGON);
  trigger.UserId = WshNetwork.UserDomain + "\\" + WshNetwork.UserName;
  try {
    TaskFolder.RegisterTaskDefinition(taskName,  // path
      taskDefinition,                            // definition
      TASK_CREATE_OR_UPDATE,                     // flags
      null,                                      // userId
      null,                                      // password
      TASK_LOGON_INTERACTIVE_TOKEN);             // logonType
  }
  catch(err) {
    result = err.number;
  }
  return result;
}

function removeTask(taskName) {
  var result = 0;
  if ( taskExists(taskName) ) {
    try {
      TaskFolder.DeleteTask(taskName,0);
    }
    catch(err) {
      result = err.number;
    }
  }
  return result;
}

function help() {
  WScript.Echo("\u7528\u6cd5: " + WScript.ScriptName + " /create [/startonacpoweronly] [/cloudurl:<url>]|/remove [/silent]");
}

function reportStatus(errorCode) {
  if ( errorCode != 0 ) {
    WshShell.Popup(getErrorDescription(errorCode),0,MSG_DLG_TITLE,MB_ICONERROR);
  }
}

function query(message) {
  var response = WshShell.Popup(message,0,MSG_DLG_TITLE,MB_YESNO | MB_ICONQUESTION);
  return response == IDYES;  // user clicked Yes
}

function getUserId() {
  var userId = WshNetwork.UserName + '@' + WshNetwork.UserDomain;
  return userId.replace('/\\\/\:\*\?\"\<\>\|/g','_');
}

function main() {
  var result = 0;
  var validParams = Args.Named.Exists("create") || Args.Named.Exists("remove") ||
    Args.Named.Exists("test");
  var taskName = MSG_TASK_NAME + " (" + getUserId() + ")";
  // Parse arguments
  if ( Args.Named.Exists("create") ) {
    if ( (Args.Named.Exists("silent")) || query(MSG_QUERY_CREATE) ) {
      var programName = FSO.BuildPath(ScriptPath,"stctl.exe");
      var programArgs = '--start';
      if ( Args.Named.Exists("cloudurl") && (Args.Named.Item("cloudurl") != "") ) {
        programArgs += ' -- --cloud-url ' + quoteArg(Args.Named.Item("cloudurl"));
      }
      result = createOrUpdateLogonTask(taskName,programName,programArgs,Args.Named.Exists("startonacpoweronly"));
    }
  }
  else if ( Args.Named.Exists("remove") ) {
    if ( (Args.Named.Exists("silent")) || query(MSG_QUERY_REMOVE) ) {
      result = removeTask(taskName);
    }
  }
  else if ( Args.Named.Exists("test") ) {
    if ( ! taskExists(taskName) ) {
      result = ERROR_FILE_NOT_FOUND;
    }
  }
  if ( validParams ) {
    if ( ! Args.Named.Exists("silent") ) {
      if ( ! Args.Named.Exists("test") ) {
        reportStatus(result);
      }
    }
  }
  else {
    help();
  }
  return result;
}

WScript.Quit(main());
