#!/bin/bash

set -e

echo "Installing macOS packages..."

# Install Homebrew if not installed
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update

# Install packages
echo "Installing packages..."
brew install \
  uv \
  zellij \
  eza \
  starship \
  fd \
  ripgrep \
  fzf \
  bat \
  git-delta \
  neovim \
  mise

echo "Cleanup..."
brew cleanup

echo "macOS packages installed successfully!"
