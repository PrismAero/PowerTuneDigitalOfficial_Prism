#ifndef EXBOARDCONFIGMANAGER_H
#define EXBOARDCONFIGMANAGER_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantMap>

class AppSettings;
class CalibrationHelper;
class SensorRegistry;

class ExBoardConfigManager : public QObject
{
    Q_OBJECT

public:
    explicit ExBoardConfigManager(QObject *parent = nullptr);

    void setAppSettings(AppSettings *settings) { m_appSettings = settings; }
    void setCalibrationHelper(CalibrationHelper *helper) { m_calibrationHelper = helper; }
    void setSensorRegistry(SensorRegistry *reg) { m_sensorRegistry = reg; }

    static constexpr int kAnalogChannels = 8;
    static constexpr int kNtcChannels = 6;
    static constexpr int kDigitalChannels = 8;

    Q_INVOKABLE QVariantMap loadAllSettings() const;
    Q_INVOKABLE void saveAllSettings(const QVariantMap &config);

    Q_INVOKABLE QVariantMap getChannelConfig(int channel) const;
    Q_INVOKABLE void saveChannelConfig(int channel, const QVariantMap &config);

    Q_INVOKABLE void applyLinearPreset(int channel, const QString &presetName);
    Q_INVOKABLE void applyNtcPreset(int channel, const QString &presetName);

    Q_INVOKABLE QVariantMap loadBoardConfig() const;
    Q_INVOKABLE void saveBoardConfig(const QVariantMap &config);
    Q_INVOKABLE QVariantMap loadBrightnessConfig() const;
    Q_INVOKABLE void saveBrightnessConfig(const QVariantMap &config);

    Q_INVOKABLE QStringList channelNames() const;
    Q_INVOKABLE QStringList digitalChannelNames() const;

    Q_INVOKABLE QVariantMap getDifferentialSensorConfig() const;
    Q_INVOKABLE void saveDifferentialSensorConfig(const QVariantMap &config);

signals:
    void configChanged();

private:
    AppSettings *m_appSettings = nullptr;
    CalibrationHelper *m_calibrationHelper = nullptr;
    SensorRegistry *m_sensorRegistry = nullptr;

    static const QString s_linearKeys[kAnalogChannels][2];
    static const QString s_linearPresetKeys[kAnalogChannels];
    static const QString s_ntcPresetKeys[kNtcChannels];
    static const QString s_ntcOnKeys[kNtcChannels];
    static const QString s_divider100Keys[kNtcChannels];
    static const QString s_divider1kKeys[kNtcChannels];
    static const QString s_steinhartTKeys[kNtcChannels][3];
    static const QString s_steinhartRKeys[kNtcChannels][3];
    static const QString s_channelNameKeys[kAnalogChannels];
    static const QString s_digitalNameKeys[kDigitalChannels];
    static const QString s_channelEnableKeys[kAnalogChannels];
    static const QString s_digitalEnableKeys[kDigitalChannels];

    QVariantMap getDigitalChannelConfig(int channel) const;
    void saveChannelConfigInternal(int channel, const QVariantMap &config);
    void saveDigitalChannelConfigInternal(int channel, const QVariantMap &config);
    void applyAnalogRuntimeSettings() const;
    void refreshSensorRegistry() const;
    void syncChannelSensorMetadata(int channel) const;
};

#endif  // EXBOARDCONFIGMANAGER_H
