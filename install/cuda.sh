#!/usr/bin/env bash

###############################################################################
# CUDA Toolkit Installer
#
# Ubuntu 22.04 / 24.04
# Default: CUDA 12.4
#
# Usage:
#
# ./install/cuda.sh
#
# ./install/cuda.sh 12-4
#
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
# Config
################################################################################

CUDA_VERSION="${1:-12-4}"

################################################################################
# Check Driver
################################################################################

if ! command -v nvidia-smi >/dev/null 2>&1; then
    error "NVIDIA Driver not found."
    echo
    echo "Run ./install/driver.sh first."
    exit 1
fi

################################################################################
# Download Keyring
################################################################################

info "Installing NVIDIA CUDA repository..."

UBUNTU_VER=$(lsb_release -sr | tr -d .)
wget "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${UBUNTU_VER}/x86_64/cuda-keyring_1.1-1_all.deb"

sudo dpkg -i cuda-keyring_1.1-1_all.deb

rm cuda-keyring_1.1-1_all.deb

################################################################################
# Install
################################################################################

sudo apt update

info "Installing CUDA Toolkit ${CUDA_VERSION}..."

sudo apt install -y cuda-toolkit-${CUDA_VERSION}

################################################################################
# PATH
################################################################################

CUDA_PATH="/usr/local/cuda-${CUDA_VERSION/-/.}"

if ! grep -q CUDA_HOME ~/.zshrc 2>/dev/null; then

cat <<EOF >> ~/.zshrc

# CUDA
export CUDA_HOME=${CUDA_PATH}
export PATH=\$CUDA_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\$CUDA_HOME/lib64:\$LD_LIBRARY_PATH

EOF

fi

################################################################################
# Verify
################################################################################

echo

success "CUDA installation completed."

echo

echo "Driver"

nvidia-smi

echo

echo "NVCC"

export PATH="${CUDA_PATH}/bin:$PATH"
nvcc --version

echo

################################################################################
# Nsight
################################################################################

if command -v ncu >/dev/null 2>&1; then
    success "Nsight Compute detected."
else
    warn "Nsight Compute not found."
    echo "  Install: sudo apt install -y nsight-compute"
fi

if command -v nsys >/dev/null 2>&1; then
    success "Nsight Systems detected."
else
    warn "Nsight Systems not found."
    echo "  Install: sudo apt install -y nsight-systems"
fi

################################################################################
# Finish
################################################################################

echo

success "CUDA Toolkit installed."

echo

echo "Open a new terminal or run"

echo

echo "source ~/.zshrc"

echo

echo "Next"

echo

echo "    ./install/tools.sh"

echo