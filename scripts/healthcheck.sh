#!/usr/bin/env bash
set -Eeuo pipefail

GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"
BOLD="\033[1m"

PASS=0
FAIL=0

pass() { echo -e "  ${GREEN}✔${RESET} $1"; ((PASS++)); }
fail() { echo -e "  ${RED}✘${RESET} $1"; ((FAIL++)); }
info() { echo -e "\n${BOLD}${BLUE}── $1 ──${RESET}"; }

echo
echo -e "${BOLD}========================================================${RESET}"
echo -e "${BOLD} GPU Infrastructure Health Check${RESET}"
echo -e "${BOLD}========================================================${RESET}"

info "System"
pass "Kernel: $(uname -r)"
pass "OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 | tr -d '"' || echo 'unknown')"

info "NVIDIA Driver"
if nvidia-smi >/dev/null 2>&1; then
    DRIVER_VER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1)
    pass "Driver: ${DRIVER_VER}"
else
    fail "nvidia-smi unavailable"
fi

info "CUDA Toolk"
if command -v nvcc >/dev/null 2>&1; then
    NVCC_VER=$(nvcc --version 2>/dev/null | grep "release" | awk '{print $5}' | tr -d ',')
    pass "nvcc: ${NVCC_VER}"
else
    fail "nvcc not found"
fi

if [[ -d /usr/local/cuda ]]; then
    pass "CUDA_HOME: /usr/local/cuda"
else
    fail "CUDA_HOME missing"
fi

info "GPU Info"
if nvidia-smi >/dev/null 2>&1; then
    GPU_COUNT=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | wc -l)
    pass "GPU count: ${GPU_COUNT}"
    nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | while IFS= read -r name; do
        echo -e "      ${name}"
    done
else
    fail "Cannot query GPU"
fi

info "Python"
if command -v python >/dev/null 2>&1; then
    PY_VER=$(python --version 2>&1)
    pass "${PY_VER}"
else
    fail "python not found"
fi

info "PyTorch"
python - <<'EOF'
import sys, torch
print(f"  Torch: {torch.__version__}")
cuda_ok = torch.cuda.is_available()
print(f"  CUDA available: {cuda_ok}")
if cuda_ok:
    print(f"  GPU count: {torch.cuda.device_count()}")
    for i in range(torch.cuda.device_count()):
        print(f"    [{i}] {torch.cuda.get_device_name(i)}")
sys.exit(0 if cuda_ok else 1)
EOF
if [[ $? -eq 0 ]]; then
    pass "PyTorch CUDA"
else
    fail "PyTorch CUDA"
fi

info "Triton"
python - <<'EOF' 2>&1
import triton
print(f"  Triton: {triton.__version__}")
EOF
if [[ $? -eq 0 ]]; then
    pass "Triton"
else
    fail "Triton"
fi

info "NCCL"
if dpkg -l 2>/dev/null | grep -q libnccl-dev; then
    NCCL_VER=$(dpkg -l 2>/dev/null | grep libnccl-dev | awk '{print $3}')
    pass "libnccl-dev: ${NCCL_VER}"
else
    fail "libnccl-dev not found"
fi

if command -v all_reduce_perf >/dev/null 2>&1; then
    pass "nccl-tests: available"
else
    fail "nccl-tests not installed (run make nccl-test to compile)"
fi

info "Disk"
df -h /workspace 2>/dev/null || df -h /

echo
echo -e "${BOLD}========================================================${RESET}"
echo -e "${GREEN}PASS: ${PASS}${RESET}  ${RED}FAIL: ${FAIL}${RESET}"
if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}✓ All checks passed${RESET}"
else
    echo -e "${RED}✗ ${FAIL} check(s) failed${RESET}"
    exit 1
fi
echo -e "${BOLD}========================================================${RESET}"
