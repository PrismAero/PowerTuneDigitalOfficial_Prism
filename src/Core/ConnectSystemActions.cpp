#include "Connect.h"

#include "AppSettings.h"
#include "DiagnosticsProvider.h"
#include "Models/ConnectionData.h"

#include <QProcess>

void Connect::changefolderpermission()
{
    QProcess *process = new QProcess(this);
    const QString program = QStringLiteral("sudo");
    const QStringList arguments = {
        QStringLiteral("chown"),
        QStringLiteral("-R"),
        QStringLiteral("root:root"),
        QStringLiteral("/home/root/KTracks"),
    };

    connect(process, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this, [this, process](int, QProcess::ExitStatus) {
        process->deleteLater();
        reboot();
    });
    process->start(program, arguments);
}

void Connect::shutdown()
{
    m_connectionData->setSerialStat(QStringLiteral("Shutting Down"));
    if (m_diagnosticsProvider)
        m_diagnosticsProvider->addLogMessage(QStringLiteral("WARN"), QStringLiteral("System shutdown initiated"));
    if (m_appSettings)
        m_appSettings->sync();
    QProcess::startDetached(QStringLiteral("shutdown"), QStringList() << QStringLiteral("-h") << QStringLiteral("now"));
}

void Connect::reboot()
{
    m_connectionData->setSerialStat(QStringLiteral("Rebooting"));
    if (m_diagnosticsProvider)
        m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"), QStringLiteral("System reboot initiated"));
    if (m_appSettings)
        m_appSettings->sync();
    QProcess::startDetached(QStringLiteral("reboot"), QStringList());
}

void Connect::turnscreen()
{
    m_connectionData->setSerialStat(QStringLiteral("Turning Screen"));
    QProcess *process = new QProcess(this);
    const QString program = QStringLiteral("sudo");
    const QStringList arguments = {
        QStringLiteral("cp"),
        QStringLiteral("/home/root/src/config.txt"),
        QStringLiteral("/boot/config.txt"),
    };

    connect(process, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this, [this, process](int, QProcess::ExitStatus) {
        process->deleteLater();
        reboot();
    });
    process->start(program, arguments);
}
