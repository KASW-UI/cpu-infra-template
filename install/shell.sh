#!/usr/bin/env bash

###############################################################################
# Shell Environment Installer
###############################################################################

set -Eeuo pipefail

GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[ OK ]${RESET} $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() { echo -e "${RED}[FAIL]${RESET} $1"; }

if ! command -v zsh >/dev/null 2>&1; then
    error "zsh not found. Run install/base.sh first."
    exit 1
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    success "Oh My Zsh already installed."
fi

P10K="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [[ ! -d "$P10K" ]]; then
    info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K"
fi

PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$PLUGIN_DIR"

install_plugin() {
    local NAME="$1" URL="$2"
    if [[ ! -d "$PLUGIN_DIR/$NAME" ]]; then
        info "Installing $NAME..."
        git clone --depth=1 "$URL" "$PLUGIN_DIR/$NAME"
    else
        success "$NAME already installed."
    fi
}

install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
install_plugin zsh-vi-mode https://github.com/jeffreytse/zsh-vi-mode.git

CPU_CONFIG_DIR="$HOME/.config/cpu-dev"
mkdir -p "$CPU_CONFIG_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -d "$SCRIPT_DIR/config" ]]; then
    for f in "$SCRIPT_DIR/config/"*; do
        name="$(basename "$f")"
        cp "$f" "$CPU_CONFIG_DIR/$name"
        success "Installed $name → $CPU_CONFIG_DIR/$name"
    done
else
    warn "config/ directory not found at $SCRIPT_DIR/config"
fi

SOURCE_LINE='[[ -f "$HOME/.config/cpu-dev/.zshrc" ]] && source "$HOME/.config/cpu-dev/.zshrc"'
if [[ -f "$HOME/.zshrc" ]]; then
    if ! grep -qF "$SOURCE_LINE" "$HOME/.zshrc" 2>/dev/null; then
        echo >> "$HOME/.zshrc"
        echo "$SOURCE_LINE" >> "$HOME/.zshrc"
        success "Appended cpu-dev config source to ~/.zshrc"
    else
        success "~/.zshrc already sources cpu-dev config"
    fi
else
    echo "$SOURCE_LINE" > "$HOME/.zshrc"
    success "Created ~/.zshrc with cpu-dev config source"
fi

if [[ "$SHELL" != "$(which zsh)" ]]; then
    info "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

echo
success "Shell environment installed."
echo "  Oh My Zsh / Powerlevel10k / zsh-autosuggestions / syntax-highlighting / vi-mode"
echo "  Config files → $CPU_CONFIG_DIR"
echo
