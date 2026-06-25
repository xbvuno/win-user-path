param(
    [Parameter(Position = 0)]
    [ValidateSet("help", "list", "add", "remove", "refresh")]
    [string]$Command = "help",

    [Parameter(Position = 1)]
    [string]$Value
)

# =========================
# LOGGING
# =========================

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

# =========================
# HELP
# =========================
function Show-Help {
    Write-Host ""
    Write-Host "upath - easy user PATH manager" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:"
    Write-Host "   upath add <path>        Add a directory to User PATH"
    Write-Host "   upath remove <path>     Remove a directory from User PATH"
    Write-Host "   upath list              Show current User PATH entries"
    Write-Host "   upath refresh           Refresh PATH for current session"
    Write-Host "   upath help              Show this help message"
    Write-Host ""
}

# =========================
# NORMALIZATION
# =========================
function Normalize([string]$p) {
    if (-not $p) { return $null }
    return $p.Trim().TrimEnd([char[]]("\", "/"))
}

function Split-PathList([string]$p) {
    if (-not $p) { return @() }
    return $p -split ";" | Where-Object { $_ -and $_.Trim() -ne "" }
}

function Get-CanonicalList([string]$raw) {
    $list = Split-PathList $raw | ForEach-Object { Normalize $_ } | Where-Object { $_ }

    $seen = @{}
    $result = @()

    foreach ($item in $list) {
        $key = $item.ToLower()
        if (-not $seen.ContainsKey($key)) {
            $seen[$key] = $true
            $result += $item
        }
    }

    return $result
}

function Load-UserPath {
    return [Environment]::GetEnvironmentVariable("Path", "User")
}

function Save-UserPath($list) {
    $new = ($list | Where-Object { $_ }) -join ";"
    [Environment]::SetEnvironmentVariable("Path", $new, "User")

    Log-Info "run 'upath refresh' to apply changes"
}

# =========================
# LOAD STATE
# =========================
$userPath = Load-UserPath
$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")

# =========================
# COMMANDS
# =========================
switch ($Command) {

    "help" {
        Show-Help
    }

    "list" {
        $list = Get-CanonicalList $userPath

        if (-not $list -or $list.Count -eq 0) {
            Log-Warn "User PATH is empty"
        }
        else {
            $list | ForEach-Object { Write-Host $_ }
        }
    }

    "add" {
        if (-not $Value) {
            Log-Error "missing path argument"
            exit 1
        }

        $Value = [System.IO.Path]::GetFullPath($Value)
        $p = Normalize $Value
        $list = Get-CanonicalList $userPath

        $exists = $list | Where-Object { $_ -ieq $p }

        if ($exists) {
            Log-Warn "already exists: $p"
            exit 0
        }

        $list += $p
        Save-UserPath $list

        Log-Good "added: $p"
    }

    "remove" {
        if (-not $Value) {
            Log-Error "missing path argument"
            exit 1
        }

        $Value = [System.IO.Path]::GetFullPath($Value)
        $p = Normalize $Value
        $list = Get-CanonicalList $userPath

        $exists = $list | Where-Object { $_ -ieq $p }

        if (-not $exists) {
            Log-Warn "not found: $p"
            exit 0
        }

        $newList = $list | Where-Object { $_ -ine $p }
        Save-UserPath $newList

        Log-Good "removed: $p"
    }

    "refresh" {
        $user = Load-UserPath

        if ($machinePath) {
            $env:Path = "$machinePath;$user"
        }
        else {
            $env:Path = $user
        }

        Log-Good "refreshed"
    }

    default {
        Log-Error "command not found: $Command"
        Log-Info "run 'upath help' for available commands"
        exit 1
    }
}