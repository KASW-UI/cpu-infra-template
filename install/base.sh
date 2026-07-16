#!/usr/bin/env bash

###############################################################################
# CPU HPC Base Development Environment
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

info "Updating apt..."
sudo apt update && sudo apt upgrade -y

PACKAGES=(
    # Compiler Toolchain
    build-essential
    gcc g++
    clang clangd lld
    gdb valgrind strace ltrace

    # Build System
    cmake ninja-build
    make pkg-config

    # Parallel Runtime
    libomp-dev
    openmpi-bin libopenmpi-dev

    # Math Libraries
    libopenblas-dev liblapack-dev libeigen3-dev

    # Profiling Tools
    linux-tools-generic numactl hwloc

    # Benchmark
    libbenchmark-dev stress-ng

    # Development Tools
    git git-lfs
    curl wget unzip zip
    vim nano tmux tree
    htop btop jq
    ripgrep fd-find bat fzf
    zsh

    # SSH & Network
    openssh-client openssh-server
    net-tools

    # System
    software-properties-common
    ca-certificates gnupg lsb-release apt-transport-https

    # Python
    python3 python3-pip python3-venv python3-dev
    libssl-dev libffi-dev libbz2-dev liblzma-dev
    libsqlite3-dev libreadline-dev zlib1g-dev xz-utils
    libncurses-dev pkg-config
)

info "Installing packages..."
sudo apt install -y "${PACKAGES[@]}"

if command -v git-lfs >/dev/null 2>&1; then
    git lfs install
fi

if command -v batcat >/dev/null 2>&1; then
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/batcat ~/.local/bin/bat
fi

if command -v fdfind >/dev/null 2>&1; then
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/fdfind ~/.local/bin/fd
fi

if [[ "$SHELL" != "$(which zsh)" ]]; then
    warn "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

mkdir -p "$HOME/workspace"/{src,build,benchmarks,notes,tmp}

echo
success "Base HPC environment installed."
echo
echo "  GCC / Clang / GDB"
echo "  CMake / Ninja / Make"
echo "  OpenMP / MPI"
echo "  OpenBLAS / LAPACK / Eigen3"
echo "  perf / numactl / hwloc"
echo "  stress-ng / Google Benchmark"
echo "  Python 3 + scientific stack"
echo
