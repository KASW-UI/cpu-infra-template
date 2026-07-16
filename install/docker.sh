#!/usr/bin/env bash

###############################################################################
# Docker Installer
#
# Ubuntu 22.04 / 24.04
###############################################################################

set -Eeuo pipefail

GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[ OK ]${RESET} $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() { echo -e "${RED}[FAIL]${RESET} $1"; }

if command -v docker >/dev/null 2>&1; then
    success "Docker already installed."
    docker --version
    exit 0
fi

info "Removing old Docker packages..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true

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

info "Installing Docker..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

if ! groups "$USER" | grep -q docker; then
    info "Adding current user to docker group..."
    sudo usermod -aG docker "$USER"
fi

echo
success "Docker installed."
docker --version
docker compose version

echo
info "Testing Docker..."
if docker run hello-world >/dev/null 2>&1; then
    success "Docker is working."
else
    warn "Docker test skipped (log out and back in if permission denied)."
fi

echo
echo "========================================================"
echo "Docker installation completed."
echo
echo "Next: make build && make run && make shell"
echo "========================================================"
