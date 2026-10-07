# ~/.config/fish/config.fish
# --------------------------------------
# Fish Shell Config
# --------------------------------------

# --- Greeting ---
set -g fish_greeting

# --- Key Bindings ---
# Vi bindings are set in conf.d/fish_frozen_key_bindings.fish
# Alt+L to accept autosuggestions
bind -M insert \el accept-autosuggestion
# Ctrl+Z to toggle fg/bg
bind \cz 'fg 2>/dev/null; commandline -f repaint'

# --- Environment Variables ---
# Bun
set -gx BUN_INSTALL $HOME/.bun
# Starship
set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
# Dotnet
set -gx DOTNET_CLI_TELEMETRY_OPTOUT 1
set -gx DOTNET_ROOT (mise where dotnet@8)
# Virt manager
set -gx LIBVIRT_DEFAULT_URI qemu:///system
# Android
set -gx ANDROID_HOME $HOME/Android/Sdk
set -gx ANDROID_AVD_HOME $HOME/.config/.android/avd
set -gx PATH $PATH $ANDROID_HOME/cmdline-tools/latest/bin
set -gx PATH $PATH $ANDROID_HOME/platform-tools
set -gx PATH $PATH $ANDROID_HOME/emulator/
set -gx PATH $PATH $ANDROID_HOME/build-tools/34.0.0
# Android Emulator - Enable GPU acceleration
set -gx ANDROID_EMULATOR_USE_HOST_GPU 1
set -gx ANDROID_EMULATOR_WAIT_TIME_BEFORE_KILL 1
# Java
set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk
set -gx PATH $JAVA_HOME/bin $PATH
# Sideshow
set -gx SIDESHOW_URL https://sideshow.sh
# Opencode
set -gx OPENCODE_ENABLE_EXA 1

# --- PATH ---
# mise shims must be in PATH BEFORE mise activate captures __MISE_ORIG_PATH
set -gx PATH $HOME/.local/share/mise/shims $PATH
fish_add_path -a $HOME/.local/bin
fish_add_path -a $BUN_INSTALL/bin
fish_add_path -a $HOME/go/bin
fish_add_path -a $DOTNET_ROOT
fish_add_path -a $HOME/.avm/bin

# # --- Rust ---
# source "$HOME/.cargo/env.fish"

# mise-en-place
/usr/bin/mise activate fish | source

# --- Starship Prompt ---
if type -q starship
    function starship_transient_rprompt_func
        starship module time
    end
    starship init fish | source
    enable_transience
end

# --- Abbreviations (expand inline, better than aliases) ---
abbr -a g git
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gp 'git push'
abbr -a gst 'git status'
abbr -a gd 'git diff'
abbr -a gco 'git checkout'
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'

# --- Aliases ---
alias download "wget --mirror --convert-links --adjust-extension --page-requisites --no-parent "
alias fzf "fzf --preview 'bat --color=always {}'"
alias ncdu "ncdu --color dark"
alias ls "eza -lh --group-directories-first --icons=auto"
alias l ls
alias la "ls -a"
alias pacsearch "pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse"
alias yaysearch "yay -Slq | fzf --preview 'yay -Si {}' --layout=reverse"
alias pacinstall "sudo pacman -S --noconfirm"
alias yayinstall "yay -S --noconfirm"
alias prisma "bunx --bun prisma"
alias open "setsid xdg-open"
alias bottles-cli "flatpak run --command=bottles-cli com.usebottles.bottles"
alias pandoc "docker run --rm -v (pwd):/data -w /data --user (id -u):(id -g) pandoc/core:latest"

# --- uwu cli helper (custom function) ---
function uwu
    set cmd (uwu-cli $argv)
    or return
    read -P "" cmd
    history merge
    eval $cmd
end

# --- mkcd: Create directory and cd into it ---
function mkcd -d "Create directory and cd into it"
    mkdir -p $argv[1] && cd $argv[1]
end
