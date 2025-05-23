#!/bin/bash

set -e

# Function to check for required commands
require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "❌ Error: '$1' is not installed."
        echo "Please install with brew/macports on macos or your distributions package manager."
        echo "Exiting..."
        exit 1
    }
}

# Function to compare Neovim version
check_nvim_version() {
    local ver
    ver=$(nvim --version | head -n 1 | sed -E 's/.*v([0-9]+\.[0-9]+).*/\1/')
    local major="${ver%%.*}"
    local minor="${ver#*.}"
    if [ "$major" -lt 0 ] || { [ "$major" -eq 0 ] && [ "$minor" -lt 11 ]; }; then
        echo "❌ Error: Neovim >= 0.11.0 is required (found $ver)."
        echo "Please update with brew on macOS or your Linux package manager."
        exit 1
    fi
}


echo "🔍 Checking requirements..."
require_cmd git
require_cmd gcc
require_cmd nvim
check_nvim_version

# Backup old config
CONFIG_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim.bak"

if [ -d "$CONFIG_DIR" ]; then
    echo "📦 Backing up existing Neovim config to $BACKUP_DIR"
    rm -rf "$BACKUP_DIR"
    mv "$CONFIG_DIR" "$BACKUP_DIR"
fi

echo "📁 Creating new Neovim config directory..."
mkdir -p "$CONFIG_DIR"

echo "⬇️ Cloning ZaeNvim config..."
git clone https://github.com/Zaetrix/ZaeNvim.git "$CONFIG_DIR"

echo "🧹 Cleaning up unnecessary files..."
rm -rf "$CONFIG_DIR/.git" "$CONFIG_DIR/README.md" "$CONFIG_DIR/LICENSE"

echo "✅ ZaeNvim installed successfully!"
echo "Please run NeoVim (nvim) once to finish plugin installation."
