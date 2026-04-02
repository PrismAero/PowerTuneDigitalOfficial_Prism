#include "wifiscanner.h"

#include "../Core/Models/ConnectionData.h"

#include <QByteArray>
#include <QFileDevice>
#include <QFile>
#include <QFileInfo>
#include <QHostAddress>
#include <QNetworkInterface>
#include <QProcess>
#include <QRegularExpression>
#include <QSaveFile>
#include <QTextStream>

namespace {
constexpr int kStatusPollMs = 3000;
constexpr int kVerifyPollMs = 1000;
constexpr int kVerifyTimeoutMs = 20000;
}

WifiScanner::WifiScanner(QObject *parent) : QObject(parent), m_connectionData(nullptr)
{
    m_statusTimer.setInterval(kStatusPollMs);
    connect(&m_statusTimer, &QTimer::timeout, this, &WifiScanner::getconnectionStatus);

    m_verifyPollTimer.setInterval(kVerifyPollMs);
    m_verifyPollTimer.setSingleShot(false);
    connect(&m_verifyPollTimer, &QTimer::timeout, this, &WifiScanner::verifyConnectionStep);

    m_verifyTimeoutTimer.setInterval(kVerifyTimeoutMs);
    m_verifyTimeoutTimer.setSingleShot(true);
    connect(&m_verifyTimeoutTimer, &QTimer::timeout, this, [this]() {
        finishWifiOperation(false, QStringLiteral("Wi-Fi connect timed out"));
    });

    connect(&m_scanProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this,
            [this](int exitCode, QProcess::ExitStatus exitStatus) {
        QStringList ssids;
        if (exitStatus == QProcess::NormalExit && exitCode == 0) {
            const QString output = QString::fromUtf8(m_scanProcess.readAllStandardOutput());
            const QStringList lines = output.split('\n', Qt::SkipEmptyParts);
            for (const QString &line : lines) {
                QString value = line.trimmed();
                if (value.startsWith(QStringLiteral("SSID:")))
                    value = value.mid(5).trimmed();
                if (!value.isEmpty() && !ssids.contains(value))
                    ssids.append(value);
            }
        } else {
            if (m_connectionData)
                m_connectionData->setWifiLastError(QStringLiteral("Scan failed: %1")
                                                       .arg(QString::fromUtf8(m_scanProcess.readAllStandardError())
                                                                .trimmed()));
        }

        if (m_connectionData)
            m_connectionData->setwifi(ssids);

        if (m_operationInProgress)
            finishWifiOperation(exitStatus == QProcess::NormalExit && exitCode == 0,
                                ssids.isEmpty() ? QStringLiteral("Scan complete (no networks)")
                                                : QStringLiteral("Scan complete"));
    });

    connect(&m_commandProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this,
            [this](int exitCode, QProcess::ExitStatus exitStatus) {
        if (exitStatus != QProcess::NormalExit || exitCode != 0) {
            const QString stderrText = QString::fromUtf8(m_commandProcess.readAllStandardError()).trimmed();
            finishWifiOperation(false, stderrText.isEmpty() ? QStringLiteral("Wi-Fi restart command failed")
                                                            : stderrText);
            return;
        }
        runNextCommand();
    });
}


WifiScanner::WifiScanner(ConnectionData *connectionData, QObject *parent)
    : QObject(parent), m_connectionData(connectionData)
{
    m_statusTimer.setInterval(kStatusPollMs);
    connect(&m_statusTimer, &QTimer::timeout, this, &WifiScanner::getconnectionStatus);

    m_verifyPollTimer.setInterval(kVerifyPollMs);
    m_verifyPollTimer.setSingleShot(false);
    connect(&m_verifyPollTimer, &QTimer::timeout, this, &WifiScanner::verifyConnectionStep);

    m_verifyTimeoutTimer.setInterval(kVerifyTimeoutMs);
    m_verifyTimeoutTimer.setSingleShot(true);
    connect(&m_verifyTimeoutTimer, &QTimer::timeout, this, [this]() {
        finishWifiOperation(false, QStringLiteral("Wi-Fi connect timed out"));
    });

    connect(&m_scanProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this,
            [this](int exitCode, QProcess::ExitStatus exitStatus) {
        QStringList ssids;
        if (exitStatus == QProcess::NormalExit && exitCode == 0) {
            const QString output = QString::fromUtf8(m_scanProcess.readAllStandardOutput());
            const QStringList lines = output.split('\n', Qt::SkipEmptyParts);
            for (const QString &line : lines) {
                QString value = line.trimmed();
                if (value.startsWith(QStringLiteral("SSID:")))
                    value = value.mid(5).trimmed();
                if (!value.isEmpty() && !ssids.contains(value))
                    ssids.append(value);
            }
        } else {
            if (m_connectionData)
                m_connectionData->setWifiLastError(QStringLiteral("Scan failed: %1")
                                                       .arg(QString::fromUtf8(m_scanProcess.readAllStandardError())
                                                                .trimmed()));
        }

        if (m_connectionData)
            m_connectionData->setwifi(ssids);

        if (m_operationInProgress)
            finishWifiOperation(exitStatus == QProcess::NormalExit && exitCode == 0,
                                ssids.isEmpty() ? QStringLiteral("Scan complete (no networks)")
                                                : QStringLiteral("Scan complete"));
    });

    connect(&m_commandProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this,
            [this](int exitCode, QProcess::ExitStatus exitStatus) {
        if (exitStatus != QProcess::NormalExit || exitCode != 0) {
            const QString stderrText = QString::fromUtf8(m_commandProcess.readAllStandardError()).trimmed();
            finishWifiOperation(false, stderrText.isEmpty() ? QStringLiteral("Wi-Fi restart command failed")
                                                            : stderrText);
            return;
        }
        runNextCommand();
    });
}


void WifiScanner::initializeWifiscanner()
{
    if (!m_statusTimer.isActive())
        m_statusTimer.start();
    getconnectionStatus();
    scanNetworksAsync();
}

void WifiScanner::shutdownWifiscanner()
{
    m_statusTimer.stop();
    m_verifyPollTimer.stop();
    m_verifyTimeoutTimer.stop();
}


void WifiScanner::getconnectionStatus()
{
    if (!m_connectionData)
        return;

    const QString wlanIp = firstIpv4ForInterface(QStringLiteral("wlan0"));
    m_connectionData->setWifiStat(wlanIp.isEmpty() ? QStringLiteral("NOT CONNECTED") : wlanIp);

    const QString ethIp = firstIpv4ForInterface(QStringLiteral("eth0"));
    m_connectionData->setEthernetStat(ethIp.isEmpty() ? QStringLiteral("NOT CONNECTED") : ethIp);
}

void WifiScanner::setwifi(const QString &country, const QString &ssid1, const QString &psk1, const QString &ssid2,
                          const QString &psk2)
{
    Q_UNUSED(ssid2);
    Q_UNUSED(psk2);

    if (m_operationInProgress) {
        if (m_connectionData)
            m_connectionData->setWifiLastError(QStringLiteral("Wi-Fi operation already in progress"));
        return;
    }

    m_operationInProgress = true;
    if (m_connectionData) {
        m_connectionData->setWifiBusy(true);
        m_connectionData->setWifiLastError(QString());
        m_connectionData->setWifiLastActionMessage(QStringLiteral("Applying Wi-Fi configuration..."));
    }

    QString errorMessage;
    if (!applyWifiConfig(country, ssid1, psk1, &errorMessage)) {
        finishWifiOperation(false, errorMessage);
        return;
    }

    restartWifiStack();
}

void WifiScanner::scanNetworksAsync()
{
    if (m_scanProcess.state() != QProcess::NotRunning)
        m_scanProcess.kill();

    m_operationInProgress = true;
    if (m_connectionData) {
        m_connectionData->setWifiBusy(true);
        m_connectionData->setWifiLastError(QString());
        m_connectionData->setWifiLastActionMessage(QStringLiteral("Scanning Wi-Fi networks..."));
    }
    m_scanProcess.start(QStringLiteral("sh"),
                        QStringList() << QStringLiteral("-c") << QStringLiteral("iw wlan0 scan | grep 'SSID:'"));
}

bool WifiScanner::applyWifiConfig(const QString &country, const QString &ssid, const QString &psk, QString *errorMessage)
{
    if (ssid.trimmed().isEmpty()) {
        if (errorMessage)
            *errorMessage = QStringLiteral("SSID is required");
        return false;
    }
    if (psk.size() < 8 || psk.size() > 63) {
        if (errorMessage)
            *errorMessage = QStringLiteral("Password must be 8 to 63 characters");
        return false;
    }
    if (!isCountryCodeValid(country)) {
        if (errorMessage)
            *errorMessage = QStringLiteral("Invalid country code");
        return false;
    }

    const QString filepath = selectWpaSupplicantPath();
    QSaveFile file(filepath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        if (errorMessage)
            *errorMessage = QStringLiteral("Failed to open Wi-Fi config for writing");
        return false;
    }

    QTextStream out(&file);
    out << "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\n"
        << "update_config=1\n"
        << "country=" << country << "\n"
        << "network={\n"
        << "ssid=\"" << escapeWpaQuoted(ssid) << "\"\n"
        << "psk=\"" << escapeWpaQuoted(psk) << "\"\n"
        << "}\n";

    if (out.status() != QTextStream::Ok) {
        if (errorMessage)
            *errorMessage = QStringLiteral("Failed to write Wi-Fi config");
        return false;
    }

    if (!file.commit()) {
        if (errorMessage)
            *errorMessage = QStringLiteral("Failed to commit Wi-Fi config");
        return false;
    }

    QFile::setPermissions(filepath, QFileDevice::ReadOwner | QFileDevice::WriteOwner);
    return true;
}

void WifiScanner::restartWifiStack()
{
    m_pendingCommands = QStringList()
                        << QStringLiteral(
                               "wpa_cli -i wlan0 reconfigure || systemctl restart wpa_supplicant || systemctl restart "
                               "wpa_supplicant@wlan0")
                        << QStringLiteral("ip link set wlan0 down && ip link set wlan0 up")
                        << QStringLiteral("udhcpc -i wlan0 -n -q || dhclient wlan0 || true");

    if (m_connectionData)
        m_connectionData->setWifiLastActionMessage(QStringLiteral("Restarting Wi-Fi interface..."));
    runNextCommand();
}

void WifiScanner::runNextCommand()
{
    if (m_pendingCommands.isEmpty()) {
        beginConnectionVerification();
        return;
    }

    const QString command = m_pendingCommands.takeFirst();
    m_commandProcess.start(QStringLiteral("sh"), QStringList() << QStringLiteral("-c") << command);
}

void WifiScanner::beginConnectionVerification()
{
    if (m_connectionData)
        m_connectionData->setWifiLastActionMessage(QStringLiteral("Verifying Wi-Fi connection..."));
    m_verifyTimeoutTimer.start();
    m_verifyPollTimer.start();
}

void WifiScanner::verifyConnectionStep()
{
    getconnectionStatus();
    if (isWifiAssociated() && firstIpv4ForInterface(QStringLiteral("wlan0")).size() > 0)
        finishWifiOperation(true, QStringLiteral("Wi-Fi connected"));
}

void WifiScanner::finishWifiOperation(bool success, const QString &message)
{
    m_verifyPollTimer.stop();
    m_verifyTimeoutTimer.stop();
    m_pendingCommands.clear();
    m_operationInProgress = false;

    if (!m_connectionData)
        return;

    m_connectionData->setWifiBusy(false);
    if (success) {
        m_connectionData->setWifiLastError(QString());
        m_connectionData->setWifiLastActionMessage(message);
    } else {
        m_connectionData->setWifiLastError(message);
        m_connectionData->setWifiLastActionMessage(QStringLiteral("Wi-Fi operation failed"));
    }
}

QString WifiScanner::selectWpaSupplicantPath() const
{
    if (QFileInfo::exists(QStringLiteral("/etc/wpa_supplicant/")))
        return QStringLiteral("/etc/wpa_supplicant/wpa_supplicant.conf");
    return QStringLiteral("/etc/wpa_supplicant.conf");
}

QString WifiScanner::firstIpv4ForInterface(const QString &interfaceName) const
{
    const QNetworkInterface iface = QNetworkInterface::interfaceFromName(interfaceName);
    const QList<QNetworkAddressEntry> entries = iface.addressEntries();
    for (const QNetworkAddressEntry &entry : entries) {
        const QHostAddress ip = entry.ip();
        if (ip.protocol() == QAbstractSocket::IPv4Protocol && !ip.isLoopback())
            return ip.toString();
    }
    return QString();
}

QString WifiScanner::escapeWpaQuoted(const QString &value) const
{
    QString escaped = value;
    escaped.replace(QStringLiteral("\\"), QStringLiteral("\\\\"));
    escaped.replace(QStringLiteral("\""), QStringLiteral("\\\""));
    return escaped;
}

bool WifiScanner::isCountryCodeValid(const QString &country) const
{
    static const QRegularExpression regex(QStringLiteral("^[A-Z]{2}$"));
    return regex.match(country).hasMatch();
}

bool WifiScanner::isWifiAssociated() const
{
    QProcess proc;
    proc.start(QStringLiteral("sh"),
               QStringList() << QStringLiteral("-c") << QStringLiteral("iw dev wlan0 link | grep 'Connected to'"));
    if (!proc.waitForFinished(2000))
        return false;
    return proc.exitStatus() == QProcess::NormalExit && proc.exitCode() == 0;
}
