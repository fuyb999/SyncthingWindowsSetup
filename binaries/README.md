# Local helper binaries

Place the helper executables required by `Syncthing.iss` in these folders before compiling:

- `binaries/i386`
- `binaries/x86_64`

You can download and populate them automatically by running:

`bash scripts/download-build-assets.sh`

Required files:

- `asmt.exe`
- `ErrInfo.exe`
- `ServMan.exe`
- `shawl.exe`
- `stctl.exe`

The installer packages these files from the local repository. They are no longer expected to be fetched during installation.
