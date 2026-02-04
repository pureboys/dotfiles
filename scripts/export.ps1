#
# Export current editor configs to dotfiles repo (Windows)
# Usage: .\export.ps1 [-Target cursor|windsurf|all]
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

$CursorConfigDir = "$env:APPDATA\Cursor\User"
$WindsurfConfigDir = "$env:APPDATA\Windsurf\User"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $colors = @{ "INFO" = "Green"; "WARN" = "Yellow" }
    Write-Host "[$Level] " -ForegroundColor $colors[$Level] -NoNewline
    Write-Host $Message
}

function Export-Editor {
    param(
        [string]$Editor,
        [string]$ConfigDir,
        [string]$CliCmd
    )

    Write-Log "Exporting $Editor configuration..."

    $editorDir = Join-Path $DotfilesDir $Editor
    if (-not (Test-Path $editorDir)) {
        New-Item -ItemType Directory -Path $editorDir -Force | Out-Null
    }

    # Export settings
    $settingsPath = Join-Path $ConfigDir "settings.json"
    if (Test-Path $settingsPath) {
        Copy-Item -Path $settingsPath -Destination (Join-Path $editorDir "settings.json") -Force
        Write-Log "Exported settings.json"
    }
    else {
        Write-Log "No settings.json found for $Editor" -Level "WARN"
    }

    # Export keybindings
    $keybindingsPath = Join-Path $ConfigDir "keybindings.json"
    if (Test-Path $keybindingsPath) {
        Copy-Item -Path $keybindingsPath -Destination (Join-Path $editorDir "keybindings.json") -Force
        Write-Log "Exported keybindings.json"
    }

    # Export extensions
    $cliPath = Get-Command $CliCmd -ErrorAction SilentlyContinue
    if ($cliPath) {
        $extensions = & $CliCmd --list-extensions
        $extensions | Out-File -FilePath (Join-Path $editorDir "extensions.txt") -Encoding utf8
        Write-Log "Exported $($extensions.Count) extensions to extensions.txt"
    }
    else {
        Write-Log "$CliCmd CLI not found. Skipping extensions export." -Level "WARN"
    }

    Write-Log "$Editor export done!"
}

# Main
Write-Host ""
Write-Host "======================================"
Write-Host "  Dotfiles Exporter (Windows)"
Write-Host "======================================"
Write-Host ""

switch ($Target) {
    "cursor" {
        Export-Editor -Editor "cursor" -ConfigDir $CursorConfigDir -CliCmd "cursor"
    }
    "windsurf" {
        Export-Editor -Editor "windsurf" -ConfigDir $WindsurfConfigDir -CliCmd "windsurf"
    }
    "all" {
        Export-Editor -Editor "cursor" -ConfigDir $CursorConfigDir -CliCmd "cursor"
        Write-Host ""
        Export-Editor -Editor "windsurf" -ConfigDir $WindsurfConfigDir -CliCmd "windsurf"
    }
}

Write-Host ""
Write-Log "Export complete! Don't forget to commit:"
Write-Host "  cd $DotfilesDir; git add -A; git commit -m 'update configs'"
