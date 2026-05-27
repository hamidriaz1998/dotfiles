#!/usr/bin/env bash

set -euo pipefail

THEME_DIR="$HOME/.config/omarchy/current/theme"
COLORS_FILE="$THEME_DIR/colors.toml"
WAYBAR_FILE="$THEME_DIR/waybar.css"

# Exit if accent already exists
if grep -q '^@define-color accent ' "$WAYBAR_FILE"; then
    echo "Accent color already defined in $WAYBAR_FILE"
    exit 0
fi

# Extract accent color
accent=$(grep '^accent *= *"' "$COLORS_FILE" | sed -E 's/.*"([^"]+)".*/\1/')

if [[ -z "$accent" ]]; then
    echo "Failed to extract accent color from $COLORS_FILE"
    exit 1
fi

# Append new accent definition
echo "@define-color accent $accent;" >> "$WAYBAR_FILE"

echo "Added accent color to $WAYBAR_FILE"

~/.local/share/omarchy/bin/omarchy toggle waybar
~/.local/share/omarchy/bin/omarchy toggle waybar
