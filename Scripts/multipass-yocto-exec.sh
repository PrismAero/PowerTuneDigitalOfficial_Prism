#!/usr/bin/env bash

set -euo pipefail

vm_name="${POWERTUNE_VM_NAME:-powertune-yocto}"
mount_path="${POWERTUNE_VM_MOUNT_PATH:-/workspace/PowerTuneDigitalOfficial_Prism}"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 '<command>'" >&2
    exit 1
fi

command_string="$1"
exec multipass exec "${vm_name}" -- bash -lc "cd '${mount_path}' && ${command_string}"
