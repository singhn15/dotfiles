export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# Append this whole block to the end of your existing ~/.zshrc
# (Or replace ~/.zshrc with it if you're starting fresh — you have no
# oh-my-zsh to preserve, so there's nothing to conflict with.)

# --- Homebrew (Apple Silicon path; drop this line on Intel Macs) ---
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- History ---
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY

# --- Completion ---
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# --- Prompt theme ---
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# --- Smarter cd (jumps to frecent directories) ---
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# --- Fuzzy history/file search (Ctrl+R, Ctrl+T) ---
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# --- direnv: auto-load/unload env vars per directory (e.g. AWS_PROFILE per client) ---
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# --- Inline history suggestions (must load before syntax-highlighting) ---
_autosuggest="/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
if [ -f "$_autosuggest" ]; then
  source "$_autosuggest"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
fi

# --- Syntax highlighting (must be sourced LAST, after everything above) ---
_synhl="/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "$_synhl" ] && source "$_synhl"
unset _autosuggest _synhl

# --- A few conveniences ---
alias ll='ls -lahG'
alias tm='tmux new -A -s main'   # create-or-attach to a session called "main"
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'
