SUMMARY = "PowerTune system configuration, networking, and init"
DESCRIPTION = "Custom inittab (no getty, app respawn via native launcher), \
IPv4-only networking with CAN bus, sysctl hardening, and the administrative \
init.d script for stop/restart control."
LICENSE = "CLOSED"

SRC_URI = " \
    file://powertune.init \
    file://kms-config.json \
    file://interfaces \
    file://inittab \
    file://sysctl-no-ipv6.conf \
"

RDEPENDS:${PN} = "iproute2 can-utils"

INITSCRIPT_NAME = "powertune"
INITSCRIPT_PARAMS = "defaults 99"

inherit update-rc.d

do_install() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/powertune.init ${D}${sysconfdir}/init.d/powertune

    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/inittab ${D}${sysconfdir}/inittab

    install -d ${D}${sysconfdir}/network
    install -m 0644 ${WORKDIR}/interfaces ${D}${sysconfdir}/network/interfaces

    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/sysctl-no-ipv6.conf ${D}${sysconfdir}/sysctl.d/99-no-ipv6.conf

    install -d ${D}/opt/PowerTune
    install -m 0644 ${WORKDIR}/kms-config.json ${D}/opt/PowerTune/kms-config.json
}

FILES:${PN} = " \
    ${sysconfdir}/init.d/powertune \
    ${sysconfdir}/inittab \
    ${sysconfdir}/network/interfaces \
    ${sysconfdir}/sysctl.d/99-no-ipv6.conf \
    /opt/PowerTune/kms-config.json \
"

CONFFILES:${PN} = " \
    ${sysconfdir}/inittab \
    ${sysconfdir}/network/interfaces \
    ${sysconfdir}/sysctl.d/99-no-ipv6.conf \
"
