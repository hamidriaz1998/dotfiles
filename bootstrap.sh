#!/usr/bin/env bash

set -e

echo "==> Checking and installing required tools..."

# Function to check and install a package if missing
check_and_install() {
  local cmd="$1"
  local pkg="$2"

  if ! command -v "$cmd" &> /dev/null; then
    echo "⚙ $cmd not found — installing $pkg..."

    if [ -f /etc/debian_version ]; then
      sudo apt update && sudo apt install -y "$pkg"
    elif [ -f /etc/fedora-release ]; then
      sudo dnf install -y "$pkg"
    elif [ -f /etc/arch-release ]; then
      sudo pacman -Sy --noconfirm "$pkg"
    else
      echo "Error: Unsupported distro. Please install $pkg manually."
      exit 1
    fi

    echo "✔ $cmd installed."
  else
    echo "✔ $cmd found."
  fi
}

# Required tools
check_and_install stow stow
check_and_install wget wget

# Only install dconf if GNOME desktop environment is detected
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" || "$DESKTOP_SESSION" == "gnome" ]]; then
    check_and_install dconf dconf
fi

echo "==> Bootstrapping dotfiles with GNU Stow..."
cd ~/dotfiles

for pkg in */ ; do
  pkg="${pkg%/}"  # Remove trailing slash
  if [ "$pkg" != "gnome" ] && [ -d "$pkg" ]; then
    echo "Stowing $pkg..."
    stow "$pkg"
  fi
done

# Only run GNOME setup if current desktop env is GNOME
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" || "$DESKTOP_SESSION" == "gnome" ]]; then
    echo "==> Running GNOME setup..."
    bash ~/dotfiles/gnome-setup.sh
else
    echo "==> GNOME desktop environment not detected. Skipping GNOME setup."
fi

echo "==> All done! ✅ Your dotfiles and GNOME config are ready."