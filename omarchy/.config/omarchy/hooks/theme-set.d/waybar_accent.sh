#!/usr/bin/env bash

set -euo pipefail

THEME_DIR="$HOME/.config/omarchy/current/theme"
COLORS_FILE="$THEME_DIR/colors.toml"
WAYBAR_FILE="$THEME_DIR/waybar.css"

# Extract accent color
accent=$(grep '^accent *= *"' "$COLORS_FILE" | sed -E 's/.*"([^"]+)".*/\1/')

if [[ -z "$accent" ]]; then
    echo "Failed to extract accent color from $COLORS_FILE"
    exit 1
fi

# Remove existing @define-color accent line if present
sed -i '/^@define-color accent /d' "$WAYBAR_FILE"

# Append new accent definition
echo "@define-color accent $accent;" >> "$WAYBAR_FILE"

echo "Updated accent color in $WAYBAR_FILE"

~/.local/share/omarchy/bin/omarchy toggle waybar
~/.local/share/omarchy/bin/omarchy toggle waybar
