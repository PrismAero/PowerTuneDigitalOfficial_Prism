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
    qtserialport \
    qtsvg \
    qtsvg-plugins \
    qtshadertools \
    qtmultimedia \
    \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
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
    powertune-config \
    powertune-launcher \
    powertune-fonts \
    powertune-app \
"

silence_banner_and_bootsplash() {
    printf '#!/bin/sh\nexit 0\n' > ${IMAGE_ROOTFS}${sysconfdir}/init.d/banner.sh
    rm -f ${IMAGE_ROOTFS}${sysconfdir}/rcS.d/S40bootsplash
}
ROOTFS_POSTPROCESS_COMMAND:append = " silence_banner_and_bootsplash;"

IMAGE_ROOTFS_EXTRA_SPACE = "524288"

IMAGE_FSTYPES = "wic wic.bz2"
WKS_FILE = "sdimage-raspberrypi.wks"
