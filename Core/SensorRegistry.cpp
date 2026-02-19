// Copyright (c) 2026 Kai Wyborny. All rights reserved.

/**
 * @file SensorRegistry.cpp
 * @brief Implementation of the SensorRegistry runtime sensor tracking class.
 */

#include "SensorRegistry.h"

#include <QDateTime>
#include <QDebug>
#include <QMetaEnum>
#include <algorithm>

/// CAN sensor timeout threshold in milliseconds (10 seconds)
static constexpr qint64 kCanTimeoutMs = 10000;

/// CAN timeout check interval in milliseconds (5 seconds)
static constexpr int kCanCheckIntervalMs = 5000;

/**
 * @brief Construct a SensorRegistry and populate it with built-in and common CAN sensors.
 *
 * Sets up the CAN timeout timer to periodically check for stale CAN sensors.
 *
 * @param parent QObject parent
 */
SensorRegistry::SensorRegistry(QObject *parent)
    : QObject(parent)
{
    registerBuiltinSensors();
    registerCommonCanSensors();

    // Set up the CAN timeout timer to mark stale CAN sensors as inactive
    m_canTimeoutTimer.setInterval(kCanCheckIntervalMs);
    connect(&m_canTimeoutTimer, &QTimer::timeout, this, &SensorRegistry::checkCanTimeouts);
    m_canTimeoutTimer.start();
}

/**
 * @brief Register a sensor as available in the registry.
 *
 * If a sensor with the same key already exists, it is updated in place.
 *
 * @param key Unique property key (e.g., "rpm", "boost", "an1")
 * @param displayName Human-readable name (e.g., "RPM", "Boost Pressure")
 * @param category Category for grouping (e.g., "Engine", "Analog Inputs")
 * @param unit Unit string (e.g., "rpm", "psi", "V")
 * @param source Where this sensor data comes from
 */
void SensorRegistry::registerSensor(const QString &key, const QString &displayName,
                                    const QString &category, const QString &unit,
                                    SensorSource source)
{
    const bool isNew = !m_sensors.contains(key);

    SensorEntry entry;
    entry.key = key;
    entry.displayName = displayName;
    entry.category = category;
    entry.unit = unit;
    entry.source = source;
    entry.active = (source != SensorSource::CAN); // CAN sensors start inactive
    entry.lastActiveTimestamp = 0;

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
QVariantList SensorRegistry::getSensorsByCategory(const QString &category) const
{
    QVariantList result;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (category.isEmpty() || it->category == category) {
            result.append(entryToVariantMap(it.value()));
        }
    }
    return result;
}

/**
 * @brief Check from QML if a sensor key is available.
 * @param key Sensor property key
 * @return true if available
 */
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

/**
 * @brief Register analog input channels AN1 through AN11.
 *
 * Removes any previously registered analog input sensors and re-registers
 * them based on current configuration. Call this when analog input settings change.
 */
void SensorRegistry::refreshAnalogInputs()
{
    // Remove existing analog input entries
    QStringList toRemove;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (it->source == SensorSource::AnalogInput) {
            toRemove.append(it.key());
        }
    }
    for (const QString &key : toRemove) {
        m_sensors.remove(key);
    }

    // Register AN1 through AN11
    for (int i = 1; i <= 11; ++i) {
        const QString key = QStringLiteral("an%1").arg(i);
        const QString displayName = QStringLiteral("Analog Input %1").arg(i);

        SensorEntry entry;
        entry.key = key;
        entry.displayName = displayName;
        entry.category = QStringLiteral("Analog Inputs");
        entry.unit = QStringLiteral("V");
        entry.source = SensorSource::AnalogInput;
        entry.active = true;
        entry.lastActiveTimestamp = 0;
        m_sensors.insert(key, entry);
    }

    emit sensorsChanged();
}

/**
 * @brief Register expander board analog channels EX_AN1 through EX_AN8.
 *
 * Removes any previously registered expander board sensors and re-registers
 * them. Call this when expander board settings change.
 */
void SensorRegistry::refreshExpanderBoard()
{
    // Remove existing expander board entries
    QStringList toRemove;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (it->source == SensorSource::ExpanderBoard) {
            toRemove.append(it.key());
        }
    }
    for (const QString &key : toRemove) {
        m_sensors.remove(key);
    }

    // Register EX_AN1 through EX_AN8
    for (int i = 1; i <= 8; ++i) {
        const QString key = QStringLiteral("ex_an%1").arg(i);
        const QString displayName = QStringLiteral("Expander Analog %1").arg(i);

        SensorEntry entry;
        entry.key = key;
        entry.displayName = displayName;
        entry.category = QStringLiteral("Expander Board");
        entry.unit = QStringLiteral("V");
        entry.source = SensorSource::ExpanderBoard;
        entry.active = true;
        entry.lastActiveTimestamp = 0;
        m_sensors.insert(key, entry);
    }

    emit sensorsChanged();
}

/**
 * @brief Register digital input channels DI1 through DI4.
 *
 * Removes any previously registered digital input sensors and re-registers
 * them. Call this when digital input settings change.
 */
void SensorRegistry::refreshDigitalInputs()
{
    // Remove existing digital input entries
    QStringList toRemove;
    for (auto it = m_sensors.constBegin(); it != m_sensors.constEnd(); ++it) {
        if (it->source == SensorSource::DigitalInput) {
            toRemove.append(it.key());
        }
    }
    for (const QString &key : toRemove) {
        m_sensors.remove(key);
    }

    // Register DI1 through DI4
    for (int i = 1; i <= 4; ++i) {
        const QString key = QStringLiteral("di%1").arg(i);
        const QString displayName = QStringLiteral("Digital Input %1").arg(i);

        SensorEntry entry;
        entry.key = key;
        entry.displayName = displayName;
        entry.category = QStringLiteral("Digital Inputs");
        entry.unit = QString();
        entry.source = SensorSource::DigitalInput;
        entry.active = true;
        entry.lastActiveTimestamp = 0;
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
 * Registers GPS position/speed/heading/altitude/satellites sensors and
 * SenseHat accelerometer axes (X, Y, Z).
 */
void SensorRegistry::registerBuiltinSensors()
{
    // GPS sensors - always available when GPS hardware is present
    registerSensor(QStringLiteral("gpsLatitude"),
                   QStringLiteral("Latitude"), QStringLiteral("GPS"),
                   QStringLiteral("deg"), SensorSource::GPS);
    registerSensor(QStringLiteral("gpsLongitude"),
                   QStringLiteral("Longitude"), QStringLiteral("GPS"),
                   QStringLiteral("deg"), SensorSource::GPS);
    registerSensor(QStringLiteral("gpsAltitude"),
                   QStringLiteral("Altitude"), QStringLiteral("GPS"),
                   QStringLiteral("m"), SensorSource::GPS);
    registerSensor(QStringLiteral("gpsSpeed"),
                   QStringLiteral("GPS Speed"), QStringLiteral("GPS"),
                   QStringLiteral("km/h"), SensorSource::GPS);
    registerSensor(QStringLiteral("gpsbearing"),
                   QStringLiteral("Heading"), QStringLiteral("GPS"),
                   QStringLiteral("deg"), SensorSource::GPS);
    registerSensor(QStringLiteral("gpsVisibleSatelites"),
                   QStringLiteral("Satellites"), QStringLiteral("GPS"),
                   QString(), SensorSource::GPS);

    // SenseHat accelerometer sensors
    registerSensor(QStringLiteral("accelX"),
                   QStringLiteral("Accelerometer X"), QStringLiteral("Accelerometer"),
                   QStringLiteral("g"), SensorSource::SenseHat);
    registerSensor(QStringLiteral("accelY"),
                   QStringLiteral("Accelerometer Y"), QStringLiteral("Accelerometer"),
                   QStringLiteral("g"), SensorSource::SenseHat);
    registerSensor(QStringLiteral("accelZ"),
                   QStringLiteral("Accelerometer Z"), QStringLiteral("Accelerometer"),
                   QStringLiteral("g"), SensorSource::SenseHat);
}

/**
 * @brief Register common CAN/daemon sensors that most ECUs provide.
 *
 * All CAN sensors are registered with active=false. They become active
 * when markCanSensorActive() is called (i.e., when UDPReceiver receives data).
 * The property keys match the Q_PROPERTY names in the domain data models.
 */
void SensorRegistry::registerCommonCanSensors()
{
    // Helper lambda to reduce boilerplate for CAN sensor registration
    auto reg = [this](const QString &key, const QString &name,
                      const QString &category, const QString &unit) {
        SensorEntry entry;
        entry.key = key;
        entry.displayName = name;
        entry.category = category;
        entry.unit = unit;
        entry.source = SensorSource::CAN;
        entry.active = false;
        entry.lastActiveTimestamp = 0;
        m_sensors.insert(key, entry);
    };

    // -- Engine category --
    reg(QStringLiteral("rpm"),            QStringLiteral("RPM"),                QStringLiteral("Engine"), QStringLiteral("rpm"));
    reg(QStringLiteral("BoostPres"),      QStringLiteral("Boost Pressure"),     QStringLiteral("Engine"), QStringLiteral("psi"));
    reg(QStringLiteral("BoostPreskpa"),   QStringLiteral("Boost Pressure kPa"), QStringLiteral("Engine"), QStringLiteral("kPa"));
    reg(QStringLiteral("MAP"),            QStringLiteral("Manifold Pressure"),  QStringLiteral("Engine"), QStringLiteral("kPa"));
    reg(QStringLiteral("TPS"),            QStringLiteral("Throttle Position"),  QStringLiteral("Engine"), QStringLiteral("%"));
    reg(QStringLiteral("Intaketemp"),     QStringLiteral("Intake Air Temp"),    QStringLiteral("Engine"), QStringLiteral("C"));
    reg(QStringLiteral("Watertemp"),      QStringLiteral("Coolant Temp"),       QStringLiteral("Engine"), QStringLiteral("C"));
    reg(QStringLiteral("AFR"),            QStringLiteral("Air Fuel Ratio"),     QStringLiteral("Engine"), QStringLiteral("AFR"));
    reg(QStringLiteral("LAMBDA"),         QStringLiteral("Lambda"),             QStringLiteral("Engine"), QStringLiteral("lambda"));
    reg(QStringLiteral("InjDuty"),        QStringLiteral("Injector Duty"),      QStringLiteral("Engine"), QStringLiteral("%"));
    reg(QStringLiteral("Ign"),            QStringLiteral("Ignition Timing"),    QStringLiteral("Engine"), QStringLiteral("deg"));
    reg(QStringLiteral("EngLoad"),        QStringLiteral("Engine Load"),        QStringLiteral("Engine"), QStringLiteral("%"));
    reg(QStringLiteral("Knock"),          QStringLiteral("Knock Level"),        QStringLiteral("Engine"), QString());
    reg(QStringLiteral("Dwell"),          QStringLiteral("Dwell"),              QStringLiteral("Engine"), QStringLiteral("ms"));
    reg(QStringLiteral("BoostDuty"),      QStringLiteral("Boost Duty"),         QStringLiteral("Engine"), QStringLiteral("%"));
    reg(QStringLiteral("Intakepress"),    QStringLiteral("Intake Pressure"),    QStringLiteral("Engine"), QStringLiteral("kPa"));
    reg(QStringLiteral("Power"),          QStringLiteral("Power"),              QStringLiteral("Engine"), QStringLiteral("kW"));
    reg(QStringLiteral("Torque"),         QStringLiteral("Torque"),             QStringLiteral("Engine"), QStringLiteral("Nm"));

    // -- Vehicle category --
    reg(QStringLiteral("speed"),          QStringLiteral("Vehicle Speed"),      QStringLiteral("Vehicle"), QStringLiteral("km/h"));
    reg(QStringLiteral("Gear"),           QStringLiteral("Gear"),               QStringLiteral("Vehicle"), QString());
    reg(QStringLiteral("Odo"),            QStringLiteral("Odometer"),           QStringLiteral("Vehicle"), QStringLiteral("km"));
    reg(QStringLiteral("batteryVoltage"), QStringLiteral("Battery Voltage"),    QStringLiteral("Vehicle"), QStringLiteral("V"));

    // -- Fuel category --
    reg(QStringLiteral("FuelPress"),      QStringLiteral("Fuel Pressure"),      QStringLiteral("Fuel"), QStringLiteral("psi"));
    reg(QStringLiteral("Fueltemp"),       QStringLiteral("Fuel Temperature"),   QStringLiteral("Fuel"), QStringLiteral("C"));
    reg(QStringLiteral("fuelclevel"),     QStringLiteral("Fuel Level"),         QStringLiteral("Fuel"), QStringLiteral("%"));
    reg(QStringLiteral("fuelflow"),       QStringLiteral("Fuel Flow"),          QStringLiteral("Fuel"), QStringLiteral("cc/min"));
    reg(QStringLiteral("fuelconsrate"),   QStringLiteral("Fuel Consumption"),   QStringLiteral("Fuel"), QStringLiteral("L/100km"));

    // -- Oil category --
    reg(QStringLiteral("oilpres"),        QStringLiteral("Oil Pressure"),       QStringLiteral("Oil"), QStringLiteral("psi"));
    reg(QStringLiteral("oiltemp"),        QStringLiteral("Oil Temperature"),    QStringLiteral("Oil"), QStringLiteral("C"));
    reg(QStringLiteral("transoiltemp"),   QStringLiteral("Trans Oil Temp"),     QStringLiteral("Oil"), QStringLiteral("C"));
    reg(QStringLiteral("diffoiltemp"),    QStringLiteral("Diff Oil Temp"),      QStringLiteral("Oil"), QStringLiteral("C"));

    // -- Exhaust category (EGT 1-12) --
    for (int i = 1; i <= 12; ++i) {
        reg(QStringLiteral("egt%1").arg(i),
            QStringLiteral("EGT %1").arg(i),
            QStringLiteral("Exhaust"),
            QStringLiteral("C"));
    }

    // -- Electrical category --
    // batteryVoltage already registered under Vehicle
    // Sensors for SensorData model
    reg(QStringLiteral("O2volt"),         QStringLiteral("O2 Voltage"),         QStringLiteral("Electrical"), QStringLiteral("V"));
    reg(QStringLiteral("O2volt_2"),       QStringLiteral("O2 Voltage 2"),       QStringLiteral("Electrical"), QStringLiteral("V"));
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

    // Convert enum to string for QML
    const QMetaEnum metaEnum = QMetaEnum::fromType<SensorSource>();
    map[QStringLiteral("source")] = QString::fromLatin1(metaEnum.valueToKey(static_cast<int>(entry.source)));
    map[QStringLiteral("active")] = entry.active;

    return map;
}

/**
 * @brief Timer callback to mark CAN sensors as inactive if no data received recently.
 *
 * Iterates all CAN-sourced sensors and sets active=false for any that have not
 * received data within the last 10 seconds. Emits sensorsChanged if any state changed.
 */
void SensorRegistry::checkCanTimeouts()
{
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    bool changed = false;

    for (auto it = m_sensors.begin(); it != m_sensors.end(); ++it) {
        if (it->source == SensorSource::CAN && it->active) {
            if (it->lastActiveTimestamp > 0 && (now - it->lastActiveTimestamp) > kCanTimeoutMs) {
                it->active = false;
                changed = true;
            }
        }
    }

    if (changed) {
        emit sensorsChanged();
    }
}
