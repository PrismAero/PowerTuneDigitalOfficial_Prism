#!/bin/bash
# Format all tracked C/C++ and QML sources

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/format-cpp.sh"
"${SCRIPT_DIR}/format-qml.sh"
