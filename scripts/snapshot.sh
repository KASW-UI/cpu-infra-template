#!/usr/bin/env bash
set -Eeuo pipefail

SNAPSHOT_DIR="${SNAPSHOT_DIR:-/workspace/snapshots}"
LOG_DIR="${LOG_DIR:-/workspace/logs}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME=$(hostname 2>/dev/null || echo "unknown")
GIT_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

mkdir -p "$SNAPSHOT_DIR" "$LOG_DIR"

# ── Gather system info ────────────────────────────────────────────────────────
OS_ID=$(cat /etc/os-release 2>/dev/null | grep '^ID=' | cut -d= -f2 | tr -d '"' || echo "unknown")
OS_VERSION=$(cat /etc/os-release 2>/dev/null | grep '^VERSION_ID=' | cut -d= -f2 | tr -d '"' || echo "unknown")
KERNEL=$(uname -r)
CPU_MODEL=$(lscpu 2>/dev/null | grep "Model name" | cut -d':' -f2 | xargs || echo "unknown")
CPU_CORES=$(lscpu 2>/dev/null | grep "^CPU(s):" | awk '{print $2}' || echo "0")
CPU_SOCKETS=$(lscpu 2>/dev/null | grep "Socket(s):" | awk '{print $2}' || echo "0")
GCC_V=$(gcc --version 2>/dev/null | head -1 || echo "unknown")
CLANG_V=$(clang --version 2>/dev/null | head -1 || echo "unknown")
CMAKE_V=$(cmake --version 2>/dev/null | head -1 || echo "unknown")
PYTHON_V=$(python --version 2>&1 || echo "unknown")
OMP_NUM_THREADS_V=$(python -c "import os; print(os.environ.get('OMP_NUM_THREADS', 'not set'))" 2>/dev/null || echo "unknown")
OPENBLAS_V=$(dpkg -l 2>/dev/null | grep libopenblas-dev | awk '{print $3}' | head -1 || echo "unknown")
MPI_V=$(mpirun --version 2>/dev/null | head -1 || echo "unknown")
IMAGE_DIGEST="${IMAGE_DIGEST:-unknown}"
BUILD_USER="${BUILD_USER:-$(whoami)}"

# ── apt snapshot ──────────────────────────────────────────────────────────────
apt-mark showmanual 2>/dev/null > "$LOG_DIR/apt-installed.txt" || true
echo "---" >> "$LOG_DIR/apt-installed.txt" 2>/dev/null || true
dpkg-query -W -f='${binary:Package} ${Version}\n' 2>/dev/null >> "$LOG_DIR/apt-installed.txt" || true

# ── pip freeze snapshot ───────────────────────────────────────────────────────
python -m pip freeze 2>/dev/null > "$LOG_DIR/pip-freeze.txt" || true

# ── JSON snapshot ─────────────────────────────────────────────────────────────
cat > "$SNAPSHOT_DIR/deployment.json" <<JSONEOF
{
  "project": "cpu-infra-template",
  "time": "${TIMESTAMP}",
  "hostname": "${HOSTNAME}",
  "git_commit": "${GIT_COMMIT}",
  "image": "${IMAGE_NAME:-cpu-infra-template:cpu-hpc-ubuntu22.04}",
  "base_image_digest": "${IMAGE_DIGEST}",
  "os": "${OS_ID} ${OS_VERSION}",
  "kernel": "${KERNEL}",
  "cpu_model": "${CPU_MODEL}",
  "cpu_cores": ${CPU_CORES},
  "cpu_sockets": ${CPU_SOCKETS},
  "gcc": "${GCC_V}",
  "clang": "${CLANG_V}",
  "cmake": "${CMAKE_V}",
  "python": "${PYTHON_V}",
  "openmp_threads": "${OMP_NUM_THREADS_V}",
  "openblas": "${OPENBLAS_V}",
  "mpi": "${MPI_V}",
  "build_user": "${BUILD_USER}"
}
JSONEOF

# ── YAML snapshot ─────────────────────────────────────────────────────────────
cat > "$SNAPSHOT_DIR/deployment.yaml" <<YMLEOF
project: cpu-infra-template
time: "${TIMESTAMP}"
hostname: "${HOSTNAME}"
git_commit: "${GIT_COMMIT}"
image: "${IMAGE_NAME:-cpu-infra-template:cpu-hpc-ubuntu22.04}"
base_image_digest: "${IMAGE_DIGEST}"
os: "${OS_ID} ${OS_VERSION}"
kernel: "${KERNEL}"
cpu_model: "${CPU_MODEL}"
cpu_cores: ${CPU_CORES}
cpu_sockets: ${CPU_SOCKETS}
gcc: "${GCC_V}"
clang: "${CLANG_V}"
cmake: "${CMAKE_V}"
python: "${PYTHON_V}"
openmp_threads: "${OMP_NUM_THREADS_V}"
openblas: "${OPENBLAS_V}"
mpi: "${MPI_V}"
build_user: "${BUILD_USER}"
YMLEOF

echo "Snapshot saved:"
echo "  $SNAPSHOT_DIR/deployment.json"
echo "  $SNAPSHOT_DIR/deployment.yaml"
echo "  $LOG_DIR/apt-installed.txt"
echo "  $LOG_DIR/pip-freeze.txt"
