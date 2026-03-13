#ifndef EXBOARDCAN_H
#define EXBOARDCAN_H

#include "../../Can/CanInterface.h"

#include <QByteArray>
#include <QCanBusFrame>
#include <QMetaObject>
#include <QString>
#include <QVariantMap>
#include <QVector>

class CanTransport;
class DigitalInputs;
class ExpanderBoardData;
class EngineData;
class SettingsData;
class VehicleData;
class ConnectionData;
class SteinhartCalculator;
class SensorRegistry;
class DiagnosticsProvider;

static constexpr int EX_ANALOG_CHANNELS = 8;
static constexpr int EX_BOARD_BACKEND_ID = 5;

struct ChannelCalibration
{
    qreal val0v = 0.0;
    qreal val5v = 5.0;
    bool ntcEnabled = false;
};

struct GearVoltageConfig
{
    bool enabled = false;
    int port = 0;
    double tolerance = 0.2;
    double voltageN = 0.0;
    double voltageR = 0.5;
    double voltage1 = 1.0;
    double voltage2 = 1.5;
    double voltage3 = 2.0;
    double voltage4 = 2.5;
    double voltage5 = 3.0;
    double voltage6 = 3.5;
};

struct SpeedSensorConfig
{
    bool enabled = false;
    QString sourceType = QStringLiteral("analog");
    int analogPort = 0;
    int digitalPort = 0;
    double pulsesPerRev = 4.0;
    double voltageMultiplier = 1.0;
    double tireCircumference = 2.06;
    double finalDriveRatio = 1.0;
    QString unit = QStringLiteral("MPH");
};

class ExBoardCan : public CanInterface
{
    Q_OBJECT
    Q_PROPERTY(int extenderBaseId READ extenderBaseId NOTIFY baseIdsChanged)
    Q_PROPERTY(int rpmBaseId READ rpmBaseId NOTIFY baseIdsChanged)

public:
    explicit ExBoardCan(QObject *parent = nullptr);
    explicit ExBoardCan(DigitalInputs *digitalInputs, ExpanderBoardData *expanderBoardData, EngineData *engineData,
                        SettingsData *settingsData, VehicleData *vehicleData, ConnectionData *connectionData,
                        QObject *parent = nullptr);
    ~ExBoardCan() override;

    QString moduleName() const override;
    int moduleBackendId() const override;
    void configureConnection(const QVariantMap &config) override;
    void attachTransport(CanTransport *transport) override;
    void detachTransport() override;

    int extenderBaseId() const { return static_cast<int>(m_canBaseAddress); }
    int rpmBaseId() const { return static_cast<int>(m_address5 > 0 ? m_address5 - 1 : 0); }

    void setSteinhartCalculator(SteinhartCalculator *calc);
    void setSensorRegistry(SensorRegistry *reg) { m_sensorRegistry = reg; }
    void setDiagnosticsProvider(DiagnosticsProvider *diag) { m_diagnosticsProvider = diag; }
    void connectCalibrationSignals();

    Q_INVOKABLE void setGearVoltageConfig(const QVariantMap &config);
    GearVoltageConfig gearVoltageConfig() const { return m_gearConfig; }

    Q_INVOKABLE void setSpeedSensorConfig(const QVariantMap &config);
    SpeedSensorConfig speedSensorConfig() const { return m_speedConfig; }

public slots:
    void openCAN(const int &extenderBaseId, const int &rpmBaseId);
    void closeConnection();
    Q_INVOKABLE void setChannelCalibration(int channel, qreal val0v, qreal val5v, bool ntcEnabled);

signals:
    void baseIdsChanged();
    void NewCanFrameReceived(int canId, QString payload);
    void Newtestsignal();

private slots:
    void onFrameReceived(const QCanBusFrame &frame);

private:
    void applyCalibration(int channel, qreal voltage);
    QString byteArrayToHex(const QByteArray &byteArray) const;
    int voltageToGear(double voltage) const;
    void onGearPortVoltageChanged();
    void onSpeedSourceChanged();

    CanTransport *m_transport = nullptr;
    DigitalInputs *m_digitalInputs = nullptr;
    ExpanderBoardData *m_expanderBoardData = nullptr;
    EngineData *m_engineData = nullptr;
    SettingsData *m_settingsData = nullptr;
    VehicleData *m_vehicleData = nullptr;
    ConnectionData *m_connectionData = nullptr;
    SteinhartCalculator *m_steinhartCalc = nullptr;
    SensorRegistry *m_sensorRegistry = nullptr;
    DiagnosticsProvider *m_diagnosticsProvider = nullptr;

    double pkgpayload[8] = {};
    struct payload
    {
        quint16 CH1;
        quint16 CH2;
        quint16 CH3;
        quint16 CH4;
        payload parse(const QByteArray &);
    };

    int m_units = 0;
    quint32 m_canBaseAddress = 0;
    quint32 m_address1 = 0;
    quint32 m_address2 = 0;
    quint32 m_address3 = 0;
    quint32 m_address5 = 0;
    QVector<int> m_hzAverage;
    qreal m_avgHz = 0;

    ChannelCalibration m_calibration[EX_ANALOG_CHANNELS];
    GearVoltageConfig m_gearConfig;
    SpeedSensorConfig m_speedConfig;
    QMetaObject::Connection m_gearConnection;
    QMetaObject::Connection m_speedConnection;
};

#endif  // EXBOARDCAN_H
