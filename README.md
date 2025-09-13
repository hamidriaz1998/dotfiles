# Dotfiles

Welcome to my dotfiles repository! This project contains my personal configuration files and scripts for setting up and customizing my development environment. It includes shell configurations, GNOME settings, and other tools to streamline my workflow.

## Features

- **Automated Setup**: Scripts to bootstrap your environment quickly.
- **GNOME Integration**: Backup and restore GNOME settings and extensions.
- **Version Control**: Keep track of changes to your configuration files.
- **Portability**: Easily replicate your setup on new machines.
- **Customization**: Tailor your environment to your specific needs.

## Structure

The repository is organized as follows:

- `bootstrap.sh`: Main script to check dependencies, install required tools, and apply dotfiles using GNU Stow.
- `gnome-setup.sh`: Script to restore GNOME settings, extensions, and configurations.
- `Makefile`: Provides commands for installation, uninstallation, backup, and updates.
- `zsh/`: Contains Zsh configuration files, including `.zshenv` and `.zshrc`.
- `gnome/`: Includes GNOME-specific settings like `dconf-settings.ini` and `extensions-list.txt`.
- `starship/`: Placeholder for Starship prompt configuration.
- `zed/`: Placeholder for Zed editor configuration.
- `ghostty/`: Placeholder for Ghostty-related configuration.

## Installation

To use these dotfiles on your system, follow these steps:

1. Clone the repository:

   ```bash
   git clone https://github.com/hamidriaz1999/dotfiles.git ~/.dotfiles
   ```

2. Navigate to the dotfiles directory:

   ```bash
   cd ~/.dotfiles
   ```

3. Run the bootstrap script to set up your environment:

   ```bash
   ./bootstrap.sh
   ```

   This script will:
   - Check and install required tools (`stow`, `dconf`, `wget`) based on your Linux distribution.
   - Apply dotfiles for various tools and environments using GNU Stow.
   - Restore GNOME settings from `dconf-settings.ini` and install extensions listed in `extensions-list.txt`.

4. Follow any additional instructions provided by the scripts (e.g., reloading GNOME Shell).

## Makefile Commands

This repository includes a `Makefile` for convenience. Here are the available commands:

- **Install**: Run the full bootstrap process.

  ```bash
  make install
  ```

- **Uninstall**: Unstow all dotfiles except GNOME-related ones.

  ```bash
  make uninstall
  ```

- **Backup**: Save current GNOME settings and extensions list.

  ```bash
  make backup
  ```

- **Update**: Pull the latest changes from the repository and re-run the bootstrap process.
  ```bash
  make update
  ```

## Customization

Feel free to modify these files to suit your preferences. Each file is structured to be easily understandable and adaptable to your needs.
