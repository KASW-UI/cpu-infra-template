# ── CPU HPC Development Environment ────────────────────────────────────────────
#
#   Source this from your ~/.zshrc:
#
#       source ~/cpu-infra-template/config/.zshrc
#
#   Or let install/shell.sh wire it for you automatically.
#
# ────────────────────────────────────────────────────────────────────────────────

CPU_DEV_CONFIG="$HOME/cpu-infra-template/config"

[[ -f "$CPU_DEV_CONFIG/exports.zsh" ]]  && source "$CPU_DEV_CONFIG/exports.zsh"
[[ -f "$CPU_DEV_CONFIG/aliases.zsh" ]]  && source "$CPU_DEV_CONFIG/aliases.zsh"
[[ -f "$CPU_DEV_CONFIG/.p10k.zsh" ]]    && source "$CPU_DEV_CONFIG/.p10k.zsh"
