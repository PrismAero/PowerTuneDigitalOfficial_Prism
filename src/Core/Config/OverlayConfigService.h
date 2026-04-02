#ifndef OVERLAYCONFIGSERVICE_H
#define OVERLAYCONFIGSERVICE_H

#include <QObject>
#include <QStringList>
#include <QVariantMap>

class AppSettings;
class OverlayConfigDefaults;

class OverlayConfigService : public QObject
{
    Q_OBJECT

public:
    explicit OverlayConfigService(QObject *parent = nullptr);

    void setAppSettings(AppSettings *settings) { m_appSettings = settings; }
    void setDefaults(OverlayConfigDefaults *defaults) { m_defaults = defaults; }

    Q_INVOKABLE QVariantMap migrateAndLoadConfigs(const QString &dashboardId, const QStringList &overlayIds);
    Q_INVOKABLE QVariantMap prepareOverlayEditorConfig(const QString &dashboardId, const QString &overlayId,
                                                       const QString &configType);
    Q_INVOKABLE QVariantMap buildOverlayConfig(const QString &configType, const QVariantMap &uiState) const;
    Q_INVOKABLE QString normalizeAnalogSensorKey(const QString &key) const;

private:
    struct OverlayDefinition
    {
        QString id;
        QStringList legacyIds;
    };

    bool objectHasKeys(const QVariantMap &map) const;
    bool boolValue(const QVariantMap &map, const QString &key, bool fallback) const;
    void mergeConfig(QVariantMap &target, const QVariantMap &source) const;
    QVariantMap loadWithLegacyFallback(const QString &dashboardId, const QString &overlayId, const QString &configType);
    QList<OverlayDefinition> overlayDefinitions() const;

    AppSettings *m_appSettings = nullptr;
    OverlayConfigDefaults *m_defaults = nullptr;
};

#endif  // OVERLAYCONFIGSERVICE_H
