#include "DataLogger.h"

#include "../Core/dashboard.h"
#include "../Core/Models/EngineData.h"
#include "../Core/Models/VehicleData.h"
#include "../Core/Models/GPSData.h"
#include "../Core/Models/SensorData.h"
#include "../Core/Models/FlagsData.h"
#include "../Core/Models/AnalogInputs.h"
#include "../Core/Models/ExpanderBoardData.h"
#include "../Core/Models/DigitalInputs.h"
#include "../Core/Models/ConnectionData.h"
#include "../Core/Models/TimingData.h"

#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QThread>

// Run this as a thread and update every 50 ms
// still need to find a way to make this configurable
QTime loggerStartT;
QString Log;

datalogger::datalogger(QObject *parent) : QObject(parent), m_dashboard(nullptr) {}
datalogger::datalogger(DashBoard *dashboard, QObject *parent) : QObject(parent), m_dashboard(dashboard) {}
datalogger::datalogger(
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
    QObject *parent
) : QObject(parent),
    m_engineData(engineData),
    m_vehicleData(vehicleData),
    m_gpsData(gpsData),
    m_sensorData(sensorData),
    m_flagsData(flagsData),
    m_analogInputs(analogInputs),
    m_expanderBoardData(expanderBoardData),
    m_digitalInputs(digitalInputs),
    m_connectionData(connectionData),
    m_timingData(timingData)
{}

void datalogger::startLog(QString Logfilename)
{
    connect(&m_updatetimer, &QTimer::timeout, this, &datalogger::updateLog);
    Log = Logfilename;
    loggerStartT = QTime::currentTime();
    m_updatetimer.start(100);
    datalogger::createHeader();
}

void datalogger::stopLog()
{
    m_updatetimer.stop();
}

void datalogger::updateLog()
{
    m_updatetimer.start(50);
    QString filename = Log + ".csv";
    QFile file(filename);

    if (file.open(QIODevice::ReadWrite)) {
        {
            QString fileName = Log + ".csv";
            // qDebug() << Logfile;
            QFile mFile(fileName);
            if (!mFile.open(QFile::Append | QFile::Text)) {}
            QTextStream out(&mFile);

            int ecuValue = m_connectionData ? m_connectionData->ecu() : 0;
            switch (ecuValue) {
            case 0:  ////Apexi ECU
                out << (loggerStartT.msecsTo(QTime::currentTime())) << "," << (m_engineData ? m_engineData->rpm() : 0) << ","
                    << (m_engineData ? m_engineData->Intakepress() : 0) << "," << (m_engineData ? m_engineData->PressureV() : 0) << "," << (m_engineData ? m_engineData->ThrottleV() : 0)
                    << "," << (m_engineData ? m_engineData->Primaryinp() : 0) << "," << (m_engineData ? m_engineData->Fuelc() : 0) << ","
                    << (m_engineData ? m_engineData->Leadingign() : 0) << "," << (m_engineData ? m_engineData->Trailingign() : 0) << "," << (m_engineData ? m_engineData->Fueltemp() : 0)
                    << "," << (m_engineData ? m_engineData->Moilp() : 0) << "," << (m_engineData ? m_engineData->Boosttp() : 0) << "," << (m_engineData ? m_engineData->Boostwg() : 0)
                    << "," << (m_engineData ? m_engineData->Watertemp() : 0) << "," << (m_engineData ? m_engineData->Intaketemp() : 0) << ","
                    << (m_engineData ? m_engineData->Knock() : 0) << "," << (m_engineData ? m_engineData->BatteryV() : 0) << "," << (m_vehicleData ? m_vehicleData->speed() : 0) << ","
                    << (m_engineData ? m_engineData->Iscvduty() : 0) << "," << (m_engineData ? m_engineData->O2volt() : 0) << "," << (m_engineData ? m_engineData->na1() : 0) << ","
                    << (m_engineData ? m_engineData->Secinjpulse() : 0) << "," << (m_engineData ? m_engineData->na2() : 0) << "," << (m_engineData ? m_engineData->InjDuty() : 0) << ","
                    << (m_engineData ? m_engineData->EngLoad() : 0) << "," << (m_engineData ? m_engineData->MAF1V() : 0) << "," << (m_engineData ? m_engineData->MAF2V() : 0) << ","
                    << (m_engineData ? m_engineData->injms() : 0) << "," << (m_engineData ? m_engineData->Inj() : 0) << "," << (m_engineData ? m_engineData->Ign() : 0) << ","
                    << (m_engineData ? m_engineData->Dwell() : 0) << "," << (m_engineData ? m_engineData->BoostPres() : 0) << "," << (m_engineData ? m_engineData->BoostDuty() : 0) << ","
                    << (m_engineData ? m_engineData->MAFactivity() : 0) << "," << (m_engineData ? m_engineData->O2volt_2() : 0) << "," << (m_engineData ? m_engineData->pim() : 0) << ","
                    << (m_sensorData ? m_sensorData->auxcalc1() : 0) << "," << (m_sensorData ? m_sensorData->auxcalc2() : 0) << "," << (m_sensorData ? m_sensorData->sens1() : 0) << ","
                    << (m_sensorData ? m_sensorData->sens2() : 0) << "," << (m_sensorData ? m_sensorData->sens3() : 0) << "," << (m_sensorData ? m_sensorData->sens4() : 0) << ","
                    << (m_sensorData ? m_sensorData->sens5() : 0) << "," << (m_sensorData ? m_sensorData->sens6() : 0) << "," << (m_sensorData ? m_sensorData->sens7() : 0) << ","
                    << (m_sensorData ? m_sensorData->sens8() : 0) << "," << (m_flagsData ? m_flagsData->Flag1() : 0) << "," << (m_flagsData ? m_flagsData->Flag2() : 0) << ","
                    << (m_flagsData ? m_flagsData->Flag3() : 0) << "," << (m_flagsData ? m_flagsData->Flag4() : 0) << "," << (m_flagsData ? m_flagsData->Flag5() : 0) << ","
                    << (m_flagsData ? m_flagsData->Flag6() : 0) << "," << (m_flagsData ? m_flagsData->Flag7() : 0) << "," << (m_flagsData ? m_flagsData->Flag8() : 0) << ","
                    << (m_flagsData ? m_flagsData->Flag9() : 0) << "," << (m_flagsData ? m_flagsData->Flag10() : 0) << "," << (m_flagsData ? m_flagsData->Flag11() : 0) << ","
                    << (m_flagsData ? m_flagsData->Flag12() : 0) << "," << (m_flagsData ? m_flagsData->Flag13() : 0) << "," << (m_flagsData ? m_flagsData->Flag14() : 0) << ","
                    << (m_flagsData ? m_flagsData->Flag15() : 0) << "," << (m_flagsData ? m_flagsData->Flag16() : 0) << "," << (m_engineData ? m_engineData->MAP() : 0) << ","
                    << (m_engineData ? m_engineData->AUXT() : 0) << "," << (m_engineData ? m_engineData->AFR() : 0) << "," << (m_engineData ? m_engineData->TPS() : 0) << ","
                    << (m_engineData ? m_engineData->IdleValue() : 0) << "," << (m_vehicleData ? m_vehicleData->MVSS() : 0) << "," << (m_vehicleData ? m_vehicleData->SVSS() : 0) << ","
                    << (m_engineData ? m_engineData->Inj1() : 0) << "," << (m_engineData ? m_engineData->Inj2() : 0) << "," << (m_engineData ? m_engineData->Inj3() : 0) << ","
                    << (m_engineData ? m_engineData->Inj4() : 0) << "," << (m_engineData ? m_engineData->Ign1() : 0) << "," << (m_engineData ? m_engineData->Ign2() : 0) << ","
                    << (m_engineData ? m_engineData->Ign3() : 0) << "," << (m_engineData ? m_engineData->Ign4() : 0) << "," << (m_engineData ? m_engineData->TRIM() : 0) << ","
                    << (m_gpsData ? m_gpsData->gpsTime() : QString()) << "," << (m_gpsData ? m_gpsData->gpsAltitude() : 0) << ","
                    << QString("%1").arg(m_gpsData ? m_gpsData->gpsLatitude() : 0, 0, 'f', 6) << ","
                    << QString("%1").arg(m_gpsData ? m_gpsData->gpsLongitude() : 0, 0, 'f', 6)
                    << ","
                    //<< m_gpsData->gpsLatitude()  << "," << << QString("%1").arg(x, 0, 'f', 6)
                    // << m_gpsData->gpsLongitude()   << ","
                    << (m_gpsData ? m_gpsData->gpsSpeed() : 0) << "," << (m_gpsData ? m_gpsData->gpsVisibleSatelites() : 0) << ","
                    << (m_vehicleData ? m_vehicleData->accelx() : 0) << "," << (m_vehicleData ? m_vehicleData->accely() : 0) << "," << (m_vehicleData ? m_vehicleData->accelz() : 0) << ","
                    << (m_vehicleData ? m_vehicleData->gyrox() : 0) << "," << (m_vehicleData ? m_vehicleData->gyroy() : 0) << "," << (m_vehicleData ? m_vehicleData->gyroz() : 0) << ","
                    << (m_vehicleData ? m_vehicleData->compass() : 0) << "," << (m_vehicleData ? m_vehicleData->ambitemp() : 0) << "," << (m_vehicleData ? m_vehicleData->ambipress() : 0)
                    << "," << (m_timingData ? m_timingData->currentLap() : 0) << "," << (m_timingData ? m_timingData->laptime() : QString()) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput0() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput1() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput2() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput3() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput4() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput5() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput6() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput7() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc0() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc1() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc2() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc3() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc4() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc5() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc6() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc7() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput1() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput2() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput3() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput4() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput5() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput6() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput7() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput8() : 0) << "," << Qt::endl;
                mFile.close();
                break;
            case 1:  ////Link ECU Generic CAN
                out << (loggerStartT.msecsTo(QTime::currentTime())) << "," << (m_engineData ? m_engineData->rpm() : 0) << ","
                    << (m_engineData ? m_engineData->MAP() : 0) << ","
                    << "MGP" << "," << (m_vehicleData ? m_vehicleData->ambipress() : 0) << "," << (m_engineData ? m_engineData->TPS() : 0) << ","
                    << (m_engineData ? m_engineData->InjDuty() : 0) << "," << (m_engineData ? m_engineData->InjDuty2() : 0) << "," << (m_engineData ? m_engineData->injms() : 0) << ","
                    << (m_engineData ? m_engineData->Watertemp() : 0) << "," << (m_engineData ? m_engineData->Intaketemp() : 0) << "," << (m_engineData ? m_engineData->BatteryV() : 0)
                    << "," << (m_engineData ? m_engineData->MAFactivity() : 0) << "," << (m_vehicleData ? m_vehicleData->Gear() : 0) << "," << (m_engineData ? m_engineData->InjAngle() : 0)
                    << "," << (m_engineData ? m_engineData->Ign() : 0) << "," << (m_engineData ? m_engineData->incamangle1() : 0) << ","
                    << (m_engineData ? m_engineData->incamangle2() : 0) << "," << (m_engineData ? m_engineData->excamangle1() : 0) << ","
                    << (m_engineData ? m_engineData->excamangle2() : 0) << "," << (m_engineData ? m_engineData->LAMBDA() : 0) << "," << (m_engineData ? m_engineData->lambda2() : 0)
                    << ","
                    << "Trig 1 Error Counter" << "," << (m_connectionData ? m_connectionData->Error() : QString()) << "," << (m_engineData ? m_engineData->FuelPress() : 0) << ","
                    << (m_engineData ? m_engineData->oiltemp() : 0) << "," << (m_engineData ? m_engineData->oilpres() : 0) << "," << (m_vehicleData ? m_vehicleData->wheelspdftleft() : 0)
                    << "," << (m_vehicleData ? m_vehicleData->wheelspdrearleft() : 0) << "," << (m_vehicleData ? m_vehicleData->wheelspdftright() : 0) << ","
                    << (m_vehicleData ? m_vehicleData->wheelspdrearright() : 0) << "," << (m_engineData ? m_engineData->Knock() : 0) << ","
                    << "Knock Level 2" << ","
                    << "Knock Level 3" << ","
                    << "Knock Level 4" << ","
                    << "Knock Level 5" << ","
                    << "Knock Level 6" << ","
                    << "Knock Level 7" << ","
                    << "Knock Level 8" << "," << (m_timingData ? m_timingData->currentLap() : 0) << "," << (m_timingData ? m_timingData->laptime() : QString()) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput0() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput1() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput2() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput3() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput4() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput5() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput6() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput7() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc0() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc1() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc2() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc3() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc4() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc5() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc6() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc7() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput1() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput2() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput3() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput4() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput5() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput6() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput7() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput8() : 0) << "," << Qt::endl;
                mFile.close();
                break;
            case 2:  ////Toyota86 BRZ FRS
                out << (loggerStartT.msecsTo(QTime::currentTime())) << "," << (m_engineData ? m_engineData->rpm() : 0) << ","
                    << (m_engineData ? m_engineData->Watertemp() : 0) << "," << (m_engineData ? m_engineData->oiltemp() : 0) << "," << (m_vehicleData ? m_vehicleData->wheelspdftleft() : 0)
                    << "," << (m_vehicleData ? m_vehicleData->wheelspdrearleft() : 0) << "," << (m_vehicleData ? m_vehicleData->wheelspdftright() : 0) << ","
                    << (m_vehicleData ? m_vehicleData->wheelspdrearright() : 0) << "," << (m_vehicleData ? m_vehicleData->SteeringWheelAngle() : 0) << ","
                    << (m_engineData ? m_engineData->brakepress() : 0) << "," << (m_gpsData ? m_gpsData->gpsTime() : QString()) << "," << (m_gpsData ? m_gpsData->gpsAltitude() : 0)
                    << "," << QString("%1").arg(m_gpsData ? m_gpsData->gpsLatitude() : 0, 0, 'f', 6) << ","
                    << QString("%1").arg(m_gpsData ? m_gpsData->gpsLongitude() : 0, 0, 'f', 6) << "," << (m_gpsData ? m_gpsData->gpsSpeed() : 0)
                    << "," << (m_timingData ? m_timingData->currentLap() : 0) << "," << (m_timingData ? m_timingData->laptime() : QString()) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput0() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput1() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput2() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput3() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput4() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput5() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput6() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput7() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc0() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc1() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc2() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc3() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc4() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc5() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc6() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc7() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput1() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput2() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput3() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput4() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput5() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput6() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput7() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput8() : 0) << "," << Qt::endl;
                mFile.close();
                break;
            case 5:  ////ECU MASTERS EMU CAN
                out << (loggerStartT.msecsTo(QTime::currentTime())) << ","

                    << (m_engineData ? m_engineData->rpm() : 0) << "," << (m_engineData ? m_engineData->TPS() : 0) << "," << (m_engineData ? m_engineData->injms() : 0) << ","
                    << (m_vehicleData ? m_vehicleData->speed() : 0) << "," << (m_vehicleData ? m_vehicleData->ambipress() : 0) << "," << (m_engineData ? m_engineData->oiltemp() : 0) << ","
                    << (m_engineData ? m_engineData->oilpres() : 0) << "," << (m_engineData ? m_engineData->FuelPress() : 0) << "," << (m_engineData ? m_engineData->Watertemp() : 0)
                    << "," << (m_engineData ? m_engineData->Ign() : 0) << "," << (m_engineData ? m_engineData->Dwell() : 0) << "," << (m_engineData ? m_engineData->LAMBDA() : 0) << ","
                    << (m_engineData ? m_engineData->LAMBDA() : 0) << "," << (m_engineData ? m_engineData->egt1() : 0) << "," << (m_engineData ? m_engineData->egt2() : 0) << ","
                    << (m_vehicleData ? m_vehicleData->Gear() : 0) << "," << (m_engineData ? m_engineData->BatteryV() : 0) << "," << (m_engineData ? m_engineData->fuelcomposition() : 0)
                    << "," << (m_analogInputs ? m_analogInputs->Analog1() : 0) << "," << (m_analogInputs ? m_analogInputs->Analog2() : 0) << "," << (m_analogInputs ? m_analogInputs->Analog3() : 0)
                    << "," << (m_analogInputs ? m_analogInputs->Analog4() : 0) << "," << (m_analogInputs ? m_analogInputs->Analog5() : 0) << "," << (m_analogInputs ? m_analogInputs->Analog6() : 0)
                    << "," << (m_gpsData ? m_gpsData->gpsTime() : QString()) << "," << (m_gpsData ? m_gpsData->gpsAltitude() : 0) << ","
                    << QString("%1").arg(m_gpsData ? m_gpsData->gpsLatitude() : 0, 0, 'f', 6) << ","
                    << QString("%1").arg(m_gpsData ? m_gpsData->gpsLongitude() : 0, 0, 'f', 6) << "," << (m_gpsData ? m_gpsData->gpsSpeed() : 0)
                    << "," << (m_timingData ? m_timingData->currentLap() : 0) << "," << (m_timingData ? m_timingData->laptime() : QString()) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput0() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput1() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput2() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput3() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput4() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput5() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput6() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput7() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc0() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc1() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc2() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc3() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc4() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc5() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc6() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc7() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput1() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput2() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput3() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput4() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput5() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput6() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput7() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput8() : 0) << "," << Qt::endl;
                mFile.close();
                break;
            case 6:  ////GR YARIS
                out << (loggerStartT.msecsTo(QTime::currentTime())) << ","

                    << (m_engineData ? m_engineData->rpm() : 0) << "," << (m_vehicleData ? m_vehicleData->wheelspdftleft() : 0) << ","
                    << (m_vehicleData ? m_vehicleData->wheelspdftright() : 0) << "," << (m_vehicleData ? m_vehicleData->wheelspdrearleft() : 0) << ","
                    << (m_vehicleData ? m_vehicleData->wheelspdrearright() : 0) << "," << (m_vehicleData ? m_vehicleData->SteeringWheelAngle() : 0) << ","
                    << (m_flagsData ? m_flagsData->Flag1() : 0) << ","       // Brake Switch
                    << (m_engineData ? m_engineData->brakepress() : 0) << ","  // Brake Pressure
                    << (m_engineData ? m_engineData->IdleValue() : 0) << ","   //  Idle Switch
                    << (m_engineData ? m_engineData->TPS() : 0) << ","         // Throttle Position A
                    << (m_engineData ? m_engineData->ThrottleV() : 0) << ","   // Throttle Position B
                    << (m_engineData ? m_engineData->Torque() : 0) << ","      // Steering Torque
                    << (m_vehicleData ? m_vehicleData->clutchswitchstate() : 0) << "," << (m_gpsData ? m_gpsData->gpsTime() : QString()) << ","
                    << (m_gpsData ? m_gpsData->gpsAltitude() : 0) << "," << QString("%1").arg(m_gpsData ? m_gpsData->gpsLatitude() : 0, 0, 'f', 6)
                    << "," << QString("%1").arg(m_gpsData ? m_gpsData->gpsLongitude() : 0, 0, 'f', 6) << ","
                    << (m_gpsData ? m_gpsData->gpsSpeed() : 0) << "," << (m_timingData ? m_timingData->currentLap() : 0) << "," << (m_timingData ? m_timingData->laptime() : QString())
                    << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput0() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput1() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput2() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput3() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput4() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput5() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput6() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogInput7() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc0() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc1() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc2() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc3() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc4() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc5() : 0) << ","
                    << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc6() : 0) << "," << (m_expanderBoardData ? m_expanderBoardData->EXAnalogCalc7() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput1() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput2() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput3() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput4() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput5() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput6() : 0) << ","
                    << (m_digitalInputs ? m_digitalInputs->EXDigitalInput7() : 0) << "," << (m_digitalInputs ? m_digitalInputs->EXDigitalInput8() : 0) << "," << Qt::endl;
                mFile.close();
                break;
            }
        }
    }
}


void datalogger::createHeader()
{
    int ecuValue = m_connectionData ? m_connectionData->ecu() : 0;
    qDebug() << "ECU" << ecuValue;
    QString filename = Log + ".csv";
    QFile file(filename);
    // qDebug() << "update Log";
    if (file.open(QIODevice::ReadWrite)) {
        {
            QString fileName = Log + ".csv";
            QFile mFile(fileName);
            if (!mFile.open(QFile::Append | QFile::Text)) {}

            QTextStream out(&mFile);
            switch (ecuValue) {
            case 0:  ////Apexi

                out << "Time ms" << ","
                    << "RPM" << ","
                    << "Intakepress" << ","
                    << "PressureV" << ","
                    << "ThrottleV" << ","
                    << "Primaryinp" << ","
                    << "Fuelc" << ","
                    << "Leadingign" << ","
                    << "Trailingign" << ","
                    << "Fueltemp" << ","
                    << "Moilp" << ","
                    << "Boosttp" << ","
                    << "Boostwg" << ","
                    << "Watertemp" << ","
                    << "Intaketemp" << ","
                    << "Knock" << ","
                    << "BatteryV" << ","
                    << "speed" << ","
                    << "Iscvduty" << ","
                    << "O2volt" << ","
                    << "na1" << ","
                    << "Secinjpulse" << ","
                    << "na2" << ","
                    << "InjDuty" << ","
                    << "Engine Load" << ","
                    << "MAF1 Voltage " << ","
                    << "MAF2 Voltage " << ","
                    << "injms" << ","
                    << "Inj" << ","
                    << "Ign" << ","
                    << "Dwell" << ","
                    << "BoostPres" << ","
                    << "BoostDuty" << ","
                    << "MAFactivity" << ","
                    << "O2volt_2" << ","
                    << "pim" << ","
                    << "auxcalc1" << ","
                    << "auxcalc2" << "," << (m_flagsData ? m_flagsData->SensorString1() : QString()) << "," << (m_flagsData ? m_flagsData->SensorString2() : QString()) << ","
                    << (m_flagsData ? m_flagsData->SensorString3() : QString()) << "," << (m_flagsData ? m_flagsData->SensorString4() : QString()) << ","
                    << (m_flagsData ? m_flagsData->SensorString5() : QString()) << "," << (m_flagsData ? m_flagsData->SensorString6() : QString()) << ","
                    << (m_flagsData ? m_flagsData->SensorString7() : QString()) << "," << (m_flagsData ? m_flagsData->SensorString8() : QString()) << ","
                    << (m_flagsData ? m_flagsData->FlagString1() : QString()) << "," << (m_flagsData ? m_flagsData->FlagString2() : QString()) << ","
                    << (m_flagsData ? m_flagsData->FlagString3() : QString()) << "," << (m_flagsData ? m_flagsData->FlagString4() : QString()) << ","
                    << (m_flagsData ? m_flagsData->FlagString5() : QString()) << "," << (m_flagsData ? m_flagsData->FlagString6() : QString()) << ","
                    << (m_flagsData ? m_flagsData->FlagString7() : QString()) << "," << (m_flagsData ? m_flagsData->FlagString8() : QString()) << ","
                    << (m_flagsData ? m_flagsData->FlagString9() : QString()) << "," << (m_flagsData ? m_flagsData->FlagString10() : QString()) << ","
                    << (m_flagsData ? m_flagsData->FlagString11() : QString()) << "," << (m_flagsData ? m_flagsData->FlagString12() : QString()) << ","
                    << (m_flagsData ? m_flagsData->FlagString13() : QString()) << "," << (m_flagsData ? m_flagsData->FlagString14() : QString()) << ","
                    << (m_flagsData ? m_flagsData->FlagString15() : QString()) << "," << (m_flagsData ? m_flagsData->FlagString16() : QString()) << ","
                    << "MAP" << ","
                    << "AUXT" << ","
                    << "AFR" << ","
                    << "TPS" << ","
                    << "IdleValue" << ","
                    << "Master Speed" << ","
                    << "Slave Speed " << ","
                    << "Inj1" << ","
                    << "Inj2" << ","
                    << "Inj3" << ","
                    << "Inj4" << ","
                    << "Ign1" << ","
                    << "Ign2" << ","
                    << "Ign3" << ","
                    << "Ign4" << ","
                    << "TRIM" << ","
                    << "GPS Time" << ","
                    << "GPS Altitude" << ","
                    << "GPS Latitude" << ","
                    << "GPS Longitude" << ","
                    << "GPS Speed" << ","
                    << "Visible Satelites" << ","
                    << "Lateral Accel" << ","
                    << "Longitudinal Accel" << ","
                    << "Gravity" << ","
                    << "Gyro X" << ","
                    << "Gyro Y" << ","
                    << "Gyro Z" << ","
                    << "Azimuth" << ","
                    << "Ambient Temperature" << ","
                    << "Ambient Pressure" << ","
                    << "Current LAP" << ","
                    << "LAP TIME" << ","
                    << "EX AN0" << ","
                    << "EX AN1" << ","
                    << "EX AN2" << ","
                    << "EX AN3" << ","
                    << "EX AN4" << ","
                    << "EX AN5" << ","
                    << "EX AN6" << ","
                    << "EX AN7" << ","
                    << "EX AN0 calc" << ","
                    << "EX AN1 calc" << ","
                    << "EX AN2 calc" << ","
                    << "EX AN3 calc" << ","
                    << "EX AN4 calc" << ","
                    << "EX AN5 calc" << ","
                    << "EX AN6 calc" << ","
                    << "EX AN7 calc" << ","
                    << "EX Digitial 1" << ","
                    << "EX Digitial 2" << ","
                    << "EX Digitial 3" << ","
                    << "EX Digitial 4" << ","
                    << "EX Digitial 5" << ","
                    << "EX Digitial 6" << ","
                    << "EX Digitial 7" << ","
                    << "EX Digitial 8" << "," << Qt::endl;
                mFile.close();
                break;
            case 1:  ////Link ECU Generic CAN
                out << "Time ms" << ","
                    << "RPM" << ","
                    << "MAP" << ","
                    << "MGP" << ","
                    << "Barometric Pressure" << ","
                    << "TPS" << ","
                    << "Injector DC (pri)" << ","
                    << "Injector DC (sec)" << ","
                    << "Injector Pulse Width (Actual)" << ","
                    << "ECT" << ","
                    << "IAT" << ","
                    << "ECU Volts" << ","
                    << "MAF" << ","
                    << "Gear Position" << ","
                    << "Injector Timing" << ","
                    << "Ignition Timing" << ","
                    << "Cam Inlet Position L" << ","
                    << "Cam Inlet Position R" << ","
                    << "Cam Exhaust Position L" << ","
                    << "Cam Exhaust Position R" << ","
                    << "Lambda 1" << ","
                    << "Lambda 2" << ","
                    << "Trig 1 Error Counter" << ","
                    << "Fault Codes" << ","
                    << "Fuel Pressure" << ","
                    << "Oil Temp " << ","
                    << "Oil Pressure" << ","
                    << "LF Wheel Speed" << ","
                    << "LR Wheel Speed" << ","
                    << "RF Wheel Speed" << ","
                    << "RR Wheel Speed" << ","
                    << "Knock Level 1" << ","
                    << "Knock Level 2" << ","
                    << "Knock Level 3" << ","
                    << "Knock Level 4" << ","
                    << "Knock Level 5" << ","
                    << "Knock Level 6" << ","
                    << "Knock Level 7" << ","
                    << "Knock Level 8" << ","
                    << "Current LAP" << ","
                    << "LAP TIME" << ","
                    << "EX AN0" << ","
                    << "EX AN1" << ","
                    << "EX AN2" << ","
                    << "EX AN3" << ","
                    << "EX AN4" << ","
                    << "EX AN5" << ","
                    << "EX AN6" << ","
                    << "EX AN7" << ","
                    << "EX AN0 calc" << ","
                    << "EX AN1 calc" << ","
                    << "EX AN2 calc" << ","
                    << "EX AN3 calc" << ","
                    << "EX AN4 calc" << ","
                    << "EX AN5 calc" << ","
                    << "EX AN6 calc" << ","
                    << "EX AN7 calc" << ","
                    << "EX Digitial 1" << ","
                    << "EX Digitial 2" << ","
                    << "EX Digitial 3" << ","
                    << "EX Digitial 4" << ","
                    << "EX Digitial 5" << ","
                    << "EX Digitial 6" << ","
                    << "EX Digitial 7" << ","
                    << "EX Digitial 8" << "," << Qt::endl;
                mFile.close();
                break;

            case 2:  ////Toyota86 BRZ FRS
                out << "Time ms" << ","
                    << "RPM" << ","
                    << "Coolant Temp" << ","
                    << "Oil Temp" << ","
                    << "LF Wheel Speed" << ","
                    << "LR Wheel Speed" << ","
                    << "RF Wheel Speed" << ","
                    << "RR Wheel Speed" << ","
                    << "Steering Wheel Angle " << ","
                    << "Brake Pressure"
                       ","
                    << "GPS Time" << ","
                    << "GPS Altitude" << ","
                    << "GPS Latitude" << ","
                    << "GPS Longitude" << ","
                    << "GPS Speed" << ","
                    << "Current LAP" << ","
                    << "LAP TIME" << ","
                    << "EX AN0" << ","
                    << "EX AN1" << ","
                    << "EX AN2" << ","
                    << "EX AN3" << ","
                    << "EX AN4" << ","
                    << "EX AN5" << ","
                    << "EX AN6" << ","
                    << "EX AN7" << ","
                    << "EX AN0 calc" << ","
                    << "EX AN1 calc" << ","
                    << "EX AN2 calc" << ","
                    << "EX AN3 calc" << ","
                    << "EX AN4 calc" << ","
                    << "EX AN5 calc" << ","
                    << "EX AN6 calc" << ","
                    << "EX AN7 calc" << ","
                    << "EX Digitial 1" << ","
                    << "EX Digitial 2" << ","
                    << "EX Digitial 3" << ","
                    << "EX Digitial 4" << ","
                    << "EX Digitial 5" << ","
                    << "EX Digitial 6" << ","
                    << "EX Digitial 7" << ","
                    << "EX Digitial 8" << "," << Qt::endl;
                mFile.close();
                break;

            case 5:  ////EMU CAN
                out << "Time ms" << ","
                    << "RPM" << ","
                    << "TPS" << ","
                    << "IAT" << ","
                    << "MAP" << ","
                    << "Inj PW (ms)" << ","
                    << "Speed" << ","
                    << "Barometric Pressure" << ","
                    << "Oil Temp" << ","
                    << "Oil Pressure"
                       ","
                    << "Fuel Pressure"
                       ","
                    << "Coolant Temp"
                       ","
                    << "Ignition Angle"
                       ","
                    << "Dwell (ms)"
                       ","
                    << "LAMDA λ"
                       ","
                    << "LAMDA Corr. %"
                       ","
                    << "EGT 1"
                       ","
                    << "EGT 2"
                       ","
                    << "Gear"
                       ","
                    << "Battery V"
                       ","
                    << "Ethanol %"
                       ","
                    << "Analog 1 V"
                       ","
                    << "Analog 2 V"
                       ","
                    << "Analog 3 V"
                       ","
                    << "Analog 4 V"
                       ","
                    << "Analog 5 V"
                       ","
                    << "Analog 6 V"
                       ","
                    << "GPS Time" << ","
                    << "GPS Altitude" << ","
                    << "GPS Latitude" << ","
                    << "GPS Longitude" << ","
                    << "GPS Speed" << ","
                    << "Current LAP" << ","
                    << "LAP TIME" << ","
                    << "EX AN0" << ","
                    << "EX AN1" << ","
                    << "EX AN2" << ","
                    << "EX AN3" << ","
                    << "EX AN4" << ","
                    << "EX AN5" << ","
                    << "EX AN6" << ","
                    << "EX AN7" << ","
                    << "EX AN0 calc" << ","
                    << "EX AN1 calc" << ","
                    << "EX AN2 calc" << ","
                    << "EX AN3 calc" << ","
                    << "EX AN4 calc" << ","
                    << "EX AN5 calc" << ","
                    << "EX AN6 calc" << ","
                    << "EX AN7 calc" << ","
                    << "EX Digitial 1" << ","
                    << "EX Digitial 2" << ","
                    << "EX Digitial 3" << ","
                    << "EX Digitial 4" << ","
                    << "EX Digitial 5" << ","
                    << "EX Digitial 6" << ","
                    << "EX Digitial 7" << ","
                    << "EX Digitial 8" << "," << Qt::endl;
                mFile.close();
                break;
            case 6:  ////GR YARIS
                out << "Time ms" << ","
                    << "RPM" << ","
                    << "Wheel speed FL" << ","
                    << "Wheel speed FR" << ","
                    << "Wheel speed RL" << ","
                    << "Wheel speed RR" << ","
                    << "Steering wheel angle" << ","
                    << "Brake switch" << ","
                    << "Brake pressure" << ","
                    << "Idle switch" << ","
                    << "Throttle pos.A" << ","
                    << "Throttle pos.B" << ","
                    << "Steering torque" << ","
                    << "Clutch switch" << ","
                    << "GPS Time" << ","
                    << "GPS Altitude" << ","
                    << "GPS Latitude" << ","
                    << "GPS Longitude" << ","
                    << "GPS Speed" << ","
                    << "Current LAP" << ","
                    << "LAP TIME" << ","
                    << "EX AN0" << ","
                    << "EX AN1" << ","
                    << "EX AN2" << ","
                    << "EX AN3" << ","
                    << "EX AN4" << ","
                    << "EX AN5" << ","
                    << "EX AN6" << ","
                    << "EX AN7" << ","
                    << "EX AN0 calc" << ","
                    << "EX AN1 calc" << ","
                    << "EX AN2 calc" << ","
                    << "EX AN3 calc" << ","
                    << "EX AN4 calc" << ","
                    << "EX AN5 calc" << ","
                    << "EX AN6 calc" << ","
                    << "EX AN7 calc" << ","
                    << "EX Digitial 1" << ","
                    << "EX Digitial 2" << ","
                    << "EX Digitial 3" << ","
                    << "EX Digitial 4" << ","
                    << "EX Digitial 5" << ","
                    << "EX Digitial 6" << ","
                    << "EX Digitial 7" << ","
                    << "EX Digitial 8" << "," << Qt::endl;
                mFile.close();
                break;
            }
        }
    }
}
