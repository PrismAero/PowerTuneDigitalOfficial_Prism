/**
 * @file EngineData.cpp
 * @brief Implementation of the EngineData class
 */

#include "EngineData.h"

EngineData::EngineData(QObject *parent) : QObject(parent) {}

void EngineData::setrpm(qreal rpm)
{
    if (m_rpm != rpm) {
        m_rpm = rpm;
        emit rpmChanged(rpm);
    }
}

void EngineData::setPower(qreal Power)
{
    if (m_Power != Power) {
        m_Power = Power;
        emit powerChanged(Power);
    }
}

void EngineData::setTorque(qreal Torque)
{
    if (m_Torque != Torque) {
        m_Torque = Torque;
        emit torqueChanged(Torque);
    }
}

void EngineData::setCylinders(qreal Cylinders)
{
    if (m_Cylinders != Cylinders) {
        m_Cylinders = Cylinders;
        emit CylindersChanged(Cylinders);
    }
}

void EngineData::setLambdamultiply(qreal Lambdamultiply)
{
    if (m_Lambdamultiply != Lambdamultiply) {
        m_Lambdamultiply = Lambdamultiply;
        emit LambdamultiplyChanged(Lambdamultiply);
    }
}
