#include "appsettings.h"

#include "AppConstants.h"
#include "../Hardware/Extender.h"
#include "../Utils/SteinhartCalculator.h"
#include "Models/DataModels.h"

#include <QDebug>
#include <QSettings>

#include <iterator>

static constexpr int ECU_DROPDOWN_TO_BACKEND[] = {5, 0, 4};

AppSettings::AppSettings(QObject *parent)
    : QObject(parent),
      m_settingsData(nullptr),
      m_uiState(nullptr),
      m_vehicleData(nullptr),
      m_analogInputs(nullptr),
      m_expanderBoardData(nullptr),
      m_engineData(nullptr),
      m_connectionData(nullptr),
      m_digitalInputs(nullptr),
      m_settings(AppConstants::ORG_NAME, AppConstants::APP_NAME)
{
    m_syncTimer.setSingleShot(true);
    m_syncTimer.setInterval(500);
    connect(&m_syncTimer, &QTimer::timeout, this, &AppSettings::flushToDisk);
    preloadCache();
}

AppSettings::AppSettings(SettingsData *settingsData, UIState *uiState, VehicleData *vehicleData, AnalogInputs *analogInputs,
                         ExpanderBoardData *expanderBoardData, EngineData *engineData, ConnectionData *connectionData,
                         DigitalInputs *digitalInputs, QObject *parent)
    : QObject(parent),
      m_settingsData(settingsData),
      m_uiState(uiState),
      m_vehicleData(vehicleData),
      m_analogInputs(analogInputs),
      m_expanderBoardData(expanderBoardData),
      m_engineData(engineData),
      m_connectionData(connectionData),
      m_digitalInputs(digitalInputs),
      m_settings(AppConstants::ORG_NAME, AppConstants::APP_NAME)
{
    m_syncTimer.setSingleShot(true);
    m_syncTimer.setInterval(500);
    connect(&m_syncTimer, &QTimer::timeout, this, &AppSettings::flushToDisk);
    preloadCache();
}

AppSettings::~AppSettings() = default;

void AppSettings::setValue(const QString &key, const QVariant &value)
{
    const auto existing = m_cache.constFind(key);
    if (existing != m_cache.constEnd() && existing.value() == value)
        return;

    m_cache.insert(key, value);
    m_settings.setValue(key, value);
    m_dirty = true;
    scheduleSync();
}

QVariant AppSettings::getValue(const QString &key, const QVariant &defaultValue) const
{
    auto cached = m_cache.constFind(key);
    if (cached != m_cache.constEnd())
        return cached.value();

    const QVariant value = m_settings.value(key, defaultValue);
    m_cache.insert(key, value);
    return value;
}

void AppSettings::sync()
{
    m_syncTimer.stop();
    flushToDisk();
}

void AppSettings::preloadCache()
{
    if (m_cacheLoaded)
        return;

    const QStringList keys = m_settings.allKeys();
    for (const QString &key : keys)
        m_cache.insert(key, m_settings.value(key));
    m_cacheLoaded = true;
}

void AppSettings::scheduleSync()
{
    m_syncTimer.start();
}

void AppSettings::flushToDisk()
{
    if (!m_dirty)
        return;
    m_settings.sync();
    m_dirty = false;
}

void AppSettings::setSpeedUnitIndex(int index)
{
    setValue(QStringLiteral("ui/unitSelector1"), index);

    if (!m_settingsData)
        return;

    switch (index) {
    case 0:
        m_settingsData->setspeedunits(QStringLiteral("metric"));
        break;
    case 1:
        m_settingsData->setspeedunits(QStringLiteral("imperial"));
        break;
    default:
        break;
    }
}

void AppSettings::setTempUnitIndex(int index)
{
    setValue(QStringLiteral("ui/unitSelector"), index);

    if (!m_settingsData)
        return;

    switch (index) {
    case 0:
        m_settingsData->setunits(QStringLiteral("metric"));
        break;
    case 1:
        m_settingsData->setunits(QStringLiteral("imperial"));
        break;
    default:
        break;
    }
}

void AppSettings::setPressureUnitIndex(int index)
{
    setValue(QStringLiteral("ui/unitSelector2"), index);

    if (!m_settingsData)
        return;

    switch (index) {
    case 0:
        m_settingsData->setpressureunits(QStringLiteral("metric"));
        break;
    case 1:
        m_settingsData->setpressureunits(QStringLiteral("imperial"));
        break;
    default:
        break;
    }
}

void AppSettings::setEcuIndex(int index)
{
    if (index < 0 || index >= static_cast<int>(std::size(ECU_DROPDOWN_TO_BACKEND)))
        return;

    const int backendIndex = ECU_DROPDOWN_TO_BACKEND[index];
    setECU(backendIndex);

    if (m_connectionData)
        m_connectionData->setecu(backendIndex);
}

void AppSettings::setMainSpeedSourceIndex(int index)
{
    setValue(QStringLiteral("ui/mainSpeedSource"), index);
    writeStartupSettings(index);
}

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

    if (m_extender) {
        const qreal v0v[] = {EXA00, EXA10, EXA20, EXA30, EXA40, EXA50, EXA60, EXA70};
        const qreal v5v[] = {EXA05, EXA15, EXA25, EXA35, EXA45, EXA55, EXA65, EXA75};
        const int ntcFlags[] = {steinhartcalc0on,
                                steinhartcalc1on,
                                steinhartcalc2on,
                                steinhartcalc3on,
                                steinhartcalc4on,
                                steinhartcalc5on,
                                0,
                                0};
        for (int ch = 0; ch < EX_ANALOG_CHANNELS; ++ch) {
            const qreal minV = getValue(QStringLiteral("ui/exboard/ch%1_minVoltage").arg(ch), 0.0).toDouble();
            const qreal maxV = getValue(QStringLiteral("ui/exboard/ch%1_maxVoltage").arg(ch), 5.0).toDouble();
            m_extender->setChannelCalibration(ch, v0v[ch], v5v[ch], ntcFlags[ch] != 0, minV, maxV);
        }
    }

    if (m_steinhartCalc) {
        const int ntcOn[] = {steinhartcalc0on, steinhartcalc1on, steinhartcalc2on,
                             steinhartcalc3on, steinhartcalc4on, steinhartcalc5on};
        const int r3Vals[] = {AN0R3VAL, AN1R3VAL, AN2R3VAL, AN3R3VAL, AN4R3VAL, AN5R3VAL};
        const int r4Vals[] = {AN0R4VAL, AN1R4VAL, AN2R4VAL, AN3R4VAL, AN4R4VAL, AN5R4VAL};
        for (int ch = 0; ch < SteinhartCalculator::MAX_CHANNELS; ++ch) {
            m_steinhartCalc->setChannelEnabled(ch, ntcOn[ch] != 0);
            qreal r3 = (r3Vals[ch] != 0) ? 100.0 : 0.0;
            qreal r4 = (r4Vals[ch] != 0) ? 1000.0 : 0.0;
            m_steinhartCalc->setVoltageDividerParams(ch, r3, r4);
        }
    }
}

void AppSettings::applyEXBoardCalibration(const QVariantList &channels)
{
    if (!m_extender && !m_steinhartCalc)
        return;

    const int channelCount = qMin(channels.size(), EX_ANALOG_CHANNELS);
    for (int ch = 0; ch < channelCount; ++ch) {
        const QVariantMap channel = channels.at(ch).toMap();
        const qreal val0 = channel.value(QStringLiteral("val0v"), 0.0).toDouble();
        const qreal val5 = channel.value(QStringLiteral("val5v"), 5.0).toDouble();
        const qreal minVoltage = channel.value(QStringLiteral("minVoltage"), 0.0).toDouble();
        const qreal maxVoltage = channel.value(QStringLiteral("maxVoltage"), 5.0).toDouble();
        const bool ntcEnabled = channel.value(QStringLiteral("ntcEnabled"), false).toBool();

        if (m_extender)
            m_extender->setChannelCalibration(ch, val0, val5, ntcEnabled, minVoltage, maxVoltage);

        if (!m_steinhartCalc || ch >= SteinhartCalculator::MAX_CHANNELS)
            continue;

        m_steinhartCalc->setChannelEnabled(ch, ntcEnabled);

        const QVariantList steinhartT = channel.value(QStringLiteral("steinhartT")).toList();
        const QVariantList steinhartR = channel.value(QStringLiteral("steinhartR")).toList();
        if (steinhartT.size() >= 3 && steinhartR.size() >= 3) {
            const qreal t1 = steinhartT.at(0).toDouble();
            const qreal t2 = steinhartT.at(1).toDouble();
            const qreal t3 = steinhartT.at(2).toDouble();
            const qreal r1 = steinhartR.at(0).toDouble();
            const qreal r2 = steinhartR.at(1).toDouble();
            const qreal r3 = steinhartR.at(2).toDouble();
            if (r1 > 0 && r2 > 0 && r3 > 0)
                m_steinhartCalc->calibrateChannel(ch, t1, t2, t3, r1, r2, r3);
        }

        const qreal divider100 = channel.value(QStringLiteral("divider100"), false).toBool() ? 100.0 : 0.0;
        const qreal divider1k = channel.value(QStringLiteral("divider1k"), false).toBool() ? 1000.0 : 0.0;
        m_steinhartCalc->setVoltageDividerParams(ch, divider100, divider1k);
    }
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

    if (m_steinhartCalc) {
        const qreal T[][3] = {{T01, T02, T03}, {T11, T12, T13}, {T21, T22, T23},
                              {T31, T32, T33}, {T41, T42, T43}, {T51, T52, T53}};
        const qreal R[][3] = {{R01, R02, R03}, {R11, R12, R13}, {R21, R22, R23},
                              {R31, R32, R33}, {R41, R42, R43}, {R51, R52, R53}};
        for (int ch = 0; ch < SteinhartCalculator::MAX_CHANNELS; ++ch) {
            if (R[ch][0] > 0 && R[ch][1] > 0 && R[ch][2] > 0) {
                m_steinhartCalc->calibrateChannel(ch, T[ch][0], T[ch][1], T[ch][2], R[ch][0], R[ch][1], R[ch][2]);
            }
        }
    }
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

int AppSettings::readDisplayBrightnessPercent() const
{
    return qBound(0, getValue(QStringLiteral("ui/displayBrightnessPercent"), 100).toInt(), 100);
}

void AppSettings::writeDisplayBrightnessPercent(int percent)
{
    setValue(QStringLiteral("ui/displayBrightnessPercent"), qBound(0, percent, 100));
}

int AppSettings::readGlobalBrightnessPercent() const
{
    return qBound(0, getValue(QStringLiteral("ui/globalMaxBrightnessPercent"), 100).toInt(), 100);
}

void AppSettings::writeGlobalBrightnessPercent(int percent)
{
    setValue(QStringLiteral("ui/globalMaxBrightnessPercent"), qBound(0, percent, 100));
}

void AppSettings::writeBrightnessDayPreset(int percent)
{
    setValue(QStringLiteral("ui/brightnessDayPreset"), qBound(0, percent, 100));
}

void AppSettings::writeBrightnessNightPreset(int percent)
{
    setValue(QStringLiteral("ui/brightnessNightPreset"), qBound(0, percent, 100));
}

bool AppSettings::readBrightnessPopupEnabled() const
{
    return getValue(QStringLiteral("ui/brightnessPopupEnabled"), false).toBool();
}

void AppSettings::writeBrightnessPopupEnabled(bool enabled)
{
    setValue(QStringLiteral("ui/brightnessPopupEnabled"), enabled);
}

QString AppSettings::readLastBrightnessPreset() const
{
    const QString preset = getValue(QStringLiteral("ui/brightnessLastPreset"), QStringLiteral("day")).toString();
    return preset == QLatin1String("night") ? preset : QStringLiteral("day");
}

void AppSettings::writeLastBrightnessPreset(const QString &preset)
{
    setValue(QStringLiteral("ui/brightnessLastPreset"),
             preset == QLatin1String("night") ? QStringLiteral("night") : QStringLiteral("day"));
}

bool AppSettings::readDashboardLockEnabled() const
{
    return getValue(QStringLiteral("ui/dashboardLockEnabled"), false).toBool();
}

void AppSettings::writeDashboardLockEnabled(bool enabled)
{
    setValue(QStringLiteral("ui/dashboardLockEnabled"), enabled);
}

void AppSettings::writeStartupSettings(const int &ExternalSpeed)
{
    setValue("ExternalSpeed", ExternalSpeed);
    if (m_settingsData) {
        m_settingsData->setExternalSpeed(ExternalSpeed);
    }
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
    if (m_settingsData)
        m_settingsData->setExternalrpm(checked);
}

void AppSettings::writeRpmSource(int source)
{
    setValue("ui/exboard/rpmSource", source);
    setValue("ui/exboard/rpmSourceValue", source);
    if (m_extender)
        m_extender->setRpmSource(source);
}

void AppSettings::writeLanguage(const int Language)
{
    setValue("Language", Language);
    if (m_settingsData) {
        m_settingsData->setlanguage(Language);
    }
}

void AppSettings::writeDashboardConfig(int index, const QString &bgPicture, const QString &bgColor)
{
    QString prefix = QString("dashboard_%1/").arg(index);
    setValue(prefix + "backgroundPicture", bgPicture);
    setValue(prefix + "backgroundColor", bgColor);
}

QVariantMap AppSettings::loadDashboardConfig(int index) const
{
    QString prefix = QString("dashboard_%1/").arg(index);
    QVariantMap config;
    config["backgroundPicture"] = getValue(prefix + "backgroundPicture", "");
    config["backgroundColor"] = getValue(prefix + "backgroundColor", "#000000");
    return config;
}

void AppSettings::saveOverlayConfig(const QString &dashboardId, const QString &overlayId, const QVariantMap &config)
{
    const QString prefix = QStringLiteral("overlay/%1/%2/").arg(dashboardId, overlayId);
    for (auto it = config.constBegin(); it != config.constEnd(); ++it) {
        const QString fullKey = prefix + it.key();
        m_settings.setValue(fullKey, it.value());
        m_cache.insert(fullKey, it.value());
    }
    m_dirty = true;
    scheduleSync();
}

QVariantMap AppSettings::loadOverlayConfig(const QString &dashboardId, const QString &overlayId)
{
    QVariantMap config;
    const QString group = QStringLiteral("overlay/%1/%2").arg(dashboardId, overlayId);
    m_settings.beginGroup(group);
    const QStringList keys = m_settings.childKeys();
    for (const QString &key : keys) {
        const QVariant value = m_settings.value(key);
        config.insert(key, value);
        m_cache.insert(group + QLatin1Char('/') + key, value);
    }
    m_settings.endGroup();
    return config;
}

QVariantMap AppSettings::loadOverlayConfigs(const QString &dashboardId, const QStringList &overlayIds)
{
    QVariantMap allConfigs;
    for (const QString &overlayId : overlayIds) {
        QVariantMap config;
        const QString group = QStringLiteral("overlay/%1/%2").arg(dashboardId, overlayId);
        m_settings.beginGroup(group);
        const QStringList keys = m_settings.childKeys();
        for (const QString &key : keys) {
            const QVariant value = m_settings.value(key);
            config.insert(key, value);
            m_cache.insert(group + QLatin1Char('/') + key, value);
        }
        m_settings.endGroup();
        allConfigs.insert(overlayId, config);
    }
    return allConfigs;
}

void AppSettings::removeOverlayConfig(const QString &dashboardId, const QString &overlayId)
{
    const QString group = QStringLiteral("overlay/%1/%2").arg(dashboardId, overlayId);
    m_settings.beginGroup(group);
    m_settings.remove(QString());
    m_settings.endGroup();

    for (auto it = m_cache.begin(); it != m_cache.end();) {
        if (it.key().startsWith(group + QLatin1Char('/'))) {
            it = m_cache.erase(it);
        } else {
            ++it;
        }
    }

    m_dirty = true;
    scheduleSync();
}

// * Expander board sensor config persistence

void AppSettings::writeGearSensorConfig(const QVariantMap &config)
{
    static const char *prefix = "ui/exboard/gearSensor/";
    const QStringList keys = {"enabled",  "port",     "tolerance", "voltageN", "voltageR", "voltage1",
                              "voltage2", "voltage3", "voltage4",  "voltage5", "voltage6"};
    for (const QString &key : keys) {
        if (config.contains(key))
            setValue(QString(prefix) + key, config.value(key));
    }
    if (m_extender)
        m_extender->setGearVoltageConfig(config);
    if (m_settingsData)
        m_settingsData->setGearSourceExpander(config.value(QStringLiteral("enabled"), false).toBool());
}

QVariantMap AppSettings::readGearSensorConfig()
{
    static const char *prefix = "ui/exboard/gearSensor/";
    QVariantMap config;
    config["enabled"] = getValue(QString(prefix) + "enabled", false);
    config["port"] = getValue(QString(prefix) + "port", 0);
    config["tolerance"] = getValue(QString(prefix) + "tolerance", 0.2);
    config["voltageN"] = getValue(QString(prefix) + "voltageN", 0.0);
    config["voltageR"] = getValue(QString(prefix) + "voltageR", 0.5);
    config["voltage1"] = getValue(QString(prefix) + "voltage1", 1.0);
    config["voltage2"] = getValue(QString(prefix) + "voltage2", 1.5);
    config["voltage3"] = getValue(QString(prefix) + "voltage3", 2.0);
    config["voltage4"] = getValue(QString(prefix) + "voltage4", 2.5);
    config["voltage5"] = getValue(QString(prefix) + "voltage5", 3.0);
    config["voltage6"] = getValue(QString(prefix) + "voltage6", 3.5);
    return config;
}

void AppSettings::writeSpeedSensorConfig(const QVariantMap &config)
{
    static const char *prefix = "ui/exboard/speedSensor/";
    const QStringList keys = {"enabled",           "sourceType",      "analogPort",
                              "digitalPort",       "pulsesPerRev",    "voltageMultiplier",
                              "frequencyThreshold","frequencyHysteresis",
                              "tireCircumference", "finalDriveRatio", "unit"};
    for (const QString &key : keys) {
        if (config.contains(key))
            setValue(QString(prefix) + key, config.value(key));
    }
    if (m_extender)
        m_extender->setSpeedSensorConfig(config);
}

QVariantMap AppSettings::readSpeedSensorConfig()
{
    static const char *prefix = "ui/exboard/speedSensor/";
    QVariantMap config;
    config["enabled"] = getValue(QString(prefix) + "enabled", false);
    config["sourceType"] = getValue(QString(prefix) + "sourceType", "analog");
    config["analogPort"] = getValue(QString(prefix) + "analogPort", 0);
    config["digitalPort"] = getValue(QString(prefix) + "digitalPort", 0);
    config["pulsesPerRev"] = getValue(QString(prefix) + "pulsesPerRev", 4.0);
    config["voltageMultiplier"] = getValue(QString(prefix) + "voltageMultiplier", 1.0);
    config["frequencyThreshold"] = getValue(QString(prefix) + "frequencyThreshold", 1.2);
    config["frequencyHysteresis"] = getValue(QString(prefix) + "frequencyHysteresis", 0.2);
    config["tireCircumference"] = getValue(QString(prefix) + "tireCircumference", 2.06);
    config["finalDriveRatio"] = getValue(QString(prefix) + "finalDriveRatio", 1.0);
    config["unit"] = getValue(QString(prefix) + "unit", "MPH");
    return config;
}

void AppSettings::setExtender(Extender *extender)
{
    m_extender = extender;
}

void AppSettings::setSteinhartCalculator(SteinhartCalculator *calc)
{
    m_steinhartCalc = calc;
}

void AppSettings::readandApplySettings()
{
    if (m_settingsData) {
        m_settingsData->setmaxRPM(getValue("Max RPM").toInt());
        m_settingsData->setrpmStage1(getValue("Shift Light1").toInt());
        m_settingsData->setrpmStage2(getValue("Shift Light2").toInt());
        m_settingsData->setrpmStage3(getValue("Shift Light3").toInt());
        m_settingsData->setrpmStage4(getValue("Shift Light4").toInt());
        m_settingsData->setsmootexAnalogInput7(getValue("AN7Damping").toInt());
    }

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

    if (m_engineData) {
        m_engineData->setLambdamultiply(getValue("lambdamultiply").toReal());
    }

    if (m_settingsData) {
        m_settingsData->setgearcalc1(static_cast<int>(getValue("valgear1").toReal()));
        m_settingsData->setgearcalc2(static_cast<int>(getValue("valgear2").toReal()));
        m_settingsData->setgearcalc3(static_cast<int>(getValue("valgear3").toReal()));
        m_settingsData->setgearcalc4(static_cast<int>(getValue("valgear4").toReal()));
        m_settingsData->setgearcalc5(static_cast<int>(getValue("valgear5").toReal()));
        m_settingsData->setgearcalc6(static_cast<int>(getValue("valgear6").toReal()));
    }

    if (m_engineData) {
        m_engineData->setCylinders(getValue("Cylinders").toReal());
    }

    if (m_settingsData) {
        m_settingsData->setExternalSpeed(getValue("ExternalSpeed").toInt());
    }

    if (m_settingsData) {
        m_settingsData->setCBXCountrysave(getValue("Country").toString());
        m_settingsData->setCBXTracksave(getValue("Track").toString());
    }

    if (m_uiState) {
        m_uiState->setBrightness(getValue("Brightness").toInt());
    }

    if (m_digitalInputs) {
        m_digitalInputs->setRPMFrequencyDividerDi1(getValue("RPMFrequencyDivider").toReal());
        m_digitalInputs->setDI1RPMEnabled(getValue("DI1RPMEnabled").toInt());
    }

    if (m_settingsData) {
        qreal speedPercent = getValue("Speedcorrection").toReal();
        m_settingsData->setspeedpercent(speedPercent <= 0 ? 1 : speedPercent);

        qreal pulsesPerMile = getValue("Pulsespermile").toReal();
        m_settingsData->setpulsespermile(pulsesPerMile <= 0 ? 100000 : pulsesPerMile);
    }

    if (m_settingsData)
        m_settingsData->setExternalrpm(getValue("ExternalRPM").toInt());
    if (m_extender) {
        const int rpmSource = getValue("ui/exboard/rpmSource", getValue("ui/exboard/rpmSourceValue", 0)).toInt();
        m_extender->setRpmSource(rpmSource);
    }

    if (m_connectionData) {
        m_connectionData->setexternalspeedconnectionrequest(getValue("externalspeedconnect").toInt());
        m_connectionData->setexternalspeedport(getValue("externalspeedport").toString());
    }

    // Restore per-channel linear calibration values and NTC flags into the Extender
    if (m_extender) {
        const QString val0vKeys[] = {"EXA00", "EXA10", "EXA20", "EXA30", "EXA40", "EXA50", "EXA60", "EXA70"};
        const QString val5vKeys[] = {"EXA05", "EXA15", "EXA25", "EXA35", "EXA45", "EXA55", "EXA65", "EXA75"};
        const QString ntcKeys[] = {"steinhartcalc0on",
                                   "steinhartcalc1on",
                                   "steinhartcalc2on",
                                   "steinhartcalc3on",
                                   "steinhartcalc4on",
                                   "steinhartcalc5on",
                                   "",
                                   ""};

        for (int ch = 0; ch < EX_ANALOG_CHANNELS; ++ch) {
            qreal v0 = getValue(val0vKeys[ch], 0.0).toReal();
            qreal v5 = getValue(val5vKeys[ch], 5.0).toReal();
            bool ntc = (ch < 6) ? (getValue(ntcKeys[ch], 0).toInt() != 0) : false;
            qreal minV = getValue(QStringLiteral("ui/exboard/ch%1_minVoltage").arg(ch), 0.0).toReal();
            qreal maxV = getValue(QStringLiteral("ui/exboard/ch%1_maxVoltage").arg(ch), 5.0).toReal();
            m_extender->setChannelCalibration(ch, v0, v5, ntc, minV, maxV);
        }
    }

    // Restore Steinhart-Hart calibration coefficients and voltage divider jumper settings
    if (m_steinhartCalc) {
        const QString tKeys[][3] = {{"T01", "T02", "T03"}, {"T11", "T12", "T13"}, {"T21", "T22", "T23"},
                                    {"T31", "T32", "T33"}, {"T41", "T42", "T43"}, {"T51", "T52", "T53"}};
        const QString rKeys[][3] = {{"R01", "R02", "R03"}, {"R11", "R12", "R13"}, {"R21", "R22", "R23"},
                                    {"R31", "R32", "R33"}, {"R41", "R42", "R43"}, {"R51", "R52", "R53"}};
        const QString r3Keys[] = {"AN0R3VAL", "AN1R3VAL", "AN2R3VAL", "AN3R3VAL", "AN4R3VAL", "AN5R3VAL"};
        const QString r4Keys[] = {"AN0R4VAL", "AN1R4VAL", "AN2R4VAL", "AN3R4VAL", "AN4R4VAL", "AN5R4VAL"};
        const QString ntcOnKeys[] = {"steinhartcalc0on", "steinhartcalc1on", "steinhartcalc2on",
                                     "steinhartcalc3on", "steinhartcalc4on", "steinhartcalc5on"};

        for (int ch = 0; ch < SteinhartCalculator::MAX_CHANNELS; ++ch) {
            bool ntcOn = getValue(ntcOnKeys[ch], 0).toInt() != 0;
            m_steinhartCalc->setChannelEnabled(ch, ntcOn);

            qreal t1 = getValue(tKeys[ch][0]).toReal();
            qreal t2 = getValue(tKeys[ch][1]).toReal();
            qreal t3 = getValue(tKeys[ch][2]).toReal();
            qreal r1 = getValue(rKeys[ch][0]).toReal();
            qreal r2 = getValue(rKeys[ch][1]).toReal();
            qreal r3 = getValue(rKeys[ch][2]).toReal();

            if (r1 > 0 && r2 > 0 && r3 > 0) {
                m_steinhartCalc->calibrateChannel(ch, t1, t2, t3, r1, r2, r3);
            }

            int r3Jumper = getValue(r3Keys[ch], 0).toInt();
            int r4Jumper = getValue(r4Keys[ch], 0).toInt();
            qreal r3Val = (r3Jumper != 0) ? 100.0 : 0.0;
            qreal r4Val = (r4Jumper != 0) ? 1000.0 : 0.0;
            m_steinhartCalc->setVoltageDividerParams(ch, r3Val, r4Val);
        }
    }

    // Restore expander board gear and speed sensor configs into the Extender
    {
        QVariantMap gearConfig = readGearSensorConfig();
        if (m_extender)
            m_extender->setGearVoltageConfig(gearConfig);
        if (m_settingsData)
            m_settingsData->setGearSourceExpander(gearConfig.value(QStringLiteral("enabled"), false).toBool());

        QVariantMap speedConfig = readSpeedSensorConfig();
        if (m_extender)
            m_extender->setSpeedSensorConfig(speedConfig);
    }
}
