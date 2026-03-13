#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

vm_name="${POWERTUNE_VM_NAME:-powertune-yocto}"
vm_image="${POWERTUNE_VM_IMAGE:-22.04}"
vm_cpus="${POWERTUNE_VM_CPUS:-6}"
vm_mem="${POWERTUNE_VM_MEM:-8G}"
vm_disk="${POWERTUNE_VM_DISK:-120G}"
mount_path="${POWERTUNE_VM_MOUNT_PATH:-/workspace/PowerTuneDigitalOfficial_Prism}"

if ! command -v multipass >/dev/null 2>&1; then
    echo "multipass is not installed on this Mac." >&2
    exit 1
fi

if multipass info "${vm_name}" >/dev/null 2>&1; then
    echo "Using existing Multipass VM: ${vm_name}"
    multipass start "${vm_name}"
else
    echo "Launching Multipass VM ${vm_name} (${vm_image}, ${vm_cpus} CPU, ${vm_mem} RAM, ${vm_disk} disk)"
    multipass launch "${vm_image}" \
        --name "${vm_name}" \
        --cpus "${vm_cpus}" \
        --memory "${vm_mem}" \
        --disk "${vm_disk}"
fi

if ! multipass exec "${vm_name}" -- test -d "${mount_path}"; then
    multipass exec "${vm_name}" -- sudo mkdir -p "$(dirname "${mount_path}")"
    multipass mount "${repo_root}" "${vm_name}:${mount_path}"
fi

multipass exec "${vm_name}" -- bash -lc "cd '${mount_path}' && chmod +x Scripts/bootstrap-yocto-ubuntu.sh && Scripts/bootstrap-yocto-ubuntu.sh"

echo
echo "Multipass Yocto VM ready."
echo "VM name: ${vm_name}"
echo "Mounted repo: ${mount_path}"
echo "Open shell with: ./Scripts/multipass-yocto-shell.sh"
