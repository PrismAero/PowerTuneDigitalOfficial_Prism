#ifndef SERIALPORT_H
#define SERIALPORT_H

#include <QSerialPort>

class SerialPort : public QSerialPort
{
    Q_OBJECT
public:
    SerialPort(QObject *parent = nullptr);
    void setParity(const int &parity);
};

#endif  // SERIALPORT_H
