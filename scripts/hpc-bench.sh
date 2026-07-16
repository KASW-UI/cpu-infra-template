#!/usr/bin/env bash

###############################################################################
# HPC Micro-Benchmark — OpenBLAS GEMM + OpenMP parallel loop
###############################################################################

set -Eeuo pipefail

GREEN="\033[32m"
BLUE="\033[34m"
RED="\033[31m"
RESET="\033[0m"

info() { echo -e "${BLUE}[INFO]${RESET} $1"; }

echo
echo "======================================================"
echo " HPC Micro-Benchmarks"
echo "======================================================"
echo

################################################################################
# OpenBLAS GEMM
################################################################################

info "OpenBLAS SGEMM benchmark"

cat > /tmp/gemm_bench.cpp << 'CPPEOF'
#include <cblas.h>
#include <cstdio>
#include <cstdlib>
#include <chrono>
#include <vector>

int main() {
    const int N = 2048;
    const int warmup = 3;
    const int iters = 10;

    std::vector<float> A(N * N, 1.0f), B(N * N, 2.0f), C(N * N, 0.0f);

    for (int i = 0; i < warmup; i++)
        cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans,
                    N, N, N, 1.0f, A.data(), N, B.data(), N, 0.0f, C.data(), N);

    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < iters; i++)
        cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans,
                    N, N, N, 1.0f, A.data(), N, B.data(), N, 0.0f, C.data(), N);
    auto end = std::chrono::high_resolution_clock::now();

    double t = std::chrono::duration<double>(end - start).count() / iters;
    double flops = 2.0 * N * N * N / t;
    printf("  Matrix:    %d × %d\n", N, N);
    printf("  Avg time:  %.3f ms\n", t * 1000);
    printf("  GFLOPS:    %.2f\n", flops / 1e9);
    return 0;
}
CPPEOF

g++ -O3 -march=native -std=c++17 /tmp/gemm_bench.cpp -o /tmp/gemm_bench -lopenblas
/tmp/gemm_bench
rm -f /tmp/gemm_bench.cpp /tmp/gemm_bench

echo

################################################################################
# OpenMP Parallel Loop
################################################################################

info "OpenMP parallel reduction benchmark"

cat > /tmp/omp_bench.cpp << 'CPPEOF'
#include <omp.h>
#include <cstdio>
#include <cstdlib>
#include <chrono>
#include <cmath>

int main() {
    const long N = 500'000'000;
    const int warmup = 2;
    const int iters = 5;

    auto run = [&]() -> double {
        double sum = 0.0;
        #pragma omp parallel for reduction(+:sum)
        for (long i = 0; i < N; i++)
            sum += sin(i * 1e-6);
        return sum;
    };

    for (int i = 0; i < warmup; i++) run();

    auto start = std::chrono::high_resolution_clock::now();
    double result = 0;
    for (int i = 0; i < iters; i++) result += run();
    auto end = std::chrono::high_resolution_clock::now();

    double t = std::chrono::duration<double>(end - start).count() / iters;
    int threads = omp_get_max_threads();
    printf("  Threads:   %d\n", threads);
    printf("  Iterations: %ld\n", N);
    printf("  Avg time:  %.3f ms (result: %.2f to prevent optimize-away)\n", t * 1000, result);
    return 0;
}
CPPEOF

g++ -O2 -fopenmp -std=c++17 /tmp/omp_bench.cpp -o /tmp/omp_bench -lm
/tmp/omp_bench
rm -f /tmp/omp_bench.cpp /tmp/omp_bench

echo
echo -e "${GREEN}HPC benchmarks completed.${RESET}"
echo
