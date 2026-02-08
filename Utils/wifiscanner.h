#ifndef WIFISCANNER_H
#define WIFISCANNER_H

#include <QObject>
#include <QTimer>
#include <QList>
#include <QStringList>
#include <QProcess>

// * Forward declarations
class DashBoard;
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
    explicit WifiScanner(DashBoard *dashboard, QObject *parent = nullptr);

    int foundCount = 0;
    QStringList wifilist;
    QStringList WiFisList;

    Q_INVOKABLE void initializeWifiscanner();
    Q_INVOKABLE void setwifi(const QString &country, const QString &ssid1, const QString &psk1, 
                             const QString &ssid2, const QString &psk2);

public slots:
    void getconnectionStatus();

private:
    QStandardItemModel *listModel = nullptr;
    DashBoard *m_dashboard = nullptr;
    QProcess *process = nullptr;
};

#endif // WIFISCANNER_H
