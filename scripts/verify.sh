#!/usr/bin/env bash

###############################################################################
# GPU Development Environment Verification
#
# Detects container vs bare-metal and adjusts checks accordingly.
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

PASS=0
FAIL=0

pass() { echo -e "  ${GREEN}✔${RESET} $1"; ((PASS++)); }
fail() { echo -e "  ${RED}✘${RESET} $1"; ((FAIL++)); }
info() { echo -e "\n${BLUE}[INFO]${RESET} $1"; step_title="$1"; }

IS_CONTAINER=false
if [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    IS_CONTAINER=true
fi

################################################################################
# Header
################################################################################

echo
echo "======================================================"
if $IS_CONTAINER; then
    echo " GPU Dev Environment Verification (Container Mode)"
else
    echo " GPU Development Environment Verification"
fi
echo "======================================================"
echo

################################################################################
# NVIDIA Driver
################################################################################

info "Checking NVIDIA Driver..."

if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi >/dev/null
    pass "nvidia-smi"
else
    fail "nvidia-smi"
fi

################################################################################
# CUDA Compiler
################################################################################

info "Checking CUDA..."

if command -v nvcc >/dev/null 2>&1; then
    nvcc --version >/dev/null
    pass "nvcc"
else
    fail "nvcc"
fi

################################################################################
# CUDA Samples (skip in container)
################################################################################

if ! $IS_CONTAINER; then

    DEVICE_QUERY="$HOME/workspace/cuda-samples/bin/x86_64/linux/release/deviceQuery"

    info "Running CUDA Sample..."

    if [[ -x "$DEVICE_QUERY" ]]; then

        if "$DEVICE_QUERY" >/tmp/deviceQuery.log 2>&1; then

            pass "deviceQuery"

        else

            fail "deviceQuery"

            cat /tmp/deviceQuery.log

        fi

    else

        pass "deviceQuery (skipped - not built)"

    fi

fi

################################################################################
# PyTorch
################################################################################

info "Checking PyTorch..."

python3 - <<EOF
import sys
import torch

print("  Torch:", torch.__version__)
print("  CUDA available:", torch.cuda.is_available())

if not torch.cuda.is_available():
    sys.exit(1)

print("  GPU count:", torch.cuda.device_count())
for i in range(torch.cuda.device_count()):
    print(f"  GPU [{i}]:", torch.cuda.get_device_name(i))
EOF

if [[ $? == 0 ]]; then
    pass "PyTorch CUDA"
else
    fail "PyTorch CUDA"
fi

################################################################################
# Triton
################################################################################

info "Checking Triton..."

python3 - <<EOF
import triton
print("  Triton:", triton.__version__)
EOF

if [[ $? == 0 ]]; then
    pass "Triton"
else
    fail "Triton"
fi

################################################################################
# Docker (skip in container)
################################################################################

if ! $IS_CONTAINER; then

    if command -v docker >/dev/null 2>&1; then

        info "Checking Docker..."

        if docker run --rm hello-world >/dev/null 2>&1; then

            pass "Docker"

        else

            fail "Docker"

        fi

    fi

    ################################################################################
    # Docker GPU
    ################################################################################

    if command -v docker >/dev/null 2>&1; then

        info "Checking Docker GPU..."

        if docker run --rm \
            --gpus all \
            nvidia/cuda:12.4.0-base-ubuntu$(lsb_release -sr) \
            nvidia-smi >/dev/null 2>&1
        then

            pass "Docker GPU"

        else

            fail "Docker GPU"

        fi

    fi

fi

################################################################################
# Disk
################################################################################

info "Disk Usage"

df -h /workspace 2>/dev/null || df -h /

################################################################################
# Finish
################################################################################

echo
echo "======================================================"

echo -e "${GREEN}PASS: ${PASS}${RESET}  ${RED}FAIL: ${FAIL}${RESET}"

if [[ $FAIL -eq 0 ]]; then
    pass "Verification completed."
else
    fail "Verification failed with ${FAIL} error(s)."
    exit 1
fi

echo "======================================================"
echo
