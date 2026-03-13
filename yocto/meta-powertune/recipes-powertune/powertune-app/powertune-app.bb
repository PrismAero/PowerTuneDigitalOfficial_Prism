SUMMARY = "PowerTune Digital Dashboard Application"
DESCRIPTION = "Qt 6 / QML automotive dashboard targeting Raspberry Pi 4"
LICENSE = "CLOSED"

SRC_URI = "file://powertune-src.tar.gz"
S = "${WORKDIR}/powertune-src"

inherit qt6-cmake

DEPENDS = " \
    qtbase \
    qtdeclarative \
    qtserialbus \
    qtserialport \
    qtsvg \
    qtcharts \
    qtmultimedia \
    qt5compat \
"

RDEPENDS:${PN} = " \
    qtbase \
    qtdeclarative \
    qtserialbus \
    qtserialport \
    qtsvg \
    qtcharts \
    qtmultimedia \
    qt5compat \
"

EXTRA_OECMAKE = " \
    -DCMAKE_BUILD_TYPE=Release \
    -DFORCE_DDCUTIL=ON \
"

do_install() {
    install -d ${D}/opt/PowerTune
    install -m 0755 ${B}/PowerTuneQMLGui ${D}/opt/PowerTune/PowerTuneQMLGui
}

FILES:${PN} = "/opt/PowerTune"
