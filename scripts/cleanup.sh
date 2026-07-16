#!/usr/bin/env bash

###############################################################################
# CPU HPC Cleanup Script
###############################################################################

set -Eeuo pipefail

GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
RESET="\033[0m"

info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[ OK ]${RESET} $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }

info "Cleaning apt cache..."
sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean

info "Cleaning systemd journal..."
sudo journalctl --vacuum-time=7d >/dev/null 2>&1 || true

if command -v pip >/dev/null 2>&1; then
    info "Cleaning pip cache..."
    pip cache purge || true
fi

info "Removing Python cache..."
find /workspace -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find /workspace -type f -name "*.pyc" -delete 2>/dev/null || true

info "Removing CMake build artifacts..."
find /workspace -type f -name "CMakeCache.txt" -delete 2>/dev/null || true
find /workspace -type d -name "CMakeFiles" -exec rm -rf {} + 2>/dev/null || true

info "Cleaning temporary files..."
rm -rf /tmp/omp_* /tmp/mpi_* /tmp/gemm_bench* 2>/dev/null || true

if command -v docker >/dev/null 2>&1; then
    warn "Docker cleanup..."
    docker system prune -f || true
fi

echo
success "Cleanup completed."
du -sh /workspace 2>/dev/null || true
echo
df -h /
echo
