#!/usr/bin/env bash

###############################################################################
# Docker Installer
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

if command -v docker >/dev/null 2>&1; then

    success "Docker already installed."

    docker --version

    exit 0

fi

################################################################################
# Remove Old Versions
################################################################################

info "Removing old Docker packages..."

sudo apt remove -y \
docker \
docker-engine \
docker.io \
containerd \
runc || true

################################################################################
# Repository
################################################################################

info "Adding Docker repository..."

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

################################################################################
# Install
################################################################################

info "Installing Docker..."

sudo apt update

sudo apt install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin

################################################################################
# Enable Service
################################################################################

sudo systemctl enable docker

sudo systemctl start docker

################################################################################
# User Group
################################################################################

if ! groups "$USER" | grep -q docker; then

    info "Adding current user to docker group..."

    sudo usermod -aG docker "$USER"

fi

################################################################################
# NVIDIA Container Toolkit
################################################################################

if ! dpkg -l nvidia-container-toolkit >/dev/null 2>&1; then

    info "Installing NVIDIA Container Toolkit..."

    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
        | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
        | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
        | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null

    sudo apt update

    sudo apt install -y nvidia-container-toolkit

    sudo nvidia-ctk runtime configure --runtime=docker

    sudo systemctl restart docker

    success "NVIDIA Container Toolkit installed."

else

    success "NVIDIA Container Toolkit already installed."

fi

################################################################################
# Verify
################################################################################

echo

success "Docker installed."

docker --version

echo

docker compose version

echo

################################################################################
# Test
################################################################################

info "Testing Docker..."

if docker run hello-world >/dev/null 2>&1; then

    success "Docker is working."

else

    warn "Docker test skipped (log out and back in if permission denied)."

fi

if docker run --rm --runtime=nvidia nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi >/dev/null 2>&1; then

    success "NVIDIA GPU passthrough working."

else

    warn "GPU test skipped (log out and back in if you just joined the docker group)."

fi

################################################################################
# Finish
################################################################################

echo

echo "========================================================"

echo "Docker installation completed."

echo

echo "If you just joined the docker group,"

echo "please log out and log back in."

echo

echo "Verify:"

echo

echo "docker run hello-world"

echo

echo "Next (Docker GPU dev container):"

echo

echo "make build"

echo "make run"

echo "make shell"

echo

echo "Next (bare-metal):"

echo

echo "./install/python.sh"

echo

echo "========================================================"