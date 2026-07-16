#!/usr/bin/env bash

###############################################################################
# Python Environment Installer — CPU HPC
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

if command -v uv >/dev/null 2>&1; then
    success "uv already installed."
else
    info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

export PATH="$HOME/.local/bin:$PATH"

WORKSPACE="$HOME/workspace/cpu-infra"
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

if [[ ! -d ".venv" ]]; then
    info "Creating virtual environment..."
    uv venv --python 3.12
fi

source .venv/bin/activate
uv pip install --upgrade pip setuptools wheel

info "Installing Python packages..."
uv pip install \
    numpy \
    scipy \
    pandas \
    matplotlib \
    ipython \
    jupyterlab \
    pytest \
    black \
    ruff \
    mypy \
    cmake \
    ninja

echo
success "Python Environment"
python --version
uv --version
pip --version

echo
python - <<EOF
import numpy as np; print("numpy:", np.__version__)
import scipy; print("scipy:", scipy.__version__)
import pandas; print("pandas:", pandas.__version__)
EOF

if ! grep -q "cpu-infra/.venv/bin/activate" ~/.zshrc 2>/dev/null; then
cat <<'EOF' >> ~/.zshrc

# CPU HPC Environment
source $HOME/workspace/cpu-infra/.venv/bin/activate
EOF
fi

echo
success "Python environment installed."
echo "  $WORKSPACE"
echo
echo "Activate: source ~/workspace/cpu-infra/.venv/bin/activate"
echo
