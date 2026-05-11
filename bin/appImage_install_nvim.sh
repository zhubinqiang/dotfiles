#!/bin/bash

# Download the latest stable Neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
rm -rf /opt/nvim
tar -C /opt -xzf nvim-linux-x86_64.tar.gz
# Link to bin
ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

