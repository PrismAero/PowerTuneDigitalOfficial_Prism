TEMPLATE = app

QT += qml quick serialport serialbus network charts location positioning sensors multimedia widgets

CONFIG += c++11

# QMAKE_LFLAGS += -static
# Check for the existence of ddcutil headers
exists(/usr/lib/libddcutil.so.4) {
    DEFINES += HAVE_DDCUTIL
}
static {
    QT += svg
    QTPLUGIN += qtvirtualkeyboardplugin
}

# * Include paths for organized directory structure
INCLUDEPATH += \
    Core \
    ECU \
    Hardware \
    Utils

SOURCES += main.cpp \
    Core/connect.cpp \
    Core/dashboard.cpp \
    Core/serialport.cpp \
    Core/appsettings.cpp \
    ECU/Apexi.cpp \
    ECU/AdaptronicSelect.cpp \
    ECU/arduino.cpp \
    Hardware/Extender.cpp \
    Hardware/gopro.cpp \
    Hardware/gps.cpp \
    Hardware/sensors.cpp \
    Utils/DataLogger.cpp \
    Utils/Calculations.cpp \
    Utils/downloadmanager.cpp \
    Utils/iomapdata.cpp \
    Utils/ParseGithubData.cpp \
    Utils/shcalc.cpp \
    Utils/textprogressbar.cpp \
    Utils/UDPReceiver.cpp \
    Utils/wifiscanner.cpp \
    Utils/Speedo.cpp


RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = QML Gauges Settings GPSTracks

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    Core/connect.h \
    Core/dashboard.h \
    Core/serialport.h \
    Core/appsettings.h \
    ECU/Apexi.h \
    ECU/AdaptronicSelect.h \
    ECU/arduino.h \
    ECU/obd.h \
    Hardware/Extender.h \
    Hardware/gopro.h \
    Hardware/gps.h \
    Hardware/sensors.h \
    Utils/DataLogger.h \
    Utils/Calculations.h \
    Utils/downloadmanager.h \
    Utils/iomapdata.h \
    Utils/ParseGithubData.h \
    Utils/shcalc.h \
    Utils/textprogressbar.h \
    Utils/UDPReceiver.h \
    Utils/wifiscanner.h


FORMS +=

DISTFILES += \
    Resources/KTracks/Australia/KimTestTrack - Copy.txt \
    Resources/KTracks/Australia/stupid2.txt \
    Resources/KTracks/Australia/stupid3.txt \
    Resources/KTracks/Australia/stupid4.txt

