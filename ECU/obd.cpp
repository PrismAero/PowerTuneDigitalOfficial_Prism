/*
 * file obd.cpp
 * Copyright (C) 2018 Markus Ippy
 *
 * Communications class for OBD2 Live readouts
 *
 * No warranty is made or implied. You use this program at your own risk.
 */

#include "obd.h"
#include "../Core/dashboard.h"
#include "../Core/serialport.h"

#include <QDebug>

OBD::OBD(QObject *parent)
    : QObject(parent)
    , m_dashboard(nullptr)
    , m_serial(nullptr)
    , m_ecuList(nullptr)
    , m_bytesWritten(0)
    , m_units(0)
{
}

OBD::OBD(DashBoard *dashboard, QObject *parent)
    : QObject(parent)
    , m_dashboard(dashboard)
    , m_serial(nullptr)
    , m_ecuList(nullptr)
    , m_bytesWritten(0)
    , m_units(0)
{
}

void OBD::clear() const
{
    if (m_serial) {
        m_serial->clear();
    }
}

void OBD::initSerialPort()
{
    m_serial = new SerialPort(this);
    connect(m_serial, &QSerialPort::readyRead, this, &OBD::readyToRead);
    connect(m_serial, &QSerialPort::errorOccurred, this, &OBD::handleError);
    connect(m_serial, &QSerialPort::bytesWritten, this, &OBD::handleBytesWritten);
    connect(&m_timer, &QTimer::timeout, this, &OBD::handleTimeout);
    m_readData.clear();
}

void OBD::openConnection(const QString &portName)
{
    initSerialPort();
    m_serial->setPortName(portName);
    m_serial->setBaudRate(QSerialPort::Baud38400);
    m_serial->setParity(QSerialPort::NoParity);
    m_serial->setDataBits(QSerialPort::Data8);
    m_serial->setStopBits(QSerialPort::OneStop);
    m_serial->setFlowControl(QSerialPort::NoFlowControl);

    if (!m_serial->open(QIODevice::ReadWrite)) {
        qDebug() << "OBD: Failed to open serial port" << portName;
        if (m_dashboard) {
            m_dashboard->setSerialStat("OBD: Connection failed");
        }
    } else {
        qDebug() << "OBD: Connected to" << portName;
        if (m_dashboard) {
            m_dashboard->setSerialStat("OBD: Connected");
        }
    }
}

void OBD::closeConnection()
{
    if (m_serial) {
        disconnect(m_serial, &QSerialPort::readyRead, this, &OBD::readyToRead);
        disconnect(m_serial, &QSerialPort::errorOccurred, this, &OBD::handleError);
        disconnect(m_serial, &QSerialPort::bytesWritten, this, &OBD::handleBytesWritten);
        disconnect(&m_timer, &QTimer::timeout, this, &OBD::handleTimeout);
        m_serial->close();
    }
}

void OBD::writeRequest(QByteArray data)
{
    if (m_serial && m_serial->isOpen()) {
        m_serial->write(data);
    }
}

void OBD::readyToRead()
{
    m_readData.append(m_serial->readAll());
    messageconstructor(m_readData);
}

void OBD::handleTimeout()
{
    qDebug() << "OBD: Timeout";
    m_timer.stop();
}

void OBD::handleBytesWritten(qint64 bytes)
{
    m_bytesWritten += bytes;
}

void OBD::handleError(QSerialPort::SerialPortError error)
{
    if (error == QSerialPort::ReadError) {
        qDebug() << "OBD: Serial read error:" << m_serial->errorString();
        if (m_dashboard) {
            m_dashboard->setSerialStat(m_serial->errorString());
        }
    }
}

void OBD::messageconstructor(const QByteArray &buffer)
{
    // TODO: Implement OBD message parsing
    // ! This is a stub implementation
    Q_UNUSED(buffer)
}

void OBD::sendRequest(int requestIndex)
{
    // TODO: Implement OBD request sending
    // ! This is a stub implementation
    Q_UNUSED(requestIndex)
}

void OBD::readData(QByteArray serialdata)
{
    // TODO: Implement OBD data processing
    // ! This is a stub implementation
    Q_UNUSED(serialdata)
}
