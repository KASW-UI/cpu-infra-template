# ── GPU Development Environment ────────────────────────────────────────────────
#
#   Source this from your ~/.zshrc:
#
#       source ~/gpu-dev-env/config/.zshrc
#
#   Or let install/shell.sh wire it for you automatically.
#
# ────────────────────────────────────────────────────────────────────────────────

GPU_DEV_CONFIG="$HOME/gpu-dev-env/config"

[[ -f "$GPU_DEV_CONFIG/exports.zsh" ]]  && source "$GPU_DEV_CONFIG/exports.zsh"
[[ -f "$GPU_DEV_CONFIG/aliases.zsh" ]]  && source "$GPU_DEV_CONFIG/aliases.zsh"
[[ -f "$GPU_DEV_CONFIG/.p10k.zsh" ]]    && source "$GPU_DEV_CONFIG/.p10k.zsh"
