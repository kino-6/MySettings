# shellcheck source=/dev/null
[[ -f ~/.zshrc.common ]] && source ~/.zshrc.common

# user local bin (uv, pipx)
export PATH="$HOME/.local/bin:$PATH"

# optional pyenv path only
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# initialize LS_COLORS when dircolors is available
if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
fi

# color / compatibility aliases
alias grep='grep --color=auto'

# fd command alias (Ubuntu package is fd-find)
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd='fdfind'
fi

if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  alias bat='batcat'
fi

if command -v colordiff >/dev/null 2>&1; then
  alias diff='colordiff'
fi

# practical lightweight aliases
if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -al --git'
  alias la='eza -a'
  alias lt='eza --tree --level=2'
  alias l='eza'
else
  alias ls='ls --color=auto'
  alias ll='ls -alF'
  alias la='ls -A'
  alias l='ls -CF'
fi
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'

# safer file ops for interactive work
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# auto activate toolbox venv for disposable scripts
if [[ -o interactive && -f "$HOME/.venv-tools/bin/activate" ]]; then
  # shellcheck source=/dev/null
  source "$HOME/.venv-tools/bin/activate"
fi

# lightweight helper functions
mkcd() {
  [[ $# -eq 1 ]] || {
    echo "Usage: mkcd <dir>"
    return 1
  }
  mkdir -p "$1" && cd "$1" || return
}

cdf() {
  [[ $# -eq 1 ]] || {
    echo "Usage: cdf <file-path>"
    return 1
  }
  local target="$1"
  local dir
  dir="$(dirname "$target")"
  [[ -d "$dir" ]] && cd "$dir" || {
    echo "No such directory: $dir"
    return 1
  }
}

ff() {
  local query="${1:-}"
  if command -v fd >/dev/null 2>&1; then
    fd "$query"
  elif command -v fdfind >/dev/null 2>&1; then
    fdfind "$query"
  else
    echo "fd/fdfind not found"
    return 127
  fi
}

rgg() {
  rg -n --hidden --glob '!.git' "$@"
}

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
