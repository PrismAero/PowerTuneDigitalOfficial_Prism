#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /absolute/path/to/PowerTuneQMLGui" >&2
    exit 1
fi

binary_path="$1"

"${script_dir}/backup-target-state.sh"
POWERTUNE_SKIP_BACKUP=1 "${script_dir}/deploy-target-runtime.sh"
POWERTUNE_SKIP_BACKUP=1 "${script_dir}/deploy-prebuilt-binary.sh" "${binary_path}"
"${script_dir}/check-target-can.sh"
