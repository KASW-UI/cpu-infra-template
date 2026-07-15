#!/usr/bin/env bash

###############################################################################
# Base Development Environment
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
# Update
################################################################################

info "Updating apt..."

sudo apt update
sudo apt upgrade -y

################################################################################
# Base Packages
################################################################################

PACKAGES=(
    build-essential
    cmake
    ninja-build

    gcc
    g++

    clang
    clangd
    lld

    make
    pkg-config

    git
    git-lfs

    curl
    wget

    unzip
    zip

    vim
    nano
    tmux

    tree

    htop
    btop

    jq

    ripgrep
    fd-find

    bat

    fzf

    zsh

    gdb

    valgrind

    strace

    ltrace

    openssh-client
    openssh-server

    net-tools

    software-properties-common

    ca-certificates

    gnupg

    lsb-release

    apt-transport-https

    python3

    python3-pip

    python3-venv

    python3-dev

    libssl-dev

    libffi-dev

    libbz2-dev

    liblzma-dev

    libsqlite3-dev

    libreadline-dev

    zlib1g-dev

    xz-utils

    libncurses-dev

    pkg-config
)

################################################################################
# Install
################################################################################

info "Installing packages..."

sudo apt install -y "${PACKAGES[@]}"

################################################################################
# Git LFS
################################################################################

if command -v git-lfs >/dev/null 2>&1; then
    git lfs install
fi

################################################################################
# bat alias
################################################################################

if command -v batcat >/dev/null 2>&1; then

    mkdir -p ~/.local/bin

    ln -sf /usr/bin/batcat ~/.local/bin/bat

fi

################################################################################
# fd alias
################################################################################

if command -v fdfind >/dev/null 2>&1; then

    mkdir -p ~/.local/bin

    ln -sf /usr/bin/fdfind ~/.local/bin/fd

fi

################################################################################
# Shell
################################################################################

if [[ "$SHELL" != "$(which zsh)" ]]; then

    warn "Changing default shell to zsh..."

    chsh -s "$(which zsh)"

fi

################################################################################
# Workspace
################################################################################

mkdir -p "$HOME/workspace"

mkdir -p "$HOME/workspace/models"

mkdir -p "$HOME/workspace/datasets"

mkdir -p "$HOME/workspace/scripts"

mkdir -p "$HOME/workspace/notes"

mkdir -p "$HOME/workspace/tmp"

################################################################################
# Finish
################################################################################

echo
success "Base environment installed."

echo
echo "Installed tools:"
echo

echo "  GCC"
echo "  Clang"
echo "  CMake"
echo "  Ninja"
echo "  Git"
echo "  Git LFS"
echo "  Python"
echo "  tmux"
echo "  ripgrep"
echo "  fd"
echo "  bat"
echo "  fzf"
echo "  zsh"
echo "  gdb"
echo "  valgrind"

echo
success "Workspace created at ~/workspace"
echo