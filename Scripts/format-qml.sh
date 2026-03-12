#!/bin/bash
# Format tracked QML sources with qmlformat

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v qmlformat >/dev/null 2>&1; then
    echo "Error: qmlformat is not installed or not on PATH." >&2
    exit 1
fi

cd "${PROJECT_DIR}"

if [ "$#" -gt 0 ]; then
    files=("$@")
else
    mapfile -t files < <(git ls-files '*.qml')
fi

if [ "${#files[@]}" -eq 0 ]; then
    echo "No QML files found to format."
    exit 0
fi

tmpfile="$(mktemp)"
trap 'rm -f "${tmpfile}"' EXIT
printf '%s\n' "${files[@]}" > "${tmpfile}"

echo "Formatting ${#files[@]} QML files..."
qmlformat -i -n --objects-spacing --functions-spacing -w 4 -W 120 -l native -F "${tmpfile}"
echo "QML formatting complete."
