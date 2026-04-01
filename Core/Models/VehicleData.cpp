/**
 * @file VehicleData.cpp
 * @brief Implementation of the VehicleData class
 */

#include "VehicleData.h"

VehicleData::VehicleData(QObject *parent) : QObject(parent) {}

void VehicleData::setGear(int Gear)
{
    if (m_Gear != Gear) {
        m_Gear = Gear;
        emit GearChanged(Gear);
    }
}

void VehicleData::setGearCalculation(int GearCalculation)
{
    if (m_GearCalculation != GearCalculation) {
        m_GearCalculation = GearCalculation;
        emit GearCalculationChanged(GearCalculation);
    }
}

void VehicleData::setOdo(qreal Odo)
{
    if (m_Odo != Odo) {
        m_Odo = Odo;
        emit odoChanged(Odo);
    }
}

void VehicleData::setTrip(qreal Trip)
{
    if (m_Trip != Trip) {
        m_Trip = Trip;
        emit tripChanged(Trip);
    }
}

void VehicleData::setWeight(int Weight)
{
    if (m_Weight != Weight) {
        m_Weight = Weight;
        emit weightChanged(Weight);
    }
}
