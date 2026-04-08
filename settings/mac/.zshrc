# shellcheck source=/dev/null
[[ -f ~/.zshrc.common ]] && source ~/.zshrc.common

# Activate pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# venv (interactive only)
if [[ -o interactive && -f ~/py3_11_6/bin/activate ]]; then
  source ~/py3_11_6/bin/activate
fi

# broot
if [[ -f ~/.config/broot/launcher/bash/br ]]; then
  source ~/.config/broot/launcher/bash/br
fi

# nodebrew
export PATH="$HOME/.nodebrew/current/bin:$PATH"

# kiro integration (safe)
if [[ "$TERM_PROGRAM" == "kiro" ]] && command -v kiro >/dev/null 2>&1; then
  . "$(kiro --locate-shell-integration-path zsh)"
fi

# prompt
eval "$(starship init zsh)"
