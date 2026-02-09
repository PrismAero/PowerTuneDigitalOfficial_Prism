#!/bin/bash
# * PowerTune macOS Run Script
# Runs the application from the build directory

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_DIR}/build/macos-dev"
APP_PATH="${BUILD_DIR}/PowerTuneQMLGui.app/Contents/MacOS/PowerTuneQMLGui"

if [ ! -f "${APP_PATH}" ]; then
    echo "Application not found. Building first..."
    "${PROJECT_DIR}/scripts/build-macos.sh"
fi

echo "Starting PowerTune..."
cd "${PROJECT_DIR}"
"${APP_PATH}" "$@"
