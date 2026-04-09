<!-- omit in toc -->
# Building Syncthing Windows Setup

- [Listing of Files](#listing-of-files)
- [Get the Files](#get-the-files)
- [Build Setup](#build-setup)
- [Localization Steps](#localization-steps)
- [Localization Example](#localization-example)

## Listing of Files

The following table lists all of the files associated with Syncthing Windows Setup (hereafter referred to as "Setup").

| Folder or File             | Description
| --------------             | -----------
| `binaries`                 | Folder contains 32-bit (i386) and 64-bit (x86_64) binaries
| `building.md`              | This file
| _lang_`-`_scriptname_`.js` | Setup installs one or more of these WSH scripts on the user's system
| `LICENSE`                  | License agreement
| `Localization.ini`         | Facilitates localization of the script files (see [Localization](#localization))
| `Messages-`_lang_`.isl`    | Setup messages file (see [Localization](#localization))
| `offline`                  | Folder contains the bundled offline Syncthing zip files
| `ProcessCheck.dll`         | 32-bit [ProcessCheck](https://github.com/Bill-Stewart/ProcessCheck) DLL (used during installation only)
| `README.md`                | Setup documentation
| `SetupVersion.ini`         | Setup version file
| `Syncthing.iss`            | Inno Setup source script
| `UninsIS.dll`              | 32-bit [UninsIS](https://github.com/Bill-Stewart/UninsIS) DLL (used during installation only)
| `unzip.exe`                | 32-bit [UnZip](https://infozip.sourceforge.net/) tool (used during installation only)

## Get the Files

1. [Download the project from Github](https://github.com/Bill-Stewart/SyncthingWindowsSetup/archive/refs/heads/main.zip) and extract it into a folder of your choice.

2. Download the executables for the `binaries` folder:

   * [asmt](https://github.com/Bill-Stewart/asmt/releases/latest/)
   * [ErrInfo](https://github.com/Bill-Stewart/ErrInfo)
   * [ServMan](https://github.com/Bill-Stewart/ServMan/releases/latest/)
   * [shawl](https://github.com/mtkennerly/shawl/releases/latest/)
   * [stctl](https://github.com/Bill-Stewart/stctl/releases/latest/)

3. Put the 32-bit binaries in the `binaries\i386` folder and the 64-bit binaries in the `binaries\x86_64` folder.

4. Put the offline Syncthing zip files you want to bundle into the `offline` folder using these exact filenames:

   * `syncthing-windows-386.zip`
   * `syncthing-windows-amd64.zip`
   * `syncthing-windows-arm64.zip`

## Build Setup

Use whatever method you prefer to compile `Syncthing.iss` using Inno Setup 6.3.3 or later. The output filename will be `syncthing-windows-setup.exe`.

The repository includes `ChineseSimplified.isl` locally because the Simplified Chinese language file is not always present in the default Inno Setup installation.

The local `sthttpscert.exe` helper should be built with a Windows 7 compatible Go toolchain. `scripts/download-build-assets.sh` does this by default using `GOTOOLCHAIN=go1.20.14`.

The installer no longer downloads Syncthing during installation. It will use resources in this order:

1. `/zipfilepath=...` if specified
2. A bundled zip file from the `offline` folder that matches the target architecture
3. A zip file selected manually on the **Select Installation Zip File** page

## Localization Steps

To add additional language support to Setup, do the following:

1.  Copy the `Messages-en.isl` file to `Messages-`_lang_`.isl` (where _lang_ is the language code you want to use) and update the strings in the file.

2.  Update the strings in `Messages-`_lang_`.isl` for the language.

3.  Update the `[Languages]` section in the `Syncthing.iss` file.

4.  Copy each `en-`_scriptname_`.js` script to _lang_`-`_scriptname_`.js` (where _lang_ is the language you want to add).

5.  Edit the messages at the top of each _lang_`-`_scriptname_`.js` script such that the messages are appropriate for the language.

    > NOTE: If the messages do not display correctly when the scripts run, it may be an encoding problem. Try saving the scripts using UTF-16 LE (little endian) encoding.

6.  In the `Localization.ini` file, add a section for the language, and specify the source file names you want to use for the language.

7.  Increment the `NumLanguages` preprocessor directive in `Syncthing.iss`.

8. Add a language preprocessor directive to `Syncthing.iss`, using the following syntax:

     `#define Languages[`_index_`] "`_lang_`"`

     (where _index_ is the next-higher index value in the `Languages` preprocessor directive array)

## Localization Example

The following steps describe how to add localization for Dutch (language code `nl`):

1.  Copy `Messages-en.isl` to `Messages-nl.isl`.

2.  Update the strings in `Messages-nl.isl` to Dutch.

3.  Add Dutch to the `[Languages]` section in `Syncthing.iss`; e.g.:

        [Languages]
        Name: "en"; MessagesFile: "compiler:Default.isl,Messages-en.isl"
        Name: "nl"; MessagesFile: "compiler:Languages\Dutch.isl,Messages-nl.isl"

4.  Copy the `en-`_scriptname_`.js` scripts to `nl-`_scriptname_`.js` files. PowerShell example:

        Get-ChildItem en-*.js | ForEach-Object { Copy-Item $_ ($_.Name -replace '^en-','nl-') }

5.  Update the messages at the top of each `nl-`_scriptname_`.js` script file to Dutch.

6.  Add a section in `Localization.ini` for the Dutch language code (`nl`) and add the corresponding file names; e.g.:

        [nl]
        ScriptNameSetSyncthingConfig=nl-SetSyncthingConfig.js
        ScriptNameSyncthingFirewallRule=nl-SyncthingFirewallRule.js
        ScriptNameSyncthingLogonTask=nl-SyncthingLogonTask.js

7.  Increment the `NumLanguages` preprocessor directive in `Syncthing.iss`; e.g.:

        ...
        #define NumLanguages 2
        ...

8. Also in `Syncthing.iss`, add Dutch to the `Languages` preprocessor directive array using the next higher index; e.g.:

        ...
        #define Languages[0] "en"
        #define Languages[1] "nl"
        ...
