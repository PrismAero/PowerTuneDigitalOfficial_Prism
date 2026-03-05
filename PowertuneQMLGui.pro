TEMPLATE = app

QT += qml quick serialbus network widgets

CONFIG += c++11

# QMAKE_LFLAGS += -static
# Check for the existence of ddcutil headers
exists(/usr/lib/libddcutil.so.4) {
    DEFINES += HAVE_DDCUTIL
}
static {
    QT += svg
}

# * Include paths for organized directory structure
INCLUDEPATH += \
    Core \
    Core/Models \
    Hardware \
    Utils

SOURCES += main.cpp \
    Core/connect.cpp \
    Core/dashboard.cpp \
    Core/appsettings.cpp \
    Core/Models/EngineData.cpp \
    Core/Models/VehicleData.cpp \
    Core/Models/GPSData.cpp \
    Core/Models/AnalogInputs.cpp \
    Core/Models/DigitalInputs.cpp \
    Core/Models/ExpanderBoardData.cpp \
    Core/Models/ElectricMotorData.cpp \
    Core/Models/FlagsData.cpp \
    Core/Models/TimingData.cpp \
    Hardware/Extender.cpp \
    Utils/DataLogger.cpp \
    Utils/Calculations.cpp \
    Utils/downloadmanager.cpp \
    Utils/ParseGithubData.cpp \
    Utils/shcalc.cpp \
    Utils/textprogressbar.cpp \
    Utils/UDPReceiver.cpp \
    Utils/wifiscanner.cpp


RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = QML Gauges Settings GPSTracks

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    Core/connect.h \
    Core/dashboard.h \
    Core/appsettings.h \
    Core/Models/DataModels.h \
    Core/Models/EngineData.h \
    Core/Models/VehicleData.h \
    Core/Models/GPSData.h \
    Core/Models/AnalogInputs.h \
    Core/Models/DigitalInputs.h \
    Core/Models/ExpanderBoardData.h \
    Core/Models/ElectricMotorData.h \
    Core/Models/FlagsData.h \
    Core/Models/TimingData.h \
    Hardware/Extender.h \
    Utils/DataLogger.h \
    Utils/Calculations.h \
    Utils/downloadmanager.h \
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

