# Install hola on Windows from a public GitHub Releases zip.
# If a native Windows zip is not available, the script prints WSL fallback
# instructions and exits cleanly.
# Usage:
#   Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.ps1' -UseBasicParsing).Content
param(
    # NOTE: do not use `-or` for defaults here. It is a logical operator in
    # PowerShell: it coerces both sides to [bool] and returns True/False, so
    # $Version became the string "True" and every download 404'd into the
    # WSL fallback.
    [string]$Version,
    [string]$ReleasesRepo,
    [string]$InstallDir
)

if (-not $Version)      { $Version      = if ($env:HOLA_VERSION)      { $env:HOLA_VERSION }      else { '1.1.4' } }
if (-not $ReleasesRepo) { $ReleasesRepo = if ($env:HOLA_RELEASES_REPO) { $env:HOLA_RELEASES_REPO } else { 'cloudgpu/hola-releases' } }
if (-not $InstallDir)   { $InstallDir   = if ($env:HOLA_INSTALL_DIR)  { $env:HOLA_INSTALL_DIR }  else { "$env:LOCALAPPDATA\hola" } }
$Version = $Version.TrimStart('v')

function Show-Fallback {
    param([string]$Url)
    Write-Host ""
    Write-Host "A native Windows build is not available for this release yet." -ForegroundColor Yellow
    if ($Url) { Write-Host "  (no asset at $Url)" -ForegroundColor DarkGray }
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
Write-Host "  $url" -ForegroundColor DarkGray
$tmp = New-TemporaryFile
$tmpZip = "$tmp.zip"

try {
    Invoke-WebRequest -Uri $url -OutFile $tmpZip -UseBasicParsing
} catch {
    # Only a 404 means "this release has no Windows zip". Every other
    # failure (TLS, proxy, DNS, rate limit) used to print the same WSL
    # message, which made real errors look like a missing build.
    $status = $null
    try { $status = [int]$_.Exception.Response.StatusCode } catch { }
    if ($status -eq 404) { Show-Fallback -Url $url }
    Write-Host ""
    Write-Host "Download failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  URL: $url"
    if ($status) { Write-Host "  HTTP status: $status" }
    exit 1
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
