/**
 * @file ConnectionData.h
 * @brief Communication and connection status data model for PowerTune
 *
 * This class encapsulates communication-related status data including:
 * - Serial status (SerialStat, RecvData, TimeoutStat, RunStat)
 * - Network status (WifiStat, EthernetStat)
 * - Platform identification
 * - Available interfaces (wifi, can)
 * - ECU connection status
 * - Error messages
 *
 * Part of the DashBoard God Object refactoring (Phase 3)
 */

#ifndef CONNECTIONDATA_H
#define CONNECTIONDATA_H

#include <QObject>
#include <QString>
#include <QStringList>

class ConnectionData : public QObject
{
    Q_OBJECT

    // * Serial communication status
    Q_PROPERTY(QString SerialStat READ SerialStat WRITE setSerialStat NOTIFY serialStatChanged)
    Q_PROPERTY(QString RecvData READ RecvData WRITE setRecvData NOTIFY recvDataChanged)
    Q_PROPERTY(QString TimeoutStat READ TimeoutStat WRITE setTimeoutStat NOTIFY timeoutStatChanged)
    Q_PROPERTY(QString RunStat READ RunStat WRITE setRunStat NOTIFY runStatChanged)

    // * Network status
    Q_PROPERTY(QString WifiStat READ WifiStat WRITE setWifiStat NOTIFY WifiStatChanged)
    Q_PROPERTY(QString EthernetStat READ EthernetStat WRITE setEthernetStat NOTIFY EthernetStatChanged)

    // * Platform
    Q_PROPERTY(QString Platform READ Platform WRITE setPlatform NOTIFY platformChanged)

    // * Available interfaces
    Q_PROPERTY(QStringList wifi READ wifi WRITE setwifi NOTIFY wifiChanged)
    Q_PROPERTY(QStringList can READ can WRITE setcan NOTIFY canChanged)

    // * ECU status
    Q_PROPERTY(int ecu READ ecu WRITE setecu NOTIFY ecuChanged)
    Q_PROPERTY(int supportedReg READ supportedReg WRITE setsupportedReg NOTIFY supportedRegChanged)

    // * Error state
    Q_PROPERTY(QString Error READ Error WRITE setError NOTIFY ErrorChanged)

    // * External speed connection
    Q_PROPERTY(int externalspeedconnectionrequest READ externalspeedconnectionrequest WRITE setexternalspeedconnectionrequest NOTIFY externalspeedconnectionrequestChanged)
    Q_PROPERTY(QString externalspeedport READ externalspeedport WRITE setexternalspeedport NOTIFY externalspeedportChanged)

    // * Media path
    Q_PROPERTY(QString musicpath READ musicpath WRITE setmusicpath NOTIFY musicpathChanged)

public:
    explicit ConnectionData(QObject *parent = nullptr);

    // * Getters - Serial status
    QString SerialStat() const { return m_SerialStat; }
    QString RecvData() const { return m_RecvData; }
    QString TimeoutStat() const { return m_TimeoutStat; }
    QString RunStat() const { return m_RunStat; }

    // * Getters - Network status
    QString WifiStat() const { return m_WifiStat; }
    QString EthernetStat() const { return m_EthernetStat; }

    // * Getters - Platform
    QString Platform() const { return m_Platform; }

    // * Getters - Available interfaces
    QStringList wifi() const { return m_wifi; }
    QStringList can() const { return m_can; }

    // * Getters - ECU status
    int ecu() const { return m_ecu; }
    int supportedReg() const { return m_supportedReg; }

    // * Getters - Error state
    QString Error() const { return m_Error; }

    // * Getters - External speed connection
    int externalspeedconnectionrequest() const { return m_externalspeedconnectionrequest; }
    QString externalspeedport() const { return m_externalspeedport; }

    // * Getters - Media path
    QString musicpath() const { return m_musicpath; }

public slots:
    // * Setters - Serial status
    void setSerialStat(const QString &SerialStat);
    void setRecvData(const QString &RecvData);
    void setTimeoutStat(const QString &TimeoutStat);
    void setRunStat(const QString &RunStat);

    // * Setters - Network status
    void setWifiStat(const QString &WifiStat);
    void setEthernetStat(const QString &EthernetStat);

    // * Setters - Platform
    void setPlatform(const QString &Platform);

    // * Setters - Available interfaces
    void setwifi(const QStringList &wifi);
    void setcan(const QStringList &can);

    // * Setters - ECU status
    void setecu(int ecu);
    void setsupportedReg(int supportedReg);

    // * Setters - Error state
    void setError(const QString &Error);

    // * Setters - External speed connection
    void setexternalspeedconnectionrequest(int externalspeedconnectionrequest);
    void setexternalspeedport(const QString &externalspeedport);

    // * Setters - Media path
    void setmusicpath(const QString &musicpath);

signals:
    // * Signals - Serial status
    void serialStatChanged(const QString &SerialStat);
    void recvDataChanged(const QString &RecvData);
    void timeoutStatChanged(const QString &TimeoutStat);
    void runStatChanged(const QString &RunStat);

    // * Signals - Network status
    void WifiStatChanged(const QString &WifiStat);
    void EthernetStatChanged(const QString &EthernetStat);

    // * Signals - Platform
    void platformChanged(const QString &Platform);

    // * Signals - Available interfaces
    void wifiChanged(const QStringList &wifi);
    void canChanged(const QStringList &can);

    // * Signals - ECU status
    void ecuChanged(int ecu);
    void supportedRegChanged(int supportedReg);

    // * Signals - Error state
    void ErrorChanged(const QString &Error);

    // * Signals - External speed connection
    void externalspeedconnectionrequestChanged(int externalspeedconnectionrequest);
    void externalspeedportChanged(const QString &externalspeedport);

    // * Signals - Media path
    void musicpathChanged(const QString &musicpath);

private:
    // * Serial status
    QString m_SerialStat;
    QString m_RecvData;
    QString m_TimeoutStat;
    QString m_RunStat;

    // * Network status
    QString m_WifiStat;
    QString m_EthernetStat;

    // * Platform
    QString m_Platform;

    // * Available interfaces
    QStringList m_wifi;
    QStringList m_can;

    // * ECU status
    int m_ecu = 0;
    int m_supportedReg = 0;

    // * Error state
    QString m_Error;

    // * External speed connection
    int m_externalspeedconnectionrequest = 0;
    QString m_externalspeedport;

    // * Media path
    QString m_musicpath;
};

#endif  // CONNECTIONDATA_H
