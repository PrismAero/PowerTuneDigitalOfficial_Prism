#ifndef WIFISCANNER_H
#define WIFISCANNER_H

#include <QList>
#include <QObject>
#include <QProcess>
#include <QStringList>
#include <QTimer>

// * Forward declarations
class ConnectionData;
class QStandardItemModel;

/**
 * @brief WiFi scanner and configuration manager
 *
 * Scans for available WiFi networks and manages wpa_supplicant configuration
 * on Linux/Raspberry Pi systems.
 */
class WifiScanner : public QObject
{
    Q_OBJECT

public:
    explicit WifiScanner(QObject *parent = nullptr);
    explicit WifiScanner(ConnectionData *connectionData, QObject *parent = nullptr);

    int foundCount = 0;
    QStringList wifilist;
    QStringList WiFisList;

    Q_INVOKABLE void initializeWifiscanner();
    Q_INVOKABLE void shutdownWifiscanner();
    Q_INVOKABLE void setwifi(const QString &country, const QString &ssid1, const QString &psk1, const QString &ssid2,
                             const QString &psk2);

public slots:
    void getconnectionStatus();

private:
    void scanNetworksAsync();
    bool applyWifiConfig(const QString &country, const QString &ssid, const QString &psk, QString *errorMessage);
    void restartWifiStack();
    void runNextCommand();
    void beginConnectionVerification();
    void verifyConnectionStep();
    void finishWifiOperation(bool success, const QString &message);
    QString selectWpaSupplicantPath() const;
    QString firstIpv4ForInterface(const QString &interfaceName) const;
    QString escapeWpaQuoted(const QString &value) const;
    bool isCountryCodeValid(const QString &country) const;
    bool isWifiAssociated() const;

    QStandardItemModel *listModel = nullptr;
    ConnectionData *m_connectionData = nullptr;
    QTimer m_statusTimer;
    QProcess m_scanProcess;
    QProcess m_commandProcess;
    QTimer m_verifyPollTimer;
    QTimer m_verifyTimeoutTimer;
    QStringList m_pendingCommands;
    bool m_operationInProgress = false;
};

#endif  // WIFISCANNER_H
