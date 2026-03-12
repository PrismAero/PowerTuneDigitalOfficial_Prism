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
    for (const QString &key : keys) {
        QVariant val = settings.value(key);
        if (val.isValid())
            config.insert(key, val);
    }

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
        pos[QStringLiteral("x")] = settings.value(QStringLiteral("x"), 0).toDouble();
        pos[QStringLiteral("y")] = settings.value(QStringLiteral("y"), 0).toDouble();
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

QVariantMap OverlayConfigManager::getConfigForPopup(const QString &overlayId, const QString &configType) const
{
    QVariantMap cfg = getConfig(overlayId);
    QVariantMap result;

    result[QStringLiteral("sensorKey")] = cfg.value(QStringLiteral("sensorKey"), QString());
    result[QStringLiteral("label")] = cfg.value(QStringLiteral("label"), QString());
    result[QStringLiteral("unit")] = cfg.value(QStringLiteral("unit"), QString());
    result[QStringLiteral("threshold")] = cfg.value(QStringLiteral("threshold"), 0.5).toDouble();
    result[QStringLiteral("minValue")] = cfg.value(QStringLiteral("minValue"), 0.0).toDouble();
    result[QStringLiteral("decimals")] = cfg.value(QStringLiteral("decimals"), 0).toInt();
    result[QStringLiteral("arcColorStart")] = cfg.value(QStringLiteral("arcColorStart"), QString());
    result[QStringLiteral("arcColorEnd")] = cfg.value(QStringLiteral("arcColorEnd"), QString());
    result[QStringLiteral("gearKey")] = cfg.value(QStringLiteral("gearKey"), QStringLiteral("Gear"));
    result[QStringLiteral("shiftPattern")] = cfg.value(QStringLiteral("shiftPattern"), QStringLiteral("center-out"));
    result[QStringLiteral("text")] = cfg.value(QStringLiteral("text"), QString());

    QSettings appSettings(ORG_NAME, APP_NAME);

    if (configType == QLatin1String("tachGroup") || configType == QLatin1String("tachCluster")) {
        double maxRpm = cfg.value(QStringLiteral("maxValue"), 0.0).toDouble();
        if (maxRpm <= 0.0) {
            maxRpm = appSettings.value(QStringLiteral("Max RPM"), 10000).toDouble();
            if (maxRpm <= 0.0) maxRpm = 10000.0;
        }
        result[QStringLiteral("maxValue")] = maxRpm;

        double shiftPoint = cfg.value(QStringLiteral("shiftPoint"), -1.0).toDouble();
        if (shiftPoint <= 0.0) {
            double s1 = appSettings.value(QStringLiteral("Shift Light1"), 3000).toDouble();
            shiftPoint = maxRpm > 0.0 ? s1 / maxRpm : 0.75;
        }
        result[QStringLiteral("shiftPoint")] = shiftPoint;
        result[QStringLiteral("shiftCount")] = cfg.value(QStringLiteral("shiftCount"), 11).toInt();
    } else {
        result[QStringLiteral("maxValue")] = cfg.value(QStringLiteral("maxValue"), 100.0).toDouble();
        result[QStringLiteral("shiftPoint")] = cfg.value(QStringLiteral("shiftPoint"), 0.75).toDouble();
        result[QStringLiteral("shiftCount")] = cfg.value(QStringLiteral("shiftCount"), 11).toInt();
    }

    return result;
}

void OverlayConfigManager::saveConfigFromPopup(const QString &overlayId, const QString &configType, const QVariantMap &fields)
{
    QVariantMap cfg;

    if (configType == QLatin1String("sensorCard")) {
        cfg[QStringLiteral("sensorKey")] = fields.value(QStringLiteral("sensorKey"));
        cfg[QStringLiteral("label")] = fields.value(QStringLiteral("label"));
        cfg[QStringLiteral("unit")] = fields.value(QStringLiteral("unit"));
        cfg[QStringLiteral("decimals")] = fields.value(QStringLiteral("decimals"));
    } else if (configType == QLatin1String("statusRow")) {
        cfg[QStringLiteral("sensorKey")] = fields.value(QStringLiteral("sensorKey"));
        cfg[QStringLiteral("label")] = fields.value(QStringLiteral("label"));
        cfg[QStringLiteral("threshold")] = fields.value(QStringLiteral("threshold"));
    } else if (configType == QLatin1String("tachGroup") || configType == QLatin1String("tachCluster")) {
        cfg[QStringLiteral("sensorKey")] = fields.value(QStringLiteral("sensorKey"));
        cfg[QStringLiteral("minValue")] = fields.value(QStringLiteral("minValue"));
        cfg[QStringLiteral("maxValue")] = fields.value(QStringLiteral("maxValue"));
        cfg[QStringLiteral("unit")] = fields.value(QStringLiteral("unit"));
        cfg[QStringLiteral("arcColorStart")] = fields.value(QStringLiteral("arcColorStart"));
        cfg[QStringLiteral("arcColorEnd")] = fields.value(QStringLiteral("arcColorEnd"));
        cfg[QStringLiteral("gearKey")] = fields.value(QStringLiteral("gearKey"));
        cfg[QStringLiteral("gearTextColor")] = fields.value(QStringLiteral("gearTextColor"));
        cfg[QStringLiteral("gearFontSize")] = fields.value(QStringLiteral("gearFontSize"));
        cfg[QStringLiteral("suffixFontSize")] = fields.value(QStringLiteral("suffixFontSize"));
        cfg[QStringLiteral("gearOffsetX")] = fields.value(QStringLiteral("gearOffsetX"));
        cfg[QStringLiteral("gearOffsetY")] = fields.value(QStringLiteral("gearOffsetY"));
        cfg[QStringLiteral("gearWidth")] = fields.value(QStringLiteral("gearWidth"));
        cfg[QStringLiteral("gearHeight")] = fields.value(QStringLiteral("gearHeight"));
        cfg[QStringLiteral("readoutStep")] = fields.value(QStringLiteral("readoutStep"));
        cfg[QStringLiteral("readoutOffsetX")] = fields.value(QStringLiteral("readoutOffsetX"));
        cfg[QStringLiteral("readoutOffsetY")] = fields.value(QStringLiteral("readoutOffsetY"));
        cfg[QStringLiteral("readoutValueScale")] = fields.value(QStringLiteral("readoutValueScale"));
        cfg[QStringLiteral("readoutUnitScale")] = fields.value(QStringLiteral("readoutUnitScale"));
        cfg[QStringLiteral("readoutTextColor")] = fields.value(QStringLiteral("readoutTextColor"));
        cfg[QStringLiteral("shiftPoint")] = fields.value(QStringLiteral("shiftPoint"));
        cfg[QStringLiteral("shiftCount")] = fields.value(QStringLiteral("shiftCount"));
        cfg[QStringLiteral("shiftPattern")] = fields.value(QStringLiteral("shiftPattern"));
        cfg[QStringLiteral("decimals")] = fields.value(QStringLiteral("decimals"));
    } else if (configType == QLatin1String("speedGroup") || configType == QLatin1String("speedCluster")) {
        cfg[QStringLiteral("sensorKey")] = fields.value(QStringLiteral("sensorKey"));
        cfg[QStringLiteral("minValue")] = fields.value(QStringLiteral("minValue"));
        cfg[QStringLiteral("maxValue")] = fields.value(QStringLiteral("maxValue"));
        cfg[QStringLiteral("unit")] = fields.value(QStringLiteral("unit"));
        cfg[QStringLiteral("arcColorStart")] = fields.value(QStringLiteral("arcColorStart"));
        cfg[QStringLiteral("arcColorEnd")] = fields.value(QStringLiteral("arcColorEnd"));
        cfg[QStringLiteral("readoutStep")] = fields.value(QStringLiteral("readoutStep"));
        cfg[QStringLiteral("readoutOffsetX")] = fields.value(QStringLiteral("readoutOffsetX"));
        cfg[QStringLiteral("readoutOffsetY")] = fields.value(QStringLiteral("readoutOffsetY"));
        cfg[QStringLiteral("readoutValueScale")] = fields.value(QStringLiteral("readoutValueScale"));
        cfg[QStringLiteral("readoutUnitScale")] = fields.value(QStringLiteral("readoutUnitScale"));
        cfg[QStringLiteral("readoutTextColor")] = fields.value(QStringLiteral("readoutTextColor"));
        cfg[QStringLiteral("decimals")] = fields.value(QStringLiteral("decimals"));
    } else if (configType == QLatin1String("staticText")) {
        cfg[QStringLiteral("text")] = fields.value(QStringLiteral("text"));
    }

    saveConfig(overlayId, cfg);
}

QVariantMap OverlayConfigManager::getOverlayProperties(const QString &overlayId) const
{
    QVariantMap cfg = getConfig(overlayId);
    QVariantMap result;
    QSettings appSettings(ORG_NAME, APP_NAME);

    auto strVal = [&](const QString &key, const QString &def) -> QString {
        return cfg.value(key, def).toString();
    };
    auto dblVal = [&](const QString &key, double def) -> double {
        QVariant v = cfg.value(key);
        return v.isValid() ? v.toDouble() : def;
    };
    auto intVal = [&](const QString &key, int def) -> int {
        QVariant v = cfg.value(key);
        return v.isValid() ? v.toInt() : def;
    };

    if (overlayId == QLatin1String("waterTemp")) {
        result[QStringLiteral("sensorKey")] = strVal(QStringLiteral("sensorKey"), QStringLiteral("Watertemp"));
        result[QStringLiteral("label")] = strVal(QStringLiteral("label"), QStringLiteral("Water Temp"));
        result[QStringLiteral("unit")] = strVal(QStringLiteral("unit"), QStringLiteral("F\u00B0"));
        result[QStringLiteral("decimals")] = intVal(QStringLiteral("decimals"), 2);
    } else if (overlayId == QLatin1String("oilPressure")) {
        result[QStringLiteral("sensorKey")] = strVal(QStringLiteral("sensorKey"), QStringLiteral("oilpres"));
        result[QStringLiteral("label")] = strVal(QStringLiteral("label"), QStringLiteral("Oil Pressure"));
        result[QStringLiteral("unit")] = strVal(QStringLiteral("unit"), QStringLiteral("PSI"));
        result[QStringLiteral("decimals")] = intVal(QStringLiteral("decimals"), 2);
    } else if (overlayId == QLatin1String("statusRow0")) {
        result[QStringLiteral("sensorKey")] = strVal(QStringLiteral("sensorKey"), QStringLiteral("DigitalInput1"));
        result[QStringLiteral("label")] = strVal(QStringLiteral("label"), QStringLiteral("Digital 1:"));
        result[QStringLiteral("threshold")] = dblVal(QStringLiteral("threshold"), 0.5);
    } else if (overlayId == QLatin1String("statusRow1")) {
        result[QStringLiteral("sensorKey")] = strVal(QStringLiteral("sensorKey"), QStringLiteral("DigitalInput2"));
        result[QStringLiteral("label")] = strVal(QStringLiteral("label"), QStringLiteral("Digital 2:"));
        result[QStringLiteral("threshold")] = dblVal(QStringLiteral("threshold"), 0.5);
    } else if (overlayId == QLatin1String("tachGroup") || overlayId == QLatin1String("tachCluster")) {
        double defMax = appSettings.value(QStringLiteral("Max RPM"), 10000).toDouble();
        if (defMax <= 0.0) defMax = 10000.0;
        double s1 = appSettings.value(QStringLiteral("Shift Light1"), 3000).toDouble();
        double defShift = defMax > 0.0 ? s1 / defMax : 0.75;

        result[QStringLiteral("sensorKey")] = strVal(QStringLiteral("sensorKey"), QStringLiteral("rpm"));
        result[QStringLiteral("minValue")] = dblVal(QStringLiteral("minValue"), 0.0);
        result[QStringLiteral("maxValue")] = dblVal(QStringLiteral("maxValue"), defMax);
        result[QStringLiteral("unit")] = strVal(QStringLiteral("unit"), QStringLiteral("RPM"));
        result[QStringLiteral("arcColorStart")] = strVal(QStringLiteral("arcColorStart"), QStringLiteral("#E88A1A"));
        result[QStringLiteral("arcColorEnd")] = strVal(QStringLiteral("arcColorEnd"), QStringLiteral("#C45A00"));
        result[QStringLiteral("gearKey")] = strVal(QStringLiteral("gearKey"), QStringLiteral("Gear"));
        result[QStringLiteral("gearTextColor")] = strVal(QStringLiteral("gearTextColor"), QStringLiteral("#FFFFFF"));
        result[QStringLiteral("gearFontSize")] = dblVal(QStringLiteral("gearFontSize"), 140.013);
        result[QStringLiteral("suffixFontSize")] = dblVal(QStringLiteral("suffixFontSize"), 52.505);
        result[QStringLiteral("gearOffsetX")] = dblVal(QStringLiteral("gearOffsetX"), 21.5);
        result[QStringLiteral("gearOffsetY")] = dblVal(QStringLiteral("gearOffsetY"), -76.0);
        result[QStringLiteral("gearWidth")] = dblVal(QStringLiteral("gearWidth"), 168.0);
        result[QStringLiteral("gearHeight")] = dblVal(QStringLiteral("gearHeight"), 117.0);
        result[QStringLiteral("readoutStep")] = dblVal(QStringLiteral("readoutStep"), 1.0);
        result[QStringLiteral("readoutOffsetX")] = dblVal(QStringLiteral("readoutOffsetX"), 0.0);
        result[QStringLiteral("readoutOffsetY")] = dblVal(QStringLiteral("readoutOffsetY"), 94.0);
        result[QStringLiteral("readoutValueScale")] = dblVal(QStringLiteral("readoutValueScale"), 0.213);
        result[QStringLiteral("readoutUnitScale")] = dblVal(QStringLiteral("readoutUnitScale"), 0.076);
        result[QStringLiteral("readoutTextColor")] = strVal(QStringLiteral("readoutTextColor"), QStringLiteral("#FFFFFF"));
        result[QStringLiteral("shiftPoint")] = dblVal(QStringLiteral("shiftPoint"), defShift);
        result[QStringLiteral("shiftCount")] = intVal(QStringLiteral("shiftCount"), 11);
        result[QStringLiteral("shiftPattern")] = strVal(QStringLiteral("shiftPattern"), QStringLiteral("center-out"));
        result[QStringLiteral("decimals")] = intVal(QStringLiteral("decimals"), 0);
    } else if (overlayId == QLatin1String("speedGroup") || overlayId == QLatin1String("speedCluster")) {
        result[QStringLiteral("sensorKey")] = strVal(QStringLiteral("sensorKey"), QStringLiteral("speed"));
        result[QStringLiteral("minValue")] = dblVal(QStringLiteral("minValue"), 0.0);
        result[QStringLiteral("maxValue")] = dblVal(QStringLiteral("maxValue"), 200.0);
        result[QStringLiteral("unit")] = strVal(QStringLiteral("unit"), QStringLiteral("MPH"));
        result[QStringLiteral("arcColorStart")] = strVal(QStringLiteral("arcColorStart"), QStringLiteral("#AA1111"));
        result[QStringLiteral("arcColorEnd")] = strVal(QStringLiteral("arcColorEnd"), QStringLiteral("#880000"));
        result[QStringLiteral("readoutStep")] = dblVal(QStringLiteral("readoutStep"), 1.0);
        result[QStringLiteral("readoutOffsetX")] = dblVal(QStringLiteral("readoutOffsetX"), 0.0);
        result[QStringLiteral("readoutOffsetY")] = dblVal(QStringLiteral("readoutOffsetY"), 62.0);
        result[QStringLiteral("readoutValueScale")] = dblVal(QStringLiteral("readoutValueScale"), 0.213);
        result[QStringLiteral("readoutUnitScale")] = dblVal(QStringLiteral("readoutUnitScale"), 0.076);
        result[QStringLiteral("readoutTextColor")] = strVal(QStringLiteral("readoutTextColor"), QStringLiteral("#FFFFFF"));
        result[QStringLiteral("decimals")] = intVal(QStringLiteral("decimals"), 0);
    } else if (overlayId == QLatin1String("bottomBar")) {
        result[QStringLiteral("text")] = strVal(QStringLiteral("text"), QStringLiteral("Cardinal Racing"));
    }

    return result;
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
