/*
 * Copyright (C) 2018 Markus Ippy, Bastian Gschrey,
 * use this program at your own risk.
  \file calculations.cpp
  \brief Various Calculations Power / Torque / Gear / 0-100 ...
  \author Markus Ippy, Bastian Gschrey
 */

#include "Calculations.h"

#include "../Core/Models/EngineData.h"
#include "../Core/Models/ExpanderBoardData.h"
#include "../Core/Models/SettingsData.h"
#include "../Core/Models/TimingData.h"
#include "../Core/Models/VehicleData.h"

#include <QDebug>

qreal Power;
qreal Torque;
qreal odometer;
qreal tripmeter;
qreal traveleddistance;
qreal timesincelastupdate;

QTime startTime;
QTime reactiontimerdiff = QTime::currentTime();
qreal dragdistance;
qreal dragdistancetotal;
qreal totaldragtime;
qreal zerotohundredtime;
qreal twohundredtime;
qreal threehundredtime;
qreal reactiontime;
qreal qmlgreentime;

int zerotohundredset = 0;
int hundredtotwohundredset = 0;
int twohundredtothreehundredset = 0;
int sixtyfootset = 0;
int threhundredthirtyfootset = 0;
int eightmileset = 0;
int quartermileset = 0;
int thousandfootset = 0;
int startdragcalculation = 0;

int weight;  // just set this to 1300 for testing
int gearratio;
int odoisset;
int PreviousSpeed;
int Gear1;
int Gear2;
int Gear3;
int Gear4;
int Gear5;
int Gear6;
int GearN;
double prev_speed = 0;
qint64 prev_timestamp = QDateTime::currentMSecsSinceEpoch();

calculations::calculations(QObject *parent)
    : QObject(parent),
      m_vehicleData(nullptr),
      m_engineData(nullptr),
      m_timingData(nullptr),
      m_settingsData(nullptr)
{}
calculations::calculations(VehicleData *vehicleData, EngineData *engineData, TimingData *timingData,
                           SettingsData *settingsData, QObject *parent)
    : QObject(parent),
      m_vehicleData(vehicleData),
      m_engineData(engineData),
      m_timingData(timingData),
      m_settingsData(settingsData)
{}

void calculations::setExpanderBoardData(ExpanderBoardData *expander)
{
    m_expanderBoardData = expander;
}

void calculations::start()
{
    if (m_updatetimer.isActive())
        return;

    connect(&m_updatetimer, &QTimer::timeout, this, &calculations::calculate, Qt::UniqueConnection);
    connect(&m_updateodotimer, &QTimer::timeout, this, &calculations::saveodoandtriptofile, Qt::UniqueConnection);
    odometer = m_vehicleData->Odo();
    tripmeter = m_vehicleData->Trip();
    m_updatetimer.setInterval(25);
    // m_updateodotimer.start(10000);
    m_updatetimer.start();
}
void calculations::stop()
{
    m_updatetimer.stop();
}
void calculations::resettrip()
{
    tripmeter = 0;
    m_vehicleData->setTrip(0);
}
void calculations::startdragtimer()
{
    zerotohundredtime = 0;
    twohundredtime = 0;
    threehundredtime = 0;

    dragdistance = 0;
    totaldragtime = 0;
    dragdistancetotal = 0;
    zerotohundredset = 0;
    hundredtotwohundredset = 0;
    twohundredtothreehundredset = 0;
    sixtyfootset = 0, threhundredthirtyfootset = 0;
    eightmileset = 0;
    quartermileset = 0;
    thousandfootset = 0;
    startdragcalculation = 0;
    startdragcalculation = 1;
}
void calculations::startreactiontimer()
{
    // qDebug() << "Reactiontimer start";
    reactiontime = 0;
    qmlgreentime = 0;
    reactiontimerdiff = QTime::currentTime();
    m_reactiontimer.start();
}

void calculations::qmlrealtime()
{
    // qDebug() << "QML Light Green";
    qmlgreentime = (reactiontimerdiff.msecsTo(QTime::currentTime()) / 1000);  // reactiontime
}
void calculations::stopreactiontimer()
{
    // qDebug() << "stop reaction timer";
    m_reactiontimer.stop();
    startTime = QTime::currentTime();
    reactiontime = (reactiontimerdiff.msecsTo(QTime::currentTime()));  // reactiontime
    m_timingData->setreactiontime(reactiontime / 1000);
}


/*
void calculations::calculatereactiontime()
{
    m_timingData->setreactiontime((reactiontime / 1000) - qmlgreentime) ;
}
*/
void calculations::readodoandtrip()
{
    // Call this from QML to read Odo and Trip from file
}
void calculations::saveodoandtriptofile()
{
    // To avoid file corruption  save this every 10 seconds only if speed is greater 10 KM/h
    //  m_updateodotimer.start(600);
    // qDebug() << "Update Odometer";
}
// 1 foot = 0,00018939 miles =
// 60 Feet = 0,0113634 miles = 0,01828762 km
// 330 Feet  = 0,0624987 miles = 0,10058191 km
void calculations::calculate()
{
    weight = m_vehicleData->Weight();
    const qreal currentSpeed = m_expanderBoardData ? m_expanderBoardData->EXSpeed() : 0.0;

    if (m_settingsData->speedunits() == "metric" && startdragcalculation == 1) {
        timesincelastupdate = (startTime.msecsTo(QTime::currentTime())) - totaldragtime;
        dragdistance = (timesincelastupdate * (currentSpeed / 3600000));
        totaldragtime = (startTime.msecsTo(QTime::currentTime()));
        dragdistancetotal += dragdistance;
        if (dragdistancetotal >= 0.01828762 && sixtyfootset == 0) {
            m_timingData->setsixtyfoottime(totaldragtime / 1000);
            m_timingData->setsixtyfootspeed(currentSpeed);
            sixtyfootset = 1;
        }
        if (dragdistancetotal >= 0.10058191 && threhundredthirtyfootset == 0) {
            m_timingData->setthreehundredthirtyfoottime(totaldragtime / 1000);
            m_timingData->setthreehundredthirtyfootspeed(currentSpeed);
            threhundredthirtyfootset = 1;
        }
        if (dragdistancetotal >= 0.201168 && eightmileset == 0) {
            m_timingData->seteightmiletime(totaldragtime / 1000);
            m_timingData->seteightmilespeed(currentSpeed);
            eightmileset = 1;
        }
        if (dragdistancetotal >= 0.402336 && quartermileset == 0) {
            m_timingData->setquartermiletime(totaldragtime / 1000);
            m_timingData->setquartermilespeed(currentSpeed);
            quartermileset = 1;
        }
        if (dragdistancetotal >= 0.3048 && thousandfootset == 0) {
            m_timingData->setthousandfoottime(totaldragtime / 1000);
            m_timingData->setthousandfootspeed(currentSpeed);
            thousandfootset = 1;
        }
        if (currentSpeed >= 100 && zerotohundredset == 0) {
            zerotohundredtime = totaldragtime;
            m_timingData->setzerotohundredt(totaldragtime / 1000);
            zerotohundredset = 1;
        }
        if (currentSpeed >= 200 && hundredtotwohundredset == 0) {
            twohundredtime = totaldragtime - zerotohundredtime;
            m_timingData->sethundredtotwohundredtime(twohundredtime / 1000);
            hundredtotwohundredset = 1;
        }
        if (currentSpeed >= 300 && twohundredtothreehundredset == 0) {
            threehundredtime = totaldragtime - zerotohundredtime - twohundredtime;
            m_timingData->settwohundredtothreehundredtime(threehundredtime / 1000);
            twohundredtothreehundredset = 1;
        }
    }
    if (m_settingsData->speedunits() == "imperial" && startdragcalculation == 1) {
        timesincelastupdate = (startTime.msecsTo(QTime::currentTime())) - totaldragtime;
        dragdistance = (timesincelastupdate * (currentSpeed / 3600000));
        totaldragtime = (startTime.msecsTo(QTime::currentTime()));
        dragdistancetotal += dragdistance;
        if (dragdistancetotal >= 0.01136364 && sixtyfootset == 0) {
            m_timingData->setsixtyfoottime(totaldragtime / 1000);
            m_timingData->setsixtyfootspeed(currentSpeed);
            sixtyfootset = 1;
        }
        if (dragdistancetotal >= 0.0625 && threhundredthirtyfootset == 0) {
            m_timingData->setthreehundredthirtyfoottime(totaldragtime / 1000);
            m_timingData->setthreehundredthirtyfootspeed(currentSpeed);
            threhundredthirtyfootset = 1;
        }
        if (dragdistancetotal >= 0.125 && eightmileset == 0) {
            m_timingData->seteightmiletime(totaldragtime / 1000);
            m_timingData->seteightmilespeed(currentSpeed);
            eightmileset = 1;
        }
        if (dragdistancetotal >= 0.25 && quartermileset == 0) {
            m_timingData->setquartermiletime(totaldragtime / 1000);
            m_timingData->setquartermilespeed(currentSpeed);
            quartermileset = 1;
        }
        if (dragdistancetotal >= 0.18939394 && thousandfootset == 0) {
            m_timingData->setthousandfoottime(totaldragtime / 1000);
            m_timingData->setthousandfootspeed(currentSpeed);
            thousandfootset = 1;
        }
        if (currentSpeed >= 60 && zerotohundredset == 0) {
            zerotohundredtime = totaldragtime;
            m_timingData->setzerotohundredt(totaldragtime / 1000);
            zerotohundredset = 1;
        }
        if (currentSpeed >= 120 && hundredtotwohundredset == 0) {
            twohundredtime = totaldragtime - zerotohundredtime;
            m_timingData->sethundredtotwohundredtime(twohundredtime / 1000);
            hundredtotwohundredset = 1;
        }
        if (currentSpeed >= 180 && twohundredtothreehundredset == 0) {
            threehundredtime = totaldragtime - zerotohundredtime - twohundredtime;
            m_timingData->settwohundredtothreehundredtime(threehundredtime / 1000);
            twohundredtothreehundredset = 1;
        }
    }

    if (m_settingsData->gearcalcactivation() == 1 && !m_settingsData->gearSourceExpander()) {
        int N = m_engineData->rpm() / (currentSpeed == 0.0 ? 0.01 : currentSpeed);
        int CurrentGear =
            (N > (m_settingsData->gearcalc1() * 1.5)
                 ? 0.0
                 : (N > ((m_settingsData->gearcalc1() + m_settingsData->gearcalc2()) / 2.0)
                        ? 1.0
                        : (N > ((m_settingsData->gearcalc2() + m_settingsData->gearcalc3()) / 2.0)
                               ? 2.0
                               : (N > ((m_settingsData->gearcalc3() + m_settingsData->gearcalc4()) / 2.0)
                                      ? 3.0
                                      : (N > ((m_settingsData->gearcalc4() + m_settingsData->gearcalc5()) / 2.0)
                                             ? 4.0
                                             : (m_settingsData->gearcalc5() == 0
                                                    ? 0.0
                                                    : (N > ((m_settingsData->gearcalc5() +
                                                             m_settingsData->gearcalc6()) /
                                                            2.0)
                                                           ? 5.0
                                                           : (m_settingsData->gearcalc6() == 0
                                                                  ? 0.0
                                                                  : (N > (m_settingsData->gearcalc6() / 2.0)
                                                                         ? 6.0
                                                                         : 0.0)))))))));
        m_vehicleData->setGear(CurrentGear);
        m_vehicleData->setGearCalculation(CurrentGear);
    }

    if (currentSpeed > 0) {
        qint64 current_timestamp = QDateTime::currentMSecsSinceEpoch();
        double time_interval = (current_timestamp - prev_timestamp) / 1000.0;
        double current_speed_mps = currentSpeed / 3.6;
        if (prev_timestamp == 0)
            prev_speed = current_speed_mps;
        double distance_traveled = ((current_speed_mps + prev_speed) * time_interval * 0.5) / 1000;
        if (distance_traveled < 0.005) {
            m_vehicleData->setOdo(m_vehicleData->Odo() + distance_traveled);
            m_vehicleData->setTrip(m_vehicleData->Trip() + distance_traveled);
        }
        prev_speed = current_speed_mps;
        prev_timestamp = current_timestamp;
    }
}
