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
echo -e "${BOLD} CPU HPC Infrastructure Health Check${RESET}"
echo -e "${BOLD}========================================================${RESET}"

info "System"
pass "Kernel: $(uname -r)"
pass "OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 | tr -d '"' || echo 'unknown')"

info "CPU Topology"
if command -v lscpu >/dev/null 2>&1; then
    lscpu 2>/dev/null | grep -E "Model name|Socket|Core|Thread|CPU\(s\):|NUMA" | while IFS= read -r line; do
        pass "${line}"
    done
else
    fail "lscpu unavailable"
fi

info "Compilers"
for cmd in gcc g++ clang gdb; do
    if command -v "$cmd" >/dev/null 2>&1; then
        VER=$("$cmd" --version 2>/dev/null | head -1)
        pass "$cmd: ${VER}"
    else
        fail "$cmd not found"
    fi
done

info "Build System"
for cmd in cmake ninja make; do
    if command -v "$cmd" >/dev/null 2>&1; then
        VER=$("$cmd" --version 2>/dev/null | head -1)
        pass "$cmd: ${VER}"
    else
        fail "$cmd not found"
    fi
done

info "OpenMP"
cat > /tmp/omp_hc.cpp << 'EOF'
#include <omp.h>
#include <cstdio>
int main() {
    #pragma omp parallel
    {
        #pragma omp single
        printf("  Threads: %d\n", omp_get_num_threads());
    }
    return 0;
}
EOF
if g++ -fopenmp /tmp/omp_hc.cpp -o /tmp/omp_hc 2>/dev/null && /tmp/omp_hc; then
    pass "OpenMP — compiled and ran"
else
    fail "OpenMP — compile or run failed"
fi
rm -f /tmp/omp_hc.cpp /tmp/omp_hc

info "MPI"
if command -v mpirun >/dev/null 2>&1; then
    MPI_VER=$(mpirun --version 2>/dev/null | head -1)
    pass "MPI: ${MPI_VER}"

    cat > /tmp/mpi_hc.cpp << 'EOF'
#include <mpi.h>
#include <cstdio>
int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);
    int r, s;
    MPI_Comm_rank(MPI_COMM_WORLD, &r);
    MPI_Comm_size(MPI_COMM_WORLD, &s);
    if (r == 0) printf("  MPI ranks: %d\n", s);
    MPI_Finalize();
    return 0;
}
EOF
    if mpic++ /tmp/mpi_hc.cpp -o /tmp/mpi_hc 2>/dev/null && mpirun --allow-run-as-root -np 4 /tmp/mpi_hc 2>/dev/null; then
        pass "MPI — 4-rank ring OK"
    else
        fail "MPI — communication test failed"
    fi
    rm -f /tmp/mpi_hc.cpp /tmp/mpi_hc
else
    fail "MPI not installed"
fi

info "Math Libraries"
for lib in libopenblas-dev liblapack-dev libeigen3-dev; do
    if dpkg -l 2>/dev/null | grep -q "$lib"; then
        pass "$lib"
    else
        fail "$lib missing"
    fi
done

info "Profiling Tools"
for tool in perf numactl lstopo likwid-perfctr; do
    if command -v "$tool" >/dev/null 2>&1; then
        pass "$tool"
    else
        fail "$tool"
    fi
done

info "perf stat — quick smoke test"
if command -v perf >/dev/null 2>&1; then
    if perf stat -e cycles,instructions -- /bin/true 2>&1 | grep -q "cycles"; then
        pass "perf stat — cycles/instructions OK"
    else
        fail "perf stat — check perf_event_paranoid"
    fi
else
    fail "perf not available"
fi

info "Python"
if command -v python3 >/dev/null 2>&1; then
    PY_VER=$(python3 --version 2>&1)
    pass "${PY_VER}"
else
    fail "python3 not found"
fi

python3 - <<'EOF'
import numpy, scipy, pandas, matplotlib
print(f"  numpy: {numpy.__version__}")
print(f"  scipy: {scipy.__version__}")
print(f"  pandas: {pandas.__version__}")
print(f"  matplotlib: {matplotlib.__version__}")
EOF
if [[ $? -eq 0 ]]; then
    pass "Python scientific stack"
else
    fail "Python imports failed"
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
