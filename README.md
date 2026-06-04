# this is my dotfiles

## 🚀 Installation Workflow (Zero-to-Hero)

This dotfiles repository follows a strict Monorepo architecture, combining both system provisioning and configuration management.

To set up a fresh macOS or Linux machine, follow the 3-phase workflow:

### Phase 1: Package Provisioning (OS-Level)
Install the core system dependencies and base software (e.g., Neovim, Tmux, Git).
* **macOS:** `bash setup/macos.sh` (Powered by Homebrew)
* **Ubuntu/Debian:** `bash setup/apt.sh` (Powered by APT)

### Phase 2: Runtime Provisioning (Language-Level)
Install language runtimes required by development tools.
* **Node.js Environment:** `bash setup/dev_node.sh` (Installs NVM and the required Node version for tools like `coc.nvim`).

### Phase 3: Configuration Linking (The Glue)
Deploy the configurations safely. This script creates necessary directories, symlinks your `.dotfiles` to the home directory, and securely patches SSH permissions.
* **Run the installer:** `bash install.sh`


