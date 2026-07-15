#!/usr/bin/env bash

###############################################################################
# Visual Studio Code Installer
#
# Ubuntu 22.04 / 24.04
###############################################################################

set -Eeuo pipefail

################################################################################
# Colors
################################################################################

GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

success() {
    echo -e "${GREEN}[ OK ]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

error() {
    echo -e "${RED}[FAIL]${RESET} $1"
}

################################################################################
# Already Installed
################################################################################

if command -v code >/dev/null 2>&1; then

    success "VS Code already installed."

    code --version | head -1

    exit 0

fi

################################################################################
# Repository
################################################################################

info "Adding Microsoft repository..."

wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
| gpg --dearmor \
| sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] \
https://packages.microsoft.com/repos/code stable main" \
| sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

################################################################################
# Install
################################################################################

sudo apt update

info "Installing VS Code..."

sudo apt install -y code

################################################################################
# Extensions
################################################################################

#   Do not run `code --install-extension` as root
info "Installing recommended extensions..."

EXTENSIONS=(
    ms-vscode.cpptools-extension-pack
    ms-vscode.cmake-tools
    llvm-vs-code-extensions.vscode-clangd
    ms-python.python
    ms-azuretools.vscode-docker
    eamodio.gitlens
    vadimcn.vscode-lldb
    ms-toolsai.jupyter
    nvidia.nsight-vscode-edition
)

for ext in "${EXTENSIONS[@]}"; do

    if code --install-extension "$ext" >/dev/null 2>&1; then
        success "$ext"
    else
        warn "Skipped $ext (run manually after opening VS Code)"
    fi

done

################################################################################
# Verify
################################################################################

echo
success "VS Code installed."

echo

code --version | head -1

echo

echo "Launch"
echo
echo "    code"
echo

################################################################################
# Finish
################################################################################

echo "========================================================"
echo "VS Code installation completed."
echo "========================================================"
echo
