#include "ExBoardConfigManager.h"
#include "SensorRegistry.h"
#include "appsettings.h"
#include "../Utils/CalibrationHelper.h"

const QString ExBoardConfigManager::s_linearKeys[kAnalogChannels][2] = {
    {"EXA00", "EXA05"}, {"EXA10", "EXA15"}, {"EXA20", "EXA25"}, {"EXA30", "EXA35"},
    {"EXA40", "EXA45"}, {"EXA50", "EXA55"}, {"EXA60", "EXA65"}, {"EXA70", "EXA75"},
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
    for (int ch = 0; ch < kAnalogChannels; ++ch)
        channels.append(getChannelConfig(ch));
    config[QStringLiteral("channels")] = channels;

    QVariantList digitalNames;
    for (int i = 0; i < kDigitalChannels; ++i)
        digitalNames.append(m_appSettings->getValue(s_digitalNameKeys[i], QString()));
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
        saveChannelConfig(ch, channels.at(ch).toMap());

    const QVariantList digitalNames = config.value(QStringLiteral("digitalNames")).toList();
    for (int i = 0; i < qMin(digitalNames.size(), kDigitalChannels); ++i)
        m_appSettings->setValue(s_digitalNameKeys[i], digitalNames.at(i).toString());

    const QVariantMap board = config.value(QStringLiteral("board")).toMap();
    if (!board.isEmpty())
        saveBoardConfig(board);

    if (m_sensorRegistry) {
        m_sensorRegistry->refreshExtenderAnalogInputs();
        m_sensorRegistry->refreshExtenderDigitalInputs();
    }

    emit configChanged();
}

QVariantMap ExBoardConfigManager::getChannelConfig(int channel) const
{
    if (!m_appSettings || channel < 0 || channel >= kAnalogChannels)
        return {};

    QVariantMap cfg;
    cfg[QStringLiteral("enabled")] = m_appSettings->getValue(s_channelEnableKeys[channel], true);
    cfg[QStringLiteral("name")] = m_appSettings->getValue(s_channelNameKeys[channel], QString());
    cfg[QStringLiteral("val0v")] = m_appSettings->getValue(s_linearKeys[channel][0], QStringLiteral("0"));
    cfg[QStringLiteral("val5v")] = m_appSettings->getValue(s_linearKeys[channel][1], QStringLiteral("5"));

    if (channel < kNtcChannels) {
        cfg[QStringLiteral("ntcEnabled")] = m_appSettings->getValue(s_ntcOnKeys[channel], 0);
        cfg[QStringLiteral("divider100")] = m_appSettings->getValue(s_divider100Keys[channel], 0);
        cfg[QStringLiteral("divider1k")] = m_appSettings->getValue(s_divider1kKeys[channel], 0);

        QVariantList tVals, rVals;
        for (int j = 0; j < 3; ++j) {
            tVals.append(m_appSettings->getValue(s_steinhartTKeys[channel][j], QStringLiteral("0")));
            rVals.append(m_appSettings->getValue(s_steinhartRKeys[channel][j], QStringLiteral("0")));
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

    if (config.contains(QStringLiteral("enabled")))
        m_appSettings->setValue(s_channelEnableKeys[channel], config.value(QStringLiteral("enabled")));
    if (config.contains(QStringLiteral("name")))
        m_appSettings->setValue(s_channelNameKeys[channel], config.value(QStringLiteral("name")));
    if (config.contains(QStringLiteral("val0v")))
        m_appSettings->setValue(s_linearKeys[channel][0], config.value(QStringLiteral("val0v")));
    if (config.contains(QStringLiteral("val5v")))
        m_appSettings->setValue(s_linearKeys[channel][1], config.value(QStringLiteral("val5v")));

    if (channel < kNtcChannels) {
        if (config.contains(QStringLiteral("ntcEnabled")))
            m_appSettings->setValue(s_ntcOnKeys[channel], config.value(QStringLiteral("ntcEnabled")));
        if (config.contains(QStringLiteral("divider100")))
            m_appSettings->setValue(s_divider100Keys[channel], config.value(QStringLiteral("divider100")));
        if (config.contains(QStringLiteral("divider1k")))
            m_appSettings->setValue(s_divider1kKeys[channel], config.value(QStringLiteral("divider1k")));

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

void ExBoardConfigManager::applyLinearPreset(int channel, const QString &presetName)
{
    if (!m_appSettings || !m_calibrationHelper || channel < 0 || channel >= kAnalogChannels)
        return;

    if (presetName == QLatin1String("Custom"))
        return;

    QVariantMap preset = m_calibrationHelper->getLinearPreset(presetName);
    if (preset.isEmpty())
        return;

    m_appSettings->setValue(s_linearKeys[channel][0], preset.value(QStringLiteral("val0v")));
    m_appSettings->setValue(s_linearKeys[channel][1], preset.value(QStringLiteral("val5v")));
    emit configChanged();
}

void ExBoardConfigManager::applyNtcPreset(int channel, const QString &presetName)
{
    if (!m_appSettings || !m_calibrationHelper || channel < 0 || channel >= kNtcChannels)
        return;

    if (presetName == QLatin1String("Custom"))
        return;

    QVariantMap preset = m_calibrationHelper->getNtcPreset(presetName);
    if (preset.isEmpty())
        return;

    const QStringList tKeys = {QStringLiteral("t1"), QStringLiteral("t2"), QStringLiteral("t3")};
    const QStringList rKeys = {QStringLiteral("r1"), QStringLiteral("r2"), QStringLiteral("r3")};

    for (int j = 0; j < 3; ++j) {
        m_appSettings->setValue(s_steinhartTKeys[channel][j], preset.value(tKeys.at(j)));
        m_appSettings->setValue(s_steinhartRKeys[channel][j], preset.value(rKeys.at(j)));
    }
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
    cfg[QStringLiteral("cylinderCombobox")] = m_appSettings->getValue(QStringLiteral("ui/exboard/cylinderCombobox"), 0);
    cfg[QStringLiteral("cylinderComboboxV2")] = m_appSettings->getValue(QStringLiteral("ui/exboard/cylinderComboboxV2"), 0);
    cfg[QStringLiteral("cylinderComboboxDi1")] = m_appSettings->getValue(QStringLiteral("ui/exboard/cylinderComboboxDi1"), 0);
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

    auto setIfPresent = [&](const QString &key, const QString &settingsKey) {
        if (config.contains(key))
            m_appSettings->setValue(settingsKey, config.value(key));
    };

    setIfPresent(QStringLiteral("selectedValue"), QStringLiteral("ui/exboard/selectedValue"));
    setIfPresent(QStringLiteral("switchValue"), QStringLiteral("ui/exboard/switchValue"));
    setIfPresent(QStringLiteral("rpmSource"), QStringLiteral("ui/exboard/rpmSource"));
    setIfPresent(QStringLiteral("cylinderCombobox"), QStringLiteral("ui/exboard/cylinderCombobox"));
    setIfPresent(QStringLiteral("cylinderComboboxV2"), QStringLiteral("ui/exboard/cylinderComboboxV2"));
    setIfPresent(QStringLiteral("cylinderComboboxDi1"), QStringLiteral("ui/exboard/cylinderComboboxDi1"));
    setIfPresent(QStringLiteral("rpmcheckbox"), QStringLiteral("ui/exboard/rpmcheckbox"));
    if (config.contains(QStringLiteral("an7Damping")))
        m_appSettings->writeEXAN7dampingSettings(config.value(QStringLiteral("an7Damping")).toInt());
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
