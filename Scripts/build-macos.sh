#!/bin/bash
# * PowerTune macOS Build Script
# Builds the application for local development on macOS with Homebrew Qt

set -e

# * Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_DIR}/build/macos-dev"
BUILD_TYPE="${1:-Debug}"
PARALLEL_JOBS="${2:-$(sysctl -n hw.ncpu)}"

# * Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  PowerTune macOS Build${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# * Check for Qt
if ! command -v qmake &> /dev/null; then
    echo -e "${RED}Error: Qt not found. Please install Qt via Homebrew:${NC}"
    echo "  brew install qt"
    exit 1
fi

QT_VERSION=$(qmake -query QT_VERSION)
QT_PREFIX=$(qmake -query QT_INSTALL_PREFIX)
echo -e "${GREEN}✓${NC} Qt ${QT_VERSION} found at ${QT_PREFIX}"

# * Check for CMake
if ! command -v cmake &> /dev/null; then
    echo -e "${RED}Error: CMake not found. Please install:${NC}"
    echo "  brew install cmake"
    exit 1
fi

CMAKE_VERSION=$(cmake --version | head -n1)
echo -e "${GREEN}✓${NC} ${CMAKE_VERSION}"

# * Create build directory
echo ""
echo -e "${YELLOW}Build Configuration:${NC}"
echo "  Project Dir: ${PROJECT_DIR}"
echo "  Build Dir:   ${BUILD_DIR}"
echo "  Build Type:  ${BUILD_TYPE}"
echo "  Parallel:    ${PARALLEL_JOBS} jobs"
echo ""

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# * Configure with CMake
echo -e "${CYAN}Configuring...${NC}"
cmake "${PROJECT_DIR}" \
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
    -DCMAKE_PREFIX_PATH="/opt/homebrew" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# * Symlink compile_commands.json to project root for clangd
if [ -f "${BUILD_DIR}/compile_commands.json" ]; then
    ln -sf "${BUILD_DIR}/compile_commands.json" "${PROJECT_DIR}/compile_commands.json"
    echo -e "${GREEN}✓${NC} compile_commands.json linked for IDE support"
fi

# * Build
echo ""
echo -e "${CYAN}Building with ${PARALLEL_JOBS} parallel jobs...${NC}"
cmake --build . --parallel "${PARALLEL_JOBS}"

# * Report success
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Build Successful!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Application: ${CYAN}${BUILD_DIR}/PowerTuneQMLGui.app${NC}"
echo ""
echo "To run the application:"
echo -e "  ${YELLOW}open ${BUILD_DIR}/PowerTuneQMLGui.app${NC}"
echo ""
echo "Or from command line:"
echo -e "  ${YELLOW}${BUILD_DIR}/PowerTuneQMLGui.app/Contents/MacOS/PowerTuneQMLGui${NC}"
echo ""
