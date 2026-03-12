#!/bin/bash
# Format tracked C/C++ sources with the repo's .clang-format

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v clang-format >/dev/null 2>&1; then
    echo "Error: clang-format is not installed or not on PATH." >&2
    exit 1
fi

cd "${PROJECT_DIR}"

if [ "$#" -gt 0 ]; then
    files=("$@")
else
    mapfile -t files < <(git ls-files '*.cpp' '*.cc' '*.cxx' '*.h' '*.hh' '*.hpp')
fi

if [ "${#files[@]}" -eq 0 ]; then
    echo "No C/C++ files found to format."
    exit 0
fi

echo "Formatting ${#files[@]} C/C++ files..."
clang-format -i "${files[@]}"
echo "C/C++ formatting complete."
