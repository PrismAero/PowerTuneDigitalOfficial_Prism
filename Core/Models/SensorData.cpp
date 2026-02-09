/**
 * @file SensorData.cpp
 * @brief Implementation of SensorData model
 */

#include "SensorData.h"

SensorData::SensorData(QObject *parent)
    : QObject(parent)
{
}

// * Setters - Raw sensor voltages
void SensorData::setsens1(qreal sens1)
{
    if (qFuzzyCompare(m_sens1, sens1))
        return;
    m_sens1 = sens1;
    emit sens1Changed(m_sens1);
}

void SensorData::setsens2(qreal sens2)
{
    if (qFuzzyCompare(m_sens2, sens2))
        return;
    m_sens2 = sens2;
    emit sens2Changed(m_sens2);
}

void SensorData::setsens3(qreal sens3)
{
    if (qFuzzyCompare(m_sens3, sens3))
        return;
    m_sens3 = sens3;
    emit sens3Changed(m_sens3);
}

void SensorData::setsens4(qreal sens4)
{
    if (qFuzzyCompare(m_sens4, sens4))
        return;
    m_sens4 = sens4;
    emit sens4Changed(m_sens4);
}

void SensorData::setsens5(qreal sens5)
{
    if (qFuzzyCompare(m_sens5, sens5))
        return;
    m_sens5 = sens5;
    emit sens5Changed(m_sens5);
}

void SensorData::setsens6(qreal sens6)
{
    if (qFuzzyCompare(m_sens6, sens6))
        return;
    m_sens6 = sens6;
    emit sens6Changed(m_sens6);
}

void SensorData::setsens7(qreal sens7)
{
    if (qFuzzyCompare(m_sens7, sens7))
        return;
    m_sens7 = sens7;
    emit sens7Changed(m_sens7);
}

void SensorData::setsens8(qreal sens8)
{
    if (qFuzzyCompare(m_sens8, sens8))
        return;
    m_sens8 = sens8;
    emit sens8Changed(m_sens8);
}

// * Setters - Sensor labels
void SensorData::setSensorString1(const QString &SensorString1)
{
    if (m_SensorString1 == SensorString1)
        return;
    m_SensorString1 = SensorString1;
    emit sensorString1Changed(m_SensorString1);
}

void SensorData::setSensorString2(const QString &SensorString2)
{
    if (m_SensorString2 == SensorString2)
        return;
    m_SensorString2 = SensorString2;
    emit sensorString2Changed(m_SensorString2);
}

void SensorData::setSensorString3(const QString &SensorString3)
{
    if (m_SensorString3 == SensorString3)
        return;
    m_SensorString3 = SensorString3;
    emit sensorString3Changed(m_SensorString3);
}

void SensorData::setSensorString4(const QString &SensorString4)
{
    if (m_SensorString4 == SensorString4)
        return;
    m_SensorString4 = SensorString4;
    emit sensorString4Changed(m_SensorString4);
}

void SensorData::setSensorString5(const QString &SensorString5)
{
    if (m_SensorString5 == SensorString5)
        return;
    m_SensorString5 = SensorString5;
    emit sensorString5Changed(m_SensorString5);
}

void SensorData::setSensorString6(const QString &SensorString6)
{
    if (m_SensorString6 == SensorString6)
        return;
    m_SensorString6 = SensorString6;
    emit sensorString6Changed(m_SensorString6);
}

void SensorData::setSensorString7(const QString &SensorString7)
{
    if (m_SensorString7 == SensorString7)
        return;
    m_SensorString7 = SensorString7;
    emit sensorString7Changed(m_SensorString7);
}

void SensorData::setSensorString8(const QString &SensorString8)
{
    if (m_SensorString8 == SensorString8)
        return;
    m_SensorString8 = SensorString8;
    emit sensorString8Changed(m_SensorString8);
}

// * Setters - Aux calculations
void SensorData::setauxcalc1(qreal auxcalc1)
{
    if (qFuzzyCompare(m_auxcalc1, auxcalc1))
        return;
    m_auxcalc1 = auxcalc1;
    emit auxcalc1Changed(m_auxcalc1);
}

void SensorData::setauxcalc2(qreal auxcalc2)
{
    if (qFuzzyCompare(m_auxcalc2, auxcalc2))
        return;
    m_auxcalc2 = auxcalc2;
    emit auxcalc2Changed(m_auxcalc2);
}

void SensorData::setauxcalc3(qreal auxcalc3)
{
    if (qFuzzyCompare(m_auxcalc3, auxcalc3))
        return;
    m_auxcalc3 = auxcalc3;
    emit auxcalc3Changed(m_auxcalc3);
}

void SensorData::setauxcalc4(qreal auxcalc4)
{
    if (qFuzzyCompare(m_auxcalc4, auxcalc4))
        return;
    m_auxcalc4 = auxcalc4;
    emit auxcalc4Changed(m_auxcalc4);
}
