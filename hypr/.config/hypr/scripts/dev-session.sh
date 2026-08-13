#!/usr/bin/env bash
# ~/.local/bin/launch-workspace-apps.sh
# Launches Brave, Ghostty, and Android Studio onto workspaces 1, 2, 3

hyprctl dispatch exec "[workspace 1 silent] brave-origin --profile-directory='Default'"
hyprctl dispatch exec "[workspace 2 silent] ghostty -e herdr"
hyprctl dispatch exec "[workspace 3 silent] android-studio"
