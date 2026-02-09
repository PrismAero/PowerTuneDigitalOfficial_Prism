#include "AdaptronicSelect.h"

#include "../Core/appsettings.h"
#include "../Core/connect.h"
#include "../Core/serialport.h"
#include "../Core/Models/EngineData.h"
#include "../Core/Models/VehicleData.h"
#include "../Core/Models/SensorData.h"

#include <QDebug>
#include <QThread>
// #include <QSerialPort>
// #include <QSerialPortInfo>
#include <QModbusRtuSerialMaster>


AdaptronicSelect::AdaptronicSelect(QObject *parent)
    : QObject(parent), m_engineData(nullptr), m_vehicleData(nullptr), m_sensorData(nullptr),
      lastRequest(nullptr), modbusDevice(nullptr)
{}

AdaptronicSelect::~AdaptronicSelect()
{
    if (modbusDevice)
        modbusDevice->disconnectDevice();
    delete modbusDevice;
}

AdaptronicSelect::AdaptronicSelect(EngineData *engineData, VehicleData *vehicleData, SensorData *sensorData,
                                   QObject *parent)
    : QObject(parent), m_engineData(engineData), m_vehicleData(vehicleData),
      m_sensorData(sensorData), lastRequest(nullptr), modbusDevice(nullptr)
{}


// function to open serial port
void AdaptronicSelect::openConnection(const QString &portName)
{
    if (!modbusDevice) {
        modbusDevice = new QModbusRtuSerialMaster(this);
        connect(this, &AdaptronicSelect::sig_adaptronicReadFinished, this, &AdaptronicSelect::AdaptronicStartStream);
        qDebug() << "Modbusdevice created";
    }

    {
        if (modbusDevice->state() != QModbusDevice::ConnectedState) {
            modbusDevice->setConnectionParameter(QModbusDevice::SerialPortNameParameter, portName);
            modbusDevice->setConnectionParameter(QModbusDevice::SerialBaudRateParameter, 57600);
            modbusDevice->setConnectionParameter(QModbusDevice::SerialDataBitsParameter, 8);
            modbusDevice->setConnectionParameter(QModbusDevice::SerialParityParameter, 0);
            modbusDevice->setConnectionParameter(QModbusDevice::SerialStopBitsParameter, 1);
            modbusDevice->setTimeout(200);
            modbusDevice->setNumberOfRetries(10);
            modbusDevice->connectDevice();
            if (modbusDevice->state() != QModbusDevice::ConnectedState) {
                qDebug() << "error creating Modbus device";
                delete modbusDevice;
                modbusDevice = nullptr;
            } else
                AdaptronicSelect::AdaptronicStartStream();
        }
    }
}

void AdaptronicSelect::closeConnection()
{
    if (modbusDevice) {
        modbusDevice->disconnectDevice();
        delete modbusDevice;
        modbusDevice = nullptr;
    }
}


// Adaptronic streaming comms

void AdaptronicSelect::AdaptronicStartStream()
{
    auto *reply = modbusDevice->sendReadRequest(QModbusDataUnit(QModbusDataUnit::HoldingRegisters, 4096, 21),
                                                1);  // read first twenty-one realtime values
    qDebug() << "send :" << ((QModbusDataUnit::HoldingRegisters, 4096, 21), 1);
    if (!reply->isFinished())
        connect(reply, &QModbusReply::finished, this, &AdaptronicSelect::readyToRead);
    else
        delete reply;
}


void AdaptronicSelect::readyToRead()
{
    auto reply = qobject_cast<QModbusReply *>(sender());
    qDebug() << "recieve :" << reply;
    if (!reply)
        return;
    if (reply->error() == QModbusDevice::NoError) {
        const QModbusDataUnit unit = reply->result();
        AdaptronicSelect::decodeAdaptronic(unit);
    }
}

void AdaptronicSelect::decodeAdaptronic(QModbusDataUnit unit)
{
    qreal realBoost;
    int Boostconv;

    // qDebug()<<"Watertemp: " <<unit.value(3);
    // Use domain models
    if (m_vehicleData) {
        m_vehicleData->setSpeed(unit.value(10));  // <-This is for the "main" speedo KMH
        m_vehicleData->setMVSS(unit.value(10));
        m_vehicleData->setSVSS(unit.value(11));
    }
    if (m_engineData) {
        m_engineData->setrpm(unit.value(0));
        m_engineData->setMAP(unit.value(1));
        m_engineData->setIntaketemp(unit.value(2));
        m_engineData->setWatertemp(unit.value(3));
        m_engineData->setAUXT(unit.value(4));
        m_engineData->setKnock(unit.value(6) / 256);
        m_engineData->setTPS(unit.value(7));
        m_engineData->setIdleValue(unit.value(8));
        m_engineData->setBatteryV(unit.value(9) / 10);
        m_engineData->setInj1((unit.value(12) / 3) * 2);
        m_engineData->setInj2((unit.value(13) / 3) * 2);
        m_engineData->setInj3((unit.value(14) / 3) * 2);
        m_engineData->setInj4((unit.value(15) / 3) * 2);
        m_engineData->setIgn1((unit.value(16) / 5));
        m_engineData->setIgn2((unit.value(17) / 5));
        m_engineData->setIgn3((unit.value(18) / 5));
        m_engineData->setIgn4((unit.value(19) / 5));
        m_engineData->setTRIM((unit.value(20)));

        // Convert absolute pressure in KPA to relative pressure mmhg/Kg/cm2

        if ((unit.value(1)) > 103)  // while boost pressure is positive multiply by 0.01 to show kg/cm2
        {
            Boostconv = ((unit.value(1)) - 103);
            realBoost = Boostconv * 0.01;
            // qDebug() << realBoost;
        } else if ((unit.value(1)) < 103)  // while boost pressure is negative  multiply by 0.01 to show kg/cm2
        {
            Boostconv = ((unit.value(1)) - 103) * 7.50061561303;
            realBoost = Boostconv;
        }

        m_engineData->setpim(realBoost);
    }
    if (m_sensorData) {
        m_sensorData->setauxcalc1(unit.value(5) / 2570.00);
    }
    emit sig_adaptronicReadFinished();
}
