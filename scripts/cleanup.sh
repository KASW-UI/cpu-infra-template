#!/usr/bin/env bash

###############################################################################
# Cleanup Script
#
# Safe cleanup for GPU Development Environment
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

################################################################################
# Apt Cache
################################################################################

info "Cleaning apt cache..."

sudo apt autoremove -y
sudo apt autoclean -y
sudo apt clean

################################################################################
# Journal Logs
################################################################################

info "Cleaning systemd journal..."

sudo journalctl --vacuum-time=7d >/dev/null 2>&1 || true

################################################################################
# Pip Cache
################################################################################

if command -v pip >/dev/null 2>&1; then
    info "Cleaning pip cache..."
    pip cache purge || true
fi

################################################################################
# uv Cache
################################################################################

if command -v uv >/dev/null 2>&1; then
    info "Cleaning uv cache..."
    uv cache clean || true
fi

################################################################################
# Python Cache
################################################################################

info "Removing Python cache..."

find "$HOME/workspace" \
-type d \
-name "__pycache__" \
-exec rm -rf {} + 2>/dev/null || true

find "$HOME/workspace" \
-type f \
-name "*.pyc" \
-delete 2>/dev/null || true

################################################################################
# CMake Cache
################################################################################

info "Removing CMake cache..."

find "$HOME/workspace" \
-type f \
-name "CMakeCache.txt" \
-delete 2>/dev/null || true

find "$HOME/workspace" \
-type d \
-name "CMakeFiles" \
-exec rm -rf {} + 2>/dev/null || true

################################################################################
# Temporary Files
################################################################################

info "Cleaning temporary files..."

rm -rf "$HOME/workspace/tmp/"* 2>/dev/null || true

################################################################################
# Trash
################################################################################

if [[ -d "$HOME/.local/share/Trash/files" ]]; then

    info "Emptying trash..."

    rm -rf "$HOME/.local/share/Trash/files/"* 2>/dev/null || true

fi

################################################################################
# Docker
################################################################################

if command -v docker >/dev/null 2>&1; then

    warn "Docker cleanup..."

    docker system prune -f || true

fi

################################################################################
# Finish
################################################################################

echo
success "Cleanup completed."

echo

echo "Workspace"

du -sh "$HOME/workspace" 2>/dev/null || true

echo

echo "Disk Usage"

df -h /

echo