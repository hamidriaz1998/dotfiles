# --- Zinit Init ---
if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  print -P "%F{33}Installing Zinit...%f"
  mkdir -p ~/.zinit && git clone https://github.com/zdharma-continuum/zinit ~/.zinit/bin
fi
source ~/.zinit/bin/zinit.zsh

# --- Plugins ---
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light marlonrichert/zsh-autocomplete
zinit light Aloxaf/fzf-tab
zinit light ael-code/zsh-colored-man-pages
zinit light jeffreytse/zsh-vi-mode

# --- Compinit ---
#autoload -Uz compinit
#compinit -C

# Optional theme (if not using starship)
# zinit ice depth=1; zinit light romkatv/powerlevel10k

# --- Env & Tools ---
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH=$HOME/.local/bin:$PATH
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# --- History ---
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don\'t record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don\'t record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don\'t write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
export HISTSIZE=70000
export HISTFILE=~/.zsh_history
export SAVEHIST=10000

# --- Aliases ---
alias download="wget --mirror --convert-links --adjust-extension --page-requisites --no-parent "
alias fzf="fzf --preview='bat --color=always {}'"
alias flatpak='flatpak --installation=external'
alias ncdu='ncdu --color dark'
alias ls='eza -lh --group-directories-first --icons=auto'
alias postman='setsid postman >/dev/null 2>&1 &'

# --- Tools ---
source <(fzf --zsh)
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
#export STARSHIP_CONFIG="$HOME/.config/omarchy/themes/hakker-green/starship.toml"
eval "$(starship init zsh)"

# --- uwu cli helper ---
uwu() {
  local cmd
  cmd="$(uwu-cli "$@")" || return
  vared -p "" -c cmd
  print -s -- "$cmd"   # add to history
  eval "$cmd"
}



# bun completions
[ -s "/home/hamid/.bun/_bun" ] && source "/home/hamid/.bun/_bun"
