#ifndef CANTRANSPORT_H
#define CANTRANSPORT_H

#include <QCanBusDevice>
#include <QCanBusFrame>
#include <QObject>
#include <QString>

class CanTransport : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionChanged)
    Q_PROPERTY(QString interfaceName READ interfaceName WRITE setInterfaceName NOTIFY interfaceNameChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY errorOccurred)

public:
    explicit CanTransport(QObject *parent = nullptr);
    ~CanTransport() override;

    bool socketCanAvailable() const;
    QString interfaceName() const;
    void setInterfaceName(const QString &interfaceName);
    QString lastError() const;
    bool isConnected() const;

    bool open();
    void close();
    bool writeFrame(const QCanBusFrame &frame);

signals:
    void frameReceived(const QCanBusFrame &frame);
    void connectionChanged(bool connected);
    void interfaceNameChanged();
    void errorOccurred(const QString &message);

private slots:
    void onFramesReceived();
    void onCanError(QCanBusDevice::CanBusError error);

private:
    void setLastError(const QString &message);

    QCanBusDevice *m_device = nullptr;
    QString m_interfaceName = QStringLiteral("can0");
    QString m_lastError;
};

#endif  // CANTRANSPORT_H
