#include "DfiSerialReader.h"

#include "../Core/AppSettings.h"
#include "../Core/DiagnosticsProvider.h"
#include "../Core/SensorRegistry.h"
#include "../Core/Models/VehicleData.h"

#include <QDebug>

const int DfiSerialReader::KnownCodes[KnownCodeCount] = {
    11, 12, 13, 14, 15, 21, 23, 24, 25, 31, 32, 33, 34, 35,
    36, 39, 46, 51, 52, 53, 54, 56, 62, 63, 64, 67, 83
};

DfiSerialReader::DfiSerialReader(QObject *parent)
    : QObject(parent)
    , m_portPath(QStringLiteral("/dev/ttyAMA0"))
{
    dfi_init(&m_decoder);
    dfi_set_status_callback(&m_decoder, &DfiSerialReader::statusCallback, this);

    m_signalTimer.setInterval(SIGNAL_TIMEOUT_MS);
    m_signalTimer.setSingleShot(true);
    connect(&m_signalTimer, &QTimer::timeout, this, &DfiSerialReader::checkSignalTimeout);
}

DfiSerialReader::~DfiSerialReader()
{
    stop();
}

void DfiSerialReader::setAppSettings(AppSettings *settings)
{
    m_appSettings = settings;
    if (m_appSettings) {
        m_portPath = m_appSettings->getValue(QStringLiteral("ui/dfiSerial/port"),
                                             QStringLiteral("/dev/ttyAMA0")).toString();
        m_enabled = m_appSettings->getValue(QStringLiteral("ui/dfiSerial/enabled"), false).toBool();
        loadSuppressedCodes();
    }
}

void DfiSerialReader::setVehicleData(VehicleData *vehicleData)
{
    m_vehicleData = vehicleData;
}

void DfiSerialReader::setDiagnosticsProvider(DiagnosticsProvider *diag)
{
    m_diagnosticsProvider = diag;
}

void DfiSerialReader::setSensorRegistry(SensorRegistry *registry)
{
    m_sensorRegistry = registry;
}

int DfiSerialReader::gear() const
{
    return m_gear;
}

QString DfiSerialReader::gearString() const
{
    if (m_gear < 0)
        return QStringLiteral("?");
    return QString::fromUtf8(dfi_gear_str(static_cast<dfi_gear_t>(m_gear)));
}

QString DfiSerialReader::activeCodes() const
{
    return m_activeCodes;
}

int DfiSerialReader::checksumErrors() const
{
    return static_cast<int>(m_decoder.status.checksum_errors);
}

int DfiSerialReader::groupsReceived() const
{
    return static_cast<int>(m_decoder.status.groups_received);
}

bool DfiSerialReader::connected() const
{
    return m_connected;
}

bool DfiSerialReader::hasSignal() const
{
    return m_hasSignal;
}

QString DfiSerialReader::portPath() const
{
    return m_portPath;
}

bool DfiSerialReader::enabled() const
{
    return m_enabled;
}

void DfiSerialReader::setPortPath(const QString &path)
{
    if (m_portPath == path)
        return;
    m_portPath = path;
    if (m_appSettings)
        m_appSettings->setValue(QStringLiteral("ui/dfiSerial/port"), path);
    emit portPathChanged(path);
}

void DfiSerialReader::setEnabled(bool on)
{
    if (m_enabled == on)
        return;
    m_enabled = on;
    if (m_appSettings)
        m_appSettings->setValue(QStringLiteral("ui/dfiSerial/enabled"), on);
    if (on)
        start();
    else
        stop();
    emit enabledChanged(on);
}

void DfiSerialReader::start()
{
    if (m_serial) {
        stop();
    }

    m_serial = new QSerialPort(this);
    m_serial->setPortName(m_portPath);
    m_serial->setBaudRate(DFI_BAUD_RATE);
    m_serial->setDataBits(QSerialPort::Data8);
    m_serial->setParity(QSerialPort::NoParity);
    m_serial->setStopBits(QSerialPort::OneStop);
    m_serial->setFlowControl(QSerialPort::NoFlowControl);

    connect(m_serial, &QSerialPort::readyRead, this, &DfiSerialReader::onReadyRead);
    connect(m_serial, &QSerialPort::errorOccurred, this, &DfiSerialReader::onSerialError);

    if (!m_serial->open(QIODevice::ReadOnly)) {
        qWarning() << "DfiSerialReader: failed to open" << m_portPath << m_serial->errorString();
        if (m_diagnosticsProvider)
            m_diagnosticsProvider->addLogMessage(QStringLiteral("ERROR"),
                QStringLiteral("DFI Serial: failed to open %1 - %2").arg(m_portPath, m_serial->errorString()));
        delete m_serial;
        m_serial = nullptr;
        return;
    }

    dfi_init(&m_decoder);
    dfi_set_status_callback(&m_decoder, &DfiSerialReader::statusCallback, this);
    m_elapsedTimer.start();
    m_lastStatusEmitMs = 0;

    bool wasConnected = m_connected;
    m_connected = true;
    if (!wasConnected)
        emit connectedChanged(true);

    qInfo() << "DfiSerialReader: listening on" << m_portPath << "at" << DFI_BAUD_RATE << "baud";
    if (m_diagnosticsProvider)
        m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"),
            QStringLiteral("DFI Serial: listening on %1 at %2 baud").arg(m_portPath).arg(DFI_BAUD_RATE));
}

void DfiSerialReader::stop()
{
    m_signalTimer.stop();

    if (m_serial) {
        m_serial->close();
        delete m_serial;
        m_serial = nullptr;
    }

    bool wasConnected = m_connected;
    m_connected = false;
    m_hasSignal = false;
    if (wasConnected)
        emit connectedChanged(false);
}

void DfiSerialReader::onReadyRead()
{
    if (!m_serial)
        return;

    const QByteArray data = m_serial->readAll();
    if (data.isEmpty())
        return;
    const quint64 now_us = static_cast<quint64>(m_elapsedTimer.nsecsElapsed() / 1000);

    for (int i = 0; i < data.size(); ++i) {
        dfi_feed_byte(&m_decoder, static_cast<uint8_t>(data.at(i)),
                      static_cast<uint32_t>(now_us & 0xFFFFFFFF));
    }

    if (!m_hasSignal) {
        m_hasSignal = true;
        emit statusUpdated();
    }

    if (m_sensorRegistry) {
        m_sensorRegistry->markCanSensorActive(QStringLiteral("DfiSerialGear"));
        m_sensorRegistry->markCanSensorActive(QStringLiteral("DfiSerialCodes"));
        m_sensorRegistry->markCanSensorActive(QStringLiteral("DfiSerialChecksumErrors"));
        m_sensorRegistry->markCanSensorActive(QStringLiteral("DfiSerialGroupsRx"));
    }

    // Decoder callbacks only fire when gear/code set changes; emit a throttled
    // status update here so counters and activity stay fresh during steady data.
    const qint64 nowMs = m_elapsedTimer.elapsed();
    if ((nowMs - m_lastStatusEmitMs) >= 200) {
        m_lastStatusEmitMs = nowMs;
        emit statusUpdated();
    }
    m_signalTimer.start();
}

void DfiSerialReader::onSerialError(QSerialPort::SerialPortError error)
{
    if (error == QSerialPort::NoError)
        return;

    qWarning() << "DfiSerialReader: serial error" << error
               << (m_serial ? m_serial->errorString() : QString());

    if (m_diagnosticsProvider)
        m_diagnosticsProvider->addLogMessage(QStringLiteral("ERROR"),
            QStringLiteral("DFI Serial error: %1").arg(m_serial ? m_serial->errorString() : QStringLiteral("unknown")));

    if (error == QSerialPort::ResourceError) {
        stop();
    }
}

void DfiSerialReader::checkSignalTimeout()
{
    if (m_hasSignal) {
        m_hasSignal = false;
        emit statusUpdated();
    }
}

void DfiSerialReader::statusCallback(const dfi_status_t *status, void *userData)
{
    auto *self = static_cast<DfiSerialReader *>(userData);
    self->publishStatus(status);
}

void DfiSerialReader::publishStatus(const dfi_status_t *status)
{
    int newGear = (status->gear == DFI_GEAR_INVALID) ? -1 : static_cast<int>(status->gear);
    bool gearDirty = (newGear != m_gear);
    m_gear = newGear;

    QString newCodes = buildFilteredCodeString(status);
    bool codesDirty = (newCodes != m_activeCodes);
    m_activeCodes = newCodes;

    if (gearDirty) {
        emit gearChanged(m_gear);
        if (m_vehicleData && m_gear >= 0)
            m_vehicleData->setGear(m_gear);
    }
    if (codesDirty)
        emit activeCodesChanged(m_activeCodes);

    if (m_sensorRegistry) {
        m_sensorRegistry->markCanSensorActive(QStringLiteral("DfiSerialGear"));
        m_sensorRegistry->markCanSensorActive(QStringLiteral("DfiSerialCodes"));
        m_sensorRegistry->markCanSensorActive(QStringLiteral("DfiSerialChecksumErrors"));
        m_sensorRegistry->markCanSensorActive(QStringLiteral("DfiSerialGroupsRx"));
    }

    emit statusUpdated();
}

QString DfiSerialReader::buildFilteredCodeString(const dfi_status_t *status) const
{
    QStringList parts;
    for (uint8_t i = 0; i < status->code_count; ++i) {
        int code = status->codes[i];
        if (!m_suppressedCodes.contains(code))
            parts.append(QString::number(code));
    }
    return parts.join(',');
}

// -- Code suppression --

bool DfiSerialReader::isCodeSuppressed(int code) const
{
    return m_suppressedCodes.contains(code);
}

void DfiSerialReader::suppressCode(int code)
{
    int before = m_suppressedCodes.size();
    m_suppressedCodes.insert(code);
    if (m_suppressedCodes.size() == before)
        return;
    saveSuppressedCodes();
    const dfi_status_t *status = dfi_get_status(&m_decoder);
    QString newCodes = buildFilteredCodeString(status);
    if (newCodes != m_activeCodes) {
        m_activeCodes = newCodes;
        emit activeCodesChanged(m_activeCodes);
    }
}

void DfiSerialReader::unsuppressCode(int code)
{
    if (m_suppressedCodes.remove(code)) {
        saveSuppressedCodes();
        const dfi_status_t *status = dfi_get_status(&m_decoder);
        QString newCodes = buildFilteredCodeString(status);
        if (newCodes != m_activeCodes) {
            m_activeCodes = newCodes;
            emit activeCodesChanged(m_activeCodes);
        }
    }
}

void DfiSerialReader::suppressAllKnownCodes()
{
    for (int i = 0; i < KnownCodeCount; ++i)
        m_suppressedCodes.insert(KnownCodes[i]);
    saveSuppressedCodes();
    const dfi_status_t *status = dfi_get_status(&m_decoder);
    m_activeCodes = buildFilteredCodeString(status);
    emit activeCodesChanged(m_activeCodes);
}

void DfiSerialReader::enableAllCodes()
{
    m_suppressedCodes.clear();
    saveSuppressedCodes();
    const dfi_status_t *status = dfi_get_status(&m_decoder);
    m_activeCodes = buildFilteredCodeString(status);
    emit activeCodesChanged(m_activeCodes);
}

QStringList DfiSerialReader::suppressedCodeList() const
{
    QStringList result;
    for (int code : m_suppressedCodes)
        result.append(QString::number(code));
    result.sort();
    return result;
}

QString DfiSerialReader::dfiCodeDescription(int code)
{
    return QString::fromUtf8(dfi_code_description(static_cast<uint8_t>(code)));
}

void DfiSerialReader::loadSuppressedCodes()
{
    if (!m_appSettings)
        return;
    const QString csv = m_appSettings->getValue(QStringLiteral("ui/dfiSerial/suppressedCodes")).toString();
    m_suppressedCodes.clear();
    if (csv.isEmpty())
        return;
    const QStringList parts = csv.split(',', Qt::SkipEmptyParts);
    for (const QString &s : parts) {
        bool ok = false;
        int code = s.trimmed().toInt(&ok);
        if (ok)
            m_suppressedCodes.insert(code);
    }
}

void DfiSerialReader::saveSuppressedCodes()
{
    if (!m_appSettings)
        return;
    QStringList parts;
    for (int code : m_suppressedCodes)
        parts.append(QString::number(code));
    parts.sort();
    m_appSettings->setValue(QStringLiteral("ui/dfiSerial/suppressedCodes"), parts.join(','));
}
