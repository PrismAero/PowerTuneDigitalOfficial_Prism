#ifndef PTEXTENDERCONFIGMANAGER_H
#define PTEXTENDERCONFIGMANAGER_H

#include <QMap>
#include <QObject>
#include <QStringList>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>

class AppSettings;
class PTExtenderCan;

class PTExtenderConfigManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList suppressedCodesList READ suppressedCodesList NOTIFY suppressedCodesChanged)
    Q_PROPERTY(bool configModeActive READ configModeActive NOTIFY configModeActiveChanged)
    Q_PROPERTY(bool metadataLoaded READ metadataLoaded NOTIFY metadataLoadedChanged)

public:
    explicit PTExtenderConfigManager(QObject *parent = nullptr);

    void setAppSettings(AppSettings *settings) { m_appSettings = settings; }
    void setPTExtenderCan(PTExtenderCan *can);

    Q_INVOKABLE QVariantMap loadAllSettings() const;
    Q_INVOKABLE void saveAllSettings(const QVariantMap &config);

    Q_INVOKABLE bool syncToDevice();
    Q_INVOKABLE bool syncFromDevice();
    Q_INVOKABLE bool saveToDeviceEeprom();
    Q_INVOKABLE bool writeLedChannel(int channel);
    Q_INVOKABLE bool writeAllLedChannels();
    Q_INVOKABLE QString ledStorageKey(int channel, const QString &suffix) const;
    Q_INVOKABLE QString rgbToHex(int r, int g, int b) const;
    Q_INVOKABLE QVariantMap hexToRgb(const QString &hex, int fallbackR, int fallbackG, int fallbackB) const;

    Q_INVOKABLE void suppressCode(int code);
    Q_INVOKABLE void unsuppressCode(int code);
    Q_INVOKABLE bool isCodeSuppressed(int code) const;
    Q_INVOKABLE QVariantList suppressedCodes() const;
    Q_INVOKABLE void suppressAllKnownCodes();
    Q_INVOKABLE void enableAllCodes();
    QStringList suppressedCodesList() const;

    bool configModeActive() const { return m_configModeActive; }
    bool metadataLoaded() const { return m_metadataLoaded; }

    Q_INVOKABLE void enterConfigMode();
    Q_INVOKABLE void exitConfigMode();
    Q_INVOKABLE void saveAndReboot();

    Q_INVOKABLE QStringList gpiFunctionNames() const;
    Q_INVOKABLE QStringList relayFunctionNames() const;
    Q_INVOKABLE QStringList logicConditionNames() const;
    Q_INVOKABLE QStringList ledPatternNames() const;
    Q_INVOKABLE QStringList ledTypeNames() const;

    Q_INVOKABLE bool writeIndicatorProfile(int profile);
    Q_INVOKABLE bool writeIndicatorStateEffect(int profile, int state);

signals:
    void configChanged();
    void suppressedCodesChanged();
    void configModeActiveChanged();
    void metadataLoadedChanged();

private slots:
    void onMetadataReceived(int category, int totalCount, int optionIndex, int chunkIndex, const QByteArray &data);

private:
    AppSettings *m_appSettings = nullptr;
    PTExtenderCan *m_ptExtenderCan = nullptr;

    bool m_configModeActive = false;
    bool m_metadataLoaded = false;
    QMap<int, QStringList> m_metadata;
    QMap<int, QMap<int, QString>> m_assemblyBuffer;
    int m_expectedCounts[5] = {0, 0, 0, 0, 0};
    QTimer m_rebootTimer;

    void checkMetadataComplete();

    static QStringList parseSuppressedCodes(const QString &csv);
    static QString toSuppressedCodesCsv(const QStringList &codes);
    static int clampByte(int value);
};

#endif  // PTEXTENDERCONFIGMANAGER_H
