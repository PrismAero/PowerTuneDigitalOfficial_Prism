#ifndef DATALOGGER_H
#define DATALOGGER_H
#include <QObject>
#include <QFile>
#include <QThread>
#include <QTime>
#include <QTimer>

class datalogger;

class EngineData;
class VehicleData;
class ExpanderBoardData;
class DigitalInputs;
class TimingData;

class datalogger : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(QString logBasePath READ logBasePath NOTIFY logBasePathChanged)


public:
    explicit datalogger(QObject *parent = nullptr);
    explicit datalogger(EngineData *engineData, VehicleData *vehicleData, ExpanderBoardData *expanderBoardData,
                        DigitalInputs *digitalInputs, TimingData *timingData, QObject *parent = nullptr);
    Q_INVOKABLE void startLog(QString Logfilename);
    Q_INVOKABLE void stopLog();
    bool active() const { return m_updatetimer.isActive(); }
    QString logBasePath() const { return m_logBasePath; }


public slots:

    void updateLog();
    void createHeader();

signals:
    void activeChanged(bool active);
    void logBasePathChanged(const QString &logBasePath);

private:
    EngineData *m_engineData = nullptr;
    VehicleData *m_vehicleData = nullptr;
    ExpanderBoardData *m_expanderBoardData = nullptr;
    DigitalInputs *m_digitalInputs = nullptr;
    TimingData *m_timingData = nullptr;

    QTimer m_updatetimer;
    QString m_logBasePath;
    QTime m_loggerStartTime;
    QFile m_logFile;
};

#endif  // DATALOGGER_H
