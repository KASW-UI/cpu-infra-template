#!/usr/bin/env bash

###############################################################################
# CPU HPC Development Environment Updater
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

################################################################################
# System
################################################################################

info "Updating Ubuntu..."
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

################################################################################
# Git LFS
################################################################################

if command -v git-lfs >/dev/null 2>&1; then
    info "Updating Git LFS..."
    git lfs install
fi

################################################################################
# Python Environment
################################################################################

VENV="/workspace/.venv"
if [[ -d "$VENV" ]]; then
    info "Updating Python packages..."
    source "$VENV/bin/activate"
    pip install --upgrade pip setuptools wheel
    deactivate
fi

################################################################################
# Docker
################################################################################

if command -v docker >/dev/null 2>&1; then
    info "Updating Docker images..."
    docker image prune -f || true
fi

echo
success "Update completed."
echo "Run ./scripts/doctor.sh to verify your environment."
echo
