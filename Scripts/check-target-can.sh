#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=Scripts/target-common.sh
source "${script_dir}/target-common.sh"

echo "Checking CAN status on $(pt_target_userhost)"

pt_ssh 'sh -lc "
echo \"== can0 ==\"
ip -details link show can0 || true
echo
echo \"== powertune process ==\"
ps | grep -E \"PowerTuneQMLGui|Generic\" | grep -v grep || true
echo
echo \"== last app log lines ==\"
tail -n 80 /var/log/powertune.log 2>/dev/null || true
echo
echo \"== candump sample ==\"
if command -v candump >/dev/null 2>&1; then
    candump can0 &
    dump_pid=\$!
    sleep 5
    kill \$dump_pid >/dev/null 2>&1 || true
    wait \$dump_pid 2>/dev/null || true
else
    echo \"candump not installed on target\"
fi
"'
