SUMMARY = "PowerTune runtime configuration and init scripts"
DESCRIPTION = "Init scripts, CAN configuration, network interfaces, and environment for PowerTune"
LICENSE = "CLOSED"

SRC_URI = " \
    file://powertune.init \
    file://kms-config.json \
    file://interfaces \
"

RDEPENDS:${PN} = "can-utils iproute2"

INITSCRIPT_NAME = "powertune"
INITSCRIPT_PARAMS = "defaults 99"

inherit update-rc.d

do_install() {
    # Init script
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/powertune.init ${D}${sysconfdir}/init.d/powertune

    # KMS config
    install -d ${D}/opt/PowerTune
    install -m 0644 ${WORKDIR}/kms-config.json ${D}/opt/PowerTune/kms-config.json

    # Network interfaces
    install -d ${D}${sysconfdir}/network
    install -m 0644 ${WORKDIR}/interfaces ${D}${sysconfdir}/network/interfaces
}

FILES:${PN} = " \
    ${sysconfdir}/init.d/powertune \
    ${sysconfdir}/network/interfaces \
    /opt/PowerTune/kms-config.json \
"
