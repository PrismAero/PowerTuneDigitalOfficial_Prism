/**
 * @file VehicleData.h
 * @brief Vehicle-level data model for PowerTune
 */

#ifndef VEHICLEDATA_H
#define VEHICLEDATA_H

#include <QObject>

class VehicleData : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int Gear READ Gear WRITE setGear NOTIFY GearChanged)
    Q_PROPERTY(int DfiSerialGear READ DfiSerialGear WRITE setDfiSerialGear NOTIFY DfiSerialGearChanged)
    Q_PROPERTY(int GearCalculation READ GearCalculation WRITE setGearCalculation NOTIFY GearCalculationChanged)
    Q_PROPERTY(qreal Odo READ Odo WRITE setOdo NOTIFY odoChanged)
    Q_PROPERTY(qreal Trip READ Trip WRITE setTrip NOTIFY tripChanged)
    Q_PROPERTY(int Weight READ Weight WRITE setWeight NOTIFY weightChanged)

public:
    explicit VehicleData(QObject *parent = nullptr);

    int Gear() const { return m_Gear; }
    int DfiSerialGear() const { return m_DfiSerialGear; }
    int GearCalculation() const { return m_GearCalculation; }
    qreal Odo() const { return m_Odo; }
    qreal Trip() const { return m_Trip; }
    int Weight() const { return m_Weight; }

public slots:
    void setGear(int Gear);
    void setDfiSerialGear(int Gear);
    void setGearCalculation(int GearCalculation);
    void setOdo(qreal Odo);
    void setTrip(qreal Trip);
    void setWeight(int Weight);

signals:
    void GearChanged(int Gear);
    void DfiSerialGearChanged(int Gear);
    void GearCalculationChanged(int GearCalculation);
    void odoChanged(qreal Odo);
    void tripChanged(qreal Trip);
    void weightChanged(int Weight);

private:
    int m_Gear = 0;
    int m_DfiSerialGear = 0;
    int m_GearCalculation = 0;
    qreal m_Odo = 0;
    qreal m_Trip = 0;
    int m_Weight = 0;
};

#endif  // VEHICLEDATA_H
