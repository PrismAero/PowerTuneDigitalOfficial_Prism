#include "AppSettings.h"

void AppSettings::writeDashboardConfig(int index, const QString &bgPicture, const QString &bgColor)
{
    QString prefix = QString("dashboard_%1/").arg(index);
    setValue(prefix + "backgroundPicture", bgPicture);
    setValue(prefix + "backgroundColor", bgColor);
}

QVariantMap AppSettings::loadDashboardConfig(int index) const
{
    QString prefix = QString("dashboard_%1/").arg(index);
    QVariantMap config;
    config["backgroundPicture"] = getValue(prefix + "backgroundPicture", "");
    config["backgroundColor"] = getValue(prefix + "backgroundColor", "#000000");
    return config;
}

void AppSettings::saveOverlayConfig(const QString &dashboardId, const QString &overlayId, const QVariantMap &config)
{
    const QString prefix = QStringLiteral("overlay/%1/%2/").arg(dashboardId, overlayId);
    for (auto it = config.constBegin(); it != config.constEnd(); ++it) {
        const QString fullKey = prefix + it.key();
        m_settings.setValue(fullKey, it.value());
        m_cache.insert(fullKey, it.value());
    }
    m_dirty = true;
    scheduleSync();
}

QVariantMap AppSettings::loadOverlayConfig(const QString &dashboardId, const QString &overlayId)
{
    QVariantMap config;
    const QString group = QStringLiteral("overlay/%1/%2").arg(dashboardId, overlayId);
    m_settings.beginGroup(group);
    const QStringList keys = m_settings.childKeys();
    for (const QString &key : keys) {
        const QVariant value = m_settings.value(key);
        config.insert(key, value);
        m_cache.insert(group + QLatin1Char('/') + key, value);
    }
    m_settings.endGroup();
    return config;
}

QVariantMap AppSettings::loadOverlayConfigs(const QString &dashboardId, const QStringList &overlayIds)
{
    QVariantMap allConfigs;
    for (const QString &overlayId : overlayIds) {
        QVariantMap config;
        const QString group = QStringLiteral("overlay/%1/%2").arg(dashboardId, overlayId);
        m_settings.beginGroup(group);
        const QStringList keys = m_settings.childKeys();
        for (const QString &key : keys) {
            const QVariant value = m_settings.value(key);
            config.insert(key, value);
            m_cache.insert(group + QLatin1Char('/') + key, value);
        }
        m_settings.endGroup();
        allConfigs.insert(overlayId, config);
    }
    return allConfigs;
}

void AppSettings::removeOverlayConfig(const QString &dashboardId, const QString &overlayId)
{
    const QString group = QStringLiteral("overlay/%1/%2").arg(dashboardId, overlayId);
    m_settings.beginGroup(group);
    m_settings.remove(QString());
    m_settings.endGroup();

    for (auto it = m_cache.begin(); it != m_cache.end();) {
        if (it.key().startsWith(group + QLatin1Char('/'))) {
            it = m_cache.erase(it);
        } else {
            ++it;
        }
    }

    m_dirty = true;
    scheduleSync();
}
