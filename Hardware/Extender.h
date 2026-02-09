/*
 * Copyright (C) 2016 Markus Ippy, Bastian Gschrey, Jan
 *
 * Digital Gauges for Apexi Power FC for RX7 on Raspberry Pi
 *
 *
 * This software comes under the GPL (GNU Public License)
 * You may freely copy,distribute etc. this as long as the source code
 * is made available for FREE.
 *
 * No warranty is made or implied. You use this program at your own risk.

  \file Extender.h
  \brief request and receive messages from Adaptronic Modular via CANBUS (socketcan
  \author Bastian Gschrey & Markus Ippy
 */

#ifndef Extender_H
#define Extender_H
#include <QCanBus>
#include <QCanBusDevice>
#include <QCanBusFrame>
#include <QObject>


class DigitalInputs;
class ExpanderBoardData;
class EngineData;
class SettingsData;
class VehicleData;
class ConnectionData;

class Extender : public QObject
{
    Q_OBJECT
public:
    explicit Extender(QObject *parent = nullptr);
    explicit Extender(DigitalInputs *digitalInputs,
                      ExpanderBoardData *expanderBoardData,
                      EngineData *engineData,
                      SettingsData *settingsData,
                      VehicleData *vehicleData,
                      ConnectionData *connectionData,
                      QObject *parent = nullptr);
    ~Extender() override;


public slots:
    void openCAN(const int &ExtenderBaseID, const int &RPMCANBaseID);
    void closeConnection();
    void readyToRead();

private:
    QCanBusDevice *m_canDevice;
    QString byteArrayToHex(const QByteArray &byteArray);
    DigitalInputs *m_digitalInputs;
    ExpanderBoardData *m_expanderBoardData;
    EngineData *m_engineData;
    SettingsData *m_settingsData;
    VehicleData *m_vehicleData;
    ConnectionData *m_connectionData;
    double pkgpayload[8];
    struct payload
    {
        quint16 CH1;
        quint16 CH2;
        quint16 CH3;
        quint16 CH4;
        payload parse(const QByteArray &);
    };
    double pkgpayload1[8];
    struct payload1
    {
        quint8 CH10;
        quint8 CH11;
        quint8 CH12;
        quint8 CH13;
        quint8 CH14;
        quint8 CH15;
        quint8 CH16;
        quint8 CH17;
        payload1 parse(const QByteArray &);
    };
    int m_units;


signals:

    void NewCanFrameReceived(int canId, QString payload);
    void Newtestsignal();
};

#endif  // Extender_H
