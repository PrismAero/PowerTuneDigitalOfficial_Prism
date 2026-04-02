#ifndef OVERLAYPOSITIONMANAGER_H
#define OVERLAYPOSITIONMANAGER_H

#include <QObject>
#include <QSettings>
#include <QVariantMap>

#include "../Core/AppConstants.h"

class OverlayPositionManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool positionsLocked READ positionsLocked WRITE setPositionsLocked NOTIFY positionsLockedChanged)

public:
    explicit OverlayPositionManager(QObject *parent = nullptr);

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
    bool m_positionsLocked = false;
    mutable QSettings m_settings;
};

#endif  // OVERLAYPOSITIONMANAGER_H
