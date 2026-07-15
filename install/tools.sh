#!/usr/bin/env bash

###############################################################################
# AI Infrastructure Projects
#
# Ubuntu 22.04 / 24.04
#
# Clone commonly used GPU / AI infrastructure repositories.
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
# Workspace
################################################################################

WORKSPACE="$HOME/workspace"

mkdir -p "$WORKSPACE"

cd "$WORKSPACE"

################################################################################
# Clone Function
################################################################################

clone_repo() {

    local NAME="$1"
    localRL="$2"

    if [[ -d "$NAME/.git" ]]; then

        warn "$NAME already exists."

    else

        info "Cloning $NAME..."

        git clone --recursive "$URL" "$NAME"

        success "$NAME cloned."

    fi

}

################################################################################
# CUDA
################################################################################

clone_repo \
cuda-samples \
https://github.com/NVIDIA/cuda-samples.git

clone_repo \
cutlass \
https://github.com/NVIDIA/cutlass.git

clone_repo \
nccl \
https://github.com/NVIDIA/nccl.git

clone_repo \
nccl-tests \
https://github.com/NVIDIA/nccl-tests.git

################################################################################
# AI Infrastructure
################################################################################

clone_repo \
tinygrad \
https://github.com/tinygrad/tinygrad.git

clone_repo \
triton \
https://github.com/triton-lang/triton.git

clone_repo \
vllm \
https://github.com/vllm-project/vllm.git

clone_repo \
sglang \
https://github.com/sgl-project/sglang.git

clone_repo \
Megatron-LM \
https://github.com/NVIDIA/Megatron-LM.git

clone_repo \
DeepEP \
https://github.com/deepseek-ai/DeepEP.git

################################################################################
# Inference
################################################################################

clone_repo \
llama.cpp \
https://github.com/ggml-org/llama.cpp.git

clone_repo \
TensorRT-LLM \
https://github.com/NVIDIA/TensorRT-LLM.git

################################################################################
# Performance
################################################################################

clone_repo \
flash-attention \
https://github.com/Dao-AILab/flash-attention.git

################################################################################
# Utilities
################################################################################

mkdir -p models
mkdir -p datasets
mkdir -p notes
mkdir -p playground
mkdir -p scripts
mkdir -p benchmarks
mkdir -p tmp

################################################################################
# Finish
################################################################################

echo
success "Repositories downloaded."

echo

echo "Workspace"

echo "  $WORKSPACE"

echo

echo "Installed"

echo "  cuda-samples"
echo "  cutlass"
echo "  nccl"
echo "  nccl-tests"
echo "  tinygrad"
echo "  triton"
echo "  vllm"
echo "  sglang"
echo "  Megatron-LM"
echo "  DeepEP"
echo "  llama.cpp"
echo "  TensorRT-LLM"
echo "  flash-attention"

echo

echo "Next"

echo

echo "Run"

echo "    ./scripts/verify.sh"

echo

echo "Then begin with"

echo "    ~/workspace/cuda-samples"

echo