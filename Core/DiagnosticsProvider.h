// Copyright (c) 2026 Kai Wyborny. All rights reserved.

/**
 * @file DiagnosticsProvider.h
 * @brief Provides diagnostic and system health data for the Diagnostics settings page.
 *
 * Aggregates:
 * - Live sensor values (raw + calibrated) for active sensors
 * - CAN bus health metrics (message rate, error count, connection status)
 * - Analog input raw ADC values
 * - Digital input states
 * - System info (CPU temp, memory usage, uptime)
 * - Log buffer (last N messages)
 */

#ifndef DIAGNOSTICSPROVIDER_H
#define DIAGNOSTICSPROVIDER_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>
#include <QStringList>
#include <QTimer>
#include <QElapsedTimer>
#include <QDateTime>

class SensorRegistry;

class DiagnosticsProvider : public QObject
{
    Q_OBJECT

    // -- System Info --

    /// CPU temperature in Celsius (Linux: thermal_zone, macOS: best-effort)
    Q_PROPERTY(double cpuTemperature READ cpuTemperature NOTIFY systemInfoChanged)

    /// Memory usage as percentage 0-100
    Q_PROPERTY(double memoryUsagePercent READ memoryUsagePercent NOTIFY systemInfoChanged)

    /// Application uptime formatted as "Xd Xh Xm Xs"
    Q_PROPERTY(QString uptime READ uptime NOTIFY systemInfoChanged)

    /// Current system time formatted as "yyyy-MM-dd hh:mm:ss"
    Q_PROPERTY(QString systemTime READ systemTime NOTIFY systemInfoChanged)

    // -- CAN Bus --

    /// Whether the CAN bus daemon connection is active
    Q_PROPERTY(bool canConnected READ canConnected NOTIFY canStatusChanged)

    /// CAN messages received per second
    Q_PROPERTY(int canMessageRate READ canMessageRate NOTIFY canStatusChanged)

    /// Total CAN errors since startup
    Q_PROPERTY(int canErrorCount READ canErrorCount NOTIFY canStatusChanged)

    /// Total CAN messages received since startup
    Q_PROPERTY(int canTotalMessages READ canTotalMessages NOTIFY canStatusChanged)

    /// Name of the active CAN daemon
    Q_PROPERTY(QString daemonName READ daemonName NOTIFY canStatusChanged)

    // -- Connection --

    /// Connection type string (e.g., "Serial", "WiFi", "CAN")
    Q_PROPERTY(QString connectionType READ connectionType NOTIFY connectionChanged)

    /// Whether serial connection is active
    Q_PROPERTY(bool serialConnected READ serialConnected NOTIFY connectionChanged)

    /// Serial port name (e.g., "/dev/ttyUSB0")
    Q_PROPERTY(QString serialPort READ serialPort NOTIFY connectionChanged)

    /// Serial baud rate
    Q_PROPERTY(int serialBaudRate READ serialBaudRate NOTIFY connectionChanged)

    // -- Sensor Summary --

    /// Number of sensors currently receiving data
    Q_PROPERTY(int activeSensorCount READ activeSensorCount NOTIFY sensorDataChanged)

    /// Total number of registered sensors
    Q_PROPERTY(int totalSensorCount READ totalSensorCount NOTIFY sensorDataChanged)

    // -- Log --

    /// Circular log buffer (newest first, max 200 entries)
    Q_PROPERTY(QStringList logMessages READ logMessages NOTIFY logChanged)

public:
    /**
     * @brief Construct a DiagnosticsProvider.
     * @param parent Parent QObject (typically the Connect instance)
     *
     * Starts uptime timer, system info polling (2s), and CAN rate tracking (1s).
     */
    explicit DiagnosticsProvider(QObject *parent = nullptr);

    /**
     * @brief Set the SensorRegistry reference for querying sensor status.
     * @param registry Pointer to the SensorRegistry instance
     */
    void setSensorRegistry(SensorRegistry *registry);

    // -- System Info accessors --

    /**
     * @brief Get the current CPU temperature.
     * @return Temperature in Celsius, or 0.0 if unavailable
     */
    double cpuTemperature() const;

    /**
     * @brief Get the current memory usage percentage.
     * @return Usage as percentage 0-100, or 0.0 if unavailable
     */
    double memoryUsagePercent() const;

    /**
     * @brief Get the application uptime formatted as "Xd Xh Xm Xs".
     * @return Formatted uptime string
     */
    QString uptime() const;

    /**
     * @brief Get the current system time.
     * @return Time formatted as "yyyy-MM-dd hh:mm:ss"
     */
    QString systemTime() const;

    // -- CAN Bus accessors --

    /**
     * @brief Check if CAN bus is connected.
     * @return true if CAN daemon connection is active
     */
    bool canConnected() const;

    /**
     * @brief Get the CAN message rate.
     * @return Messages per second
     */
    int canMessageRate() const;

    /**
     * @brief Get the total CAN error count since startup.
     * @return Error count
     */
    int canErrorCount() const;

    /**
     * @brief Get total CAN messages received since startup.
     * @return Total message count
     */
    int canTotalMessages() const;

    /**
     * @brief Get the name of the active CAN daemon.
     * @return Daemon name string
     */
    QString daemonName() const;

    // -- Connection accessors --

    /**
     * @brief Get the connection type string.
     * @return Connection type (e.g., "Serial", "WiFi", "CAN")
     */
    QString connectionType() const;

    /**
     * @brief Check if serial connection is active.
     * @return true if serial is connected
     */
    bool serialConnected() const;

    /**
     * @brief Get the serial port name.
     * @return Port name string (e.g., "/dev/ttyUSB0")
     */
    QString serialPort() const;

    /**
     * @brief Get the serial baud rate.
     * @return Baud rate integer
     */
    int serialBaudRate() const;

    // -- Sensor accessors --

    /**
     * @brief Get the count of sensors currently receiving data.
     * @return Active sensor count
     */
    int activeSensorCount() const;

    /**
     * @brief Get the total number of registered sensors.
     * @return Total sensor count
     */
    int totalSensorCount() const;

    // -- Log accessors --

    /**
     * @brief Get the log message buffer.
     * @return List of log strings, newest first
     */
    QStringList logMessages() const;

    // -- Q_INVOKABLE for QML --

    /**
     * @brief Get live sensor data for all active sensors.
     * @return List of maps: {key, displayName, rawValue, calibratedValue, unit, source, active}
     */
    Q_INVOKABLE QVariantList getLiveSensorData() const;

    /**
     * @brief Get analog input diagnostics (raw ADC values).
     * @return List of maps: {channel, rawVoltage, calibratedValue, presetName, unit, configured}
     */
    Q_INVOKABLE QVariantList getAnalogInputDiagnostics() const;

    /**
     * @brief Get digital input states.
     * @return List of maps: {channel, state, configured, label}
     */
    Q_INVOKABLE QVariantList getDigitalInputDiagnostics() const;

    /**
     * @brief Get expander board diagnostics.
     * @return List of maps: {channel, rawVoltage, calibratedValue, presetName, unit, configured}
     */
    Q_INVOKABLE QVariantList getExpanderBoardDiagnostics() const;

    /**
     * @brief Add a log message to the buffer.
     * @param level Log level: "INFO", "WARN", "ERROR"
     * @param message The log message text
     */
    Q_INVOKABLE void addLogMessage(const QString &level, const QString &message);

    /**
     * @brief Clear the log buffer.
     */
    Q_INVOKABLE void clearLog();

    // -- CAN tracking (called from UDPReceiver/connect) --

    /**
     * @brief Record a received CAN message for rate tracking.
     *
     * Increments both the per-second counter and the total counter.
     */
    void recordCanMessage();

    /**
     * @brief Record a CAN error.
     *
     * Increments the error counter and emits canStatusChanged.
     */
    void recordCanError();

    /**
     * @brief Set the CAN connection status.
     * @param connected Whether CAN is connected
     * @param daemon Name of the active daemon
     */
    void setCanStatus(bool connected, const QString &daemon);

    /**
     * @brief Set serial connection info.
     * @param connected Whether serial is connected
     * @param port Serial port name
     * @param baudRate Baud rate
     * @param type Connection type string
     */
    void setConnectionInfo(bool connected, const QString &port, int baudRate, const QString &type);

signals:
    /// Emitted when system info (CPU temp, memory, uptime) is updated
    void systemInfoChanged();

    /// Emitted when CAN bus status changes (connection, rate, errors)
    void canStatusChanged();

    /// Emitted when serial/connection info changes
    void connectionChanged();

    /// Emitted when sensor summary counts change
    void sensorDataChanged();

    /// Emitted when log buffer is modified
    void logChanged();

private slots:
    /**
     * @brief Periodic callback to refresh CPU temp and memory usage.
     *
     * Connected to m_systemInfoTimer (2-second interval).
     */
    void updateSystemInfo();

    /**
     * @brief Periodic callback to compute CAN message rate.
     *
     * Connected to m_canRateTimer (1-second interval).
     * Sets m_canMessageRate = m_canMessagesThisSecond, then resets counter.
     */
    void updateCanRate();

private:
    // System info
    double m_cpuTemp = 0.0;
    double m_memoryUsage = 0.0;
    QElapsedTimer m_uptimeTimer;

    // CAN bus
    bool m_canConnected = false;
    int m_canMessageRate = 0;
    int m_canErrorCount = 0;
    int m_canTotalMessages = 0;
    int m_canMessagesThisSecond = 0;
    QString m_daemonName;

    // Connection
    QString m_connectionType;
    bool m_serialConnected = false;
    QString m_serialPort;
    int m_serialBaudRate = 0;

    // Sensor registry reference
    SensorRegistry *m_sensorRegistry = nullptr;

    // Log buffer (circular, max 200 entries)
    QStringList m_logMessages;
    static constexpr int MAX_LOG_ENTRIES = 200;

    // Timers
    QTimer m_systemInfoTimer;  // 2-second interval for system info
    QTimer m_canRateTimer;     // 1-second interval for CAN message rate

    /**
     * @brief Read CPU temperature from system.
     *
     * On Linux: reads /sys/class/thermal/thermal_zone0/temp (divided by 1000).
     * On macOS: returns 0.0 (no standard thermal API).
     *
     * @return Temperature in Celsius, or 0.0 if unavailable
     */
    double readCpuTemperature() const;

    /**
     * @brief Read memory usage percentage from system.
     *
     * On Linux: parses /proc/meminfo for MemTotal/MemAvailable.
     * On macOS: runs vm_stat and parses output.
     *
     * @return Usage as percentage 0-100, or 0.0 if unavailable
     */
    double readMemoryUsage() const;
};

#endif // DIAGNOSTICSPROVIDER_H
