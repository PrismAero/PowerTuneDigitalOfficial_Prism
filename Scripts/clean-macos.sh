#!/bin/bash
# * PowerTune macOS Clean Script
# Removes build artifacts

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_DIR}/build/macos-dev"

echo "Cleaning build directory..."
rm -rf "${BUILD_DIR}"
echo "Done."
