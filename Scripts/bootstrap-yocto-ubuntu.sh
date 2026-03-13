#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
    echo "This bootstrap script must run inside a Linux VM or container, not directly on macOS." >&2
    echo "Use an Ubuntu 22.04 environment hosted on your Mac, then rerun this script there." >&2
    exit 1
fi

sudo apt-get update
sudo apt-get install -y \
    gawk \
    wget \
    git \
    diffstat \
    unzip \
    texinfo \
    gcc \
    build-essential \
    chrpath \
    socat \
    cpio \
    python3 \
    python3-pip \
    python3-pexpect \
    python3-git \
    python3-jinja2 \
    xz-utils \
    debianutils \
    iputils-ping \
    libsdl1.2-dev \
    xterm \
    zstd \
    file \
    locales

sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo "Ubuntu Yocto host dependencies installed."
echo "Next: clone the Yocto layer stack onto this Linux host and build from there."
