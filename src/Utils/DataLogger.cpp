#include "DataLogger.h"

#include "../Core/Models/DigitalInputs.h"
#include "../Core/Models/EngineData.h"
#include "../Core/Models/ExpanderBoardData.h"
#include "../Core/Models/TimingData.h"
#include "../Core/Models/VehicleData.h"

#include <QFile>
#include <QTextStream>

namespace {
qreal elapsedMs(const QTime &startTime)
{
    return static_cast<qreal>(startTime.msecsTo(QTime::currentTime()));
}
}

datalogger::datalogger(QObject *parent) : QObject(parent) {}

datalogger::datalogger(EngineData *engineData, VehicleData *vehicleData, ExpanderBoardData *expanderBoardData,
                       DigitalInputs *digitalInputs, TimingData *timingData, QObject *parent)
    : QObject(parent),
      m_engineData(engineData),
      m_vehicleData(vehicleData),
      m_expanderBoardData(expanderBoardData),
      m_digitalInputs(digitalInputs),
      m_timingData(timingData)
{}

void datalogger::startLog(QString logFilename)
{
    if (m_updatetimer.isActive())
        stopLog();

    m_logBasePath = std::move(logFilename);
    m_loggerStartTime = QTime::currentTime();
    createHeader();
    m_logFile.setFileName(m_logBasePath + ".csv");
    if (!m_logFile.open(QFile::Append | QFile::Text))
        return;
    connect(&m_updatetimer, &QTimer::timeout, this, &datalogger::updateLog, Qt::UniqueConnection);
    m_updatetimer.start(200);
}

void datalogger::stopLog()
{
    m_updatetimer.stop();
    if (m_logFile.isOpen())
        m_logFile.close();
}

void datalogger::createHeader()
{
    QFile file(m_logBasePath + ".csv");
    if (!file.open(QFile::WriteOnly | QFile::Text))
        return;

    QTextStream out(&file);
    out << "time_ms,rpm,power,torque,gear,gear_calculation,odo,trip,ex_speed,ex_gear,differential_sensor,"
           "lap_time,best_lap,last_lap,current_lap,"
           "ex_an0,ex_an1,ex_an2,ex_an3,ex_an4,ex_an5,ex_an6,ex_an7,"
           "ex_calc0,ex_calc1,ex_calc2,ex_calc3,ex_calc4,ex_calc5,ex_calc6,ex_calc7,"
           "di1,di2,di3,di4,di5,di6,di7,di8,di1_freq\n";
}

void datalogger::updateLog()
{
    if (!m_logFile.isOpen() && !m_logFile.open(QFile::Append | QFile::Text))
        return;

    QTextStream out(&m_logFile);
    out << elapsedMs(m_loggerStartTime) << ","
        << (m_engineData ? m_engineData->rpm() : 0.0) << ","
        << (m_engineData ? m_engineData->Power() : 0.0) << ","
        << (m_engineData ? m_engineData->Torque() : 0.0) << ","
        << (m_vehicleData ? m_vehicleData->Gear() : 0) << ","
        << (m_vehicleData ? m_vehicleData->GearCalculation() : 0.0) << ","
        << (m_vehicleData ? m_vehicleData->Odo() : 0.0) << ","
        << (m_vehicleData ? m_vehicleData->Trip() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXSpeed() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXGear() : 0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->differentialSensor() : 0.0) << ","
        << (m_timingData ? m_timingData->laptime() : QString()) << ","
        << (m_timingData ? m_timingData->bestlaptime() : QString()) << ","
        << (m_timingData ? m_timingData->Lastlaptime() : QString()) << ","
        << (m_timingData ? m_timingData->currentLap() : 0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput0() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput1() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput2() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput3() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput4() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput5() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput6() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput7() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc0() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc1() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc2() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc3() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc4() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc5() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc6() : 0.0) << ","
        << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc7() : 0.0) << ","
        << (m_digitalInputs ? m_digitalInputs->EXDigitalInput1() : 0) << ","
        << (m_digitalInputs ? m_digitalInputs->EXDigitalInput2() : 0) << ","
        << (m_digitalInputs ? m_digitalInputs->EXDigitalInput3() : 0) << ","
        << (m_digitalInputs ? m_digitalInputs->EXDigitalInput4() : 0) << ","
        << (m_digitalInputs ? m_digitalInputs->EXDigitalInput5() : 0) << ","
        << (m_digitalInputs ? m_digitalInputs->EXDigitalInput6() : 0) << ","
        << (m_digitalInputs ? m_digitalInputs->EXDigitalInput7() : 0) << ","
        << (m_digitalInputs ? m_digitalInputs->EXDigitalInput8() : 0) << ","
        << (m_digitalInputs ? m_digitalInputs->frequencyDIEX1() : 0.0) << "\n";
    m_logFile.flush();
}
