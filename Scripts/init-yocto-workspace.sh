#!/usr/bin/env bash
#
# Initializes the Yocto workspace inside the Multipass VM.
# Clones layers if missing, symlinks meta-powertune from the mounted repo,
# and installs the conf templates.
#
# Run from Mac: ./Scripts/init-yocto-workspace.sh
#

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

vm_name="${POWERTUNE_VM_NAME:-powertune-yocto}"
vm_repo="/workspace/PowerTuneDigitalOfficial_Prism"
yocto_root="\${HOME}/powertune-yocto"

mp_exec() {
    multipass exec "${vm_name}" -- bash -lc "$1"
}

echo "=== Initializing Yocto workspace in ${vm_name} ==="

mp_exec "mkdir -p ${yocto_root}"

echo "--- Checking Yocto layers ---"

if ! mp_exec "test -d ${yocto_root}/poky/.git"; then
    echo "Cloning poky (scarthgap)..."
    mp_exec "cd ${yocto_root} && git clone -b scarthgap git://git.yoctoproject.org/poky.git poky"
else
    echo "poky already present."
fi

if ! mp_exec "test -d ${yocto_root}/meta-raspberrypi/.git"; then
    echo "Cloning meta-raspberrypi (scarthgap)..."
    mp_exec "cd ${yocto_root} && git clone -b scarthgap https://github.com/agherzan/meta-raspberrypi.git meta-raspberrypi"
else
    echo "meta-raspberrypi already present."
fi

if ! mp_exec "test -d ${yocto_root}/meta-openembedded/.git"; then
    echo "Cloning meta-openembedded (scarthgap)..."
    mp_exec "cd ${yocto_root} && git clone -b scarthgap https://github.com/openembedded/meta-openembedded.git meta-openembedded"
else
    echo "meta-openembedded already present."
fi

if ! mp_exec "test -d ${yocto_root}/meta-qt6/.git"; then
    echo "Cloning meta-qt6 (6.8)..."
    mp_exec "cd ${yocto_root} && git clone -b 6.8 https://code.qt.io/yocto/meta-qt6.git meta-qt6"
else
    echo "meta-qt6 already present."
fi

echo "--- Linking meta-powertune from mounted repo ---"
mp_exec "rm -f ${yocto_root}/meta-powertune && ln -sfn ${vm_repo}/yocto/meta-powertune ${yocto_root}/meta-powertune"

echo "--- Initializing build directory ---"
mp_exec "cd ${yocto_root} && source poky/oe-init-build-env build-powertune > /dev/null 2>&1 || true"

echo "--- Installing conf templates ---"
mp_exec "
if [ ! -f ${yocto_root}/build-powertune/conf/local.conf.bak ]; then
    cp ${yocto_root}/build-powertune/conf/local.conf ${yocto_root}/build-powertune/conf/local.conf.bak 2>/dev/null || true
fi
cp ${vm_repo}/yocto/conf/local.conf.template ${yocto_root}/build-powertune/conf/local.conf
yocto_abs=\$(cd ${yocto_root} && pwd)
sed \"s|YOCTO_ROOT_PLACEHOLDER|\${yocto_abs}|g\" ${vm_repo}/yocto/conf/bblayers.conf.template > ${yocto_root}/build-powertune/conf/bblayers.conf
"

echo "--- Creating source tarball staging area ---"
mp_exec "mkdir -p ${yocto_root}/meta-powertune/recipes-powertune/powertune-app/files"

echo ""
echo "Yocto workspace initialized at ~/powertune-yocto inside ${vm_name}."
echo "Layers:"
mp_exec "ls -1d ${yocto_root}/*/ | sed 's|.*/||;s|/||'"
echo ""
echo "Next: ./Scripts/bitbake-recipe.sh powertune-app"
