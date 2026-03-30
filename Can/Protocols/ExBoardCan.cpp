#include "ExBoardCan.h"

#include "../../Can/CanTransport.h"
#include "../../Core/DiagnosticsProvider.h"
#include "../../Core/Models/ConnectionData.h"
#include "../../Core/Models/DigitalInputs.h"
#include "../../Core/Models/EngineData.h"
#include "../../Core/Models/ExpanderBoardData.h"
#include "../../Core/Models/SettingsData.h"
#include "../../Core/Models/VehicleData.h"
#include "../../Core/SensorRegistry.h"
#include "../../Utils/SteinhartCalculator.h"

#include <QtEndian>

#include <algorithm>
#include <cmath>

static constexpr int STATUS_MASK = 128;
static constexpr int FREQUENCY_MASK = 127;
static constexpr int HZ_AVERAGE_WINDOW = 10;
static constexpr double DI1_FREQUENCY_SCALE = 16.6666667;

ExBoardCan::ExBoardCan(QObject *parent) : CanInterface(parent), m_hzAverage(HZ_AVERAGE_WINDOW, 0) {}

ExBoardCan::ExBoardCan(DigitalInputs *digitalInputs, ExpanderBoardData *expanderBoardData, EngineData *engineData,
                       SettingsData *settingsData, VehicleData *vehicleData, ConnectionData *connectionData,
                       QObject *parent)
    : CanInterface(parent),
      m_digitalInputs(digitalInputs),
      m_expanderBoardData(expanderBoardData),
      m_engineData(engineData),
      m_settingsData(settingsData),
      m_vehicleData(vehicleData),
      m_connectionData(connectionData),
      m_hzAverage(HZ_AVERAGE_WINDOW, 0)
{}

ExBoardCan::~ExBoardCan()
{
    detachTransport();
}

QString ExBoardCan::moduleName() const
{
    return QStringLiteral("ExBoardCan");
}

int ExBoardCan::moduleBackendId() const
{
    return EX_BOARD_BACKEND_ID;
}

void ExBoardCan::configureConnection(const QVariantMap &config)
{
    const int canBaseId = config.value(QStringLiteral("canBaseId"), 0).toInt();
    const int rpmBaseId = config.value(QStringLiteral("rpmBaseId"), 0).toInt();
    m_canBaseAddress = static_cast<quint32>(canBaseId);
    m_address1 = m_canBaseAddress + 1;
    m_address2 = m_canBaseAddress + 2;
    m_address3 = m_canBaseAddress + 3;
    m_address5 = static_cast<quint32>(rpmBaseId) + 1;
    emit baseIdsChanged();
}

void ExBoardCan::attachTransport(CanTransport *transport)
{
    if (m_transport == transport)
        return;

    detachTransport();
    m_transport = transport;
    if (m_transport) {
        connect(m_transport, &CanTransport::frameReceived, this, &ExBoardCan::onFrameReceived);
    }
}

void ExBoardCan::detachTransport()
{
    if (!m_transport)
        return;

    disconnect(m_transport, nullptr, this, nullptr);
    m_transport = nullptr;
}

void ExBoardCan::setSteinhartCalculator(SteinhartCalculator *calc)
{
    m_steinhartCalc = calc;
}

void ExBoardCan::connectCalibrationSignals()
{
    if (!m_expanderBoardData)
        return;

    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput0Changed, this,
            [this](qreal v) { applyCalibration(0, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput1Changed, this,
            [this](qreal v) { applyCalibration(1, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput2Changed, this,
            [this](qreal v) { applyCalibration(2, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput3Changed, this,
            [this](qreal v) { applyCalibration(3, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput4Changed, this,
            [this](qreal v) { applyCalibration(4, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput5Changed, this,
            [this](qreal v) { applyCalibration(5, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput6Changed, this,
            [this](qreal v) { applyCalibration(6, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput7Changed, this,
            [this](qreal v) { applyCalibration(7, v); });
}

void ExBoardCan::openCAN(const int &extenderBaseId, const int &rpmBaseId)
{
    configureConnection({{QStringLiteral("canBaseId"), extenderBaseId}, {QStringLiteral("rpmBaseId"), rpmBaseId}});
}

void ExBoardCan::closeConnection()
{
    detachTransport();
}

void ExBoardCan::setChannelCalibration(int channel, qreal val0v, qreal val5v, bool ntcEnabled,
                                       qreal minVoltage, qreal maxVoltage)
{
    if (channel < 0 || channel >= EX_ANALOG_CHANNELS)
        return;

    m_calibration[channel].val0v = val0v;
    m_calibration[channel].val5v = val5v;
    m_calibration[channel].ntcEnabled = ntcEnabled;
    m_calibration[channel].minVoltage = minVoltage;
    m_calibration[channel].maxVoltage = (maxVoltage > minVoltage) ? maxVoltage : minVoltage + 0.001;
}

void ExBoardCan::applyCalibration(int channel, qreal voltage)
{
    if (!m_expanderBoardData || channel < 0 || channel >= EX_ANALOG_CHANNELS)
        return;

    qreal calibrated = 0.0;
    const auto &cal = m_calibration[channel];

    if (cal.ntcEnabled && m_steinhartCalc && channel < SteinhartCalculator::MAX_CHANNELS) {
        if (m_steinhartCalc->isChannelEnabled(channel) && m_steinhartCalc->isChannelCalibrated(channel)) {
            calibrated = m_steinhartCalc->voltageToTemperature(channel, voltage);
            if (std::isnan(calibrated))
                calibrated = 0.0;
        }
    } else {
        const qreal range = cal.maxVoltage - cal.minVoltage;
        if (range > 0.0) {
            const qreal clamped = std::clamp(voltage, cal.minVoltage, cal.maxVoltage);
            const qreal normalized = (clamped - cal.minVoltage) / range;
            calibrated = cal.val0v + normalized * (cal.val5v - cal.val0v);
        }
    }

    switch (channel) {
    case 0:
        m_expanderBoardData->setEXAnalogCalc0(calibrated);
        break;
    case 1:
        m_expanderBoardData->setEXAnalogCalc1(calibrated);
        break;
    case 2:
        m_expanderBoardData->setEXAnalogCalc2(calibrated);
        break;
    case 3:
        m_expanderBoardData->setEXAnalogCalc3(calibrated);
        break;
    case 4:
        m_expanderBoardData->setEXAnalogCalc4(calibrated);
        break;
    case 5:
        m_expanderBoardData->setEXAnalogCalc5(calibrated);
        break;
    case 6:
        m_expanderBoardData->setEXAnalogCalc6(calibrated);
        break;
    case 7:
        m_expanderBoardData->setEXAnalogCalc7(calibrated);
        break;
    }
}

void ExBoardCan::setGearVoltageConfig(const QVariantMap &config)
{
    m_gearConfig.enabled = config.value(QStringLiteral("enabled"), false).toBool();
    m_gearConfig.port = config.value(QStringLiteral("port"), 0).toInt();
    m_gearConfig.tolerance = config.value(QStringLiteral("tolerance"), 0.2).toDouble();
    m_gearConfig.voltageN = config.value(QStringLiteral("voltageN"), 0.0).toDouble();
    m_gearConfig.voltageR = config.value(QStringLiteral("voltageR"), 0.5).toDouble();
    m_gearConfig.voltage1 = config.value(QStringLiteral("voltage1"), 1.0).toDouble();
    m_gearConfig.voltage2 = config.value(QStringLiteral("voltage2"), 1.5).toDouble();
    m_gearConfig.voltage3 = config.value(QStringLiteral("voltage3"), 2.0).toDouble();
    m_gearConfig.voltage4 = config.value(QStringLiteral("voltage4"), 2.5).toDouble();
    m_gearConfig.voltage5 = config.value(QStringLiteral("voltage5"), 3.0).toDouble();
    m_gearConfig.voltage6 = config.value(QStringLiteral("voltage6"), 3.5).toDouble();

    if (m_gearConnection)
        disconnect(m_gearConnection);

    if (!m_gearConfig.enabled || !m_expanderBoardData)
        return;

    const int port = m_gearConfig.port;
    auto connectGearSignal = [this, port]() {
        switch (port) {
        case 0:
            return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput0Changed, this,
                           &ExBoardCan::onGearPortVoltageChanged);
        case 1:
            return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput1Changed, this,
                           &ExBoardCan::onGearPortVoltageChanged);
        case 2:
            return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput2Changed, this,
                           &ExBoardCan::onGearPortVoltageChanged);
        case 3:
            return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput3Changed, this,
                           &ExBoardCan::onGearPortVoltageChanged);
        case 4:
            return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput4Changed, this,
                           &ExBoardCan::onGearPortVoltageChanged);
        case 5:
            return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput5Changed, this,
                           &ExBoardCan::onGearPortVoltageChanged);
        case 6:
            return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput6Changed, this,
                           &ExBoardCan::onGearPortVoltageChanged);
        case 7:
            return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput7Changed, this,
                           &ExBoardCan::onGearPortVoltageChanged);
        default:
            return QMetaObject::Connection();
        }
    };

    m_gearConnection = connectGearSignal();
}

int ExBoardCan::voltageToGear(double voltage) const
{
    if (!m_gearConfig.enabled)
        return -2;

    struct GearEntry
    {
        int gear;
        double targetV;
    };

    const GearEntry entries[] = {
        {0, m_gearConfig.voltageN}, {-1, m_gearConfig.voltageR}, {1, m_gearConfig.voltage1}, {2, m_gearConfig.voltage2},
        {3, m_gearConfig.voltage3}, {4, m_gearConfig.voltage4},  {5, m_gearConfig.voltage5}, {6, m_gearConfig.voltage6},
    };

    double bestDelta = m_gearConfig.tolerance + 1.0;
    int bestGear = -2;
    for (const auto &entry : entries) {
        const double delta = std::abs(voltage - entry.targetV);
        if (delta <= m_gearConfig.tolerance && delta < bestDelta) {
            bestDelta = delta;
            bestGear = entry.gear;
        }
    }
    return bestGear;
}

void ExBoardCan::onGearPortVoltageChanged()
{
    if (!m_gearConfig.enabled || !m_expanderBoardData)
        return;

    double voltage = 0.0;
    switch (m_gearConfig.port) {
    case 0:
        voltage = m_expanderBoardData->EXAnalogInput0();
        break;
    case 1:
        voltage = m_expanderBoardData->EXAnalogInput1();
        break;
    case 2:
        voltage = m_expanderBoardData->EXAnalogInput2();
        break;
    case 3:
        voltage = m_expanderBoardData->EXAnalogInput3();
        break;
    case 4:
        voltage = m_expanderBoardData->EXAnalogInput4();
        break;
    case 5:
        voltage = m_expanderBoardData->EXAnalogInput5();
        break;
    case 6:
        voltage = m_expanderBoardData->EXAnalogInput6();
        break;
    case 7:
        voltage = m_expanderBoardData->EXAnalogInput7();
        break;
    default:
        return;
    }

    const int gear = voltageToGear(voltage);
    m_expanderBoardData->setEXGear(gear);
    if (m_vehicleData && gear >= -1)
        m_vehicleData->setGear(gear);
}

void ExBoardCan::setSpeedSensorConfig(const QVariantMap &config)
{
    m_speedConfig.enabled = config.value(QStringLiteral("enabled"), false).toBool();
    m_speedConfig.sourceType = config.value(QStringLiteral("sourceType"), QStringLiteral("analog")).toString();
    m_speedConfig.analogPort = config.value(QStringLiteral("analogPort"), 0).toInt();
    m_speedConfig.digitalPort = config.value(QStringLiteral("digitalPort"), 0).toInt();
    m_speedConfig.pulsesPerRev = config.value(QStringLiteral("pulsesPerRev"), 4.0).toDouble();
    m_speedConfig.voltageMultiplier = config.value(QStringLiteral("voltageMultiplier"), 1.0).toDouble();
    m_speedConfig.tireCircumference = config.value(QStringLiteral("tireCircumference"), 2.06).toDouble();
    m_speedConfig.finalDriveRatio = config.value(QStringLiteral("finalDriveRatio"), 1.0).toDouble();
    m_speedConfig.unit = config.value(QStringLiteral("unit"), QStringLiteral("MPH")).toString();

    if (m_speedConnection)
        disconnect(m_speedConnection);

    if (!m_speedConfig.enabled || !m_expanderBoardData)
        return;

    if (m_speedConfig.sourceType == QLatin1String("analog")) {
        const int port = m_speedConfig.analogPort;
        auto connectSpeedSignal = [this, port]() {
            switch (port) {
            case 0:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput0Changed, this,
                               &ExBoardCan::onSpeedSourceChanged);
            case 1:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput1Changed, this,
                               &ExBoardCan::onSpeedSourceChanged);
            case 2:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput2Changed, this,
                               &ExBoardCan::onSpeedSourceChanged);
            case 3:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput3Changed, this,
                               &ExBoardCan::onSpeedSourceChanged);
            case 4:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput4Changed, this,
                               &ExBoardCan::onSpeedSourceChanged);
            case 5:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput5Changed, this,
                               &ExBoardCan::onSpeedSourceChanged);
            case 6:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput6Changed, this,
                               &ExBoardCan::onSpeedSourceChanged);
            case 7:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput7Changed, this,
                               &ExBoardCan::onSpeedSourceChanged);
            default:
                return QMetaObject::Connection();
            }
        };
        m_speedConnection = connectSpeedSignal();
    } else if (m_digitalInputs) {
        m_speedConnection =
            connect(m_digitalInputs, &DigitalInputs::frequencyDIEX1Changed, this, &ExBoardCan::onSpeedSourceChanged);
    }
}

void ExBoardCan::onSpeedSourceChanged()
{
    if (!m_speedConfig.enabled || !m_expanderBoardData)
        return;

    double speed = 0.0;
    if (m_speedConfig.sourceType == QLatin1String("analog")) {
        double voltage = 0.0;
        switch (m_speedConfig.analogPort) {
        case 0:
            voltage = m_expanderBoardData->EXAnalogInput0();
            break;
        case 1:
            voltage = m_expanderBoardData->EXAnalogInput1();
            break;
        case 2:
            voltage = m_expanderBoardData->EXAnalogInput2();
            break;
        case 3:
            voltage = m_expanderBoardData->EXAnalogInput3();
            break;
        case 4:
            voltage = m_expanderBoardData->EXAnalogInput4();
            break;
        case 5:
            voltage = m_expanderBoardData->EXAnalogInput5();
            break;
        case 6:
            voltage = m_expanderBoardData->EXAnalogInput6();
            break;
        case 7:
            voltage = m_expanderBoardData->EXAnalogInput7();
            break;
        default:
            break;
        }
        speed = voltage * m_speedConfig.voltageMultiplier;
    } else {
        const double frequency = m_digitalInputs ? m_digitalInputs->frequencyDIEX1() : 0.0;
        if (m_speedConfig.pulsesPerRev > 0.0) {
            const double wheelRPM = frequency / m_speedConfig.pulsesPerRev;
            const double wheelSpeedMps = wheelRPM * m_speedConfig.tireCircumference / 60.0;
            const double corrected =
                (m_speedConfig.finalDriveRatio > 0.0) ? wheelSpeedMps / m_speedConfig.finalDriveRatio : wheelSpeedMps;
            speed = (m_speedConfig.unit == QLatin1String("MPH")) ? corrected * 2.23694 : corrected * 3.6;
        }
    }

    m_expanderBoardData->setEXSpeed(speed);
}

QString ExBoardCan::byteArrayToHex(const QByteArray &byteArray) const
{
    QString hexString;
    for (const uchar &byte : byteArray)
        hexString.append(QStringLiteral("%1 ").arg(byte, 2, 16, QChar('0')));
    return hexString.trimmed();
}

void ExBoardCan::onFrameReceived(const QCanBusFrame &frame)
{
    QString canid = QStringLiteral("0x") + QString::number(static_cast<quint32>(frame.frameId()), 16).toUpper();
    const QString payloadHex = byteArrayToHex(frame.payload());
    emit NewCanFrameReceived(static_cast<int>(frame.frameId()), payloadHex);

    if (m_connectionData)
        m_connectionData->setcan({canid, payloadHex});
    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->recordCanFrame(static_cast<quint32>(frame.frameId()), frame.payload());
        m_diagnosticsProvider->recordCanMessage();
    }

    QByteArray splitpayload = frame.payload();
    if (splitpayload.size() < 8)
        splitpayload.append(QByteArray(8 - splitpayload.size(), '\0'));

    payload *info = reinterpret_cast<payload *>(splitpayload.data());
    pkgpayload[0] = qFromLittleEndian(info->CH1);
    pkgpayload[1] = qFromLittleEndian(info->CH2);
    pkgpayload[2] = qFromLittleEndian(info->CH3);
    pkgpayload[3] = qFromLittleEndian(info->CH4);

    const int byte0 = static_cast<unsigned char>(splitpayload[0]);
    const int byte1 = static_cast<unsigned char>(splitpayload[1]);
    const int byte2 = static_cast<unsigned char>(splitpayload[2]);
    const int byte3 = static_cast<unsigned char>(splitpayload[3]);
    const int byte4 = static_cast<unsigned char>(splitpayload[4]);
    const int byte5 = static_cast<unsigned char>(splitpayload[5]);
    const int byte6 = static_cast<unsigned char>(splitpayload[6]);
    const int byte7 = static_cast<unsigned char>(splitpayload[7]);

    if (frame.frameId() == m_address1) {
        if (m_digitalInputs) {
            m_digitalInputs->setEXDigitalInput1((byte0 & STATUS_MASK) > 0);
            m_digitalInputs->setEXDigitalInput2((byte1 & STATUS_MASK) > 0);
            m_digitalInputs->setEXDigitalInput3((byte2 & STATUS_MASK) > 0);
            m_digitalInputs->setEXDigitalInput4((byte3 & STATUS_MASK) > 0);
            m_digitalInputs->setEXDigitalInput5((byte4 & STATUS_MASK) > 0);
            m_digitalInputs->setEXDigitalInput6((byte5 & STATUS_MASK) > 0);
            m_digitalInputs->setEXDigitalInput7((byte6 & STATUS_MASK) > 0);
            m_digitalInputs->setEXDigitalInput8((byte7 & STATUS_MASK) > 0);

            if (m_digitalInputs->DI1RPMEnabled() > 0 && m_digitalInputs->RPMFrequencyDividerDi1() > 0.0) {
                m_hzAverage.removeFirst();
                m_hzAverage.append(byte0 & FREQUENCY_MASK);
                m_avgHz = 0;
                for (int i = 0; i < HZ_AVERAGE_WINDOW; ++i)
                    m_avgHz += m_hzAverage[i];
                const double avgRaw = m_avgHz / HZ_AVERAGE_WINDOW;
                const double rpm =
                    (avgRaw * DI1_FREQUENCY_SCALE * 60.0) / m_digitalInputs->RPMFrequencyDividerDi1();
                m_digitalInputs->setfrequencyDIEX1(qRound(rpm));
            }
        }

        if (m_sensorRegistry) {
            for (int i = 1; i <= 8; ++i)
                m_sensorRegistry->markCanSensorActive(QStringLiteral("EXDigitalInput%1").arg(i));
            if (m_rpmSource == 2)
                m_sensorRegistry->markCanSensorActive(QStringLiteral("frequencyDIEX1"));
            if (m_speedConfig.enabled)
                m_sensorRegistry->markCanSensorActive(QStringLiteral("EXSpeed"));
            if (m_gearConfig.enabled)
                m_sensorRegistry->markCanSensorActive(QStringLiteral("EXGear"));
        }
    }

    if (frame.frameId() == m_address2) {
        if (m_expanderBoardData) {
            m_expanderBoardData->setEXAnalogInput0(pkgpayload[0] * 0.001);
            m_expanderBoardData->setEXAnalogInput1(pkgpayload[1] * 0.001);
            m_expanderBoardData->setEXAnalogInput2(pkgpayload[2] * 0.001);
            m_expanderBoardData->setEXAnalogInput3(pkgpayload[3] * 0.001);
        }
        if (m_sensorRegistry) {
            for (int i = 0; i <= 3; ++i) {
                m_sensorRegistry->markCanSensorActive(QStringLiteral("EXAnalogInput%1").arg(i));
                m_sensorRegistry->markCanSensorActive(QStringLiteral("EXAnalogCalc%1").arg(i));
            }
        }
    }

    if (frame.frameId() == m_address3) {
        if (m_expanderBoardData) {
            m_expanderBoardData->setEXAnalogInput4(pkgpayload[0] * 0.001);
            m_expanderBoardData->setEXAnalogInput5(pkgpayload[1] * 0.001);
            m_expanderBoardData->setEXAnalogInput6(pkgpayload[2] * 0.001);
            m_expanderBoardData->setEXAnalogInput7(pkgpayload[3] * 0.001);
        }
        if (m_sensorRegistry) {
            for (int i = 4; i <= 7; ++i) {
                m_sensorRegistry->markCanSensorActive(QStringLiteral("EXAnalogInput%1").arg(i));
                m_sensorRegistry->markCanSensorActive(QStringLiteral("EXAnalogCalc%1").arg(i));
            }
        }
    }

    if (frame.frameId() == m_address5 && m_engineData && m_rpmSource == 1) {
        const double cylinders = m_engineData->Cylinders();
        if (cylinders > 0.0) {
            m_engineData->setrpm(qRound((pkgpayload[0] * 8.0) / cylinders));
        }
    }
}

void ExBoardCan::setRpmSource(int source)
{
    if (m_rpmConnection)
        disconnect(m_rpmConnection);

    m_rpmSource = source;

    if (source == 2 && m_digitalInputs && m_engineData) {
        m_rpmConnection = connect(m_digitalInputs, &DigitalInputs::frequencyDIEX1Changed, this, [this]() {
            if (m_engineData)
                m_engineData->setrpm(qRound(m_digitalInputs->frequencyDIEX1()));
        });
    }
}
