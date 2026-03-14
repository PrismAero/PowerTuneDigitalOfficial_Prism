SUMMARY = "Native process launcher for the PowerTune dashboard"
DESCRIPTION = "Compiled C binary that sets Qt/EGLFS environment and exec's PowerTuneQMLGui. \
Designed for inittab respawn to replace the legacy chain of shell-script wrappers."
LICENSE = "CLOSED"

SRC_URI = "file://powertune-launcher.c"

S = "${WORKDIR}"

do_compile() {
    ${CC} ${CFLAGS} ${LDFLAGS} -o powertune-launcher ${WORKDIR}/powertune-launcher.c
}

do_install() {
    install -d ${D}/opt/PowerTune
    install -m 0755 ${S}/powertune-launcher ${D}/opt/PowerTune/powertune-launcher
}

FILES:${PN} = "/opt/PowerTune/powertune-launcher"
