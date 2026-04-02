#include "PTExtenderCan.h"

#include "../../Can/CanTransport.h"
#include "../../Core/DiagnosticsProvider.h"
#include "../../Core/Models/ConnectionData.h"
#include "../../Core/Models/DigitalInputs.h"
#include "../../Core/Models/ExpanderBoardData.h"
#include "../../Core/Models/VehicleData.h"
#include "../../Core/SensorRegistry.h"

#include <QStringList>

PTExtenderCan::PTExtenderCan(QObject *parent) : CanInterface(parent) {}

PTExtenderCan::PTExtenderCan(DigitalInputs *digitalInputs, ExpanderBoardData *expanderBoardData,
                             VehicleData *vehicleData, ConnectionData *connectionData, QObject *parent)
    : CanInterface(parent),
      m_digitalInputs(digitalInputs),
      m_expanderBoardData(expanderBoardData),
      m_vehicleData(vehicleData),
      m_connectionData(connectionData)
{}

PTExtenderCan::~PTExtenderCan()
{
    detachTransport();
}

QString PTExtenderCan::moduleName() const
{
    return QStringLiteral("PTExtenderCan");
}

int PTExtenderCan::moduleBackendId() const
{
    return PT_EXTENDER_BACKEND_ID;
}

void PTExtenderCan::configureConnection(const QVariantMap &config)
{
    const int base = config.value(QStringLiteral("canBaseId"), 0).toInt();
    m_baseId = static_cast<quint32>(base);
    m_statusAddress = m_baseId + 0x01;
    m_ioAddress = m_baseId + 0x02;
    m_ledAddress = m_baseId + 0x03;
    emit baseIdChanged();
}

void PTExtenderCan::attachTransport(CanTransport *transport)
{
    if (m_transport == transport)
        return;

    detachTransport();
    m_transport = transport;
    if (m_transport) {
        connect(m_transport, &CanTransport::frameReceived, this, &PTExtenderCan::onFrameReceived);
    }
}

void PTExtenderCan::detachTransport()
{
    if (!m_transport)
        return;

    disconnect(m_transport, nullptr, this, nullptr);
    m_transport = nullptr;
}

bool PTExtenderCan::sendLedChannelCommand(int channel, int brightness)
{
    QByteArray payload(8, '\0');
    payload[0] = static_cast<char>(qBound(0, channel, 15));
    payload[1] = static_cast<char>(qBound(0, brightness, 255));
    return writeFrame(m_baseId + 0x10, payload);
}

bool PTExtenderCan::sendStateOverrideCommand(int state, int r, int g, int b, int pattern, int period10ms)
{
    QByteArray payload(8, '\0');
    payload[0] = static_cast<char>(qBound(0, state, 255));
    payload[1] = static_cast<char>(qBound(0, r, 255));
    payload[2] = static_cast<char>(qBound(0, g, 255));
    payload[3] = static_cast<char>(qBound(0, b, 255));
    payload[4] = static_cast<char>(qBound(0, pattern, 255));
    payload[5] = static_cast<char>(qBound(0, period10ms, 255));
    return writeFrame(m_baseId + 0x11, payload);
}

bool PTExtenderCan::sendDeviceCommand(int command)
{
    QByteArray payload(8, '\0');
    payload[0] = static_cast<char>(qBound(0, command, 255));
    return writeFrame(m_baseId + 0x12, payload);
}

void PTExtenderCan::onFrameReceived(const QCanBusFrame &frame)
{
    const quint32 frameId = static_cast<quint32>(frame.frameId());
    const QString payloadHex = byteArrayToHex(frame.payload());
    emit NewCanFrameReceived(static_cast<int>(frame.frameId()), payloadHex);

    if (m_connectionData) {
        const QString canid = QStringLiteral("0x") + QString::number(frameId, 16).toUpper();
        m_connectionData->setcan({canid, payloadHex});
    }

    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->recordCanFrame(frameId, frame.payload());
        m_diagnosticsProvider->recordCanMessage();
    }

    QByteArray payload = frame.payload();
    if (payload.size() < 8)
        payload.append(QByteArray(8 - payload.size(), '\0'));

    if (frameId == m_statusAddress) {
        const int gear = static_cast<unsigned char>(payload[0]);
        if (m_expanderBoardData)
            m_expanderBoardData->setEXGear(gear);
        if (m_vehicleData)
            m_vehicleData->setGear(gear);
        updateActiveCodesFromFrame(payload);
        if (m_sensorRegistry) {
            m_sensorRegistry->markCanSensorActive(QStringLiteral("EXGear"));
        }
    } else if (frameId == m_ioAddress) {
        if (m_digitalInputs) {
            const int byte0 = static_cast<unsigned char>(payload[0]);
            const int byte1 = static_cast<unsigned char>(payload[1]);
            m_digitalInputs->setPTDigitalInput1((byte0 & 0x01) != 0);
            m_digitalInputs->setPTDigitalInput2((byte0 & 0x02) != 0);
            m_digitalInputs->setPTDigitalInput3((byte0 & 0x04) != 0);
            m_digitalInputs->setPTDigitalInput4((byte0 & 0x08) != 0);

            m_digitalInputs->setPTRelayMask(byte1 & 0x0F);
            m_digitalInputs->setPTRelay1((byte1 & 0x01) != 0);
            m_digitalInputs->setPTRelay2((byte1 & 0x02) != 0);
            m_digitalInputs->setPTRelay3((byte1 & 0x04) != 0);
            m_digitalInputs->setPTRelay4((byte1 & 0x08) != 0);
        }
        if (m_sensorRegistry) {
            for (int i = 1; i <= 4; ++i) {
                m_sensorRegistry->markCanSensorActive(QStringLiteral("PTDigitalInput%1").arg(i));
                m_sensorRegistry->markCanSensorActive(QStringLiteral("PTRelay%1").arg(i));
            }
            m_sensorRegistry->markCanSensorActive(QStringLiteral("PTRelayMask"));
        }
    } else if (frameId == m_ledAddress) {
        // LED feedback frame is currently consumed only via diagnostics/frame viewer.
    }
}

QString PTExtenderCan::byteArrayToHex(const QByteArray &byteArray) const
{
    QString hexString;
    for (const uchar &byte : byteArray)
        hexString.append(QStringLiteral("%1 ").arg(byte, 2, 16, QChar('0')));
    return hexString.trimmed();
}

bool PTExtenderCan::writeFrame(quint32 id, const QByteArray &payload)
{
    if (!m_transport)
        return false;
    return m_transport->writeFrame(QCanBusFrame(id, payload));
}

void PTExtenderCan::updateActiveCodesFromFrame(const QByteArray &payload)
{
    const int count = qBound(0, static_cast<int>(static_cast<unsigned char>(payload[1])), 6);
    QStringList codes;
    for (int i = 0; i < count; i++) {
        const int code = static_cast<unsigned char>(payload[2 + i]);
        if (code > 0)
            codes << QString::number(code);
    }
    const QString next = codes.join(QStringLiteral(","));
    if (next != m_activeCodes) {
        m_activeCodes = next;
        emit activeCodesChanged();
    }
}
