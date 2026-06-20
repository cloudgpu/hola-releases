# Install hola on Windows from a public GitHub Releases zip.
# If a native Windows zip is not available, the script prints WSL fallback
# instructions and exits cleanly.
# Usage:
#   Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/cloudgpu/hola-releases/main/scripts/install.ps1' -UseBasicParsing).Content
param(
    [string]$Version = ($env:HOLA_VERSION -or '0.5.0'),
    [string]$ReleasesRepo = ($env:HOLA_RELEASES_REPO -or 'cloudgpu/hola-releases'),
    [string]$InstallDir = ($env:HOLA_INSTALL_DIR -or "$env:LOCALAPPDATA\hola")
)

function Show-Fallback {
    Write-Host ""
    Write-Host "A native Windows build is not available for this release yet." -ForegroundColor Yellow
    Write-Host "You can run Hola on Windows Subsystem for Linux (WSL) using the Linux installer:"
    Write-Host ""
    Write-Host "    wsl --install -d Ubuntu"
    Write-Host "    wsl curl -fsSL https://raw.githubusercontent.com/${ReleasesRepo}/main/scripts/install.sh | sh"
    Write-Host ""
    exit 0
}

$ErrorActionPreference = 'Stop'

$arch = if ([Environment]::Is64BitOperatingSystem) { 'amd64' } else { '386' }
$zip = "hola-${Version}-windows-${arch}.zip"
$url = "https://github.com/${ReleasesRepo}/releases/download/v${Version}/${zip}"

Write-Host "Downloading hola $Version for windows/$arch from ${ReleasesRepo}..."
$tmp = New-TemporaryFile
$tmpZip = "$tmp.zip"

try {
    Invoke-WebRequest -Uri $url -OutFile $tmpZip -UseBasicParsing
} catch {
    Show-Fallback
}

Write-Host "Extracting to $InstallDir..."
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Expand-Archive -Path $tmpZip -DestinationPath $InstallDir -Force
Remove-Item $tmpZip

$binDir = "$InstallDir\bin"
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable('Path', "$userPath;$binDir", 'User')
    Write-Host "Added $binDir to your user PATH. Restart your terminal to use hola."
}

Write-Host "hola $Version installed."
