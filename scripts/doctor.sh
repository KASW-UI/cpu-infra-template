#!/usr/bin/env bash

###############################################################################
# GPU Development Environment Doctor
###############################################################################

set -Eeuo pipefail

################################################################################
# Colors
################################################################################

GREEN="\033[32m"
RED="\033[31m"
BLUE="\033[34m"
YELLOW="\033[33m"
RESET="\033[0m"

pass() {
    echo -e "${GREEN}✔${RESET} $1"
}

fail() {
    echo -e "${RED}✘${RESET} $1"
}

info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

################################################################################
# Header
################################################################################

echo
echo "======================================================"
echo " GPU Development Environment Doctor"
echo "======================================================"
echo

################################################################################
# OS
################################################################################

if command -v lsb_release >/dev/null 2>&1; then
    pass "Ubuntu $(lsb_release -rs)"
else
    fail "Ubuntu not detected"
fi

################################################################################
# NVIDIA Driver
################################################################################

if command -v nvidia-smi >/dev/null 2>&1; then

    DRIVER=$(nvidia-smi --query-gpu=driver_version \
        --format=csv,noheader | head -1)

    pass "NVIDIA Driver : $DRIVER"

else

    fail "NVIDIA Driver"

    echo "    Run: ./install/driver.sh"

fi

################################################################################
# GPU
################################################################################

if command -v nvidia-smi >/dev/null 2>&1; then

    GPU=$(nvidia-smi \
        --query-gpu=name \
        --format=csv,noheader | head -1)

    pass "GPU : $GPU"

fi

################################################################################
# CUDA
################################################################################

if command -v nvcc >/dev/null 2>&1; then

    VERSION=$(nvcc --version | grep release | sed 's/.*release //' | cut -d',' -f1)

    pass "CUDA Toolkit : $VERSION"

else

    fail "CUDA Toolkit"

    echo "    Run: ./install/cuda.sh"

fi

################################################################################
# Docker
################################################################################

if command -v docker >/dev/null 2>&1; then

    pass "$(docker --version)"

else

    fail "Docker"

fi

################################################################################
# Git
################################################################################

if command -v git >/dev/null 2>&1; then

    pass "$(git --version)"

else

    fail "Git"

fi

################################################################################
# GCC
################################################################################

if command -v gcc >/dev/null 2>&1; then

    pass "$(gcc --version | head -1)"

else

    fail "GCC"

fi

################################################################################
# Clang
################################################################################

if command -v clang >/dev/null 2>&1; then

    pass "$(clang --version | head -1)"

else

    fail "Clang"

fi

################################################################################
# CMake
################################################################################

if command -v cmake >/dev/null 2>&1; then

    pass "$(cmake --version | head -1)"

else

    fail "CMake"

fi

################################################################################
# Ninja
################################################################################

if command -v ninja >/dev/null 2>&1; then

    pass "$(ninja --version)"

else

    fail "Ninja"

fi

################################################################################
# Python
################################################################################

if command -v python3 >/dev/null 2>&1; then

    pass "$(python3 --version)"

else

    fail "Python"

fi

################################################################################
# uv
################################################################################

if command -v uv >/dev/null 2>&1; then

    pass "$(uv --version)"

else

    fail "uv"

fi

################################################################################
# PyTorch
################################################################################

if python3 -c "import torch" >/dev/null 2>&1; then

    TORCH=$(python3 -c "import torch;print(torch.__version__)")

    pass "Torch $TORCH"

    python3 - <<EOF
import torch
print("    CUDA Available :", torch.cuda.is_available())
if torch.cuda.is_available():
    print("    Device         :", torch.cuda.get_device_name(0))
EOF

else

    fail "PyTorch"

fi

################################################################################
# Triton
################################################################################

if python3 -c "import triton" >/dev/null 2>&1; then

    pass "Triton Installed"

else

    fail "Triton"

fi

################################################################################
# Nsight
################################################################################

if command -v ncu >/dev/null 2>&1; then

    pass "Nsight Compute"

else

    fail "Nsight Compute"

fi

if command -v nsys >/dev/null 2>&1; then

    pass "Nsight Systems"

else

    fail "Nsight Systems"

fi

################################################################################
# Workspace
################################################################################

echo

info "Workspace"

for DIR in \
cuda-samples \
cutlass \
tinygrad \
triton \
vllm \
sglang \
Megatron-LM \
llama.cpp \
nccl \
nccl-tests \
DeepEP \
TensorRT-LLM \
flash-attention
do

    if [[ -d "$HOME/workspace/$DIR" ]]; then

        pass "$DIR"

    else

        fail "$DIR"

    fi

done

################################################################################
# Disk
################################################################################

echo

info "Disk"

df -h /

################################################################################
# Memory
################################################################################

echo

info "Memory"

free -h

################################################################################
# Finish
################################################################################

echo
echo "======================================================"
echo " Doctor Finished"
echo "======================================================"
echo