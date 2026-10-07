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
MODEL_STATE="$SCRIPT_DIR/.claude-auth-models.json"

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

# Is $1 a model ID usable under profile $2? Aliases (opus, sonnet, haiku, ...) always pass.
model_valid_for() {
    local model="$1" profile_json="$2" target="$3"
    case "$model" in
        bedrock.*)
            [ "$target" = "api" ] && echo "$profile_json" | jq -e --arg m "$model" \
                '[.env[], .modelOverrides[]?] | index($m)' >/dev/null
            ;;
        claude-*)
            [ "$target" = "sub" ] || echo "$profile_json" | jq -e --arg m "${model%%\[*}" \
                '.modelOverrides | has($m)' >/dev/null
            ;;
        *) return 0 ;;
    esac
}

switch_profile() {
    local target="$1"
    local from
    from=$(current_profile)
    local profile_file="$PROFILES_DIR/${target}.json"

    if [ ! -f "$profile_file" ]; then
        echo -e "${RED}Profile not found:${NC} $profile_file"
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

    local profile
    profile=$(cat "$PROFILES_DIR/${target}.json")

    local config
    config=$(cat "$SETTINGS")

    # Remember the model selected under the profile we're leaving
    local models='{}'
    [ -f "$MODEL_STATE" ] && models=$(cat "$MODEL_STATE")
    models=$(echo "$models" | jq --arg p "$from" --argjson c "$config" \
        'if $c.model then .[$p] = $c.model else del(.[$p]) end')
    echo "$models" > "$MODEL_STATE"

    # Remove switching-related env keys (all ANTHROPIC_DEFAULT_*, ANTHROPIC_CUSTOM_*, base URL, auth token)
    config=$(echo "$config" | jq '.env |= with_entries(select(
        .key | (startswith("ANTHROPIC_DEFAULT_") or startswith("ANTHROPIC_CUSTOM_") or . == "ANTHROPIC_BASE_URL" or . == "ANTHROPIC_AUTH_TOKEN") | not
    ))')

    # Apply profile: merge env, replace modelOverrides / companyAnnouncements (removed if profile lacks them)
    config=$(echo "$config" | jq --argjson p "$profile" '
        .env += $p.env
        | del(.modelOverrides, .companyAnnouncements)
        | . + ($p | with_entries(select(.key == "modelOverrides" or .key == "companyAnnouncements")))
    ')

    # Restore the model last used under the target profile, else the profile default
    local model
    model=$(echo "$models" | jq -r --arg p "$target" '.[$p] // empty')
    if [ -n "$model" ] && ! model_valid_for "$model" "$profile" "$target"; then
        echo -e "${YELLOW}Note:${NC} saved model '$model' not available on $target, using default"
        model=""
    fi
    [ -z "$model" ] && model=$(echo "$profile" | jq -r '.defaultModel // empty')
    if [ -n "$model" ]; then
        config=$(echo "$config" | jq --arg m "$model" '.model = $m')
    else
        config=$(echo "$config" | jq 'del(.model)')
    fi

    if [ "$target" = "api" ]; then
        # Re-inject auth token: try env first, then cached file
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
    fi

    echo "$config" > "$SETTINGS"
    echo "$target" > "$MARKER_FILE"

    if [ "$target" = "sub" ]; then
        echo -e "${GREEN}Switched to:${NC} Claude subscription (OAuth)"
    else
        echo -e "${GREEN}Switched to:${NC} API key (GovTech Bedrock)"
    fi
    echo -e "${CYAN}Model:${NC} ${model:-default}  (restart claude to apply)"
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
