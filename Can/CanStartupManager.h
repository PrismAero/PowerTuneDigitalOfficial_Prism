#ifndef CANSTARTUPMANAGER_H
#define CANSTARTUPMANAGER_H

#include <QObject>
#include <QString>
#include <QStringList>

class CanStartupManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY startupFailed)

public:
    explicit CanStartupManager(QObject *parent = nullptr);

    bool prepareInterface(const QString &interfaceName, int bitrate);
    QString lastError() const;

signals:
    void startupSucceeded(const QString &interfaceName);
    void startupFailed(const QString &reason);

private:
#ifdef Q_OS_LINUX
    bool runIpCommand(const QStringList &arguments, QString *output = nullptr) const;
#endif
    void setLastError(const QString &reason);

    QString m_lastError;
};

#endif  // CANSTARTUPMANAGER_H
