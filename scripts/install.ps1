#
# Dotfiles Install Script for Windows
# Usage: .\install.ps1 [-Target cursor|windsurf|all]
#

param(
    [ValidateSet("cursor", "windsurf", "all")]
    [string]$Target = "all"
)

$ErrorActionPreference = "Stop"
$DotfilesDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not $DotfilesDir) {
    $DotfilesDir = Split-Path -Parent $PSScriptRoot
}

# Config paths for Windows
$CursorConfigDir = "$env:APPDATA\Cursor\User"
$WindsurfConfigDir = "$env:APPDATA\Windsurf\User"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $colors = @{
        "INFO"  = "Green"
        "WARN"  = "Yellow"
        "ERROR" = "Red"
    }
    Write-Host "[$Level] " -ForegroundColor $colors[$Level] -NoNewline
    Write-Host $Message
}

function Backup-Config {
    param([string]$ConfigDir, [string]$AppName)

    if (Test-Path $ConfigDir) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupDir = "${ConfigDir}.backup.${timestamp}"
        Write-Log "Backing up existing $AppName config to $backupDir"
        Copy-Item -Path $ConfigDir -Destination $backupDir -Recurse
    }
}

function Install-Editor {
    param(
        [string]$Editor,
        [string]$ConfigDir,
        [string]$CliCmd
    )

    Write-Log "Installing $Editor configuration..."

    # Create config directory if not exists
    if (-not (Test-Path $ConfigDir)) {
        New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
    }

    # Copy settings and keybindings
    $settingsSource = Join-Path $DotfilesDir "$Editor\settings.json"
    if (Test-Path $settingsSource) {
        Copy-Item -Path $settingsSource -Destination "$ConfigDir\settings.json" -Force
        Write-Log "Copied settings.json"
    }

    $keybindingsSource = Join-Path $DotfilesDir "$Editor\keybindings.json"
    if (Test-Path $keybindingsSource) {
        Copy-Item -Path $keybindingsSource -Destination "$ConfigDir\keybindings.json" -Force
        Write-Log "Copied keybindings.json"
    }

    # Install extensions
    $extensionsFile = Join-Path $DotfilesDir "$Editor\extensions.txt"
    $cliPath = Get-Command $CliCmd -ErrorAction SilentlyContinue

    if ((Test-Path $extensionsFile) -and $cliPath) {
        Write-Log "Installing $Editor extensions..."
        Get-Content $extensionsFile | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
            $extension = $_.Trim()
            Write-Log "  Installing: $extension"
            try {
                & $CliCmd --install-extension $extension --force 2>$null
            }
            catch {
                Write-Log "  Failed: $extension" -Level "WARN"
            }
        }
    }
    elseif (-not $cliPath) {
        Write-Log "$CliCmd CLI not found. Skipping extension installation." -Level "WARN"
        Write-Log "Make sure $Editor is installed and CLI is in PATH." -Level "WARN"
    }

    Write-Log "$Editor configuration installed!"
}

# Main
Write-Host ""
Write-Host "======================================"
Write-Host "  Dotfiles Installer (Windows)"
Write-Host "======================================"
Write-Host ""

switch ($Target) {
    "cursor" {
        Backup-Config -ConfigDir $CursorConfigDir -AppName "Cursor"
        Install-Editor -Editor "cursor" -ConfigDir $CursorConfigDir -CliCmd "cursor"
    }
    "windsurf" {
        Backup-Config -ConfigDir $WindsurfConfigDir -AppName "Windsurf"
        Install-Editor -Editor "windsurf" -ConfigDir $WindsurfConfigDir -CliCmd "windsurf"
    }
    "all" {
        Backup-Config -ConfigDir $CursorConfigDir -AppName "Cursor"
        Backup-Config -ConfigDir $WindsurfConfigDir -AppName "Windsurf"
        Install-Editor -Editor "cursor" -ConfigDir $CursorConfigDir -CliCmd "cursor"
        Write-Host ""
        Install-Editor -Editor "windsurf" -ConfigDir $WindsurfConfigDir -CliCmd "windsurf"
    }
}

Write-Host ""
Write-Log "Installation complete!"
