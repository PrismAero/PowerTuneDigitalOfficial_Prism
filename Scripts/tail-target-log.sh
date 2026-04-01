#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=Scripts/target-common.sh
source "${script_dir}/target-common.sh"

log_path="${1:-/var/log/powertune.log}"

echo "Tailing ${log_path} on $(pt_target_userhost)"
pt_ssh "tail -n 200 -f \"${log_path}\""
