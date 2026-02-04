#!/bin/bash
#
# Export current editor configs to dotfiles repo (macOS / Linux)
# Usage: ./export.sh [cursor|windsurf|all]
#

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET=${1:-all}

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

detect_os() {
    case "$(uname -s)" in
        Darwin)
            CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
            WINDSURF_CONFIG_DIR="$HOME/Library/Application Support/Windsurf/User"
            ;;
        Linux)
            CURSOR_CONFIG_DIR="$HOME/.config/Cursor/User"
            WINDSURF_CONFIG_DIR="$HOME/.config/Windsurf/User"
            ;;
        *)
            echo "Unsupported OS. Use export.ps1 for Windows."
            exit 1
            ;;
    esac
}

export_editor() {
    local editor="$1"
    local config_dir="$2"
    local cli_cmd="$3"

    log_info "Exporting $editor configuration..."

    mkdir -p "$DOTFILES_DIR/$editor"

    # Export settings
    if [ -f "$config_dir/settings.json" ]; then
        cp "$config_dir/settings.json" "$DOTFILES_DIR/$editor/settings.json"
        log_info "Exported settings.json"
    else
        log_warn "No settings.json found for $editor"
    fi

    # Export keybindings
    if [ -f "$config_dir/keybindings.json" ]; then
        cp "$config_dir/keybindings.json" "$DOTFILES_DIR/$editor/keybindings.json"
        log_info "Exported keybindings.json"
    fi

    # Export extensions list
    if command -v "$cli_cmd" &> /dev/null; then
        "$cli_cmd" --list-extensions > "$DOTFILES_DIR/$editor/extensions.txt"
        local count
        count=$(wc -l < "$DOTFILES_DIR/$editor/extensions.txt" | tr -d ' ')
        log_info "Exported $count extensions to extensions.txt"
    else
        log_warn "$cli_cmd CLI not found. Skipping extensions export."
    fi

    log_info "$editor export done!"
}

# Main
detect_os

echo ""
echo "======================================"
echo "  Dotfiles Exporter"
echo "======================================"
echo ""

case "$TARGET" in
    cursor)
        export_editor "cursor" "$CURSOR_CONFIG_DIR" "cursor"
        ;;
    windsurf)
        export_editor "windsurf" "$WINDSURF_CONFIG_DIR" "windsurf"
        ;;
    all)
        export_editor "cursor" "$CURSOR_CONFIG_DIR" "cursor"
        echo ""
        export_editor "windsurf" "$WINDSURF_CONFIG_DIR" "windsurf"
        ;;
    *)
        echo "Usage: $0 [cursor|windsurf|all]"
        exit 1
        ;;
esac

echo ""
log_info "Export complete! Don't forget to commit:"
echo "  cd $DOTFILES_DIR && git add -A && git commit -m 'update configs'"
