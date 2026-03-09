// Copyright (c) 2026 Kai Wyborny. All rights reserved.

/**
 * @file DiagnosticsProvider.cpp
 * @brief Implementation of the DiagnosticsProvider class.
 *
 * Provides system health, CAN bus metrics, sensor status, and log buffering
 * for the Diagnostics settings page.
 */

#include "DiagnosticsProvider.h"
#include "PropertyRouter.h"
#include "SensorRegistry.h"

#include <QFile>
#include <QRegularExpression>
#include <QTextStream>
#include <QTime>
#include <QDebug>

#ifdef Q_OS_MACOS
#include <QProcess>
#include <mach/mach.h>
#include <mach/mach_host.h>
#endif

#ifdef Q_OS_LINUX
#include <QProcess>
#include <sys/statvfs.h>
#endif

DiagnosticsProvider *DiagnosticsProvider::s_instance = nullptr;
QtMessageHandler DiagnosticsProvider::s_previousHandler = nullptr;

void DiagnosticsProvider::qtMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    Q_UNUSED(context)

    QString level;
    switch (type) {
    case QtDebugMsg:    level = QStringLiteral("DEBUG"); break;
    case QtInfoMsg:     level = QStringLiteral("INFO");  break;
    case QtWarningMsg:  level = QStringLiteral("WARN");  break;
    case QtCriticalMsg: level = QStringLiteral("ERROR"); break;
    case QtFatalMsg:    level = QStringLiteral("FATAL"); break;
    }

    if (s_instance) {
        QMetaObject::invokeMethod(s_instance, [=]() {
            s_instance->addLogMessage(level, msg);
        }, Qt::QueuedConnection);
    }

    if (s_previousHandler)
        s_previousHandler(type, context, msg);
    else
        fprintf(stderr, "[%s] %s\n", level.toUtf8().constData(), msg.toUtf8().constData());
}

DiagnosticsProvider::DiagnosticsProvider(QObject *parent)
    : QObject(parent)
{
    s_instance = this;
    s_previousHandler = qInstallMessageHandler(qtMessageHandler);

    m_uptimeTimer.start();

    connect(&m_systemInfoTimer, &QTimer::timeout, this, &DiagnosticsProvider::updateSystemInfo);
    m_systemInfoTimer.start(2000);

    connect(&m_canRateTimer, &QTimer::timeout, this, &DiagnosticsProvider::updateCanRate);
    m_canRateTimer.start(1000);

    connect(&m_liveSensorTimer, &QTimer::timeout, this, &DiagnosticsProvider::refreshLiveSensorEntries);
    m_liveSensorTimer.start(1000);

    updateSystemInfo();

    addLogMessage(QStringLiteral("INFO"), QStringLiteral("Diagnostics provider initialized"));
}

DiagnosticsProvider *DiagnosticsProvider::instance()
{
    return s_instance;
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

void DiagnosticsProvider::setPropertyRouter(PropertyRouter *router)
{
    m_propertyRouter = router;
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

double DiagnosticsProvider::cpuLoadAverage() const
{
    return m_cpuLoadAvg;
}

double DiagnosticsProvider::diskUsagePercent() const
{
    return m_diskUsage;
}

double DiagnosticsProvider::memoryUsedMB() const
{
    return m_memUsedMB;
}

double DiagnosticsProvider::memoryTotalMB() const
{
    return m_memTotalMB;
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

QString DiagnosticsProvider::canStatusText() const
{
    if (!m_canConnected)
        return QStringLiteral("Disconnected");
    if (m_lastCanMsgTimeValid && m_lastCanMsgTime.elapsed() <= 5000)
        return QStringLiteral("Active");
    return QStringLiteral("Waiting");
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
// Live Sensor Table
// ---------------------------------------------------------------------------

QVariantList DiagnosticsProvider::liveSensorEntries() const
{
    return m_liveSensorEntries;
}

bool DiagnosticsProvider::showAllSensors() const
{
    return m_showAllSensors;
}

void DiagnosticsProvider::setShowAllSensors(bool showAll)
{
    if (m_showAllSensors != showAll) {
        m_showAllSensors = showAll;
        emit showAllSensorsChanged();
        refreshLiveSensorEntries();
    }
}

QString DiagnosticsProvider::displayTime() const
{
    QTime now = QTime::currentTime();
    int h = now.hour();
    int m = now.minute();
    QString ampm = h >= 12 ? QStringLiteral("Pm") : QStringLiteral("Am");
    h = h % 12;
    if (h == 0) h = 12;
    return QStringLiteral("%1:%2 %3").arg(h).arg(m, 2, 10, QLatin1Char('0')).arg(ampm);
}

void DiagnosticsProvider::refreshLiveSensorEntries()
{
    struct SensorDef {
        const char *name;
        const char *source;
        const char *key;
        const char *unit;
    };

    static const SensorDef sensors[] = {
        {"RPM",           "Engine",   "rpm",             "rpm"},
        {"Speed",         "Vehicle",  "speed",           "km/h"},
        {"Water Temp",    "Engine",   "Watertemp",       "C"},
        {"Intake Temp",   "Engine",   "Intaketemp",      "C"},
        {"Boost",         "Engine",   "BoostPres",       "kPa"},
        {"MAP",           "Engine",   "MAP",             "kPa"},
        {"TPS",           "Engine",   "TPS",             "%"},
        {"Inj Duty",      "Engine",   "InjDuty",         "%"},
        {"Ignition",      "Engine",   "Ign",             "deg"},
        {"AFR",           "Engine",   "AFR",             ""},
        {"Knock",         "Engine",   "Knock",           ""},
        {"Battery",       "Engine",   "BatteryV",        "V"},
        {"Oil Pressure",  "Engine",   "oilpres",         "kPa"},
        {"Oil Temp",      "Engine",   "oiltemp",         "C"},
        {"Fuel Pressure", "Engine",   "FuelPress",       "kPa"},
        {"Gear",          "Vehicle",  "Gear",            ""},
        {"Odometer",      "Vehicle",  "Odo",             "km"},
        {"EX AN 0",       "Expander", "EXAnalogInput0",  "V"},
        {"EX AN 1",       "Expander", "EXAnalogInput1",  "V"},
        {"EX AN 2",       "Expander", "EXAnalogInput2",  "V"},
        {"EX AN 3",       "Expander", "EXAnalogInput3",  "V"},
        {"EX AN 4",       "Expander", "EXAnalogInput4",  "V"},
        {"EX AN 5",       "Expander", "EXAnalogInput5",  "V"},
        {"EX AN 6",       "Expander", "EXAnalogInput6",  "V"},
        {"EX AN 7",       "Expander", "EXAnalogInput7",  "V"},
        {"Analog 0",      "ECU",      "Analog0",         "V"},
        {"Analog 1",      "ECU",      "Analog1",         "V"},
        {"Analog 2",      "ECU",      "Analog2",         "V"},
        {"Analog 3",      "ECU",      "Analog3",         "V"},
        {"Analog 4",      "ECU",      "Analog4",         "V"},
        {"EX Digi 1",     "Expander", "EXDigitalInput1", ""},
        {"EX Digi 2",     "Expander", "EXDigitalInput2", ""},
        {"EX Digi 3",     "Expander", "EXDigitalInput3", ""},
        {"EX Digi 4",     "Expander", "EXDigitalInput4", ""},
        {"EX Digi 5",     "Expander", "EXDigitalInput5", ""},
        {"EX Digi 6",     "Expander", "EXDigitalInput6", ""},
        {"EX Digi 7",     "Expander", "EXDigitalInput7", ""},
        {"EX Digi 8",     "Expander", "EXDigitalInput8", ""},
    };

    QVariantList entries;
    for (const auto &s : sensors) {
        double value = 0.0;
        if (m_propertyRouter && m_propertyRouter->hasProperty(QLatin1String(s.key)))
            value = m_propertyRouter->getValue(QLatin1String(s.key)).toDouble();

        if (!m_showAllSensors && qAbs(value) < 0.001)
            continue;

        QVariantMap entry;
        entry[QStringLiteral("name")] = QLatin1String(s.name);
        entry[QStringLiteral("source")] = QLatin1String(s.source);
        entry[QStringLiteral("value")] = value;
        entry[QStringLiteral("unit")] = QLatin1String(s.unit);
        entries.append(entry);
    }

    m_liveSensorEntries = entries;
    emit liveSensorEntriesChanged();
}


// ---------------------------------------------------------------------------
// Log accessors
// ---------------------------------------------------------------------------

QStringList DiagnosticsProvider::logMessages() const
{
    return m_logMessages;
}

QStringList DiagnosticsProvider::filteredLogMessages() const
{
    if (m_logLevel <= 0)
        return m_logMessages;

    QStringList filtered;
    for (const auto &entry : m_logEntries) {
        if (entry.level >= m_logLevel)
            filtered.append(entry.text);
    }
    return filtered;
}

int DiagnosticsProvider::logLevel() const
{
    return m_logLevel;
}

void DiagnosticsProvider::setLogLevel(int level)
{
    if (m_logLevel != level) {
        m_logLevel = level;
        emit logLevelChanged();
        emit logChanged();
    }
}

void DiagnosticsProvider::rebuildLogCache()
{
    m_logMessages.clear();
    m_logMessages.reserve(m_logEntries.size());
    for (const auto &entry : m_logEntries)
        m_logMessages.append(entry.text);
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

    if (!m_sensorRegistry)
        return result;

    const QVariantList sensors = m_sensorRegistry->availableSensors();
    for (const QVariant &v : sensors) {
        QVariantMap sensorMap = v.toMap();
        QString key = sensorMap.value(QStringLiteral("key"), QString()).toString();

        QVariantMap entry;
        entry[QStringLiteral("key")] = key;
        entry[QStringLiteral("displayName")] = sensorMap.value(QStringLiteral("displayName"), QString()).toString();
        entry[QStringLiteral("unit")] = sensorMap.value(QStringLiteral("unit"), QString()).toString();
        entry[QStringLiteral("source")] = sensorMap.value(QStringLiteral("source"), QString()).toString();

        double rawValue = 0.0;
        if (m_propertyRouter && !key.isEmpty() && m_propertyRouter->hasProperty(key)) {
            QVariant val = m_propertyRouter->getValue(key);
            rawValue = val.toDouble();
        }
        entry[QStringLiteral("rawValue")] = rawValue;
        entry[QStringLiteral("calibratedValue")] = rawValue;
        entry[QStringLiteral("active")] = (qAbs(rawValue) > 0.0001);
        result.append(entry);
    }

    return result;
}

/**
 * @brief Returns diagnostic information for ECU-reported analog input channels.
 *
 * Provides raw ADC voltage and calibration data for Analog0 through Analog10
 * (0-indexed, 11 channels total) received via daemon UDP.
 *
 * @return QVariantList containing diagnostic entries for each analog input channel.
 */
QVariantList DiagnosticsProvider::getAnalogInputDiagnostics() const
{
    QVariantList result;

    for (int i = 0; i <= 10; ++i) {
        QString rawKey = QStringLiteral("Analog%1").arg(i);
        QString calcKey = QStringLiteral("AnalogCalc%1").arg(i);

        double rawVoltage = 0.0;
        double calibrated = 0.0;

        if (m_propertyRouter) {
            if (m_propertyRouter->hasProperty(rawKey))
                rawVoltage = m_propertyRouter->getValue(rawKey).toDouble();
            if (m_propertyRouter->hasProperty(calcKey))
                calibrated = m_propertyRouter->getValue(calcKey).toDouble();
        }

        QVariantMap entry;
        entry[QStringLiteral("channel")] = i;
        entry[QStringLiteral("label")] = rawKey;
        entry[QStringLiteral("rawVoltage")] = rawVoltage;
        entry[QStringLiteral("calibratedValue")] = calibrated;
        entry[QStringLiteral("presetName")] = QString();
        entry[QStringLiteral("unit")] = QStringLiteral("V");
        entry[QStringLiteral("configured")] = (qAbs(rawVoltage) > 0.001 || qAbs(calibrated) > 0.001);
        result.append(entry);
    }

    return result;
}

/**
 * @brief Returns diagnostic information for daemon-reported digital inputs.
 *
 * Provides state and configuration data for DigitalInput1 through
 * DigitalInput7 (7 channels total) received via daemon UDP.
 *
 * @return QVariantList containing diagnostic entries for each digital input channel.
 */
QVariantList DiagnosticsProvider::getDigitalInputDiagnostics() const
{
    QVariantList result;

    for (int i = 1; i <= 7; ++i) {
        QString key = QStringLiteral("DigitalInput%1").arg(i);

        bool state = false;
        if (m_propertyRouter && m_propertyRouter->hasProperty(key))
            state = m_propertyRouter->getValue(key).toBool();

        QVariantMap entry;
        entry[QStringLiteral("channel")] = i;
        entry[QStringLiteral("label")] = key;
        entry[QStringLiteral("state")] = state;
        entry[QStringLiteral("configured")] = state;
        result.append(entry);
    }

    return result;
}

/**
 * @brief Returns diagnostic information for extender board analog inputs.
 *
 * Provides raw ADC voltage and calibration data for EXAnalogInput0 through
 * EXAnalogInput7 (0-indexed, 8 channels total) from the extender board CAN interface.
 *
 * @return QVariantList containing diagnostic entries for each extender analog input channel.
 */
QVariantList DiagnosticsProvider::getExpanderBoardDiagnostics() const
{
    QVariantList result;

    for (int i = 0; i <= 7; ++i) {
        QString rawKey = QStringLiteral("EXAnalogInput%1").arg(i);
        QString calcKey = QStringLiteral("EXAnalogCalc%1").arg(i);

        double rawVoltage = 0.0;
        double calibrated = 0.0;

        if (m_propertyRouter) {
            if (m_propertyRouter->hasProperty(rawKey))
                rawVoltage = m_propertyRouter->getValue(rawKey).toDouble();
            if (m_propertyRouter->hasProperty(calcKey))
                calibrated = m_propertyRouter->getValue(calcKey).toDouble();
        }

        QVariantMap entry;
        entry[QStringLiteral("channel")] = i;
        entry[QStringLiteral("label")] = rawKey;
        entry[QStringLiteral("rawVoltage")] = rawVoltage;
        entry[QStringLiteral("calibratedValue")] = calibrated;
        entry[QStringLiteral("presetName")] = QString();
        entry[QStringLiteral("unit")] = QStringLiteral("V");
        entry[QStringLiteral("configured")] = (qAbs(rawVoltage) > 0.001 || qAbs(calibrated) > 0.001);
        result.append(entry);
    }

    return result;
}

/**
 * @brief Returns diagnostic information for extender board digital inputs.
 *
 * Provides state and configuration data for EXDigitalInput1 through
 * EXDigitalInput8 from the extender board CAN interface.
 *
 * @return QVariantList containing diagnostic entries for each extender digital input channel.
 */
QVariantList DiagnosticsProvider::getExtenderDigitalDiagnostics() const
{
    QVariantList result;

    for (int i = 1; i <= 8; ++i) {
        QString key = QStringLiteral("EXDigitalInput%1").arg(i);

        bool state = false;
        if (m_propertyRouter && m_propertyRouter->hasProperty(key))
            state = m_propertyRouter->getValue(key).toBool();

        QVariantMap entry;
        entry[QStringLiteral("channel")] = i;
        entry[QStringLiteral("label")] = key;
        entry[QStringLiteral("state")] = state;
        entry[QStringLiteral("configured")] = state;
        result.append(entry);
    }

    return result;
}

void DiagnosticsProvider::addLogMessage(const QString &level, const QString &message)
{
    int levelInt = 1;
    if (level == QLatin1String("DEBUG"))      levelInt = 0;
    else if (level == QLatin1String("INFO"))  levelInt = 1;
    else if (level == QLatin1String("WARN"))  levelInt = 2;
    else if (level == QLatin1String("ERROR") || level == QLatin1String("FATAL")) levelInt = 3;

    QString timestamp = QDateTime::currentDateTime().toString(QStringLiteral("hh:mm:ss"));
    QString text = QStringLiteral("[%1] [%2] %3").arg(timestamp, level, message);

    LogEntry entry{levelInt, text};
    m_logEntries.prepend(entry);
    m_logMessages.prepend(text);

    while (m_logEntries.size() > MAX_LOG_ENTRIES) {
        m_logEntries.removeLast();
        m_logMessages.removeLast();
    }

    emit logChanged();
}

void DiagnosticsProvider::clearLog()
{
    m_logEntries.clear();
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
    m_lastCanMsgTime.restart();
    m_lastCanMsgTimeValid = true;
}

/**
 * @brief Record a CAN error.
 *
 * Increments the error counter and emits canStatusChanged.
 */
void DiagnosticsProvider::recordCanError()
{
    ++m_canErrorCount;
    addLogMessage(QStringLiteral("ERROR"),
                  QStringLiteral("CAN error #%1").arg(m_canErrorCount));
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
        if (connected) {
            addLogMessage(QStringLiteral("INFO"),
                          QStringLiteral("CAN connected (daemon: %1)").arg(daemon));
        } else {
            m_lastCanMsgTimeValid = false;
            addLogMessage(QStringLiteral("WARN"), QStringLiteral("CAN disconnected"));
        }
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
    m_cpuTemp = readCpuTemperature();
    m_memoryUsage = readMemoryUsage();
    m_cpuLoadAvg = readCpuLoadAverage();
    m_diskUsage = readDiskUsage();
    readMemoryAbsolute(m_memUsedMB, m_memTotalMB);

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

double DiagnosticsProvider::readCpuLoadAverage() const
{
#ifdef Q_OS_LINUX
    QFile loadFile(QStringLiteral("/proc/loadavg"));
    if (loadFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&loadFile);
        QString line = in.readLine().trimmed();
        loadFile.close();
        QStringList parts = line.split(QStringLiteral(" "));
        if (!parts.isEmpty()) {
            bool ok = false;
            double avg1 = parts.at(0).toDouble(&ok);
            if (ok) return avg1;
        }
    }
    return 0.0;
#else
    return 0.0;
#endif
}

double DiagnosticsProvider::readDiskUsage() const
{
#ifdef Q_OS_LINUX
    struct statvfs stat;
    if (statvfs("/", &stat) == 0) {
        double total = static_cast<double>(stat.f_blocks) * stat.f_frsize;
        double avail = static_cast<double>(stat.f_bavail) * stat.f_frsize;
        if (total > 0) {
            return ((total - avail) / total) * 100.0;
        }
    }
    return 0.0;
#else
    return 0.0;
#endif
}

void DiagnosticsProvider::readMemoryAbsolute(double &usedMB, double &totalMB) const
{
#ifdef Q_OS_LINUX
    QFile memFile(QStringLiteral("/proc/meminfo"));
    if (!memFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        usedMB = 0.0;
        totalMB = 0.0;
        return;
    }
    QTextStream in(&memFile);
    double memTotalKB = 0.0;
    double memAvailKB = 0.0;
    bool foundTotal = false, foundAvail = false;
    while (!in.atEnd()) {
        QString line = in.readLine();
        if (line.startsWith(QStringLiteral("MemTotal:"))) {
            QStringList parts = line.split(QRegularExpression(QStringLiteral("\\s+")));
            if (parts.size() >= 2) { memTotalKB = parts.at(1).toDouble(); foundTotal = true; }
        } else if (line.startsWith(QStringLiteral("MemAvailable:"))) {
            QStringList parts = line.split(QRegularExpression(QStringLiteral("\\s+")));
            if (parts.size() >= 2) { memAvailKB = parts.at(1).toDouble(); foundAvail = true; }
        }
        if (foundTotal && foundAvail) break;
    }
    memFile.close();
    totalMB = memTotalKB / 1024.0;
    usedMB = (memTotalKB - memAvailKB) / 1024.0;
#elif defined(Q_OS_MACOS)
    mach_port_t host = mach_host_self();
    vm_statistics64_data_t vmStats;
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
    kern_return_t result = host_statistics64(host, HOST_VM_INFO64,
                                             reinterpret_cast<host_info64_t>(&vmStats), &count);
    if (result != KERN_SUCCESS) { usedMB = 0.0; totalMB = 0.0; return; }
    vm_size_t pageSize = 0;
    host_page_size(host, &pageSize);
    uint64_t active = static_cast<uint64_t>(vmStats.active_count) * pageSize;
    uint64_t wired = static_cast<uint64_t>(vmStats.wire_count) * pageSize;
    uint64_t compressed = static_cast<uint64_t>(vmStats.compressor_page_count) * pageSize;
    uint64_t inactive = static_cast<uint64_t>(vmStats.inactive_count) * pageSize;
    uint64_t free_mem = static_cast<uint64_t>(vmStats.free_count) * pageSize;
    uint64_t used = active + wired + compressed;
    uint64_t total = active + inactive + wired + free_mem + compressed;
    totalMB = static_cast<double>(total) / (1024.0 * 1024.0);
    usedMB = static_cast<double>(used) / (1024.0 * 1024.0);
#else
    usedMB = 0.0;
    totalMB = 0.0;
#endif
}
