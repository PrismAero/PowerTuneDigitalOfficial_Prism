#ifndef CANINTERFACE_H
#define CANINTERFACE_H

#include <QObject>
#include <QString>
#include <QVariantMap>

class CanTransport;

class CanInterface : public QObject
{
    Q_OBJECT

public:
    explicit CanInterface(QObject *parent = nullptr) : QObject(parent) {}
    ~CanInterface() override = default;

    virtual QString moduleName() const = 0;
    virtual int moduleBackendId() const = 0;
    virtual void configureConnection(const QVariantMap &config) = 0;
    virtual void attachTransport(CanTransport *transport) = 0;
    virtual void detachTransport() = 0;
};

#endif  // CANINTERFACE_H
