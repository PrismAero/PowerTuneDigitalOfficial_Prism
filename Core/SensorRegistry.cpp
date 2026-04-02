// Copyright (c) 2026 Kai Wyborny. All rights reserved.

/**
 * @file SensorRegistry.cpp
 * @brief Implementation of the SensorRegistry runtime sensor tracking class.
 */

#include "SensorRegistry.h"

#include "appsettings.h"

#include <QDateTime>
#include <QDebug>
#include <QMetaEnum>
#include <QSettings>

/// CAN sensor timeout threshold in milliseconds (10 seconds)
static constexpr qint64 kCanTimeoutMs = 10000;

/// CAN timeout check interval in milliseconds (5 seconds)
static constexpr int kCanCheckIntervalMs = 5000;

SensorRegistry::SensorRegistry(QObject *parent) : QObject(parent)
{
    registerBuiltinSensors();

    m_canTimeoutTimer.setInterval(kCanCheckIntervalMs);
    connect(&m_canTimeoutTimer, &QTimer::timeout, this, &SensorRegistry::checkCanTimeouts);
    m_canTimeoutTimer.start();

    m_sensorsChangedTimer.setSingleShot(true);
    m_sensorsChangedTimer.setInterval(0);
    connect(&m_sensorsChangedTimer, &QTimer::timeout, this, &SensorRegistry::emitScheduledSensorsChanged);
}

void SensorRegistry::setAppSettings(AppSettings *settings)
{
    m_appSettings = settings;
}

/**
 * @brief Register a sensor as available in the registry.
 *
 * If a sensor with the same key already exists, it is updated in place.
 *
 * @param key Unique property key (e.g., "rpm", "boost", "Analog0")
 * @param displayName Human-readable name (e.g., "RPM", "Boost Pressure")
 * @param category Category for grouping (e.g., "Engine", "Analog Inputs")
 * @param unit Unit string (e.g., "rpm", "psi", "V")
 * @param source Where this sensor data comes from
 */
void SensorRegistry::registerSensor(const QString &key, const QString &displayName, const QString &category,
                                    const QString &unit, SensorSource source, int decimals, double maxValue,
                                    double stepSize)
{
    const bool isNew = !m_sensors.contains(key);

    SensorEntry entry;
    entry.key = key;
    entry.displayName = displayName;
    entry.category = category;
    entry.unit = unit;
    entry.source = source;
    entry.active = (source == SensorSource::Computed);
    entry.lastActiveTimestamp = 0;
    entry.decimals = decimals;
    entry.maxValue = maxValue;
    entry.stepSize = stepSize;

    m_sensors.insert(key, entry);

    if (isNew) {
        emit sensorRegistered(key);
    }
    scheduleSensorsChanged();
}

/**
 * @brief Unregister a sensor, removing it from the registry entirely.
 * @param key Unique property key
 */
void SensorRegistry::unregisterSensor(const QString &key)
{
    if (m_sensors.remove(key) > 0) {
        emit sensorUnregistered(key);
        scheduleSensorsChanged();
    }
}

/**
 * @brief Check if a sensor is registered in the registry.
 * @param key Unique property key
 * @return true if sensor exists in the registry
 */
bool SensorRegistry::isSensorAvailable(const QString &key) const
{
    return m_sensors.contains(key);
}

/**
 * @brief Mark a CAN sensor as active, indicating data was recently received.
 *
 * If the sensor does not exist in the registry, the call is ignored.
 * If the sensor transitions from inactive to active, sensorsChanged is emitted.
 *
 * @param key Property key for the CAN-backed sensor
 */
void SensorRegistry::markCanSensorActive(const QString &key)
{
    auto it = m_sensors.find(key);
    if (it == m_sensors.end()) {
        return;
    }

    const bool wasInactive = !it->active;
    it->active = true;
    it->lastActiveTimestamp = QDateTime::currentMSecsSinceEpoch();

    if (wasInactive) {
        scheduleSensorsChanged();
    }
}

/**
 * @brief Get all available sensors, optionally filtered by category.
 * @param category Category filter (empty string = all sensors)
 * @return List of sensor maps with keys: key, displayName, category, unit, source, active
 */
QVariantList SensorRegistry::getSensorsByCategory(const QString &category, bool activeOnly) const
{
    QVariantList result;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (activeOnly && !it->active)
            continue;
        if (category.isEmpty() || it->category == category)
            result.append(entryToVariantMap(it.value()));
    }
    return result;
}

QVariantList SensorRegistry::getActiveSensors() const
{
    return getSensorsByCategory(QString(), true);
}

QStringList SensorRegistry::sensorDisplayNames(const QString &category, bool activeOnly) const
{
    QStringList names;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (activeOnly && !it->active)
            continue;
        if (category.isEmpty() || it->category == category)
            names.append(it->displayName + QStringLiteral(" (") + it->key + QStringLiteral(")"));
    }
    return names;
}

QStringList SensorRegistry::sensorKeys(const QString &category, bool activeOnly) const
{
    QStringList keys;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (activeOnly && !it->active)
            continue;
        if (category.isEmpty() || it->category == category)
            keys.append(it->key);
    }
    return keys;
}

int SensorRegistry::indexOfSensorKey(const QString &key, const QString &category) const
{
    int idx = 0;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (!category.isEmpty() && it->category != category)
            continue;
        if (it->key == key)
            return idx;
        ++idx;
    }
    return -1;
}

bool SensorRegistry::isAvailable(const QString &key) const
{
    return isSensorAvailable(key);
}

bool SensorRegistry::isActive(const QString &key) const
{
    const auto it = m_sensors.constFind(key);
    if (it == m_sensors.constEnd())
        return false;
    return it->active;
}

/**
 * @brief Get display name for a sensor key.
 * @param key Sensor property key
 * @return Display name or empty string if not found
 */
QString SensorRegistry::getDisplayName(const QString &key) const
{
    auto it = m_sensors.constFind(key);
    if (it != m_sensors.constEnd()) {
        return it->displayName;
    }
    return QString();
}

/**
 * @brief Get unit for a sensor key.
 * @param key Sensor property key
 * @return Unit string or empty string if not found
 */
QString SensorRegistry::getUnit(const QString &key) const
{
    auto it = m_sensors.constFind(key);
    if (it != m_sensors.constEnd()) {
        return it->unit;
    }
    return QString();
}

int SensorRegistry::getDecimals(const QString &key) const
{
    auto it = m_sensors.constFind(key);
    return it != m_sensors.constEnd() ? it->decimals : 2;
}

double SensorRegistry::getMaxValue(const QString &key) const
{
    auto it = m_sensors.constFind(key);
    return it != m_sensors.constEnd() ? it->maxValue : 100.0;
}

double SensorRegistry::getStepSize(const QString &key) const
{
    auto it = m_sensors.constFind(key);
    return it != m_sensors.constEnd() ? it->stepSize : 1.0;
}

void SensorRegistry::updateSensorMetadata(const QString &key, const QString &unit, int decimals, double maxValue,
                                          double stepSize)
{
    auto it = m_sensors.find(key);
    if (it == m_sensors.end())
        return;

    bool changed = false;

    if (it->unit != unit) {
        it->unit = unit;
        changed = true;
    }
    if (it->decimals != decimals) {
        it->decimals = decimals;
        changed = true;
    }
    if (!qFuzzyCompare(it->maxValue + 1.0, maxValue + 1.0)) {
        it->maxValue = maxValue;
        changed = true;
    }
    if (!qFuzzyCompare(it->stepSize + 1.0, stepSize + 1.0)) {
        it->stepSize = stepSize;
        changed = true;
    }

    if (changed)
        scheduleSensorsChanged();
}

/**
 * @brief Register extender board analog input channels EXAnalogInput0 through EXAnalogInput7.
 *
 * Removes any previously registered ExtenderAnalog sensors and re-registers
 * them. Also registers EXAnalogCalc0 through EXAnalogCalc7 calibrated channels.
 * These are analog inputs from the extender board received via CAN bus.
 *
 * Call this when extender board settings change.
 */
void SensorRegistry::refreshExtenderAnalogInputs()
{
    QStringList toRemove;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (it->source == SensorSource::ExtenderAnalog)
            toRemove.append(it.key());
    }
    for (const QString &key : toRemove)
        m_sensors.remove(key);

    QSettings settings(QStringLiteral("PowerTune"), QStringLiteral("PowerTune"));
    const auto readValue = [this, &settings](const QString &key, const QVariant &defaultValue) -> QVariant {
        if (m_appSettings)
            return m_appSettings->getValue(key, defaultValue);
        return settings.value(key, defaultValue);
    };

    for (int i = 0; i <= 7; ++i) {
        const bool enabled = readValue(QStringLiteral("ui/exboard/ch%1_enabled").arg(i), true).toBool();
        const QString customName = readValue(QStringLiteral("ui/exboard/exan%1name").arg(i), QString()).toString();
        if (!enabled || customName.trimmed().isEmpty())
            continue;

        const QString rawKey = QStringLiteral("EXAnalogInput%1").arg(i);
        SensorEntry rawEntry;
        rawEntry.key = rawKey;
        rawEntry.displayName = QStringLiteral("EX AN %1: %2").arg(i).arg(customName);
        rawEntry.category = QStringLiteral("Extender Board");
        rawEntry.unit = QStringLiteral("V");
        rawEntry.source = SensorSource::ExtenderAnalog;
        rawEntry.active = false;
        rawEntry.lastActiveTimestamp = 0;
        rawEntry.decimals = 3;
        rawEntry.maxValue = 5.0;
        rawEntry.stepSize = 0.1;
        m_sensors.insert(rawKey, rawEntry);

        const QString calcKey = QStringLiteral("EXAnalogCalc%1").arg(i);
        SensorEntry calcEntry;
        calcEntry.key = calcKey;
        calcEntry.displayName = QStringLiteral("EX AN Calc %1: %2").arg(i).arg(customName);
        calcEntry.category = QStringLiteral("Extender Board");
        calcEntry.unit = QString();
        calcEntry.source = SensorSource::ExtenderAnalog;
        calcEntry.active = false;
        calcEntry.lastActiveTimestamp = 0;
        calcEntry.decimals = 2;
        calcEntry.maxValue = 100.0;
        calcEntry.stepSize = 1.0;
        m_sensors.insert(calcKey, calcEntry);
    }

    const bool speedEnabled = readValue(QStringLiteral("ui/exboard/speedSensor/enabled"), false).toBool();
    if (speedEnabled && !m_sensors.contains(QStringLiteral("EXSpeed"))) {
        SensorEntry speedEntry;
        speedEntry.key = QStringLiteral("EXSpeed");
        speedEntry.displayName = QStringLiteral("EX Speed");
        speedEntry.category = QStringLiteral("Extender Board");
        speedEntry.unit = QStringLiteral("km/h");
        speedEntry.source = SensorSource::ExtenderAnalog;
        speedEntry.active = false;
        speedEntry.decimals = 1;
        speedEntry.maxValue = 300.0;
        speedEntry.stepSize = 1.0;
        m_sensors.insert(speedEntry.key, speedEntry);
    }
    const bool gearEnabled = readValue(QStringLiteral("ui/exboard/gearSensor/enabled"), false).toBool();
    if (gearEnabled && !m_sensors.contains(QStringLiteral("EXGear"))) {
        SensorEntry gearEntry;
        gearEntry.key = QStringLiteral("EXGear");
        gearEntry.displayName = QStringLiteral("EX Gear");
        gearEntry.category = QStringLiteral("Extender Board");
        gearEntry.unit = QString();
        gearEntry.source = SensorSource::ExtenderAnalog;
        gearEntry.active = false;
        gearEntry.decimals = 0;
        gearEntry.maxValue = 7.0;
        gearEntry.stepSize = 1.0;
        m_sensors.insert(gearEntry.key, gearEntry);
    }

    const bool diffEnabled = readValue(QStringLiteral("ui/exboard/diffSensor_enabled"), false).toBool();
    if (diffEnabled && !m_sensors.contains(QStringLiteral("differentialSensor"))) {
        SensorEntry diffEntry;
        diffEntry.key = QStringLiteral("differentialSensor");
        diffEntry.displayName = QStringLiteral("Differential Sensor");
        diffEntry.category = QStringLiteral("Calculated");
        diffEntry.unit = QString();
        diffEntry.source = SensorSource::Computed;
        diffEntry.active = false;
        diffEntry.decimals = 2;
        diffEntry.maxValue = 100.0;
        diffEntry.stepSize = 1.0;
        m_sensors.insert(diffEntry.key, diffEntry);
    }

    scheduleSensorsChanged();
}

/**
 * @brief Refreshes extender board digital input sensors in the registry.
 *
 * Registers EXDigitalInput1 through EXDigitalInput8 (1-indexed per reference).
 * These are digital inputs from the extender board received via CAN bus.
 */
void SensorRegistry::refreshExtenderDigitalInputs()
{
    QStringList toRemove;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (it->source == SensorSource::ExtenderDigital)
            toRemove.append(it.key());
    }
    for (const QString &key : toRemove)
        m_sensors.remove(key);

    QSettings settings(QStringLiteral("PowerTune"), QStringLiteral("PowerTune"));
    const auto readValue = [this, &settings](const QString &key, const QVariant &defaultValue) -> QVariant {
        if (m_appSettings)
            return m_appSettings->getValue(key, defaultValue);
        return settings.value(key, defaultValue);
    };

    const int rpmSource = readValue(QStringLiteral("ui/exboard/rpmSource"),
                                    readValue(QStringLiteral("ui/exboard/rpmSourceValue"), 0))
                              .toInt();

    for (int i = 1; i <= 8; ++i) {
        const bool enabled = readValue(QStringLiteral("ui/exboard/di%1_enabled").arg(i), true).toBool();
        const QString customName = readValue(QStringLiteral("ui/exboard/exdigi%1name").arg(i), QString()).toString();

        const bool isTachSource = (i == 1 && rpmSource == 2);
        if (!enabled || (customName.trimmed().isEmpty() && !isTachSource))
            continue;

        const QString key = QStringLiteral("EXDigitalInput%1").arg(i);
        const QString displayName = customName.isEmpty() ? QStringLiteral("EX Digital %1").arg(i)
                                                         : QStringLiteral("EX Digi %1: %2").arg(i).arg(customName);

        SensorEntry entry;
        entry.key = key;
        entry.displayName = displayName;
        entry.category = QStringLiteral("Extender Board");
        entry.unit = QString();
        entry.source = SensorSource::ExtenderDigital;
        entry.active = false;
        entry.lastActiveTimestamp = 0;
        entry.decimals = 0;
        entry.maxValue = 1.0;
        entry.stepSize = 1.0;
        m_sensors.insert(key, entry);
    }

    if (rpmSource == 2) {
        SensorEntry freqEntry;
        freqEntry.key = QStringLiteral("frequencyDIEX1");
        freqEntry.displayName = QStringLiteral("EX Tach RPM");
        freqEntry.category = QStringLiteral("Extender Board");
        freqEntry.unit = QStringLiteral("rpm");
        freqEntry.source = SensorSource::ExtenderDigital;
        freqEntry.active = false;
        freqEntry.decimals = 0;
        freqEntry.maxValue = 10000.0;
        freqEntry.stepSize = 100.0;
        m_sensors.insert(freqEntry.key, freqEntry);
    }

    for (int i = 1; i <= 4; ++i) {
        SensorEntry ptDiEntry;
        ptDiEntry.key = QStringLiteral("PTDigitalInput%1").arg(i);
        ptDiEntry.displayName = QStringLiteral("PT Digital %1").arg(i);
        ptDiEntry.category = QStringLiteral("PT Extender");
        ptDiEntry.unit = QString();
        ptDiEntry.source = SensorSource::ExtenderDigital;
        ptDiEntry.active = false;
        ptDiEntry.lastActiveTimestamp = 0;
        ptDiEntry.decimals = 0;
        ptDiEntry.maxValue = 1.0;
        ptDiEntry.stepSize = 1.0;
        m_sensors.insert(ptDiEntry.key, ptDiEntry);

        SensorEntry ptRelayEntry;
        ptRelayEntry.key = QStringLiteral("PTRelay%1").arg(i);
        ptRelayEntry.displayName = QStringLiteral("PT Relay %1").arg(i);
        ptRelayEntry.category = QStringLiteral("PT Extender");
        ptRelayEntry.unit = QString();
        ptRelayEntry.source = SensorSource::ExtenderDigital;
        ptRelayEntry.active = false;
        ptRelayEntry.lastActiveTimestamp = 0;
        ptRelayEntry.decimals = 0;
        ptRelayEntry.maxValue = 1.0;
        ptRelayEntry.stepSize = 1.0;
        m_sensors.insert(ptRelayEntry.key, ptRelayEntry);
    }

    SensorEntry ptRelayMask;
    ptRelayMask.key = QStringLiteral("PTRelayMask");
    ptRelayMask.displayName = QStringLiteral("PT Relay Mask");
    ptRelayMask.category = QStringLiteral("PT Extender");
    ptRelayMask.unit = QString();
    ptRelayMask.source = SensorSource::ExtenderDigital;
    ptRelayMask.active = false;
    ptRelayMask.lastActiveTimestamp = 0;
    ptRelayMask.decimals = 0;
    ptRelayMask.maxValue = 15.0;
    ptRelayMask.stepSize = 1.0;
    m_sensors.insert(ptRelayMask.key, ptRelayMask);

    SensorEntry ptState;
    ptState.key = QStringLiteral("PTSystemState");
    ptState.displayName = QStringLiteral("PT System State");
    ptState.category = QStringLiteral("PT Extender");
    ptState.unit = QString();
    ptState.source = SensorSource::ExtenderDigital;
    ptState.active = false;
    ptState.lastActiveTimestamp = 0;
    ptState.decimals = 0;
    ptState.maxValue = 255.0;
    ptState.stepSize = 1.0;
    m_sensors.insert(ptState.key, ptState);

    SensorEntry ptFault;
    ptFault.key = QStringLiteral("PTSystemFault");
    ptFault.displayName = QStringLiteral("PT System Fault");
    ptFault.category = QStringLiteral("PT Extender");
    ptFault.unit = QString();
    ptFault.source = SensorSource::ExtenderDigital;
    ptFault.active = false;
    ptFault.lastActiveTimestamp = 0;
    ptFault.decimals = 0;
    ptFault.maxValue = 255.0;
    ptFault.stepSize = 1.0;
    m_sensors.insert(ptFault.key, ptFault);

    SensorEntry ptDfiErr;
    ptDfiErr.key = QStringLiteral("PTDfiChecksumErrors");
    ptDfiErr.displayName = QStringLiteral("PT DFI Checksum Errors");
    ptDfiErr.category = QStringLiteral("PT Extender");
    ptDfiErr.unit = QString();
    ptDfiErr.source = SensorSource::ExtenderDigital;
    ptDfiErr.active = false;
    ptDfiErr.lastActiveTimestamp = 0;
    ptDfiErr.decimals = 0;
    ptDfiErr.maxValue = 255.0;
    ptDfiErr.stepSize = 1.0;
    m_sensors.insert(ptDfiErr.key, ptDfiErr);

    SensorEntry ptCanErr;
    ptCanErr.key = QStringLiteral("PTCanTxErrors");
    ptCanErr.displayName = QStringLiteral("PT CAN TX Errors");
    ptCanErr.category = QStringLiteral("PT Extender");
    ptCanErr.unit = QString();
    ptCanErr.source = SensorSource::ExtenderDigital;
    ptCanErr.active = false;
    ptCanErr.lastActiveTimestamp = 0;
    ptCanErr.decimals = 0;
    ptCanErr.maxValue = 255.0;
    ptCanErr.stepSize = 1.0;
    m_sensors.insert(ptCanErr.key, ptCanErr);

    SensorEntry ptFollowerMask;
    ptFollowerMask.key = QStringLiteral("PTRelayFollowerMask");
    ptFollowerMask.displayName = QStringLiteral("PT Relay Follower Mask");
    ptFollowerMask.category = QStringLiteral("PT Extender");
    ptFollowerMask.unit = QString();
    ptFollowerMask.source = SensorSource::ExtenderDigital;
    ptFollowerMask.active = false;
    ptFollowerMask.lastActiveTimestamp = 0;
    ptFollowerMask.decimals = 0;
    ptFollowerMask.maxValue = 15.0;
    ptFollowerMask.stepSize = 1.0;
    m_sensors.insert(ptFollowerMask.key, ptFollowerMask);

    SensorEntry ptInvertMask;
    ptInvertMask.key = QStringLiteral("PTRelayInvertMask");
    ptInvertMask.displayName = QStringLiteral("PT Relay Invert Mask");
    ptInvertMask.category = QStringLiteral("PT Extender");
    ptInvertMask.unit = QString();
    ptInvertMask.source = SensorSource::ExtenderDigital;
    ptInvertMask.active = false;
    ptInvertMask.lastActiveTimestamp = 0;
    ptInvertMask.decimals = 0;
    ptInvertMask.maxValue = 15.0;
    ptInvertMask.stepSize = 1.0;
    m_sensors.insert(ptInvertMask.key, ptInvertMask);

    SensorEntry ptBoundPack;
    ptBoundPack.key = QStringLiteral("PTRelayBoundTargetsPacked");
    ptBoundPack.displayName = QStringLiteral("PT Relay Bound Targets");
    ptBoundPack.category = QStringLiteral("PT Extender");
    ptBoundPack.unit = QString();
    ptBoundPack.source = SensorSource::ExtenderDigital;
    ptBoundPack.active = false;
    ptBoundPack.lastActiveTimestamp = 0;
    ptBoundPack.decimals = 0;
    ptBoundPack.maxValue = 255.0;
    ptBoundPack.stepSize = 1.0;
    m_sensors.insert(ptBoundPack.key, ptBoundPack);

    SensorEntry ptGear;
    ptGear.key = QStringLiteral("PTGear");
    ptGear.displayName = QStringLiteral("PT Gear");
    ptGear.category = QStringLiteral("PT Extender");
    ptGear.unit = QString();
    ptGear.source = SensorSource::ExtenderDigital;
    ptGear.active = false;
    ptGear.lastActiveTimestamp = 0;
    ptGear.decimals = 0;
    ptGear.maxValue = 7.0;
    ptGear.stepSize = 1.0;
    m_sensors.insert(ptGear.key, ptGear);

    SensorEntry ptActiveCodes;
    ptActiveCodes.key = QStringLiteral("PTActiveCodes");
    ptActiveCodes.displayName = QStringLiteral("PT Active Codes");
    ptActiveCodes.category = QStringLiteral("PT Extender");
    ptActiveCodes.unit = QString();
    ptActiveCodes.source = SensorSource::ExtenderDigital;
    ptActiveCodes.active = false;
    ptActiveCodes.lastActiveTimestamp = 0;
    ptActiveCodes.decimals = 0;
    ptActiveCodes.maxValue = 0.0;
    ptActiveCodes.stepSize = 1.0;
    m_sensors.insert(ptActiveCodes.key, ptActiveCodes);

    scheduleSensorsChanged();
}

void SensorRegistry::refreshAll()
{
    const bool priorSuppress = m_suppressEmit;
    m_suppressEmit = true;
    refreshExtenderAnalogInputs();
    refreshExtenderDigitalInputs();
    m_suppressEmit = priorSuppress;
    if (m_sensorsChangedPending)
        scheduleSensorsChanged();
}

/**
 * @brief Get the total number of registered sensors.
 * @return Count of sensors in the registry
 */
int SensorRegistry::availableCount() const
{
    return m_sensors.count();
}

/**
 * @brief Get all registered sensors as a QVariantList of QVariantMaps.
 * @return List where each entry is a map with key, displayName, category, unit, source, active
 */
QVariantList SensorRegistry::availableSensors() const
{
    return getSensorsByCategory(QString());
}

/**
 * @brief Get the list of unique category names across all registered sensors.
 * @return Sorted list of category strings
 */
QStringList SensorRegistry::availableCategories() const
{
    QSet<QString> categories;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        categories.insert(it->category);
    }
    QStringList result(categories.begin(), categories.end());
    result.sort();
    return result;
}

/**
 * @brief Register built-in sensors that are always available.
 *
 * Registers GPS position/speed/heading/altitude/satellites sensors,
 * SenseHat accelerometer axes (X, Y, Z), gyroscope axes (X, Y, Z),
 * compass heading, ambient temperature, and ambient pressure.
 */
void SensorRegistry::registerBuiltinSensors()
{
    // GPS sensors - always available when GPS hardware is present
    registerSensor(QStringLiteral("gpsLatitude"), QStringLiteral("Latitude"), QStringLiteral("GPS"),
                   QStringLiteral("deg"), SensorSource::GPS, 6, 180.0, 0.000001);
    registerSensor(QStringLiteral("gpsLongitude"), QStringLiteral("Longitude"), QStringLiteral("GPS"),
                   QStringLiteral("deg"), SensorSource::GPS, 6, 180.0, 0.000001);
    registerSensor(QStringLiteral("gpsAltitude"), QStringLiteral("Altitude"), QStringLiteral("GPS"),
                   QStringLiteral("m"), SensorSource::GPS, 1, 10000.0, 1.0);
    registerSensor(QStringLiteral("gpsSpeed"), QStringLiteral("GPS Speed"), QStringLiteral("GPS"),
                   QStringLiteral("km/h"), SensorSource::GPS, 1, 400.0, 1.0);
    registerSensor(QStringLiteral("gpsbearing"), QStringLiteral("Heading"), QStringLiteral("GPS"),
                   QStringLiteral("deg"), SensorSource::GPS, 1, 360.0, 1.0);
    registerSensor(QStringLiteral("gpsVisibleSatelites"), QStringLiteral("Satellites"), QStringLiteral("GPS"),
                   QString(), SensorSource::GPS, 0, 32.0, 1.0);

    // SenseHat accelerometer sensors
    registerSensor(QStringLiteral("accelx"), QStringLiteral("Accelerometer X"), QStringLiteral("Accelerometer"),
                   QStringLiteral("g"), SensorSource::SenseHat, 2, 16.0, 0.1);
    registerSensor(QStringLiteral("accely"), QStringLiteral("Accelerometer Y"), QStringLiteral("Accelerometer"),
                   QStringLiteral("g"), SensorSource::SenseHat, 2, 16.0, 0.1);
    registerSensor(QStringLiteral("accelz"), QStringLiteral("Accelerometer Z"), QStringLiteral("Accelerometer"),
                   QStringLiteral("g"), SensorSource::SenseHat, 2, 16.0, 0.1);

    // SenseHat gyroscope sensors
    registerSensor(QStringLiteral("gyrox"), QStringLiteral("Gyroscope X"), QStringLiteral("Gyroscope"),
                   QStringLiteral("deg/s"), SensorSource::SenseHat, 1, 2000.0, 10.0);
    registerSensor(QStringLiteral("gyroy"), QStringLiteral("Gyroscope Y"), QStringLiteral("Gyroscope"),
                   QStringLiteral("deg/s"), SensorSource::SenseHat, 1, 2000.0, 10.0);
    registerSensor(QStringLiteral("gyroz"), QStringLiteral("Gyroscope Z"), QStringLiteral("Gyroscope"),
                   QStringLiteral("deg/s"), SensorSource::SenseHat, 1, 2000.0, 10.0);

    // SenseHat compass
    registerSensor(QStringLiteral("compass"), QStringLiteral("Compass Heading"), QStringLiteral("Compass"),
                   QStringLiteral("deg"), SensorSource::SenseHat, 1, 360.0, 1.0);

    // SenseHat ambient temperature
    registerSensor(QStringLiteral("ambitemp"), QStringLiteral("Ambient Temperature"), QStringLiteral("Environment"),
                   QStringLiteral("C"), SensorSource::SenseHat, 1, 150.0, 1.0);

    // SenseHat ambient pressure
    registerSensor(QStringLiteral("ambipress"), QStringLiteral("Ambient Pressure"), QStringLiteral("Environment"),
                   QStringLiteral("Pa"), SensorSource::SenseHat, 0, 120000.0, 100.0);
}

/**
 * @brief Convert a SensorEntry to a QVariantMap for QML consumption.
 * @param entry The sensor entry to convert
 * @return QVariantMap with keys: key, displayName, category, unit, source, active
 */
QVariantMap SensorRegistry::entryToVariantMap(const SensorEntry &entry) const
{
    QVariantMap map;
    map[QStringLiteral("key")] = entry.key;
    map[QStringLiteral("displayName")] = entry.displayName;
    map[QStringLiteral("category")] = entry.category;
    map[QStringLiteral("unit")] = entry.unit;
    map[QStringLiteral("decimals")] = entry.decimals;
    map[QStringLiteral("maxValue")] = entry.maxValue;
    map[QStringLiteral("stepSize")] = entry.stepSize;

    // Convert enum to string for QML
    const QMetaEnum metaEnum = QMetaEnum::fromType<SensorSource>();
    map[QStringLiteral("source")] = QString::fromLatin1(metaEnum.valueToKey(static_cast<int>(entry.source)));
    map[QStringLiteral("active")] = entry.active;

    return map;
}

/**
 * @brief Timer callback to mark sensors as inactive if no data received recently.
 *
 * Iterates all non-Computed sensors and sets active=false for any that have not
 * received data within the last 10 seconds. Emits sensorsChanged if any state changed.
 */
void SensorRegistry::checkCanTimeouts()
{
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    bool changed = false;

    for (auto it = m_sensors.begin(); it != m_sensors.end(); ++it) {
        if (it->source == SensorSource::Computed)
            continue;
        if (it->active && it->lastActiveTimestamp > 0 && (now - it->lastActiveTimestamp) > kCanTimeoutMs) {
            it->active = false;
            changed = true;
        }
    }

    if (changed) {
        scheduleSensorsChanged();
    }
}

void SensorRegistry::scheduleSensorsChanged()
{
    if (m_suppressEmit) {
        m_sensorsChangedPending = true;
        return;
    }
    if (m_sensorsChangedPending)
        return;
    m_sensorsChangedPending = true;
    m_sensorsChangedTimer.start();
}

void SensorRegistry::emitScheduledSensorsChanged()
{
    if (!m_sensorsChangedPending)
        return;
    m_sensorsChangedPending = false;
    emit sensorsChanged();
}
