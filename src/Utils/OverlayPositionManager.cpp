#include "OverlayPositionManager.h"

OverlayPositionManager::OverlayPositionManager(QObject *parent)
    : QObject(parent), m_positionsLocked(false), m_settings(AppConstants::ORG_NAME, AppConstants::APP_NAME)
{
    m_positionsLocked = m_settings.value(QStringLiteral("ui/overlayPositionsLocked"), false).toBool();
    m_syncTimer.setSingleShot(true);
    m_syncTimer.setInterval(500);
    connect(&m_syncTimer, &QTimer::timeout, this, [this]() { m_settings.sync(); });
}

void OverlayPositionManager::savePosition(const QString &overlayId, qreal x, qreal y)
{
    m_settings.beginGroup(QStringLiteral("overlayPos"));
    m_settings.setValue(overlayId + QStringLiteral("/x"), x);
    m_settings.setValue(overlayId + QStringLiteral("/y"), y);
    m_settings.endGroup();
    m_syncTimer.start();
}

QVariantMap OverlayPositionManager::getPosition(const QString &overlayId) const
{
    m_settings.beginGroup(QStringLiteral("overlayPos"));
    m_settings.beginGroup(overlayId);

    QVariantMap pos;
    if (m_settings.contains(QStringLiteral("x"))) {
        pos[QStringLiteral("x")] = m_settings.value(QStringLiteral("x"), 0).toDouble();
        pos[QStringLiteral("y")] = m_settings.value(QStringLiteral("y"), 0).toDouble();
    }

    m_settings.endGroup();
    m_settings.endGroup();
    return pos;
}

void OverlayPositionManager::resetAllPositions()
{
    m_settings.remove(QStringLiteral("overlayPos"));
    m_settings.sync();
    emit positionsReset();
}

bool OverlayPositionManager::positionsLocked() const
{
    return m_positionsLocked;
}

void OverlayPositionManager::setPositionsLocked(bool locked)
{
    if (m_positionsLocked != locked) {
        m_positionsLocked = locked;
        m_settings.setValue(QStringLiteral("ui/overlayPositionsLocked"), locked);
        m_settings.sync();
        emit positionsLockedChanged();
    }
}
