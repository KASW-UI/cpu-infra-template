#!/usr/bin/env bash

###############################################################################
# CPU HPC Development Environment Verification
#
# Detects container vs bare-metal and adjusts checks accordingly.
###############################################################################

set -Eeuo pipefail

GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

PASS=0
FAIL=0

pass() { echo -e "  ${GREEN}✔${RESET} $1"; ((PASS++)); }
fail() { echo -e "  ${RED}✘${RESET} $1"; ((FAIL++)); }
info() { echo -e "\n${BLUE}[INFO]${RESET} $1"; }

IS_CONTAINER=false
if [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    IS_CONTAINER=true
fi

echo
echo "======================================================"
if $IS_CONTAINER; then
    echo " CPU HPC Environment Verification (Container Mode)"
else
    echo " CPU HPC Development Environment Verification"
fi
echo "======================================================"
echo

################################################################################
# CPU Info
################################################################################

info "CPU Information"

if command -v lscpu >/dev/null 2>&1; then
    MODEL=$(lscpu 2>/dev/null | grep "Model name" | cut -d':' -f2 | xargs)
    CORES=$(lscpu 2>/dev/null | grep "^CPU(s):" | awk '{print $2}')
    SOCKETS=$(lscpu 2>/dev/null | grep "Socket(s):" | awk '{print $2}')
    pass "CPU: ${CORES} cores × ${SOCKETS} socket(s) — ${MODEL}"
else
    fail "lscpu unavailable"
fi

################################################################################
# Compilers
################################################################################

info "Checking Compilers"

if command -v gcc >/dev/null 2>&1; then
    GCC_VER=$(gcc --version 2>/dev/null | head -1)
    pass "gcc: ${GCC_VER}"
else
    fail "gcc"
fi

if command -v g++ >/dev/null 2>&1; then
    GXX_VER=$(g++ --version 2>/dev/null | head -1)
    pass "g++: ${GXX_VER}"
else
    fail "g++"
fi

if command -v clang >/dev/null 2>&1; then
    CLANG_VER=$(clang --version 2>/dev/null | head -1)
    pass "clang: ${CLANG_VER}"
else
    fail "clang"
fi

if command -v clang++ >/dev/null 2>&1; then
    pass "clang++"
else
    fail "clang++"
fi

if command -v gdb >/dev/null 2>&1; then
    pass "gdb"
else
    fail "gdb"
fi

################################################################################
# Build System
################################################################################

info "Checking Build System"

if command -v cmake >/dev/null 2>&1; then
    CMAKE_VER=$(cmake --version 2>/dev/null | head -1)
    pass "cmake: ${CMAKE_VER}"
else
    fail "cmake"
fi

if command -v ninja >/dev/null 2>&1; then
    NINJA_VER=$(ninja --version 2>/dev/null)
    pass "ninja: ${NINJA_VER}"
else
    fail "ninja"
fi

if command -v make >/dev/null 2>&1; then
    pass "make"
else
    fail "make"
fi

################################################################################
# OpenMP
################################################################################

info "Checking OpenMP"

cat > /tmp/omp_check.cpp << 'EOF'
#include <omp.h>
#include <cstdio>
int main() {
    #pragma omp parallel
    {
        #pragma omp single
        printf("  OpenMP threads: %d\n", omp_get_num_threads());
    }
    return 0;
}
EOF

if g++ -fopenmp /tmp/omp_check.cpp -o /tmp/omp_check 2>/dev/null && /tmp/omp_check; then
    pass "OpenMP"
else
    fail "OpenMP"
fi
rm -f /tmp/omp_check.cpp /tmp/omp_check

################################################################################
# MPI
################################################################################

info "Checking MPI"

if command -v mpirun >/dev/null 2>&1; then
    MPI_VER=$(mpirun --version 2>/dev/null | head -1)
    pass "mpirun: ${MPI_VER}"

    cat > /tmp/mpi_check.cpp << 'EOF'
#include <mpi.h>
#include <cstdio>
int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    if (rank == 0) printf("  MPI processes: %d\n", size);
    MPI_Finalize();
    return 0;
}
EOF

    if mpic++ /tmp/mpi_check.cpp -o /tmp/mpi_check 2>/dev/null && mpirun --allow-run-as-root -np 2 /tmp/mpi_check 2>/dev/null; then
        pass "MPI communication"
    else
        fail "MPI communication"
    fi
    rm -f /tmp/mpi_check.cpp /tmp/mpi_check
else
    fail "mpirun"
fi

################################################################################
# Math Libraries
################################################################################

info "Checking Math Libraries"

if dpkg -l 2>/dev/null | grep -q libopenblas-dev; then
    pass "OpenBLAS"
else
    fail "OpenBLAS"
fi

if dpkg -l 2>/dev/null | grep -q liblapack-dev; then
    pass "LAPACK"
else
    fail "LAPACK"
fi

if dpkg -l 2>/dev/null | grep -q libeigen3-dev; then
    pass "Eigen3"
else
    fail "Eigen3"
fi

################################################################################
# Profiling Tools
################################################################################

info "Checking Profiling Tools"

if command -v perf >/dev/null 2>&1; then
    PERF_VER=$(perf --version 2>/dev/null | head -1)
    pass "perf: ${PERF_VER}"
else
    fail "perf"
fi

if command -v numactl >/dev/null 2>&1; then
    pass "numactl"
else
    fail "numactl"
fi

if command -v lstopo >/dev/null 2>&1; then
    pass "hwloc (lstopo)"
else
    fail "hwloc (lstopo)"
fi

if command -v likwid-perfctr >/dev/null 2>&1; then
    pass "likwid"
else
    fail "likwid"
fi

################################################################################
# Python
################################################################################

info "Checking Python"

if command -v python3 >/dev/null 2>&1; then
    PY_VER=$(python3 --version 2>&1)
    pass "${PY_VER}"
else
    fail "python3"
fi

python3 - <<EOF
import numpy as np; print(f"  numpy: {np.__version__}")
import scipy;  print(f"  scipy: {scipy.__version__}")
EOF

if [[ $? -eq 0 ]]; then
    pass "numpy / scipy"
else
    fail "numpy / scipy"
fi

################################################################################
# Benchmark Tools
################################################################################

info "Checking Benchmark Tools"

if command -v stress-ng >/dev/null 2>&1; then
    pass "stress-ng"
else
    fail "stress-ng"
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
