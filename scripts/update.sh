#!/usr/bin/env bash

###############################################################################
# GPU Development Environment Updater
###############################################################################

set -Eeuo pipefail

################################################################################
# Colors
################################################################################

GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

success() {
    echo -e "${GREEN}[ OK ]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

################################################################################
# System
################################################################################

info "Updating Ubuntu..."

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

################################################################################
# Git LFS
################################################################################

if command -v git-lfs >/dev/null 2>&1; then

    info "Updating Git LFS..."

    git lfs install

fi

################################################################################
# uv
################################################################################

if command -v uv >/dev/null 2>&1; then

    info "Updating uv..."

    uv self update || true

fi

################################################################################
# Python Environment
################################################################################

VENV="$HOME/workspace/ai-infra/.venv"

if [[ -d "$VENV" ]]; then

    info "Updating Python packages..."

    source "$VENV/bin/activate"

    uv pip install --upgrade \
        pip \
        setuptools \
        wheel

    deactivate

fi

################################################################################
# Docker
################################################################################

if command -v docker >/dev/null 2>&1; then

    info "Updating Docker images..."

    docker image prune -f || true

fi

################################################################################
# Git Repositories
################################################################################

WORKSPACE="$HOME/workspace"

if [[ -d "$WORKSPACE" ]]; then

    info "Updating repositories..."

    for repo in "$WORKSPACE"/*; do

        if [[ -d "$repo/.git" ]]; then

            echo

            echo "----------------------------------------"
            echo "$(basename "$repo")"
            echo "----------------------------------------"

            (
                cd "$repo"

                git fetch --all --prune

                CURRENT_BRANCH=$(git branch --show-current)

                if [[ -n "$CURRENT_BRANCH" ]]; then

                    git pull --ff-only || true

                fi
            )

        fi

    done

fi

################################################################################
# Verify
################################################################################

echo

success "Update completed."

echo

echo "Run"

echo

echo "    ./scripts/doctor.sh"

echo

echo "to verify your environment."

echo