#!/usr/bin/env bash
set -euo pipefail

source /home/dev/.config/gpu-infra/nccl.env 2>/dev/null || true
source /home/dev/.config/gpu-infra/torch.env 2>/dev/null || true
source /workspace/.venv/bin/activate 2>/dev/null || true

exec "$@"
