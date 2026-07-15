# ── Environment Variables ──────────────────────────────────────────────────────

# CUDA
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

# Python (uv)
export PATH="$HOME/.local/bin:$PATH"

# Go (optional)
# export GOPATH=$HOME/go
# export PATH=$GOPATH/bin:$PATH

# Rust / Cargo (optional)
# export PATH="$HOME/.cargo/bin:$PATH"
