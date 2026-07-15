#!/usr/bin/env bash

###############################################################################
# NVIDIA Driver Installer
#
# Ubuntu 22.04 / 24.04
# RTX Series
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
# Check Ubuntu
################################################################################

if ! command -v ubuntu-drivers >/dev/null 2>&1; then
    error "ubuntu-drivers not found."
    echo
    echo "Run base.sh first."
    exit 1
fi

################################################################################
# Detect NVIDIA GPU
################################################################################

if ! lspci | grep -i nvidia >/dev/null; then
    error "No NVIDIA GPU detected."
    exit 1
fi

GPU=$(lspci | grep -i nvidia | head -1)

info "Detected GPU:"
echo "  $GPU"
echo

################################################################################
# Existing Driver
################################################################################

if command -v nvidia-smi >/dev/null 2>&1; then

    success "NVIDIA Driver already installed."

    nvidia-smi

    echo
    if [[ -t 0 ]]; then
        read -rp "Reinstall driver? [y/N]: " ans

        if [[ ! "$ans" =~ ^[Yy]$ ]]; then
            exit 0
        fi
    else
        warn "Non-interactive mode — skipping reinstall. Remove driver manually first if needed."
        exit 0
    fi

fi

################################################################################
# Update apt
################################################################################

info "Updating package index..."

sudo apt update

################################################################################
# Recommended Driver
################################################################################

info "Recommended driver:"

ubuntu-drivers devices

echo

################################################################################
# Install
################################################################################

info "Installing recommended NVIDIA driver..."

sudo ubuntu-drivers autoinstall

################################################################################
# Verify Package
################################################################################

echo

success "Driver installation completed."

echo

echo "Installed packages:"

dpkg -l | grep nvidia-driver || true

echo

################################################################################
# Finish
################################################################################

warn "A reboot is required."

echo

echo "Run:"

echo

echo "    sudo reboot"

echo

echo "After reboot verify with:"

echo

echo "    nvidia-smi"

echo

echo "Then continue with:"

echo

echo "    ./install/cuda.sh"

echo