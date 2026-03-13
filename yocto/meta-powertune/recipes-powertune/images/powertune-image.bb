SUMMARY = "PowerTune Digital Dashboard image for Raspberry Pi 4"
LICENSE = "CLOSED"

inherit core-image

IMAGE_INSTALL:append = " \
    powertune-app \
    powertune-config \
    powertune-fonts \
    can-utils \
    iproute2 \
    openssh-sftp-server \
    openssh-sshd \
    openssh-ssh \
    ntp \
    tzdata \
    liberation-fonts \
"

IMAGE_FEATURES:append = " \
    ssh-server-openssh \
    package-management \
"

IMAGE_ROOTFS_EXTRA_SPACE = "524288"

WKS_FILE = "sdimage-raspberrypi.wks"
IMAGE_FSTYPES = "wic wic.bz2"

DISTRO_FEATURES:append = " sysvinit"
DISTRO_FEATURES_BACKFILL_CONSIDERED:append = " systemd"
VIRTUAL-RUNTIME_init_manager = "sysvinit"
VIRTUAL-RUNTIME_initscripts = "initscripts"
