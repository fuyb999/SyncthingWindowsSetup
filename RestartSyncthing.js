// RestartSyncthing.js
// Restarts Syncthing for the current user.

var SW_HIDE = 0;
var POPUP_ICON_STOP = 16;
var POPUP_ICON_INFO = 64;
var POPUP_ICON_WARNING = 48;
var Args = WScript.Arguments;
var FSO = new ActiveXObject("Scripting.FileSystemObject");
var WshShell = new ActiveXObject("WScript.Shell");
var ScriptPath = WScript.ScriptFullName.substring(0, WScript.ScriptFullName.length - WScript.ScriptName.length);
var UI = getUIStrings();

function quoteArg(value) {
  return '"' + value.replace(/"/g, '\\"') + '"';
}

function getNamedArgument(name) {
  if (Args.Named.Exists(name)) {
    return String(Args.Named.Item(name));
  }

  return "";
}

function getUIStrings() {
  var lang = getNamedArgument("lang").toLowerCase();

  if (lang.indexOf("zh") === 0) {
    return {
      title: "\u91cd\u542f Syncthing",
      success: "Syncthing \u5df2\u6210\u529f\u91cd\u542f\u3002",
      warning: "Syncthing \u5df2\u542f\u52a8\uff0c\u4f46\u505c\u6b62\u65e7\u8fdb\u7a0b\u65f6\u53ef\u80fd\u672a\u5b8c\u5168\u6210\u529f\u3002",
      failure: "\u91cd\u542f Syncthing \u5931\u8d25\u3002",
      missing: "\u672a\u627e\u5230 stctl.exe\uff0c\u65e0\u6cd5\u6267\u884c\u91cd\u542f\u3002",
      stopCode: "\u505c\u6b62\u9000\u51fa\u7801",
      startCode: "\u542f\u52a8\u9000\u51fa\u7801",
      detailPrefix: "\u8be6\u60c5\uff1a"
    };
  }

  return {
    title: "Restart Syncthing",
    success: "Syncthing was restarted successfully.",
    warning: "Syncthing started, but stopping the previous process may not have completed successfully.",
    failure: "Failed to restart Syncthing.",
    missing: "Could not find stctl.exe, so restart could not be performed.",
    stopCode: "Stop exit code",
    startCode: "Start exit code",
    detailPrefix: "Details:"
  };
}

function showPopup(message, icon) {
  WshShell.Popup(message, 0, UI.title, icon);
}

function buildDetailMessage(stopCode, startCode, errorMessage) {
  var lines = [];

  if (typeof stopCode === "number") {
    lines.push(UI.stopCode + ": " + stopCode);
  }
  if (typeof startCode === "number") {
    lines.push(UI.startCode + ": " + startCode);
  }
  if (errorMessage) {
    lines.push(UI.detailPrefix + " " + errorMessage);
  }

  return lines.join("\r\n");
}

function main() {
  var stctlPath = FSO.BuildPath(ScriptPath, "stctl.exe");
  var stopCommand;
  var startCommand;
  var stopExitCode;
  var startExitCode;
  var detailMessage;

  if (!FSO.FileExists(stctlPath)) {
    showPopup(UI.missing, POPUP_ICON_STOP);
    return 1;
  }

  stopCommand = quoteArg(stctlPath) + " --stop -q";
  startCommand = quoteArg(stctlPath) + " --start -q";

  if (getNamedArgument("cloudurl") !== "") {
    startCommand += " -- --cloud-url " + quoteArg(getNamedArgument("cloudurl"));
  }

  try {
    stopExitCode = WshShell.Run(stopCommand, SW_HIDE, true);
    WScript.Sleep(1000);
    startExitCode = WshShell.Run(startCommand, SW_HIDE, true);
  } catch (e) {
    detailMessage = buildDetailMessage(stopExitCode, startExitCode, e.message);
    showPopup(UI.failure + "\r\n\r\n" + detailMessage, POPUP_ICON_STOP);
    return 1;
  }

  if (startExitCode === 0) {
    if (stopExitCode === 0) {
      showPopup(UI.success, POPUP_ICON_INFO);
      return 0;
    }

    detailMessage = buildDetailMessage(stopExitCode, startExitCode, "");
    showPopup(UI.warning + "\r\n\r\n" + detailMessage, POPUP_ICON_WARNING);
    return 0;
  }

  detailMessage = buildDetailMessage(stopExitCode, startExitCode, "");
  showPopup(UI.failure + "\r\n\r\n" + detailMessage, POPUP_ICON_STOP);
  return startExitCode;
}

WScript.Quit(main());
