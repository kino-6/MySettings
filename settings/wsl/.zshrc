# shellcheck source=/dev/null
[[ -f ~/.zshrc.common ]] && source ~/.zshrc.common

# user local bin (uv, pipx)
export PATH="$HOME/.local/bin:$PATH"

# optional pyenv path only
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# fd command alias (Ubuntu package is fd-find)
if command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

if command -v colordiff >/dev/null 2>&1; then
  alias diff='colordiff'
fi

# auto activate toolbox venv for disposable scripts
if [[ -o interactive && -f "$HOME/.venv-tools/bin/activate" ]]; then
  # shellcheck source=/dev/null
  source "$HOME/.venv-tools/bin/activate"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
