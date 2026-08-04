# shellcheck source=/dev/null
[[ -f ~/.zshrc.common ]] && source ~/.zshrc.common

prepend_path() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  # Remove any existing occurrence before prepending. A plain "skip if already
  # present" guard is not enough: .zshrc.common appends ~/.local/bin to the end
  # of PATH before this file runs, which would leave the nvim shim behind the
  # very directories this function exists to take precedence over.
  path=("$dir" ${path:#"$dir"})
}

# prioritize user-managed bins over system binaries
prepend_path "$HOME/.cargo/bin"
prepend_path "$HOME/opt/nvim/current/bin"
prepend_path "$HOME/.local/bin"

export PATH

# zsh command hash refresh (useful right after setup/symlink updates)
if [[ -o interactive ]]; then
  rehash
fi

# optional pyenv path only
export PYENV_ROOT="$HOME/.pyenv"
prepend_path "$PYENV_ROOT/bin"
export PATH

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

if command -v fzf >/dev/null 2>&1; then
  # fzf 0.48+ emits the integration itself; Ubuntu 24.04 ships 0.44, which
  # still installs it as files under the package docs directory.
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    for _fzf_file in \
      /usr/share/doc/fzf/examples/key-bindings.zsh \
      /usr/share/doc/fzf/examples/completion.zsh \
      /usr/share/fzf/key-bindings.zsh \
      /usr/share/fzf/completion.zsh; do
      # shellcheck source=/dev/null
      [[ -f "$_fzf_file" ]] && source "$_fzf_file"
    done
    unset _fzf_file
  fi

  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

  # fzf runs these commands through sh, so the fd -> fdfind alias above does
  # not apply. $commands only sees real binaries, which is what is needed.
  if (( $+commands[fd] )); then
    _fzf_fd=fd
  elif (( $+commands[fdfind] )); then
    _fzf_fd=fdfind
  fi
  if [[ -n "${_fzf_fd:-}" ]]; then
    export FZF_DEFAULT_COMMAND="$_fzf_fd --type f --hidden --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="$_fzf_fd --type d --hidden --exclude .git"
  fi
  unset _fzf_fd
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
