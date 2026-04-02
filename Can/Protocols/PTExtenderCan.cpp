#include "PTExtenderCan.h"

#include "../../Can/CanTransport.h"
#include "../../Core/DiagnosticsProvider.h"
#include "../../Core/PTExtenderConfigManager.h"
#include "../../Core/Models/ConnectionData.h"
#include "../../Core/Models/DigitalInputs.h"
#include "../../Core/Models/ExpanderBoardData.h"
#include "../../Core/Models/VehicleData.h"
#include "../../Core/SensorRegistry.h"

#include <QStringList>

namespace {
struct DfiCodeDesc
{
    int code;
    const char *description;
};

static const DfiCodeDesc kDfiCodeDescriptions[] = {
    {11, "Main throttle sensor"},
    {12, "Inlet air pressure sensor"},
    {13, "Inlet air temperature sensor"},
    {14, "Water temperature sensor"},
    {15, "Atmospheric pressure sensor"},
    {21, "Crankshaft sensor"},
    {23, "Camshaft position sensor"},
    {24, "Speed sensor"},
    {25, "Gear position switch"},
    {31, "Vehicle-down sensor"},
    {32, "Subthrottle sensor"},
    {33, "Oxygen sensor #1 inactivation"},
    {34, "Exhaust butterfly valve actuator sensor"},
    {35, "Immobilizer amplifier"},
    {36, "Blank key detection"},
    {39, "ECU communication error"},
    {46, "Fuel pump relay stuck"},
    {51, "Stick coil #1"},
    {52, "Stick coil #2"},
    {53, "Stick coil #3"},
    {54, "Stick coil #4"},
    {56, "Radiator fan relay"},
    {62, "Subthrottle valve actuator"},
    {63, "Exhaust butterfly valve actuator"},
    {64, "Air switching valve"},
    {67, "Oxygen sensor heater #1/#2"},
    {83, "Oxygen sensor #2 inactivation"},
};
}

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
    m_indicatorConfigAddress = m_baseId + 0x04;
    m_configReadResponseAddress = m_baseId + 0x05;
    m_configWriteAckAddress = m_baseId + 0x06;
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

void PTExtenderCan::setConfigManager(PTExtenderConfigManager *manager)
{
    if (m_configManager == manager)
        return;

    if (m_configManager)
        disconnect(m_configManager, nullptr, this, nullptr);
    m_configManager = manager;
    if (m_configManager) {
        connect(m_configManager, &PTExtenderConfigManager::suppressedCodesChanged, this, [this]() {
            if (m_digitalInputs)
                m_digitalInputs->setPTActiveCodes(filteredActiveCodes());
            emit activeCodesChanged();
        });
    }
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

bool PTExtenderCan::writeConfigRegister(int group, int index, int sub, const QByteArray &data)
{
    QByteArray payload(8, '\0');
    payload[0] = static_cast<char>(qBound(0, group, 255));
    payload[1] = static_cast<char>(qBound(0, index, 255));
    payload[2] = static_cast<char>(qBound(0, sub, 255));

    const int copyLen = qMin(5, data.size());
    for (int i = 0; i < copyLen; ++i)
        payload[3 + i] = data[i];

    return writeFrame(m_baseId + 0x20, payload);
}

bool PTExtenderCan::readConfigRegister(int group, int index, int sub)
{
    QByteArray payload(8, '\0');
    payload[0] = static_cast<char>(qBound(0, group, 255));
    payload[1] = static_cast<char>(qBound(0, index, 255));
    payload[2] = static_cast<char>(qBound(0, sub, 255));
    return writeFrame(m_baseId + 0x21, payload);
}

bool PTExtenderCan::setGpiFunction(int channel, int function)
{
    QByteArray payload(4, '\0');
    payload[0] = static_cast<char>(qBound(0, function, 255));
    payload[1] = static_cast<char>(50); // keep current behavior defaults if caller uses wrapper only
    payload[2] = static_cast<char>(0);
    payload[3] = static_cast<char>(1);
    return writeConfigRegister(ConfigGroupGpi, channel, 0x00, payload);
}

bool PTExtenderCan::setRelayFunction(int channel, int function)
{
    QByteArray payload(4, '\0');
    payload[0] = static_cast<char>(qBound(0, function, 255));
    payload[1] = static_cast<char>(1);
    payload[2] = static_cast<char>(0);
    payload[3] = static_cast<char>(0xFF); // -1 (independent)
    return writeConfigRegister(ConfigGroupRelay, channel, 0x00, payload);
}

bool PTExtenderCan::setTimingParam(int param, int valueMs)
{
    QByteArray payload(2, '\0');
    const int bounded = qBound(0, valueMs, 65535);
    payload[0] = static_cast<char>(bounded & 0xFF);
    payload[1] = static_cast<char>((bounded >> 8) & 0xFF);
    return writeConfigRegister(ConfigGroupTiming, param, 0x00, payload);
}

bool PTExtenderCan::setEngineProofMode(int mode)
{
    QByteArray payload(1, '\0');
    payload[0] = static_cast<char>(qBound(0, mode, 255));
    return writeConfigRegister(ConfigGroupSystemGlobals, 0x06, 0x00, payload);
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

    if (frameId == m_configReadResponseAddress) {
        const int group = static_cast<unsigned char>(payload[0]);
        const int index = static_cast<unsigned char>(payload[1]);
        const int sub = static_cast<unsigned char>(payload[2]);
        const QByteArray data = payload.mid(3, 5);

        m_lastConfigReadGroup = group;
        m_lastConfigReadIndex = index;
        m_lastConfigReadSub = sub;
        m_lastConfigReadPayloadHex = byteArrayToHex(data);
        emit configResponseReceived(group, index, sub, data);
    } else if (frameId == m_configWriteAckAddress) {
        const int status = static_cast<unsigned char>(payload[0]);
        const int group = static_cast<unsigned char>(payload[1]);
        const int index = static_cast<unsigned char>(payload[2]);
        const int sub = static_cast<unsigned char>(payload[3]);

        m_lastConfigAckStatus = status;
        emit configWriteAcked(status, group, index, sub);
    } else if (frameId == m_statusAddress) {
        const int rawGear = static_cast<unsigned char>(payload[0]);
        const int gear = (rawGear == 0xFF) ? -2 : rawGear;
        if (m_gear != gear) {
            m_gear = gear;
            emit gearChanged();
        }
        if (m_expanderBoardData)
            m_expanderBoardData->setEXGear(gear);
        if (m_vehicleData)
            m_vehicleData->setGear(gear);
        if (m_digitalInputs)
            m_digitalInputs->setPTGear(gear);
        updateActiveCodesFromFrame(payload);
        if (m_sensorRegistry) {
            m_sensorRegistry->markCanSensorActive(QStringLiteral("EXGear"));
            m_sensorRegistry->markCanSensorActive(QStringLiteral("PTGear"));
            m_sensorRegistry->markCanSensorActive(QStringLiteral("PTActiveCodes"));
        }
    } else if (frameId == m_ioAddress) {
        const int byte2 = static_cast<unsigned char>(payload[2]);
        const int byte3 = static_cast<unsigned char>(payload[3]);
        const int byte4 = static_cast<unsigned char>(payload[4]);
        const int byte5 = static_cast<unsigned char>(payload[5]);
        const int byte6 = static_cast<unsigned char>(payload[6]);
        const int byte7 = static_cast<unsigned char>(payload[7]);
        bool ioStatusChanged = false;
        if (m_ioState != byte2) {
            m_ioState = byte2;
            ioStatusChanged = true;
        }
        if (m_ioFault != byte3) {
            m_ioFault = byte3;
            ioStatusChanged = true;
        }
        if (m_relayFollowerMask != (byte4 & 0x0F)) {
            m_relayFollowerMask = byte4 & 0x0F;
            ioStatusChanged = true;
        }
        if (m_relayInvertMask != ((byte4 >> 4) & 0x0F)) {
            m_relayInvertMask = (byte4 >> 4) & 0x0F;
            ioStatusChanged = true;
        }
        if (m_relayBoundTargetsPacked != byte5) {
            m_relayBoundTargetsPacked = byte5;
            ioStatusChanged = true;
        }
        if (m_dfiChecksumErrors != byte6) {
            m_dfiChecksumErrors = byte6;
            ioStatusChanged = true;
        }
        if (m_canTxErrors != byte7) {
            m_canTxErrors = byte7;
            ioStatusChanged = true;
        }
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
            m_digitalInputs->setPTSystemState(byte2);
            m_digitalInputs->setPTSystemFault(byte3);
            m_digitalInputs->setPTRelayFollowerMask(byte4 & 0x0F);
            m_digitalInputs->setPTRelayInvertMask((byte4 >> 4) & 0x0F);
            m_digitalInputs->setPTRelayBoundTargetsPacked(byte5);
            m_digitalInputs->setPTDfiChecksumErrors(byte6);
            m_digitalInputs->setPTCanTxErrors(byte7);
        }
        if (m_sensorRegistry) {
            for (int i = 1; i <= 4; ++i) {
                m_sensorRegistry->markCanSensorActive(QStringLiteral("PTDigitalInput%1").arg(i));
                m_sensorRegistry->markCanSensorActive(QStringLiteral("PTRelay%1").arg(i));
            }
            m_sensorRegistry->markCanSensorActive(QStringLiteral("PTRelayMask"));
            m_sensorRegistry->markCanSensorActive(QStringLiteral("PTSystemState"));
            m_sensorRegistry->markCanSensorActive(QStringLiteral("PTSystemFault"));
            m_sensorRegistry->markCanSensorActive(QStringLiteral("PTDfiChecksumErrors"));
            m_sensorRegistry->markCanSensorActive(QStringLiteral("PTCanTxErrors"));
            m_sensorRegistry->markCanSensorActive(QStringLiteral("PTRelayFollowerMask"));
            m_sensorRegistry->markCanSensorActive(QStringLiteral("PTRelayInvertMask"));
            m_sensorRegistry->markCanSensorActive(QStringLiteral("PTRelayBoundTargetsPacked"));
        }
        if (ioStatusChanged)
            emit ioStatusChanged();
    } else if (frameId == m_ledAddress) {
        const int systemR = static_cast<unsigned char>(payload[0]);
        const int systemG = static_cast<unsigned char>(payload[1]);
        const int systemB = static_cast<unsigned char>(payload[2]);
        const int systemPattern = static_cast<unsigned char>(payload[3]);
        const int startR = static_cast<unsigned char>(payload[4]);
        const int startG = static_cast<unsigned char>(payload[5]);
        const int startB = static_cast<unsigned char>(payload[6]);
        const int startPattern = static_cast<unsigned char>(payload[7]);
        bool changed = false;
        if (m_systemLedR != systemR) {
            m_systemLedR = systemR;
            changed = true;
        }
        if (m_systemLedG != systemG) {
            m_systemLedG = systemG;
            changed = true;
        }
        if (m_systemLedB != systemB) {
            m_systemLedB = systemB;
            changed = true;
        }
        if (m_systemLedPattern != systemPattern) {
            m_systemLedPattern = systemPattern;
            changed = true;
        }
        if (m_startStopLedR != startR) {
            m_startStopLedR = startR;
            changed = true;
        }
        if (m_startStopLedG != startG) {
            m_startStopLedG = startG;
            changed = true;
        }
        if (m_startStopLedB != startB) {
            m_startStopLedB = startB;
            changed = true;
        }
        if (m_startStopLedPattern != startPattern) {
            m_startStopLedPattern = startPattern;
            changed = true;
        }
        if (changed)
            emit ledStateChanged();
    } else if (frameId == m_indicatorConfigAddress) {
        const int systemMeta = static_cast<unsigned char>(payload[0]);
        const int systemCh1 = static_cast<unsigned char>(payload[1]);
        const int systemCh2 = static_cast<unsigned char>(payload[2]);
        const int systemCh3 = static_cast<unsigned char>(payload[3]);
        const int startMeta = static_cast<unsigned char>(payload[4]);
        const int startCh1 = static_cast<unsigned char>(payload[5]);
        const int startCh2 = static_cast<unsigned char>(payload[6]);
        const int startCh3 = static_cast<unsigned char>(payload[7]);
        bool changed = false;
        if (m_systemIndicatorMeta != systemMeta) {
            m_systemIndicatorMeta = systemMeta;
            changed = true;
        }
        if (m_systemIndicatorCh1 != systemCh1) {
            m_systemIndicatorCh1 = systemCh1;
            changed = true;
        }
        if (m_systemIndicatorCh2 != systemCh2) {
            m_systemIndicatorCh2 = systemCh2;
            changed = true;
        }
        if (m_systemIndicatorCh3 != systemCh3) {
            m_systemIndicatorCh3 = systemCh3;
            changed = true;
        }
        if (m_startStopIndicatorMeta != startMeta) {
            m_startStopIndicatorMeta = startMeta;
            changed = true;
        }
        if (m_startStopIndicatorCh1 != startCh1) {
            m_startStopIndicatorCh1 = startCh1;
            changed = true;
        }
        if (m_startStopIndicatorCh2 != startCh2) {
            m_startStopIndicatorCh2 = startCh2;
            changed = true;
        }
        if (m_startStopIndicatorCh3 != startCh3) {
            m_startStopIndicatorCh3 = startCh3;
            changed = true;
        }
        if (changed)
            emit indicatorConfigChanged();
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
        if (m_digitalInputs)
            m_digitalInputs->setPTActiveCodes(filteredActiveCodes());
        emit activeCodesChanged();
    } else if (m_digitalInputs) {
        m_digitalInputs->setPTActiveCodes(filteredActiveCodes());
    }
}

QVariantList PTExtenderCan::activeCodeDetails() const
{
    QVariantList list;
    const QList<int> codes = parseActiveCodeList();
    for (int code : codes) {
        QVariantMap row;
        row[QStringLiteral("code")] = code;
        row[QStringLiteral("description")] = dfiCodeDescription(code);
        list.append(row);
    }
    return list;
}

QVariantList PTExtenderCan::filteredActiveCodeDetails() const
{
    QVariantList list;
    const QList<int> codes = parseActiveCodeList();
    for (int code : codes) {
        if (isCodeSuppressed(code))
            continue;
        QVariantMap row;
        row[QStringLiteral("code")] = code;
        row[QStringLiteral("description")] = dfiCodeDescription(code);
        list.append(row);
    }
    return list;
}

QString PTExtenderCan::filteredActiveCodes() const
{
    QStringList codes;
    const QList<int> allCodes = parseActiveCodeList();
    for (int code : allCodes) {
        if (!isCodeSuppressed(code))
            codes << QString::number(code);
    }
    return codes.join(QStringLiteral(","));
}

int PTExtenderCan::filteredActiveCodeCount() const
{
    int count = 0;
    const QList<int> allCodes = parseActiveCodeList();
    for (int code : allCodes) {
        if (!isCodeSuppressed(code))
            ++count;
    }
    return count;
}

QString PTExtenderCan::dfiCodeDescription(int code)
{
    for (const DfiCodeDesc &entry : kDfiCodeDescriptions) {
        if (entry.code == code)
            return QString::fromLatin1(entry.description);
    }
    return QStringLiteral("Unknown");
}

QList<int> PTExtenderCan::parseActiveCodeList() const
{
    QList<int> codes;
    if (m_activeCodes.trimmed().isEmpty())
        return codes;

    const QStringList parts = m_activeCodes.split(',', Qt::SkipEmptyParts);
    for (const QString &part : parts) {
        bool ok = false;
        const int code = part.trimmed().toInt(&ok);
        if (ok && code > 0)
            codes.append(code);
    }
    return codes;
}

bool PTExtenderCan::isCodeSuppressed(int code) const
{
    return m_configManager && m_configManager->isCodeSuppressed(code);
}
