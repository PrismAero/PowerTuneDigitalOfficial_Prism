#include "CanTransport.h"

#include <QCanBus>

CanTransport::CanTransport(QObject *parent) : QObject(parent) {}

CanTransport::~CanTransport()
{
    close();
}

bool CanTransport::socketCanAvailable() const
{
    return QCanBus::instance()->plugins().contains(QStringLiteral("socketcan"));
}

QString CanTransport::interfaceName() const
{
    return m_interfaceName;
}

void CanTransport::setInterfaceName(const QString &interfaceName)
{
    if (m_interfaceName == interfaceName || interfaceName.isEmpty())
        return;

    m_interfaceName = interfaceName;
    emit interfaceNameChanged();
}

QString CanTransport::lastError() const
{
    return m_lastError;
}

bool CanTransport::isConnected() const
{
    return m_device && m_device->state() == QCanBusDevice::ConnectedState;
}

bool CanTransport::open()
{
    close();

    if (!socketCanAvailable()) {
        setLastError(QStringLiteral("Qt socketcan plugin is not available"));
        return false;
    }

    QString errorString;
    m_device = QCanBus::instance()->createDevice(QStringLiteral("socketcan"), m_interfaceName, &errorString);
    if (!m_device) {
        setLastError(errorString.isEmpty() ? QStringLiteral("Failed to create CAN device") : errorString);
        return false;
    }

    connect(m_device, &QCanBusDevice::framesReceived, this, &CanTransport::onFramesReceived);
    connect(m_device, &QCanBusDevice::errorOccurred, this, &CanTransport::onCanError);

    if (!m_device->connectDevice()) {
        setLastError(m_device->errorString().isEmpty() ? QStringLiteral("Failed to connect CAN device")
                                                       : m_device->errorString());
        close();
        return false;
    }

    m_lastError.clear();
    emit connectionChanged(true);
    return true;
}

void CanTransport::close()
{
    if (!m_device)
        return;

    disconnect(m_device, nullptr, this, nullptr);
    if (m_device->state() == QCanBusDevice::ConnectedState)
        m_device->disconnectDevice();
    m_device->deleteLater();
    m_device = nullptr;
    emit connectionChanged(false);
}

bool CanTransport::writeFrame(const QCanBusFrame &frame)
{
    if (!isConnected()) {
        setLastError(QStringLiteral("Cannot write CAN frame while disconnected"));
        return false;
    }

    if (!m_device->writeFrame(frame)) {
        setLastError(m_device->errorString().isEmpty() ? QStringLiteral("Failed to write CAN frame")
                                                       : m_device->errorString());
        return false;
    }

    return true;
}

void CanTransport::onFramesReceived()
{
    if (!m_device)
        return;

    while (m_device->framesAvailable())
        emit frameReceived(m_device->readFrame());
}

void CanTransport::onCanError(QCanBusDevice::CanBusError error)
{
    if (!m_device || error == QCanBusDevice::NoError)
        return;

    const QString interpreted = m_device->errorString().isEmpty() ? QStringLiteral("CAN transport error")
                                                                   : m_device->errorString();
    setLastError(interpreted);
}

void CanTransport::setLastError(const QString &message)
{
    m_lastError = message;
    emit errorOccurred(m_lastError);
}
