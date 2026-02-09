// * Speedo - Serial port speed sensor reader
#ifndef SPEEDO_H
#define SPEEDO_H

#include "../Core/serialport.h"

#include <QByteArray>
#include <QObject>

class VehicleData;

class Speedo : public QObject
{
    Q_OBJECT

public:
    explicit Speedo(QObject *parent = nullptr);
    explicit Speedo(VehicleData *vehicleData, QObject *parent = nullptr);

    void initSerialPort();
    void openConnection(const QString &portName);

private slots:
    void readyToRead();

private:
    SerialPort *m_serialport = nullptr;
    VehicleData *m_vehicleData = nullptr;
    QByteArray m_readData;
};

#endif  // SPEEDO_H
