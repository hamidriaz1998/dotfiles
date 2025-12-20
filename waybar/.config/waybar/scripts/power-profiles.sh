#!/bin/bash

menu() {
  local prompt="$1"
  local options="$2"

  printf "%s\n" "$options" |
    walker --dmenu --width 295 --minheight 1 --maxheight 630 \
      -p "$prompt…" 2>/dev/null
}

# Get list of profiles
if command -v jq >/dev/null; then
  raw_options=$(~/.local/bin/power-daemon-mgr list-profiles | jq -r '.[]')
else
  raw_options=$(~/.local/bin/power-daemon-mgr list-profiles | tr -d '[]" ' | tr ',' '\n')
fi

# Add "Default"
raw_options="Default"$'\n'"${raw_options}"

# Detect current override
current=$(~/.local/bin/power-daemon-mgr get-profile-override 2>/dev/null || true)
if [[ "$current" == "No profile override is currently set" ]]; then
  current="Default"
fi

# Icons for each profile
icon_for() {
  case "$1" in
    "Default")        echo "󱂬" ;;
    "Powersave++")    echo "" ;;
    "Powersave")      echo "" ;;
    "Balanced")       echo "" ;;
    "Performance")    echo "" ;;
    "Performance++")  echo "" ;;
    *)                echo "󰓅" ;;
  esac
}

# Decorate line: ICON + NAME + (✔ if current)
decorate() {
  local icon
  icon=$(icon_for "$1")

  if [[ "$1" == "$current" ]]; then
    echo "$icon $1 ✔"
  else
    echo "$icon $1"
  fi
}

# Build final menu
options=""
while IFS= read -r o; do
  options+=$(decorate "$o")$'\n'
done <<<"$raw_options"
options="${options%$'\n'}"

# Strip icon + checkmark from selection
strip_line() {
  # remove first glyph + space
  line=$(echo "$1" | sed 's/^[^ ]* //')
  # remove trailing checkmark
  echo "$line" | sed 's/ ✔$//'
}

selected=$(menu "Power Profile" "$options")
[[ -z "$selected" ]] && exit 0

clean=$(strip_line "$selected")

if [[ "$clean" == "Default" ]]; then
    ~/.local/bin/power-daemon-mgr reset-profile-override
    notify-send "⚡ Power Mode Reset" "Using system default"
else
    ~/.local/bin/power-daemon-mgr set-profile-override "$clean"
    notify-send "⚡ Power Mode Updated" "$clean"
fi
