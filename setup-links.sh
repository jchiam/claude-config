#!/bin/bash
# Sets up:
#   1. ~/.claude symlink → this repo directory
#   2. Skill symlinks from ~/.claude/skills to ~/.qoderwork/skills and ~/.qwen/skills

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$SCRIPT_DIR/skills"
QODERWORK_SKILLS_DIR="$HOME/.qoderwork/skills"
QWEN_SKILLS_DIR="$HOME/.qwen/skills"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

is_windows() {
    case "$(uname -s)" in
        CYGWIN*|MINGW*|MSYS*) return 0 ;;
        *) return 1 ;;
    esac
}

create_skill_link() {
    local source="$1"
    local target="$2"
    local name=$(basename "$target")

    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target"
    fi

    mkdir -p "$(dirname "$target")"

    if is_windows; then
        local win_source=$(cygpath -w "$source" 2>/dev/null || echo "$source")
        local win_target=$(cygpath -w "$target" 2>/dev/null || echo "$target")
        cmd //c "mklink /J \"$win_target\" \"$win_source\"" > /dev/null 2>&1 && {
            info "Linked: $name"
        } || {
            cmd //c "mklink /D \"$win_target\" \"$win_source\"" > /dev/null 2>&1 || {
                error "Failed to create link for $name (may need Administrator)"
                return 1
            }
        }
    else
        ln -s "$source" "$target"
        info "Linked: $name"
    fi
}

# Step 1: ~/.claude → this repo
link_claude() {
    info "Configuring $CLAUDE_DIR → $SCRIPT_DIR"

    if [ -L "$CLAUDE_DIR" ]; then
        local current
        current=$(readlink "$CLAUDE_DIR")
        if [ "$current" = "$SCRIPT_DIR" ]; then
            info "~/.claude already points to this repo. Skipping."
            return
        fi
        warn "~/.claude currently points to: $current"
        read -rp "Repoint to this repo? [y/N] " confirm
        [[ "$confirm" =~ ^[yY]$ ]] || { info "Skipped ~/.claude link."; return; }
        rm "$CLAUDE_DIR"
    elif [ -d "$CLAUDE_DIR" ]; then
        warn "~/.claude is a real directory (not a symlink)."
        read -rp "Back it up and replace with symlink? [y/N] " confirm
        [[ "$confirm" =~ ^[yY]$ ]] || { info "Skipped ~/.claude link."; return; }
        local backup="${CLAUDE_DIR}.bak.$(date +%s)"
        mv "$CLAUDE_DIR" "$backup"
        warn "Backed up existing ~/.claude to: $backup"
    fi

    ln -s "$SCRIPT_DIR" "$CLAUDE_DIR"
    info "Created: ~/.claude → $SCRIPT_DIR"
}

# Step 2: Sync skills to other tool directories
sync_skills() {
    info "Syncing skills to other tool directories..."

    if [ ! -d "$SKILLS_DIR" ]; then
        warn "Skills directory not found: $SKILLS_DIR"
        return
    fi

    local skills=()
    for skill_path in "$SKILLS_DIR"/*/; do
        [ -d "$skill_path" ] && skills+=("$(basename "$skill_path")")
    done

    if [ ${#skills[@]} -eq 0 ]; then
        warn "No skills found in $SKILLS_DIR"
        return
    fi

    info "Found ${#skills[@]} skill(s)"

    for skill in "${skills[@]}"; do
        local source="$SKILLS_DIR/$skill"
        create_skill_link "$source" "$QODERWORK_SKILLS_DIR/$skill"
        create_skill_link "$source" "$QWEN_SKILLS_DIR/$skill"
    done

    info "Skills synced."
}

link_claude
echo ""
sync_skills
echo ""
info "Links configured."
