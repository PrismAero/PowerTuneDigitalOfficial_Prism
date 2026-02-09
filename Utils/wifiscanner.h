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
    Q_INVOKABLE void setwifi(const QString &country, const QString &ssid1, const QString &psk1, const QString &ssid2,
                             const QString &psk2);

public slots:
    void getconnectionStatus();

private:
    QStandardItemModel *listModel = nullptr;
    ConnectionData *m_connectionData = nullptr;
    QProcess *process = nullptr;
};

#endif  // WIFISCANNER_H
