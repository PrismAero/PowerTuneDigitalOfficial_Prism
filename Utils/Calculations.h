#ifndef CALCULATIONS_H
#define CALCULATIONS_H
#include <QObject>
#include <QThread>
#include <QTime>
#include <QTimer>

class DashBoard;
class VehicleData;
class EngineData;
class TimingData;
class SettingsData;

class calculations : public QObject
{
    Q_OBJECT


public:
    explicit calculations(QObject *parent = nullptr);
    explicit calculations(DashBoard *dashboard, VehicleData *vehicleData, EngineData *engineData, TimingData *timingData, SettingsData *settingsData, QObject *parent = nullptr);

public slots:
    Q_INVOKABLE void startdragtimer();
    Q_INVOKABLE void startreactiontimer();
    Q_INVOKABLE void qmlrealtime();
    Q_INVOKABLE void stopreactiontimer();
    // Q_INVOKABLE void calculatereactiontime();
    Q_INVOKABLE void readodoandtrip();
    void saveodoandtriptofile();
    void calculate();
    void start();
    void stop();
    void resettrip();


private:
    DashBoard *m_dashboard;
    VehicleData *m_vehicleData;
    EngineData *m_engineData;
    TimingData *m_timingData;
    SettingsData *m_settingsData;
    QTimer m_updatetimer;
    QTimer m_updateodotimer;
    QTimer m_reactiontimer;
    QTimer m_dynotimer;
};


#endif  // CALCULATIONS_H
