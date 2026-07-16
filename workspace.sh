#!/usr/bin/env bash

###############################################################################
# CPU HPC Workspace Setup
#
# Creates a structured HPC development workspace
###############################################################################

set -Eeuo pipefail

GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
RESET="\033[0m"

info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[ OK ]${RESET} $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }

WORKSPACE="$HOME/workspace"
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

info "Creating workspace structure..."

DIRS=(
    "src"
    "build"
    "hpc"
    "parallel"
    "math"
    "profiling"
    "benchmarks"
    "notes"
    "tmp"
    "playground"
)

for d in "${DIRS[@]}"; do
    mkdir -p "$WORKSPACE/$d"
done

info "Creating HPC learning roadmap..."

mkdir -p "$WORKSPACE/roadmap"
cat > "$WORKSPACE/roadmap/README.md" <<'EOF'
# CPU HPC Roadmap

## Order of Study

1. CPU Architecture & Microarchitecture
2. Memory Hierarchy (Cache, NUMA, TLB)
3. Compiler Optimizations (gcc -O2 / -O3 / -march=native)
4. OpenMP — Shared-Memory Parallelism
5. MPI — Distributed-Memory Parallelism
6. SIMD & Vectorization (AVX2, AVX-512)
7. BLAS / LAPACK — Numerical Linear Algebra
8. Perf Analysis — cycles, IPC, cache miss, branch miss
9. Profiling Tools — perf, likwid, hwloc, numactl
10. Geant4 / ASC Applications

## Rules

- Always start from profiling, not code reading
- Always ask: "what is the bottleneck?"
- Always measure performance
- Compare gcc vs clang output
EOF

info "Creating project stubs..."

PROJECTS=(
    "openmp-samples"
    "mpi-samples"
    "gemm"
    "stencil"
    "reduction"
    "profiling-lab"
)

for p in "${PROJECTS[@]}"; do
    mkdir -p "$WORKSPACE/$p"
done

cat > "$WORKSPACE/playground/README.md" <<'EOF'
# Playground

This is where you:
- test OpenMP/MPI programs
- benchmark GEMM implementations
- profile cache behavior
- experiment with compiler flags

Nothing here is permanent.
EOF

cat > "$WORKSPACE/notes/README.md" <<'EOF'
# Notes

Organize learning notes:
- CPU microarchitecture
- Cache coherence protocols
- NUMA optimization
- OpenMP scheduling strategies
- MPI communication patterns
- Perf analysis results
EOF

echo
success "Workspace initialized"
echo "  $WORKSPACE"
echo
for d in "${DIRS[@]}"; do echo "  - $d"; done
echo
echo "Next step: make build && make run && make shell"
echo
