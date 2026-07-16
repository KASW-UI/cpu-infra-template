#!/usr/bin/env bash
set -euo pipefail

source /home/dev/.config/cpu-infra/openmp.env 2>/dev/null || true
source /home/dev/.config/cpu-infra/mpi.env 2>/dev/null || true
source /home/dev/.config/cpu-infra/hpc.env 2>/dev/null || true
source /workspace/.venv/bin/activate 2>/dev/null || true

exec "$@"
