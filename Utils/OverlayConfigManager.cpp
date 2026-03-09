#include "OverlayConfigManager.h"

OverlayConfigManager::OverlayConfigManager(QObject *parent)
    : QObject(parent)
    , m_positionsLocked(false)
{
    QSettings settings(ORG_NAME, APP_NAME);
    m_positionsLocked = settings.value(QStringLiteral("ui/overlayPositionsLocked"), false).toBool();
}

QString OverlayConfigManager::prefix(const QString &overlayId) const
{
    return QStringLiteral("overlay/%1/").arg(overlayId);
}

QVariantMap OverlayConfigManager::getConfig(const QString &overlayId) const
{
    QSettings settings(ORG_NAME, APP_NAME);
    QVariantMap config;
    const QString p = prefix(overlayId);

    settings.beginGroup(QStringLiteral("overlay"));
    settings.beginGroup(overlayId);

    const QStringList keys = settings.childKeys();
    for (const QString &key : keys)
        config.insert(key, settings.value(key));

    settings.endGroup();
    settings.endGroup();

    return config;
}

void OverlayConfigManager::saveConfig(const QString &overlayId, const QVariantMap &config)
{
    QSettings settings(ORG_NAME, APP_NAME);

    settings.beginGroup(QStringLiteral("overlay"));
    settings.beginGroup(overlayId);

    for (auto it = config.constBegin(); it != config.constEnd(); ++it)
        settings.setValue(it.key(), it.value());

    settings.endGroup();
    settings.endGroup();
    settings.sync();

    emit configChanged(overlayId);
}

void OverlayConfigManager::resetConfig(const QString &overlayId)
{
    QSettings settings(ORG_NAME, APP_NAME);

    settings.beginGroup(QStringLiteral("overlay"));
    settings.remove(overlayId);
    settings.endGroup();
    settings.sync();

    emit configChanged(overlayId);
}

QStringList OverlayConfigManager::configKeys(const QString &overlayId) const
{
    QSettings settings(ORG_NAME, APP_NAME);

    settings.beginGroup(QStringLiteral("overlay"));
    settings.beginGroup(overlayId);
    QStringList keys = settings.childKeys();
    settings.endGroup();
    settings.endGroup();

    return keys;
}

void OverlayConfigManager::savePosition(const QString &overlayId, qreal x, qreal y)
{
    QSettings settings(ORG_NAME, APP_NAME);
    settings.beginGroup(QStringLiteral("overlayPos"));
    settings.setValue(overlayId + QStringLiteral("/x"), x);
    settings.setValue(overlayId + QStringLiteral("/y"), y);
    settings.endGroup();
    settings.sync();
}

QVariantMap OverlayConfigManager::getPosition(const QString &overlayId) const
{
    QSettings settings(ORG_NAME, APP_NAME);
    settings.beginGroup(QStringLiteral("overlayPos"));
    settings.beginGroup(overlayId);

    QVariantMap pos;
    if (settings.contains(QStringLiteral("x"))) {
        pos[QStringLiteral("x")] = settings.value(QStringLiteral("x"));
        pos[QStringLiteral("y")] = settings.value(QStringLiteral("y"));
    }

    settings.endGroup();
    settings.endGroup();
    return pos;
}

void OverlayConfigManager::resetAllPositions()
{
    QSettings settings(ORG_NAME, APP_NAME);
    settings.remove(QStringLiteral("overlayPos"));
    settings.sync();
    emit positionsReset();
}

bool OverlayConfigManager::positionsLocked() const
{
    return m_positionsLocked;
}

void OverlayConfigManager::setPositionsLocked(bool locked)
{
    if (m_positionsLocked != locked) {
        m_positionsLocked = locked;
        QSettings settings(ORG_NAME, APP_NAME);
        settings.setValue(QStringLiteral("ui/overlayPositionsLocked"), locked);
        settings.sync();
        emit positionsLockedChanged();
    }
}
