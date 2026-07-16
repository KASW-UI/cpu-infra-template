# CPU HPC Infrastructure Template

> HPC Development Template for ASC / Scientific Computing
>
> Docker + GCC/Clang + OpenMP/MPI + OpenBLAS/LAPACK + perf/numactl/hwloc
>
> One command to deploy a ready-to-use CPU HPC environment.

---

## Architecture

```
Host (Ubuntu 22.04/24.04)
│
└── Docker Engine
    │
    └── Container: cpu-infra-dev
        │
        ├── ubuntu:22.04
        │
        ├── Compiler Toolchain
        │   ├── GCC 11 / G++ 11
        │   ├── Clang 14 / Clang++ 14
        │   └── GDB / Valgrind / strace
        │
        ├── Build System
        │   ├── CMake
        │   └── Ninja
        │
        ├── Parallel Runtime
        │   ├── OpenMP (libomp)
        │   └── MPI (OpenMPI)
        │
        ├── Math Libraries
        │   ├── OpenBLAS
        │   ├── LAPACK
        │   └── Eigen3
        │
        ├── Profiling Tools
        │   ├── perf
        │   ├── numactl
        │   ├── hwloc (lstopo)
        │   └── likwid
        │
        ├── Benchmark Tools
        │   ├── Google Benchmark
        │   └── stress-ng
        │
        └── Python 3.12 (NumPy / SciPy / Pandas / Matplotlib)
```

Version consistency is guaranteed by `env/versions.env` → `Makefile --build-arg` → `Dockerfile`.

---

## Docker Deployment

**Pull pre-built image from GHCR**
```bash
git clone https://github.com/KASW-UI/cpu-infra-template.git
cd cpu-infra-template

make pull       # docker pull from ghcr.io
make run        # Launch container
make shell      # Enter the container
make verify     # Check compilers / OpenMP / MPI / perf / math libs
make healthcheck
make mpi-test   # MPI ring bandwidth test
make hpc-bench  # OpenBLAS GEMM + OpenMP micro-benchmarks
make stop       # Stop container
make clean      # Remove image and container
```

**Build locally**
```bash
make build      # Build Docker image with locked versions
make run        # Launch container
make shell      # Enter the container
make verify     # Verify environment
make mpi-test   # Run MPI communication test
make hpc-bench  # Run HPC micro-benchmarks
make stop       # Stop container
make clean      # Remove image and container
```

---

## Image Layers

| Layer | Packages |
|-------|----------|
| **Compiler Toolchain** | gcc, g++, clang, clang++, lld, gdb, valgrind |
| **Build System** | cmake, ninja-build, make, pkg-config |
| **Parallel Runtime** | libomp-dev, openmpi-bin, libopenmpi-dev |
| **Math Libraries** | libopenblas-dev, liblapack-dev, libeigen3-dev |
| **Profiling** | linux-tools-generic (perf), numactl, hwloc, likwid |
| **Benchmark** | libbenchmark-dev, stress-ng |
| **Python** | numpy, scipy, pandas, matplotlib, ipython, pytest |

---

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make build` | Build Docker image |
| `make pull` | Pull pre-built image from GHCR |
| `make run` | Start container |
| `make shell` | Enter container bash |
| `make verify` | Full environment verification |
| `make healthcheck` | Detailed health check |
| `make snapshot` | Generate deployment snapshot |
| `make mpi-test` | MPI ring bandwidth benchmark |
| `make hpc-bench` | OpenBLAS GEMM + OpenMP benchmarks |
| `make stop` | Stop container |
| `make logs` | Tail container logs |
| `make clean` | Remove container and image |
| `make lock` | Regenerate requirements.lock |

---

## GPU vs CPU Infra Mapping

| GPU Infra | CPU Infra |
|-----------|-----------|
| CUDA Toolkit | GCC / Clang |
| nvcc | g++ / clang++ |
| Nsight Compute/Systems | perf / likwid |
| cuBLAS | OpenBLAS |
| CUDA Stream | OpenMP |
| NCCL | MPI |
| SM / Warp analysis | Core / Cache analysis |
| GPU topology (nvidia-smi topo) | hwloc (lstopo) |

---

## Repository Structure

```
cpu-infra-template/
│
├── docker/
│   ├── Dockerfile
│   └── entrypoint.sh
│
├── env/
│   ├── versions.env
│   ├── requirements.in
│   ├── requirements.lock
│   └── requirements-hash.lock
│
├── configs/
│   ├── openmp.env
│   ├── mpi.env
│   └── hpc.env
│
├── scripts/
│   ├── verify.sh
│   ├── healthcheck.sh
│   ├── snapshot.sh
│   ├── mpi-test.sh
│   ├── hpc-bench.sh
│   ├── update.sh
│   ├── cleanup.sh
│   └── doctor.sh
│
├── deploy/
│   └── docker/
│       └── docker-compose.yml
│
├── install/                    # Bare-metal bootstrap (legacy)
│   ├── base.sh
│   ├── shell.sh
│   ├── docker.sh
│   ├── python.sh
│   ├── vscode.sh
│   └── fonts.sh
│
├── src/                        # Mount point for source code
│
├── Makefile
├── bootstrap.sh
├── workspace.sh
└── README.md
```

---

## Recommended Hardware

- x86-64 CPU with AVX2 (Intel Haswell+ / AMD Excavator+)
- 16GB+ RAM
- 50GB+ disk

---

## Philosophy

Do not learn HPC by reading textbooks only.

Learn HPC by measuring real hardware.

```
Compiler (gcc/clang)
    ↓
Parallel (OpenMP / MPI)
    ↓
Profiling (perf / likwid)
    ↓
Optimize (cache / NUMA / SIMD)
    ↓
Benchmark (GEMM / Stencil / Reduction)
```

HPC is a systems engineering discipline.

Build systems. Read source code. Measure performance. Understand why they are designed this way.
