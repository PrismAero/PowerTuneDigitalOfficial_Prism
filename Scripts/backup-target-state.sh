#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=Scripts/target-common.sh
source "${script_dir}/target-common.sh"

stamp="${1:-$(pt_timestamp)}"
remote_archive="/tmp/powertune-target-backup-${stamp}.tar.gz"

pt_prepare_backup_dir
local_archive="${pt_backup_dir}/powertune-target-backup-${stamp}.tar.gz"

echo "Creating target backup on $(pt_target_userhost)"

pt_ssh "sh -lc '
set -eu
archive=\"${remote_archive}\"
set --
for path in \
    /opt/PowerTune \
    /etc/init.d/powertune \
    /home/pi/startdaemon.sh \
    /home/root/startdaemon.sh \
    /boot/config.txt \
    /var/log/powertune.log \
    /var/log/generic-daemon.log
do
    if [ -e \"\$path\" ]; then
        set -- \"\$@\" \"\$path\"
    fi
done
tar czf \"\$archive\" \"\$@\"
'"

pt_scp_from "${remote_archive}" "${local_archive}"
pt_ssh "rm -f \"${remote_archive}\""

echo "Saved backup to ${local_archive}"
