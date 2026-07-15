# GPU Infrastructure Template

> AI Infrastructure Development Template
>
> Docker + CUDA 12.4 + PyTorch 2.6 + Triton 3.2 + Multi-GPU NCCL
>
> A100 / H100 / L40S / RTX — one command to deploy.

---

## Architecture

```
Host (Ubuntu 22.04/24.04)
│
├── NVIDIA Driver (>= 550)
│
└── Docker Engine
    │
    └── Container: gpu-infra-dev
        │
        ├── nvidia/cuda:12.4.1-devel-ubuntu22.04
        │
        ├── Python 3.12.10
        │   ├── Torch 2.6.0+cu124
        │   ├── Triton 3.2.0
        │   └── NumPy / SciPy / pytest / ruff / mypy
        │
        ├── NCCL 2.x (multi-GPU)
        │
        └── Build toolchain (gcc, clang, cmake, ninja)
```

Version consistency is guaranteed by `env/versions.env` → `Makefile --build-arg` → `Dockerfile`.

---

# Overview

This repository bootstraps a modern AI Systems / GPU development environment.

The goal is not simply learning CUDA, but building an environment suitable for studying modern AI Infrastructure projects such as

- CUDA Samples
- CUTLASS
- Triton
- tinygrad
- llama.cpp
- FlashAttention
- NCCL
- DeepEP
- vLLM
- SGLang
- Megatron-LM

Two deployment modes are supported: **Docker** (recommended) and **bare-metal** (legacy scripts).

---

## Docker Deployment (Recommended)

Two modes:

**A. Pull pre-built image from GHCR (fast, ~30s)**
```bash
git clone https://github.com/kasw-ui/gpu-infra-template.git
cd gpu-infra-template

make pull       # docker pull from ghcr.io (skip 15-30min build)
make run        # Launch container with all GPUs
make shell      # Enter the container
make verify     # Check nvidia-smi / nvcc / torch / triton / nccl
make nccl-test  # Run all_reduce_perf bandwidth test
make stop       # Stop container
make clean      # Remove image and container
```

**B. Build locally (if you need to customize)**
```bash
git clone https://github.com/kasw-ui/gpu-infra-template.git
cd gpu-infra-template

make build      # Build Docker image with locked versions (~15-30min)
make run        # Launch container with all GPUs
make shell      # Enter the container
make verify     # Check nvidia-smi / nvcc / torch / triton / nccl
make snapshot   # Generate deployment.json + deployment.yaml
make nccl-test  # Run all_reduce_perf bandwidth test
make stop       # Stop container
make clean      # Remove image and container
```

The image locks the entire software stack:

```
nvidia/cuda:12.4.1-devel-ubuntu22.04
  → Python 3.12.10
    → Torch 2.6.0+cu124
      → Triton 3.2.0
```

All versions are declared once in `env/versions.env`. The `Makefile` reads them and passes them to Docker via `--build-arg`.

### Multi-GPU NCCL

Edit `configs/nccl.env` to switch between Ethernet and InfiniBand:

```bash
# Ethernet (default)
NCCL_SOCKET_IFNAME=eth0
NCCL_IB_DISABLE=1

# InfiniBand
NCCL_IB_DISABLE=0
NCCL_NET_GDR_LEVEL=5
NCCL_IB_GID_INDEX=3
```

Then `make nccl-test` to verify GPU-to-GPU bandwidth.

---

# Supported Platform

Recommended

- Ubuntu 22.04 / 24.04 LTS
- NVIDIA RTX 4060 (8GB+)
- CUDA 12.x
- Docker
- Zsh
- VS Code
- Warp Terminal

Other NVIDIA GPUs should also work.

---

# Repository Structure

```
gpu-infra-template/
│
├── docker/
│   ├── Dockerfile              # Multi-stage build, pinned versions
│   └── entrypoint.sh           # Source env → exec "$@"
│
├── env/
│   ├── versions.env            # Single source of truth for all versions
│   ├── requirements.in         # Top-level Python dependencies
│   ├── requirements.lock       # uv pip compile (no hash)
│   └── requirements-hash.lock  # uv pip compile --generate-hashes
│
├── configs/
│   ├── nccl.env                # NCCL tuning (IB / eth)
│   ├── docker.env              # Docker runtime env vars
│   └── torch.env               # PyTorch runtime tuning
│
├── scripts/
│   ├── healthcheck.sh          # Full-stack check (nvidia-smi → triton → nccl)
│   ├── verify.sh               # Container-aware verification
│   ├── snapshot.sh             # Generate deployment.json + deployment.yaml
│   ├── nccl-test.sh            # NCCL bandwidth benchmark
│   ├── update.sh
│   ├── cleanup.sh
│   └── doctor.sh
│
├── deploy/
│   ├── docker/
│   │   └── docker-compose.yml  # Multi-GPU deployment manifest
│   ├── k8s/                    # Reserved for Kubernetes
│   └── helm/                   # Reserved for Helm charts
│
├── runtime/
│   ├── logs/
│   └── snapshots/
│
├── install/                    # Legacy: bare-metal bootstrap scripts
│   ├── base.sh
│   ├── driver.sh
│   ├── cuda.sh
│   ├── docker.sh
│   ├── python.sh
│   ├── shell.sh
│   ├── vscode.sh
│   ├── fonts.sh
│   └── tools.sh
│
├── config/                     # Legacy: dotfiles
│   ├── .zshrc
│   ├── .gitconfig
│   ├── .tmux.conf
│   ├── .p10k.zsh
│   ├── exports.zsh
│   ├── aliases.zsh
│   └── clang-format
│
├── src/                        # Mount point for source code
│
├── Makefile                    # build / run / shell / verify / snapshot / clean
├── manifest.json               # Auto-generated on make build
├── .dockerignore
└── README.md
```

---

# Installation

Clone

```bash
git clone https://github.com/<your-name>/gpu-dev-env.git

cd gpu-dev-env
```

Grant execution permission

```bash
chmod +x bootstrap.sh
chmod +x install/*.sh
chmod +x scripts/*.sh
```

Run bootstrap

```bash
./bootstrap.sh
```

---

# Installation Order

The recommended installation sequence is

```
Base Packages
        │
        ▼
Docker
        │
        ▼
Python (uv)
        │
        ▼
VS Code
        │
        ▼
NVIDIA Driver
        │
        ▼
CUDA Toolkit
        │
        ▼
Development Tools
        │
        ▼
Verify
```

---

# Driver Installation

Install NVIDIA Driver

```bash
./install/driver.sh
```

Reboot

```bash
sudo reboot
```

---

# CUDA Installation

After reboot

```bash
./install/cuda.sh
```

Verify

```bash
nvidia-smi

nvcc --version
```

---

# Docker

Install Docker

```bash
./install/docker.sh
```

Verify

```bash
docker --version
```

---

# Python Environment

Install

```bash
./install/python.sh
```

This script installs

- uv
- Python virtual environment
- PyTorch
- Triton
- NumPy
- SciPy
- IPython
- pytest

Workspace

```
~/workspace/ai-infra
```

---

# Development Tools

Install

```bash
./install/tools.sh
```

Repositories

- CUDA Samples
- CUTLASS
- tinygrad
- Triton
- llama.cpp
- FlashAttention
- NCCL
- vLLM
- Megatron-LM
- SGLang

Directory

```
~/workspace
```

---

# Verification

Run

```bash
./scripts/verify.sh
```

Checks

- NVIDIA Driver
- CUDA
- nvcc
- Docker
- Git
- CMake
- Clang
- Python
- uv
- PyTorch
- Triton
- Nsight

---

# Update

Update packages

```bash
./scripts/update.sh
```

---

# Cleanup

Remove cache

```bash
./scripts/cleanup.sh
```

---

# Workspace Layout

```
~/workspace
│
├── cuda-samples
├── cutlass
├── tinygrad
├── triton
├── llama.cpp
├── flash-attention
├── nccl
├── vllm
├── Megatron-LM
├── sglang
│
├── datasets
├── models
├── notes
├── scripts
└── tmp
```

---

# Learning Roadmap

Recommended order

```
CUDA Samples
        │
        ▼
CUTLASS
        │
        ▼
Triton
        │
        ▼
tinygrad
        │
        ▼
llama.cpp
        │
        ▼
FlashAttention
        │
        ▼
vLLM
        │
        ▼
NCCL
        │
        ▼
DeepEP
        │
        ▼
Megatron-LM
        │
        ▼
SGLang
```

---

# Recommended Editor

Visual Studio Code

Extensions

- C/C++
- CMake Tools
- clangd
- Python
- Docker
- GitLens
- Continue (optional)

Terminal

- Warp

---

# Recommended Hardware

Minimum

- RTX 3060 12GB

Recommended

- RTX 4060
- RTX 4070
- RTX 4080
- RTX 4090

---

# Future Plans

- TensorRT-LLM
- DeepEP
- MSCCL
- ROCm Support
- Multi-GPU Support
- Cluster Bootstrap
- Slurm Integration

---

# License

MIT

---

# Philosophy

Do not learn CUDA by reading documentation only.

Learn CUDA by understanding real systems.

```
CUDA Samples

↓

CUTLASS

↓

Triton

↓

FlashAttention

↓

vLLM

↓

Megatron

↓

SGLang
```

Modern AI Infrastructure is a systems engineering discipline.

Build systems.

Read source code.

Measure performance.

Understand why they are designed this way.