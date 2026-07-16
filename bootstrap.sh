#!/usr/bin/env bash

###############################################################################
# CPU HPC Development Environment Bootstrap
#
# Ubuntu 22.04 / 24.04
###############################################################################

set -Eeuo pipefail

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[ OK ]${RESET} $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() { echo -e "${RED}[FAIL]${RESET} $1"; }

if [[ "$EUID" -eq 0 ]]; then
    error "Do not run this script as root."
    exit 1
fi

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

echo
echo "========================================================"
echo " CPU HPC Development Environment"
echo " Ubuntu ${VERSION}"
echo "========================================================"
echo

chmod +x install/*.sh
chmod +x scripts/*.sh

info "Installing base packages (compilers, MPI, OpenMP, math libs, profiling)..."
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
echo "  Docker workflow (recommended):"
echo
echo "    make build  # Build CPU HPC dev image"
echo "    make run    # Launch container"
echo "    make shell  # Enter the container"
echo "    make verify # Verify environment"
echo
echo "  Or verify bare-metal:"
echo
echo "    ./scripts/verify.sh"
echo
echo "Happy hacking!"
echo
