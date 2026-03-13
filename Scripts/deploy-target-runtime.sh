#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
# shellcheck source=Scripts/target-common.sh
source "${script_dir}/target-common.sh"

init_template="${repo_root}/operating_platform/powertune.init.sh"
remote_init_tmp="/tmp/powertune.init.new"
remote_legacy_script="/home/pi/startdaemon.sh"
remote_legacy_backup="/home/pi/startdaemon.sh.legacy-disabled"

if [[ ! -f "${init_template}" ]]; then
    echo "Missing init template: ${init_template}" >&2
    exit 1
fi

if [[ "${POWERTUNE_SKIP_BACKUP:-0}" != "1" ]]; then
    "${script_dir}/backup-target-state.sh"
fi

echo "Deploying runtime files to $(pt_target_userhost)"
pt_stop_service
pt_scp "${init_template}" "${remote_init_tmp}"

pt_ssh "sh -lc '
install -m 0755 \"${remote_init_tmp}\" /etc/init.d/powertune
rm -f \"${remote_init_tmp}\"
if [ -f \"${remote_legacy_script}\" ]; then
    mv \"${remote_legacy_script}\" \"${remote_legacy_backup}\"
fi
killall Generic 2>/dev/null || true
'"

pt_start_service
echo "Runtime deployment complete."
