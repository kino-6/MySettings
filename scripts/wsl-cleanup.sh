#!/usr/bin/env bash
set -euo pipefail

echo "Starting stronger cleanup (more aggressive than maintenance)."

echo "[1/5] apt autoremove"
sudo apt autoremove -y || true

echo "[2/5] apt clean"
sudo apt clean || true

echo "[3/5] pip cache purge (if available)"
if command -v pip >/dev/null 2>&1; then
  pip cache purge || true
elif command -v pip3 >/dev/null 2>&1; then
  pip3 cache purge || true
else
  echo "pip not found, skipped"
fi

echo "[4/5] uv cache clean (if available)"
if command -v uv >/dev/null 2>&1; then
  uv cache clean || true
else
  echo "uv not found, skipped"
fi

echo "[5/5] docker system prune -f (if docker exists)"
if command -v docker >/dev/null 2>&1; then
  docker system prune -f || true
else
  echo "docker not found, skipped"
fi

echo "Cleanup completed."
