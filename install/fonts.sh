#!/usr/bin/env bash

###############################################################################
# Fonts Installer
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
# Install Packages
################################################################################

info "Installing font utilities..."

sudo apt update

sudo apt install -y \
fontconfig \
unzip \
wget

################################################################################
# Font Directory
################################################################################

FONT_DIR="$HOME/.local/share/fonts"

mkdir -p "$FONT_DIR"

cd "$FONT_DIR"

################################################################################
# JetBrainsMono Nerd Font
################################################################################

if [[ ! -d "JetBrainsMono" ]]; then

    info "Installing JetBrainsMono Nerd Font..."

    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip

    unzip -oq JetBrainsMono.zip -d JetBrainsMono

    rm JetBrainsMono.zip

else

    warn "JetBrainsMono already installed."

fi

################################################################################
# FiraCode Nerd Font
################################################################################

if [[ ! -d "FiraCode" ]]; then

    info "Installing FiraCode Nerd Font..."

    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip

    unzip -oq FiraCode.zip -d FiraCode

    rm FiraCode.zip

else

    warn "FiraCode already installed."

fi

################################################################################
# CascadiaCode Nerd Font
################################################################################

if [[ ! -d "CascadiaCode" ]]; then

    info "Installing CascadiaCode Nerd Font..."

    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip

    unzip -oq CascadiaCode.zip -d CascadiaCode

    rm CascadiaCode.zip

else

    warn "CascadiaCode already installed."

fi

################################################################################
# Refresh Cache
################################################################################

info "Refreshing font cache..."

fc-cache -fv >/dev/null

################################################################################
# Verify
################################################################################

echo

success "Installed fonts:"

fc-list | grep -i "JetBrains" | head -3 || true

fc-list | grep -i "Fira" | head -3 || true

fc-list | grep -i "Cascadia" | head -3 || true

################################################################################
# Finish
################################################################################

echo

success "Fonts installed."

echo

echo "Recommended terminal font:"

echo

echo "    JetBrainsMono Nerd Font"

echo

echo "Recommended VS Code font:"

echo

echo "    JetBrainsMono Nerd Font"

echo

echo "Recommended Warp font:"

echo

echo "    JetBrainsMono Nerd Font"

echo