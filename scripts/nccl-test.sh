#!/usr/bin/env bash
set -Eeuo pipefail

GREEN="\033[32m"
BLUE="\033[34m"
RED="\033[31m"
RESET="\033[0m"

info() { echo -e "${BLUE}==>${RESET} $1"; }
pass() { echo -e "${GREEN}✔${RESET} $1"; }
fail() { echo -e "${RED}✘${RESET} $1"; }

NCCL_TESTS_REPO="https://github.com/NVIDIA/nccl-tests.git"
NCCL_TESTS_DIR="/tmp/nccl-tests"

# ── Source NCCL env ───────────────────────────────────────────────────────────
if [[ -f /home/dev/.config/gpu-infra/nccl.env ]]; then
    set -a
    source /home/dev/.config/gpu-infra/nccl.env
    set +a
fi

# ── Load NCCL env vars into this script ──────────────────────────────────────
export NCCL_DEBUG="${NCCL_DEBUG:-INFO}"
export NCCL_IB_DISABLE="${NCCL_IB_DISABLE:-1}"
export NCCL_P2P_DISABLE="${NCCL_P2P_DISABLE:-0}"

# ── GPU check ─────────────────────────────────────────────────────────────────
GPU_COUNT=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | wc -l || echo "0")

if [[ "$GPU_COUNT" -lt 1 ]]; then
    fail "No GPU detected"
    exit 1
fi

echo -e "${BLUE}NCCL Bandwidth Test${RESET}"
echo "  GPUs: ${GPU_COUNT}"
echo "  NCCL_DEBUG: ${NCCL_DEBUG}"
echo "  NCCL_IB_DISABLE: ${NCCL_IB_DISABLE}"
echo ""

if [[ "$GPU_COUNT" -eq 1 ]]; then
    info "Single GPU detected — skipping multi-GPU NCCL tests"
    info "All-reduce on 1 GPU is a no-op, generating test with 2 processes instead..."
fi

# ── Clone / update nccl-tests ─────────────────────────────────────────────────
if [[ -d "$NCCL_TESTS_DIR/.git" ]]; then
    git -C "$NCCL_TESTS_DIR" pull --ff-only 2>/dev/null || true
else
    info "Cloning nccl-tests..."
    git clone --depth 1 "$NCCL_TESTS_REPO" "$NCCL_TESTS_DIR"
fi

# ── Build ─────────────────────────────────────────────────────────────────────
info "Building nccl-tests..."
make -C "$NCCL_TESTS_DIR" -j$(nproc) CUDA_HOME="${CUDA_HOME:-/usr/local/cuda}" MPI=0 2>&1 | tail -5

# ── Run tests ─────────────────────────────────────────────────────────────────
if [[ "$GPU_COUNT" -ge 2 ]]; then
    info "All-Reduce Test ($GPU_COUNT GPUs)..."
    "$NCCL_TESTS_DIR/build/all_reduce_perf" -b 4 -e 128M -f 2 -g "$GPU_COUNT" 2>&1 | tail -10
    echo ""
    info "All-to-All Test ($GPU_COUNT GPUs)..."
    "$NCCL_TESTS_DIR/build/alltoall_perf" -b 4 -e 128M -f 2 -g "$GPU_COUNT" 2>&1 | tail -10
else
    info "Single GPU: running 2-process NCCL test on same device..."
    "$NCCL_TESTS_DIR/build/all_reduce_perf" -b 4 -e 128M -f 2 -g 1 2>&1 | tail -10
fi

echo ""
pass "NCCL test complete"
echo ""
echo "Logs: ${LOG_DIR:-/workspace/logs}/nccl-test.log"
echo "Re-run: make nccl-test"
