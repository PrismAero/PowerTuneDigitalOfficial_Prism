// Copyright (c) 2026 Kai Wyborny. All rights reserved.

/**
 * @file SensorRegistry.cpp
 * @brief Implementation of the SensorRegistry runtime sensor tracking class.
 */

#include "SensorRegistry.h"

#include <QDateTime>
#include <QDebug>
#include <QMetaEnum>
#include <QSettings>

/// DaemonUDP sensor timeout threshold in milliseconds (10 seconds)
static constexpr qint64 kCanTimeoutMs = 10000;

/// DaemonUDP timeout check interval in milliseconds (5 seconds)
static constexpr int kCanCheckIntervalMs = 5000;

/**
 * @brief Construct a SensorRegistry and populate it with built-in and common DaemonUDP sensors.
 *
 * Sets up the DaemonUDP timeout timer to periodically check for stale sensors.
 *
 * @param parent QObject parent
 */
SensorRegistry::SensorRegistry(QObject *parent) : QObject(parent)
{
    registerBuiltinSensors();
    registerCommonCanSensors();

    // Set up the DaemonUDP timeout timer to mark stale sensors as inactive
    m_canTimeoutTimer.setInterval(kCanCheckIntervalMs);
    connect(&m_canTimeoutTimer, &QTimer::timeout, this, &SensorRegistry::checkCanTimeouts);
    m_canTimeoutTimer.start();
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
    emit sensorsChanged();
}

/**
 * @brief Unregister a sensor, removing it from the registry entirely.
 * @param key Unique property key
 */
void SensorRegistry::unregisterSensor(const QString &key)
{
    if (m_sensors.remove(key) > 0) {
        emit sensorUnregistered(key);
        emit sensorsChanged();
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
 * @param key Property key from UDPReceiver
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
        emit sensorsChanged();
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
        emit sensorsChanged();
}

/**
 * @brief Register ECU-reported analog voltage channels Analog0 through Analog10.
 *
 * Removes any previously registered DaemonUDP analog input sensors and re-registers
 * them based on current configuration. Also registers AnalogCalc0 through AnalogCalc10
 * calibrated/calculated analog channels.
 *
 * These are ECU-reported analog voltage channels received via daemon UDP (port 45454),
 * not physical Raspberry Pi analog inputs.
 *
 * Call this when analog input settings change.
 */
void SensorRegistry::refreshEcuAnalogChannels()
{
    // Remove existing DaemonUDP analog input entries (keys starting with "Analog")
    QStringList toRemove;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (it->source == SensorSource::DaemonUDP && it.key().startsWith(QStringLiteral("Analog"))) {
            toRemove.append(it.key());
        }
    }
    for (const QString &key : toRemove) {
        m_sensors.remove(key);
    }

    // Register Analog0 through Analog10
    for (int i = 0; i <= 10; ++i) {
        const QString key = QStringLiteral("Analog%1").arg(i);
        const QString displayName = QStringLiteral("Analog Input %1").arg(i);

        SensorEntry entry;
        entry.key = key;
        entry.displayName = displayName;
        entry.category = QStringLiteral("Analog Inputs");
        entry.unit = QStringLiteral("V");
        entry.source = SensorSource::DaemonUDP;
        entry.active = false;
        entry.lastActiveTimestamp = 0;
        entry.decimals = 3;
        entry.maxValue = 5.0;
        entry.stepSize = 0.1;
        m_sensors.insert(key, entry);
    }

    // Register calibrated/calculated analog channels
    for (int i = 0; i <= 10; ++i) {
        const QString key = QStringLiteral("AnalogCalc%1").arg(i);
        const QString displayName = QStringLiteral("Analog Calc %1").arg(i);

        SensorEntry entry;
        entry.key = key;
        entry.displayName = displayName;
        entry.category = QStringLiteral("Analog Inputs");
        entry.unit = QString();
        entry.source = SensorSource::DaemonUDP;
        entry.active = false;
        entry.lastActiveTimestamp = 0;
        entry.decimals = 2;
        entry.maxValue = 100.0;
        entry.stepSize = 1.0;
        m_sensors.insert(key, entry);
    }

    emit sensorsChanged();
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
    // Remove existing ExtenderAnalog entries
    QStringList toRemove;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (it->source == SensorSource::ExtenderAnalog) {
            toRemove.append(it.key());
        }
    }
    for (const QString &key : toRemove) {
        m_sensors.remove(key);
    }

    QSettings settings(QStringLiteral("PowerTune"), QStringLiteral("PowerTune"));

    // Register EXAnalogInput0 through EXAnalogInput7
    for (int i = 0; i <= 7; ++i) {
        const QString key = QStringLiteral("EXAnalogInput%1").arg(i);
        const QString customName = settings.value(QStringLiteral("ui/exboard/exan%1name").arg(i)).toString();
        const QString displayName = customName.isEmpty() ? QStringLiteral("EX Analog %1").arg(i)
                                                         : QStringLiteral("EX AN %1: %2").arg(i).arg(customName);

        SensorEntry entry;
        entry.key = key;
        entry.displayName = displayName;
        entry.category = QStringLiteral("Extender Board");
        entry.unit = QStringLiteral("V");
        entry.source = SensorSource::ExtenderAnalog;
        entry.active = false;
        entry.lastActiveTimestamp = 0;
        entry.decimals = 3;
        entry.maxValue = 5.0;
        entry.stepSize = 0.1;
        m_sensors.insert(key, entry);
    }

    // Register calibrated/calculated extender analog channels
    for (int i = 0; i <= 7; ++i) {
        const QString key = QStringLiteral("EXAnalogCalc%1").arg(i);
        const QString customName = settings.value(QStringLiteral("ui/exboard/exan%1name").arg(i)).toString();
        const QString displayName = customName.isEmpty() ? QStringLiteral("EX Analog Calc %1").arg(i)
                                                         : QStringLiteral("EX AN Calc %1: %2").arg(i).arg(customName);

        SensorEntry entry;
        entry.key = key;
        entry.displayName = displayName;
        entry.category = QStringLiteral("Extender Board");
        entry.unit = QString();
        entry.source = SensorSource::ExtenderAnalog;
        entry.active = false;
        entry.lastActiveTimestamp = 0;
        entry.decimals = 2;
        entry.maxValue = 100.0;
        entry.stepSize = 1.0;
        m_sensors.insert(key, entry);
    }

    emit sensorsChanged();
}

/**
 * @brief Register ECU-reported digital input channels DigitalInput1 through DigitalInput7.
 *
 * Removes any previously registered DaemonUDP digital input sensors and re-registers
 * them. These are ECU-reported digital input states received via daemon UDP (port 45454),
 * not physical Raspberry Pi GPIO inputs.
 *
 * Call this when digital input settings change.
 */
void SensorRegistry::refreshEcuDigitalInputs()
{
    // Remove existing DaemonUDP digital input entries (keys starting with "DigitalInput")
    QStringList toRemove;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (it->source == SensorSource::DaemonUDP && it.key().startsWith(QStringLiteral("DigitalInput"))) {
            toRemove.append(it.key());
        }
    }
    for (const QString &key : toRemove) {
        m_sensors.remove(key);
    }

    // Register DigitalInput1 through DigitalInput7
    for (int i = 1; i <= 7; ++i) {
        const QString key = QStringLiteral("DigitalInput%1").arg(i);
        const QString displayName = QStringLiteral("Digital Input %1").arg(i);

        SensorEntry entry;
        entry.key = key;
        entry.displayName = displayName;
        entry.category = QStringLiteral("Digital Inputs");
        entry.unit = QString();
        entry.source = SensorSource::DaemonUDP;
        entry.active = false;
        entry.lastActiveTimestamp = 0;
        entry.decimals = 0;
        entry.maxValue = 1.0;
        entry.stepSize = 1.0;
        m_sensors.insert(key, entry);
    }

    emit sensorsChanged();
}

/**
 * @brief Refreshes extender board digital input sensors in the registry.
 *
 * Registers EXDigitalInput1 through EXDigitalInput8 (1-indexed per reference).
 * These are digital inputs from the extender board received via CAN bus.
 */
void SensorRegistry::refreshExtenderDigitalInputs()
{
    // Remove existing ExtenderDigital entries
    QStringList toRemove;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (it->source == SensorSource::ExtenderDigital) {
            toRemove.append(it.key());
        }
    }
    for (const QString &key : toRemove) {
        m_sensors.remove(key);
    }

    QSettings settings(QStringLiteral("PowerTune"), QStringLiteral("PowerTune"));

    // Register EXDigitalInput1 through EXDigitalInput8 (1-indexed per reference)
    for (int i = 1; i <= 8; ++i) {
        const QString key = QStringLiteral("EXDigitalInput%1").arg(i);
        const QString customName = settings.value(QStringLiteral("ui/exboard/exdigi%1name").arg(i)).toString();
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

    emit sensorsChanged();
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
 * @brief Register common CAN/daemon sensors that most ECUs provide.
 *
 * All DaemonUDP sensors are registered with active=false. They become active
 * when markCanSensorActive() is called (i.e., when UDPReceiver receives data).
 * The property keys match the Q_PROPERTY names in the domain data models.
 */
void SensorRegistry::registerCommonCanSensors()
{
    // Helper lambda to reduce boilerplate for DaemonUDP sensor registration
    auto reg = [this](const QString &key, const QString &name, const QString &category, const QString &unit,
                      int decimals = 2, double maxValue = 100.0, double stepSize = 1.0) {
        SensorEntry entry;
        entry.key = key;
        entry.displayName = name;
        entry.category = category;
        entry.unit = unit;
        entry.source = SensorSource::DaemonUDP;
        entry.active = false;
        entry.lastActiveTimestamp = 0;
        entry.decimals = decimals;
        entry.maxValue = maxValue;
        entry.stepSize = stepSize;
        m_sensors.insert(key, entry);
    };

    // -- Engine category --
    reg(QStringLiteral("rpm"), QStringLiteral("RPM"), QStringLiteral("Engine"), QStringLiteral("rpm"), 0, 10000.0,
        100.0);
    reg(QStringLiteral("BoostPres"), QStringLiteral("Boost Pressure"), QStringLiteral("Engine"), QStringLiteral("psi"),
        1, 60.0, 1.0);
    reg(QStringLiteral("BoostPreskpa"), QStringLiteral("Boost Pressure kPa"), QStringLiteral("Engine"),
        QStringLiteral("kPa"), 0, 400.0, 5.0);
    reg(QStringLiteral("MAP"), QStringLiteral("Manifold Pressure"), QStringLiteral("Engine"), QStringLiteral("kPa"), 0,
        400.0, 5.0);
    reg(QStringLiteral("TPS"), QStringLiteral("Throttle Position"), QStringLiteral("Engine"), QStringLiteral("%"), 1,
        100.0, 1.0);
    reg(QStringLiteral("Intaketemp"), QStringLiteral("Intake Air Temp"), QStringLiteral("Engine"), QStringLiteral("C"),
        1, 200.0, 1.0);
    reg(QStringLiteral("Watertemp"), QStringLiteral("Coolant Temp"), QStringLiteral("Engine"), QStringLiteral("C"), 1,
        200.0, 1.0);
    reg(QStringLiteral("AFR"), QStringLiteral("Air Fuel Ratio"), QStringLiteral("Engine"), QStringLiteral("AFR"), 2,
        25.0, 0.1);
    reg(QStringLiteral("LAMBDA"), QStringLiteral("Lambda"), QStringLiteral("Engine"), QStringLiteral("lambda"), 2, 2.0,
        0.01);
    reg(QStringLiteral("InjDuty"), QStringLiteral("Injector Duty"), QStringLiteral("Engine"), QStringLiteral("%"), 1,
        100.0, 1.0);
    reg(QStringLiteral("Ign"), QStringLiteral("Ignition Timing"), QStringLiteral("Engine"), QStringLiteral("deg"), 1,
        80.0, 1.0);
    reg(QStringLiteral("EngLoad"), QStringLiteral("Engine Load"), QStringLiteral("Engine"), QStringLiteral("%"), 1,
        100.0, 1.0);
    reg(QStringLiteral("Knock"), QStringLiteral("Knock Level"), QStringLiteral("Engine"), QString());
    reg(QStringLiteral("Dwell"), QStringLiteral("Dwell"), QStringLiteral("Engine"), QStringLiteral("ms"));
    reg(QStringLiteral("BoostDuty"), QStringLiteral("Boost Duty"), QStringLiteral("Engine"), QStringLiteral("%"));
    reg(QStringLiteral("Intakepress"), QStringLiteral("Intake Pressure"), QStringLiteral("Engine"),
        QStringLiteral("kPa"));
    reg(QStringLiteral("Power"), QStringLiteral("Power"), QStringLiteral("Engine"), QStringLiteral("kW"), 1, 2000.0,
        10.0);
    reg(QStringLiteral("Torque"), QStringLiteral("Torque"), QStringLiteral("Engine"), QStringLiteral("Nm"), 1, 2000.0,
        10.0);

    reg(QStringLiteral("brakepress"), QStringLiteral("Brake Pressure"), QStringLiteral("Engine"),
        QStringLiteral("psi"));
    reg(QStringLiteral("coolantpress"), QStringLiteral("Coolant Pressure"), QStringLiteral("Engine"),
        QStringLiteral("psi"));
    reg(QStringLiteral("MAP2"), QStringLiteral("Manifold Pressure 2"), QStringLiteral("Engine"), QStringLiteral("kPa"));
    reg(QStringLiteral("turborpm"), QStringLiteral("Turbo RPM"), QStringLiteral("Engine"), QStringLiteral("rpm"));
    reg(QStringLiteral("wastegatepress"), QStringLiteral("Wastegate Pressure"), QStringLiteral("Engine"),
        QStringLiteral("psi"));
    reg(QStringLiteral("accelpedpos"), QStringLiteral("Accel Pedal Pos"), QStringLiteral("Engine"),
        QStringLiteral("%"));

    // -- Vehicle category --
    reg(QStringLiteral("speed"), QStringLiteral("Vehicle Speed"), QStringLiteral("Vehicle"), QStringLiteral("km/h"), 1,
        400.0, 1.0);
    reg(QStringLiteral("Gear"), QStringLiteral("Gear"), QStringLiteral("Vehicle"), QString());
    reg(QStringLiteral("Odo"), QStringLiteral("Odometer"), QStringLiteral("Vehicle"), QStringLiteral("km"), 1, 999999.0,
        1.0);
    reg(QStringLiteral("BatteryV"), QStringLiteral("Battery Voltage"), QStringLiteral("Vehicle"), QStringLiteral("V"),
        2, 24.0, 0.1);
    reg(QStringLiteral("FuelLevel"), QStringLiteral("Fuel Level (Vehicle)"), QStringLiteral("Vehicle"),
        QStringLiteral("%"));
    reg(QStringLiteral("SteeringWheelAngle"), QStringLiteral("Steering Angle"), QStringLiteral("Vehicle"),
        QStringLiteral("deg"));
    reg(QStringLiteral("wheelspdftleft"), QStringLiteral("Wheel Speed FL"), QStringLiteral("Vehicle"),
        QStringLiteral("km/h"));
    reg(QStringLiteral("wheelspdftright"), QStringLiteral("Wheel Speed FR"), QStringLiteral("Vehicle"),
        QStringLiteral("km/h"));
    reg(QStringLiteral("wheelspdrearleft"), QStringLiteral("Wheel Speed RL"), QStringLiteral("Vehicle"),
        QStringLiteral("km/h"));
    reg(QStringLiteral("wheelspdrearright"), QStringLiteral("Wheel Speed RR"), QStringLiteral("Vehicle"),
        QStringLiteral("km/h"));

    // -- Fuel category --
    reg(QStringLiteral("FuelPress"), QStringLiteral("Fuel Pressure"), QStringLiteral("Fuel"), QStringLiteral("psi"), 1,
        150.0, 1.0);
    reg(QStringLiteral("Fueltemp"), QStringLiteral("Fuel Temperature"), QStringLiteral("Fuel"), QStringLiteral("C"), 1,
        200.0, 1.0);
    reg(QStringLiteral("fuelclevel"), QStringLiteral("Fuel Level"), QStringLiteral("Fuel"), QStringLiteral("%"));
    reg(QStringLiteral("fuelflow"), QStringLiteral("Fuel Flow"), QStringLiteral("Fuel"), QStringLiteral("cc/min"));
    reg(QStringLiteral("fuelconsrate"), QStringLiteral("Fuel Consumption"), QStringLiteral("Fuel"),
        QStringLiteral("L/100km"));

    // -- Oil category --
    reg(QStringLiteral("oilpres"), QStringLiteral("Oil Pressure"), QStringLiteral("Oil"), QStringLiteral("psi"), 1,
        150.0, 1.0);
    reg(QStringLiteral("oiltemp"), QStringLiteral("Oil Temperature"), QStringLiteral("Oil"), QStringLiteral("C"), 1,
        200.0, 1.0);
    reg(QStringLiteral("transoiltemp"), QStringLiteral("Trans Oil Temp"), QStringLiteral("Oil"), QStringLiteral("C"), 1,
        200.0, 1.0);
    reg(QStringLiteral("diffoiltemp"), QStringLiteral("Diff Oil Temp"), QStringLiteral("Oil"), QStringLiteral("C"), 1,
        200.0, 1.0);
    reg(QStringLiteral("GearOilPress"), QStringLiteral("Gear Oil Pressure"), QStringLiteral("Oil"),
        QStringLiteral("psi"));
    reg(QStringLiteral("Moilp"), QStringLiteral("Oil Pressure 2"), QStringLiteral("Oil"), QStringLiteral("psi"));

    // -- Exhaust category (EGT 1-12) --
    for (int i = 1; i <= 12; ++i) {
        reg(QStringLiteral("egt%1").arg(i), QStringLiteral("EGT %1").arg(i), QStringLiteral("Exhaust"),
            QStringLiteral("C"));
    }

    reg(QStringLiteral("egthighest"), QStringLiteral("EGT Highest"), QStringLiteral("Exhaust"), QStringLiteral("C"));

    // -- Tires category --
    reg(QStringLiteral("TiretempLF"), QStringLiteral("Tire Temp LF"), QStringLiteral("Tires"), QStringLiteral("C"));
    reg(QStringLiteral("TiretempRF"), QStringLiteral("Tire Temp RF"), QStringLiteral("Tires"), QStringLiteral("C"));
    reg(QStringLiteral("TiretempLR"), QStringLiteral("Tire Temp LR"), QStringLiteral("Tires"), QStringLiteral("C"));
    reg(QStringLiteral("TiretempRR"), QStringLiteral("Tire Temp RR"), QStringLiteral("Tires"), QStringLiteral("C"));
    reg(QStringLiteral("TirepresLF"), QStringLiteral("Tire Press LF"), QStringLiteral("Tires"), QStringLiteral("psi"));
    reg(QStringLiteral("TirepresRF"), QStringLiteral("Tire Press RF"), QStringLiteral("Tires"), QStringLiteral("psi"));
    reg(QStringLiteral("TirepresLR"), QStringLiteral("Tire Press LR"), QStringLiteral("Tires"), QStringLiteral("psi"));
    reg(QStringLiteral("TirepresRR"), QStringLiteral("Tire Press RR"), QStringLiteral("Tires"), QStringLiteral("psi"));

    // -- Electrical category --
    reg(QStringLiteral("O2volt"), QStringLiteral("O2 Voltage"), QStringLiteral("Electrical"), QStringLiteral("V"));
    reg(QStringLiteral("O2volt_2"), QStringLiteral("O2 Voltage 2"), QStringLiteral("Electrical"), QStringLiteral("V"));
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
        emit sensorsChanged();
    }
}
