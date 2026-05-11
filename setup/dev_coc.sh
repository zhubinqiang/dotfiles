#!/bin/bash
# --- SETUP: Development Environment Dependencies ---

set -e

echo ">>> Installing System Language Servers..."

# Update package list
sudo apt update

# 1. C/C++ Support
sudo apt install -y clangd

# 2. Bash Support (shellcheck is the 'brain' for bash-lsp)
sudo apt install -y shellcheck

# 3. Build Tools (Optional but recommended for C++)
sudo apt install -y build-essential cmake

# --- Keep your NVM & Node installation below ---
# [Existing NVM installation code...]

echo ">>> System dependencies installed!"

