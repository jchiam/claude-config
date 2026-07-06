#!/bin/bash
# Generates settings.json from settings.template.json.
# Prompts for sensitive values; skipped values are omitted from output.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/settings.template.json"
OUTPUT="$SCRIPT_DIR/settings.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Require jq
if ! command -v jq &>/dev/null; then
    error "jq is required but not installed."
    echo "  macOS:  brew install jq"
    echo "  Ubuntu: sudo apt-get install jq"
    exit 1
fi

# Require template
if [ ! -f "$TEMPLATE" ]; then
    error "Template not found: $TEMPLATE"
    exit 1
fi

# Confirm overwrite if settings.json already exists
if [ -f "$OUTPUT" ]; then
    warn "settings.json already exists."
    read -rp "Overwrite? [y/N] " confirm
    case "$confirm" in
        [yY]) ;;
        *) info "Skipped. No changes made."; exit 0 ;;
    esac
fi

# Start from template
config=$(cat "$TEMPLATE")

# --- ANTHROPIC_AUTH_TOKEN ---
echo ""
echo "Enter your ANTHROPIC_AUTH_TOKEN (press Enter to skip):"
read -rsp "> " auth_token
echo ""

if [ -n "$auth_token" ]; then
    config=$(echo "$config" | jq --arg val "$auth_token" '.env.ANTHROPIC_AUTH_TOKEN = $val')
    info "ANTHROPIC_AUTH_TOKEN set."
else
    warn "ANTHROPIC_AUTH_TOKEN skipped — key will not be present in settings.json."
fi

# --- Status line ---
statusline_script="$SCRIPT_DIR/statusline-command.sh"
if [ -f "$statusline_script" ]; then
    config=$(echo "$config" | jq --arg cmd "bash \"$statusline_script\"" \
        '.statusLine = {"type": "command", "command": $cmd}')
    info "statusLine configured."
fi

# --- GovTech Claude Code tools ---
echo ""
read -rp "Install GovTech Claude Code tools? (runs: gt tools configure claude-code) [y/N] " gt_confirm
case "$gt_confirm" in
    [yY])
        info "Running: gt tools configure claude-code"
        if command -v gt &>/dev/null; then
            # Write current config first so gt can merge into it
            echo "$config" > "$OUTPUT"
            gt tools configure claude-code
            info "GovTech tools configured. settings.json updated by gt."
            exit 0
        else
            error "'gt' command not found. Install GovTech tools first."
            echo "  See: https://go.gov.sg/gt-cc-managed-settings"
        fi
        ;;
    *)
        warn "GovTech tools skipped — OTEL settings will not be present."
        ;;
esac

# Write final output
echo "$config" > "$OUTPUT"
info "settings.json written to: $OUTPUT"
