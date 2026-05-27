#!/usr/bin/env bash

set -euo pipefail

THEME_DIR="$HOME/.config/omarchy/current/theme"
COLORS_FILE="$THEME_DIR/colors.toml"
OUTPUT_FILE="$THEME_DIR/ltmnight.rasi"

# Read a value from TOML
get_color() {
    grep "^$1 *= *\"" "$COLORS_FILE" \
        | sed -E 's/.*"([^"]+)".*/\1/'
}

# Convert hex (#rrggbb) to rgba(r, g, b, a)
hex_to_rgba() {
    local hex="${1#\#}"
    local alpha="${2:-1.0}"

    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    printf 'rgba(%d, %d, %d, %s)' "$r" "$g" "$b" "$alpha"
}

accent=$(get_color accent)
cursor=$(get_color cursor)
foreground=$(get_color foreground)
background=$(get_color background)
selection_foreground=$(get_color selection_foreground)
selection_background=$(get_color selection_background)

color0=$(get_color color0)
color1=$(get_color color1)
color2=$(get_color color2)
color3=$(get_color color3)
color4=$(get_color color4)
color5=$(get_color color5)
color6=$(get_color color6)
color7=$(get_color color7)
color8=$(get_color color8)
color9=$(get_color color9)
color10=$(get_color color10)
color11=$(get_color color11)
color12=$(get_color color12)
color13=$(get_color color13)
color14=$(get_color color14)
color15=$(get_color color15)

cat > "$OUTPUT_FILE" <<EOF
// Auto-generated from colors.toml

* {
    ltmnight0:  $background; /* Background */
    ltmnight1:  $color0; /* Secondary Background */
    ltmnight2:  $foreground; /* Foreground Text */
    ltmnight3:  $color8; /* Comment / Outline */
    ltmnight4:  $color1; /* Red / Errors */
    ltmnight5:  $color3; /* Orange / Warnings */
    ltmnight6:  $color11; /* Yellow / Highlights */
    ltmnight7:  $color2; /* Green / Success */
    ltmnight8:  $color6; /* Cyan / Info */
    ltmnight9:  $color5; /* Purple / Primary */
    ltmnight10: $accent; /* Pink / Accent */
    ltmnight11: $color7; /* Gray / Placeholder */

    // Rofi Color Mappings to ltmnight Palette
    background: $(hex_to_rgba "$background" 0.9);
    foreground: @ltmnight2;

    primary: @ltmnight9;
    accent:  @ltmnight10;
    on-primary: $cursor;

    primary-fixed: @ltmnight1;
    on-primary-fixed: @ltmnight2;

    selection: $(hex_to_rgba "$selection_background" 0.5);
    on-selection: $selection_foreground;

    error: @ltmnight4;
    on-error: $cursor;

    surface: $(hex_to_rgba "$background" 0.9);
    on-surface: @ltmnight2;

    outline: @ltmnight3;
    shadow: rgba(0, 0, 0, 0.5);

    highlight: @ltmnight6;

    prompt: @ltmnight11;
    placeholder: @ltmnight11;

    message-background: transparent;
    message-border: @ltmnight8;
    message-text: @ltmnight8;

    error-message: @ltmnight4;
    warning-message: @ltmnight5;
    success-message: @ltmnight7;
    info-message: @ltmnight8;
}
EOF

echo "Generated $OUTPUT_FILE"
