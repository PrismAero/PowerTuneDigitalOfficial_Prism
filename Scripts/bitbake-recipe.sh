#!/usr/bin/env bash
#
# Builds a single Yocto recipe inside the Multipass VM.
# For powertune-app: packages the source tarball first, copies it in, then builds.
# Extracts the key artifact to a local output directory.
#
# Usage:
#   ./Scripts/bitbake-recipe.sh powertune-app          # build app only
#   ./Scripts/bitbake-recipe.sh powertune-config        # build config only
#   ./Scripts/bitbake-recipe.sh powertune-image         # build full image
#   ./Scripts/bitbake-recipe.sh powertune-app --deploy  # build + deploy binary to target
#

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

vm_name="${POWERTUNE_VM_NAME:-powertune-yocto}"
vm_repo="/workspace/PowerTuneDigitalOfficial_Prism"
yocto_root="\${HOME}/powertune-yocto"
build_dir="${yocto_root}/build-powertune"
output_dir="${repo_root}/build-artifacts"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <recipe> [--deploy] [--clean]" >&2
    echo "  Recipes: powertune-app, powertune-config, powertune-fonts, powertune-image" >&2
    exit 1
fi

recipe="$1"
shift

do_deploy=0
do_clean=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --deploy) do_deploy=1 ;;
        --clean)  do_clean=1 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

mp_exec() {
    multipass exec "${vm_name}" -- bash -lc "$1"
}

bb_exec() {
    mp_exec "cd ${yocto_root} && source poky/oe-init-build-env build-powertune > /dev/null 2>&1 && $1"
}

mkdir -p "${output_dir}"

if [[ "${recipe}" == "powertune-app" ]]; then
    echo "=== Packaging source tarball ==="
    "${script_dir}/package-source-tarball.sh"

    tarball_src="${POWERTUNE_SOURCE_TARBALL:-/tmp/powertune-src.tar.gz}"
    tarball_vm_tmp="/tmp/powertune-src.tar.gz"
    tarball_dst="${yocto_root}/meta-powertune/recipes-powertune/powertune-app/files/powertune-src.tar.gz"

    echo "=== Copying tarball into meta-powertune inside VM ==="
    multipass transfer "${tarball_src}" "${vm_name}:${tarball_vm_tmp}"
    mp_exec "mkdir -p \$(dirname ${tarball_dst}) && cp ${tarball_vm_tmp} ${tarball_dst}"
fi

if [[ "${do_clean}" == "1" ]]; then
    echo "=== Cleaning ${recipe} ==="
    bb_exec "bitbake -c cleansstate ${recipe}"
fi

echo "=== Building ${recipe} ==="
bb_exec "bitbake ${recipe}"

echo "=== Build complete ==="

app_binary_glob="${build_dir}/tmp/work/cortexa7t2hf-neon-vfpv4-poky-linux-gnueabi/powertune-app/*/image/opt/PowerTune/PowerTuneQMLGui"

case "${recipe}" in
    powertune-app)
        echo "=== Extracting app binary ==="
        binary_path=$(mp_exec "ls ${app_binary_glob} 2>/dev/null | head -1")
        if [[ -z "${binary_path}" ]]; then
            echo "Could not locate built binary in work directory." >&2
            exit 1
        fi
        multipass transfer "${vm_name}:${binary_path}" "${output_dir}/PowerTuneQMLGui"
        chmod +x "${output_dir}/PowerTuneQMLGui"
        echo "Binary extracted to: ${output_dir}/PowerTuneQMLGui"

        file "${output_dir}/PowerTuneQMLGui" || true

        if [[ "${do_deploy}" == "1" ]]; then
            echo "=== Deploying to target ==="
            "${script_dir}/deploy-native-can-target.sh" "${output_dir}/PowerTuneQMLGui"
        fi
        ;;
    powertune-image)
        echo "=== Extracting image ==="
        image_path=$(mp_exec "ls ${build_dir}/tmp/deploy/images/raspberrypi4/powertune-image-raspberrypi4.rootfs.wic.bz2 2>/dev/null | head -1")
        if [[ -n "${image_path}" ]]; then
            multipass transfer "${vm_name}:${image_path}" "${output_dir}/powertune-image-raspberrypi4.rootfs.wic.bz2"
            echo "Image extracted to: ${output_dir}/powertune-image-raspberrypi4.rootfs.wic.bz2"
        else
            echo "Image file not found. Check build output." >&2
        fi
        ;;
    *)
        echo "Recipe ${recipe} built successfully. No artifact extraction configured for this recipe."
        echo "To deploy config changes, use: ./Scripts/deploy-target-runtime.sh"
        ;;
esac
