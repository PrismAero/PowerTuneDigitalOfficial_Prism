#ifndef GPS_H_
#define GPS_H_
#include "serialport.h"

#include <QElapsedTimer>
#include <QTimer>

class GPSData;
class TimingData;
class Serialport;

class GPS : public QObject
{
    Q_OBJECT

public:
    explicit GPS(QObject *parent = nullptr);
    explicit GPS(GPSData *gpsData, TimingData *timingData, QObject *parent = nullptr);
    Q_INVOKABLE void defineFinishLine(const qreal &Y1, const qreal &X1, const qreal &Y2, const qreal &X2);
    Q_INVOKABLE void defineFinishLine2(const qreal &Y1, const qreal &X1, const qreal &Y2, const qreal &X2);
    Q_INVOKABLE void resetLaptimer();

private:
    GPSData *m_gpsData;
    TimingData *m_timingData;
    SerialPort *m_serialport;
    QByteArray m_readData;
    QByteArray m_buffer;
    QElapsedTimer m_timer;
    QTimer m_timeouttimer;
    QTimer m_reconnecttimer;
    float convertToFloat(const QString &coord, const QString &dir);
    void processGPRMC(const QString &line);
    void checklinecrossed();
    void linecrossed();
    void processGPGGA(const QString &line);
    void processGPVTG(const QString &line);
    void checknewLap();


public slots:
    // void delaytimer();
    void openConnection(const QString &portName, const QString &Baud);
    void ProcessMessage(QByteArray messageline);
    void removeNMEAmsg();
    void setGPSBAUD115();
    void setGPS10HZ();
    void setGPSOnly();
    void closeConnection();
    void clear();

private slots:
    void readyToRead();
    void handleTimeout();
    void handleReconnect();
    void handleError(QSerialPort::SerialPortError error);
    void initSerialPort();
    void logNMEA(const QString &line);

signals:
    void sig_linecrossed();
};

#endif  // GPS_H_
