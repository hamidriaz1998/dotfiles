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

# --- Homebrew ---
eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# --- Environment Variables ---
set -gx BUN_INSTALL $HOME/.bun
set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
set -gx DOTNET_CLI_TELEMETRY_OPTOUT 1
set -gx DOTNET_ROOT (mise where dotnet@8)
set -gx LIBVIRT_DEFAULT_URI qemu:///system

# --- PATH ---
fish_add_path -a $HOME/.local/bin
fish_add_path -a $BUN_INSTALL/bin
fish_add_path -a $HOME/.dotnet/tools
fish_add_path -a $HOME/go/bin
fish_add_path -a $DOTNET_ROOT

# --- Rust ---
source "$HOME/.cargo/env.fish"

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
alias dotnet "mise x dotnet@8 -- dotnet"
alias pacsearch "pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse"
alias yaysearch "yay -Slq | fzf --preview 'yay -Si {}' --layout=reverse"
alias pacinstall "sudo pacman -S --noconfirm"
alias yayinstall "yay -S --noconfirm"
alias prisma "bunx --bun prisma"

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
