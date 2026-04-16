#!/bin/bash
# Fresh setup: configure ~/.claude symlink, sync skills, then generate settings.json.
# Run once after cloning the repo on a new machine.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Claude Code Setup ==="
echo ""
echo "Step 1/2: Configure links..."
bash "$SCRIPT_DIR/setup-links.sh"

echo ""
echo "Step 2/2: Configure settings..."
bash "$SCRIPT_DIR/setup-settings.sh"

echo ""
echo "=== Setup complete! ==="
