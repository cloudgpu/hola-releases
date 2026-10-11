# Install hola on Windows from a public GitHub Releases zip.
# If a native Windows zip is not available, the script prints WSL fallback
# instructions and returns cleanly.
# Works in Windows PowerShell 5.1 and PowerShell 7.
# Usage (download the script, read it, then run it):
#   Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/cloudgpu/hola-releases/main/install.ps1' -OutFile install.ps1
#   .\install.ps1
# Options: -Version 1.5.0  -InstallDir <path>  -NoPath (do not edit your PATH)
# Piping this script into Invoke-Expression is not recommended: antivirus
# products treat "download and run in memory" as a malware pattern.
param(
    # NOTE: do not use `-or` for defaults here. It is a logical operator in
    # PowerShell: it coerces both sides to [bool] and returns True/False, so
    # $Version became the string "True" and every download 404'd into the
    # WSL fallback.
    [string]$Version,
    [string]$ReleasesRepo,
    [string]$InstallDir,
    [switch]$NoPath
)

if (-not $Version)      { $Version      = if ($env:HOLA_VERSION)      { $env:HOLA_VERSION }      else { '1.17.0' } }
if (-not $ReleasesRepo) { $ReleasesRepo = if ($env:HOLA_RELEASES_REPO) { $env:HOLA_RELEASES_REPO } else { 'cloudgpu/hola-releases' } }
if (-not $InstallDir)   { $InstallDir   = if ($env:HOLA_INSTALL_DIR)  { $env:HOLA_INSTALL_DIR }  else { "$env:LOCALAPPDATA\hola" } }
$Version = $Version.TrimStart('v')

# Everything runs inside a function so failures use `return`, never `exit`:
# `exit` under Invoke-Expression would close the user's PowerShell window and
# hide the error message.
function Install-Hola {
    param([string]$Version, [string]$ReleasesRepo, [string]$InstallDir, [bool]$NoPath)

    $oldEap = $ErrorActionPreference
    $oldProgress = $ProgressPreference
    $ErrorActionPreference = 'Stop'
    # Windows PowerShell 5.1 renders a progress bar per chunk, which makes
    # even small downloads slow.
    $ProgressPreference = 'SilentlyContinue'
    $tmpZip = $null

    try {
        $arch = if ([Environment]::Is64BitOperatingSystem) { 'amd64' } else { '386' }
        $zip = "hola-${Version}-windows-${arch}.zip"
        $url = "https://github.com/${ReleasesRepo}/releases/download/v${Version}/${zip}"

        Write-Host "Downloading hola $Version for windows/$arch from ${ReleasesRepo}..."
        Write-Host "  $url" -ForegroundColor DarkGray
        $tmpZip = Join-Path ([IO.Path]::GetTempPath()) ("hola-" + [Guid]::NewGuid().ToString('N') + ".zip")

        try {
            Invoke-WebRequest -Uri $url -OutFile $tmpZip -UseBasicParsing
        } catch {
            # Only a 404 means "this release has no Windows zip". Every other
            # failure (TLS, proxy, DNS, rate limit) used to print the same WSL
            # message, which made real errors look like a missing build.
            $status = $null
            try { $status = [int]$_.Exception.Response.StatusCode } catch { }
            if ($status -eq 404) {
                Write-Host ""
                Write-Host "A native Windows build is not available for this release yet." -ForegroundColor Yellow
                Write-Host "  (no asset at $url)" -ForegroundColor DarkGray
                Write-Host "You can run Hola on Windows Subsystem for Linux (WSL) using the Linux installer:"
                Write-Host ""
                Write-Host "    wsl --install -d Ubuntu"
                Write-Host "    wsl curl -fsSL https://raw.githubusercontent.com/${ReleasesRepo}/main/install.sh | sh"
                Write-Host ""
                return
            }
            Write-Host ""
            Write-Host "Download failed: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "  URL: $url"
            if ($status) { Write-Host "  HTTP status: $status" }
            return
        }

        Write-Host "Extracting to $InstallDir..."
        New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
        Expand-Archive -Path $tmpZip -DestinationPath $InstallDir -Force

        $binDir = Join-Path $InstallDir 'bin'
        if (-not (Test-Path (Join-Path $binDir 'hola-coder.exe'))) {
            Write-Host ""
            Write-Host "Install incomplete: $binDir\hola-coder.exe was not found after extraction." -ForegroundColor Red
            Write-Host "  The archive may be corrupt or blocked by antivirus. Try again, or download it manually:"
            Write-Host "  $url"
            return
        }

        if ($NoPath) {
            Write-Host "Skipping PATH change (-NoPath). Run hola with: $binDir\hola-coder.exe"
        } else {
            $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
            if (-not $userPath) { $userPath = '' }
            $onPath = $false
            foreach ($p in ($userPath -split ';')) {
                if ($p.TrimEnd('\') -ieq $binDir.TrimEnd('\')) { $onPath = $true }
            }
            if (-not $onPath) {
                $newPath = if ($userPath) { "$userPath;$binDir" } else { $binDir }
                [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
                Write-Host "Added $binDir to your user PATH."
            }
            # Make it usable in this session too.
            if ($env:Path -notlike "*$binDir*") { $env:Path = "$env:Path;$binDir" }
        }

        if ($NoPath) { Write-Host "hola $Version installed." }
        else { Write-Host "hola $Version installed. Run: hola-coder --version" }
    } catch {
        Write-Host ""
        Write-Host "Install failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
            Write-Host $_.InvocationInfo.PositionMessage -ForegroundColor DarkGray
        }
        Write-Host "Please report this message at https://github.com/${ReleasesRepo}/issues"
    } finally {
        if ($tmpZip -and (Test-Path $tmpZip)) { Remove-Item $tmpZip -Force -ErrorAction SilentlyContinue }
        $ErrorActionPreference = $oldEap
        $ProgressPreference = $oldProgress
    }
}

Install-Hola -Version $Version -ReleasesRepo $ReleasesRepo -InstallDir $InstallDir -NoPath ([bool]$NoPath)
