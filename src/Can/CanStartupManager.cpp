#include "CanStartupManager.h"

#ifdef Q_OS_LINUX
    #include <QProcess>
    #include <QStandardPaths>
#endif

CanStartupManager::CanStartupManager(QObject *parent) : QObject(parent) {}

bool CanStartupManager::prepareInterface(const QString &interfaceName, int bitrate)
{
    if (interfaceName.isEmpty()) {
        setLastError(QStringLiteral("CAN interface name is empty"));
        return false;
    }

    if (bitrate <= 0) {
        setLastError(QStringLiteral("Invalid CAN bitrate"));
        return false;
    }

#ifdef Q_OS_LINUX
    QString output;
    if (!runIpCommand({QStringLiteral("link"), QStringLiteral("show"), interfaceName}, &output)) {
        setLastError(QStringLiteral("CAN interface %1 was not found").arg(interfaceName));
        return false;
    }

    runIpCommand({QStringLiteral("link"), QStringLiteral("set"), interfaceName, QStringLiteral("down")});

    if (!runIpCommand({QStringLiteral("link"),
                       QStringLiteral("set"),
                       interfaceName,
                       QStringLiteral("type"),
                       QStringLiteral("can"),
                       QStringLiteral("bitrate"),
                       QString::number(bitrate)})) {
        setLastError(QStringLiteral("Failed to set %1 bitrate to %2").arg(interfaceName).arg(bitrate));
        return false;
    }

    if (!runIpCommand({QStringLiteral("link"), QStringLiteral("set"), interfaceName, QStringLiteral("up")})) {
        setLastError(QStringLiteral("Failed to bring %1 up").arg(interfaceName));
        return false;
    }
#else
    Q_UNUSED(interfaceName)
    Q_UNUSED(bitrate)
#endif

    m_lastError.clear();
    emit startupSucceeded(interfaceName);
    return true;
}

QString CanStartupManager::lastError() const
{
    return m_lastError;
}

#ifdef Q_OS_LINUX
bool CanStartupManager::runIpCommand(const QStringList &arguments, QString *output) const
{
    const QString ipBinary = QStandardPaths::findExecutable(QStringLiteral("ip"));
    if (ipBinary.isEmpty())
        return false;

    QProcess process;
    process.start(ipBinary, arguments);
    if (!process.waitForStarted(3000))
        return false;

    if (!process.waitForFinished(5000))
        return false;

    if (output) {
        *output = QString::fromUtf8(process.readAllStandardOutput());
        const QString stderrOutput = QString::fromUtf8(process.readAllStandardError());
        if (!stderrOutput.isEmpty()) {
            if (!output->isEmpty())
                output->append(QLatin1Char('\n'));
            output->append(stderrOutput);
        }
    }

    return process.exitStatus() == QProcess::NormalExit && process.exitCode() == 0;
}
#endif

void CanStartupManager::setLastError(const QString &reason)
{
    m_lastError = reason;
    emit startupFailed(m_lastError);
}
