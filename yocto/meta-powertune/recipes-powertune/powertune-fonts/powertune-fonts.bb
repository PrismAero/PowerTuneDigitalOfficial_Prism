SUMMARY = "Custom fonts for PowerTune dashboard"
DESCRIPTION = "Magneto, Nissan, SF Automaton, DejaVu, MS Core fonts"
LICENSE = "CLOSED"

SRC_URI = ""

do_install() {
    install -d ${D}/opt/PowerTune/fonts
}

FILES:${PN} = "/opt/PowerTune/fonts"

ALLOW_EMPTY:${PN} = "1"
