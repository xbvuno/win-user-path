$ErrorActionPreference = "Stop"

$repoUrl = "https://raw.githubusercontent.com/xbvuno/win-user-path/main/upath.ps1"
$installDir = "$env:LOCALAPPDATA\upath"
$targetFile = "$installDir\upath.ps1"

function Log-Info {
    param([string]$Message)
    Write-Host "🛈 $Message" -ForegroundColor White
}

function Log-Warn {
    param([string]$Message)
    Write-Host "⟁ $Message" -ForegroundColor Yellow
}

function Log-Good {
    param([string]$Message)
    Write-Host "🗹 $Message" -ForegroundColor Green
}

function Log-Error {
    param([string]$Message)
    Write-Host "⛒ $Message" -ForegroundColor Red
}

Log-Info "installing upath..."

# remove previous installation if present
if (Test-Path $installDir) {
    Remove-Item -Path $installDir -Recurse -Force
    Log-Info "removed previous installation"
}

# create install directory
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

# download core
try {
    Invoke-WebRequest -Uri $repoUrl -OutFile $targetFile
    Log-Info "downloaded upath core"
}
catch {
    Log-Error "failed to download script"
    exit 1
}

# add install directory to User PATH if missing
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

$paths = @()
if ($userPath) {
    $paths = $userPath -split ';' | Where-Object { $_ -ne '' }
}

if ($paths -notcontains $installDir) {
    $newPath = ($paths + $installDir) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Log-Info "added install directory to User PATH"
}
else {
    Log-Warn "install directory already in User PATH"
}

Log-Good "installation complete"

# refresh current session PATH
try {
    Log-Info "refreshing PATH..."

    $env:Path =
    [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
    [Environment]::GetEnvironmentVariable("Path", "User")

    Log-Info "run 'upath' for testing"
}
catch {
    Log-Warn "could not refresh PATH, open a new terminal if needed"
}