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

# Function to install eza (modern ls replacement)
install_eza() {
    if ! command -v eza &>/dev/null; then
        gum spin --spinner dot --title "Installing eza (modern ls replacement)..." -- sh -c '
            if [ -f /etc/debian_version ]; then
                sudo apt update && sudo apt install -y eza
            elif [ -f /etc/fedora-release ]; then
                # Fedora
                sudo dnf install -y eza
            elif [ -f /etc/arch-release ]; then
                # Arch Linux
                sudo pacman -Sy --noconfirm eza
            else
                # Fallback: install via cargo if available
                if command -v cargo &>/dev/null; then
                    cargo install eza
                else
                    echo "⚠ Unable to install eza automatically. Please install manually."
                fi
            fi
        '
        echo "✔ eza installed."
    else
        echo "✔ eza found."
    fi
}

# Function to install Starship prompt
install_starship() {
    if ! command -v starship &>/dev/null; then
        gum spin --spinner dot --title "Installing Starship prompt..." -- \
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
        echo "✔ Starship installed."
    else
        echo "✔ Starship found."
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

# Function to check if running Hyprland
is_hyprland() {
    [[ "$XDG_CURRENT_DESKTOP" == *"Hyprland"* ]] || [[ "$HYPRLAND_INSTANCE_SIGNATURE" != "" ]] || pgrep -x hyprland >/dev/null
}

# Function to check if device has a touchpad
has_touchpad() {
    # Check for touchpad devices in /proc/bus/input/devices
    grep -i touchpad /proc/bus/input/devices >/dev/null 2>&1 ||
        # Check for trackpad devices
        grep -i trackpad /proc/bus/input/devices >/dev/null 2>&1 ||
        # Check xinput if available
        (command -v xinput >/dev/null && xinput list | grep -i touchpad >/dev/null 2>&1) ||
        # Check libinput if available
        (command -v libinput >/dev/null && libinput list-devices | grep -i touchpad >/dev/null 2>&1)
}

# Function to install and setup Touchegg
setup_touchegg() {
    if ! command -v touchegg &>/dev/null; then
        echo "⚙ Installing Touchegg..."

        if [ -f /etc/debian_version ]; then
            sudo apt update && sudo apt install -y touchegg
        elif [ -f /etc/fedora-release ]; then
            sudo dnf install -y touchegg
        elif [ -f /etc/arch-release ]; then
            sudo pacman -Sy --noconfirm touchegg
        else
            echo "⚠ Unsupported distro for Touchegg auto-install. Please install manually."
            return 1
        fi

        echo "✔ Touchegg installed."
    else
        echo "✔ Touchegg found."
    fi

    # Enable and start touchegg service
    if systemctl --user is-enabled touchegg.service >/dev/null 2>&1; then
        echo "✔ Touchegg service already enabled."
    else
        echo "⚙ Enabling Touchegg service..."
        systemctl --user enable touchegg.service
        echo "✔ Touchegg service enabled."
    fi

    if systemctl --user is-active touchegg.service >/dev/null 2>&1; then
        echo "✔ Touchegg service already running."
    else
        echo "⚙ Starting Touchegg service..."
        systemctl --user start touchegg.service
        echo "✔ Touchegg service started."
    fi
}

echo "==> Checking and installing required tools..."

# Required tools (including Gum for beautiful prompts)
check_and_install stow stow
check_and_install wget wget
check_and_install curl curl

# Install Gum first so we can use it for prompts
install_gum

# Install eza and Starship prompt
install_eza
install_starship

# Ask user for shell preference using beautiful Gum prompts
choose_shell

# Install selected shell
check_and_install "$SELECTED_SHELL" "$SHELL_PKG"

# Only install dconf if GNOME desktop environment is detected
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" || "$DESKTOP_SESSION" == "gnome" ]]; then
    check_and_install dconf dconf
fi

# Install Touchegg if device has a touchpad
if has_touchpad; then
    gum style --foreground 99 "Touchpad detected - setting up Touchegg for gestures..."
    setup_touchegg
else
    gum style --foreground 240 "No touchpad detected. Skipping Touchegg setup."
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

    # Skip hypr config if not running Hyprland
    if [ "$pkg" = "hypr" ] && ! is_hyprland; then
        gum style --foreground 240 "Skipping hypr config (not running Hyprland)..."
        continue
    fi

    # Skip touchegg config if no touchpad detected
    if [ "$pkg" = "touchegg" ] && ! has_touchpad; then
        gum style --foreground 240 "Skipping touchegg config (no touchpad detected)..."
        continue
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

# Show Starship configuration info
if [ -f "$HOME/.config/starship.toml" ]; then
    gum style \
        --foreground 135 --border-foreground 135 --border rounded \
        --align center --width 60 --margin "1 0" --padding "1 2" \
        "🌟 Starship Configuration" \
        "Using custom config: ~/.config/starship.toml" \
        "Theme: Catppuccin Mocha"
else
    gum style \
        --foreground 135 --border-foreground 135 --border rounded \
        --align center --width 60 --margin "1 0" --padding "1 2" \
        "🌟 Starship Configuration" \
        "Using default Starship configuration"
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

# Show Hyprland configuration info if running Hyprland
if is_hyprland && [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
    gum style \
        --foreground 99 --border-foreground 99 --border rounded \
        --align center --width 60 --margin "1 0" --padding "1 2" \
        "🪟 Hyprland Configuration" \
        "Config stowed: ~/.config/hypr/" \
        "Restart Hyprland to apply changes"
fi

# Show Touchegg configuration info if touchpad detected and config exists
if has_touchpad && [ -f "$HOME/.config/touchegg/touchegg.conf" ]; then
    gum style \
        --foreground 135 --border-foreground 135 --border rounded \
        --align center --width 60 --margin "1 0" --padding "1 2" \
        "👆 Touchegg Configuration" \
        "Gesture config: ~/.config/touchegg/touchegg.conf" \
        "Service: $(systemctl --user is-active touchegg.service)"
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
SUCCESS_MSG="All done! ✅ Your dotfiles are ready."
if [ "$SELECTED_SHELL" = "fish" ]; then
    SHELL_MSG="🐟 Fish shell configured with Fisher and your dotfiles."
elif [ "$SELECTED_SHELL" = "zsh" ]; then
    SHELL_MSG="🚀 Zsh configured with oh-my-zsh and your dotfiles."
fi

STARSHIP_MSG="🌟 Starship prompt with Catppuccin Mocha theme"

# Build additional status messages
ADDITIONAL_MSGS=()
if is_hyprland && [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
    ADDITIONAL_MSGS+=("$(gum style --foreground 99 --align center --width 70 --padding "1 0" "🪟 Hyprland configuration applied")")
fi

if has_touchpad && [ -f "$HOME/.config/touchegg/touchegg.conf" ]; then
    ADDITIONAL_MSGS+=("$(gum style --foreground 135 --align center --width 70 --padding "1 0" "👆 Touchegg gestures configured")")
fi

NEXT_STEPS="💡 Start a new terminal session to see your beautiful setup!"

# Build the final message array
FINAL_MSGS=(
    "$(gum style --foreground 212 --border-foreground 212 --border double --align center --width 70 --padding "1 2" "$SUCCESS_MSG")"
    "$(gum style --foreground 99 --align center --width 70 --padding "1 0" "$SHELL_MSG")"
    "$(gum style --foreground 135 --align center --width 70 --padding "1 0" "$STARSHIP_MSG")"
)

# Add additional messages if any
for msg in "${ADDITIONAL_MSGS[@]}"; do
    FINAL_MSGS+=("$msg")
done

FINAL_MSGS+=("$(gum style --foreground 46 --bold --align center --width 70 --padding "1 0" "$NEXT_STEPS")")

# Join all messages
gum join --vertical "${FINAL_MSGS[@]}"
