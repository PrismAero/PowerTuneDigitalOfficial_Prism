#include "arduino.h"

#include "../Core/connect.h"
#include "../Core/Models/ConnectionData.h"

#include <QByteArrayMatcher>
#include <QDebug>

Arduino::Arduino(QObject *parent) : QObject(parent), m_connectionData(nullptr) {}

Arduino::Arduino(ConnectionData *connectionData, QObject *parent) : QObject(parent), m_connectionData(connectionData) {}

void Arduino::initSerialPort()
{
    m_serialport = new SerialPort(this);
    connect(m_serialport, &QSerialPort::readyRead, this, &Arduino::readyToRead);
    connect(m_serialport, &QSerialPort::errorOccurred, this, &Arduino::handleError);
    m_readData.clear();
    // qDebug("Serial port set for arduino");
}

// function for flushing all serial buffers
void Arduino::clear()
{
    m_serialport->clear();
}


// function to open serial port
void Arduino::openConnection(const QString &portName)
{
    // qDebug()<<"open Arduino  "+portName;

    initSerialPort();
    m_serialport->setPortName(portName);
    m_serialport->setBaudRate(QSerialPort::Baud9600);
    m_serialport->setParity(QSerialPort::NoParity);
    m_serialport->setDataBits(QSerialPort::Data8);
    m_serialport->setStopBits(QSerialPort::OneStop);
    m_serialport->setFlowControl(QSerialPort::NoFlowControl);
    ;

    if (m_serialport->open(QIODevice::ReadWrite) == false) {
        Arduino::closeConnection();
        //   qDebug("no arduino");
    } else {
        //  qDebug("arduino connected");
    }
}
void Arduino::closeConnection()
{
    disconnect(m_serialport, &QSerialPort::readyRead, this, &Arduino::readyToRead);
    disconnect(m_serialport, &QSerialPort::errorOccurred, this, &Arduino::handleError);
    m_serialport->close();
    if (m_connectionData) {
        m_connectionData->setSerialSpeed(0);
    }
}


void Arduino::handleError(QSerialPort::SerialPortError serialPortError)
{
    if (serialPortError == QSerialPort::ReadError) {
        QString fileName = "Errors.txt";
        QFile mFile(fileName);
        if (!mFile.open(QFile::Append | QFile::Text)) {}
        QTextStream out(&mFile);
        out << "Serial Error " << (m_serialport->errorString()) << Qt::endl;
        mFile.close();
        if (m_connectionData) {
            m_connectionData->setSerialStat(m_serialport->errorString());
        }
    }
}


void Arduino::readyToRead()
{
    QByteArray test;
    test = m_readData = m_serialport->readAll();
    /*
    QString fileName = "AdaptronicOutputTest.txt";
    QFile mFile(fileName);
    if(!mFile.open(QFile::Append | QFile::Text)){
    }
    QTextStream out(&mFile);
    out  << (test.toHex()) << Qt::endl;
    mFile.close();*/
    if (m_connectionData) {
        m_connectionData->setSerialStat(test.toHex());
    }
    // qDebug()<< "Arduino"+m_readData;
    Arduino::assemblemessage(m_readData);
}


void Arduino::assemblemessage(const QByteArray &buffer)
{
    m_buffer.append(buffer);
    QByteArray message = m_buffer;
    if (m_buffer.contains("\r\n")) {
        int end = m_buffer.indexOf("\r\n") + 2;
        message.remove(m_buffer.indexOf("\r\n"), end);
        m_buffer.clear();

        bool ok = false;
        float value = message.toFloat(&ok);

        if (!ok) {
            qDebug() << "Conversion failed";
        }

        else {
            if (m_connectionData) {
                m_connectionData->setSerialSpeed(value);
            }
        }
    }
}
