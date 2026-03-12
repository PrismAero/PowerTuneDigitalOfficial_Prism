#include "ExBoardConfigManager.h"

#include "SensorRegistry.h"
#include "appsettings.h"
#include "../Utils/CalibrationHelper.h"

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
    "ui/exboard/exan0name", "ui/exboard/exan1name", "ui/exboard/exan2name",
    "ui/exboard/exan3name", "ui/exboard/exan4name", "ui/exboard/exan5name",
    "ui/exboard/exan6name", "ui/exboard/exan7name",
};

const QString ExBoardConfigManager::s_digitalNameKeys[kDigitalChannels] = {
    "ui/exboard/exdigi1name", "ui/exboard/exdigi2name", "ui/exboard/exdigi3name",
    "ui/exboard/exdigi4name", "ui/exboard/exdigi5name", "ui/exboard/exdigi6name",
    "ui/exboard/exdigi7name", "ui/exboard/exdigi8name",
};

const QString ExBoardConfigManager::s_channelEnableKeys[kAnalogChannels] = {
    "ui/exboard/ch0_enabled", "ui/exboard/ch1_enabled", "ui/exboard/ch2_enabled",
    "ui/exboard/ch3_enabled", "ui/exboard/ch4_enabled", "ui/exboard/ch5_enabled",
    "ui/exboard/ch6_enabled", "ui/exboard/ch7_enabled",
};

const QString ExBoardConfigManager::s_digitalEnableKeys[kDigitalChannels] = {
    "ui/exboard/di1_enabled", "ui/exboard/di2_enabled", "ui/exboard/di3_enabled", "ui/exboard/di4_enabled",
    "ui/exboard/di5_enabled", "ui/exboard/di6_enabled", "ui/exboard/di7_enabled", "ui/exboard/di8_enabled",
};

ExBoardConfigManager::ExBoardConfigManager(QObject *parent)
    : QObject(parent)
{
}

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

    applyAnalogRuntimeSettings();

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
    applyAnalogRuntimeSettings();
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
        }
    }

    saveChannelConfigInternal(channel, config);
    applyAnalogRuntimeSettings();
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
            config[QStringLiteral("steinhartT")] =
                QVariantList{preset.value(QStringLiteral("t1")).toString(), preset.value(QStringLiteral("t2")).toString(),
                             preset.value(QStringLiteral("t3")).toString()};
            config[QStringLiteral("steinhartR")] =
                QVariantList{preset.value(QStringLiteral("r1")).toString(), preset.value(QStringLiteral("r2")).toString(),
                             preset.value(QStringLiteral("r3")).toString()};
        }
    }

    saveChannelConfigInternal(channel, config);
    applyAnalogRuntimeSettings();
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
    cfg[QStringLiteral("rpmSource")] = m_appSettings->getValue(QStringLiteral("ui/exboard/rpmSource"), 0);
    cfg[QStringLiteral("rpmCanVersion")] = m_appSettings->getValue(QStringLiteral("ui/exboard/rpmCanVersion"), 0);
    cfg[QStringLiteral("cylinderCombobox")] = m_appSettings->getValue(QStringLiteral("ui/exboard/cylinderCombobox"), 0);
    cfg[QStringLiteral("cylinderComboboxV2")] =
        m_appSettings->getValue(QStringLiteral("ui/exboard/cylinderComboboxV2"), 0);
    cfg[QStringLiteral("cylinderComboboxDi1")] =
        m_appSettings->getValue(QStringLiteral("ui/exboard/cylinderComboboxDi1"), 0);
    cfg[QStringLiteral("rpmcheckbox")] = m_appSettings->getValue(QStringLiteral("ui/exboard/rpmcheckbox"), 0);
    cfg[QStringLiteral("an7Damping")] = m_appSettings->getValue(QStringLiteral("AN7Damping"), QStringLiteral("0"));
    cfg[QStringLiteral("gearSensor")] = m_appSettings->readGearSensorConfig();
    cfg[QStringLiteral("speedSensor")] = m_appSettings->readSpeedSensorConfig();
    return cfg;
}

void ExBoardConfigManager::saveBoardConfig(const QVariantMap &config)
{
    if (!m_appSettings)
        return;

    QVariantMap merged = loadBoardConfig();
    for (auto it = config.constBegin(); it != config.constEnd(); ++it)
        merged[it.key()] = it.value();

    const int rpmSource = merged.value(QStringLiteral("rpmSource"), 0).toInt();
    const int rpmCanVersion = merged.value(QStringLiteral("rpmCanVersion"), 0).toInt();

    m_appSettings->setValue(QStringLiteral("ui/exboard/selectedValue"), merged.value(QStringLiteral("selectedValue"), 0));
    m_appSettings->setValue(QStringLiteral("ui/exboard/switchValue"), merged.value(QStringLiteral("switchValue"), false));
    m_appSettings->setValue(QStringLiteral("ui/exboard/rpmSource"), rpmSource);
    m_appSettings->setValue(QStringLiteral("ui/exboard/rpmCanVersion"), rpmCanVersion);
    m_appSettings->setValue(QStringLiteral("ui/exboard/cylinderCombobox"),
                            merged.value(QStringLiteral("cylinderCombobox"), 0));
    m_appSettings->setValue(QStringLiteral("ui/exboard/cylinderComboboxV2"),
                            merged.value(QStringLiteral("cylinderComboboxV2"), 0));
    m_appSettings->setValue(QStringLiteral("ui/exboard/cylinderComboboxDi1"),
                            merged.value(QStringLiteral("cylinderComboboxDi1"), 0));
    m_appSettings->setValue(QStringLiteral("ui/exboard/rpmcheckbox"), merged.value(QStringLiteral("rpmcheckbox"), 0));
    m_appSettings->writeEXAN7dampingSettings(merged.value(QStringLiteral("an7Damping"), 0).toInt());
    m_appSettings->writeExternalrpm(rpmSource > 0);

    if (rpmSource == 0) {
        m_appSettings->writeRPMFrequencySettings(0.0, 0);
    } else if (rpmSource == 1) {
        double cylinders = merged.value(QStringLiteral("cylinderComboboxValue")).toDouble();
        if (rpmCanVersion == 1) {
            const double v2Value = merged.value(QStringLiteral("cylinderComboboxV2Value")).toDouble();
            const int multiplier =
                m_calibrationHelper ? m_calibrationHelper->expanderChannelMultiplier(
                                          merged.value(QStringLiteral("cylinderComboboxV2"), 0).toInt())
                                    : 1;
            cylinders = v2Value * multiplier;
        }

        if (cylinders > 0.0)
            m_appSettings->writeCylinderSettings(cylinders);
        m_appSettings->writeRPMFrequencySettings(0.0, 0);
    } else {
        const double divider = m_calibrationHelper
                                   ? m_calibrationHelper->frequencyDividerForCylinders(
                                         merged.value(QStringLiteral("cylinderComboboxDi1"), 0).toInt())
                                   : 1.0;
        m_appSettings->writeRPMFrequencySettings(divider, 1);
    }

    if (merged.contains(QStringLiteral("gearSensor")))
        m_appSettings->writeGearSensorConfig(merged.value(QStringLiteral("gearSensor")).toMap());
    if (merged.contains(QStringLiteral("speedSensor")))
        m_appSettings->writeSpeedSensorConfig(merged.value(QStringLiteral("speedSensor")).toMap());
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

void ExBoardConfigManager::applyAnalogRuntimeSettings() const
{
    if (!m_appSettings)
        return;

    const qreal exa00 = m_appSettings->getValue(QStringLiteral("EXA00"), 0).toDouble();
    const qreal exa05 = m_appSettings->getValue(QStringLiteral("EXA05"), 5).toDouble();
    const qreal exa10 = m_appSettings->getValue(QStringLiteral("EXA10"), 0).toDouble();
    const qreal exa15 = m_appSettings->getValue(QStringLiteral("EXA15"), 5).toDouble();
    const qreal exa20 = m_appSettings->getValue(QStringLiteral("EXA20"), 0).toDouble();
    const qreal exa25 = m_appSettings->getValue(QStringLiteral("EXA25"), 5).toDouble();
    const qreal exa30 = m_appSettings->getValue(QStringLiteral("EXA30"), 0).toDouble();
    const qreal exa35 = m_appSettings->getValue(QStringLiteral("EXA35"), 5).toDouble();
    const qreal exa40 = m_appSettings->getValue(QStringLiteral("EXA40"), 0).toDouble();
    const qreal exa45 = m_appSettings->getValue(QStringLiteral("EXA45"), 5).toDouble();
    const qreal exa50 = m_appSettings->getValue(QStringLiteral("EXA50"), 0).toDouble();
    const qreal exa55 = m_appSettings->getValue(QStringLiteral("EXA55"), 5).toDouble();
    const qreal exa60 = m_appSettings->getValue(QStringLiteral("EXA60"), 0).toDouble();
    const qreal exa65 = m_appSettings->getValue(QStringLiteral("EXA65"), 5).toDouble();
    const qreal exa70 = m_appSettings->getValue(QStringLiteral("EXA70"), 0).toDouble();
    const qreal exa75 = m_appSettings->getValue(QStringLiteral("EXA75"), 5).toDouble();

    const int ntc0 = m_appSettings->getValue(QStringLiteral("steinhartcalc0on"), 0).toInt();
    const int ntc1 = m_appSettings->getValue(QStringLiteral("steinhartcalc1on"), 0).toInt();
    const int ntc2 = m_appSettings->getValue(QStringLiteral("steinhartcalc2on"), 0).toInt();
    const int ntc3 = m_appSettings->getValue(QStringLiteral("steinhartcalc3on"), 0).toInt();
    const int ntc4 = m_appSettings->getValue(QStringLiteral("steinhartcalc4on"), 0).toInt();
    const int ntc5 = m_appSettings->getValue(QStringLiteral("steinhartcalc5on"), 0).toInt();

    const int an0r3 = m_appSettings->getValue(QStringLiteral("AN0R3VAL"), 0).toInt();
    const int an0r4 = m_appSettings->getValue(QStringLiteral("AN0R4VAL"), 0).toInt();
    const int an1r3 = m_appSettings->getValue(QStringLiteral("AN1R3VAL"), 0).toInt();
    const int an1r4 = m_appSettings->getValue(QStringLiteral("AN1R4VAL"), 0).toInt();
    const int an2r3 = m_appSettings->getValue(QStringLiteral("AN2R3VAL"), 0).toInt();
    const int an2r4 = m_appSettings->getValue(QStringLiteral("AN2R4VAL"), 0).toInt();
    const int an3r3 = m_appSettings->getValue(QStringLiteral("AN3R3VAL"), 0).toInt();
    const int an3r4 = m_appSettings->getValue(QStringLiteral("AN3R4VAL"), 0).toInt();
    const int an4r3 = m_appSettings->getValue(QStringLiteral("AN4R3VAL"), 0).toInt();
    const int an4r4 = m_appSettings->getValue(QStringLiteral("AN4R4VAL"), 0).toInt();
    const int an5r3 = m_appSettings->getValue(QStringLiteral("AN5R3VAL"), 0).toInt();
    const int an5r4 = m_appSettings->getValue(QStringLiteral("AN5R4VAL"), 0).toInt();

    m_appSettings->writeEXBoardSettings(exa00, exa05, exa10, exa15, exa20, exa25, exa30, exa35, exa40, exa45, exa50,
                                        exa55, exa60, exa65, exa70, exa75, ntc0, ntc1, ntc2, ntc3, ntc4, ntc5, an0r3,
                                        an0r4, an1r3, an1r4, an2r3, an2r4, an3r3, an3r4, an4r3, an4r4, an5r3, an5r4);

    const qreal t01 = m_appSettings->getValue(QStringLiteral("T01"), 0).toDouble();
    const qreal t02 = m_appSettings->getValue(QStringLiteral("T02"), 0).toDouble();
    const qreal t03 = m_appSettings->getValue(QStringLiteral("T03"), 0).toDouble();
    const qreal r01 = m_appSettings->getValue(QStringLiteral("R01"), 0).toDouble();
    const qreal r02 = m_appSettings->getValue(QStringLiteral("R02"), 0).toDouble();
    const qreal r03 = m_appSettings->getValue(QStringLiteral("R03"), 0).toDouble();
    const qreal t11 = m_appSettings->getValue(QStringLiteral("T11"), 0).toDouble();
    const qreal t12 = m_appSettings->getValue(QStringLiteral("T12"), 0).toDouble();
    const qreal t13 = m_appSettings->getValue(QStringLiteral("T13"), 0).toDouble();
    const qreal r11 = m_appSettings->getValue(QStringLiteral("R11"), 0).toDouble();
    const qreal r12 = m_appSettings->getValue(QStringLiteral("R12"), 0).toDouble();
    const qreal r13 = m_appSettings->getValue(QStringLiteral("R13"), 0).toDouble();
    const qreal t21 = m_appSettings->getValue(QStringLiteral("T21"), 0).toDouble();
    const qreal t22 = m_appSettings->getValue(QStringLiteral("T22"), 0).toDouble();
    const qreal t23 = m_appSettings->getValue(QStringLiteral("T23"), 0).toDouble();
    const qreal r21 = m_appSettings->getValue(QStringLiteral("R21"), 0).toDouble();
    const qreal r22 = m_appSettings->getValue(QStringLiteral("R22"), 0).toDouble();
    const qreal r23 = m_appSettings->getValue(QStringLiteral("R23"), 0).toDouble();
    const qreal t31 = m_appSettings->getValue(QStringLiteral("T31"), 0).toDouble();
    const qreal t32 = m_appSettings->getValue(QStringLiteral("T32"), 0).toDouble();
    const qreal t33 = m_appSettings->getValue(QStringLiteral("T33"), 0).toDouble();
    const qreal r31 = m_appSettings->getValue(QStringLiteral("R31"), 0).toDouble();
    const qreal r32 = m_appSettings->getValue(QStringLiteral("R32"), 0).toDouble();
    const qreal r33 = m_appSettings->getValue(QStringLiteral("R33"), 0).toDouble();
    const qreal t41 = m_appSettings->getValue(QStringLiteral("T41"), 0).toDouble();
    const qreal t42 = m_appSettings->getValue(QStringLiteral("T42"), 0).toDouble();
    const qreal t43 = m_appSettings->getValue(QStringLiteral("T43"), 0).toDouble();
    const qreal r41 = m_appSettings->getValue(QStringLiteral("R41"), 0).toDouble();
    const qreal r42 = m_appSettings->getValue(QStringLiteral("R42"), 0).toDouble();
    const qreal r43 = m_appSettings->getValue(QStringLiteral("R43"), 0).toDouble();
    const qreal t51 = m_appSettings->getValue(QStringLiteral("T51"), 0).toDouble();
    const qreal t52 = m_appSettings->getValue(QStringLiteral("T52"), 0).toDouble();
    const qreal t53 = m_appSettings->getValue(QStringLiteral("T53"), 0).toDouble();
    const qreal r51 = m_appSettings->getValue(QStringLiteral("R51"), 0).toDouble();
    const qreal r52 = m_appSettings->getValue(QStringLiteral("R52"), 0).toDouble();
    const qreal r53 = m_appSettings->getValue(QStringLiteral("R53"), 0).toDouble();

    m_appSettings->writeSteinhartSettings(t01, t02, t03, r01, r02, r03, t11, t12, t13, r11, r12, r13, t21, t22, t23,
                                          r21, r22, r23, t31, t32, t33, r31, r32, r33, t41, t42, t43, r41, r42, r43,
                                          t51, t52, t53, r51, r52, r53);
}

void ExBoardConfigManager::refreshSensorRegistry() const
{
    if (!m_sensorRegistry)
        return;

    m_sensorRegistry->refreshExtenderAnalogInputs();
    m_sensorRegistry->refreshExtenderDigitalInputs();

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
    m_sensorRegistry->updateSensorMetadata(QStringLiteral("EXAnalogCalc%1").arg(channel), metadata.unit, metadata.decimals,
                                          metadata.maxValue, metadata.stepSize);
}
