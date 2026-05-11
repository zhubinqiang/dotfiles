#!/bin/bash
# ========================================================================== #
# SETUP SCRIPT: Node.js Environment for Development
# This script installs NVM and Node v24 to support coc.nvim (LSP)
# ========================================================================== #

set -e  # Exit on error

echo ">>> Starting Node.js environment setup..."

# 1. Install NVM if not present
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    # Load NVM immediately for the rest of this script
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    echo "NVM is already installed."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# 2. Install Node v24 (Crucial for fixing 'crypto' errors in coc.nvim)
echo "Installing Node v24.15.0..."
nvm install 24.15.0
nvm use 24.15.0
nvm alias default 24.15.0

# 3. Create the 'Dev Mode' flag file for .vimrc
# This tells Vim to enable Coc and heavy LSP features
touch "$HOME/.vim_dev_mode"

echo ">>> Node.js setup complete! Please restart your terminal."


# nvm install --lts
# nvm install 22
# nvm alias default 20
