// Copyright (c) 2026 Kai Wyborny. All rights reserved.

/**
 * @file DiagnosticsProvider.cpp
 * @brief Implementation of the DiagnosticsProvider class.
 *
 * Provides system health, CAN bus metrics, sensor status, and log buffering
 * for the Diagnostics settings page.
 */

#include "DiagnosticsProvider.h"
#include "SensorRegistry.h"

#include <QFile>
#include <QTextStream>
#include <QDebug>

#ifdef Q_OS_MACOS
#include <QProcess>
#include <mach/mach.h>
#include <mach/mach_host.h>
#endif

#ifdef Q_OS_LINUX
#include <QProcess>
#endif


/**
 * @brief Construct a DiagnosticsProvider.
 * @param parent Parent QObject
 *
 * Initializes the uptime timer and starts periodic polling for system info (2s)
 * and CAN message rate calculation (1s).
 */
DiagnosticsProvider::DiagnosticsProvider(QObject *parent)
    : QObject(parent)
{
    // Start uptime tracking
    m_uptimeTimer.start();

    // System info polling every 2 seconds
    connect(&m_systemInfoTimer, &QTimer::timeout, this, &DiagnosticsProvider::updateSystemInfo);
    m_systemInfoTimer.start(2000);

    // CAN rate calculation every 1 second
    connect(&m_canRateTimer, &QTimer::timeout, this, &DiagnosticsProvider::updateCanRate);
    m_canRateTimer.start(1000);

    // Initial system info read
    updateSystemInfo();
}


/**
 * @brief Set the SensorRegistry reference for querying sensor status.
 * @param registry Pointer to the SensorRegistry instance
 *
 * When set, enables getLiveSensorData() to query actual sensor metadata
 * and activeSensorCount()/totalSensorCount() to return meaningful values.
 */
void DiagnosticsProvider::setSensorRegistry(SensorRegistry *registry)
{
    m_sensorRegistry = registry;
    if (m_sensorRegistry) {
        connect(m_sensorRegistry, &SensorRegistry::sensorsChanged,
                this, &DiagnosticsProvider::sensorDataChanged);
    }
}


// ---------------------------------------------------------------------------
// System Info accessors
// ---------------------------------------------------------------------------

/**
 * @brief Get the current CPU temperature.
 * @return Temperature in Celsius, or 0.0 if unavailable
 */
double DiagnosticsProvider::cpuTemperature() const
{
    return m_cpuTemp;
}

/**
 * @brief Get the current memory usage percentage.
 * @return Usage as percentage 0-100
 */
double DiagnosticsProvider::memoryUsagePercent() const
{
    return m_memoryUsage;
}

/**
 * @brief Get the application uptime formatted as "Xd Xh Xm Xs".
 * @return Formatted uptime string
 */
QString DiagnosticsProvider::uptime() const
{
    qint64 ms = m_uptimeTimer.elapsed();
    qint64 totalSeconds = ms / 1000;

    int days = static_cast<int>(totalSeconds / 86400);
    int hours = static_cast<int>((totalSeconds % 86400) / 3600);
    int minutes = static_cast<int>((totalSeconds % 3600) / 60);
    int seconds = static_cast<int>(totalSeconds % 60);

    if (days > 0) {
        return QStringLiteral("%1d %2h %3m %4s").arg(days).arg(hours).arg(minutes).arg(seconds);
    }
    if (hours > 0) {
        return QStringLiteral("%1h %2m %3s").arg(hours).arg(minutes).arg(seconds);
    }
    if (minutes > 0) {
        return QStringLiteral("%1m %2s").arg(minutes).arg(seconds);
    }
    return QStringLiteral("%1s").arg(seconds);
}

/**
 * @brief Get the current system time.
 * @return Time formatted as "yyyy-MM-dd hh:mm:ss"
 */
QString DiagnosticsProvider::systemTime() const
{
    return QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-dd hh:mm:ss"));
}


// ---------------------------------------------------------------------------
// CAN Bus accessors
// ---------------------------------------------------------------------------

/**
 * @brief Check if CAN bus is connected.
 * @return true if CAN daemon connection is active
 */
bool DiagnosticsProvider::canConnected() const
{
    return m_canConnected;
}

/**
 * @brief Get the CAN message rate.
 * @return Messages per second
 */
int DiagnosticsProvider::canMessageRate() const
{
    return m_canMessageRate;
}

/**
 * @brief Get the total CAN error count since startup.
 * @return Error count
 */
int DiagnosticsProvider::canErrorCount() const
{
    return m_canErrorCount;
}

/**
 * @brief Get total CAN messages received since startup.
 * @return Total message count
 */
int DiagnosticsProvider::canTotalMessages() const
{
    return m_canTotalMessages;
}

/**
 * @brief Get the name of the active CAN daemon.
 * @return Daemon name string
 */
QString DiagnosticsProvider::daemonName() const
{
    return m_daemonName;
}


// ---------------------------------------------------------------------------
// Connection accessors
// ---------------------------------------------------------------------------

/**
 * @brief Get the connection type string.
 * @return Connection type (e.g., "Serial", "WiFi", "CAN")
 */
QString DiagnosticsProvider::connectionType() const
{
    return m_connectionType;
}

/**
 * @brief Check if serial connection is active.
 * @return true if serial is connected
 */
bool DiagnosticsProvider::serialConnected() const
{
    return m_serialConnected;
}

/**
 * @brief Get the serial port name.
 * @return Port name string
 */
QString DiagnosticsProvider::serialPort() const
{
    return m_serialPort;
}

/**
 * @brief Get the serial baud rate.
 * @return Baud rate integer
 */
int DiagnosticsProvider::serialBaudRate() const
{
    return m_serialBaudRate;
}


// ---------------------------------------------------------------------------
// Sensor accessors
// ---------------------------------------------------------------------------

/**
 * @brief Get the count of sensors currently receiving data.
 * @return Active sensor count from SensorRegistry, or 0 if not set
 */
int DiagnosticsProvider::activeSensorCount() const
{
    if (!m_sensorRegistry) {
        return 0;
    }
    // Count active sensors from registry
    int count = 0;
    const QVariantList sensors = m_sensorRegistry->availableSensors();
    for (const QVariant &v : sensors) {
        QVariantMap map = v.toMap();
        if (map.value(QStringLiteral("active")).toBool()) {
            ++count;
        }
    }
    return count;
}

/**
 * @brief Get the total number of registered sensors.
 * @return Total sensor count from SensorRegistry, or 0 if not set
 */
int DiagnosticsProvider::totalSensorCount() const
{
    if (!m_sensorRegistry) {
        return 0;
    }
    return m_sensorRegistry->availableCount();
}


// ---------------------------------------------------------------------------
// Log accessors
// ---------------------------------------------------------------------------

/**
 * @brief Get the log message buffer.
 * @return List of log strings, newest first
 */
QStringList DiagnosticsProvider::logMessages() const
{
    return m_logMessages;
}


// ---------------------------------------------------------------------------
// Q_INVOKABLE methods for QML
// ---------------------------------------------------------------------------

/**
 * @brief Get live sensor data for all active sensors.
 *
 * Queries the SensorRegistry for all registered sensors and returns their
 * metadata. Raw/calibrated values will be connected via PropertyRouter
 * in a future integration step.
 *
 * @return List of maps: {key, displayName, rawValue, calibratedValue, unit, source, active}
 */
QVariantList DiagnosticsProvider::getLiveSensorData() const
{
    QVariantList result;

    if (!m_sensorRegistry) {
        return result;
    }

    const QVariantList sensors = m_sensorRegistry->availableSensors();
    for (const QVariant &v : sensors) {
        QVariantMap sensorMap = v.toMap();
        QVariantMap entry;
        entry[QStringLiteral("key")] = sensorMap.value(QStringLiteral("key"));
        entry[QStringLiteral("displayName")] = sensorMap.value(QStringLiteral("displayName"));
        entry[QStringLiteral("unit")] = sensorMap.value(QStringLiteral("unit"));
        entry[QStringLiteral("source")] = sensorMap.value(QStringLiteral("source"));
        entry[QStringLiteral("active")] = sensorMap.value(QStringLiteral("active"));
        // TODO: Wire rawValue and calibratedValue via PropertyRouter when integration is complete
        entry[QStringLiteral("rawValue")] = 0.0;
        entry[QStringLiteral("calibratedValue")] = 0.0;
        result.append(entry);
    }

    return result;
}

/**
 * @brief Get analog input diagnostics (raw ADC values).
 *
 * Returns 11 entries (AN1-AN11) with channel metadata.
 * Actual raw voltage values will be wired to AnalogInputs model later.
 *
 * @return List of maps: {channel, rawVoltage, calibratedValue, presetName, unit, configured}
 */
QVariantList DiagnosticsProvider::getAnalogInputDiagnostics() const
{
    QVariantList result;

    for (int i = 1; i <= 11; ++i) {
        QVariantMap entry;
        entry[QStringLiteral("channel")] = i;
        entry[QStringLiteral("label")] = QStringLiteral("AN%1").arg(i);
        // TODO: Wire rawVoltage from AnalogInputs model when integration is complete
        entry[QStringLiteral("rawVoltage")] = 0.0;
        entry[QStringLiteral("calibratedValue")] = 0.0;
        entry[QStringLiteral("presetName")] = QString();
        entry[QStringLiteral("unit")] = QStringLiteral("V");
        entry[QStringLiteral("configured")] = false;
        result.append(entry);
    }

    return result;
}

/**
 * @brief Get digital input states.
 *
 * Returns 4 entries (DI1-DI4) with channel metadata.
 * Actual state values will be wired to DigitalInputs model later.
 *
 * @return List of maps: {channel, state, configured, label}
 */
QVariantList DiagnosticsProvider::getDigitalInputDiagnostics() const
{
    QVariantList result;

    for (int i = 1; i <= 4; ++i) {
        QVariantMap entry;
        entry[QStringLiteral("channel")] = i;
        entry[QStringLiteral("label")] = QStringLiteral("DI%1").arg(i);
        // TODO: Wire state from DigitalInputs model when integration is complete
        entry[QStringLiteral("state")] = false;
        entry[QStringLiteral("configured")] = false;
        result.append(entry);
    }

    return result;
}

/**
 * @brief Get expander board diagnostics.
 *
 * Returns 8 entries (EX_AN1-EX_AN8) with channel metadata.
 * Actual values will be wired to ExpanderBoardData model later.
 *
 * @return List of maps: {channel, rawVoltage, calibratedValue, presetName, unit, configured}
 */
QVariantList DiagnosticsProvider::getExpanderBoardDiagnostics() const
{
    QVariantList result;

    for (int i = 1; i <= 8; ++i) {
        QVariantMap entry;
        entry[QStringLiteral("channel")] = i;
        entry[QStringLiteral("label")] = QStringLiteral("EX_AN%1").arg(i);
        // TODO: Wire rawVoltage from ExpanderBoardData model when integration is complete
        entry[QStringLiteral("rawVoltage")] = 0.0;
        entry[QStringLiteral("calibratedValue")] = 0.0;
        entry[QStringLiteral("presetName")] = QString();
        entry[QStringLiteral("unit")] = QStringLiteral("V");
        entry[QStringLiteral("configured")] = false;
        result.append(entry);
    }

    return result;
}

/**
 * @brief Add a log message to the circular buffer.
 * @param level Log level: "INFO", "WARN", "ERROR"
 * @param message The log message text
 *
 * Prepends a timestamped entry "[HH:mm:ss] [LEVEL] message" to the buffer.
 * If the buffer exceeds MAX_LOG_ENTRIES, the oldest entry is removed.
 */
void DiagnosticsProvider::addLogMessage(const QString &level, const QString &message)
{
    QString timestamp = QDateTime::currentDateTime().toString(QStringLiteral("hh:mm:ss"));
    QString entry = QStringLiteral("[%1] [%2] %3").arg(timestamp, level, message);

    m_logMessages.prepend(entry);

    while (m_logMessages.size() > MAX_LOG_ENTRIES) {
        m_logMessages.removeLast();
    }

    emit logChanged();
}

/**
 * @brief Clear the log buffer.
 *
 * Removes all entries and emits logChanged.
 */
void DiagnosticsProvider::clearLog()
{
    m_logMessages.clear();
    emit logChanged();
}


// ---------------------------------------------------------------------------
// CAN tracking methods (called from UDPReceiver/connect)
// ---------------------------------------------------------------------------

/**
 * @brief Record a received CAN message for rate tracking.
 *
 * Increments both the per-second counter (for rate calculation)
 * and the total message counter.
 */
void DiagnosticsProvider::recordCanMessage()
{
    ++m_canMessagesThisSecond;
    ++m_canTotalMessages;
}

/**
 * @brief Record a CAN error.
 *
 * Increments the error counter and emits canStatusChanged.
 */
void DiagnosticsProvider::recordCanError()
{
    ++m_canErrorCount;
    emit canStatusChanged();
}

/**
 * @brief Set the CAN connection status.
 * @param connected Whether CAN is connected
 * @param daemon Name of the active daemon
 *
 * Updates connection state and daemon name, emits canStatusChanged.
 */
void DiagnosticsProvider::setCanStatus(bool connected, const QString &daemon)
{
    if (m_canConnected != connected || m_daemonName != daemon) {
        m_canConnected = connected;
        m_daemonName = daemon;
        emit canStatusChanged();
    }
}

/**
 * @brief Set serial connection info.
 * @param connected Whether serial is connected
 * @param port Serial port name
 * @param baudRate Baud rate
 * @param type Connection type string
 *
 * Updates all connection fields and emits connectionChanged.
 */
void DiagnosticsProvider::setConnectionInfo(bool connected, const QString &port,
                                            int baudRate, const QString &type)
{
    m_serialConnected = connected;
    m_serialPort = port;
    m_serialBaudRate = baudRate;
    m_connectionType = type;
    emit connectionChanged();
}


// ---------------------------------------------------------------------------
// Private slots
// ---------------------------------------------------------------------------

/**
 * @brief Periodic callback to refresh CPU temp and memory usage.
 *
 * Reads system metrics and emits systemInfoChanged if values changed.
 */
void DiagnosticsProvider::updateSystemInfo()
{
    double newTemp = readCpuTemperature();
    double newMem = readMemoryUsage();

    bool changed = false;
    if (qAbs(newTemp - m_cpuTemp) > 0.01) {
        m_cpuTemp = newTemp;
        changed = true;
    }
    if (qAbs(newMem - m_memoryUsage) > 0.01) {
        m_memoryUsage = newMem;
        changed = true;
    }

    // Always emit for uptime/systemTime updates
    emit systemInfoChanged();
}

/**
 * @brief Periodic callback to compute CAN message rate.
 *
 * Sets m_canMessageRate to the number of messages received in the last second,
 * resets the per-second counter, and emits canStatusChanged.
 */
void DiagnosticsProvider::updateCanRate()
{
    m_canMessageRate = m_canMessagesThisSecond;
    m_canMessagesThisSecond = 0;
    emit canStatusChanged();
}


// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

/**
 * @brief Read CPU temperature from system.
 *
 * On Linux (Raspberry Pi): reads /sys/class/thermal/thermal_zone0/temp
 * and divides by 1000 to get Celsius.
 * On macOS: attempts sysctl but typically returns 0.0 as macOS does not
 * expose CPU temperature through standard APIs.
 *
 * @return Temperature in Celsius, or 0.0 if unavailable
 */
double DiagnosticsProvider::readCpuTemperature() const
{
#ifdef Q_OS_LINUX
    QFile tempFile(QStringLiteral("/sys/class/thermal/thermal_zone0/temp"));
    if (tempFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&tempFile);
        QString line = in.readLine().trimmed();
        tempFile.close();

        bool ok = false;
        double milliCelsius = line.toDouble(&ok);
        if (ok) {
            return milliCelsius / 1000.0;
        }
    }
    return 0.0;
#elif defined(Q_OS_MACOS)
    // macOS does not expose CPU temperature via standard APIs.
    // sysctl machdep.xcpm.cpu_thermal_level returns a level, not temperature.
    // Return 0.0 as a placeholder.
    QProcess proc;
    proc.start(QStringLiteral("sysctl"), QStringList() << QStringLiteral("-n") << QStringLiteral("machdep.xcpm.cpu_thermal_level"));
    proc.waitForFinished(500);
    if (proc.exitCode() == 0) {
        QString output = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
        bool ok = false;
        double level = output.toDouble(&ok);
        if (ok) {
            // This is a thermal level (0-100), not actual temperature
            // Return as-is for diagnostic display
            return level;
        }
    }
    return 0.0;
#else
    return 0.0;
#endif
}

/**
 * @brief Read memory usage percentage from system.
 *
 * On Linux: parses /proc/meminfo for MemTotal and MemAvailable.
 * On macOS: uses Mach host_statistics64 API for accurate memory info.
 *
 * @return Usage as percentage 0-100, or 0.0 if unavailable
 */
double DiagnosticsProvider::readMemoryUsage() const
{
#ifdef Q_OS_LINUX
    QFile memFile(QStringLiteral("/proc/meminfo"));
    if (!memFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return 0.0;
    }

    QTextStream in(&memFile);
    double memTotal = 0.0;
    double memAvailable = 0.0;
    bool foundTotal = false;
    bool foundAvailable = false;

    while (!in.atEnd()) {
        QString line = in.readLine();
        if (line.startsWith(QStringLiteral("MemTotal:"))) {
            QStringList parts = line.split(QRegularExpression(QStringLiteral("\\s+")));
            if (parts.size() >= 2) {
                memTotal = parts.at(1).toDouble();
                foundTotal = true;
            }
        } else if (line.startsWith(QStringLiteral("MemAvailable:"))) {
            QStringList parts = line.split(QRegularExpression(QStringLiteral("\\s+")));
            if (parts.size() >= 2) {
                memAvailable = parts.at(1).toDouble();
                foundAvailable = true;
            }
        }
        if (foundTotal && foundAvailable) {
            break;
        }
    }
    memFile.close();

    if (foundTotal && foundAvailable && memTotal > 0.0) {
        return ((memTotal - memAvailable) / memTotal) * 100.0;
    }
    return 0.0;

#elif defined(Q_OS_MACOS)
    // Use Mach host_statistics64 for accurate memory info
    mach_port_t host = mach_host_self();
    vm_statistics64_data_t vmStats;
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;

    kern_return_t result = host_statistics64(host, HOST_VM_INFO64,
                                             reinterpret_cast<host_info64_t>(&vmStats),
                                             &count);
    if (result != KERN_SUCCESS) {
        return 0.0;
    }

    // Get page size
    vm_size_t pageSize = 0;
    host_page_size(host, &pageSize);

    // Calculate used and total
    uint64_t active = static_cast<uint64_t>(vmStats.active_count) * pageSize;
    uint64_t inactive = static_cast<uint64_t>(vmStats.inactive_count) * pageSize;
    uint64_t wired = static_cast<uint64_t>(vmStats.wire_count) * pageSize;
    uint64_t free_mem = static_cast<uint64_t>(vmStats.free_count) * pageSize;
    uint64_t compressed = static_cast<uint64_t>(vmStats.compressor_page_count) * pageSize;

    uint64_t used = active + wired + compressed;
    uint64_t total = active + inactive + wired + free_mem + compressed;

    if (total == 0) {
        return 0.0;
    }

    return (static_cast<double>(used) / static_cast<double>(total)) * 100.0;
#else
    return 0.0;
#endif
}
