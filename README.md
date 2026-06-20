# Hola Releases

Binary releases for the [Hola AI agent](https://cloudgpu.io/hola).

## Quick install

On Linux (and Windows via WSL):

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.sh | sh
```

On Windows with PowerShell (falls back to WSL instructions when a native zip is
not yet available):

```powershell
Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.ps1' -UseBasicParsing).Content
```

See the [latest release](https://github.com/cloudgpu/hola-releases/releases/latest)
for available packages and release notes.
