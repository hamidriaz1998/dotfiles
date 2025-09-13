# ~/.config/fish/config.fish
# --------------------------------------
# Fish Shell Config (Zsh → Fish Migration)
# --------------------------------------

# --- Env & Tools ---
set -U fish_greeting

# Set vi bindings
fish_vi_key_bindings
# use ctrl+f to accept autosuggestions
bind -M insert \cf accept-autosuggestion

eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

fish_add_path -a $HOME/.local/bin $PATH
fish_add_path -a $BUN_INSTALL/bin
set -Ux BUN_INSTALL $HOME/.bun

# --- Starship Prompt ---
if type -q starship
    function starship_transient_rprompt_func
        starship module time
    end
    set -Ux STARSHIP_CONFIG "$HOME/.config/starship.toml"
    starship init fish | source
    enable_transience
end

# --- History ---
# Fish already deduplicates & timestamps history.
# Raise history size limit to mirror Zsh config
set -U fish_history_limit 70000

# --- Aliases ---
alias download "wget --mirror --convert-links --adjust-extension --page-requisites --no-parent "
alias fzf "fzf --preview 'bat --color=always {}'"
alias flatpak "flatpak --installation=external"
alias ncdu "ncdu --color dark"
alias ls "eza -lh --group-directories-first --icons=auto"
alias l ls
alias la "ls -a"

# --- uwu cli helper (custom function) ---
function uwu
    set cmd (uwu-cli $argv)
    or return
    read -P "" cmd
    history merge
    eval $cmd
end

# --- Bun completions ---
#if test -s "$BUN_INSTALL/_bun"
#    source "$BUN_INSTALL/_bun"
#end
