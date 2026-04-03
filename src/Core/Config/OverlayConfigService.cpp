#include "OverlayConfigService.h"

#include "AppSettings.h"
#include "OverlayConfigDefaults.h"
#include <QRegularExpression>

namespace {
QString canonicalType(const QString &configType)
{
    const QString trimmed = configType.trimmed();
    if (trimmed == QLatin1String("brakebias"))
        return QStringLiteral("brakeBias");
    if (trimmed == QLatin1String("bottombar"))
        return QStringLiteral("bottomBar");
    if (trimmed == QLatin1String("shift"))
        return QStringLiteral("shiftIndicator");
    if (trimmed == QLatin1String("statusRow"))
        return QStringLiteral("statusRow");
    return trimmed;
}
}

OverlayConfigService::OverlayConfigService(QObject *parent) : QObject(parent) {}

QList<OverlayConfigService::OverlayDefinition> OverlayConfigService::overlayDefinitions() const
{
    return {{QStringLiteral("tachCluster"), {QStringLiteral("tachGroup"), QStringLiteral("gearIndicator")}},
            {QStringLiteral("speedCluster"), {QStringLiteral("speedGroup")}},
            {QStringLiteral("shiftIndicator"), {}},
            {QStringLiteral("waterTemp"), {}},
            {QStringLiteral("oilPressure"), {}},
            {QStringLiteral("statusRow0"), {}},
            {QStringLiteral("statusRow1"), {}},
            {QStringLiteral("brakeBias"), {}},
            {QStringLiteral("bottomBar"), {}}};
}

bool OverlayConfigService::objectHasKeys(const QVariantMap &map) const
{
    return !map.isEmpty();
}

void OverlayConfigService::mergeConfig(QVariantMap &target, const QVariantMap &source) const
{
    for (auto it = source.constBegin(); it != source.constEnd(); ++it)
        target.insert(it.key(), it.value());
}

QString OverlayConfigService::normalizeAnalogSensorKey(const QString &key) const
{
    const QString trimmed = key.trimmed();
    static const QRegularExpression re(QStringLiteral("^EXAnalogInput([0-7])$"));
    const QRegularExpressionMatch match = re.match(trimmed);
    if (match.hasMatch())
        return QStringLiteral("EXAnalogCalc%1").arg(match.captured(1));
    return trimmed;
}

QVariantMap OverlayConfigService::loadWithLegacyFallback(const QString &dashboardId, const QString &overlayId,
                                                         const QString &configType)
{
    if (!m_appSettings)
        return {};

    QVariantMap loaded = m_appSettings->loadOverlayConfig(dashboardId, overlayId);
    if (objectHasKeys(loaded))
        return loaded;

    if (configType == QLatin1String("tachCluster")) {
        loaded = m_appSettings->loadOverlayConfig(dashboardId, QStringLiteral("tachGroup"));
        const QVariantMap legacyGear = m_appSettings->loadOverlayConfig(dashboardId, QStringLiteral("gearIndicator"));
        mergeConfig(loaded, legacyGear);
        return loaded;
    }
    if (configType == QLatin1String("speedCluster"))
        return m_appSettings->loadOverlayConfig(dashboardId, QStringLiteral("speedGroup"));
    return loaded;
}

QVariantMap OverlayConfigService::prepareOverlayEditorConfig(const QString &dashboardId, const QString &overlayId,
                                                             const QString &configType)
{
    const QString canonical = canonicalType(configType);
    QVariantMap loaded = loadWithLegacyFallback(dashboardId, overlayId, canonical);
    QVariantMap merged = m_defaults ? m_defaults->defaultsFor(overlayId) : QVariantMap{};
    mergeConfig(merged, loaded);

    if (merged.contains(QStringLiteral("sensorKey")))
        merged[QStringLiteral("sensorKey")] =
            normalizeAnalogSensorKey(merged.value(QStringLiteral("sensorKey")).toString());
    if (merged.contains(QStringLiteral("gearKey")))
        merged[QStringLiteral("gearKey")] = normalizeAnalogSensorKey(merged.value(QStringLiteral("gearKey")).toString());

    return merged;
}

QVariantMap OverlayConfigService::migrateAndLoadConfigs(const QString &dashboardId, const QStringList &overlayIds)
{
    if (!m_appSettings || !m_defaults)
        return {};

    const QList<OverlayDefinition> defs = overlayDefinitions();
    for (const OverlayDefinition &def : defs) {
        if (def.legacyIds.isEmpty())
            continue;

        QVariantMap current = m_appSettings->loadOverlayConfig(dashboardId, def.id);
        if (objectHasKeys(current))
            continue;

        QVariantMap mergedLegacy;
        bool foundLegacy = false;
        for (const QString &legacyId : def.legacyIds) {
            QVariantMap legacyLoaded = m_appSettings->loadOverlayConfig(dashboardId, legacyId);
            if (!objectHasKeys(legacyLoaded))
                continue;
            mergeConfig(mergedLegacy, legacyLoaded);
            m_appSettings->removeOverlayConfig(dashboardId, legacyId);
            foundLegacy = true;
        }
        if (foundLegacy)
            m_appSettings->saveOverlayConfig(dashboardId, def.id, mergedLegacy);
    }

    for (const OverlayDefinition &def : defs) {
        QVariantMap loaded = m_appSettings->loadOverlayConfig(dashboardId, def.id);
        if (!objectHasKeys(loaded))
            continue;

        bool changed = false;
        if (def.id == QLatin1String("tachCluster")) {
            const QString gearKey = loaded.value(QStringLiteral("gearKey")).toString();
            const bool dfiEnabled = m_appSettings->getValue(QStringLiteral("ui/dfiSerial/enabled"), false).toBool();
            if (dfiEnabled && gearKey == QLatin1String("EXGear")) {
                loaded[QStringLiteral("gearKey")] = QStringLiteral("DfiSerialGear");
                changed = true;
            }
        }
        if (loaded.contains(QStringLiteral("sensorKey"))) {
            const QString normalized = normalizeAnalogSensorKey(loaded.value(QStringLiteral("sensorKey")).toString());
            if (normalized != loaded.value(QStringLiteral("sensorKey")).toString()) {
                loaded[QStringLiteral("sensorKey")] = normalized;
                changed = true;
            }
        }
        if (loaded.contains(QStringLiteral("gearKey"))) {
            const QString normalized = normalizeAnalogSensorKey(loaded.value(QStringLiteral("gearKey")).toString());
            if (normalized != loaded.value(QStringLiteral("gearKey")).toString()) {
                loaded[QStringLiteral("gearKey")] = normalized;
                changed = true;
            }
        }
        if (changed)
            m_appSettings->saveOverlayConfig(dashboardId, def.id, loaded);
    }

    const QVariantMap loadedById = m_appSettings->loadOverlayConfigs(dashboardId, overlayIds);
    QVariantMap out;
    for (const QString &id : overlayIds) {
        QVariantMap merged = m_defaults->defaultsFor(id);
        QVariantMap loaded = loadedById.value(id).toMap();
        if (loaded.contains(QStringLiteral("sensorKey")))
            loaded[QStringLiteral("sensorKey")] =
                normalizeAnalogSensorKey(loaded.value(QStringLiteral("sensorKey")).toString());
        if (loaded.contains(QStringLiteral("gearKey")))
            loaded[QStringLiteral("gearKey")] = normalizeAnalogSensorKey(loaded.value(QStringLiteral("gearKey")).toString());
        mergeConfig(merged, loaded);
        out[id] = merged;
    }
    return out;
}

bool OverlayConfigService::boolValue(const QVariantMap &map, const QString &key, bool fallback) const
{
    if (!map.contains(key))
        return fallback;
    const QVariant value = map.value(key);
    if (value.typeId() == QMetaType::Bool)
        return value.toBool();
    const QString s = value.toString().trimmed().toLower();
    if (s == QLatin1String("true") || s == QLatin1String("1"))
        return true;
    if (s == QLatin1String("false") || s == QLatin1String("0"))
        return false;
    return fallback;
}

QVariantMap OverlayConfigService::buildOverlayConfig(const QString &configType, const QVariantMap &uiState) const
{
    QVariantMap config;
    const QString type = canonicalType(configType);
    const bool isArc = (type == QLatin1String("tachCluster") || type == QLatin1String("speedCluster"));
    const bool isBottomBar = (type == QLatin1String("bottomBar"));
    const bool isBrakeBias = (type == QLatin1String("brakeBias"));
    const bool isCluster = isArc;
    const bool isGear = (type == QLatin1String("gear"));
    const bool isSensor = (type == QLatin1String("sensorCard"));
    const bool isShift = (type == QLatin1String("shiftIndicator"));
    const bool isStatus = (type == QLatin1String("statusRow"));
    const bool isTachCluster = (type == QLatin1String("tachCluster"));
    const bool hasDatasource = isArc || isGear || isSensor || isStatus || isBrakeBias;

    if (hasDatasource)
        config[QStringLiteral("sensorKey")] = normalizeAnalogSensorKey(uiState.value(QStringLiteral("sensorKey")).toString());
    if (isSensor || isStatus)
        config[QStringLiteral("label")] = uiState.value(QStringLiteral("labelText")).toString();
    if (isArc || isSensor) {
        config[QStringLiteral("unit")] = uiState.value(QStringLiteral("unitText")).toString();
        config[QStringLiteral("decimals")] = uiState.value(QStringLiteral("decimals")).toInt();
    }
    if (isArc || isBrakeBias) {
        config[QStringLiteral("minValue")] = uiState.value(QStringLiteral("minValue")).toDouble();
        config[QStringLiteral("maxValue")] = uiState.value(QStringLiteral("maxValue")).toDouble();
    }
    if (isArc) {
        config[QStringLiteral("startAngle")] = uiState.value(QStringLiteral("startAngle")).toDouble();
        config[QStringLiteral("endAngle")] = uiState.value(QStringLiteral("endAngle")).toDouble();
        config[QStringLiteral("arcWidth")] = uiState.value(QStringLiteral("arcWidth")).toDouble();
        config[QStringLiteral("arcScale")] = uiState.value(QStringLiteral("arcScale")).toDouble();
        config[QStringLiteral("arcOffsetX")] = uiState.value(QStringLiteral("arcOffsetX")).toDouble();
        config[QStringLiteral("arcOffsetY")] = uiState.value(QStringLiteral("arcOffsetY")).toDouble();
        config[QStringLiteral("minimumVisibleFraction")] =
            uiState.value(QStringLiteral("minimumVisibleFraction")).toDouble();
        config[QStringLiteral("startTaper")] = uiState.value(QStringLiteral("startTaper")).toDouble();
        config[QStringLiteral("endTaper")] = uiState.value(QStringLiteral("endTaper")).toDouble();
        config[QStringLiteral("testLoopEnabled")] = boolValue(uiState, QStringLiteral("testLoopEnabled"), false);
        config[QStringLiteral("testLoopDuration")] = uiState.value(QStringLiteral("testLoopDuration")).toInt();
        config[QStringLiteral("valueOffsetY")] = uiState.value(QStringLiteral("valueOffsetY")).toDouble();
        config[QStringLiteral("readoutOffsetX")] = uiState.value(QStringLiteral("readoutOffsetX")).toDouble();
        config[QStringLiteral("readoutOffsetY")] = uiState.value(QStringLiteral("readoutOffsetY")).toDouble();
        config[QStringLiteral("readoutStep")] = uiState.value(QStringLiteral("readoutStep")).toDouble();
        config[QStringLiteral("readoutValueScale")] = uiState.value(QStringLiteral("readoutValueScale")).toDouble();
        config[QStringLiteral("readoutUnitScale")] = uiState.value(QStringLiteral("readoutUnitScale")).toDouble();
        config[QStringLiteral("unitOffsetX")] = uiState.value(QStringLiteral("unitOffsetX")).toDouble();
        config[QStringLiteral("unitOffsetY")] = uiState.value(QStringLiteral("unitOffsetY")).toDouble();
        config[QStringLiteral("readoutSpacing")] = uiState.value(QStringLiteral("readoutSpacing")).toDouble();
        config[QStringLiteral("readoutTextColor")] = uiState.value(QStringLiteral("readoutTextColor")).toString();
    }
    if (isArc)
        config[QStringLiteral("overlaySize")] = uiState.value(QStringLiteral("overlaySize")).toDouble();
    if (isArc) {
        config[QStringLiteral("arcColorStart")] = uiState.value(QStringLiteral("arcColorStart")).toString();
        config[QStringLiteral("arcColorMid")] = uiState.value(QStringLiteral("arcColorMid")).toString();
        config[QStringLiteral("arcColorMidPos")] = uiState.value(QStringLiteral("arcColorMidPos")).toDouble();
        config[QStringLiteral("arcColorEnd")] = uiState.value(QStringLiteral("arcColorEnd")).toString();
    }
    if (isArc || isSensor || isShift) {
        config[QStringLiteral("warningEnabled")] = boolValue(uiState, QStringLiteral("warningEnabled"), false);
        config[QStringLiteral("warningThreshold")] = uiState.value(QStringLiteral("warningThreshold")).toDouble();
        config[QStringLiteral("warningFlash")] = boolValue(uiState, QStringLiteral("warningFlash"), true);
        config[QStringLiteral("warningFlashRate")] = uiState.value(QStringLiteral("warningFlashRate")).toInt();
        if (isArc || isSensor)
            config[QStringLiteral("warningColor")] = uiState.value(QStringLiteral("warningColor")).toString();
        if (isSensor) {
            config[QStringLiteral("warningDirection")] = uiState.value(QStringLiteral("warningDirection")).toString();
            config[QStringLiteral("normalColor")] = uiState.value(QStringLiteral("normalColor")).toString();
        }
    }
    if (isStatus) {
        config[QStringLiteral("threshold")] = uiState.value(QStringLiteral("threshold")).toDouble();
        config[QStringLiteral("onColor")] = uiState.value(QStringLiteral("onColor")).toString();
        config[QStringLiteral("offColor")] = uiState.value(QStringLiteral("offColor")).toString();
        config[QStringLiteral("invertLogic")] = boolValue(uiState, QStringLiteral("invertLogic"), false);
    }
    if (isGear || isTachCluster) {
        config[QStringLiteral("gearKey")] =
            normalizeAnalogSensorKey(uiState.value(QStringLiteral("gearSensorKey")).toString());
        config[QStringLiteral("gearTextColor")] = uiState.value(QStringLiteral("gearTextColor")).toString();
        config[QStringLiteral("gearFontSize")] = uiState.value(QStringLiteral("gearFontSize")).toInt();
        config[QStringLiteral("suffixFontSize")] = uiState.value(QStringLiteral("suffixFontSize")).toDouble();
        config[QStringLiteral("gearOffsetX")] = uiState.value(QStringLiteral("gearOffsetX")).toDouble();
        config[QStringLiteral("gearOffsetY")] = uiState.value(QStringLiteral("gearOffsetY")).toDouble();
        config[QStringLiteral("gearWidth")] = uiState.value(QStringLiteral("gearWidth")).toDouble();
        config[QStringLiteral("gearHeight")] = uiState.value(QStringLiteral("gearHeight")).toDouble();
    }
    if (isShift) {
        config[QStringLiteral("shiftPoint")] = uiState.value(QStringLiteral("shiftPoint")).toDouble();
        config[QStringLiteral("shiftCount")] = uiState.value(QStringLiteral("shiftCount")).toInt();
        config[QStringLiteral("shiftPattern")] = uiState.value(QStringLiteral("shiftPattern")).toString();
    }
    if (isBrakeBias) {
        config[QStringLiteral("leftLabel")] = uiState.value(QStringLiteral("leftLabel")).toString();
        config[QStringLiteral("rightLabel")] = uiState.value(QStringLiteral("rightLabel")).toString();
        config[QStringLiteral("showSideValues")] = boolValue(uiState, QStringLiteral("biasShowSideValues"), false);
        config[QStringLiteral("showCenterValue")] = boolValue(uiState, QStringLiteral("biasShowCenterValue"), true);
        config[QStringLiteral("valueUnit")] = uiState.value(QStringLiteral("biasValueUnit")).toString();
        config[QStringLiteral("valueDecimals")] = uiState.value(QStringLiteral("biasValueDecimals")).toInt();
        config[QStringLiteral("dampingMultiplier")] = uiState.value(QStringLiteral("biasDampingMultiplier")).toDouble();
        config[QStringLiteral("markerEnabled")] = boolValue(uiState, QStringLiteral("biasMarkerEnabled"), true);
        config[QStringLiteral("markerColor")] = uiState.value(QStringLiteral("biasMarkerColor")).toString();
        config[QStringLiteral("markerWidth")] = uiState.value(QStringLiteral("biasMarkerWidth")).toDouble();
    }
    if (isBottomBar) {
        config[QStringLiteral("text")] = uiState.value(QStringLiteral("staticText")).toString();
        config[QStringLiteral("timeEnabled")] = boolValue(uiState, QStringLiteral("timeEnabled"), true);
    }

    if (!isCluster)
        config.remove(QStringLiteral("overlaySize"));

    return config;
}
