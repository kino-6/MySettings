#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] sudo apt update"
sudo apt update

echo "[2/4] sudo apt upgrade -y"
sudo apt upgrade -y

echo "[3/4] sudo apt autoremove -y"
sudo apt autoremove -y

echo "[4/4] sudo apt autoclean -y"
sudo apt autoclean -y

echo "Maintenance completed safely."
