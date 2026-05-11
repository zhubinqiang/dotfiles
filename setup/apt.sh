#!/bin/bash


# --- Universal Ubuntu Mirror Optimizer ---
# Description: Supports Ubuntu 20.04, 22.04 (Legacy format) and 24.04 (DEB822 format)

# Ensure the script is run as root
(( EUID != 0 )) && exec sudo -E -- "$0" "$@"

# --- Variables ---
# Mirrors: mirrors.tuna.tsinghua.edu.cn | mirrors.aliyun.com | mirrors.ustc.edu.cn
MIRROR_URL="mirrors.tuna.tsinghua.edu.cn"
OS_RELEASE="/etc/os-release"

# --- Get Version Info ---
if [ -f "${OS_RELEASE}" ]; then
    # e.g., focal, jammy, noble
    VERSION_CODENAME=$(grep "VERSION_CODENAME" "${OS_RELEASE}" | cut -d'=' -f2)
else
    echo "Error: Cannot detect OS version."
    exit 1
fi

echo "Detected Ubuntu version: ${VERSION_CODENAME}"

# --- Optimization Logic ---

if [ "${VERSION_CODENAME}" == "noble" ]; then
    # --- Ubuntu 24.04 (Noble) - DEB822 Format ---
    TARGET_FILE="/etc/apt/sources.list.d/ubuntu.sources"
    echo "Configuring for 24.04 (DEB822 format) in ${TARGET_FILE}"
    
    if [ -f "${TARGET_FILE}" ]; then
        cp "${TARGET_FILE}" "${TARGET_FILE}.bak"
        sed -i "s|http://archive.ubuntu.com|http://${MIRROR_URL}|g" "${TARGET_FILE}"
        sed -i "s|http://security.ubuntu.com|http://${MIRROR_URL}|g" "${TARGET_FILE}"
    fi

else
    # --- Ubuntu 22.04/20.04/18.04 - Legacy Format ---
    TARGET_FILE="/etc/apt/sources.list"
    echo "Configuring for legacy format in ${TARGET_FILE}"
    
    if [ -f "${TARGET_FILE}" ]; then
        cp "${TARGET_FILE}" "${TARGET_FILE}.bak"
        # Use a more generic regex to replace common official mirror URLs
        sed -i "s|http://.*archive.ubuntu.com|http://${MIRROR_URL}|g" "${TARGET_FILE}"
        sed -i "s|http://.*security.ubuntu.com|http://${MIRROR_URL}|g" "${TARGET_FILE}"
    fi
fi

# --- Common Speed Optimizations ---
echo "Disabling periodic update locks..."
echo 'APT::Periodic::Update-Package-Lists "0";' > /etc/apt/apt.conf.d/10periodic


# 2. 更新并安装必备软件清单
PACKAGES=(
    vim
    git
    ssh
    tmux
    curl
    wget
    tree
    ripgrep
    build-essential
)

apt update && DEBIAN_FRONTEND=noninteractive apt install -y "${PACKAGES[@]}"

echo "APT optimization for ${VERSION_CODENAME} completed."
