#ifndef PTEXTENDERCONFIGMANAGER_H
#define PTEXTENDERCONFIGMANAGER_H

#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

class AppSettings;
class PTExtenderCan;

class PTExtenderConfigManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList suppressedCodesList READ suppressedCodesList NOTIFY suppressedCodesChanged)

public:
    explicit PTExtenderConfigManager(QObject *parent = nullptr);

    void setAppSettings(AppSettings *settings) { m_appSettings = settings; }
    void setPTExtenderCan(PTExtenderCan *can) { m_ptExtenderCan = can; }

    Q_INVOKABLE QVariantMap loadAllSettings() const;
    Q_INVOKABLE void saveAllSettings(const QVariantMap &config);

    Q_INVOKABLE bool syncToDevice();
    Q_INVOKABLE bool syncFromDevice();
    Q_INVOKABLE bool saveToDeviceEeprom();

    Q_INVOKABLE void suppressCode(int code);
    Q_INVOKABLE void unsuppressCode(int code);
    Q_INVOKABLE bool isCodeSuppressed(int code) const;
    Q_INVOKABLE QVariantList suppressedCodes() const;
    Q_INVOKABLE void suppressAllKnownCodes();
    Q_INVOKABLE void enableAllCodes();
    QStringList suppressedCodesList() const;

signals:
    void configChanged();
    void suppressedCodesChanged();

private:
    AppSettings *m_appSettings = nullptr;
    PTExtenderCan *m_ptExtenderCan = nullptr;

    static QStringList parseSuppressedCodes(const QString &csv);
    static QString toSuppressedCodesCsv(const QStringList &codes);
};

#endif  // PTEXTENDERCONFIGMANAGER_H
