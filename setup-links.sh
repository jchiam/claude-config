#!/bin/bash
# Cross-platform skill symlink setup script
# This script creates symlinks from central git-managed skills to various AI tool directories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
QODERWORK_SKILLS_DIR="$HOME/.qoderwork/skills"
QWEN_SKILLS_DIR="$HOME/.qwen/skills"

# Function to print status
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Windows (Git Bash, MSYS, Cygwin)
is_windows() {
    case "$(uname -s)" in
        CYGWIN*|MINGW*|MSYS*) return 0 ;;
        *) return 1 ;;
    esac
}

# Create symlink (cross-platform)
create_link() {
    local source="$1"
    local target="$2"
    local name=$(basename "$source")

    # Remove existing file/link if it exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        warn "Removing existing $target"
        rm -rf "$target"
    fi

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"

    if is_windows; then
        # Windows: Use mklink (requires Administrator privileges)
        # Convert Unix paths to Windows paths
        local win_source=$(cygpath -w "$source" 2>/dev/null || echo "$source")
        local win_target=$(cygpath -w "$target" 2>/dev/null || echo "$target")

        # Use junction for directories (doesn't require admin)
        cmd //c "mklink /J \"$win_target\" \"$win_source\"" > /dev/null 2>&1 && {
            info "Created junction: $name -> $target"
        } || {
            # Fallback to directory symlink (requires admin)
            cmd //c "mklink /D \"$win_target\" \"$win_source\"" > /dev/null 2>&1 && {
                info "Created symlink: $name -> $target"
            } || {
                error "Failed to create link for $name (may need Administrator privileges)"
                return 1
            }
        }
    else
        # macOS/Linux: Use standard symlinks
        ln -s "$source" "$target"
        info "Created symlink: $name -> $target"
    fi
}

# Main setup function
setup_skills() {
    info "Setting up skill symlinks..."
    info "Source: $CLAUDE_SKILLS_DIR"

    # Check if source directory exists
    if [ ! -d "$CLAUDE_SKILLS_DIR" ]; then
        error "Claude skills directory not found: $CLAUDE_SKILLS_DIR"
        exit 1
    fi

    # Find all skill directories in Claude skills folder
    local skills=()
    for skill_path in "$CLAUDE_SKILLS_DIR"/*; do
        if [ -d "$skill_path" ]; then
            skills+=("$(basename "$skill_path")")
        fi
    done

    if [ ${#skills[@]} -eq 0 ]; then
        warn "No skills found in $CLAUDE_SKILLS_DIR"
        exit 0
    fi

    info "Found ${#skills[@]} skill(s): ${skills[*]}"

    # Create symlinks for each tool
    for skill in "${skills[@]}"; do
        local source="$CLAUDE_SKILLS_DIR/$skill"

        # QoderWork
        create_link "$source" "$QODERWORK_SKILLS_DIR/$skill"

        # Qwen VSCode
        create_link "$source" "$QWEN_SKILLS_DIR/$skill"
    done

    info "Setup complete!"
}

# Run setup
setup_skills
