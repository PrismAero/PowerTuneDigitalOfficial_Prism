/**
 * @file ConnectionData.cpp
 * @brief Implementation of ConnectionData model
 */

#include "ConnectionData.h"

ConnectionData::ConnectionData(QObject *parent)
    : QObject(parent)
{
}

// * Setters - Serial status
void ConnectionData::setSerialStat(const QString &SerialStat)
{
    if (m_SerialStat == SerialStat)
        return;
    m_SerialStat = SerialStat;
    emit serialStatChanged(m_SerialStat);
}

void ConnectionData::setSerialSpeed(const qreal &SerialSpeed)
{
    if (m_SerialSpeed == SerialSpeed)
        return;
    m_SerialSpeed = SerialSpeed;
    emit serialSpeedChanged(m_SerialSpeed);
}

void ConnectionData::setRecvData(const QString &RecvData)
{
    if (m_RecvData == RecvData)
        return;
    m_RecvData = RecvData;
    emit recvDataChanged(m_RecvData);
}

void ConnectionData::setTimeoutStat(const QString &TimeoutStat)
{
    if (m_TimeoutStat == TimeoutStat)
        return;
    m_TimeoutStat = TimeoutStat;
    emit timeoutStatChanged(m_TimeoutStat);
}

void ConnectionData::setRunStat(const QString &RunStat)
{
    if (m_RunStat == RunStat)
        return;
    m_RunStat = RunStat;
    emit runStatChanged(m_RunStat);
}

// * Setters - Network status
void ConnectionData::setWifiStat(const QString &WifiStat)
{
    if (m_WifiStat == WifiStat)
        return;
    m_WifiStat = WifiStat;
    emit WifiStatChanged(m_WifiStat);
}

void ConnectionData::setEthernetStat(const QString &EthernetStat)
{
    if (m_EthernetStat == EthernetStat)
        return;
    m_EthernetStat = EthernetStat;
    emit EthernetStatChanged(m_EthernetStat);
}

// * Setters - Platform
void ConnectionData::setPlatform(const QString &Platform)
{
    if (m_Platform == Platform)
        return;
    m_Platform = Platform;
    emit platformChanged(m_Platform);
}

// * Setters - Available interfaces
void ConnectionData::setwifi(const QStringList &wifi)
{
    if (m_wifi == wifi)
        return;
    m_wifi = wifi;
    emit wifiChanged(m_wifi);
}

void ConnectionData::setcan(const QStringList &can)
{
    if (m_can == can)
        return;
    m_can = can;
    emit canChanged(m_can);
}

// * Setters - ECU status
void ConnectionData::setecu(int ecu)
{
    if (m_ecu == ecu)
        return;
    m_ecu = ecu;
    emit ecuChanged(m_ecu);
}

void ConnectionData::setsupportedReg(int supportedReg)
{
    if (m_supportedReg == supportedReg)
        return;
    m_supportedReg = supportedReg;
    emit supportedRegChanged(m_supportedReg);
}

// * Setters - Error state
void ConnectionData::setError(const QString &Error)
{
    if (m_Error == Error)
        return;
    m_Error = Error;
    emit ErrorChanged(m_Error);
}

// * Setters - External speed connection
void ConnectionData::setexternalspeedconnectionrequest(int externalspeedconnectionrequest)
{
    if (m_externalspeedconnectionrequest == externalspeedconnectionrequest)
        return;
    m_externalspeedconnectionrequest = externalspeedconnectionrequest;
    emit externalspeedconnectionrequestChanged(m_externalspeedconnectionrequest);
}

void ConnectionData::setexternalspeedport(const QString &externalspeedport)
{
    if (m_externalspeedport == externalspeedport)
        return;
    m_externalspeedport = externalspeedport;
    emit externalspeedportChanged(m_externalspeedport);
}

// * Setters - Media path
void ConnectionData::setmusicpath(const QString &musicpath)
{
    if (m_musicpath == musicpath)
        return;
    m_musicpath = musicpath;
    emit musicpathChanged(m_musicpath);
}
