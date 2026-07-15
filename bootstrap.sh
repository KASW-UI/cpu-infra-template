#!/usr/bin/env bash

###############################################################################
# GPU Development Environment Bootstrap
#
# Ubuntu 22.04 / 24.04
# RTX 4060
# AI Infrastructure Development
###############################################################################

set -Eeuo pipefail

################################################################################
# Colors
################################################################################

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

################################################################################
# Logging
################################################################################

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
# Root Check
################################################################################

if [[ "$EUID" -eq 0 ]]; then
    error "Do not run this script as root."
    exit 1
fi

################################################################################
# Ubuntu Check
################################################################################

if ! command -v lsb_release >/dev/null 2>&1; then
    error "Ubuntu is required."
    exit 1
fi

DISTRO=$(lsb_release -is)

if [[ "$DISTRO" != "Ubuntu" ]]; then
    error "Only Ubuntu is officially supported."
    exit 1
fi

VERSION=$(lsb_release -rs)

info "Detected Ubuntu ${VERSION}"

################################################################################
# Banner
################################################################################

echo
echo "========================================================"
echo " GPU Development Environment"
echo " Ubuntu ${VERSION}"
echo "========================================================"
echo

################################################################################
# Make scripts executable
################################################################################

chmod +x install/*.sh
chmod +x scripts/*.sh

################################################################################
# Install Sequence
################################################################################

info "Installing base packages..."
./install/base.sh

echo

info "Configuring shell environment..."
./install/shell.sh

echo

info "Installing Docker..."
./install/docker.sh

echo

info "Installing Python environment..."
./install/python.sh

echo

info "Installing VS Code..."
./install/vscode.sh

echo

info "Installing fonts..."
./install/fonts.sh

echo

success "Bootstrap completed."

echo
echo "========================================================"
echo "Next Steps"
echo "========================================================"
echo
echo "1. Install NVIDIA Driver"
echo
echo "   ./install/driver.sh"
echo
echo "2. Reboot"
echo
echo "   sudo reboot"
echo
echo "3. Install CUDA Toolkit"
echo
echo "   ./install/cuda.sh"
echo
echo "4. Clone GPU Projects"
echo
echo "   ./install/tools.sh"
echo
echo "5. Verify Environment"
echo
echo "   ./scripts/verify.sh"
echo
echo "Happy hacking!"
echo