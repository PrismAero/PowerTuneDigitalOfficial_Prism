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

#include <QDateTime>
#include <QElapsedTimer>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>

class SensorRegistry;
class PropertyRouter;

class DiagnosticsProvider : public QObject
{
    Q_OBJECT

    // -- System Info --

    /// CPU temperature in Celsius (Linux: thermal_zone; other platforms: unavailable)
    Q_PROPERTY(double cpuTemperature READ cpuTemperature NOTIFY systemInfoChanged)

    /// Whether cpuTemperature holds a valid Celsius reading from a real thermal source
    Q_PROPERTY(bool cpuTemperatureAvailable READ cpuTemperatureAvailable NOTIFY systemInfoChanged)

    /// Memory usage as percentage 0-100
    Q_PROPERTY(double memoryUsagePercent READ memoryUsagePercent NOTIFY systemInfoChanged)

    /// Application uptime formatted as "Xd Xh Xm Xs"
    Q_PROPERTY(QString uptime READ uptime NOTIFY systemInfoChanged)

    /// Current system time formatted as "yyyy-MM-dd hh:mm:ss"
    Q_PROPERTY(QString systemTime READ systemTime NOTIFY systemInfoChanged)

    /// CPU load average (1 minute)
    Q_PROPERTY(double cpuLoadAverage READ cpuLoadAverage NOTIFY systemInfoChanged)

    /// Disk usage percentage for root filesystem
    Q_PROPERTY(double diskUsagePercent READ diskUsagePercent NOTIFY systemInfoChanged)

    /// Memory used in MB
    Q_PROPERTY(double memoryUsedMB READ memoryUsedMB NOTIFY systemInfoChanged)

    /// Memory total in MB
    Q_PROPERTY(double memoryTotalMB READ memoryTotalMB NOTIFY systemInfoChanged)

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

    /// Human-readable CAN status: "Active", "Waiting", or "Disconnected"
    Q_PROPERTY(QString canStatusText READ canStatusText NOTIFY canStatusChanged)

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

    // -- Live Sensor Table (replaces QML JS refreshLiveData) --

    /// Pre-built list of {name, source, value, unit} maps for the diagnostics live table
    Q_PROPERTY(QVariantList liveSensorEntries READ liveSensorEntries NOTIFY liveSensorEntriesChanged)

    /// Filter toggle: true shows all sensors, false shows only those with non-zero values
    Q_PROPERTY(bool showAllSensors READ showAllSensors WRITE setShowAllSensors NOTIFY showAllSensorsChanged)

    // -- Display Time (12h format for bottom status bar clock) --

    /// Current time formatted as "h:mm AM/PM"
    Q_PROPERTY(QString displayTime READ displayTime NOTIFY systemInfoChanged)

    // -- Log --

    /// Circular log buffer (newest first, max 500 entries)
    Q_PROPERTY(QStringList logMessages READ logMessages NOTIFY logChanged)

    /// Filtered log based on current minimum level
    Q_PROPERTY(QStringList filteredLogMessages READ filteredLogMessages NOTIFY logChanged)

    /// Current minimum log level: 0=DEBUG, 1=INFO, 2=WARN, 3=ERROR
    Q_PROPERTY(int logLevel READ logLevel WRITE setLogLevel NOTIFY logLevelChanged)

    // -- CAN Frame Capture --

    Q_PROPERTY(QVariantList canFrameBuffer READ canFrameBuffer NOTIFY canFrameBufferChanged)
    Q_PROPERTY(bool canCaptureEnabled READ canCaptureEnabled WRITE setCanCaptureEnabled NOTIFY canCaptureEnabledChanged)
    Q_PROPERTY(QString canIdFilter READ canIdFilter WRITE setCanIdFilter NOTIFY canIdFilterChanged)

public:
    /**
     * @brief Construct a DiagnosticsProvider.
     * @param parent Parent QObject (typically the Connect instance)
     *
     * Starts uptime timer, system info polling (2s), and CAN rate tracking (1s).
     * Installs a Qt message handler to capture qDebug/qWarning/qCritical/qFatal.
     */
    explicit DiagnosticsProvider(QObject *parent = nullptr);

    static DiagnosticsProvider *instance();

    /**
     * @brief Set the SensorRegistry reference for querying sensor status.
     * @param registry Pointer to the SensorRegistry instance
     */
    void setSensorRegistry(SensorRegistry *registry);

    /**
     * @brief Set the PropertyRouter reference for reading live sensor values.
     * @param router Pointer to the PropertyRouter instance
     */
    void setPropertyRouter(class PropertyRouter *router);

    // -- System Info accessors --

    /**
     * @brief Get the current CPU temperature.
     * @return Temperature in Celsius; only meaningful when cpuTemperatureAvailable() is true
     */
    double cpuTemperature() const;

    /**
     * @brief Whether the CPU temperature reading is valid.
     * @return true if the platform provides a real thermal sensor reading
     */
    bool cpuTemperatureAvailable() const;

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

    double cpuLoadAverage() const;
    double diskUsagePercent() const;
    double memoryUsedMB() const;
    double memoryTotalMB() const;

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

    /**
     * @brief Get human-readable CAN status based on actual message flow.
     * @return "Active" if messages received in last 5s, "Waiting" if connected
     *         but no recent messages, "Disconnected" if not connected
     */
    QString canStatusText() const;

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

    // -- Live Sensor Table accessors --

    QVariantList liveSensorEntries() const;
    bool showAllSensors() const;
    void setShowAllSensors(bool showAll);

    // -- Display Time accessor --

    QString displayTime() const;

    // -- Log accessors --

    /**
     * @brief Get the log message buffer.
     * @return List of log strings, newest first
     */
    QStringList logMessages() const;

    /**
     * @brief Get log messages filtered by the current minimum log level.
     * @return Filtered list of log strings, newest first
     */
    QStringList filteredLogMessages() const;

    int logLevel() const;
    void setLogLevel(int level);

    // -- Q_INVOKABLE for QML --

    /**
     * @brief Get live sensor data for all active sensors.
     * @return List of maps: {key, displayName, rawValue, calibratedValue, unit, source, active}
     */
    Q_INVOKABLE QVariantList getLiveSensorData() const;

    /**
     * @brief Returns diagnostic information for ECU-reported analog input channels.
     *
     * Provides raw ADC voltage and calibration data for Analog0 through Analog10
     * (0-indexed, 11 channels total) received via daemon UDP.
     *
     * @return QVariantList containing diagnostic entries for each analog input channel.
     */
    Q_INVOKABLE QVariantList getAnalogInputDiagnostics() const;

    /**
     * @brief Returns diagnostic information for daemon-reported digital inputs.
     *
     * Provides state and configuration data for DigitalInput1 through
     * DigitalInput7 (7 channels total) received via daemon UDP.
     *
     * @return QVariantList containing diagnostic entries for each digital input channel.
     */
    Q_INVOKABLE QVariantList getDigitalInputDiagnostics() const;

    /**
     * @brief Returns diagnostic information for extender board analog inputs.
     *
     * Provides raw ADC voltage and calibration data for EXAnalogInput0 through
     * EXAnalogInput7 (0-indexed, 8 channels total) from the extender board CAN interface.
     *
     * @return QVariantList containing diagnostic entries for each extender analog input channel.
     */
    Q_INVOKABLE QVariantList getExpanderBoardDiagnostics() const;

    /**
     * @brief Returns diagnostic information for extender board digital inputs.
     *
     * Provides state and configuration data for EXDigitalInput1 through
     * EXDigitalInput8 from the extender board CAN interface.
     *
     * @return QVariantList containing diagnostic entries for each extender digital input channel.
     */
    Q_INVOKABLE QVariantList getExtenderDigitalDiagnostics() const;

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

    // -- CAN Frame Capture --

    QVariantList canFrameBuffer() const;
    bool canCaptureEnabled() const;
    void setCanCaptureEnabled(bool enabled);
    QString canIdFilter() const;
    void setCanIdFilter(const QString &filter);

    Q_INVOKABLE void resetCanErrors();
    Q_INVOKABLE void clearCanFrameBuffer();

    void recordCanFrame(quint32 id, const QByteArray &payload);

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

    /// Emitted when the pre-built live sensor entries list is updated
    void liveSensorEntriesChanged();

    /// Emitted when showAllSensors filter changes
    void showAllSensorsChanged();

    /// Emitted when CAN frame buffer changes
    void canFrameBufferChanged();

    /// Emitted when CAN capture state changes
    void canCaptureEnabledChanged();

    /// Emitted when CAN ID filter changes
    void canIdFilterChanged();

    /// Emitted when log buffer is modified
    void logChanged();

    /// Emitted when log level filter changes
    void logLevelChanged();

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

    /**
     * @brief Periodic callback to rebuild the live sensor entries list.
     *
     * Connected to m_liveSensorTimer (1-second interval).
     * Reads all known sensors via PropertyRouter and rebuilds m_liveSensorEntries.
     */
    void refreshLiveSensorEntries();

private:
    // System info
    double m_cpuTemp = 0.0;
    bool m_cpuTempAvailable = false;
    double m_memoryUsage = 0.0;
    double m_cpuLoadAvg = 0.0;
    double m_diskUsage = 0.0;
    double m_memUsedMB = 0.0;
    double m_memTotalMB = 0.0;
    QElapsedTimer m_uptimeTimer;

    // CAN bus
    bool m_canConnected = false;
    int m_canMessageRate = 0;
    int m_canErrorCount = 0;
    int m_canTotalMessages = 0;
    int m_canMessagesThisSecond = 0;
    QString m_daemonName;
    QElapsedTimer m_lastCanMsgTime;
    bool m_lastCanMsgTimeValid = false;

    // Connection
    QString m_connectionType;
    bool m_serialConnected = false;
    QString m_serialPort;
    int m_serialBaudRate = 0;

    // Sensor registry and property router references
    SensorRegistry *m_sensorRegistry = nullptr;
    PropertyRouter *m_propertyRouter = nullptr;

    struct LogEntry
    {
        int level;     // 0=DEBUG, 1=INFO, 2=WARN, 3=ERROR
        QString text;  // Formatted "[HH:mm:ss] [LEVEL] message"
    };

    QList<LogEntry> m_logEntries;
    QStringList m_logMessages;  // cached formatted strings for QML
    int m_logLevel = 0;         // minimum level to display (0=all)
    static constexpr int MAX_LOG_ENTRIES = 500;

    void rebuildLogCache();

    // Live sensor table
    QVariantList m_liveSensorEntries;
    bool m_showAllSensors = true;

    // CAN frame capture
    struct CapturedCanFrame
    {
        quint32 frameId;
        QByteArray payload;
        qint64 timestamp;
    };
    QVector<CapturedCanFrame> m_canFrameRing;
    int m_canFrameWritePos = 0;
    bool m_canCaptureEnabled = false;
    QString m_canIdFilter;
    static constexpr int MAX_CAN_FRAMES = 500;

    // Timers
    QTimer m_systemInfoTimer;  // 2-second interval for system info
    QTimer m_canRateTimer;     // 1-second interval for CAN message rate
    QTimer m_liveSensorTimer;  // 1-second interval for live sensor table

    /**
     * @brief Read CPU temperature from system.
     *
     * On Linux: reads /sys/class/thermal/thermal_zone0/temp (divided by 1000).
     * On unsupported platforms: sets available=false and returns 0.0.
     *
     * @param[out] available Set to true only when a real Celsius reading was obtained
     * @return Temperature in Celsius, or 0.0 if unavailable
     */
    double readCpuTemperature(bool &available) const;

    /**
     * @brief Read memory usage percentage from system.
     *
     * On Linux: parses /proc/meminfo for MemTotal/MemAvailable.
     * On macOS: runs vm_stat and parses output.
     *
     * @return Usage as percentage 0-100, or 0.0 if unavailable
     */
    double readMemoryUsage() const;
    double readCpuLoadAverage() const;
    double readDiskUsage() const;
    void readMemoryAbsolute(double &usedMB, double &totalMB) const;

    static DiagnosticsProvider *s_instance;
    static QtMessageHandler s_previousHandler;
    static void qtMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg);
};

#endif  // DIAGNOSTICSPROVIDER_H
