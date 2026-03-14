#include "OverlayConfigDefaults.h"

#include "appsettings.h"

OverlayConfigDefaults::OverlayConfigDefaults(QObject *parent) : QObject(parent) {}

QVariantMap OverlayConfigDefaults::defaultsFor(const QString &configType) const
{
    if (configType == QLatin1String("tachCluster"))
        return tachClusterDefaults();
    if (configType == QLatin1String("speedCluster"))
        return speedClusterDefaults();
    if (configType == QLatin1String("waterTemp"))
        return waterTempDefaults();
    if (configType == QLatin1String("oilPressure"))
        return oilPressureDefaults();
    if (configType == QLatin1String("shiftIndicator"))
        return shiftIndicatorDefaults();
    if (configType.startsWith(QLatin1String("statusRow")))
        return statusRowDefaults();
    if (configType == QLatin1String("brakeBias"))
        return brakeBiasDefaults();
    if (configType == QLatin1String("bottomBar"))
        return bottomBarDefaults();
    return genericDefaults();
}

QVariant OverlayConfigDefaults::defaultValue(const QString &configType, const QString &key) const
{
    const QVariantMap defs = defaultsFor(configType);
    return defs.value(key);
}

QVariantMap OverlayConfigDefaults::arcDefaults(const QString &configType) const
{
    const QVariantMap defs = defaultsFor(configType);
    QVariantMap arc;
    const QStringList arcKeys = {
        QStringLiteral("startAngle"),    QStringLiteral("endAngle"),
        QStringLiteral("arcWidth"),      QStringLiteral("arcScale"),
        QStringLiteral("arcOffsetX"),    QStringLiteral("arcOffsetY"),
        QStringLiteral("arcColorStart"), QStringLiteral("arcColorMid"),
        QStringLiteral("arcColorEnd"),   QStringLiteral("minimumVisibleFraction"),
    };
    for (const QString &k : arcKeys) {
        if (defs.contains(k))
            arc[k] = defs.value(k);
    }
    return arc;
}

double OverlayConfigDefaults::defaultOverlaySize(const QString &configType) const
{
    return defaultsFor(configType).value(QStringLiteral("overlaySize"), 300.0).toDouble();
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
        {QStringLiteral("sensorKey"), QStringLiteral("rpm")},
        {QStringLiteral("minValue"), 0.0},
        {QStringLiteral("maxValue"), maxRpm},
        {QStringLiteral("overlaySize"), 575.051},
        {QStringLiteral("minimumVisibleFraction"), 0.0},
        {QStringLiteral("startAngle"), 135.0},
        {QStringLiteral("endAngle"), 400.0},
        {QStringLiteral("arcWidth"), 0.32},
        {QStringLiteral("arcScale"), 1.0},
        {QStringLiteral("arcOffsetX"), 0.0},
        {QStringLiteral("arcOffsetY"), 0.0},
        {QStringLiteral("arcColorStart"), QStringLiteral("#8F4D17")},
        {QStringLiteral("arcColorMid"), QString()},
        {QStringLiteral("arcColorEnd"), QStringLiteral("#B00000")},
        {QStringLiteral("readoutStep"), 100.0},
        {QStringLiteral("readoutOffsetX"), 0.0},
        {QStringLiteral("readoutOffsetY"), 50.0},
        {QStringLiteral("valueOffsetY"), 50.0},
        {QStringLiteral("unitOffsetX"), 34.0},
        {QStringLiteral("gearKey"), QStringLiteral("Gear")},
        {QStringLiteral("gearFontSize"), 160.0},
        {QStringLiteral("gearOffsetX"), 0.0},
        {QStringLiteral("gearOffsetY"), -85.0},
        {QStringLiteral("warningThreshold"), shiftLight},
        {QStringLiteral("shiftPoint"), 0.75},
    };
}

QVariantMap OverlayConfigDefaults::speedClusterDefaults() const
{
    return {
        {QStringLiteral("sensorKey"), QStringLiteral("speed")},
        {QStringLiteral("minValue"), 0.0},
        {QStringLiteral("maxValue"), 220.0},
        {QStringLiteral("overlaySize"), 503.17},
        {QStringLiteral("minimumVisibleFraction"), 0.0},
        {QStringLiteral("startAngle"), 135.0},
        {QStringLiteral("endAngle"), 400.0},
        {QStringLiteral("arcWidth"), 0.32},
        {QStringLiteral("arcScale"), 1.0},
        {QStringLiteral("arcOffsetX"), 0.0},
        {QStringLiteral("arcOffsetY"), 0.0},
        {QStringLiteral("arcColorStart"), QStringLiteral("#7A0D0D")},
        {QStringLiteral("arcColorMid"), QStringLiteral("#E11B1B")},
        {QStringLiteral("arcColorEnd"), QStringLiteral("#B00000")},
        {QStringLiteral("readoutStep"), 10.0},
        {QStringLiteral("readoutOffsetX"), 0.0},
        {QStringLiteral("readoutOffsetY"), 0.0},
        {QStringLiteral("valueOffsetY"), 0.0},
        {QStringLiteral("unitOffsetX"), 14.0},
    };
}

QVariantMap OverlayConfigDefaults::waterTempDefaults() const
{
    return {
        {QStringLiteral("sensorKey"), QStringLiteral("Watertemp")},
        {QStringLiteral("minValue"), 0.0},
        {QStringLiteral("maxValue"), 150.0},
        {QStringLiteral("overlaySize"), 300.0},
        {QStringLiteral("minimumVisibleFraction"), 0.0},
        {QStringLiteral("startAngle"), 135.0},
        {QStringLiteral("endAngle"), 400.0},
        {QStringLiteral("arcWidth"), 0.32},
        {QStringLiteral("arcScale"), 1.0},
        {QStringLiteral("arcOffsetX"), 0.0},
        {QStringLiteral("arcOffsetY"), 0.0},
        {QStringLiteral("arcColorStart"), QStringLiteral("#0066CC")},
        {QStringLiteral("arcColorMid"), QStringLiteral("#FFB800")},
        {QStringLiteral("arcColorEnd"), QStringLiteral("#B00000")},
        {QStringLiteral("readoutStep"), 10.0},
    };
}

QVariantMap OverlayConfigDefaults::oilPressureDefaults() const
{
    return {
        {QStringLiteral("sensorKey"), QStringLiteral("oilpres")},
        {QStringLiteral("minValue"), 0.0},
        {QStringLiteral("maxValue"), 150.0},
        {QStringLiteral("overlaySize"), 300.0},
        {QStringLiteral("minimumVisibleFraction"), 0.0},
        {QStringLiteral("startAngle"), 135.0},
        {QStringLiteral("endAngle"), 400.0},
        {QStringLiteral("arcWidth"), 0.32},
        {QStringLiteral("arcScale"), 1.0},
        {QStringLiteral("arcOffsetX"), 0.0},
        {QStringLiteral("arcOffsetY"), 0.0},
        {QStringLiteral("arcColorStart"), QStringLiteral("#B00000")},
        {QStringLiteral("arcColorMid"), QStringLiteral("#FFB800")},
        {QStringLiteral("arcColorEnd"), QStringLiteral("#00AA00")},
        {QStringLiteral("readoutStep"), 10.0},
    };
}

QVariantMap OverlayConfigDefaults::shiftIndicatorDefaults() const
{
    double shiftLight = 3000.0;
    if (m_appSettings)
        shiftLight = m_appSettings->getValue(QStringLiteral("Shift Light1"), 3000).toDouble();

    return {
        {QStringLiteral("sensorKey"), QStringLiteral("rpm")},
        {QStringLiteral("overlaySize"), 200.0},
        {QStringLiteral("warningThreshold"), shiftLight},
        {QStringLiteral("shiftPoint"), 0.75},
    };
}

QVariantMap OverlayConfigDefaults::statusRowDefaults() const
{
    return {
        {QStringLiteral("sensorKey"), QStringLiteral("EXDigitalInput1")},
        {QStringLiteral("label"), QStringLiteral("Fuel Pump:")},
        {QStringLiteral("overlaySize"), 160.0},
    };
}

QVariantMap OverlayConfigDefaults::brakeBiasDefaults() const
{
    return {
        {QStringLiteral("sensorKey"), QStringLiteral("BrakeBias")},
        {QStringLiteral("overlaySize"), 300.0},
        {QStringLiteral("minValue"), 0.0},
        {QStringLiteral("maxValue"), 100.0},
    };
}

QVariantMap OverlayConfigDefaults::bottomBarDefaults() const
{
    return {
        {QStringLiteral("overlaySize"), 400.0},
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
        {QStringLiteral("startAngle"), 135.0},
        {QStringLiteral("endAngle"), 400.0},
        {QStringLiteral("arcWidth"), 0.32},
        {QStringLiteral("arcScale"), 1.0},
        {QStringLiteral("arcOffsetX"), 0.0},
        {QStringLiteral("arcOffsetY"), 0.0},
        {QStringLiteral("arcColorStart"), QStringLiteral("#8F4D17")},
        {QStringLiteral("arcColorMid"), QStringLiteral("#FF8A00")},
        {QStringLiteral("arcColorEnd"), QStringLiteral("#B00000")},
        {QStringLiteral("readoutStep"), 1.0},
    };
}
