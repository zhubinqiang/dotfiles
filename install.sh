#!/bin/bash
# --- Basic Information ---
# Description: Automated dotfiles deployment script
# Date: 2026-05-08

# --- Variables ---
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Physical location of the repository
#REAL_REPO_PATH="${HOME}/WS/dotfiles"
REAL_REPO_PATH="${SOURCE_DIR}"
# Logical entry point for the system
DOT_DIR="${HOME}/.dotfiles"
# Current date for backup suffix
DATE_SUFFIX=$(date +%Y%m%d-%H%M%S)

# --- Pre-installation: Ensure the main symlink exists ---
setup_repo_link() {
    echo "--- Checking repository symlink ---"
    if [ ! -L "${DOT_DIR}" ]; then
        echo "Creating symlink: ${DOT_DIR} -> ${REAL_REPO_PATH}"
        ln -s "${REAL_REPO_PATH}" "${DOT_DIR}"
    else
        echo "Symlink ${DOT_DIR} already exists. Skipping."
    fi
}

# --- Core Function: Link configuration files ---
# $1: Source file path relative to ${DOT_DIR}
# $2: Destination path relative to ${HOME}
link_config() {
    local src_file="${DOT_DIR}/${1}"
    local dest_file="${HOME}/${2}"

    # Ensure parent directory exists
    mkdir -p "$(dirname "${dest_file}")"

    # Check if destination exists
    if [ -e "${dest_file}" ] || [ -L "${dest_file}" ]; then
        # If it is a real file (not a symlink), rename it for backup
        if [ -f "${dest_file}" ] && [ ! -L "${dest_file}" ]; then
            local backup_name="${dest_file}_${DATE_SUFFIX}"
            echo "Backing up real file: ${dest_file} -> ${backup_name}"
            mv "${dest_file}" "${backup_name}"
        else
            # If it is already a symlink, just remove it to update
            echo "Removing existing symlink: ${dest_file}"
            rm "${dest_file}"
        fi
    fi

    # Create the new symlink
    echo "Linking: ${dest_file} -> ${src_file}"
    ln -s "${src_file}" "${dest_file}"
}

check_local_config() {
    local local_file="${HOME}/.bashrc_local"
    local example_file="${DOT_DIR}/shell/bashrc_local.example"

    if [ ! -f "${local_file}" ]; then
        echo "--------------------------------------------------------"
        echo "Notice: ~/.bashrc_local does not exist."
        echo "Found template at: ${example_file}"
        echo "You may want to copy it: cp ${example_file} ${local_file}"
        echo "--------------------------------------------------------"
    fi
}

# --- Inside your main install.sh ---
run_apt_setup() {
    if [ -f "/etc/os-release" ]; then
        # Check if OS is Ubuntu
        if grep -q "Ubuntu" /etc/os-release; then
            echo "Ubuntu detected, running APT optimization..."
            bash "${DOT_DIR}/setup/apt.sh"
        fi
    fi
}

check_dev_mode() {
    if [ -f "${HOME}/.vim_dev_mode" ]; then
        echo "Development mode detected. Ensure you have run setup/dev_node.sh"
    else
        echo "Basic mode (Docker/Minimal) initialized."
    fi
}

main() {
    # 1. Initialize the repo link first
    setup_repo_link

    echo "--- Deploying configuration files ---"

    # 2. Shell configurations
    link_config "shell/bashrc"         ".bashrc"
    link_config "shell/zshrc"          ".zshrc"
    link_config "shell/bash_profile"   ".bash_profile"
    link_config "shell/aliases"        ".aliases"

    # 3. Application configurations
    link_config "apps/vim/vimrc"       ".vimrc"
    link_config "apps/git/gitconfig"   ".gitconfig"
    link_config "apps/npm/npmrc"       ".npmrc"
    link_config "ssh/config"           ".ssh/config"
    link_config "apps/nvim/init.lua"   ".config/nvim/init.lua"

    # Note: If you have more lua files, you can link the whole directory:
    # link_config "apps/nvim/lua"        ".config/nvim/lua"

    # 4. check .bashrc_local
    check_local_config

    run_apt_setup

    check_dev_mode

    echo "--- All done! ---"
}

main


exit 0



















# 定义仓库路径
DOT_DIR="$HOME/WS/dotfiles"

# 映射函数：link_to <仓库源文件> <家目录目标名>
link_to() {
    local src="$DOT_DIR/$1"
    local dest="$HOME/$2"
    
    # 自动创建目标文件的父目录 (例如 ~/.config/xxx)
    mkdir -p "$(dirname "$dest")"
    
    echo "Linking $dest -> $src"
    ln -sf "$src" "$dest"
}



if [ "$SOURCE_DIR" != "$HOME/.dotfiles" ]; then
    if [ ! -d "$HOME/.dotfiles" ]; then
        echo "create soft link for dotfiles ..."
        ln -s "$SOURCE_DIR" "$HOME/.dotfiles"
    fi
fi

echo "--- 开始部署 Dotfiles ---"

# Shell 配置
link_to "shell/bashrc"  ".bashrc"
link_to "shell/zshrc"   ".zshrc"
link_to "shell/aliases" ".aliases"

# 应用配置
link_to "apps/vim/vimrc"       ".vimrc"
link_to "apps/git/gitconfig"   ".gitconfig"
link_to "apps/npm/npmrc"       ".npmrc"
link_to "ssh/config"           ".ssh/config"

# 注意：VS Code 在 Mac 和 Linux 的路径不同，需要特殊处理
if [ "$(uname)" == "Darwin" ]; then
    link_to "apps/vscode/settings.json" "Library/Application Support/Code/User/settings.json"
else
    link_to "apps/vscode/settings.json" ".config/Code/User/settings.json"
fi

echo "--- 部署完成！ ---"

