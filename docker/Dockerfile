ARG UBUNTU_VERSION=22.04
ARG PYTHON_VERSION=3.12.10

FROM ubuntu:${UBUNTU_VERSION}

ARG PYTHON_VERSION

LABEL project="cpu-infra-template"
LABEL python="${PYTHON_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/apt/sources.list.d/*.list 2>/dev/null; \
    echo "deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    gcc g++ \
    clang clangd lld \
    gdb valgrind strace ltrace \
    cmake ninja-build \
    make git git-lfs pkg-config \
    curl wget ca-certificates \
    vim tmux htop btop \
    jq ripgrep fd-find bat fzf \
    libssl-dev libffi-dev zlib1g-dev \
    openssh-client \
    sudo \
    python3.12 python3.12-venv python3.12-dev \
    libomp-dev \
    openmpi-bin libopenmpi-dev \
    libopenblas-dev liblapack-dev libeigen3-dev \
    linux-tools-generic numactl hwloc \
    libbenchmark-dev stress-ng \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex; \
    LIKWID_VERSION=5.3.0 && \
    curl -fsSL "https://github.com/RRZE-HPC/likwid/archive/refs/tags/v${LIKWID_VERSION}.tar.gz" -o /tmp/likwid.tar.gz && \
    tar -xzf /tmp/likwid.tar.gz -C /tmp && \
    cd /tmp/likwid-${LIKWID_VERSION} && \
    sed -i 's/^BUILD_DAEMON.*/BUILD_DAEMON=false/' config.mk 2>/dev/null; \
    sed -i 's/^BUILD_FREQ.*/BUILD_FREQ=false/' config.mk 2>/dev/null; \
    make -j$(nproc) && \
    make install PREFIX=/usr/local && \
    ldconfig && \
    rm -rf /tmp/likwid*
RUN echo "likwid installed: $(likwid-perfctr --version 2>&1 | head -1 || echo 'likwid binary OK')"

RUN groupadd -g 1000 dev && \
    useradd -m -u 1000 -g dev -s /bin/bash dev && \
    echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER dev
ENV HOME=/home/dev
WORKDIR /workspace

RUN python3.12 -m venv /workspace/.venv
ENV PATH="/workspace/.venv/bin:${PATH}"
RUN pip install --upgrade pip setuptools wheel

COPY --chown=dev:dev env/requirements.lock /tmp/requirements.lock

RUN pip install --no-cache-dir -r /tmp/requirements.lock

RUN mkdir -p /home/dev/.config/cpu-infra
COPY --chown=dev:dev configs/openmp.env /home/dev/.config/cpu-infra/openmp.env
COPY --chown=dev:dev configs/mpi.env /home/dev/.config/cpu-infra/mpi.env
COPY --chown=dev:dev configs/hpc.env /home/dev/.config/cpu-infra/hpc.env

RUN mkdir -p /workspace/scripts
COPY --chown=dev:dev scripts/ /workspace/scripts/

COPY --chown=dev:dev config/.tmux.conf /home/dev/.tmux.conf

COPY --chown=dev:dev docker/entrypoint.sh /usr/local/bin/entrypoint.sh
USER root
RUN chmod +x /usr/local/bin/entrypoint.sh
USER dev

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
