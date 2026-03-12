/*
 * Copyright (C) 2018 Markus Ippy, Bastian Gschrey,
 * use this program at your own risk.

  \file Extender.cpp
  \brief request and receive messages from Haltech via CAN Haltech CAN Protocol V2
  \author Markus Ippy
 */

#include "Extender.h"

#include "../Core/Models/ConnectionData.h"
#include "../Core/Models/DigitalInputs.h"
#include "../Core/Models/EngineData.h"
#include "../Core/Models/ExpanderBoardData.h"
#include "../Core/Models/SettingsData.h"
#include "../Core/Models/VehicleData.h"
#include "../Core/DiagnosticsProvider.h"
#include "../Core/SensorRegistry.h"
#include "../Utils/SteinhartCalculator.h"

#include <QDebug>
#include <QVector>
#include <QtEndian>

#include <cmath>


static constexpr int STATUS_MASK = 128;
static constexpr int FREQUENCY_MASK = 127;
static constexpr int HZ_AVERAGE_WINDOW = 10;


Extender::Extender(QObject *parent)
    : QObject(parent),
      m_digitalInputs(nullptr),
      m_expanderBoardData(nullptr),
      m_engineData(nullptr),
      m_settingsData(nullptr),
      m_vehicleData(nullptr),
      m_connectionData(nullptr),
      m_hzAverage(HZ_AVERAGE_WINDOW, 0)
{}

Extender::Extender(DigitalInputs *digitalInputs, ExpanderBoardData *expanderBoardData, EngineData *engineData,
                   SettingsData *settingsData, VehicleData *vehicleData, ConnectionData *connectionData,
                   QObject *parent)
    : QObject(parent),
      m_digitalInputs(digitalInputs),
      m_expanderBoardData(expanderBoardData),
      m_engineData(engineData),
      m_settingsData(settingsData),
      m_vehicleData(vehicleData),
      m_connectionData(connectionData),
      m_hzAverage(HZ_AVERAGE_WINDOW, 0)
{}

Extender::~Extender() {}

void Extender::setSteinhartCalculator(SteinhartCalculator *calc)
{
    m_steinhartCalc = calc;
}

void Extender::connectCalibrationSignals()
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

void Extender::setChannelCalibration(int channel, qreal val0v, qreal val5v, bool ntcEnabled)
{
    if (channel < 0 || channel >= EX_ANALOG_CHANNELS)
        return;
    m_calibration[channel].val0v = val0v;
    m_calibration[channel].val5v = val5v;
    m_calibration[channel].ntcEnabled = ntcEnabled;
}

void Extender::applyCalibration(int channel, qreal voltage)
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
        calibrated = cal.val0v + (voltage / 5.0) * (cal.val5v - cal.val0v);
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

// * Gear voltage sensor methods

void Extender::setGearVoltageConfig(const QVariantMap &config)
{
    m_gearConfig.enabled = config.value("enabled", false).toBool();
    m_gearConfig.port = config.value("port", 0).toInt();
    m_gearConfig.tolerance = config.value("tolerance", 0.2).toDouble();
    m_gearConfig.voltageN = config.value("voltageN", 0.0).toDouble();
    m_gearConfig.voltageR = config.value("voltageR", 0.5).toDouble();
    m_gearConfig.voltage1 = config.value("voltage1", 1.0).toDouble();
    m_gearConfig.voltage2 = config.value("voltage2", 1.5).toDouble();
    m_gearConfig.voltage3 = config.value("voltage3", 2.0).toDouble();
    m_gearConfig.voltage4 = config.value("voltage4", 2.5).toDouble();
    m_gearConfig.voltage5 = config.value("voltage5", 3.0).toDouble();
    m_gearConfig.voltage6 = config.value("voltage6", 3.5).toDouble();

    // Disconnect previous connection and reconnect to the configured port
    if (m_gearConnection)
        disconnect(m_gearConnection);

    if (m_gearConfig.enabled && m_expanderBoardData) {
        int port = m_gearConfig.port;
        auto connectGearSignal = [this, port]() {
            switch (port) {
            case 0:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput0Changed, this,
                               &Extender::onGearPortVoltageChanged);
            case 1:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput1Changed, this,
                               &Extender::onGearPortVoltageChanged);
            case 2:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput2Changed, this,
                               &Extender::onGearPortVoltageChanged);
            case 3:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput3Changed, this,
                               &Extender::onGearPortVoltageChanged);
            case 4:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput4Changed, this,
                               &Extender::onGearPortVoltageChanged);
            case 5:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput5Changed, this,
                               &Extender::onGearPortVoltageChanged);
            case 6:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput6Changed, this,
                               &Extender::onGearPortVoltageChanged);
            case 7:
                return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput7Changed, this,
                               &Extender::onGearPortVoltageChanged);
            default:
                return QMetaObject::Connection();
            }
        };
        m_gearConnection = connectGearSignal();
    }
}

int Extender::voltageToGear(double voltage) const
{
    if (!m_gearConfig.enabled)
        return -2;

    struct GearEntry
    {
        int gear;
        double targetV;
    };
    GearEntry entries[] = {{0, m_gearConfig.voltageN}, {-1, m_gearConfig.voltageR}, {1, m_gearConfig.voltage1},
                           {2, m_gearConfig.voltage2}, {3, m_gearConfig.voltage3},  {4, m_gearConfig.voltage4},
                           {5, m_gearConfig.voltage5}, {6, m_gearConfig.voltage6}};

    double bestDelta = m_gearConfig.tolerance + 1.0;
    int bestGear = -2;

    for (const auto &e : entries) {
        double delta = std::abs(voltage - e.targetV);
        if (delta <= m_gearConfig.tolerance && delta < bestDelta) {
            bestDelta = delta;
            bestGear = e.gear;
        }
    }
    return bestGear;
}

void Extender::onGearPortVoltageChanged()
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

    int gear = voltageToGear(voltage);
    m_expanderBoardData->setEXGear(gear);
}

// * Speed sensor methods

void Extender::setSpeedSensorConfig(const QVariantMap &config)
{
    m_speedConfig.enabled = config.value("enabled", false).toBool();
    m_speedConfig.sourceType = config.value("sourceType", "analog").toString();
    m_speedConfig.analogPort = config.value("analogPort", 0).toInt();
    m_speedConfig.digitalPort = config.value("digitalPort", 0).toInt();
    m_speedConfig.pulsesPerRev = config.value("pulsesPerRev", 4.0).toDouble();
    m_speedConfig.voltageMultiplier = config.value("voltageMultiplier", 1.0).toDouble();
    m_speedConfig.tireCircumference = config.value("tireCircumference", 2.06).toDouble();
    m_speedConfig.finalDriveRatio = config.value("finalDriveRatio", 1.0).toDouble();
    m_speedConfig.unit = config.value("unit", "MPH").toString();

    // Disconnect previous connection and reconnect to the configured source
    if (m_speedConnection)
        disconnect(m_speedConnection);

    if (m_speedConfig.enabled && m_expanderBoardData) {
        if (m_speedConfig.sourceType == "analog") {
            int port = m_speedConfig.analogPort;
            auto connectSpeedSignal = [this, port]() {
                switch (port) {
                case 0:
                    return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput0Changed, this,
                                   &Extender::onSpeedSourceChanged);
                case 1:
                    return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput1Changed, this,
                                   &Extender::onSpeedSourceChanged);
                case 2:
                    return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput2Changed, this,
                                   &Extender::onSpeedSourceChanged);
                case 3:
                    return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput3Changed, this,
                                   &Extender::onSpeedSourceChanged);
                case 4:
                    return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput4Changed, this,
                                   &Extender::onSpeedSourceChanged);
                case 5:
                    return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput5Changed, this,
                                   &Extender::onSpeedSourceChanged);
                case 6:
                    return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput6Changed, this,
                                   &Extender::onSpeedSourceChanged);
                case 7:
                    return connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput7Changed, this,
                                   &Extender::onSpeedSourceChanged);
                default:
                    return QMetaObject::Connection();
                }
            };
            m_speedConnection = connectSpeedSignal();
        } else if (m_digitalInputs) {
            // Digital mode: connect to frequencyDIEX1Changed (currently only DI1 has frequency)
            m_speedConnection =
                connect(m_digitalInputs, &DigitalInputs::frequencyDIEX1Changed, this, &Extender::onSpeedSourceChanged);
        }
    }
}

void Extender::onSpeedSourceChanged()
{
    if (!m_speedConfig.enabled || !m_expanderBoardData)
        return;

    double speed = 0.0;

    if (m_speedConfig.sourceType == "analog") {
        // Get raw voltage from the configured analog port
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
        // Digital mode: frequency from EXDigitalInput (DI1 frequency counter)
        double frequency = m_digitalInputs ? m_digitalInputs->frequencyDIEX1() : 0.0;
        if (m_speedConfig.pulsesPerRev > 0.0) {
            double wheelRPM = frequency / m_speedConfig.pulsesPerRev;
            double wheelSpeedMPS = wheelRPM * m_speedConfig.tireCircumference / 60.0;
            double corrected =
                (m_speedConfig.finalDriveRatio > 0.0) ? wheelSpeedMPS / m_speedConfig.finalDriveRatio : wheelSpeedMPS;

            if (m_speedConfig.unit == "MPH")
                speed = corrected * 2.23694;
            else
                speed = corrected * 3.6;
        }
    }

    m_expanderBoardData->setEXSpeed(speed);
}

void Extender::openCAN(const int &ExtenderBaseID, const int &RPMCANBaseID)
{
    m_canBaseAddress = ExtenderBaseID;
    m_address1 = m_canBaseAddress + 1;
    m_address2 = m_canBaseAddress + 2;
    m_address3 = m_canBaseAddress + 3;
    m_address5 = RPMCANBaseID + 1;
    emit baseIdsChanged();
    if (QCanBus::instance()->plugins().contains(QStringLiteral("socketcan"))) {
        QString errorString;
        m_canDevice =
            QCanBus::instance()->createDevice(QStringLiteral("socketcan"), QStringLiteral("can0"), &errorString);

        if (!m_canDevice) {
            // qDebug() << ("Error creating device");
            return;
        }


        if (m_canDevice->connectDevice()) {
            // qDebug() << m_canDevice->state();
            // qDebug() << m_canDevice;
            //  qDebug() << "device connected!";
            // connect(m_canDevice,SIGNAL(framesReceived()),this,SLOT(readyToRead()));
            connect(m_canDevice, &QCanBusDevice::framesReceived, this, &Extender::readyToRead);
        }
    }
}

void Extender::closeConnection()
{
    if (!m_canDevice)
        return;
    disconnect(m_canDevice, &QCanBusDevice::framesReceived, this, &Extender::readyToRead);
    m_canDevice->disconnectDevice();
}


QString Extender::byteArrayToHex(const QByteArray &byteArray)
{
    QString hexString;
    for (const uchar &byte : byteArray) {
        hexString.append(QString("%1 ").arg(byte, 2, 16, QChar('0')));
    }
    return hexString.trimmed();
}

void Extender::readyToRead()
{
    if (!m_canDevice)
        return;

    while (m_canDevice->framesAvailable()) {
        const QCanBusFrame frame = m_canDevice->readFrame();
        // for the CAN monitor
        QString canid = "0x" + QString::number(static_cast<quint32>(frame.frameId()), 16).toUpper();

        // Convert the payload to a hex string
        QString payloadHex = byteArrayToHex(frame.payload());

        QStringList list = {canid, payloadHex};
        if (m_connectionData) {
            m_connectionData->setcan(list);
        }
        if (m_diagnosticsProvider) {
            m_diagnosticsProvider->recordCanFrame(
                static_cast<quint32>(frame.frameId()), frame.payload());
        }
        // Just for testing  start
        QString view;
        if (frame.frameType() == QCanBusFrame::ErrorFrame)
            view = m_canDevice->interpretErrorFrame(frame);
        else
            view = frame.toString();
        /*
                const QString time = QString::fromLatin1("%1.%2  ")
                        .arg(frame.timeStamp().seconds(), 10, 10, QLatin1Char(' '))
                        .arg(frame.timeStamp().microSeconds() / 100, 4, 10, QLatin1Char('0'));
        // Just for testing  end

        //        qDebug() << time << view;
        */
        // This section decodes the recevied Payload according to the frame ID


        QByteArray splitpayload = frame.payload();
        payload *info = reinterpret_cast<payload *>(splitpayload.data());
        pkgpayload[0] = qFromLittleEndian(info->CH1);
        pkgpayload[1] = qFromLittleEndian(info->CH2);
        pkgpayload[2] = qFromLittleEndian(info->CH3);
        pkgpayload[3] = qFromLittleEndian(info->CH4);
        int byte0 = splitpayload[0];
        int byte1 = splitpayload[1];
        int byte2 = splitpayload[2];
        int byte3 = splitpayload[3];
        int byte4 = splitpayload[4];
        int byte5 = splitpayload[5];
        int byte6 = splitpayload[6];
        int byte7 = splitpayload[7];

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

                if (m_digitalInputs->RPMFrequencyDividerDi1() > 0) {
                    m_hzAverage.removeFirst();
                    m_hzAverage.append(byte0 & FREQUENCY_MASK);
                    m_avgHz = 0;
                    for (int i = 0; i < HZ_AVERAGE_WINDOW; i++) {
                        m_avgHz += m_hzAverage[i];
                    }
                    m_digitalInputs->setfrequencyDIEX1(qRound((m_avgHz / HZ_AVERAGE_WINDOW) * 16.6 * 60) /
                                                       m_digitalInputs->RPMFrequencyDividerDi1());
                }
            }
            if (m_sensorRegistry) {
                for (int i = 1; i <= 8; ++i)
                    m_sensorRegistry->markCanSensorActive(QStringLiteral("EXDigitalInput%1").arg(i));
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
                for (int i = 0; i <= 3; ++i)
                    m_sensorRegistry->markCanSensorActive(QStringLiteral("EXAnalogInput%1").arg(i));
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
                for (int i = 4; i <= 7; ++i)
                    m_sensorRegistry->markCanSensorActive(QStringLiteral("EXAnalogInput%1").arg(i));
            }
        }
        if (frame.frameId() == m_address5 && m_engineData && m_settingsData && (m_engineData->Cylinders() / 2) != 0 &&
            m_settingsData->Externalrpm() == 1) {
            m_engineData->setrpm(qRound((pkgpayload[0] * 4) / (m_engineData->Cylinders() / 2)));
        }
    }
}
