#!/bin/bash
# Toggle Claude Code between API key (GovTech Bedrock) and Claude subscription (OAuth).
# Usage: toggle-auth.sh [api|sub]
#   No argument: show current profile
#   api:         switch to GovTech API key + Bedrock models
#   sub:         switch to Claude subscription (OAuth login)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="$SCRIPT_DIR/settings.json"
PROFILES_DIR="$SCRIPT_DIR/profiles"
MARKER_FILE="$SCRIPT_DIR/.claude-auth-profile"
TOKEN_CACHE="$SCRIPT_DIR/.claude-auth-token"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

current_profile() {
    if [ -f "$MARKER_FILE" ]; then
        cat "$MARKER_FILE"
    else
        echo "api"
    fi
}

show_status() {
    local profile
    profile=$(current_profile)
    if [ "$profile" = "sub" ]; then
        echo -e "${CYAN}Claude auth:${NC} subscription (OAuth)"
    else
        echo -e "${CYAN}Claude auth:${NC} API key (GovTech Bedrock)"
    fi
}

switch_profile() {
    local target="$1"
    local profile_env="$PROFILES_DIR/${target}.env.json"

    if [ ! -f "$profile_env" ]; then
        echo -e "${RED}Profile not found:${NC} $profile_env"
        exit 1
    fi

    if ! command -v jq &>/dev/null; then
        echo -e "${RED}jq required but not installed.${NC}"
        exit 1
    fi

    if [ ! -f "$SETTINGS" ]; then
        echo -e "${RED}settings.json not found. Run setup-settings.sh first.${NC}"
        exit 1
    fi

    # Read profile env vars
    local new_env
    new_env=$(cat "$profile_env")

    # Rebuild settings: remove model-related env vars, merge profile env, handle modelOverrides
    local config
    config=$(cat "$SETTINGS")

    # Remove switching-related env keys (all ANTHROPIC_DEFAULT_*, ANTHROPIC_CUSTOM_*, base URL, auth token)
    config=$(echo "$config" | jq '.env |= with_entries(select(
        .key | (startswith("ANTHROPIC_DEFAULT_") or startswith("ANTHROPIC_CUSTOM_") or . == "ANTHROPIC_BASE_URL" or . == "ANTHROPIC_AUTH_TOKEN") | not
    ))')

    # Merge profile env vars
    config=$(echo "$config" | jq --argjson penv "$new_env" '.env += $penv')

    # Add/remove modelOverrides and org settings based on profile
    if [ "$target" = "api" ]; then
        config=$(echo "$config" | jq '.modelOverrides = {
            "claude-haiku-4-5-20251001": "bedrock.claude-haiku-4-5",
            "claude-sonnet-4-5-20250929": "bedrock.claude-sonnet-4-5",
            "claude-sonnet-4-6": "bedrock.claude-sonnet-4-6",
            "claude-opus-4-5-20251101": "bedrock.claude-opus-4-5",
            "claude-opus-4-6": "bedrock.claude-opus-4-6"
        }')

        # Restore company announcement
        config=$(echo "$config" | jq '.companyAnnouncements = ["Claude Code managed by GovTech - https://go.gov.sg/gt-cc-managed-settings"]')

        # Re-inject auth token: try env first, then cached file, then current settings
        local token="${ANTHROPIC_AUTH_TOKEN:-}"
        if [ -z "$token" ] && [ -f "$TOKEN_CACHE" ]; then
            token=$(cat "$TOKEN_CACHE")
        fi
        if [ -n "$token" ]; then
            config=$(echo "$config" | jq --arg t "$token" '.env.ANTHROPIC_AUTH_TOKEN = $t')
            # Cache for next time
            echo "$token" > "$TOKEN_CACHE"
            chmod 600 "$TOKEN_CACHE"
        else
            echo -e "${YELLOW}Note:${NC} No cached API token. Run setup-settings.sh or: export ANTHROPIC_AUTH_TOKEN=... && claude-auth api"
        fi
    else
        # Subscription mode: remove modelOverrides and org-specific settings
        config=$(echo "$config" | jq 'del(.modelOverrides, .companyAnnouncements)')
    fi

    echo "$config" > "$SETTINGS"
    echo "$target" > "$MARKER_FILE"

    if [ "$target" = "sub" ]; then
        echo -e "${GREEN}Switched to:${NC} Claude subscription (OAuth)"
    else
        echo -e "${GREEN}Switched to:${NC} API key (GovTech Bedrock)"
    fi
}

case "${1:-}" in
    api|sub)
        if [ "$(current_profile)" = "$1" ]; then
            echo -e "${YELLOW}Already on:${NC} $1"
            exit 0
        fi
        switch_profile "$1"
        ;;
    "")
        show_status
        ;;
    *)
        echo "Usage: toggle-auth.sh [api|sub]"
        echo "  api  — GovTech API key + Bedrock models"
        echo "  sub  — Claude subscription (OAuth)"
        echo "  (no arg) — show current profile"
        exit 1
        ;;
esac
