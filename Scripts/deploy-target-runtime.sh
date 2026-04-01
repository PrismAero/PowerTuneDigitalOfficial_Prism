#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
# shellcheck source=Scripts/target-common.sh
source "${script_dir}/target-common.sh"

init_template="${repo_root}/operating_platform/powertune.init.sh"
inittab_src="${repo_root}/yocto/meta-powertune/recipes-powertune/powertune-config/files/inittab"
sysctl_src="${repo_root}/yocto/meta-powertune/recipes-powertune/powertune-config/files/sysctl-no-ipv6.conf"
interfaces_src="${repo_root}/yocto/meta-powertune/recipes-powertune/powertune-config/files/interfaces"

for f in "${init_template}" "${inittab_src}" "${sysctl_src}" "${interfaces_src}"; do
    if [[ ! -f "${f}" ]]; then
        echo "Missing: ${f}" >&2
        exit 1
    fi
done

if [[ "${POWERTUNE_SKIP_BACKUP:-0}" != "1" ]]; then
    "${script_dir}/backup-target-state.sh"
fi

echo "Deploying runtime files to $(pt_target_userhost)"
pt_stop_service

pt_scp "${init_template}"  "/tmp/powertune.init.new"
pt_scp "${inittab_src}"    "/tmp/inittab.new"
pt_scp "${sysctl_src}"     "/tmp/sysctl-no-ipv6.new"
pt_scp "${interfaces_src}" "/tmp/interfaces.new"

pt_ssh "sh -lc '
install -m 0755 /tmp/powertune.init.new /etc/init.d/powertune
install -m 0644 /tmp/inittab.new /etc/inittab
mkdir -p /etc/sysctl.d
install -m 0644 /tmp/sysctl-no-ipv6.new /etc/sysctl.d/99-no-ipv6.conf
install -m 0644 /tmp/interfaces.new /etc/network/interfaces
rm -f /tmp/powertune.init.new /tmp/inittab.new /tmp/sysctl-no-ipv6.new /tmp/interfaces.new

# Remove legacy bash scripts
rm -f /home/pi/startdaemon.sh /home/pi/startdaemon.sh.legacy-disabled
rm -f /etc/init.d/bootsplash

# Stop legacy processes
killall Generic 2>/dev/null || true
killall gst-launch-1.0 2>/dev/null || true

# Apply sysctl immediately
sysctl -p /etc/sysctl.d/99-no-ipv6.conf 2>/dev/null || true
'"

pt_start_service
echo "Runtime deployment complete."
