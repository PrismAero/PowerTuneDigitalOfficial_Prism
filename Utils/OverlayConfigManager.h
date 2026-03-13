#ifndef OVERLAYCONFIGMANAGER_H
#define OVERLAYCONFIGMANAGER_H

#include <QObject>
#include <QSettings>
#include <QVariantMap>

class OverlayConfigManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool positionsLocked READ positionsLocked WRITE setPositionsLocked NOTIFY positionsLockedChanged)

public:
    explicit OverlayConfigManager(QObject *parent = nullptr);

    Q_INVOKABLE QVariantMap getConfig(const QString &overlayId) const;
    Q_INVOKABLE void saveConfig(const QString &overlayId, const QVariantMap &config);
    Q_INVOKABLE void resetConfig(const QString &overlayId);
    Q_INVOKABLE QStringList configKeys(const QString &overlayId) const;

    Q_INVOKABLE QVariantMap getConfigForPopup(const QString &overlayId, const QString &configType) const;
    Q_INVOKABLE void saveConfigFromPopup(const QString &overlayId, const QString &configType,
                                         const QVariantMap &fields);
    Q_INVOKABLE QVariantMap getOverlayProperties(const QString &overlayId) const;

    Q_INVOKABLE void savePosition(const QString &overlayId, qreal x, qreal y);
    Q_INVOKABLE QVariantMap getPosition(const QString &overlayId) const;
    Q_INVOKABLE void resetAllPositions();

    bool positionsLocked() const;
    void setPositionsLocked(bool locked);

signals:
    void configChanged(const QString &overlayId);
    void positionsLockedChanged();
    void positionsReset();

private:
    static constexpr const char *ORG_NAME = "PowerTune";
    static constexpr const char *APP_NAME = "PowerTune";
    bool m_positionsLocked = false;

    QString prefix(const QString &overlayId) const;
};

#endif  // OVERLAYCONFIGMANAGER_H
