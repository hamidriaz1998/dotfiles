#!/usr/bin/env bash

set -e

echo "==> Welcome to dotfiles setup! 🎀"

# Function to check and install a package if missing
check_and_install() {
    local cmd="$1"
    local pkg="$2"

    if ! command -v "$cmd" &>/dev/null; then
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

# Function to install Gum for beautiful prompts
install_gum() {
    if ! command -v gum &>/dev/null; then
        echo "⚙ Installing Gum for beautiful prompts..."

        if [ -f /etc/debian_version ]; then
            # Debian/Ubuntu
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
            sudo apt update && sudo apt install -y gum
        elif [ -f /etc/fedora-release ]; then
            # Fedora/RHEL
            echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
            sudo rpm --import https://repo.charm.sh/yum/gpg.key
            sudo dnf install -y gum
        elif [ -f /etc/arch-release ]; then
            # Arch Linux
            sudo pacman -Sy --noconfirm gum
        else
            echo "⚠ Unsupported distro for Gum auto-install. Please install manually:"
            echo "  Visit: https://github.com/charmbracelet/gum#installation"
            exit 1
        fi

        echo "✔ Gum installed."
    else
        echo "✔ Gum found."
    fi
}

# Function to ask user for shell preference using Gum
choose_shell() {
    echo ""
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "1 2" \
        "Shell Selection" "Choose your preferred shell"

    SELECTED_SHELL=$(gum choose --header "Which shell would you like to use?" "fish" "zsh")

    case $SELECTED_SHELL in
    "fish")
        SHELL_PKG="fish"
        ;;
    "zsh")
        SHELL_PKG="zsh"
        ;;
    esac

    gum style \
        --foreground 46 --bold \
        "✔ Selected shell: $SELECTED_SHELL"
}

echo "==> Checking and installing required tools..."

# Required tools (including Gum for beautiful prompts)
check_and_install stow stow
check_and_install wget wget
check_and_install curl curl

# Install Gum first so we can use it for prompts
install_gum

# Ask user for shell preference using beautiful Gum prompts
choose_shell

# Install selected shell
check_and_install "$SELECTED_SHELL" "$SHELL_PKG"

# Only install dconf if GNOME desktop environment is detected
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" || "$DESKTOP_SESSION" == "gnome" ]]; then
    check_and_install dconf dconf
fi

# Install shell-specific tools and frameworks
if [ "$SELECTED_SHELL" = "zsh" ]; then
    # Install oh-my-zsh if not already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        gum spin --spinner dot --title "Installing oh-my-zsh..." -- \
            sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo "✔ oh-my-zsh installed."
    else
        echo "✔ oh-my-zsh found."
    fi
elif [ "$SELECTED_SHELL" = "fish" ]; then
    # Check if Fisher (fish plugin manager) should be installed
    if ! fish -c "functions -q fisher" 2>/dev/null; then
        gum spin --spinner dot --title "Installing Fisher (fish plugin manager)..." -- \
            fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
        echo "✔ Fisher installed."
    else
        echo "✔ Fisher found."
    fi
fi

gum style \
    --foreground 99 --border-foreground 99 --border rounded \
    --align center --width 60 --margin "1 0" --padding "1 2" \
    "Bootstrapping dotfiles with GNU Stow..."

cd ~/.dotfiles

for pkg in */; do
    pkg="${pkg%/}" # Remove trailing slash

    # Skip directories based on shell choice and other conditions
    if [ "$pkg" = "gnome" ]; then
        continue # Handle GNOME separately
    fi

    # Skip the shell config that wasn't selected
    if [ "$SELECTED_SHELL" = "fish" ] && [ "$pkg" = "zsh" ]; then
        gum style --foreground 240 "Skipping zsh config (fish selected)..."
        continue
    elif [ "$SELECTED_SHELL" = "zsh" ] && [ "$pkg" = "fish" ]; then
        gum style --foreground 240 "Skipping fish config (zsh selected)..."
        continue
    fi

    if [ -d "$pkg" ]; then
        gum style --foreground 46 "Stowing $pkg..."
        stow "$pkg"
    fi
done

# Install fish plugins if fish was selected and fish_plugins file exists
if [ "$SELECTED_SHELL" = "fish" ] && [ -f "$HOME/.config/fish/fish_plugins" ]; then
    gum spin --spinner dot --title "Installing fish plugins..." -- fish -c "fisher update"
    echo "✔ Fish plugins installed."
fi

# Only run GNOME setup if current desktop env is GNOME
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" || "$DESKTOP_SESSION" == "gnome" ]]; then
    gum style \
        --foreground 165 --border-foreground 165 --border rounded \
        --align center --width 50 --margin "1 0" --padding "1 2" \
        "Running GNOME setup..."
    bash ~/.dotfiles/gnome-setup.sh
else
    gum style --foreground 240 "GNOME desktop environment not detected. Skipping GNOME setup."
fi

# Set the selected shell as default if it's not already
current_shell=$(basename "$SHELL")
if [ "$current_shell" != "$SELECTED_SHELL" ]; then
    if gum confirm "Set $SELECTED_SHELL as your default shell?"; then
        shell_path=$(which "$SELECTED_SHELL")

        # Add shell to /etc/shells if not present
        if ! grep -q "$shell_path" /etc/shells; then
            gum style --foreground 226 "Adding $shell_path to /etc/shells..."
            echo "$shell_path" | sudo tee -a /etc/shells
        fi

        # Change default shell
        chsh -s "$shell_path"
        gum style --foreground 46 "✔ Default shell changed to $SELECTED_SHELL"
        gum style --foreground 226 "⚠ Please log out and log back in for the shell change to take effect."
    else
        gum style --foreground 240 "Keeping current shell ($current_shell)."
    fi
else
    gum style --foreground 46 "✔ $SELECTED_SHELL is already your default shell."
fi

echo ""

# Final success message with styling
SUCCESS_MSG="All done! ✅ Your dotfiles and $SELECTED_SHELL config are ready."
if [ "$SELECTED_SHELL" = "fish" ]; then
    SHELL_MSG="🐟 Fish shell configured with your dotfiles.\nStart a new terminal session or run 'fish' to begin using it."
elif [ "$SELECTED_SHELL" = "zsh" ]; then
    SHELL_MSG="🚀 Zsh configured with oh-my-zsh and your dotfiles.\nStart a new terminal session or run 'zsh' to begin using it."
fi

gum join --vertical \
    "$(gum style --foreground 212 --border-foreground 212 --border double --align center --width 70 --padding "1 2" "$SUCCESS_MSG")" \
    "$(gum style --foreground 99 --align center --width 70 --padding "1 0" "$SHELL_MSG")"
