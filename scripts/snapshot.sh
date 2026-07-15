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
DRIVER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1 || echo "unknown")
GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1 || echo "unknown")
GPU_COUNT=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | wc -l || echo "0")
CUDA_V=$(nvcc --version 2>/dev/null | grep "release" | awk '{print $5}' | tr -d ',' || echo "unknown")
PYTHON_V=$(python --version 2>&1 || echo "unknown")
TORCH_V=$(python -c "import torch; print(torch.__version__)" 2>/dev/null || echo "unknown")
TORCH_CUDA=$(python -c "import torch; print(torch.version.cuda)" 2>/dev/null || echo "unknown")
TRITON_V=$(python -c "import triton; print(triton.__version__)" 2>/dev/null || echo "unknown")
COMPUTE_CAP=$(python -c "import torch; print(torch.cuda.get_device_capability(0))" 2>/dev/null | tr -d '()' | sed 's/, /./' || echo "unknown")
NCCL_V=$(dpkg -l 2>/dev/null | grep libnccl-dev | awk '{print $3}' | head -1 || echo "unknown")
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
  "project": "gpu-infra-template",
  "time": "${TIMESTAMP}",
  "hostname": "${HOSTNAME}",
  "git_commit": "${GIT_COMMIT}",
  "image": "${IMAGE_NAME:-gpu-infra-template:cuda12.4-torch2.6}",
  "base_image_digest": "${IMAGE_DIGEST}",
  "os": "${OS_ID} ${OS_VERSION}",
  "kernel": "${KERNEL}",
  "driver": "${DRIVER}",
  "gpu_name": "${GPU_NAME}",
  "gpu_count": ${GPU_COUNT},
  "gpu_arch": "${COMPUTE_CAP}",
  "compute_capability": "${COMPUTE_CAP}",
  "cuda": "${CUDA_V}",
  "python": "${PYTHON_V}",
  "torch": "${TORCH_V}",
  "torch_cuda": "${TORCH_CUDA}",
  "triton": "${TRITON_V}",
  "nccl": "${NCCL_V}",
  "build_user": "${BUILD_USER}"
}
JSONEOF

# ── YAML snapshot ─────────────────────────────────────────────────────────────
cat > "$SNAPSHOT_DIR/deployment.yaml" <<YMLEOF
project: gpu-infra-template
time: "${TIMESTAMP}"
hostname: "${HOSTNAME}"
git_commit: "${GIT_COMMIT}"
image: "${IMAGE_NAME:-gpu-infra-template:cuda12.4-torch2.6}"
base_image_digest: "${IMAGE_DIGEST}"
os: "${OS_ID} ${OS_VERSION}"
kernel: "${KERNEL}"
driver: "${DRIVER}"
gpu_name: "${GPU_NAME}"
gpu_count: ${GPU_COUNT}
gpu_arch: "${COMPUTE_CAP}"
compute_capability: "${COMPUTE_CAP}"
cuda: "${CUDA_V}"
python: "${PYTHON_V}"
torch: "${TORCH_V}"
torch_cuda: "${TORCH_CUDA}"
triton: "${TRITON_V}"
nccl: "${NCCL_V}"
build_user: "${BUILD_USER}"
YMLEOF

echo "Snapshot saved:"
echo "  $SNAPSHOT_DIR/deployment.json"
echo "  $SNAPSHOT_DIR/deployment.yaml"
echo "  $LOG_DIR/apt-installed.txt"
echo "  $LOG_DIR/pip-freeze.txt"
