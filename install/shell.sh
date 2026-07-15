#!/usr/bin/env bash

###############################################################################
# Shell Environment Installer
#
# Ubuntu 22.04 / 24.04
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

error() {
    echo -e "${RED}[FAIL]${RESET} $1"
}

################################################################################
# Check zsh
################################################################################

if ! command -v zsh >/dev/null 2>&1; then
    error "zsh not found. Run install/base.sh first."
    exit 1
fi

################################################################################
# Oh My Zsh
################################################################################

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then

    info "Installing Oh My Zsh..."

    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

else

    success "Oh My Zsh already installed."

fi

################################################################################
# Powerlevel10k
################################################################################

P10K="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

if [[ ! -d "$P10K" ]]; then

    info "Installing Powerlevel10k..."

    git clone --depth=1 \
    https://github.com/romkatv/powerlevel10k.git \
    "$P10K"

fi

################################################################################
# Plugins
################################################################################

PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins"

mkdir -p "$PLUGIN_DIR"

install_plugin() {

    local NAME="$1"
    local URL="$2"

    if [[ ! -d "$PLUGIN_DIR/$NAME" ]]; then

        info "Installing $NAME..."

        git clone --depth=1 "$URL" "$PLUGIN_DIR/$NAME"

    else

        success "$NAME already installed."

    fi

}

install_plugin \
zsh-autosuggestions \
https://github.com/zsh-users/zsh-autosuggestions.git

install_plugin \
zsh-syntax-highlighting \
https://github.com/zsh-users/zsh-syntax-highlighting.git

install_plugin \
zsh-vi-mode \
https://github.com/jeffreytse/zsh-vi-mode.git

################################################################################
# Install Config Files
#
#   Does NOT overwrite existing dotfiles.
#   Instead:
#     1. Copies config/ files to ~/.config/gpu-dev/
#     2. Appends a one-line source to ~/.zshrc (idempotent)
################################################################################

GPU_CONFIG_DIR="$HOME/.config/gpu-dev"

mkdir -p "$GPU_CONFIG_DIR"

# Copy config files (safe — ~/.config/gpu-dev/ is our namespace)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -d "$SCRIPT_DIR/config" ]]; then

    for f in "$SCRIPT_DIR/config/"*; do

        name="$(basename "$f")"

        cp "$f" "$GPU_CONFIG_DIR/$name"
        success "Installed $name → $GPU_CONFIG_DIR/$name"

    done

else

    warn "config/ directory not found at $SCRIPT_DIR/config"

fi

################################################################################
# Wire into .zshrc (idempotent — only appends if not already present)
################################################################################

SOURCE_LINE='[[ -f "$HOME/.config/gpu-dev/.zshrc" ]] && source "$HOME/.config/gpu-dev/.zshrc"'

if [[ -f "$HOME/.zshrc" ]]; then

    if ! grep -qF "$SOURCE_LINE" "$HOME/.zshrc" 2>/dev/null; then
        echo >> "$HOME/.zshrc"
        echo "$SOURCE_LINE" >> "$HOME/.zshrc"
        success "Appended GPU dev config source to ~/.zshrc"
    else
        success "~/.zshrc already sources GPU dev config"
    fi

else

    echo "$SOURCE_LINE" > "$HOME/.zshrc"
    success "Created ~/.zshrc with GPU dev config source"

fi

################################################################################
# Default Shell
################################################################################

if [[ "$SHELL" != "$(which zsh)" ]]; then

    info "Changing default shell to zsh..."

    chsh -s "$(which zsh)"

fi

################################################################################
# Finish
################################################################################

echo
success "Shell environment installed."

echo
echo "Installed"
echo "  Oh My Zsh"
echo "  Powerlevel10k"
echo "  zsh-autosuggestions"
echo "  zsh-syntax-highlighting"
echo "  zsh-vi-mode"
echo
echo "Config files copied to $GPU_CONFIG_DIR"
echo
echo "Restart terminal or run:"
echo
echo "    source ~/.zshrc"
echo
