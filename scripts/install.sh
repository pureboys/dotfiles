#!/bin/bash
#
# Dotfiles Install Script for macOS / Linux
# Usage: ./install.sh [cursor|windsurf|all]
#

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET=${1:-all}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS and set config paths
detect_os() {
    case "$(uname -s)" in
        Darwin)
            OS="macos"
            CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
            WINDSURF_CONFIG_DIR="$HOME/Library/Application Support/Windsurf/User"
            ;;
        Linux)
            OS="linux"
            CURSOR_CONFIG_DIR="$HOME/.config/Cursor/User"
            WINDSURF_CONFIG_DIR="$HOME/.config/Windsurf/User"
            ;;
        *)
            log_error "Unsupported OS. Use install.ps1 for Windows."
            exit 1
            ;;
    esac
    log_info "Detected OS: $OS"
}

# Backup existing config
backup_config() {
    local config_dir="$1"
    local app_name="$2"

    if [ -d "$config_dir" ]; then
        local backup_dir="${config_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up existing $app_name config to $backup_dir"
        cp -r "$config_dir" "$backup_dir"
    fi
}

# Install config for an editor
install_editor() {
    local editor="$1"
    local config_dir="$2"
    local cli_cmd="$3"

    log_info "Installing $editor configuration..."

    # Create config directory if not exists
    mkdir -p "$config_dir"

    # Copy settings and keybindings
    if [ -f "$DOTFILES_DIR/$editor/settings.json" ]; then
        cp "$DOTFILES_DIR/$editor/settings.json" "$config_dir/settings.json"
        log_info "Copied settings.json"
    fi

    if [ -f "$DOTFILES_DIR/$editor/keybindings.json" ]; then
        cp "$DOTFILES_DIR/$editor/keybindings.json" "$config_dir/keybindings.json"
        log_info "Copied keybindings.json"
    fi

    # Install extensions
    if [ -f "$DOTFILES_DIR/$editor/extensions.txt" ] && command -v "$cli_cmd" &> /dev/null; then
        log_info "Installing $editor extensions..."
        while IFS= read -r extension || [ -n "$extension" ]; do
            if [ -n "$extension" ]; then
                log_info "  Installing: $extension"
                "$cli_cmd" --install-extension "$extension" --force 2>/dev/null || log_warn "  Failed: $extension"
            fi
        done < "$DOTFILES_DIR/$editor/extensions.txt"
    elif ! command -v "$cli_cmd" &> /dev/null; then
        log_warn "$cli_cmd CLI not found. Skipping extension installation."
        log_warn "Make sure $editor is installed and CLI is in PATH."
    fi

    log_info "$editor configuration installed!"
}

# Main
main() {
    detect_os

    echo ""
    echo "======================================"
    echo "  Dotfiles Installer"
    echo "======================================"
    echo ""

    case "$TARGET" in
        cursor)
            backup_config "$CURSOR_CONFIG_DIR" "Cursor"
            install_editor "cursor" "$CURSOR_CONFIG_DIR" "cursor"
            ;;
        windsurf)
            backup_config "$WINDSURF_CONFIG_DIR" "Windsurf"
            install_editor "windsurf" "$WINDSURF_CONFIG_DIR" "windsurf"
            ;;
        all)
            backup_config "$CURSOR_CONFIG_DIR" "Cursor"
            backup_config "$WINDSURF_CONFIG_DIR" "Windsurf"
            install_editor "cursor" "$CURSOR_CONFIG_DIR" "cursor"
            echo ""
            install_editor "windsurf" "$WINDSURF_CONFIG_DIR" "windsurf"
            ;;
        *)
            echo "Usage: $0 [cursor|windsurf|all]"
            exit 1
            ;;
    esac

    echo ""
    log_info "Installation complete!"
}

main
