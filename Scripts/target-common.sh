#!/usr/bin/env bash

set -euo pipefail

pt_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pt_repo_root="$(cd "${pt_script_dir}/.." && pwd)"
pt_login_file="${POWERTUNE_TARGET_LOGIN_FILE:-${pt_repo_root}/remotessh.login}"
pt_backup_dir="${POWERTUNE_TARGET_BACKUP_DIR:-${pt_repo_root}/target-backups}"

pt_target_userhost() {
    if [[ -n "${POWERTUNE_TARGET:-}" ]]; then
        printf '%s\n' "${POWERTUNE_TARGET}"
        return
    fi

    if [[ ! -f "${pt_login_file}" ]]; then
        echo "Target login file not found: ${pt_login_file}" >&2
        exit 1
    fi

    local target
    target="$(awk '/^ssh[[:space:]]+/ { print $2; exit }' "${pt_login_file}")"
    if [[ -z "${target}" ]]; then
        echo "Could not parse target from ${pt_login_file}" >&2
        exit 1
    fi

    printf '%s\n' "${target}"
}

pt_ssh() {
    local target
    target="$(pt_target_userhost)"
    ssh "${target}" "$@"
}

pt_scp() {
    local source_path="$1"
    local destination_path="$2"
    local target
    target="$(pt_target_userhost)"
    scp "${source_path}" "${target}:${destination_path}"
}

pt_scp_from() {
    local remote_path="$1"
    local local_path="$2"
    local target
    target="$(pt_target_userhost)"
    scp "${target}:${remote_path}" "${local_path}"
}

pt_timestamp() {
    date +"%Y%m%d-%H%M%S"
}

pt_prepare_backup_dir() {
    mkdir -p "${pt_backup_dir}"
}

pt_stop_service() {
    pt_ssh "sh -lc '
if [ -x /etc/init.d/powertune ]; then
    /etc/init.d/powertune stop || true
elif command -v systemctl >/dev/null 2>&1; then
    systemctl stop powertune || true
fi
'"
}

pt_start_service() {
    pt_ssh "sh -lc '
if [ -x /etc/init.d/powertune ]; then
    /etc/init.d/powertune start
elif command -v systemctl >/dev/null 2>&1; then
    systemctl start powertune
fi
'"
}
