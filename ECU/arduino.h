#ifndef ARDUINO_H
#define ARDUINO_H
#include "serialport.h"

class DashBoard;
class Serialport;
class ConnectionData;

class Arduino : public QObject
{
    Q_OBJECT

public:
    explicit Arduino(QObject *parent = nullptr);
    explicit Arduino(ConnectionData *connectionData, QObject *parent = nullptr);

private:
    ConnectionData *m_connectionData;
    SerialPort *m_serialport;
    QByteArray m_readData;
    QByteArray m_buffer;

public slots:
    // void SetProtocol(const int &protocolselect);
    void readyToRead();
    void handleError(QSerialPort::SerialPortError error);
    void initSerialPort();
    void openConnection(const QString &portName);
    void closeConnection();
    void clear();
    void assemblemessage(const QByteArray &buffer);
};

#endif  // ARDUINO_H
