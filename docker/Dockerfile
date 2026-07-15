ARG CUDA_VERSION=12.4.1
ARG PYTHON_VERSION=3.12.10
ARG TORCH_VERSION=2.6.0
ARG TRITON_VERSION=3.2.0
ARG UBUNTU_VERSION=22.04

FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}

ARG PYTHON_VERSION
ARG TORCH_VERSION
ARG TRITON_VERSION

LABEL project="gpu-infra-template"
LABEL cuda="${CUDA_VERSION}"
LABEL python="${PYTHON_VERSION}"
LABEL torch="${TORCH_VERSION}+cu124"

ENV DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/apt/sources.list.d/*.list 2>/dev/null; \
    echo "deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    gcc g++ \
    clang clangd lld \
    cmake ninja-build \
    make git git-lfs \
    curl wget ca-certificates \
    vim tmux htop btop \
    jq ripgrep fd-find bat fzf \
    libssl-dev libffi-dev zlib1g-dev \
    libnccl-dev libnccl2 \
    openssh-client \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 dev && \
    useradd -m -u 1000 -g dev -s /bin/bash dev && \
    echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER dev
ENV HOME=/home/dev
WORKDIR /workspace

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/dev/.local/bin:${PATH}"

RUN uv python install ${PYTHON_VERSION}

RUN uv venv --python ${PYTHON_VERSION} /workspace/.venv
ENV PATH="/workspace/.venv/bin:${PATH}"

COPY --chown=dev:dev env/requirements.lock /tmp/requirements.lock

RUN uv pip install -r /tmp/requirements.lock

RUN mkdir -p /home/dev/.config/gpu-infra
COPY --chown=dev:dev configs/nccl.env /home/dev/.config/gpu-infra/nccl.env
COPY --chown=dev:dev configs/torch.env /home/dev/.config/gpu-infra/torch.env
COPY --chown=dev:dev configs/docker.env /home/dev/.config/gpu-infra/docker.env

RUN mkdir -p /workspace/scripts
COPY --chown=dev:dev scripts/ /workspace/scripts/

COPY --chown=dev:dev config/.tmux.conf /home/dev/.tmux.conf

COPY --chown=dev:dev docker/entrypoint.sh /usr/local/bin/entrypoint.sh
USER root
RUN chmod +x /usr/local/bin/entrypoint.sh
USER dev

ENV CUDA_HOME=/usr/local/cuda
ENV PATH="${CUDA_HOME}/bin:${PATH}"
ENV LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${CUDA_HOME}/compat:${LD_LIBRARY_PATH}"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
