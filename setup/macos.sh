#!/usr/bin/env bash

# ====================================================================
# macOS Provisioning Script (Homebrew & Core Packages)
# ====================================================================
# This script installs Homebrew, Neovim, and triggers plugin installation.

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=> Starting macOS provisioning..."

export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

# --------------------------------------------------------------------
# 1. Install Homebrew (Idempotent check)
# --------------------------------------------------------------------
if ! command -v brew &> /dev/null; then
    echo "=> Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Temporarily evaluate brew environment for this script session
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew  shellenv)"
    fi
else
    echo "=> Homebrew is already installed. Updating..."
    brew update
fi

# --------------------------------------------------------------------
# 2. Install Core Packages & Neovim Dependencies
# --------------------------------------------------------------------
echo "=> Installing core packages via Homebrew..."
brew bundle --file="${SOURCE_DIR}/../Brewfile"

# --------------------------------------------------------------------
# 3. Headless Plugin Installation (lazy.nvim & coc.nvim)
# --------------------------------------------------------------------
# WARNING: This step assumes that 'install.sh' has already been executed
# and ~/.config/nvim/init.lua is properly symlinked!

if [ -f "$HOME/.config/nvim/init.lua" ]; then
    echo "=> Bootstrapping Neovim plugins in headless mode..."

    # 1. Trigger lazy.nvim to clone and install all plugins silently
    nvim --headless "+Lazy! sync" +qa

    # 2. (Optional) Trigger coc.nvim extension installation if defined
    # nvim --headless "+CocUpdateSync" +qa

    echo "=> Neovim plugins installed successfully."
else
    echo "=> WARNING: ~/.config/nvim/init.lua not found!"
    echo "=> Please run 'install.sh' first, then open nvim manually to install plugins."
fi

echo "=> macOS provisioning completed!"

