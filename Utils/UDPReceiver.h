/**
 * @file UDPReceiver.h
 * @brief UDP data receiver for PowerTune telemetry
 *
 * Receives UDP packets on port 45454 containing comma-separated data in format "ident,value"
 * and routes data to appropriate domain models (EngineData, VehicleData, etc.)
 *
 * Part of the Dashboard Modularization - Phase 1
 */

#ifndef UDPRECEIVER_H
#define UDPRECEIVER_H

#include <QObject>

// * Forward declarations
class QUdpSocket;
class EngineData;
class VehicleData;
class GPSData;
class AnalogInputs;
class DigitalInputs;
class ExpanderBoardData;
class ElectricMotorData;
class FlagsData;
class SensorData;
class ConnectionData;
class SettingsData;

class udpreceiver : public QObject
{
    Q_OBJECT

public:
    explicit udpreceiver(QObject *parent = nullptr);

    /**
     * @brief Constructor with all model pointers
     * @param engine Engine data model
     * @param vehicle Vehicle data model
     * @param gps GPS data model
     * @param analog Analog inputs model
     * @param digital Digital inputs model
     * @param expander Expander board data model
     * @param motor Electric motor data model
     * @param flags Flags data model
     * @param sensor Sensor data model
     * @param connection Connection data model
     * @param settings Settings data model (for ExternalSpeed check)
     * @param parent Parent QObject
     */
    explicit udpreceiver(
        EngineData *engine,
        VehicleData *vehicle,
        GPSData *gps,
        AnalogInputs *analog,
        DigitalInputs *digital,
        ExpanderBoardData *expander,
        ElectricMotorData *motor,
        FlagsData *flags,
        SensorData *sensor,
        ConnectionData *connection,
        SettingsData *settings,
        QObject *parent = nullptr
    );

private:
    // * Model pointers
    EngineData *m_engine = nullptr;
    VehicleData *m_vehicle = nullptr;
    GPSData *m_gps = nullptr;
    AnalogInputs *m_analog = nullptr;
    DigitalInputs *m_digital = nullptr;
    ExpanderBoardData *m_expander = nullptr;
    ElectricMotorData *m_motor = nullptr;
    FlagsData *m_flags = nullptr;
    SensorData *m_sensor = nullptr;
    ConnectionData *m_connection = nullptr;
    SettingsData *m_settings = nullptr;

    QUdpSocket *udpSocket = nullptr;

public slots:
    void processPendingDatagrams();
    void startreceiver();
    void closeConnection();
};

#endif  // UDPRECEIVER_H
