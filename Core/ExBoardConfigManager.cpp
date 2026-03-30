#include "ExBoardConfigManager.h"

#include "../Utils/CalibrationHelper.h"
#include "SensorRegistry.h"
#include "appsettings.h"

#include <algorithm>
#include <cmath>

namespace {
struct SensorMetadata
{
    QString unit;
    int decimals = 2;
    double maxValue = 100.0;
    double stepSize = 1.0;
};

double maxAbs(double a, double b)
{
    return std::max(std::fabs(a), std::fabs(b));
}

int decimalsForRange(double maxValue, const QString &unit)
{
    if (unit.compare(QStringLiteral("V"), Qt::CaseInsensitive) == 0 && maxValue <= 5.0)
        return 3;
    if (maxValue <= 10.0)
        return 2;
    if (maxValue <= 100.0)
        return 1;
    return 0;
}

double stepForRange(double maxValue, const QString &unit)
{
    if (unit.compare(QStringLiteral("V"), Qt::CaseInsensitive) == 0 && maxValue <= 5.0)
        return 0.1;
    if (maxValue <= 2.0)
        return 0.05;
    if (maxValue <= 10.0)
        return 0.1;
    if (maxValue <= 25.0)
        return 0.5;
    if (maxValue <= 100.0)
        return 1.0;
    if (maxValue <= 400.0)
        return 5.0;
    return 10.0;
}
}  // namespace

const QString ExBoardConfigManager::s_linearKeys[kAnalogChannels][2] = {
    {"EXA00", "EXA05"}, {"EXA10", "EXA15"}, {"EXA20", "EXA25"}, {"EXA30", "EXA35"},
    {"EXA40", "EXA45"}, {"EXA50", "EXA55"}, {"EXA60", "EXA65"}, {"EXA70", "EXA75"},
};

const QString ExBoardConfigManager::s_linearPresetKeys[kAnalogChannels] = {
    "ui/exboard/ch0_linearPreset", "ui/exboard/ch1_linearPreset", "ui/exboard/ch2_linearPreset",
    "ui/exboard/ch3_linearPreset", "ui/exboard/ch4_linearPreset", "ui/exboard/ch5_linearPreset",
    "ui/exboard/ch6_linearPreset", "ui/exboard/ch7_linearPreset",
};

const QString ExBoardConfigManager::s_ntcPresetKeys[kNtcChannels] = {
    "ui/exboard/ch0_ntcPreset", "ui/exboard/ch1_ntcPreset", "ui/exboard/ch2_ntcPreset",
    "ui/exboard/ch3_ntcPreset", "ui/exboard/ch4_ntcPreset", "ui/exboard/ch5_ntcPreset",
};

const QString ExBoardConfigManager::s_ntcOnKeys[kNtcChannels] = {
    "steinhartcalc0on", "steinhartcalc1on", "steinhartcalc2on",
    "steinhartcalc3on", "steinhartcalc4on", "steinhartcalc5on",
};

const QString ExBoardConfigManager::s_divider100Keys[kNtcChannels] = {
    "AN0R3VAL", "AN1R3VAL", "AN2R3VAL", "AN3R3VAL", "AN4R3VAL", "AN5R3VAL",
};

const QString ExBoardConfigManager::s_divider1kKeys[kNtcChannels] = {
    "AN0R4VAL", "AN1R4VAL", "AN2R4VAL", "AN3R4VAL", "AN4R4VAL", "AN5R4VAL",
};

const QString ExBoardConfigManager::s_steinhartTKeys[kNtcChannels][3] = {
    {"T01", "T02", "T03"}, {"T11", "T12", "T13"}, {"T21", "T22", "T23"},
    {"T31", "T32", "T33"}, {"T41", "T42", "T43"}, {"T51", "T52", "T53"},
};

const QString ExBoardConfigManager::s_steinhartRKeys[kNtcChannels][3] = {
    {"R01", "R02", "R03"}, {"R11", "R12", "R13"}, {"R21", "R22", "R23"},
    {"R31", "R32", "R33"}, {"R41", "R42", "R43"}, {"R51", "R52", "R53"},
};

const QString ExBoardConfigManager::s_channelNameKeys[kAnalogChannels] = {
    "ui/exboard/exan0name", "ui/exboard/exan1name", "ui/exboard/exan2name", "ui/exboard/exan3name",
    "ui/exboard/exan4name", "ui/exboard/exan5name", "ui/exboard/exan6name", "ui/exboard/exan7name",
};

const QString ExBoardConfigManager::s_digitalNameKeys[kDigitalChannels] = {
    "ui/exboard/exdigi1name", "ui/exboard/exdigi2name", "ui/exboard/exdigi3name", "ui/exboard/exdigi4name",
    "ui/exboard/exdigi5name", "ui/exboard/exdigi6name", "ui/exboard/exdigi7name", "ui/exboard/exdigi8name",
};

const QString ExBoardConfigManager::s_channelEnableKeys[kAnalogChannels] = {
    "ui/exboard/ch0_enabled", "ui/exboard/ch1_enabled", "ui/exboard/ch2_enabled", "ui/exboard/ch3_enabled",
    "ui/exboard/ch4_enabled", "ui/exboard/ch5_enabled", "ui/exboard/ch6_enabled", "ui/exboard/ch7_enabled",
};

const QString ExBoardConfigManager::s_digitalEnableKeys[kDigitalChannels] = {
    "ui/exboard/di1_enabled", "ui/exboard/di2_enabled", "ui/exboard/di3_enabled", "ui/exboard/di4_enabled",
    "ui/exboard/di5_enabled", "ui/exboard/di6_enabled", "ui/exboard/di7_enabled", "ui/exboard/di8_enabled",
};

ExBoardConfigManager::ExBoardConfigManager(QObject *parent) : QObject(parent) {}

QVariantMap ExBoardConfigManager::loadAllSettings() const
{
    if (!m_appSettings)
        return {};

    QVariantMap config;

    QVariantList channels;
    channels.reserve(kAnalogChannels);
    for (int ch = 0; ch < kAnalogChannels; ++ch)
        channels.append(getChannelConfig(ch));
    config[QStringLiteral("channels")] = channels;

    QVariantList digitalChannels;
    digitalChannels.reserve(kDigitalChannels);
    QVariantList digitalNames;
    digitalNames.reserve(kDigitalChannels);
    for (int i = 0; i < kDigitalChannels; ++i) {
        const QVariantMap channel = getDigitalChannelConfig(i);
        digitalChannels.append(channel);
        digitalNames.append(channel.value(QStringLiteral("name")));
    }
    config[QStringLiteral("digitalChannels")] = digitalChannels;
    config[QStringLiteral("digitalNames")] = digitalNames;
    config[QStringLiteral("board")] = loadBoardConfig();

    return config;
}

void ExBoardConfigManager::saveAllSettings(const QVariantMap &config)
{
    if (!m_appSettings)
        return;

    const QVariantList channels = config.value(QStringLiteral("channels")).toList();
    for (int ch = 0; ch < qMin(channels.size(), kAnalogChannels); ++ch)
        saveChannelConfigInternal(ch, channels.at(ch).toMap());

    const QVariantList digitalChannels = config.value(QStringLiteral("digitalChannels")).toList();
    if (!digitalChannels.isEmpty()) {
        for (int i = 0; i < qMin(digitalChannels.size(), kDigitalChannels); ++i)
            saveDigitalChannelConfigInternal(i, digitalChannels.at(i).toMap());
    } else {
        const QVariantList digitalNames = config.value(QStringLiteral("digitalNames")).toList();
        for (int i = 0; i < qMin(digitalNames.size(), kDigitalChannels); ++i)
            m_appSettings->setValue(s_digitalNameKeys[i], digitalNames.at(i).toString());
    }

    applyAnalogRuntimeSettings(channels);

    const QVariantMap board = config.value(QStringLiteral("board")).toMap();
    if (!board.isEmpty())
        saveBoardConfig(board);

    refreshSensorRegistry();
    emit configChanged();
}

QVariantMap ExBoardConfigManager::getChannelConfig(int channel) const
{
    if (!m_appSettings || channel < 0 || channel >= kAnalogChannels)
        return {};

    QVariantMap cfg;
    cfg[QStringLiteral("enabled")] = m_appSettings->getValue(s_channelEnableKeys[channel], true).toBool();
    cfg[QStringLiteral("name")] = m_appSettings->getValue(s_channelNameKeys[channel], QString()).toString();
    cfg[QStringLiteral("val0v")] = m_appSettings->getValue(s_linearKeys[channel][0], QStringLiteral("0")).toString();
    cfg[QStringLiteral("val5v")] = m_appSettings->getValue(s_linearKeys[channel][1], QStringLiteral("5")).toString();
    cfg[QStringLiteral("linearPreset")] =
        m_appSettings->getValue(s_linearPresetKeys[channel], QStringLiteral("Custom")).toString();
    cfg[QStringLiteral("minVoltage")] =
        m_appSettings->getValue(QStringLiteral("ui/exboard/ch%1_minVoltage").arg(channel), QStringLiteral("0.0")).toString();
    cfg[QStringLiteral("maxVoltage")] =
        m_appSettings->getValue(QStringLiteral("ui/exboard/ch%1_maxVoltage").arg(channel), QStringLiteral("5.0")).toString();

    if (channel < kNtcChannels) {
        cfg[QStringLiteral("ntcEnabled")] = m_appSettings->getValue(s_ntcOnKeys[channel], false).toBool();
        cfg[QStringLiteral("divider100")] = m_appSettings->getValue(s_divider100Keys[channel], false).toBool();
        cfg[QStringLiteral("divider1k")] = m_appSettings->getValue(s_divider1kKeys[channel], false).toBool();
        cfg[QStringLiteral("ntcPreset")] =
            m_appSettings->getValue(s_ntcPresetKeys[channel], QStringLiteral("Custom")).toString();

        QVariantList tVals;
        QVariantList rVals;
        tVals.reserve(3);
        rVals.reserve(3);
        for (int j = 0; j < 3; ++j) {
            tVals.append(m_appSettings->getValue(s_steinhartTKeys[channel][j], QStringLiteral("0")).toString());
            rVals.append(m_appSettings->getValue(s_steinhartRKeys[channel][j], QStringLiteral("0")).toString());
        }
        cfg[QStringLiteral("steinhartT")] = tVals;
        cfg[QStringLiteral("steinhartR")] = rVals;
    }

    return cfg;
}

void ExBoardConfigManager::saveChannelConfig(int channel, const QVariantMap &config)
{
    if (!m_appSettings || channel < 0 || channel >= kAnalogChannels)
        return;

    saveChannelConfigInternal(channel, config);
    QVariantList channels;
    channels.reserve(kAnalogChannels);
    for (int ch = 0; ch < kAnalogChannels; ++ch)
        channels.append(getChannelConfig(ch));
    applyAnalogRuntimeSettings(channels);
    refreshSensorRegistry();
    emit configChanged();
}

void ExBoardConfigManager::applyLinearPreset(int channel, const QString &presetName)
{
    if (!m_appSettings || channel < 0 || channel >= kAnalogChannels)
        return;

    QVariantMap config = getChannelConfig(channel);
    config[QStringLiteral("linearPreset")] = presetName.isEmpty() ? QStringLiteral("Custom") : presetName;

    if (m_calibrationHelper && presetName != QLatin1String("Custom")) {
        const QVariantMap preset = m_calibrationHelper->getLinearPreset(presetName);
        if (!preset.isEmpty()) {
            config[QStringLiteral("val0v")] = preset.value(QStringLiteral("val0v")).toString();
            config[QStringLiteral("val5v")] = preset.value(QStringLiteral("val5v")).toString();
            config[QStringLiteral("minVoltage")] = preset.value(QStringLiteral("minVoltage"), QStringLiteral("0.0")).toString();
            config[QStringLiteral("maxVoltage")] = preset.value(QStringLiteral("maxVoltage"), QStringLiteral("5.0")).toString();
        }
    }

    saveChannelConfigInternal(channel, config);
    QVariantList channels;
    channels.reserve(kAnalogChannels);
    for (int ch = 0; ch < kAnalogChannels; ++ch)
        channels.append(getChannelConfig(ch));
    applyAnalogRuntimeSettings(channels);
    refreshSensorRegistry();
    emit configChanged();
}

void ExBoardConfigManager::applyNtcPreset(int channel, const QString &presetName)
{
    if (!m_appSettings || channel < 0 || channel >= kNtcChannels)
        return;

    QVariantMap config = getChannelConfig(channel);
    config[QStringLiteral("ntcPreset")] = presetName.isEmpty() ? QStringLiteral("Custom") : presetName;

    if (m_calibrationHelper && presetName != QLatin1String("Custom")) {
        const QVariantMap preset = m_calibrationHelper->getNtcPreset(presetName);
        if (!preset.isEmpty()) {
            config[QStringLiteral("steinhartT")] = QVariantList{preset.value(QStringLiteral("t1")).toString(),
                                                                preset.value(QStringLiteral("t2")).toString(),
                                                                preset.value(QStringLiteral("t3")).toString()};
            config[QStringLiteral("steinhartR")] = QVariantList{preset.value(QStringLiteral("r1")).toString(),
                                                                preset.value(QStringLiteral("r2")).toString(),
                                                                preset.value(QStringLiteral("r3")).toString()};
        }
    }

    saveChannelConfigInternal(channel, config);
    QVariantList channels;
    channels.reserve(kAnalogChannels);
    for (int ch = 0; ch < kAnalogChannels; ++ch)
        channels.append(getChannelConfig(ch));
    applyAnalogRuntimeSettings(channels);
    refreshSensorRegistry();
    emit configChanged();
}

QVariantMap ExBoardConfigManager::loadBoardConfig() const
{
    if (!m_appSettings)
        return {};

    QVariantMap cfg;
    cfg[QStringLiteral("selectedValue")] = m_appSettings->getValue(QStringLiteral("ui/exboard/selectedValue"), 0);
    cfg[QStringLiteral("switchValue")] = m_appSettings->getValue(QStringLiteral("ui/exboard/switchValue"), false);
    cfg[QStringLiteral("rpmSource")] = m_appSettings->getValue(QStringLiteral("ui/exboard/rpmSource"),
                                                              m_appSettings->getValue(QStringLiteral("ui/exboard/rpmSourceValue"), 0));
    cfg[QStringLiteral("rpmCanVersion")] = m_appSettings->getValue(QStringLiteral("ui/exboard/rpmCanVersion"), 0);
    cfg[QStringLiteral("cylinderCombobox")] = m_appSettings->getValue(QStringLiteral("ui/exboard/cylinderCombobox"), 0);
    cfg[QStringLiteral("cylinderComboboxV2")] =
        m_appSettings->getValue(QStringLiteral("ui/exboard/cylinderComboboxV2"), 0);
    cfg[QStringLiteral("cylinderComboboxDi1")] =
        m_appSettings->getValue(QStringLiteral("ui/exboard/cylinderComboboxDi1"), 0);
    cfg[QStringLiteral("rpmcheckbox")] = m_appSettings->getValue(QStringLiteral("ui/exboard/rpmcheckbox"), 0);
    cfg[QStringLiteral("an7Damping")] = m_appSettings->getValue(QStringLiteral("AN7Damping"), QStringLiteral("0"));
    cfg[QStringLiteral("brightness")] = loadBrightnessConfig();
    cfg[QStringLiteral("gearSensor")] = m_appSettings->readGearSensorConfig();
    cfg[QStringLiteral("speedSensor")] = m_appSettings->readSpeedSensorConfig();
    return cfg;
}

void ExBoardConfigManager::saveBoardConfig(const QVariantMap &config)
{
    if (!m_appSettings)
        return;

    const auto valueOrStored = [this, &config](const QString &configKey, const QString &storageKey,
                                               const QVariant &defaultValue) {
        if (config.contains(configKey))
            return config.value(configKey);
        return m_appSettings->getValue(storageKey, defaultValue);
    };

    const int rpmSource =
        valueOrStored(QStringLiteral("rpmSource"), QStringLiteral("ui/exboard/rpmSource"), 0).toInt();
    const int rpmCanVersion =
        valueOrStored(QStringLiteral("rpmCanVersion"), QStringLiteral("ui/exboard/rpmCanVersion"), 0).toInt();

    m_appSettings->setValue(QStringLiteral("ui/exboard/selectedValue"),
                            valueOrStored(QStringLiteral("selectedValue"), QStringLiteral("ui/exboard/selectedValue"), 0));
    m_appSettings->setValue(QStringLiteral("ui/exboard/switchValue"),
                            valueOrStored(QStringLiteral("switchValue"), QStringLiteral("ui/exboard/switchValue"), false));
    m_appSettings->setValue(QStringLiteral("ui/exboard/rpmSource"), rpmSource);
    m_appSettings->setValue(QStringLiteral("ui/exboard/rpmCanVersion"), rpmCanVersion);
    m_appSettings->setValue(QStringLiteral("ui/exboard/cylinderCombobox"),
                            valueOrStored(QStringLiteral("cylinderCombobox"),
                                          QStringLiteral("ui/exboard/cylinderCombobox"), 0));
    m_appSettings->setValue(QStringLiteral("ui/exboard/cylinderComboboxV2"),
                            valueOrStored(QStringLiteral("cylinderComboboxV2"),
                                          QStringLiteral("ui/exboard/cylinderComboboxV2"), 0));
    m_appSettings->setValue(QStringLiteral("ui/exboard/cylinderComboboxDi1"),
                            valueOrStored(QStringLiteral("cylinderComboboxDi1"),
                                          QStringLiteral("ui/exboard/cylinderComboboxDi1"), 0));
    m_appSettings->setValue(QStringLiteral("ui/exboard/rpmcheckbox"),
                            valueOrStored(QStringLiteral("rpmcheckbox"), QStringLiteral("ui/exboard/rpmcheckbox"), 0));
    m_appSettings->writeEXAN7dampingSettings(
        valueOrStored(QStringLiteral("an7Damping"), QStringLiteral("AN7Damping"), 0).toInt());
    m_appSettings->writeExternalrpm(rpmSource > 0);
    m_appSettings->writeRpmSource(rpmSource);

    if (config.contains(QStringLiteral("brightness")))
        saveBrightnessConfig(config.value(QStringLiteral("brightness")).toMap());

    if (rpmSource == 0) {
        m_appSettings->writeRPMFrequencySettings(0.0, 0);
    } else if (rpmSource == 1) {
        const double defaultCylinders =
            m_appSettings->getValue(QStringLiteral("Cylinders"), 4.0).toDouble();
        double cylinders = config.value(QStringLiteral("cylinderComboboxValue"), defaultCylinders).toDouble();
        if (rpmCanVersion == 1) {
            const double v2Value = config.value(QStringLiteral("cylinderComboboxV2Value"), 0.0).toDouble();
            const int multiplier = m_calibrationHelper
                                       ? m_calibrationHelper->expanderChannelMultiplier(
                                             valueOrStored(QStringLiteral("cylinderComboboxV2"),
                                                           QStringLiteral("ui/exboard/cylinderComboboxV2"), 0)
                                                 .toInt())
                                       : 1;
            cylinders = v2Value * multiplier;
        }

        if (cylinders > 0.0)
            m_appSettings->writeCylinderSettings(cylinders);
        m_appSettings->writeRPMFrequencySettings(0.0, 0);
    } else {
        const double divider = m_calibrationHelper ? m_calibrationHelper->frequencyDividerForCylinders(
                                                         valueOrStored(QStringLiteral("cylinderComboboxDi1"),
                                                                       QStringLiteral("ui/exboard/cylinderComboboxDi1"), 0)
                                                             .toInt())
                                                   : 1.0;
        m_appSettings->writeRPMFrequencySettings(divider, 1);
    }

    if (config.contains(QStringLiteral("gearSensor")))
        m_appSettings->writeGearSensorConfig(config.value(QStringLiteral("gearSensor")).toMap());
    if (config.contains(QStringLiteral("speedSensor")))
        m_appSettings->writeSpeedSensorConfig(config.value(QStringLiteral("speedSensor")).toMap());

    emit configChanged();
}

QVariantMap ExBoardConfigManager::loadBrightnessConfig() const
{
    if (!m_appSettings)
        return {};

    QVariantMap cfg;
    cfg[QStringLiteral("manualEnabled")] =
        m_appSettings->getValue(QStringLiteral("ui/exboard/brightness/manualEnabled"), true).toBool();
    cfg[QStringLiteral("discreteEnabled")] =
        m_appSettings->getValue(QStringLiteral("ui/exboard/brightness/discreteEnabled"), false).toBool();
    cfg[QStringLiteral("canIoEnabled")] =
        m_appSettings->getValue(QStringLiteral("ui/exboard/brightness/canIoEnabled"), false).toBool();
    cfg[QStringLiteral("analogEnabled")] =
        m_appSettings->getValue(QStringLiteral("ui/exboard/brightness/analogEnabled"), false).toBool();
    cfg[QStringLiteral("headlightChannel")] =
        m_appSettings->getValue(QStringLiteral("ui/exboard/brightness/headlightChannel"),
                                m_appSettings->getValue(QStringLiteral("ui/exboard/selectedValue"), 0))
            .toInt();
    cfg[QStringLiteral("analogChannel")] =
        m_appSettings->getValue(QStringLiteral("ui/exboard/brightness/analogChannel"), 0).toInt();
    cfg[QStringLiteral("globalMaxPercent")] = m_appSettings->readGlobalBrightnessPercent();
    return cfg;
}

void ExBoardConfigManager::saveBrightnessConfig(const QVariantMap &config)
{
    if (!m_appSettings)
        return;

    const QVariantMap current = loadBrightnessConfig();
    const bool manualEnabled = config.value(QStringLiteral("manualEnabled"),
                                            current.value(QStringLiteral("manualEnabled"), true))
                                   .toBool();
    const bool discreteEnabled = config.value(QStringLiteral("discreteEnabled"),
                                              current.value(QStringLiteral("discreteEnabled"), false))
                                     .toBool();
    const bool canIoEnabled = config.value(QStringLiteral("canIoEnabled"),
                                           current.value(QStringLiteral("canIoEnabled"), false))
                                  .toBool();
    const bool analogEnabled = config.value(QStringLiteral("analogEnabled"),
                                            current.value(QStringLiteral("analogEnabled"), false))
                                   .toBool();
    const int headlightChannel = qBound(0, config.value(QStringLiteral("headlightChannel"),
                                                        current.value(QStringLiteral("headlightChannel"), 0))
                                               .toInt(),
                                        kDigitalChannels - 1);
    const int analogChannel = qBound(0, config.value(QStringLiteral("analogChannel"),
                                                     current.value(QStringLiteral("analogChannel"), 0))
                                            .toInt(),
                                     kAnalogChannels - 1);
    const int globalMaxPercent = qBound(0, config.value(QStringLiteral("globalMaxPercent"),
                                                        current.value(QStringLiteral("globalMaxPercent"), 100))
                                               .toInt(),
                                        100);

    m_appSettings->setValue(QStringLiteral("ui/exboard/brightness/manualEnabled"), manualEnabled);
    m_appSettings->setValue(QStringLiteral("ui/exboard/brightness/discreteEnabled"), discreteEnabled);
    m_appSettings->setValue(QStringLiteral("ui/exboard/brightness/canIoEnabled"), canIoEnabled);
    m_appSettings->setValue(QStringLiteral("ui/exboard/brightness/analogEnabled"), analogEnabled);
    m_appSettings->setValue(QStringLiteral("ui/exboard/brightness/headlightChannel"), headlightChannel);
    m_appSettings->setValue(QStringLiteral("ui/exboard/brightness/analogChannel"), analogChannel);
    m_appSettings->writeGlobalBrightnessPercent(globalMaxPercent);
}

QStringList ExBoardConfigManager::channelNames() const
{
    QStringList names;
    if (!m_appSettings)
        return names;
    names.reserve(kAnalogChannels);
    for (int i = 0; i < kAnalogChannels; ++i)
        names.append(m_appSettings->getValue(s_channelNameKeys[i], QString()).toString());
    return names;
}

QStringList ExBoardConfigManager::digitalChannelNames() const
{
    QStringList names;
    if (!m_appSettings)
        return names;
    names.reserve(kDigitalChannels);
    for (int i = 0; i < kDigitalChannels; ++i)
        names.append(m_appSettings->getValue(s_digitalNameKeys[i], QString()).toString());
    return names;
}

QVariantMap ExBoardConfigManager::getDigitalChannelConfig(int channel) const
{
    if (!m_appSettings || channel < 0 || channel >= kDigitalChannels)
        return {};

    QVariantMap cfg;
    cfg[QStringLiteral("enabled")] = m_appSettings->getValue(s_digitalEnableKeys[channel], true).toBool();
    cfg[QStringLiteral("name")] = m_appSettings->getValue(s_digitalNameKeys[channel], QString()).toString();
    return cfg;
}

void ExBoardConfigManager::saveChannelConfigInternal(int channel, const QVariantMap &config)
{
    if (!m_appSettings || channel < 0 || channel >= kAnalogChannels)
        return;

    if (config.contains(QStringLiteral("enabled")))
        m_appSettings->setValue(s_channelEnableKeys[channel], config.value(QStringLiteral("enabled")));
    if (config.contains(QStringLiteral("name")))
        m_appSettings->setValue(s_channelNameKeys[channel], config.value(QStringLiteral("name")));
    if (config.contains(QStringLiteral("val0v")))
        m_appSettings->setValue(s_linearKeys[channel][0], config.value(QStringLiteral("val0v")));
    if (config.contains(QStringLiteral("val5v")))
        m_appSettings->setValue(s_linearKeys[channel][1], config.value(QStringLiteral("val5v")));
    if (config.contains(QStringLiteral("linearPreset")))
        m_appSettings->setValue(s_linearPresetKeys[channel], config.value(QStringLiteral("linearPreset")));
    if (config.contains(QStringLiteral("minVoltage")))
        m_appSettings->setValue(QStringLiteral("ui/exboard/ch%1_minVoltage").arg(channel), config.value(QStringLiteral("minVoltage")));
    if (config.contains(QStringLiteral("maxVoltage")))
        m_appSettings->setValue(QStringLiteral("ui/exboard/ch%1_maxVoltage").arg(channel), config.value(QStringLiteral("maxVoltage")));

    if (channel < kNtcChannels) {
        if (config.contains(QStringLiteral("ntcEnabled")))
            m_appSettings->setValue(s_ntcOnKeys[channel], config.value(QStringLiteral("ntcEnabled")));
        if (config.contains(QStringLiteral("divider100")))
            m_appSettings->setValue(s_divider100Keys[channel], config.value(QStringLiteral("divider100")));
        if (config.contains(QStringLiteral("divider1k")))
            m_appSettings->setValue(s_divider1kKeys[channel], config.value(QStringLiteral("divider1k")));
        if (config.contains(QStringLiteral("ntcPreset")))
            m_appSettings->setValue(s_ntcPresetKeys[channel], config.value(QStringLiteral("ntcPreset")));

        const QVariantList tVals = config.value(QStringLiteral("steinhartT")).toList();
        const QVariantList rVals = config.value(QStringLiteral("steinhartR")).toList();
        for (int j = 0; j < 3; ++j) {
            if (j < tVals.size())
                m_appSettings->setValue(s_steinhartTKeys[channel][j], tVals.at(j));
            if (j < rVals.size())
                m_appSettings->setValue(s_steinhartRKeys[channel][j], rVals.at(j));
        }
    }
}

void ExBoardConfigManager::saveDigitalChannelConfigInternal(int channel, const QVariantMap &config)
{
    if (!m_appSettings || channel < 0 || channel >= kDigitalChannels)
        return;

    if (config.contains(QStringLiteral("enabled")))
        m_appSettings->setValue(s_digitalEnableKeys[channel], config.value(QStringLiteral("enabled")));
    if (config.contains(QStringLiteral("name")))
        m_appSettings->setValue(s_digitalNameKeys[channel], config.value(QStringLiteral("name")));
}

void ExBoardConfigManager::applyAnalogRuntimeSettings(const QVariantList &channels) const
{
    if (!m_appSettings)
        return;
    m_appSettings->applyEXBoardCalibration(channels);
}

void ExBoardConfigManager::refreshSensorRegistry() const
{
    if (!m_sensorRegistry)
        return;

    m_sensorRegistry->refreshAll();

    for (int channel = 0; channel < kAnalogChannels; ++channel)
        syncChannelSensorMetadata(channel);
}

void ExBoardConfigManager::syncChannelSensorMetadata(int channel) const
{
    if (!m_sensorRegistry || channel < 0 || channel >= kAnalogChannels)
        return;

    const QVariantMap channelConfig = getChannelConfig(channel);
    const bool ntcEnabled = channel < kNtcChannels && channelConfig.value(QStringLiteral("ntcEnabled")).toBool();

    SensorMetadata metadata;

    if (ntcEnabled) {
        metadata.unit = QStringLiteral("C");
        metadata.decimals = 1;
        metadata.stepSize = 1.0;
        metadata.maxValue = 150.0;

        const QVariantList temps = channelConfig.value(QStringLiteral("steinhartT")).toList();
        for (const QVariant &temp : temps)
            metadata.maxValue = std::max(metadata.maxValue, temp.toDouble());
    } else {
        const QString presetName = channelConfig.value(QStringLiteral("linearPreset")).toString();
        const double val0 = channelConfig.value(QStringLiteral("val0v")).toDouble();
        const double val5 = channelConfig.value(QStringLiteral("val5v")).toDouble();
        metadata.maxValue = std::max(1.0, maxAbs(val0, val5));

        if (m_calibrationHelper && !presetName.isEmpty() && presetName != QLatin1String("Custom")) {
            const QVariantMap preset = m_calibrationHelper->getLinearPreset(presetName);
            if (!preset.isEmpty()) {
                metadata.unit = preset.value(QStringLiteral("unit")).toString();
                metadata.maxValue = std::max(1.0, maxAbs(preset.value(QStringLiteral("val0v")).toDouble(),
                                                         preset.value(QStringLiteral("val5v")).toDouble()));
            }
        }

        metadata.decimals = decimalsForRange(metadata.maxValue, metadata.unit);
        metadata.stepSize = stepForRange(metadata.maxValue, metadata.unit);
    }

    m_sensorRegistry->updateSensorMetadata(QStringLiteral("EXAnalogInput%1").arg(channel), QStringLiteral("V"), 3, 5.0,
                                           0.1);
    m_sensorRegistry->updateSensorMetadata(QStringLiteral("EXAnalogCalc%1").arg(channel), metadata.unit,
                                           metadata.decimals, metadata.maxValue, metadata.stepSize);
}

QVariantMap ExBoardConfigManager::getDifferentialSensorConfig() const
{
    if (!m_appSettings)
        return {};

    QVariantMap cfg;
    cfg[QStringLiteral("enabled")] = m_appSettings->getValue(QStringLiteral("ui/exboard/diffSensor_enabled"), false).toBool();
    cfg[QStringLiteral("channelA")] = m_appSettings->getValue(QStringLiteral("ui/exboard/diffSensor_channelA"), 0).toInt();
    cfg[QStringLiteral("channelB")] = m_appSettings->getValue(QStringLiteral("ui/exboard/diffSensor_channelB"), 1).toInt();
    cfg[QStringLiteral("formula")] = m_appSettings->getValue(QStringLiteral("ui/exboard/diffSensor_formula"), QStringLiteral("percentage")).toString();
    cfg[QStringLiteral("offset")] = m_appSettings->getValue(QStringLiteral("ui/exboard/diffSensor_offset"), 0.0).toDouble();
    return cfg;
}

void ExBoardConfigManager::saveDifferentialSensorConfig(const QVariantMap &config)
{
    if (!m_appSettings)
        return;

    if (config.contains(QStringLiteral("enabled")))
        m_appSettings->setValue(QStringLiteral("ui/exboard/diffSensor_enabled"), config.value(QStringLiteral("enabled")));
    if (config.contains(QStringLiteral("channelA")))
        m_appSettings->setValue(QStringLiteral("ui/exboard/diffSensor_channelA"), config.value(QStringLiteral("channelA")));
    if (config.contains(QStringLiteral("channelB")))
        m_appSettings->setValue(QStringLiteral("ui/exboard/diffSensor_channelB"), config.value(QStringLiteral("channelB")));
    if (config.contains(QStringLiteral("formula")))
        m_appSettings->setValue(QStringLiteral("ui/exboard/diffSensor_formula"), config.value(QStringLiteral("formula")));
    if (config.contains(QStringLiteral("offset")))
        m_appSettings->setValue(QStringLiteral("ui/exboard/diffSensor_offset"), config.value(QStringLiteral("offset")));

    emit configChanged();
}
