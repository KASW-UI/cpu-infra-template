# ── Shell Aliases ──────────────────────────────────────────────────────────────

alias ll="ls -alh"
alias la="ls -A"
alias l="ls -CF"

alias gs="git status"
alias gd="git diff"
alias gco="git checkout"
alias gp="git push"
alias gl="git pull"

alias py="python3"
alias ipy="ipython"

alias cpu="lscpu | head -20"
alias cpu-top="htop"
alias numastat="numactl --hardware"
alias topo="lstopo --no-io -.ascii | head -60"

alias perf-stat="perf stat -e cycles,instructions,cache-misses,branch-misses"
alias perf-top="perf top"

alias build="cmake -B build -G Ninja && ninja -C build"
alias rebuild="ninja -C build"

alias docker-clean="docker system prune -af"
