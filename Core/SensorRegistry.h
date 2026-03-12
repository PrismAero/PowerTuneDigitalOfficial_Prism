// Copyright (c) 2026 Kai Wyborny. All rights reserved.

/**
 * @file SensorRegistry.h
 * @brief Runtime registry tracking which sensors are actually available.
 *
 * Sensors can be registered from multiple sources:
 * - ECU data via daemon UDP (engine data, analog channels, digital inputs)
 * - Extender board analog inputs via CAN
 * - Extender board digital inputs via CAN
 * - Built-in hardware (GPS, SenseHat)
 * - Computed values derived from other sensors
 *
 * The registry provides a filtered list to the dashboard creator
 * so only available sensors are shown.
 */

#ifndef SENSORREGISTRY_H
#define SENSORREGISTRY_H

#include <QMap>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>

class SensorRegistry : public QObject
{
    Q_OBJECT

    /// Total number of available sensors
    Q_PROPERTY(int availableCount READ availableCount NOTIFY sensorsChanged)

    /// List of all available sensor entries as QVariantList of QVariantMaps
    Q_PROPERTY(QVariantList availableSensors READ availableSensors NOTIFY sensorsChanged)

    /// List of available category names
    Q_PROPERTY(QStringList availableCategories READ availableCategories NOTIFY sensorsChanged)

public:
    explicit SensorRegistry(QObject *parent = nullptr);

    // -- Sensor source enum --

    /**
     * @brief Identifies where a sensor's data originates.
     */
    enum class SensorSource {
        DaemonUDP,        ///< ECU data via daemon UDP (port 45454) - includes engine data,
                          ///< ECU-reported analog channels (Analog0-10), and
                          ///< ECU-reported digital inputs (DigitalInput1-7)
        ExtenderAnalog,   ///< Extender board analog inputs via CAN (EXAnalogInput0-7)
        ExtenderDigital,  ///< Extender board digital inputs via CAN (EXDigitalInput1-8)
        GPS,              ///< GPS hardware (serial NMEA)
        SenseHat,         ///< SenseHat sensors (accelerometer, gyroscope, compass,
                          ///< ambient temperature, ambient pressure)
        Computed          ///< Values derived from other sensors
    };
    Q_ENUM(SensorSource)

    // -- Registration methods (called from C++ backend) --

    /**
     * @brief Register a sensor as available.
     * @param key Unique property key (e.g., "rpm", "boost", "Analog0")
     * @param displayName Human-readable name (e.g., "RPM", "Boost Pressure")
     * @param category Category for grouping (e.g., "Engine", "Analog Inputs")
     * @param unit Unit string (e.g., "rpm", "psi", "V")
     * @param source Where this sensor data comes from
     */
    void registerSensor(const QString &key, const QString &displayName, const QString &category, const QString &unit,
                        SensorSource source, int decimals = 2, double maxValue = 100.0, double stepSize = 1.0);

    /**
     * @brief Unregister a sensor (e.g., when analog input is unconfigured).
     * @param key Unique property key
     */
    void unregisterSensor(const QString &key);

    /**
     * @brief Check if a sensor is registered.
     * @param key Unique property key
     * @return true if sensor is available
     */
    bool isSensorAvailable(const QString &key) const;

    /**
     * @brief Mark a CAN sensor as active (received data recently).
     * @param key Property key from UDPReceiver
     */
    void markCanSensorActive(const QString &key);

    // -- Q_INVOKABLE methods for QML --

    /**
     * @brief Get all available sensors, optionally filtered by category.
     * @param category Category filter (empty string = all)
     * @return List of sensor maps with keys: key, displayName, category, unit, source, active
     */
    Q_INVOKABLE QVariantList getSensorsByCategory(const QString &category = QString(), bool activeOnly = false) const;
    Q_INVOKABLE QVariantList getActiveSensors() const;
    Q_INVOKABLE QStringList sensorDisplayNames(const QString &category = QString(), bool activeOnly = false) const;
    Q_INVOKABLE QStringList sensorKeys(const QString &category = QString(), bool activeOnly = false) const;
    Q_INVOKABLE int indexOfSensorKey(const QString &key, const QString &category = QString()) const;

    /**
     * @brief Check from QML if a sensor key is available.
     * @param key Sensor property key
     * @return true if available
     */
    Q_INVOKABLE bool isAvailable(const QString &key) const;

    /**
     * @brief Get display name for a sensor key.
     * @param key Sensor property key
     * @return Display name or empty string if not found
     */
    Q_INVOKABLE QString getDisplayName(const QString &key) const;

    /**
     * @brief Get unit for a sensor key.
     * @param key Sensor property key
     * @return Unit string or empty string if not found
     */
    Q_INVOKABLE QString getUnit(const QString &key) const;
    Q_INVOKABLE int getDecimals(const QString &key) const;
    Q_INVOKABLE double getMaxValue(const QString &key) const;
    Q_INVOKABLE double getStepSize(const QString &key) const;
    Q_INVOKABLE void updateSensorMetadata(const QString &key, const QString &unit, int decimals, double maxValue,
                                          double stepSize);

    /**
     * @brief Register ECU-reported analog voltage channels via daemon UDP.
     *
     * Registers Analog0 through Analog10 and their corresponding AnalogCalc0
     * through AnalogCalc10 calibrated channels. These are ECU-reported analog
     * voltage channels received via daemon UDP (port 45454), not physical
     * Raspberry Pi analog inputs.
     *
     * Call this when analog input settings change.
     */
    Q_INVOKABLE void refreshEcuAnalogChannels();

    /**
     * @brief Register extender board analog input channels via CAN.
     *
     * Registers EXAnalogInput0 through EXAnalogInput7 and their corresponding
     * EXAnalogCalc0 through EXAnalogCalc7 calibrated channels. These are
     * analog inputs from the extender board received via CAN bus.
     *
     * Call this when extender board settings change.
     */
    Q_INVOKABLE void refreshExtenderAnalogInputs();

    /**
     * @brief Register ECU-reported digital input channels via daemon UDP.
     *
     * Registers DigitalInput1 through DigitalInput7. These are ECU-reported
     * digital input states received via daemon UDP (port 45454), not physical
     * Raspberry Pi GPIO inputs.
     *
     * Call this when digital input settings change.
     */
    Q_INVOKABLE void refreshEcuDigitalInputs();

    /**
     * @brief Register extender board digital input channels via CAN.
     *
     * Registers EXDigitalInput1 through EXDigitalInput8. These are digital
     * inputs from the extender board received via CAN bus.
     *
     * Call this when extender board settings change.
     */
    Q_INVOKABLE void refreshExtenderDigitalInputs();

    // -- Property accessors --

    /**
     * @brief Get the total number of registered sensors.
     * @return Count of sensors in the registry
     */
    int availableCount() const;

    /**
     * @brief Get all registered sensors as a QVariantList of QVariantMaps.
     * @return List where each entry is a map with key, displayName, category, unit, source, active
     */
    QVariantList availableSensors() const;

    /**
     * @brief Get the list of unique category names across all registered sensors.
     * @return Sorted list of category strings
     */
    QStringList availableCategories() const;

signals:
    /**
     * @brief Emitted whenever the sensor list changes (add, remove, or active state change).
     */
    void sensorsChanged();

    /**
     * @brief Emitted when a specific sensor is registered.
     * @param key The property key of the newly registered sensor
     */
    void sensorRegistered(const QString &key);

    /**
     * @brief Emitted when a specific sensor is unregistered.
     * @param key The property key of the removed sensor
     */
    void sensorUnregistered(const QString &key);

private:
    /**
     * @brief Internal representation of a registered sensor.
     */
    struct SensorEntry
    {
        QString key;
        QString displayName;
        QString category;
        QString unit;
        SensorSource source;
        bool active = true;              ///< For DaemonUDP sensors: true if data received recently
        qint64 lastActiveTimestamp = 0;  ///< msecsSinceEpoch of last markCanSensorActive call
        int decimals = 2;
        double maxValue = 100.0;
        double stepSize = 1.0;
    };

    QMap<QString, SensorEntry> m_sensors;
    QTimer m_canTimeoutTimer;  ///< Periodically check for stale DaemonUDP sensors

    /**
     * @brief Register built-in sensors that are always available (GPS, SenseHat).
     */
    void registerBuiltinSensors();

    /**
     * @brief Register common CAN/daemon sensors that most ECUs provide.
     * These are registered with active=false and become active when data arrives.
     */
    void registerCommonCanSensors();

    /**
     * @brief Convert a SensorEntry to a QVariantMap for QML consumption.
     * @param entry The sensor entry to convert
     * @return QVariantMap with keys: key, displayName, category, unit, source, active
     */
    QVariantMap entryToVariantMap(const SensorEntry &entry) const;

    /**
     * @brief Timer callback to mark non-Computed sensors as inactive if no data received in 10 seconds.
     */
    void checkCanTimeouts();
};

#endif  // SENSORREGISTRY_H
