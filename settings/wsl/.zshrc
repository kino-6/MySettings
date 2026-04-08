# shellcheck source=/dev/null
[[ -f ~/.zshrc.common ]] && source ~/.zshrc.common

# WSL toolbox: no automatic Python venv activation.

# fd command alias (Ubuntu package is fd-find)
if command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

# prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
