SUMMARY = "PowerTune Digital Dashboard image for Raspberry Pi 4"
LICENSE = "CLOSED"

inherit core-image

IMAGE_FEATURES += "ssh-server-openssh"

IMAGE_INSTALL = " \
    packagegroup-core-boot \
    kernel-modules \
    \
    qtbase \
    qtbase-plugins \
    qtdeclarative \
    qtdeclarative-qmlplugins \
    qt5compat \
    qt5compat-qmlplugins \
    qtserialbus \
    qtsvg \
    qtsvg-plugins \
    qtshadertools \
    \
    mesa-megadriver \
    libdrm \
    libinput \
    libxkbcommon \
    \
    can-utils \
    iproute2 \
    wpa-supplicant \
    openssh \
    openssh-sftp-server \
    \
    procps \
    \
    openssl-compat-1.1 \
    powertune-config \
    powertune-launcher \
    powertune-daemons \
    powertune-fonts \
    powertune-app \
"

IMAGE_ROOTFS_EXTRA_SPACE = "524288"

IMAGE_FSTYPES = "wic wic.bz2"
WKS_FILE = "sdimage-raspberrypi.wks"
