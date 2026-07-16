#!/usr/bin/env bash

###############################################################################
# MPI Communication Test — Ring All-Reduce Bandwidth Benchmark
###############################################################################

set -Eeuo pipefail

GREEN="\033[32m"
BLUE="\033[34m"
RED="\033[31m"
RESET="\033[0m"

info() { echo -e "${BLUE}[INFO]${RESET} $1"; }

echo
echo "======================================================"
echo " MPI Communication Test"
echo "======================================================"
echo

info "Compiling MPI ring benchmark..."

cat > /tmp/mpi_ring.cc << 'CPPEOF'
#include <mpi.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <chrono>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank, world_size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    const int N = -1;
    int size;
    if (argc > 1) {
        size = atoi(argv[1]);
    } else {
        size = 1024 * 1024;
    }

    const int warmup_iters = 5;
    const int benchmark_iters = 10;

    char* sendbuf = (char*)malloc(size);
    char* recvbuf = (char*)malloc(size);
    memset(sendbuf, 0xAA, size);
    memset(recvbuf, 0, size);

    int prev = (rank - 1 + world_size) % world_size;
    int next = (rank + 1) % world_size;

    for (int i = 0; i < warmup_iters; i++) {
        MPI_Sendrecv(sendbuf, size, MPI_CHAR, next, 0,
                     recvbuf, size, MPI_CHAR, prev, 0,
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }

    MPI_Barrier(MPI_COMM_WORLD);
    auto start = std::chrono::high_resolution_clock::now();

    for (int i = 0; i < benchmark_iters; i++) {
        MPI_Sendrecv(sendbuf, size, MPI_CHAR, next, 0,
                     recvbuf, size, MPI_CHAR, prev, 0,
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }

    MPI_Barrier(MPI_COMM_WORLD);
    auto end = std::chrono::high_resolution_clock::now();

    double elapsed = std::chrono::duration<double>(end - start).count();
    double avg_time_us = (elapsed / benchmark_iters) * 1e6;
    double bw_mbs = (size / (1024.0 * 1024.0)) / (avg_time_us / 1e6);

    if (rank == 0) {
        printf("\n");
        printf("  Message size:  %d bytes (%.2f MB)\n", size, size / (1024.0 * 1024.0));
        printf("  Ranks:         %d\n", world_size);
        printf("  Iterations:    %d\n", benchmark_iters);
        printf("  Avg latency:   %.2f us\n", avg_time_us);
        printf("  Bandwidth:     %.2f MB/s\n", bw_mbs);
        printf("\n");
    }

    free(sendbuf);
    free(recvbuf);
    MPI_Finalize();
    return 0;
}
CPPEOF

mpic++ -O3 -std=c++17 /tmp/mpi_ring.cc -o /tmp/mpi_ring

info "Running MPI ring benchmark..."

mpirun --allow-run-as-root --oversubscribe -np 4 /tmp/mpi_ring 1048576

echo
echo -e "${GREEN}MPI ring test completed.${RESET}"
echo

rm -f /tmp/mpi_ring.cc /tmp/mpi_ring
