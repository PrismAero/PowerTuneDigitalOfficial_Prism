// * Speedo - Serial port speed sensor reader
#ifndef SPEEDO_H
#define SPEEDO_H

#include <QObject>
#include <QByteArray>

#include "../Core/serialport.h"

class DashBoard;

class Speedo : public QObject
{
    Q_OBJECT

public:
    explicit Speedo(QObject *parent = nullptr);
    explicit Speedo(DashBoard *dashboard, QObject *parent = nullptr);

    void initSerialPort();
    void openConnection(const QString &portName);

private slots:
    void readyToRead();

private:
    SerialPort *m_serialport = nullptr;
    DashBoard *m_dashboard = nullptr;
    QByteArray m_readData;
};

#endif // SPEEDO_H
