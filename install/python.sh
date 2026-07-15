#!/usr/bin/env bash

###############################################################################
# Python Environment Installer
#
# Ubuntu 22.04 / 24.04
# Python 3.12
# uv
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
# Install uv
################################################################################

if command -v uv >/dev/null 2>&1; then

    success "uv already installed."

else

    info "Installing uv..."

    curl -LsSf https://astral.sh/uv/install.sh | sh

fi

################################################################################
# Load Environment
################################################################################

export PATH="$HOME/.local/bin:$PATH"

################################################################################
# Workspace
################################################################################

WORKSPACE="$HOME/workspace/ai-infra"

mkdir -p "$WORKSPACE"

cd "$WORKSPACE"

################################################################################
# Create Virtual Environment
################################################################################

if [[ ! -d ".venv" ]]; then

    info "Creating virtual environment..."

    uv venv --python 3.12

fi

################################################################################
# Activate
################################################################################

source .venv/bin/activate

################################################################################
# Upgrade
################################################################################

uv pip install --upgrade pip setuptools wheel

################################################################################
# Install Packages
################################################################################

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

################################################################################
# PyTorch
################################################################################

info "Installing PyTorch (CUDA)..."

uv pip install \
torch \
torchvision \
torchaudio \
--index-url https://download.pytorch.org/whl/cu124

################################################################################
# Triton
################################################################################

info "Installing Triton..."

uv pip install triton

################################################################################
# Verify
################################################################################

echo
success "Python Environment"

python --version

echo
success "uv"

uv --version

echo
success "pip"

pip --version

echo

python - <<EOF
import torch
print("Torch:", torch.__version__)
print("CUDA Available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name(0))
EOF

################################################################################
# Activation Hint
################################################################################

if ! grep -q "ai-infra/.venv/bin/activate" ~/.zshrc 2>/dev/null; then

cat <<EOF >> ~/.zshrc

# AI Infrastructure Environment
source \$HOME/workspace/ai-infra/.venv/bin/activate

EOF

fi

################################################################################
# Finish
################################################################################

echo
success "Python environment installed."

echo

echo "Workspace"

echo "  $WORKSPACE"

echo

echo "Activate manually"

echo

echo "source ~/workspace/ai-infra/.venv/bin/activate"

echo

echo "Next"

echo

echo "./install/tools.sh"

echo