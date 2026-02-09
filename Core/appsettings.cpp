#include "appsettings.h"

#include "dashboard.h"
#include "Models/DataModels.h"

#include <QDebug>
#include <QNetworkInterface>
#include <QSettings>

AppSettings::AppSettings(QObject *parent)
    : QObject(parent)
    , m_dashboard(nullptr)
    , m_settingsData(nullptr)
    , m_uiState(nullptr)
    , m_vehicleData(nullptr)
    , m_analogInputs(nullptr)
    , m_expanderBoardData(nullptr)
    , m_engineData(nullptr)
    , m_connectionData(nullptr)
    , m_digitalInputs(nullptr)
{
}

AppSettings::AppSettings(DashBoard *dashboard, QObject *parent)
    : QObject(parent)
    , m_dashboard(dashboard)
    , m_settingsData(nullptr)
    , m_uiState(nullptr)
    , m_vehicleData(nullptr)
    , m_analogInputs(nullptr)
    , m_expanderBoardData(nullptr)
    , m_engineData(nullptr)
    , m_connectionData(nullptr)
    , m_digitalInputs(nullptr)
{
}

AppSettings::AppSettings(DashBoard *dashboard, SettingsData *settingsData, UIState *uiState, VehicleData *vehicleData,
                         AnalogInputs *analogInputs, ExpanderBoardData *expanderBoardData,
                         EngineData *engineData, ConnectionData *connectionData,
                         DigitalInputs *digitalInputs, QObject *parent)
    : QObject(parent)
    , m_dashboard(dashboard)
    , m_settingsData(settingsData)
    , m_uiState(uiState)
    , m_vehicleData(vehicleData)
    , m_analogInputs(analogInputs)
    , m_expanderBoardData(expanderBoardData)
    , m_engineData(engineData)
    , m_connectionData(connectionData)
    , m_digitalInputs(digitalInputs)
{
}

AppSettings::~AppSettings() = default;

int AppSettings::getBaudRate()
{
    return getValue("serial/baudrate").toInt();
}

void AppSettings::setBaudRate(const int &arg)
{
    setValue("serial/baudrate", arg);
}

int AppSettings::getParity()
{
    return getValue("serial/parity").toInt();
}

void AppSettings::setParity(const int &arg)
{
    setValue("serial/parity", arg);
}

int AppSettings::getDataBits()
{
    return getValue("serial/databits").toInt();
}

void AppSettings::setDataBits(const int &arg)
{
    setValue("serial/databits", arg);
}

int AppSettings::getStopBits()
{
    return getValue("serial/stopbits").toInt();
}

void AppSettings::setStopBits(const int &arg)
{
    setValue("serial/stopbits", arg);
}

int AppSettings::getFlowControl()
{
    return getValue("serial/flowcontrol").toInt();
}

void AppSettings::setFlowControl(const int &arg)
{
    setValue("serial/flowcontrol", arg);
}

int AppSettings::getECU()
{
    return getValue("serial/ECU").toInt();
}

void AppSettings::setECU(const int &arg)
{
    setValue("serial/ECU", arg);
}

int AppSettings::getInterface()
{
    return getValue("serial/Interface").toInt();
}

void AppSettings::setInterface(const int &arg)
{
    setValue("serial/Interface", arg);
}

int AppSettings::getLogging()
{
    return getValue("serial/Logging").toInt();
}

void AppSettings::setLogging(const int &arg)
{
    setValue("serial/Logging", arg);
}

void AppSettings::setValue(const QString &key, const QVariant &value)
{
    QSettings settings("PowerTuneQML", "PowerTuneDash", this);
    settings.setValue(key, value);
}

QVariant AppSettings::getValue(const QString &key)
{
    QSettings settings("PowerTuneQML", "PowerTuneDash", this);
    return settings.value(key);
}

void AppSettings::writeMainSettings()
{
    // To be implemented later
}

void AppSettings::writeSelectedDashSettings(int numberofdashes)
{
    setValue("Number of Dashes", numberofdashes);
}

void AppSettings::externalspeedconnectionstatus(int connected)
{
    setValue("externalspeedconnect", connected);
    if (m_connectionData) {
        m_connectionData->setexternalspeedconnectionrequest(connected);
    }
}

void AppSettings::externalspeedport(const QString &port)
{
    setValue("externalspeedport", port);
    if (m_connectionData) {
        m_connectionData->setexternalspeedport(port);
    }
}

void AppSettings::writeWarnGearSettings(const qreal &waterwarn, const qreal &boostwarn, const qreal &rpmwarn,
                                        const qreal &knockwarn, const int &gercalactive, const qreal &lambdamultiply,
                                        const qreal &valgear1, const qreal &valgear2, const qreal &valgear3,
                                        const qreal &valgear4, const qreal &valgear5, const qreal &valgear6)
{
    setValue("waterwarn", waterwarn);
    setValue("boostwarn", boostwarn);
    setValue("rpmwarn", rpmwarn);
    setValue("knockwarn", knockwarn);
    setValue("gercalactive", gercalactive);
    setValue("lambdamultiply", lambdamultiply);
    setValue("valgear1", valgear1);
    setValue("valgear2", valgear2);
    setValue("valgear3", valgear3);
    setValue("valgear4", valgear4);
    setValue("valgear5", valgear5);
    setValue("valgear6", valgear6);

    if (m_settingsData) {
        m_settingsData->setwaterwarn(static_cast<int>(waterwarn));
        m_settingsData->setboostwarn(boostwarn);
        m_settingsData->setrpmwarn(static_cast<int>(rpmwarn));
        m_settingsData->setknockwarn(static_cast<int>(knockwarn));
        m_settingsData->setgearcalcactivation(gercalactive);
        m_settingsData->setgearcalc1(static_cast<int>(valgear1));
        m_settingsData->setgearcalc2(static_cast<int>(valgear2));
        m_settingsData->setgearcalc3(static_cast<int>(valgear3));
        m_settingsData->setgearcalc4(static_cast<int>(valgear4));
        m_settingsData->setgearcalc5(static_cast<int>(valgear5));
        m_settingsData->setgearcalc6(static_cast<int>(valgear6));
    }
    if (m_engineData) {
        m_engineData->setLambdamultiply(lambdamultiply);
    }
}

void AppSettings::writeSpeedSettings(const qreal &Speedcorrection, const qreal &Pulsespermile)
{
    setValue("Speedcorrection", Speedcorrection);
    setValue("Pulsespermile", Pulsespermile);
    if (m_settingsData) {
        m_settingsData->setspeedpercent(Speedcorrection);
        m_settingsData->setpulsespermile(Pulsespermile);
    }
}

void AppSettings::writeAnalogSettings(const qreal &A00, const qreal &A05, const qreal &A10, const qreal &A15,
                                      const qreal &A20, const qreal &A25, const qreal &A30, const qreal &A35,
                                      const qreal &A40, const qreal &A45, const qreal &A50, const qreal &A55,
                                      const qreal &A60, const qreal &A65, const qreal &A70, const qreal &A75,
                                      const qreal &A80, const qreal &A85, const qreal &A90, const qreal &A95,
                                      const qreal &A100, const qreal &A105)
{
    setValue("AN00", A00);
    setValue("AN05", A05);
    setValue("AN10", A10);
    setValue("AN15", A15);
    setValue("AN20", A20);
    setValue("AN25", A25);
    setValue("AN30", A30);
    setValue("AN35", A35);
    setValue("AN40", A40);
    setValue("AN45", A45);
    setValue("AN50", A50);
    setValue("AN55", A55);
    setValue("AN60", A60);
    setValue("AN65", A65);
    setValue("AN70", A70);
    setValue("AN75", A75);
    setValue("AN80", A80);
    setValue("AN85", A85);
    setValue("AN90", A90);
    setValue("AN95", A95);
    setValue("AN100", A100);
    setValue("AN105", A105);

    // Analog input configuration is stored in QSettings
    // Individual analog values are set via UDPReceiver/ECU directly to AnalogInputs model
}

void AppSettings::writeRPMSettings(const int &mxrpm, const int &shift1, const int &shift2, const int &shift3,
                                   const int &shift4)
{
    setValue("Max RPM", mxrpm);
    setValue("Shift Light1", shift1);
    setValue("Shift Light2", shift2);
    setValue("Shift Light3", shift3);
    setValue("Shift Light4", shift4);
    if (m_settingsData) {
        m_settingsData->setmaxRPM(mxrpm);
        m_settingsData->setrpmStage1(shift1);
        m_settingsData->setrpmStage2(shift2);
        m_settingsData->setrpmStage3(shift3);
        m_settingsData->setrpmStage4(shift4);
    }
}

void AppSettings::writeEXBoardSettings(const qreal &EXA00, const qreal &EXA05, const qreal &EXA10, const qreal &EXA15,
                                       const qreal &EXA20, const qreal &EXA25, const qreal &EXA30, const qreal &EXA35,
                                       const qreal &EXA40, const qreal &EXA45, const qreal &EXA50, const qreal &EXA55,
                                       const qreal &EXA60, const qreal &EXA65, const qreal &EXA70, const qreal &EXA75,
                                       const int &steinhartcalc0on, const int &steinhartcalc1on,
                                       const int &steinhartcalc2on, const int &steinhartcalc3on,
                                       const int &steinhartcalc4on, const int &steinhartcalc5on, const int &AN0R3VAL,
                                       const int &AN0R4VAL, const int &AN1R3VAL, const int &AN1R4VAL,
                                       const int &AN2R3VAL, const int &AN2R4VAL, const int &AN3R3VAL,
                                       const int &AN3R4VAL, const int &AN4R3VAL, const int &AN4R4VAL,
                                       const int &AN5R3VAL, const int &AN5R4VAL)
{
    setValue("EXA00", EXA00);
    setValue("EXA05", EXA05);
    setValue("EXA10", EXA10);
    setValue("EXA15", EXA15);
    setValue("EXA20", EXA20);
    setValue("EXA25", EXA25);
    setValue("EXA30", EXA30);
    setValue("EXA35", EXA35);
    setValue("EXA40", EXA40);
    setValue("EXA45", EXA45);
    setValue("EXA50", EXA50);
    setValue("EXA55", EXA55);
    setValue("EXA60", EXA60);
    setValue("EXA65", EXA65);
    setValue("EXA70", EXA70);
    setValue("EXA75", EXA75);
    setValue("steinhartcalc0on", steinhartcalc0on);
    setValue("steinhartcalc1on", steinhartcalc1on);
    setValue("steinhartcalc2on", steinhartcalc2on);
    setValue("steinhartcalc3on", steinhartcalc3on);
    setValue("steinhartcalc4on", steinhartcalc4on);
    setValue("steinhartcalc5on", steinhartcalc5on);
    setValue("AN0R3VAL", AN0R3VAL);
    setValue("AN0R4VAL", AN0R4VAL);
    setValue("AN1R3VAL", AN1R3VAL);
    setValue("AN1R4VAL", AN1R4VAL);
    setValue("AN2R3VAL", AN2R3VAL);
    setValue("AN2R4VAL", AN2R4VAL);
    setValue("AN3R3VAL", AN3R3VAL);
    setValue("AN3R4VAL", AN3R4VAL);
    setValue("AN4R3VAL", AN4R3VAL);
    setValue("AN4R4VAL", AN4R4VAL);
    setValue("AN5R3VAL", AN5R3VAL);
    setValue("AN5R4VAL", AN5R4VAL);

    // Expander board configuration is stored in QSettings
    // Individual values are set via Extender directly to ExpanderBoardData model
}

void AppSettings::writeEXAN7dampingSettings(const int &AN7damping)
{
    setValue("AN7Damping", AN7damping);
    if (m_settingsData) {
        m_settingsData->setsmootexAnalogInput7(AN7damping);
    }
}

void AppSettings::writeSteinhartSettings(const qreal &T01, const qreal &T02, const qreal &T03, const qreal &R01,
                                         const qreal &R02, const qreal &R03, const qreal &T11, const qreal &T12,
                                         const qreal &T13, const qreal &R11, const qreal &R12, const qreal &R13,
                                         const qreal &T21, const qreal &T22, const qreal &T23, const qreal &R21,
                                         const qreal &R22, const qreal &R23, const qreal &T31, const qreal &T32,
                                         const qreal &T33, const qreal &R31, const qreal &R32, const qreal &R33,
                                         const qreal &T41, const qreal &T42, const qreal &T43, const qreal &R41,
                                         const qreal &R42, const qreal &R43, const qreal &T51, const qreal &T52,
                                         const qreal &T53, const qreal &R51, const qreal &R52, const qreal &R53)
{
    setValue("T01", T01);
    setValue("T02", T02);
    setValue("T03", T03);
    setValue("R01", R01);
    setValue("R02", R02);
    setValue("R03", R03);
    setValue("T11", T11);
    setValue("T12", T12);
    setValue("T13", T13);
    setValue("R11", R11);
    setValue("R12", R12);
    setValue("R13", R13);
    setValue("T21", T21);
    setValue("T22", T22);
    setValue("T23", T23);
    setValue("R21", R21);
    setValue("R22", R22);
    setValue("R23", R23);
    setValue("T31", T31);
    setValue("T32", T32);
    setValue("T33", T33);
    setValue("R31", R31);
    setValue("R32", R32);
    setValue("R33", R33);
    setValue("T41", T41);
    setValue("T42", T42);
    setValue("T43", T43);
    setValue("R41", R41);
    setValue("R42", R42);
    setValue("R43", R43);
    setValue("T51", T51);
    setValue("T52", T52);
    setValue("T53", T53);
    setValue("R51", R51);
    setValue("R52", R52);
    setValue("R53", R53);

    // Steinhart coefficients are stored in QSettings and used by SteinhartCalculator
}

void AppSettings::writeCylinderSettings(const qreal &Cylinders)
{
    setValue("Cylinders", Cylinders);
    if (m_engineData) {
        m_engineData->setCylinders(Cylinders);
    }
}

void AppSettings::writeCountrySettings(const QString &Country)
{
    setValue("Country", Country);
    if (m_settingsData) {
        m_settingsData->setCBXCountrysave(Country);
    }
}

void AppSettings::writeTrackSettings(const QString &Track)
{
    setValue("Track", Track);
    if (m_settingsData) {
        m_settingsData->setCBXTracksave(Track);
    }
}

void AppSettings::writebrightnessettings(const int &Brightness)
{
    setValue("Brightness", Brightness);
    if (m_uiState) {
        m_uiState->setBrightness(Brightness);
    }
}

void AppSettings::writeStartupSettings(const int &ExternalSpeed)
{
    setValue("ExternalSpeed", ExternalSpeed);
    if (m_settingsData) {
        m_settingsData->setExternalSpeed(ExternalSpeed);
    }
}

void AppSettings::writeDaemonLicenseKey(const QString &DaemonLicenseKey)
{
    setValue("DaemonLicenseKey", DaemonLicenseKey);
    if (m_settingsData) {
        m_settingsData->setdaemonlicense(DaemonLicenseKey);
    }
}

void AppSettings::writeHolleyProductID(const QString &HolleyProductID)
{
    setValue("HolleyProductID", HolleyProductID);
    if (m_settingsData) {
        m_settingsData->setholleyproductid(HolleyProductID);
    }
}

QString AppSettings::getDaemonActivationKey()
{
    QNetworkInterface interface = QNetworkInterface::interfaceFromName("eth0");
    QString mac = interface.hardwareAddress();
    QStringList parts = mac.split(":");
    if (parts.size() == 6) {
        bool ok;
        int octet3 = parts[3].toInt(&ok, 16);
        int octet4 = parts[4].toInt(&ok, 16);
        int octet5 = parts[5].toInt(&ok, 16);

        if (ok) {
            QString strOctet3 = QString("%1").arg(octet3, 3, 10, QChar('0'));
            QString strOctet4 = QString("%1").arg(octet4, 3, 10, QChar('0'));
            QString strOctet5 = QString("%1").arg(octet5, 3, 10, QChar('0'));

            return strOctet3 + "-" + strOctet4 + "-" + strOctet5;
        }
    }
    return "000-000-000";
}

void AppSettings::writeRPMFrequencySettings(const qreal &Divider, const int &DI1isRPM)
{
    setValue("RPMFrequencyDivider", Divider);
    setValue("DI1RPMEnabled", DI1isRPM);
    if (m_digitalInputs) {
        m_digitalInputs->setRPMFrequencyDividerDi1(Divider);
        m_digitalInputs->setDI1RPMEnabled(DI1isRPM);
    }
}

void AppSettings::writeExternalrpm(const int checked)
{
    setValue("ExternalRPM", checked);
    if (m_settingsData) {
        m_settingsData->setExternalrpm(checked);
    }
}

void AppSettings::writeLanguage(const int Language)
{
    setValue("Language", Language);
    if (m_settingsData) {
        m_settingsData->setlanguage(Language);
    }
}

void AppSettings::readandApplySettings()
{
    // RPM settings
    if (m_settingsData) {
        m_settingsData->setmaxRPM(getValue("Max RPM").toInt());
        m_settingsData->setrpmStage1(getValue("Shift Light1").toInt());
        m_settingsData->setrpmStage2(getValue("Shift Light2").toInt());
        m_settingsData->setrpmStage3(getValue("Shift Light3").toInt());
        m_settingsData->setrpmStage4(getValue("Shift Light4").toInt());
        m_settingsData->setsmootexAnalogInput7(getValue("AN7Damping").toInt());
    }

    // Warning thresholds
    if (m_settingsData) {
        qreal waterwarn = getValue("waterwarn").toReal();
        m_settingsData->setwaterwarn(static_cast<int>(waterwarn <= 0 ? 400 : waterwarn));

        qreal boostwarn = getValue("boostwarn").toReal();
        m_settingsData->setboostwarn(boostwarn <= 0 ? 999 : boostwarn);

        qreal rpmwarn = getValue("rpmwarn").toReal();
        m_settingsData->setrpmwarn(static_cast<int>(rpmwarn <= 0 ? 99999 : rpmwarn));

        qreal knockwarn = getValue("knockwarn").toReal();
        m_settingsData->setknockwarn(static_cast<int>(knockwarn <= 0 ? 99999 : knockwarn));

        m_settingsData->setgearcalcactivation(getValue("gercalactive").toInt());
    }

    // Lambda multiplier
    if (m_engineData) {
        m_engineData->setLambdamultiply(getValue("lambdamultiply").toReal());
    }

    // Gear calculation settings
    if (m_settingsData) {
        m_settingsData->setgearcalc1(static_cast<int>(getValue("valgear1").toReal()));
        m_settingsData->setgearcalc2(static_cast<int>(getValue("valgear2").toReal()));
        m_settingsData->setgearcalc3(static_cast<int>(getValue("valgear3").toReal()));
        m_settingsData->setgearcalc4(static_cast<int>(getValue("valgear4").toReal()));
        m_settingsData->setgearcalc5(static_cast<int>(getValue("valgear5").toReal()));
        m_settingsData->setgearcalc6(static_cast<int>(getValue("valgear6").toReal()));
    }

    // Cylinder count
    if (m_engineData) {
        m_engineData->setCylinders(getValue("Cylinders").toReal());
    }

    // External speed setting
    if (m_settingsData) {
        m_settingsData->setExternalSpeed(getValue("ExternalSpeed").toInt());
    }

    // Country and track
    if (m_settingsData) {
        m_settingsData->setCBXCountrysave(getValue("Country").toString());
        m_settingsData->setCBXTracksave(getValue("Track").toString());
    }

    // Brightness
    if (m_uiState) {
        m_uiState->setBrightness(getValue("Brightness").toInt());
    }

    // RPM frequency settings
    if (m_digitalInputs) {
        m_digitalInputs->setRPMFrequencyDividerDi1(getValue("RPMFrequencyDivider").toReal());
        m_digitalInputs->setDI1RPMEnabled(getValue("DI1RPMEnabled").toInt());
    }

    // Speed settings
    if (m_settingsData) {
        qreal speedPercent = getValue("Speedcorrection").toReal();
        m_settingsData->setspeedpercent(speedPercent <= 0 ? 1 : speedPercent);

        qreal pulsesPerMile = getValue("Pulsespermile").toReal();
        m_settingsData->setpulsespermile(pulsesPerMile <= 0 ? 100000 : pulsesPerMile);
    }

    // External RPM setting
    if (m_settingsData) {
        m_settingsData->setExternalrpm(getValue("ExternalRPM").toInt());
    }

    // External speed connection
    if (m_connectionData) {
        m_connectionData->setexternalspeedconnectionrequest(getValue("externalspeedconnect").toInt());
        m_connectionData->setexternalspeedport(getValue("externalspeedport").toString());
    }

    // Daemon and product IDs
    if (m_settingsData) {
        m_settingsData->setdaemonlicense(getValue("DaemonLicenseKey").toString());
        m_settingsData->setholleyproductid(getValue("HolleyProductID").toString());
    }
}
