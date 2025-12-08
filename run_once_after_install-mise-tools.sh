#!/bin/bash

set -e

# Check if mise is installed
if ! command -v mise &> /dev/null; then
    echo "mise is not installed. Skipping mise tool installation."
    exit 0
fi

echo "Installing mise tools..."

# Install tools from .tool-versions
mise install

echo "mise tools installed successfully!"
echo "Run 'mise doctor' to verify installation."
