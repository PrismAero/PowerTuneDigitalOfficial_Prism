/*
 * Copyright (C) 2018 Markus Ippy, Bastian Gschrey,
 * use this program at your own risk.

  \file Extender.cpp
  \brief request and receive messages from Haltech via CAN Haltech CAN Protocol V2
  \author Markus Ippy
 */

#include "Extender.h"

#include "../Core/Models/DigitalInputs.h"
#include "../Core/Models/ExpanderBoardData.h"
#include "../Core/Models/EngineData.h"
#include "../Core/Models/SettingsData.h"
#include "../Core/Models/VehicleData.h"
#include "../Core/Models/ConnectionData.h"
#include "../Utils/SteinhartCalculator.h"

#include <QDebug>
#include <QVector>
#include <QtEndian>
#include <cmath>


static constexpr int STATUS_MASK = 128;
static constexpr int FREQUENCY_MASK = 127;
static constexpr int HZ_AVERAGE_WINDOW = 10;


Extender::Extender(QObject *parent)
    : QObject(parent)
    , m_digitalInputs(nullptr)
    , m_expanderBoardData(nullptr)
    , m_engineData(nullptr)
    , m_settingsData(nullptr)
    , m_vehicleData(nullptr)
    , m_connectionData(nullptr)
    , m_hzAverage(HZ_AVERAGE_WINDOW, 0)
{
}

Extender::Extender(DigitalInputs *digitalInputs,
                   ExpanderBoardData *expanderBoardData,
                   EngineData *engineData,
                   SettingsData *settingsData,
                   VehicleData *vehicleData,
                   ConnectionData *connectionData,
                   QObject *parent)
    : QObject(parent)
    , m_digitalInputs(digitalInputs)
    , m_expanderBoardData(expanderBoardData)
    , m_engineData(engineData)
    , m_settingsData(settingsData)
    , m_vehicleData(vehicleData)
    , m_connectionData(connectionData)
    , m_hzAverage(HZ_AVERAGE_WINDOW, 0)
{
}

Extender::~Extender() {}

void Extender::setSteinhartCalculator(SteinhartCalculator *calc)
{
    m_steinhartCalc = calc;
}

void Extender::connectCalibrationSignals()
{
    if (!m_expanderBoardData)
        return;

    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput0Changed,
            this, [this](qreal v) { applyCalibration(0, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput1Changed,
            this, [this](qreal v) { applyCalibration(1, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput2Changed,
            this, [this](qreal v) { applyCalibration(2, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput3Changed,
            this, [this](qreal v) { applyCalibration(3, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput4Changed,
            this, [this](qreal v) { applyCalibration(4, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput5Changed,
            this, [this](qreal v) { applyCalibration(5, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput6Changed,
            this, [this](qreal v) { applyCalibration(6, v); });
    connect(m_expanderBoardData, &ExpanderBoardData::EXAnalogInput7Changed,
            this, [this](qreal v) { applyCalibration(7, v); });
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
    case 0: m_expanderBoardData->setEXAnalogCalc0(calibrated); break;
    case 1: m_expanderBoardData->setEXAnalogCalc1(calibrated); break;
    case 2: m_expanderBoardData->setEXAnalogCalc2(calibrated); break;
    case 3: m_expanderBoardData->setEXAnalogCalc3(calibrated); break;
    case 4: m_expanderBoardData->setEXAnalogCalc4(calibrated); break;
    case 5: m_expanderBoardData->setEXAnalogCalc5(calibrated); break;
    case 6: m_expanderBoardData->setEXAnalogCalc6(calibrated); break;
    case 7: m_expanderBoardData->setEXAnalogCalc7(calibrated); break;
    }
}

void Extender::openCAN(const int &ExtenderBaseID, const int &RPMCANBaseID)
{
    m_canBaseAddress = ExtenderBaseID;
    m_address1 = m_canBaseAddress + 1;
    m_address2 = m_canBaseAddress + 2;
    m_address3 = m_canBaseAddress + 3;
    m_address5 = RPMCANBaseID + 1;
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
        // CAN frame forwarded to ConnectionData for CanMonitor
        // Can Monitor end
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

        // Wheel Turtle Tire Temperature monitor
        /*
        if(wheelturtle ==1)
        {
            switch (frame.frameId())
            {
            case 1216:  //LF_Tyre: 8 TP_Wheel_Turtle
                if (m_vehicleData) {
                    m_vehicleData->setLF_Tyre_Temp_01(byte0-50);				  //LF_Tyre_Temp_01
                    m_vehicleData->setLF_Tyre_Temp_02(byte1-50);				  //LF_Tyre_Temp_02
                    m_vehicleData->setLF_Tyre_Temp_03(byte2-50);				  //LF_Tyre_Temp_03
                    m_vehicleData->setLF_Tyre_Temp_04(byte3-50);				  //LF_Tyre_Temp_04
                    m_vehicleData->setLF_Tyre_Temp_05(byte4-50);				  //LF_Tyre_Temp_05
                    m_vehicleData->setLF_Tyre_Temp_06(byte5-50);				  //LF_Tyre_Temp_06
                    m_vehicleData->setLF_Tyre_Temp_07(byte6-50);				  //LF_Tyre_Temp_07
                    m_vehicleData->setLF_Tyre_Temp_08(byte7-50);				  //LF_Tyre_Temp_08
                }
                break;
            case 1220:  //RF_Tyre: 8 TP_Wheel_Turtle
                if (m_vehicleData) {
                    m_vehicleData->setRF_Tyre_Temp_01(byte0-50);				  //RF_Tyre_Temp_01
                    m_vehicleData->setRF_Tyre_Temp_02(byte1-50);				  //RF_Tyre_Temp_02
                    m_vehicleData->setRF_Tyre_Temp_03(byte2-50);				  //RF_Tyre_Temp_03
                    m_vehicleData->setRF_Tyre_Temp_04(byte3-50);				  //RF_Tyre_Temp_04
                    m_vehicleData->setRF_Tyre_Temp_05(byte4-50);				  //RF_Tyre_Temp_05
                    m_vehicleData->setRF_Tyre_Temp_06(byte5-50);				  //RF_Tyre_Temp_06
                    m_vehicleData->setRF_Tyre_Temp_07(byte6-50);				  //RF_Tyre_Temp_07
                    m_vehicleData->setRF_Tyre_Temp_08(byte7-50);				  //RF_Tyre_Temp_08
                }
                break;
            case 1224:  //LR_Tyre: 8 TP_Wheel_Turtle
                if (m_vehicleData) {
                    m_vehicleData->setLR_Tyre_Temp_01(byte0-50);				  //LR_Tyre_Temp_01
                    m_vehicleData->setLR_Tyre_Temp_02(byte1-50);				  //LR_Tyre_Temp_02
                    m_vehicleData->setLR_Tyre_Temp_03(byte2-50);				  //LR_Tyre_Temp_03
                    m_vehicleData->setLR_Tyre_Temp_04(byte3-50);				  //LR_Tyre_Temp_04
                    m_vehicleData->setLR_Tyre_Temp_05(byte4-50);				  //LR_Tyre_Temp_05
                    m_vehicleData->setLR_Tyre_Temp_06(byte5-50);				  //LR_Tyre_Temp_06
                    m_vehicleData->setLR_Tyre_Temp_07(byte6-50);				  //LR_Tyre_Temp_07
                    m_vehicleData->setLR_Tyre_Temp_08(byte7-50);				  //LR_Tyre_Temp_08
                }
                break;
            case 1228:  //RR_Tyre: 8 TP_Wheel_Turtle
                if (m_vehicleData) {
                    m_vehicleData->setRR_Tyre_Temp_01(byte0-50);				  //RR_Tyre_Temp_01
                    m_vehicleData->setRR_Tyre_Temp_02(byte1-50);				  //RR_Tyre_Temp_02
                    m_vehicleData->setRR_Tyre_Temp_03(byte2-50);				  //RR_Tyre_Temp_03
                    m_vehicleData->setRR_Tyre_Temp_04(byte3-50);				  //RR_Tyre_Temp_04
                    m_vehicleData->setRR_Tyre_Temp_05(byte4-50);				  //RR_Tyre_Temp_05
                    m_vehicleData->setRR_Tyre_Temp_06(byte5-50);				  //RR_Tyre_Temp_06
                    m_vehicleData->setRR_Tyre_Temp_07(byte6-50);				  //RR_Tyre_Temp_07
                    m_vehicleData->setRR_Tyre_Temp_08(byte7-50);				  //RR_Tyre_Temp_08
                }
                break;
                //No Datasources created yet
            case 1232:  //LF_DistColour: 8 TP_Wheel_Turtle
                // TODO: These setters all use EXDigitalInput1 - likely needs proper property mapping
                if (m_digitalInputs) {
                    m_digitalInputs->setEXDigitalInput1(byte0-50);  //LF_Distance
                    m_digitalInputs->setEXDigitalInput1(byte1-50);  //LF_Colour_R
                    m_digitalInputs->setEXDigitalInput1(byte2-50);  //LF_Colour_G
                    m_digitalInputs->setEXDigitalInput1(byte3-50);  //LF_Colour_B
                    m_digitalInputs->setEXDigitalInput1(byte4-50);  //LF_Colour_Alpha
                }
                break;
            case 1233:  //RF_DistColour: 8 TP_Wheel_Turtle
                if (m_digitalInputs) {
                    m_digitalInputs->setEXDigitalInput1(byte0-50);  //RF_Distance
                    m_digitalInputs->setEXDigitalInput1(byte1-50);  //RF_Colour_R
                    m_digitalInputs->setEXDigitalInput1(byte2-50);  //RF_Colour_G
                    m_digitalInputs->setEXDigitalInput1(byte3-50);  //RF_Colour_B
                    m_digitalInputs->setEXDigitalInput1(byte4-50);  //RF_Colour_Alpha
                }
                break;
            case 1234:  //LR_DistColour: 8 TP_Wheel_Turtle
                if (m_digitalInputs) {
                    m_digitalInputs->setEXDigitalInput1(byte0-50);  //LR_Distance
                    m_digitalInputs->setEXDigitalInput1(byte1-50);  //LR_Colour_R
                    m_digitalInputs->setEXDigitalInput1(byte2-50);  //LR_Colour_G
                    m_digitalInputs->setEXDigitalInput1(byte3-50);  //LR_Colour_B
                    m_digitalInputs->setEXDigitalInput1(byte4-50);  //LR_Colour_Alpha
                }
                break;
            case 1235:  //RR_DistColour: 8 TP_Wheel_Turtle
                if (m_digitalInputs) {
                    m_digitalInputs->setEXDigitalInput1(byte0-50);  //RR_Distance
                    m_digitalInputs->setEXDigitalInput1(byte1-50);  //RR_Colour_R
                    m_digitalInputs->setEXDigitalInput1(byte2-50);  //RR_Colour_G
                    m_digitalInputs->setEXDigitalInput1(byte3-50);  //RR_Colour_B
                    m_digitalInputs->setEXDigitalInput1(byte4-50);  //RR_Colour_Alpha
                }
                break;
            default:
                break;
            }
        }
        */
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
                    m_digitalInputs->setfrequencyDIEX1(
                        qRound((m_avgHz / HZ_AVERAGE_WINDOW) * 16.6 * 60) /
                        m_digitalInputs->RPMFrequencyDividerDi1());
                }
            }
        }

        if (frame.frameId() == m_address2) {
            if (m_expanderBoardData) {
                m_expanderBoardData->setEXAnalogInput0(pkgpayload[0] * 0.001);
                m_expanderBoardData->setEXAnalogInput1(pkgpayload[1] * 0.001);
                m_expanderBoardData->setEXAnalogInput2(pkgpayload[2] * 0.001);
                m_expanderBoardData->setEXAnalogInput3(pkgpayload[3] * 0.001);
            }
        }
        if (frame.frameId() == m_address3) {
            if (m_expanderBoardData) {
                m_expanderBoardData->setEXAnalogInput4(pkgpayload[0] * 0.001);
                m_expanderBoardData->setEXAnalogInput5(pkgpayload[1] * 0.001);
                m_expanderBoardData->setEXAnalogInput6(pkgpayload[2] * 0.001);
                m_expanderBoardData->setEXAnalogInput7(pkgpayload[3] * 0.001);
            }
        }
        if (frame.frameId() == m_address5 && m_engineData && m_settingsData &&
            (m_engineData->Cylinders() / 2) != 0 && m_settingsData->Externalrpm() == 1) {
            m_engineData->setrpm(qRound((pkgpayload[0] * 4) / (m_engineData->Cylinders() / 2)));
        }
    }
}
