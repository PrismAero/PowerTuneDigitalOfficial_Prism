#ifndef CANMANAGER_H
#define CANMANAGER_H

#include <QHash>
#include <QObject>
#include <QPointer>
#include <QString>
#include <QVariantMap>

class CanInterface;
class CanTransport;

class CanManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString activeModuleName READ activeModuleName NOTIFY activeModuleChanged)

public:
    explicit CanManager(QObject *parent = nullptr);

    void setTransport(CanTransport *transport);
    void registerModule(CanInterface *module);
    bool hasModule(int backendId) const;

    bool activateModule(int backendId, const QVariantMap &config);
    void deactivateModule(int backendId);
    void deactivateAll();
    bool isModuleActive(int backendId) const;

    QString activeModuleName() const;
    QList<CanInterface *> activeModules() const;

signals:
    void activeModuleChanged();
    void activationFailed(const QString &reason);

private:
    QHash<int, QPointer<CanInterface>> m_modules;
    QPointer<CanTransport> m_transport;
    QHash<int, QPointer<CanInterface>> m_activeModules;
};

#endif  // CANMANAGER_H
