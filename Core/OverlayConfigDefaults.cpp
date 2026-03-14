#include "OverlayConfigDefaults.h"

#include "appsettings.h"

OverlayConfigDefaults::OverlayConfigDefaults(QObject *parent) : QObject(parent) {}

QVariantMap OverlayConfigDefaults::defaultsFor(const QString &overlayId) const
{
    if (overlayId == QLatin1String("tachCluster"))
        return tachClusterDefaults();
    if (overlayId == QLatin1String("speedCluster"))
        return speedClusterDefaults();
    if (overlayId == QLatin1String("shiftIndicator"))
        return shiftIndicatorDefaults();
    if (overlayId == QLatin1String("waterTemp"))
        return waterTempDefaults();
    if (overlayId == QLatin1String("oilPressure"))
        return oilPressureDefaults();
    if (overlayId == QLatin1String("statusRow0"))
        return statusRow0Defaults();
    if (overlayId == QLatin1String("statusRow1"))
        return statusRow1Defaults();
    if (overlayId.startsWith(QLatin1String("statusRow")))
        return statusRowBaseDefaults();
    if (overlayId == QLatin1String("brakeBias") || overlayId == QLatin1String("brakebias"))
        return brakeBiasDefaults();
    if (overlayId == QLatin1String("bottomBar") || overlayId == QLatin1String("bottombar"))
        return bottomBarDefaults();
    if (overlayId == QLatin1String("sensorCard"))
        return sensorCardDefaults();
    return genericDefaults();
}

QVariant OverlayConfigDefaults::defaultValue(const QString &overlayId, const QString &key) const
{
    return defaultsFor(overlayId).value(key);
}

double OverlayConfigDefaults::defaultOverlaySize(const QString &overlayId) const
{
    return defaultsFor(overlayId).value(QStringLiteral("overlaySize"), 300.0).toDouble();
}

QVariantMap OverlayConfigDefaults::tachClusterDefaults() const
{
    double maxRpm = 15000.0;
    double shiftLight = 3000.0;
    if (m_appSettings) {
        maxRpm = m_appSettings->getValue(QStringLiteral("Max RPM"), 15000).toDouble();
        shiftLight = m_appSettings->getValue(QStringLiteral("Shift Light1"), 3000).toDouble();
    }

    return {
        {QStringLiteral("shapeMode"), QStringLiteral("tachSvg")},
        {QStringLiteral("sensorKey"), QStringLiteral("rpm")},
        {QStringLiteral("unit"), QStringLiteral("RPM")},
        {QStringLiteral("decimals"), 0},
        {QStringLiteral("minValue"), 0.0},
        {QStringLiteral("maxValue"), maxRpm},
        {QStringLiteral("overlaySize"), 575.051},
        {QStringLiteral("startAngle"), 225.0},
        {QStringLiteral("endAngle"), 56.0},
        {QStringLiteral("arcWidth"), 0.32},
        {QStringLiteral("arcScale"), 1.0},
        {QStringLiteral("arcOffsetX"), 0.0},
        {QStringLiteral("arcOffsetY"), 0.0},
        {QStringLiteral("minimumVisibleFraction"), 0.0},
        {QStringLiteral("startTaper"), 0.18},
        {QStringLiteral("endTaper"), 0.18},
        {QStringLiteral("testLoopEnabled"), false},
        {QStringLiteral("testLoopDuration"), 1800},
        {QStringLiteral("arcColorStart"), QStringLiteral("#8F4D17")},
        {QStringLiteral("arcColorMid"), QString()},
        {QStringLiteral("arcColorMidPos"), 0.65},
        {QStringLiteral("arcColorEnd"), QStringLiteral("#B00000")},
        {QStringLiteral("warningEnabled"), false},
        {QStringLiteral("warningThreshold"), shiftLight},
        {QStringLiteral("warningColor"), QStringLiteral("#FF0000")},
        {QStringLiteral("warningFlash"), true},
        {QStringLiteral("warningFlashRate"), 200},
        {QStringLiteral("readoutTextColor"), QStringLiteral("#FFFFFF")},
        {QStringLiteral("readoutStep"), 100.0},
        {QStringLiteral("readoutOffsetX"), 0.0},
        {QStringLiteral("readoutOffsetY"), 50.0},
        {QStringLiteral("readoutValueScale"), 0.213},
        {QStringLiteral("readoutUnitScale"), 0.076},
        {QStringLiteral("unitOffsetX"), 34.0},
        {QStringLiteral("unitOffsetY"), -2.0},
        {QStringLiteral("readoutSpacing"), -2.0},
        {QStringLiteral("valueOffsetY"), 50.0},
        {QStringLiteral("gearKey"), QStringLiteral("Gear")},
        {QStringLiteral("gearTextColor"), QStringLiteral("#FFFFFF")},
        {QStringLiteral("gearFontSize"), 160.0},
        {QStringLiteral("suffixFontSize"), 52.505},
        {QStringLiteral("gearOffsetX"), 0.0},
        {QStringLiteral("gearOffsetY"), -85.0},
        {QStringLiteral("gearWidth"), 168.0},
        {QStringLiteral("gearHeight"), 117.0},
        {QStringLiteral("shiftPoint"), 0.75},
    };
}

QVariantMap OverlayConfigDefaults::speedClusterDefaults() const
{
    return {
        {QStringLiteral("shapeMode"), QStringLiteral("speedSvg")},
        {QStringLiteral("sensorKey"), QStringLiteral("speed")},
        {QStringLiteral("unit"), QStringLiteral("MPH")},
        {QStringLiteral("decimals"), 0},
        {QStringLiteral("minValue"), 0.0},
        {QStringLiteral("maxValue"), 220.0},
        {QStringLiteral("overlaySize"), 503.17},
        {QStringLiteral("startAngle"), 225.0},
        {QStringLiteral("endAngle"), 400.0},
        {QStringLiteral("arcWidth"), 0.32},
        {QStringLiteral("arcScale"), 1.0},
        {QStringLiteral("arcOffsetX"), 0.0},
        {QStringLiteral("arcOffsetY"), 0.0},
        {QStringLiteral("minimumVisibleFraction"), 0.0},
        {QStringLiteral("startTaper"), 0.28},
        {QStringLiteral("endTaper"), 0.24},
        {QStringLiteral("testLoopEnabled"), false},
        {QStringLiteral("testLoopDuration"), 1800},
        {QStringLiteral("arcColorStart"), QStringLiteral("#7A0D0D")},
        {QStringLiteral("arcColorMid"), QStringLiteral("#E11B1B")},
        {QStringLiteral("arcColorMidPos"), 0.62},
        {QStringLiteral("arcColorEnd"), QStringLiteral("#B00000")},
        {QStringLiteral("warningEnabled"), false},
        {QStringLiteral("warningThreshold"), 0.0},
        {QStringLiteral("warningColor"), QStringLiteral("#FF0000")},
        {QStringLiteral("warningFlash"), true},
        {QStringLiteral("warningFlashRate"), 200},
        {QStringLiteral("readoutTextColor"), QStringLiteral("#FFFFFF")},
        {QStringLiteral("readoutStep"), 10.0},
        {QStringLiteral("readoutOffsetX"), 0.0},
        {QStringLiteral("readoutOffsetY"), 0.0},
        {QStringLiteral("readoutValueScale"), 0.213},
        {QStringLiteral("readoutUnitScale"), 0.076},
        {QStringLiteral("unitOffsetX"), 14.0},
        {QStringLiteral("unitOffsetY"), -2.0},
        {QStringLiteral("readoutSpacing"), -1.0},
        {QStringLiteral("valueOffsetY"), 0.0},
    };
}

QVariantMap OverlayConfigDefaults::shiftIndicatorDefaults() const
{
    double maxRpm = 10000.0;
    double shiftLight = 3000.0;
    if (m_appSettings) {
        maxRpm = m_appSettings->getValue(QStringLiteral("Max RPM"), 10000).toDouble();
        shiftLight = m_appSettings->getValue(QStringLiteral("Shift Light1"), 3000).toDouble();
    }
    const double safeMax = qMax(maxRpm, 1.0);

    return {
        {QStringLiteral("sensorKey"), QStringLiteral("rpm")},
        {QStringLiteral("maxValue"), maxRpm},
        {QStringLiteral("shiftPoint"), shiftLight / safeMax},
        {QStringLiteral("shiftCount"), 11},
        {QStringLiteral("shiftPattern"), QStringLiteral("center-out")},
    };
}

QVariantMap OverlayConfigDefaults::waterTempDefaults() const
{
    return {
        {QStringLiteral("sensorKey"), QStringLiteral("Watertemp")},
        {QStringLiteral("label"), QStringLiteral("Water Temp")},
        {QStringLiteral("unit"), QStringLiteral("F\u00B0")},
        {QStringLiteral("decimals"), 2},
    };
}

QVariantMap OverlayConfigDefaults::oilPressureDefaults() const
{
    return {
        {QStringLiteral("sensorKey"), QStringLiteral("oilpres")},
        {QStringLiteral("label"), QStringLiteral("Oil Pressure")},
        {QStringLiteral("unit"), QStringLiteral("PSI")},
        {QStringLiteral("decimals"), 2},
    };
}

QVariantMap OverlayConfigDefaults::statusRowBaseDefaults() const
{
    return {
        {QStringLiteral("sensorKey"), QStringLiteral("EXDigitalInput1")},
        {QStringLiteral("label"), QStringLiteral("Status:")},
        {QStringLiteral("threshold"), 0.5},
        {QStringLiteral("onColor"), QStringLiteral("#1ED033")},
        {QStringLiteral("offColor"), QStringLiteral("#FF0909")},
        {QStringLiteral("invertLogic"), false},
    };
}

QVariantMap OverlayConfigDefaults::statusRow0Defaults() const
{
    QVariantMap defs = statusRowBaseDefaults();
    defs[QStringLiteral("sensorKey")] = QStringLiteral("DigitalInput1");
    defs[QStringLiteral("label")] = QStringLiteral("Fuel Pump:");
    return defs;
}

QVariantMap OverlayConfigDefaults::statusRow1Defaults() const
{
    QVariantMap defs = statusRowBaseDefaults();
    defs[QStringLiteral("sensorKey")] = QStringLiteral("DigitalInput2");
    defs[QStringLiteral("label")] = QStringLiteral("Cooling Fan:");
    return defs;
}

QVariantMap OverlayConfigDefaults::brakeBiasDefaults() const
{
    return {
        {QStringLiteral("sensorKey"), QStringLiteral("differentialSensor")},
        {QStringLiteral("leftLabel"), QStringLiteral("RWD")},
        {QStringLiteral("rightLabel"), QStringLiteral("FWD")},
        {QStringLiteral("minValue"), 0.0},
        {QStringLiteral("maxValue"), 100.0},
    };
}

QVariantMap OverlayConfigDefaults::bottomBarDefaults() const
{
    return {
        {QStringLiteral("text"), QStringLiteral("Cardinal Racing")},
        {QStringLiteral("timeEnabled"), true},
    };
}

QVariantMap OverlayConfigDefaults::sensorCardDefaults() const
{
    return {
        {QStringLiteral("sensorKey"), QStringLiteral("rpm")},
        {QStringLiteral("label"), QStringLiteral("Sensor")},
        {QStringLiteral("unit"), QString()},
        {QStringLiteral("decimals"), 0},
        {QStringLiteral("warningEnabled"), false},
        {QStringLiteral("warningThreshold"), 0.0},
        {QStringLiteral("warningColor"), QStringLiteral("#FF0000")},
        {QStringLiteral("warningDirection"), QStringLiteral("above")},
        {QStringLiteral("normalColor"), QStringLiteral("#FFFFFF")},
    };
}

QVariantMap OverlayConfigDefaults::genericDefaults() const
{
    return {
        {QStringLiteral("sensorKey"), QStringLiteral("rpm")},
        {QStringLiteral("minValue"), 0.0},
        {QStringLiteral("maxValue"), 100.0},
        {QStringLiteral("overlaySize"), 300.0},
        {QStringLiteral("minimumVisibleFraction"), 0.0},
        {QStringLiteral("startAngle"), 225.0},
        {QStringLiteral("endAngle"), 400.0},
        {QStringLiteral("arcWidth"), 0.32},
        {QStringLiteral("arcScale"), 1.0},
        {QStringLiteral("arcOffsetX"), 0.0},
        {QStringLiteral("arcOffsetY"), 0.0},
        {QStringLiteral("startTaper"), 0.18},
        {QStringLiteral("endTaper"), 0.18},
        {QStringLiteral("testLoopEnabled"), false},
        {QStringLiteral("testLoopDuration"), 1800},
        {QStringLiteral("arcColorStart"), QStringLiteral("#8F4D17")},
        {QStringLiteral("arcColorMid"), QStringLiteral("#FF8A00")},
        {QStringLiteral("arcColorMidPos"), 0.65},
        {QStringLiteral("arcColorEnd"), QStringLiteral("#B00000")},
        {QStringLiteral("readoutTextColor"), QStringLiteral("#FFFFFF")},
        {QStringLiteral("readoutStep"), 1.0},
        {QStringLiteral("readoutOffsetX"), 0.0},
        {QStringLiteral("readoutOffsetY"), 0.0},
        {QStringLiteral("readoutValueScale"), 0.213},
        {QStringLiteral("readoutUnitScale"), 0.076},
        {QStringLiteral("unitOffsetX"), 0.0},
        {QStringLiteral("unitOffsetY"), 0.0},
        {QStringLiteral("readoutSpacing"), 0.0},
        {QStringLiteral("valueOffsetY"), 0.0},
    };
}
