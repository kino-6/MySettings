#!/bin/bash
set -Eeuo pipefail

# =========================================
# macOS Maintenance All-in-One (Refined)
# =========================================
#
# Usage:
#   bash update.sh
#   DRY_RUN=1 bash update.sh
#   ENABLE_DOCKER_PRUNE=1 bash update.sh
#   ENABLE_LS_REBUILD=1 bash update.sh
#   ENABLE_SPOTLIGHT_REINDEX=1 bash update.sh
#   ENABLE_BREW_ANALYTICS_OFF=1 bash update.sh
#   ENABLE_PERIODIC_MAINTENANCE=1 bash update.sh
#   ENABLE_XCODE_CLEANUP=1 bash update.sh
#   ENABLE_OLLAMA_CLEANUP=1 bash update.sh
#   ENABLE_UI_RESTART=1 bash update.sh
#
# Optional env vars:
#   DRY_RUN=1                     # Print commands without executing
#   ENABLE_DOCKER_PRUNE=1         # Prune Docker images/containers/volumes
#   ENABLE_LS_REBUILD=1           # Rebuild LaunchServices DB
#   ENABLE_SPOTLIGHT_REINDEX=1    # Reindex Spotlight
#   ENABLE_BREW_ANALYTICS_OFF=1   # Disable Homebrew analytics
#   ENABLE_PERIODIC_MAINTENANCE=1 # Run macOS periodic daily/weekly/monthly
#   ENABLE_XCODE_CLEANUP=1        # Remove Xcode DerivedData
#   ENABLE_OLLAMA_CLEANUP=1       # Run Ollama prune if available
#   ENABLE_UI_RESTART=1           # Restart Finder and Dock
#
# Notes:
# - This script intentionally updates the currently active python3 environment
#   (for example, your usual py3_11_6 environment), not macOS System Python.
# - Docker cleanup and Finder/Dock restart are optional to keep daily use comfy.

# -----------------------------
# Globals
# -----------------------------
DRY_RUN="${DRY_RUN:-0}"
SUDO_KEEPALIVE_PID=""
NEEDS_RESTART=0

# -----------------------------
# Logging helpers
# -----------------------------
log_section() {
  printf "\n==== %s ====\n" "$1"
}

log_info() {
  printf "[INFO] %s\n" "$1"
}

log_warn() {
  printf "[WARN] %s\n" "$1"
}

log_error() {
  printf "[ERROR] %s\n" "$1" >&2
}

# -----------------------------
# Command helpers
# -----------------------------
have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf "[DRY] "
    printf "%q " "$@"
    printf "\n"
  else
    "$@"
  fi
}

cleanup() {
  local exit_code=$?

  if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
    kill "${SUDO_KEEPALIVE_PID}" >/dev/null 2>&1 || true
  fi

  if [[ $exit_code -ne 0 ]]; then
    log_error "Script failed with exit code ${exit_code}"
  fi

  exit "$exit_code"
}

on_err() {
  log_error "Failed at line $1"
}

trap cleanup EXIT
trap 'on_err $LINENO' ERR

# -----------------------------
# Sudo session / keepalive
# -----------------------------
start_sudo_session() {
  if have_cmd sudo; then
    log_section "Validating sudo session"

    if [[ "$DRY_RUN" == "1" ]]; then
      log_info "DRY_RUN=1: skipping sudo validation"
      return 0
    fi

    # Authenticate once up front
    sudo -v

    # Refresh sudo timestamp in background
    (
      while true; do
        sudo -n -v >/dev/null 2>&1 || exit
        sleep 30
        kill -0 "$$" >/dev/null 2>&1 || exit
      done
    ) &
    SUDO_KEEPALIVE_PID=$!
  fi
}

# -----------------------------
# 1) macOS & Xcode CLT updates
# -----------------------------
update_macos() {
  log_section "Updating macOS software"

  if have_cmd softwareupdate; then
    run sudo softwareupdate --install --all || true

    if softwareupdate -l 2>/dev/null | grep -qi "restart"; then
      NEEDS_RESTART=1
    fi
  else
    log_warn "softwareupdate not found. Skipping macOS update."
  fi
}

# -----------------------------
# 2) Homebrew
# -----------------------------
update_homebrew() {
  if ! have_cmd brew; then
    log_warn "Homebrew not found. Skipping brew steps."
    return 0
  fi

  log_section "Updating Homebrew"
  if [[ "${ENABLE_BREW_ANALYTICS_OFF:-0}" == "1" ]]; then
    run brew analytics off || true
  fi
  run brew update --quiet

  log_section "Upgrading Homebrew packages"
  run brew upgrade --greedy || true

  log_section "Cleaning Homebrew caches"
  run brew cleanup -s --prune=all || true
  run brew autoremove || true

  log_section "Checking Homebrew health"
  if ! brew doctor; then
    log_warn "brew doctor reported issues"
  fi
}

# -----------------------------
# 3) Mac App Store apps
# -----------------------------
update_mas_apps() {
  if have_cmd mas; then
    log_section "Updating Mac App Store apps (mas)"
    run mas upgrade || true
  fi
}

# -----------------------------
# 4) Python ecosystem
# -----------------------------
update_python() {
  log_section "Updating Python ecosystem"

  if have_cmd python3; then
    run python3 -m pip install --upgrade pip setuptools wheel || true

    if python3 -m pip cache dir >/dev/null 2>&1; then
      run python3 -m pip cache purge || true
    fi
  else
    log_warn "python3 not found. Skipping Python updates."
  fi

  if have_cmd pipx; then
    log_section "Updating pipx packages"
    run pipx upgrade-all || true
  fi

  if have_cmd uv; then
    log_section "Updating uv tools"
    run uv tool upgrade --all || true
  fi
}

# -----------------------------
# 5) Node.js & npm
# -----------------------------
update_node() {
  if have_cmd npm; then
    log_section "Updating global npm packages"
    run npm update -g --location=global || true

    log_section "Verifying npm cache"
    run npm cache verify || true
  fi
}

# -----------------------------
# 6) Rust
# -----------------------------
update_rust() {
  if have_cmd rustup; then
    log_section "Updating Rust toolchain"
    run rustup update || true
  fi
}

# -----------------------------
# 7) Docker (optional)
# -----------------------------
docker_cleanup() {
  if [[ "${ENABLE_DOCKER_PRUNE:-0}" == "1" ]] && have_cmd docker; then
    log_section "Docker system prune (with volumes) - optional"
    run docker system prune -af --volumes || true
  fi
}

# -----------------------------
# 8) Rebuild LaunchServices (optional)
# -----------------------------
rebuild_launchservices() {
  if [[ "${ENABLE_LS_REBUILD:-0}" == "1" ]]; then
    log_section "Rebuilding LaunchServices database (optional)"
    local lsregister
    lsregister="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

    if [[ -x "$lsregister" ]]; then
      run "$lsregister" -kill -r -domain local -domain system -domain user || true
    else
      log_warn "lsregister not found. Skipping."
    fi
  fi
}

# -----------------------------
# 9) Spotlight reindex (optional)
# -----------------------------
reindex_spotlight() {
  if [[ "${ENABLE_SPOTLIGHT_REINDEX:-0}" == "1" ]] && have_cmd mdutil; then
    log_section "Reindexing Spotlight (optional, may take time)"
    run sudo mdutil -E / || true
  fi
}

# -----------------------------
# 10) macOS periodic maintenance (optional)
# -----------------------------
run_periodic_maintenance() {
  if [[ "${ENABLE_PERIODIC_MAINTENANCE:-0}" == "1" ]]; then
    log_section "Running macOS periodic maintenance (optional)"
    run sudo periodic daily weekly monthly || true
  fi
}

# -----------------------------
# 11) Xcode cleanup (optional)
# -----------------------------
cleanup_xcode() {
  if [[ "${ENABLE_XCODE_CLEANUP:-0}" == "1" ]]; then
    log_section "Cleaning Xcode DerivedData (optional)"
    local derived_data_dir
    derived_data_dir="${HOME}/Library/Developer/Xcode/DerivedData"

    if [[ -d "$derived_data_dir" ]]; then
      run rm -rf "$derived_data_dir"/* || true
    else
      log_warn "Xcode DerivedData directory not found. Skipping."
    fi
  fi
}

# -----------------------------
# 12) Ollama cleanup (optional)
# -----------------------------
cleanup_ollama() {
  if [[ "${ENABLE_OLLAMA_CLEANUP:-0}" == "1" ]] && have_cmd ollama; then
    log_section "Cleaning Ollama unused data (optional)"
    run ollama prune || true
  fi
}

# -----------------------------
# 13) UI restart (optional)
# -----------------------------
restart_shell_ui() {
  if [[ "${ENABLE_UI_RESTART:-0}" == "1" ]]; then
    log_section "Restarting Finder and Dock"
    if have_cmd killall; then
      run killall Finder || true
      run killall Dock || true
    fi
  fi
}

# -----------------------------
# 14) Summary
# -----------------------------
print_summary() {
  log_section "System and packages are up-to-date!"

  if [[ "$NEEDS_RESTART" == "1" ]]; then
    log_warn "System restart recommended after updates."
  else
    log_info "No restart requirement detected from softwareupdate output."
  fi

  log_info "Python maintenance targeted the currently active python3 environment."
  log_info "Tip: Run with DRY_RUN=1 first when testing changes."
}

# -----------------------------
# Main
# -----------------------------
main() {
  start_sudo_session
  update_macos
  update_homebrew
  update_mas_apps
  update_python
  update_node
  update_rust
  docker_cleanup
  rebuild_launchservices
  reindex_spotlight
  run_periodic_maintenance
  cleanup_xcode
  cleanup_ollama
  restart_shell_ui
  print_summary
}

main "$@"
