#!/usr/bin/env bash

###############################################################################
# CPU HPC Development Environment Doctor
###############################################################################

set -Eeuo pipefail

GREEN="\033[32m"
RED="\033[31m"
BLUE="\033[34m"
RESET="\033[0m"

pass() { echo -e "${GREEN}✔${RESET} $1"; }
fail() { echo -e "${RED}✘${RESET} $1"; }
info() { echo -e "${BLUE}[INFO]${RESET} $1"; }

echo
echo "======================================================"
echo " CPU HPC Development Environment Doctor"
echo "======================================================"
echo

# ── OS ────────────────────────────────────────────────────────────────────────

if command -v lsb_release >/dev/null 2>&1; then
    pass "Ubuntu $(lsb_release -rs)"
else
    fail "Ubuntu not detected"
fi

# ── CPU ───────────────────────────────────────────────────────────────────────

if command -v lscpu >/dev/null 2>&1; then
    MODEL=$(lscpu 2>/dev/null | grep "Model name" | cut -d':' -f2 | xargs)
    CORES=$(lscpu 2>/dev/null | grep "^CPU(s):" | awk '{print $2}')
    pass "CPU : ${CORES} cores — ${MODEL}"
else
    fail "lscpu"
fi

# ── Compilers ─────────────────────────────────────────────────────────────────

for cmd in gcc g++ clang clang++ gdb; do
    if command -v "$cmd" >/dev/null 2>&1; then
        pass "$($cmd --version 2>/dev/null | head -1)"
    else
        fail "$cmd"
    fi
done

# ── Build System ──────────────────────────────────────────────────────────────

if command -v cmake >/dev/null 2>&1; then
    pass "$(cmake --version | head -1)"
else
    fail "cmake"
fi

if command -v ninja >/dev/null 2>&1; then
    pass "ninja $(ninja --version)"
else
    fail "ninja"
fi

# ── OpenMP ────────────────────────────────────────────────────────────────────

if dpkg -l 2>/dev/null | grep -q libomp-dev; then
    OMP_VER=$(dpkg -l 2>/dev/null | grep libomp-dev | awk '{print $3}')
    pass "OpenMP libomp-dev: ${OMP_VER}"
else
    fail "OpenMP"
fi

# ── MPI ───────────────────────────────────────────────────────────────────────

if command -v mpirun >/dev/null 2>&1; then
    pass "$(mpirun --version 2>/dev/null | head -1)"
else
    fail "MPI"
fi

# ── Math Libraries ────────────────────────────────────────────────────────────

for lib in libopenblas-dev liblapack-dev libeigen3-dev; do
    if dpkg -l 2>/dev/null | grep -q "$lib"; then
        VER=$(dpkg -l 2>/dev/null | grep "$lib" | awk '{print $3}')
        pass "${lib}: ${VER}"
    else
        fail "$lib"
    fi
done

# ── Profiling Tools ───────────────────────────────────────────────────────────

for tool in perf numactl lstopo likwid-perfctr; do
    if command -v "$tool" >/dev/null 2>&1; then
        pass "$tool"
    else
        fail "$tool"
    fi
done

# ── Python ────────────────────────────────────────────────────────────────────

if command -v python3 >/dev/null 2>&1; then
    pass "$(python3 --version)"

    python3 - <<'EOF'
import numpy, scipy, pandas, matplotlib
print(f"    numpy:      {numpy.__version__}")
print(f"    scipy:      {scipy.__version__}")
print(f"    pandas:     {pandas.__version__}")
print(f"    matplotlib: {matplotlib.__version__}")
EOF
    if [[ $? -eq 0 ]]; then
        pass "Python scientific stack"
    else
        fail "Python scientific imports"
    fi
else
    fail "Python"
fi

# ── Docker ────────────────────────────────────────────────────────────────────

if command -v docker >/dev/null 2>&1; then
    pass "$(docker --version)"
else
    fail "Docker"
fi

# ── Disk / Memory ─────────────────────────────────────────────────────────────

echo
info "Disk"
df -h /workspace 2>/dev/null || df -h /

echo
info "Memory"
free -h

echo
echo "======================================================"
echo " Doctor Finished"
echo "======================================================"
echo
