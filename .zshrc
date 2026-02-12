# diff -> colordiff
if command -v colordiff >/dev/null 2>&1; then
  alias diff='colordiff'
  alias diffg='diff -u'
  alias diffy='diff -y --left-column'
fi

# Activate pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# venv (interactive only)
if [[ -o interactive && -f ~/py3_11_6/bin/activate ]]; then
  source ~/py3_11_6/bin/activate
fi

# pipx
export PATH="$PATH:$HOME/.local/bin"

# broot
source ~/.config/broot/launcher/bash/br

# nodebrew
export PATH="$HOME/.nodebrew/current/bin:$PATH"

# kiro integration (safe)
if [[ "$TERM_PROGRAM" == "kiro" ]] && command -v kiro >/dev/null 2>&1; then
  . "$(kiro --locate-shell-integration-path zsh)"
fi

# zsh settings
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt INC_APPEND_HISTORY
setopt COMPLETE_IN_WORD
setopt AUTO_MENU
setopt CORRECT

# enable completion (faster)
autoload -Uz compinit
compinit -d ~/.zcompdump -C

# prompt (choose ONE)
# autoload -U promptinit; promptinit
# prompt pure
eval "$(starship init zsh)"
zstyle ':completion:*' menu select
