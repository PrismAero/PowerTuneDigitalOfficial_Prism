/*
* file sensors.cpp
* Copyright (C) 2018 Markus Ippy
*
* Class to use Accelerometer / Gyroscope / Compass / Humidity / Temperature and Pressure Sensor
* If you want to use this with Pi SenseHat, install the qsensors sensehat plugin
* https://github.com/lpotter/qsensors-sensehatplugin
* Special Thanks to Lorn Potter for writing the Qsensors Sensehat Plugin
* No warranty is made or implied. You use this program at your own risk.
*/

#include "sensors.h"
#include "../Core/dashboard.h"
#include <QAccelerometer>
#include <QAccelerometerReading>
#include <QGyroscope>
#include <QGyroscopeReading>
#include <QCompass>
#include <QCompassReading>
#include <QAmbientTemperatureSensor>
#include <QPressureSensor>
#include <QDebug>
#include <QDateTime>

Sensors::Sensors(QObject *parent)
    : QObject(parent)
    , m_dashboard(nullptr)

{

}
Sensors::Sensors(DashBoard *dashboard, QObject *parent)
    : QObject(parent)
    , m_dashboard(dashboard)
    , Compass(nullptr)
    , Accelerometer(nullptr)
    , Gyroscope(nullptr)
    , AmbientTemperatureSensor(nullptr)
    , PressureSensor(nullptr)
    , compass_reading(nullptr)
    , accel_reading(nullptr)
    , gyro_reading(nullptr)
    , temp_reading(nullptr)
    , press_reading(nullptr)


{
}
void Sensors::Comp()
{
    qDebug() << "start compass";
    Compass = new QCompass(this);
    connect(Compass, &QCompass::readingChanged, this, &Sensors::updateCompass);
    connect(Compass, &QCompass::sensorError, this, &Sensors::error);
    Compass->setDataRate(1);
    Compass->start();
}
void Sensors::Accel()
{
Accelerometer = new QAccelerometer(this);
connect(Accelerometer, &QAccelerometer::readingChanged, this, &Sensors::updateAccel);
connect(Accelerometer, &QAccelerometer::sensorError, this, &Sensors::error);
Accelerometer->setDataRate(1);
Accelerometer->start();
}
void Sensors::Gyro()
{
Gyroscope = new QGyroscope(this);
connect(Gyroscope, &QGyroscope::readingChanged, this, &Sensors::updateGyro);
connect(Gyroscope, &QGyroscope::sensorError, this, &Sensors::error);
Gyroscope->setDataRate(1);
Gyroscope->start();
}

void Sensors::Temperature()
{
AmbientTemperatureSensor = new QAmbientTemperatureSensor(this);
connect(AmbientTemperatureSensor, &QAmbientTemperatureSensor::readingChanged, this, &Sensors::updateAmbientSens);
connect(AmbientTemperatureSensor, &QAmbientTemperatureSensor::sensorError, this, &Sensors::error);
        AmbientTemperatureSensor->setDataRate(1);
        AmbientTemperatureSensor->start();
}
void Sensors::Pressure()
{
PressureSensor = new QPressureSensor(this);
connect(PressureSensor, &QPressureSensor::readingChanged, this, &Sensors::updatePressureSens);
connect(PressureSensor, &QPressureSensor::sensorError, this, &Sensors::error);
PressureSensor->setDataRate(1);
PressureSensor->start();
}


void Sensors::updateCompass()
{

    QString text_compass;
    compass_reading = Compass->reading();
    if(compass_reading != 0) {
        m_dashboard->setcompass(compass_reading->azimuth());
        /*
         text_compass = " Compass:  azimuth = " + QString::number(compass_reading->azimuth())
                + " Calibration level = " + QString::number(compass_reading->calibrationLevel());

        qDebug() << "Compass"<< text_compass;
        */
    }
    else {
        text_compass = "\nCompass: UNAVAILABLE";
        qDebug() << "Compass"<< text_compass;
    }

}
void Sensors::updateAccel()
{

    QString text_accel;
    accel_reading = Accelerometer->reading();
;
    if(accel_reading != 0) {
        m_dashboard->setaccelx(accel_reading->x()*0.10197162129779);
        m_dashboard->setaccely(accel_reading->y()*0.10197162129779);
        m_dashboard->setaccelz(accel_reading->z()*0.10197162129779);
        /*text_accel = QDateTime::currentDateTime().toString() +
                + "Acceleration  x = " + QString::number(accel_reading->x())+ "y ="
                + QString::number(accel_reading->y())+ "z ="+ QString::number(accel_reading->z());
*/
    }
    else {
        text_accel = "Accelerometer: UNAVAILABLE";
        qDebug() << "Accelerometer"<< text_accel;
    }

}
void Sensors::updateGyro()
{
    gyro_reading = Gyroscope->reading();
    if(accel_reading != 0) {
        m_dashboard->setgyrox(gyro_reading->x());
        m_dashboard->setgyroy(gyro_reading->y());
        m_dashboard->setgyroz(gyro_reading->z());
    }
}
void Sensors::updateAmbientSens()
{
    temp_reading = AmbientTemperatureSensor->reading();
    if(temp_reading != 0) {
        m_dashboard->setambitemp(temp_reading->temperature());
    }
}
void Sensors::updatePressureSens()
{
    press_reading = PressureSensor->reading();
    if(press_reading != 0) {
        m_dashboard->setambipress(press_reading->pressure());
    }
}
void Sensors::error(int)
{

}

