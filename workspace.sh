#!/usr/bin/env bash

###############################################################################
# Workspace Setup Script
#
# Ubuntu 22.04 / 24.04
#
# Creates a structured AI / GPU development workspace
###############################################################################

set -Eeuo pipefail

################################################################################
# Colors
################################################################################

GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
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
# Base Path
################################################################################

WORKSPACE="$HOME/workspace"

mkdir -p "$WORKSPACE"

cd "$WORKSPACE"

################################################################################
# Core Directories
################################################################################

info "Creating workspace structure..."

DIRS=(
    "ai-infra"
    "cuda"
    "kernels"
    "distributed"
    "inference"
    "training"
    "compilers"
    "benchmarks"
    "tools"
    "notes"
    "models"
    "datasets"
    "logs"
    "tmp"
    "playground"
)

for d in "${DIRS[@]}"; do
    mkdir -p "$WORKSPACE/$d"
done

################################################################################
# AI Infra Learning Structure
################################################################################

info "Creating learning roadmap structure..."

mkdir -p "$WORKSPACE/roadmap"

cat > "$WORKSPACE/roadmap/README.md" <<'EOF'
# GPU / AI Infra Roadmap

This workspace is organized for systematic learning of GPU + AI systems.

## Order of Study

1. CUDA Samples
2. CUTLASS
3. Triton
4. tinygrad
5. llama.cpp
6. flash-attention
7. vLLM
8. NCCL
9. DeepEP
10. Megatron-LM
11. SGLang

## Rules

- Always start from profiling, not code reading
- Always ask: "what is bottleneck?"
- Always measure performance
EOF

################################################################################
# Project Mapping (Optional Symlinks Ready)
################################################################################

info "Linking known repositories if they exist..."

link_if_exists() {
    local name="$1"
    local target="$WORKSPACE/$name"
    local source="$WORKSPACE/$name"

    if [[ -d "$source" && ! -L "$target" ]]; then
        ln -s "$source" "$target" 2>/dev/null || true
    fi
}

################################################################################
# Placeholder structure for key projects
################################################################################

KEY_PROJECTS=(
    "cuda-samples"
    "cutlass"
    "triton"
    "tinygrad"
    "vllm"
    "sglang"
    "Megatron-LM"
    "llama.cpp"
    "flash-attention"
    "nccl"
    "nccl-tests"
)

for p in "${KEY_PROJECTS[@]}"; do
    mkdir -p "$WORKSPACE/$p"
done

################################################################################
# Development Scratchpad
################################################################################

cat > "$WORKSPACE/playground/README.md" <<'EOF'
# Playground

This is where you:

- test kernels
- run experiments
- break things
- benchmark ideas

Nothing here is permanent.
EOF

################################################################################
# Notes Structure
################################################################################

cat > "$WORKSPACE/notes/README.md" <<'EOF'
# Notes

Organize learning notes:

- CUDA concepts
- Triton experiments
- vLLM architecture
- NCCL communication models
EOF

################################################################################
# Finish
################################################################################

echo
success "Workspace initialized"

echo

echo "Structure created at:"
echo

echo "  $WORKSPACE"

echo

echo "Key folders:"
echo

for d in "${DIRS[@]}"; do
    echo "  - $d"
done

echo

echo "Next step:"
echo

echo "  ./install/tools.sh"
echo