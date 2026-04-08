# Bundled offline Syncthing zip files

To embed Syncthing into the installer, place the offline zip files in this folder using these exact names:

- `syncthing-windows-386.zip`
- `syncthing-windows-amd64.zip`
- `syncthing-windows-arm64.zip`

Each file should be a Syncthing release zip for the matching Windows architecture. During installation, Setup will:

1. Prefer `/zipfilepath=...` if provided.
2. Otherwise use the bundled offline zip that matches the current architecture.
3. Otherwise prompt the user to browse for a local zip file.

To download the latest helper binaries and these offline zip files automatically, run:

`bash scripts/download-build-assets.sh`
