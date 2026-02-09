#ifndef DATALOGGER_H
#define DATALOGGER_H
#include <QObject>
#include <QThread>
#include <QTime>
#include <QTimer>

class datalogger;
class DashBoard;

// Forward declarations for domain models
class EngineData;
class VehicleData;
class GPSData;
class SensorData;
class FlagsData;
class AnalogInputs;
class ExpanderBoardData;
class DigitalInputs;
class ConnectionData;
class TimingData;

class datalogger : public QObject
{
    Q_OBJECT


public:
    explicit datalogger(QObject *parent = nullptr);
    explicit datalogger(DashBoard *dashboard, QObject *parent = nullptr);
    explicit datalogger(
        EngineData *engineData,
        VehicleData *vehicleData,
        GPSData *gpsData,
        SensorData *sensorData,
        FlagsData *flagsData,
        AnalogInputs *analogInputs,
        ExpanderBoardData *expanderBoardData,
        DigitalInputs *digitalInputs,
        ConnectionData *connectionData,
        TimingData *timingData,
        QObject *parent = nullptr
    );
    Q_INVOKABLE void startLog(QString Logfilename);
    Q_INVOKABLE void stopLog();


public slots:

    void updateLog();
    void createHeader();

private:
    DashBoard *m_dashboard = nullptr;
    
    // Domain model pointers
    EngineData *m_engineData = nullptr;
    VehicleData *m_vehicleData = nullptr;
    GPSData *m_gpsData = nullptr;
    SensorData *m_sensorData = nullptr;
    FlagsData *m_flagsData = nullptr;
    AnalogInputs *m_analogInputs = nullptr;
    ExpanderBoardData *m_expanderBoardData = nullptr;
    DigitalInputs *m_digitalInputs = nullptr;
    ConnectionData *m_connectionData = nullptr;
    TimingData *m_timingData = nullptr;
    
    QTimer m_updatetimer;
};

#endif  // DATALOGGER_H
