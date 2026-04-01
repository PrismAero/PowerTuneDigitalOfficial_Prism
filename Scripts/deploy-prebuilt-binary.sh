#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=Scripts/target-common.sh
source "${script_dir}/target-common.sh"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /absolute/path/to/PowerTuneQMLGui" >&2
    exit 1
fi

binary_path="$1"
target_binary="/opt/PowerTune/PowerTuneQMLGui"
staging_binary="/tmp/PowerTuneQMLGui.new"

if [[ ! -f "${binary_path}" ]]; then
    echo "Binary not found: ${binary_path}" >&2
    exit 1
fi

if [[ "${POWERTUNE_SKIP_BACKUP:-0}" != "1" ]]; then
    "${script_dir}/backup-target-state.sh"
fi

echo "Deploying ${binary_path} to $(pt_target_userhost)"
pt_stop_service

pt_scp "${binary_path}" "${staging_binary}"

pt_ssh "sh -lc '
install -m 0755 \"${staging_binary}\" \"${target_binary}\"
rm -f \"${staging_binary}\"
'"

pt_start_service

echo "Deployment complete."
