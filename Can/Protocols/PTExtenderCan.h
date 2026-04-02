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
    Q_PROPERTY(int ioState READ ioState NOTIFY ioStatusChanged)
    Q_PROPERTY(int ioFault READ ioFault NOTIFY ioStatusChanged)
    Q_PROPERTY(int dfiChecksumErrors READ dfiChecksumErrors NOTIFY ioStatusChanged)
    Q_PROPERTY(int canTxErrors READ canTxErrors NOTIFY ioStatusChanged)
    Q_PROPERTY(int relayFollowerMask READ relayFollowerMask NOTIFY ioStatusChanged)
    Q_PROPERTY(int relayInvertMask READ relayInvertMask NOTIFY ioStatusChanged)
    Q_PROPERTY(int relayBoundTargetsPacked READ relayBoundTargetsPacked NOTIFY ioStatusChanged)
    Q_PROPERTY(int systemIndicatorMeta READ systemIndicatorMeta NOTIFY indicatorConfigChanged)
    Q_PROPERTY(int startStopIndicatorMeta READ startStopIndicatorMeta NOTIFY indicatorConfigChanged)
    Q_PROPERTY(int systemIndicatorCh1 READ systemIndicatorCh1 NOTIFY indicatorConfigChanged)
    Q_PROPERTY(int systemIndicatorCh2 READ systemIndicatorCh2 NOTIFY indicatorConfigChanged)
    Q_PROPERTY(int systemIndicatorCh3 READ systemIndicatorCh3 NOTIFY indicatorConfigChanged)
    Q_PROPERTY(int startStopIndicatorCh1 READ startStopIndicatorCh1 NOTIFY indicatorConfigChanged)
    Q_PROPERTY(int startStopIndicatorCh2 READ startStopIndicatorCh2 NOTIFY indicatorConfigChanged)
    Q_PROPERTY(int startStopIndicatorCh3 READ startStopIndicatorCh3 NOTIFY indicatorConfigChanged)
    Q_PROPERTY(int systemLedR READ systemLedR NOTIFY ledStateChanged)
    Q_PROPERTY(int systemLedG READ systemLedG NOTIFY ledStateChanged)
    Q_PROPERTY(int systemLedB READ systemLedB NOTIFY ledStateChanged)
    Q_PROPERTY(int systemLedPattern READ systemLedPattern NOTIFY ledStateChanged)
    Q_PROPERTY(int startStopLedR READ startStopLedR NOTIFY ledStateChanged)
    Q_PROPERTY(int startStopLedG READ startStopLedG NOTIFY ledStateChanged)
    Q_PROPERTY(int startStopLedB READ startStopLedB NOTIFY ledStateChanged)
    Q_PROPERTY(int startStopLedPattern READ startStopLedPattern NOTIFY ledStateChanged)

public:
    enum DeviceCommand : int {
        DeviceCommandNop = 0,
        DeviceCommandSaveConfig = 1,
        DeviceCommandResetConfig = 2,
        DeviceCommandReboot = 3
    };
    Q_ENUM(DeviceCommand)

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
    int ioState() const { return m_ioState; }
    int ioFault() const { return m_ioFault; }
    int dfiChecksumErrors() const { return m_dfiChecksumErrors; }
    int canTxErrors() const { return m_canTxErrors; }
    int relayFollowerMask() const { return m_relayFollowerMask; }
    int relayInvertMask() const { return m_relayInvertMask; }
    int relayBoundTargetsPacked() const { return m_relayBoundTargetsPacked; }
    int systemIndicatorMeta() const { return m_systemIndicatorMeta; }
    int startStopIndicatorMeta() const { return m_startStopIndicatorMeta; }
    int systemIndicatorCh1() const { return m_systemIndicatorCh1; }
    int systemIndicatorCh2() const { return m_systemIndicatorCh2; }
    int systemIndicatorCh3() const { return m_systemIndicatorCh3; }
    int startStopIndicatorCh1() const { return m_startStopIndicatorCh1; }
    int startStopIndicatorCh2() const { return m_startStopIndicatorCh2; }
    int startStopIndicatorCh3() const { return m_startStopIndicatorCh3; }
    int systemLedR() const { return m_systemLedR; }
    int systemLedG() const { return m_systemLedG; }
    int systemLedB() const { return m_systemLedB; }
    int systemLedPattern() const { return m_systemLedPattern; }
    int startStopLedR() const { return m_startStopLedR; }
    int startStopLedG() const { return m_startStopLedG; }
    int startStopLedB() const { return m_startStopLedB; }
    int startStopLedPattern() const { return m_startStopLedPattern; }

    void setDiagnosticsProvider(DiagnosticsProvider *diag) { m_diagnosticsProvider = diag; }
    void setSensorRegistry(SensorRegistry *reg) { m_sensorRegistry = reg; }

    Q_INVOKABLE bool sendLedChannelCommand(int channel, int brightness);
    Q_INVOKABLE bool sendStateOverrideCommand(int state, int r, int g, int b, int pattern, int period10ms);
    Q_INVOKABLE bool sendDeviceCommand(int command);
    Q_INVOKABLE bool saveDeviceConfig() { return sendDeviceCommand(DeviceCommandSaveConfig); }
    Q_INVOKABLE bool resetDeviceConfig() { return sendDeviceCommand(DeviceCommandResetConfig); }
    Q_INVOKABLE bool rebootDevice() { return sendDeviceCommand(DeviceCommandReboot); }

signals:
    void baseIdChanged();
    void activeCodesChanged();
    void ioStatusChanged();
    void indicatorConfigChanged();
    void ledStateChanged();
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
    quint32 m_indicatorConfigAddress = 0;
    QString m_activeCodes;
    int m_ioState = 0;
    int m_ioFault = 0;
    int m_dfiChecksumErrors = 0;
    int m_canTxErrors = 0;
    int m_relayFollowerMask = 0;
    int m_relayInvertMask = 0;
    int m_relayBoundTargetsPacked = 0;
    int m_systemIndicatorMeta = 0;
    int m_startStopIndicatorMeta = 0;
    int m_systemIndicatorCh1 = 0;
    int m_systemIndicatorCh2 = 0;
    int m_systemIndicatorCh3 = 0;
    int m_startStopIndicatorCh1 = 0;
    int m_startStopIndicatorCh2 = 0;
    int m_startStopIndicatorCh3 = 0;
    int m_systemLedR = 0;
    int m_systemLedG = 0;
    int m_systemLedB = 0;
    int m_systemLedPattern = 0;
    int m_startStopLedR = 0;
    int m_startStopLedG = 0;
    int m_startStopLedB = 0;
    int m_startStopLedPattern = 0;
};

#endif  // PTEXTENDERCAN_H
