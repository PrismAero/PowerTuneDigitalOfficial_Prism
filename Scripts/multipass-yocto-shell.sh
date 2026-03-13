#!/usr/bin/env bash

set -euo pipefail

vm_name="${POWERTUNE_VM_NAME:-powertune-yocto}"
mount_path="${POWERTUNE_VM_MOUNT_PATH:-/workspace/PowerTuneDigitalOfficial_Prism}"

echo "Opening shell in ${vm_name}."
echo "Then run: cd '${mount_path}'"
exec multipass shell "${vm_name}"
