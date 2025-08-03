#!/usr/bin/env bash

set -e

echo "==> Restoring GNOME settings from dconf..."
dconf load / < ~/dotfiles/gnome/dconf-settings.ini

echo "==> Restoring custom GNOME extensions..."
# Copy any manually backed-up extensions
cp -r ~/dotfiles/gnome/extensions/* ~/.local/share/gnome-shell/extensions/ || echo "No custom extensions found to copy."

echo "==> Checking gnome-shell-extension-installer..."
if ! command -v gnome-shell-extension-installer &> /dev/null; then
    echo "gnome-shell-extension-installer not found. Installing it..."
    wget -O gnome-shell-extension-installer "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer"
    chmod +x gnome-shell-extension-installer
    sudo mv gnome-shell-extension-installer /usr/bin/
else
    echo "gnome-shell-extension-installer already installed."
fi

echo "==> Installing extensions from list..."
while read uuid; do
    echo "Installing $uuid..."
    gnome-shell-extension-installer "$uuid" --yes
done < ~/dotfiles/gnome/extensions-list.txt

echo "==> Reloading GNOME Shell..."
# If you're on X11, you can restart GNOME Shell:
# ALT+F2, type 'r', and press Enter.
# On Wayland, you must log out and back in.
echo "Manual step: Press ALT+F2, type 'r', and press Enter (X11 only). For Wayland, log out and back in."

echo "==> Done!"
