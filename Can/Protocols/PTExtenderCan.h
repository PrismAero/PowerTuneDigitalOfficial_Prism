#ifndef PTEXTENDERCAN_H
#define PTEXTENDERCAN_H

#include "../../Can/CanInterface.h"

#include <QCanBusFrame>
#include <QString>
#include <QVariantMap>

class CanTransport;
class DigitalInputs;
class ExpanderBoardData;
class VehicleData;
class ConnectionData;
class DiagnosticsProvider;
class SensorRegistry;

static constexpr int PT_EXTENDER_BACKEND_ID = 6;

class PTExtenderCan : public CanInterface
{
    Q_OBJECT
    Q_PROPERTY(int baseId READ baseId NOTIFY baseIdChanged)
    Q_PROPERTY(QString activeCodes READ activeCodes NOTIFY activeCodesChanged)

public:
    explicit PTExtenderCan(QObject *parent = nullptr);
    explicit PTExtenderCan(DigitalInputs *digitalInputs, ExpanderBoardData *expanderBoardData, VehicleData *vehicleData,
                           ConnectionData *connectionData, QObject *parent = nullptr);
    ~PTExtenderCan() override;

    QString moduleName() const override;
    int moduleBackendId() const override;
    void configureConnection(const QVariantMap &config) override;
    void attachTransport(CanTransport *transport) override;
    void detachTransport() override;

    int baseId() const { return static_cast<int>(m_baseId); }
    QString activeCodes() const { return m_activeCodes; }

    void setDiagnosticsProvider(DiagnosticsProvider *diag) { m_diagnosticsProvider = diag; }
    void setSensorRegistry(SensorRegistry *reg) { m_sensorRegistry = reg; }

    Q_INVOKABLE bool sendLedChannelCommand(int channel, int brightness);
    Q_INVOKABLE bool sendStateOverrideCommand(int state, int r, int g, int b, int pattern, int period10ms);
    Q_INVOKABLE bool sendDeviceCommand(int command);

signals:
    void baseIdChanged();
    void activeCodesChanged();
    void NewCanFrameReceived(int canId, QString payload);
    void Newtestsignal();

private slots:
    void onFrameReceived(const QCanBusFrame &frame);

private:
    QString byteArrayToHex(const QByteArray &byteArray) const;
    bool writeFrame(quint32 id, const QByteArray &payload);
    void updateActiveCodesFromFrame(const QByteArray &payload);

    CanTransport *m_transport = nullptr;
    DigitalInputs *m_digitalInputs = nullptr;
    ExpanderBoardData *m_expanderBoardData = nullptr;
    VehicleData *m_vehicleData = nullptr;
    ConnectionData *m_connectionData = nullptr;
    DiagnosticsProvider *m_diagnosticsProvider = nullptr;
    SensorRegistry *m_sensorRegistry = nullptr;

    quint32 m_baseId = 0;
    quint32 m_statusAddress = 0;
    quint32 m_ioAddress = 0;
    quint32 m_ledAddress = 0;
    QString m_activeCodes;
};

#endif  // PTEXTENDERCAN_H
