/**
 * @file VehicleData.h
 * @brief Vehicle-level data model for PowerTune
 *
 * This class encapsulates vehicle-related sensor data including:
 * - Speed, gear, odometer, trip
 * - Wheel speeds (4 corners)
 * - Brake/clutch state
 * - Indicators, lights
 * - Steering wheel angle
 * - Tire temps/pressures (4 corners)
 * - Accelerometer/gyroscope data
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#ifndef VEHICLEDATA_H
#define VEHICLEDATA_H

#include <QObject>
#include <QString>

class VehicleData : public QObject
{
    Q_OBJECT

    // * Speed & Distance
    Q_PROPERTY(qreal speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(qreal Odo READ Odo WRITE setOdo NOTIFY odoChanged)
    Q_PROPERTY(qreal Trip READ Trip WRITE setTrip NOTIFY tripChanged)
    Q_PROPERTY(qreal MVSS READ MVSS WRITE setMVSS NOTIFY mVSSChanged)
    Q_PROPERTY(qreal SVSS READ SVSS WRITE setSVSS NOTIFY sVSSChanged)
    Q_PROPERTY(qreal distancetoempty READ distancetoempty WRITE setdistancetoempty NOTIFY distancetoemptyChanged)
    Q_PROPERTY(qreal speedpercent READ speedpercent WRITE setspeedpercent NOTIFY speedpercentChanged)
    Q_PROPERTY(qreal pulsespermile READ pulsespermile WRITE setpulsespermile NOTIFY pulsespermileChanged)
    Q_PROPERTY(qreal undrivenavgspeed READ undrivenavgspeed WRITE setundrivenavgspeed NOTIFY undrivenavgspeedChanged)
    Q_PROPERTY(qreal drivenavgspeed READ drivenavgspeed WRITE setdrivenavgspeed NOTIFY drivenavgspeedChanged)

    // * Gear
    Q_PROPERTY(qreal Gear READ Gear WRITE setGear NOTIFY GearChanged)
    Q_PROPERTY(qreal GearCalculation READ GearCalculation WRITE setGearCalculation NOTIFY GearCalculationChanged)
    Q_PROPERTY(qreal gearswitch READ gearswitch WRITE setgearswitch NOTIFY gearswitchChanged)
    Q_PROPERTY(QString autogear READ autogear WRITE setautogear NOTIFY autogearChanged)
    Q_PROPERTY(qreal Gearoffset READ Gearoffset WRITE setGearoffset NOTIFY GearoffsetChanged)
    Q_PROPERTY(qreal FuelLevel READ FuelLevel WRITE setFuelLevel NOTIFY FuelLevelChanged)

    // * Wheel Speeds
    Q_PROPERTY(qreal wheelspdftleft READ wheelspdftleft WRITE setwheelspdftleft NOTIFY wheelspdftleftChanged)
    Q_PROPERTY(qreal wheelspdftright READ wheelspdftright WRITE setwheelspdftright NOTIFY wheelspdftrightChanged)
    Q_PROPERTY(qreal wheelspdrearleft READ wheelspdrearleft WRITE setwheelspdrearleft NOTIFY wheelspdrearleftChanged)
    Q_PROPERTY(
        qreal wheelspdrearright READ wheelspdrearright WRITE setwheelspdrearright NOTIFY wheelspdrearrightChanged)
    Q_PROPERTY(qreal wheeldiff READ wheeldiff WRITE setwheeldiff NOTIFY wheeldiffChanged)
    Q_PROPERTY(qreal wheelslip READ wheelslip WRITE setwheelslip NOTIFY wheelslipChanged)

    // * Tire Temperatures
    Q_PROPERTY(qreal TiretempLF READ TiretempLF WRITE setTiretempLF NOTIFY TiretempLFChanged)
    Q_PROPERTY(qreal TiretempRF READ TiretempRF WRITE setTiretempRF NOTIFY TiretempRFChanged)
    Q_PROPERTY(qreal TiretempLR READ TiretempLR WRITE setTiretempLR NOTIFY TiretempLRChanged)
    Q_PROPERTY(qreal TiretempRR READ TiretempRR WRITE setTiretempRR NOTIFY TiretempRRChanged)

    // * Tire Pressures
    Q_PROPERTY(qreal TirepresLF READ TirepresLF WRITE setTirepresLF NOTIFY TirepresLFChanged)
    Q_PROPERTY(qreal TirepresRF READ TirepresRF WRITE setTirepresRF NOTIFY TirepresRFChanged)
    Q_PROPERTY(qreal TirepresLR READ TirepresLR WRITE setTirepresLR NOTIFY TirepresLRChanged)
    Q_PROPERTY(qreal TirepresRR READ TirepresRR WRITE setTirepresRR NOTIFY TirepresRRChanged)

    // * Detailed Tire Temperatures (8 sensors per corner)
    Q_PROPERTY(qreal LF_Tyre_Temp_01 READ LF_Tyre_Temp_01 WRITE setLF_Tyre_Temp_01 NOTIFY LF_Tyre_Temp_01Changed)
    Q_PROPERTY(qreal LF_Tyre_Temp_02 READ LF_Tyre_Temp_02 WRITE setLF_Tyre_Temp_02 NOTIFY LF_Tyre_Temp_02Changed)
    Q_PROPERTY(qreal LF_Tyre_Temp_03 READ LF_Tyre_Temp_03 WRITE setLF_Tyre_Temp_03 NOTIFY LF_Tyre_Temp_03Changed)
    Q_PROPERTY(qreal LF_Tyre_Temp_04 READ LF_Tyre_Temp_04 WRITE setLF_Tyre_Temp_04 NOTIFY LF_Tyre_Temp_04Changed)
    Q_PROPERTY(qreal LF_Tyre_Temp_05 READ LF_Tyre_Temp_05 WRITE setLF_Tyre_Temp_05 NOTIFY LF_Tyre_Temp_05Changed)
    Q_PROPERTY(qreal LF_Tyre_Temp_06 READ LF_Tyre_Temp_06 WRITE setLF_Tyre_Temp_06 NOTIFY LF_Tyre_Temp_06Changed)
    Q_PROPERTY(qreal LF_Tyre_Temp_07 READ LF_Tyre_Temp_07 WRITE setLF_Tyre_Temp_07 NOTIFY LF_Tyre_Temp_07Changed)
    Q_PROPERTY(qreal LF_Tyre_Temp_08 READ LF_Tyre_Temp_08 WRITE setLF_Tyre_Temp_08 NOTIFY LF_Tyre_Temp_08Changed)

    Q_PROPERTY(qreal RF_Tyre_Temp_01 READ RF_Tyre_Temp_01 WRITE setRF_Tyre_Temp_01 NOTIFY RF_Tyre_Temp_01Changed)
    Q_PROPERTY(qreal RF_Tyre_Temp_02 READ RF_Tyre_Temp_02 WRITE setRF_Tyre_Temp_02 NOTIFY RF_Tyre_Temp_02Changed)
    Q_PROPERTY(qreal RF_Tyre_Temp_03 READ RF_Tyre_Temp_03 WRITE setRF_Tyre_Temp_03 NOTIFY RF_Tyre_Temp_03Changed)
    Q_PROPERTY(qreal RF_Tyre_Temp_04 READ RF_Tyre_Temp_04 WRITE setRF_Tyre_Temp_04 NOTIFY RF_Tyre_Temp_04Changed)
    Q_PROPERTY(qreal RF_Tyre_Temp_05 READ RF_Tyre_Temp_05 WRITE setRF_Tyre_Temp_05 NOTIFY RF_Tyre_Temp_05Changed)
    Q_PROPERTY(qreal RF_Tyre_Temp_06 READ RF_Tyre_Temp_06 WRITE setRF_Tyre_Temp_06 NOTIFY RF_Tyre_Temp_06Changed)
    Q_PROPERTY(qreal RF_Tyre_Temp_07 READ RF_Tyre_Temp_07 WRITE setRF_Tyre_Temp_07 NOTIFY RF_Tyre_Temp_07Changed)
    Q_PROPERTY(qreal RF_Tyre_Temp_08 READ RF_Tyre_Temp_08 WRITE setRF_Tyre_Temp_08 NOTIFY RF_Tyre_Temp_08Changed)

    Q_PROPERTY(qreal LR_Tyre_Temp_01 READ LR_Tyre_Temp_01 WRITE setLR_Tyre_Temp_01 NOTIFY LR_Tyre_Temp_01Changed)
    Q_PROPERTY(qreal LR_Tyre_Temp_02 READ LR_Tyre_Temp_02 WRITE setLR_Tyre_Temp_02 NOTIFY LR_Tyre_Temp_02Changed)
    Q_PROPERTY(qreal LR_Tyre_Temp_03 READ LR_Tyre_Temp_03 WRITE setLR_Tyre_Temp_03 NOTIFY LR_Tyre_Temp_03Changed)
    Q_PROPERTY(qreal LR_Tyre_Temp_04 READ LR_Tyre_Temp_04 WRITE setLR_Tyre_Temp_04 NOTIFY LR_Tyre_Temp_04Changed)
    Q_PROPERTY(qreal LR_Tyre_Temp_05 READ LR_Tyre_Temp_05 WRITE setLR_Tyre_Temp_05 NOTIFY LR_Tyre_Temp_05Changed)
    Q_PROPERTY(qreal LR_Tyre_Temp_06 READ LR_Tyre_Temp_06 WRITE setLR_Tyre_Temp_06 NOTIFY LR_Tyre_Temp_06Changed)
    Q_PROPERTY(qreal LR_Tyre_Temp_07 READ LR_Tyre_Temp_07 WRITE setLR_Tyre_Temp_07 NOTIFY LR_Tyre_Temp_07Changed)
    Q_PROPERTY(qreal LR_Tyre_Temp_08 READ LR_Tyre_Temp_08 WRITE setLR_Tyre_Temp_08 NOTIFY LR_Tyre_Temp_08Changed)

    Q_PROPERTY(qreal RR_Tyre_Temp_01 READ RR_Tyre_Temp_01 WRITE setRR_Tyre_Temp_01 NOTIFY RR_Tyre_Temp_01Changed)
    Q_PROPERTY(qreal RR_Tyre_Temp_02 READ RR_Tyre_Temp_02 WRITE setRR_Tyre_Temp_02 NOTIFY RR_Tyre_Temp_02Changed)
    Q_PROPERTY(qreal RR_Tyre_Temp_03 READ RR_Tyre_Temp_03 WRITE setRR_Tyre_Temp_03 NOTIFY RR_Tyre_Temp_03Changed)
    Q_PROPERTY(qreal RR_Tyre_Temp_04 READ RR_Tyre_Temp_04 WRITE setRR_Tyre_Temp_04 NOTIFY RR_Tyre_Temp_04Changed)
    Q_PROPERTY(qreal RR_Tyre_Temp_05 READ RR_Tyre_Temp_05 WRITE setRR_Tyre_Temp_05 NOTIFY RR_Tyre_Temp_05Changed)
    Q_PROPERTY(qreal RR_Tyre_Temp_06 READ RR_Tyre_Temp_06 WRITE setRR_Tyre_Temp_06 NOTIFY RR_Tyre_Temp_06Changed)
    Q_PROPERTY(qreal RR_Tyre_Temp_07 READ RR_Tyre_Temp_07 WRITE setRR_Tyre_Temp_07 NOTIFY RR_Tyre_Temp_07Changed)
    Q_PROPERTY(qreal RR_Tyre_Temp_08 READ RR_Tyre_Temp_08 WRITE setRR_Tyre_Temp_08 NOTIFY RR_Tyre_Temp_08Changed)

    // * Steering
    Q_PROPERTY(
        qreal SteeringWheelAngle READ SteeringWheelAngle WRITE setSteeringWheelAngle NOTIFY SteeringWheelAngleChanged)

    // * Controls State
    Q_PROPERTY(qreal accelpedpos READ accelpedpos WRITE setaccelpedpos NOTIFY accelpedposChanged)
    Q_PROPERTY(
        qreal clutchswitchstate READ clutchswitchstate WRITE setclutchswitchstate NOTIFY clutchswitchstateChanged)
    Q_PROPERTY(qreal handbrake READ handbrake WRITE sethandbrake NOTIFY handbrakeChanged)

    // * Lights/Indicators
    Q_PROPERTY(qreal highbeam READ highbeam WRITE sethighbeam NOTIFY highbeamChanged)
    Q_PROPERTY(qreal lowBeam READ lowBeam WRITE setlowBeam NOTIFY lowBeamChanged)
    Q_PROPERTY(qreal leftindicator READ leftindicator WRITE setleftindicator NOTIFY leftindicatorChanged)
    Q_PROPERTY(qreal rightindicator READ rightindicator WRITE setrightindicator NOTIFY rightindicatorChanged)

    // * Accelerometer
    Q_PROPERTY(qreal accelx READ accelx WRITE setaccelx NOTIFY accelxChanged)
    Q_PROPERTY(qreal accely READ accely WRITE setaccely NOTIFY accelyChanged)
    Q_PROPERTY(qreal accelz READ accelz WRITE setaccelz NOTIFY accelzChanged)
    Q_PROPERTY(qreal AccelTimer READ AccelTimer WRITE setAccelTimer NOTIFY accelTimerChanged)

    // * Gyroscope
    Q_PROPERTY(qreal gyrox READ gyrox WRITE setgyrox NOTIFY gyroxChanged)
    Q_PROPERTY(qreal gyroy READ gyroy WRITE setgyroy NOTIFY gyroyChanged)
    Q_PROPERTY(qreal gyroz READ gyroz WRITE setgyroz NOTIFY gyrozChanged)

    // * Compass/Environment
    Q_PROPERTY(qreal compass READ compass WRITE setcompass NOTIFY compassChanged)
    Q_PROPERTY(qreal ambitemp READ ambitemp WRITE setambitemp NOTIFY ambitempChanged)
    Q_PROPERTY(qreal ambipress READ ambipress WRITE setambipress NOTIFY ambipressChanged)

    // * Weight
    Q_PROPERTY(qreal Weight READ Weight WRITE setWeight NOTIFY weightChanged)

public:
    explicit VehicleData(QObject *parent = nullptr);

    // * Getters - Speed & Distance
    qreal speed() const { return m_speed; }
    qreal Odo() const { return m_Odo; }
    qreal Trip() const { return m_Trip; }
    qreal MVSS() const { return m_MVSS; }
    qreal SVSS() const { return m_SVSS; }
    qreal distancetoempty() const { return m_distancetoempty; }
    qreal speedpercent() const { return m_speedpercent; }
    qreal pulsespermile() const { return m_pulsespermile; }
    qreal undrivenavgspeed() const { return m_undrivenavgspeed; }
    qreal drivenavgspeed() const { return m_drivenavgspeed; }

    // * Getters - Gear
    qreal Gear() const { return m_Gear; }
    qreal GearCalculation() const { return m_GearCalculation; }
    qreal gearswitch() const { return m_gearswitch; }
    QString autogear() const { return m_autogear; }
    qreal Gearoffset() const { return m_Gearoffset; }
    qreal FuelLevel() const { return m_FuelLevel; }

    // * Getters - Wheel Speeds
    qreal wheelspdftleft() const { return m_wheelspdftleft; }
    qreal wheelspdftright() const { return m_wheelspdftright; }
    qreal wheelspdrearleft() const { return m_wheelspdrearleft; }
    qreal wheelspdrearright() const { return m_wheelspdrearright; }
    qreal wheeldiff() const { return m_wheeldiff; }
    qreal wheelslip() const { return m_wheelslip; }

    // * Getters - Tire Temperatures
    qreal TiretempLF() const { return m_TiretempLF; }
    qreal TiretempRF() const { return m_TiretempRF; }
    qreal TiretempLR() const { return m_TiretempLR; }
    qreal TiretempRR() const { return m_TiretempRR; }

    // * Getters - Tire Pressures
    qreal TirepresLF() const { return m_TirepresLF; }
    qreal TirepresRF() const { return m_TirepresRF; }
    qreal TirepresLR() const { return m_TirepresLR; }
    qreal TirepresRR() const { return m_TirepresRR; }

    // * Getters - Detailed Tire Temps LF
    qreal LF_Tyre_Temp_01() const { return m_LF_Tyre_Temp_01; }
    qreal LF_Tyre_Temp_02() const { return m_LF_Tyre_Temp_02; }
    qreal LF_Tyre_Temp_03() const { return m_LF_Tyre_Temp_03; }
    qreal LF_Tyre_Temp_04() const { return m_LF_Tyre_Temp_04; }
    qreal LF_Tyre_Temp_05() const { return m_LF_Tyre_Temp_05; }
    qreal LF_Tyre_Temp_06() const { return m_LF_Tyre_Temp_06; }
    qreal LF_Tyre_Temp_07() const { return m_LF_Tyre_Temp_07; }
    qreal LF_Tyre_Temp_08() const { return m_LF_Tyre_Temp_08; }

    // * Getters - Detailed Tire Temps RF
    qreal RF_Tyre_Temp_01() const { return m_RF_Tyre_Temp_01; }
    qreal RF_Tyre_Temp_02() const { return m_RF_Tyre_Temp_02; }
    qreal RF_Tyre_Temp_03() const { return m_RF_Tyre_Temp_03; }
    qreal RF_Tyre_Temp_04() const { return m_RF_Tyre_Temp_04; }
    qreal RF_Tyre_Temp_05() const { return m_RF_Tyre_Temp_05; }
    qreal RF_Tyre_Temp_06() const { return m_RF_Tyre_Temp_06; }
    qreal RF_Tyre_Temp_07() const { return m_RF_Tyre_Temp_07; }
    qreal RF_Tyre_Temp_08() const { return m_RF_Tyre_Temp_08; }

    // * Getters - Detailed Tire Temps LR
    qreal LR_Tyre_Temp_01() const { return m_LR_Tyre_Temp_01; }
    qreal LR_Tyre_Temp_02() const { return m_LR_Tyre_Temp_02; }
    qreal LR_Tyre_Temp_03() const { return m_LR_Tyre_Temp_03; }
    qreal LR_Tyre_Temp_04() const { return m_LR_Tyre_Temp_04; }
    qreal LR_Tyre_Temp_05() const { return m_LR_Tyre_Temp_05; }
    qreal LR_Tyre_Temp_06() const { return m_LR_Tyre_Temp_06; }
    qreal LR_Tyre_Temp_07() const { return m_LR_Tyre_Temp_07; }
    qreal LR_Tyre_Temp_08() const { return m_LR_Tyre_Temp_08; }

    // * Getters - Detailed Tire Temps RR
    qreal RR_Tyre_Temp_01() const { return m_RR_Tyre_Temp_01; }
    qreal RR_Tyre_Temp_02() const { return m_RR_Tyre_Temp_02; }
    qreal RR_Tyre_Temp_03() const { return m_RR_Tyre_Temp_03; }
    qreal RR_Tyre_Temp_04() const { return m_RR_Tyre_Temp_04; }
    qreal RR_Tyre_Temp_05() const { return m_RR_Tyre_Temp_05; }
    qreal RR_Tyre_Temp_06() const { return m_RR_Tyre_Temp_06; }
    qreal RR_Tyre_Temp_07() const { return m_RR_Tyre_Temp_07; }
    qreal RR_Tyre_Temp_08() const { return m_RR_Tyre_Temp_08; }

    // * Getters - Steering
    qreal SteeringWheelAngle() const { return m_SteeringWheelAngle; }

    // * Getters - Controls State
    qreal accelpedpos() const { return m_accelpedpos; }
    qreal clutchswitchstate() const { return m_clutchswitchstate; }
    qreal handbrake() const { return m_handbrake; }

    // * Getters - Lights/Indicators
    qreal highbeam() const { return m_highbeam; }
    qreal lowBeam() const { return m_lowBeam; }
    qreal leftindicator() const { return m_leftindicator; }
    qreal rightindicator() const { return m_rightindicator; }

    // * Getters - Accelerometer
    qreal accelx() const { return m_accelx; }
    qreal accely() const { return m_accely; }
    qreal accelz() const { return m_accelz; }
    qreal AccelTimer() const { return m_AccelTimer; }

    // * Getters - Gyroscope
    qreal gyrox() const { return m_gyrox; }
    qreal gyroy() const { return m_gyroy; }
    qreal gyroz() const { return m_gyroz; }

    // * Getters - Compass/Environment
    qreal compass() const { return m_compass; }
    qreal ambitemp() const { return m_ambitemp; }
    qreal ambipress() const { return m_ambipress; }

    // * Getters - Weight
    qreal Weight() const { return m_Weight; }

public slots:
    // * Setters - Speed & Distance
    void setSpeed(qreal speed);
    void setOdo(qreal Odo);
    void setTrip(qreal Trip);
    void setMVSS(qreal MVSS);
    void setSVSS(qreal SVSS);
    void setdistancetoempty(qreal distancetoempty);
    void setspeedpercent(qreal speedpercent);
    void setpulsespermile(qreal pulsespermile);
    void setundrivenavgspeed(qreal undrivenavgspeed);
    void setdrivenavgspeed(qreal drivenavgspeed);

    // * Setters - Gear
    void setGear(qreal Gear);
    void setGearCalculation(qreal GearCalculation);
    void setgearswitch(qreal gearswitch);
    void setautogear(const QString &autogear);
    void setGearoffset(qreal Gearoffset);
    void setFuelLevel(qreal FuelLevel);

    // * Setters - Wheel Speeds
    void setwheelspdftleft(qreal wheelspdftleft);
    void setwheelspdftright(qreal wheelspdftright);
    void setwheelspdrearleft(qreal wheelspdrearleft);
    void setwheelspdrearright(qreal wheelspdrearright);
    void setwheeldiff(qreal wheeldiff);
    void setwheelslip(qreal wheelslip);

    // * Setters - Tire Temperatures
    void setTiretempLF(qreal TiretempLF);
    void setTiretempRF(qreal TiretempRF);
    void setTiretempLR(qreal TiretempLR);
    void setTiretempRR(qreal TiretempRR);

    // * Setters - Tire Pressures
    void setTirepresLF(qreal TirepresLF);
    void setTirepresRF(qreal TirepresRF);
    void setTirepresLR(qreal TirepresLR);
    void setTirepresRR(qreal TirepresRR);

    // * Setters - Detailed Tire Temps LF
    void setLF_Tyre_Temp_01(qreal LF_Tyre_Temp_01);
    void setLF_Tyre_Temp_02(qreal LF_Tyre_Temp_02);
    void setLF_Tyre_Temp_03(qreal LF_Tyre_Temp_03);
    void setLF_Tyre_Temp_04(qreal LF_Tyre_Temp_04);
    void setLF_Tyre_Temp_05(qreal LF_Tyre_Temp_05);
    void setLF_Tyre_Temp_06(qreal LF_Tyre_Temp_06);
    void setLF_Tyre_Temp_07(qreal LF_Tyre_Temp_07);
    void setLF_Tyre_Temp_08(qreal LF_Tyre_Temp_08);

    // * Setters - Detailed Tire Temps RF
    void setRF_Tyre_Temp_01(qreal RF_Tyre_Temp_01);
    void setRF_Tyre_Temp_02(qreal RF_Tyre_Temp_02);
    void setRF_Tyre_Temp_03(qreal RF_Tyre_Temp_03);
    void setRF_Tyre_Temp_04(qreal RF_Tyre_Temp_04);
    void setRF_Tyre_Temp_05(qreal RF_Tyre_Temp_05);
    void setRF_Tyre_Temp_06(qreal RF_Tyre_Temp_06);
    void setRF_Tyre_Temp_07(qreal RF_Tyre_Temp_07);
    void setRF_Tyre_Temp_08(qreal RF_Tyre_Temp_08);

    // * Setters - Detailed Tire Temps LR
    void setLR_Tyre_Temp_01(qreal LR_Tyre_Temp_01);
    void setLR_Tyre_Temp_02(qreal LR_Tyre_Temp_02);
    void setLR_Tyre_Temp_03(qreal LR_Tyre_Temp_03);
    void setLR_Tyre_Temp_04(qreal LR_Tyre_Temp_04);
    void setLR_Tyre_Temp_05(qreal LR_Tyre_Temp_05);
    void setLR_Tyre_Temp_06(qreal LR_Tyre_Temp_06);
    void setLR_Tyre_Temp_07(qreal LR_Tyre_Temp_07);
    void setLR_Tyre_Temp_08(qreal LR_Tyre_Temp_08);

    // * Setters - Detailed Tire Temps RR
    void setRR_Tyre_Temp_01(qreal RR_Tyre_Temp_01);
    void setRR_Tyre_Temp_02(qreal RR_Tyre_Temp_02);
    void setRR_Tyre_Temp_03(qreal RR_Tyre_Temp_03);
    void setRR_Tyre_Temp_04(qreal RR_Tyre_Temp_04);
    void setRR_Tyre_Temp_05(qreal RR_Tyre_Temp_05);
    void setRR_Tyre_Temp_06(qreal RR_Tyre_Temp_06);
    void setRR_Tyre_Temp_07(qreal RR_Tyre_Temp_07);
    void setRR_Tyre_Temp_08(qreal RR_Tyre_Temp_08);

    // * Setters - Steering
    void setSteeringWheelAngle(qreal SteeringWheelAngle);

    // * Setters - Controls State
    void setaccelpedpos(qreal accelpedpos);
    void setclutchswitchstate(qreal clutchswitchstate);
    void sethandbrake(qreal handbrake);

    // * Setters - Lights/Indicators
    void sethighbeam(qreal highbeam);
    void setlowBeam(qreal lowBeam);
    void setleftindicator(qreal leftindicator);
    void setrightindicator(qreal rightindicator);

    // * Setters - Accelerometer
    void setaccelx(qreal accelx);
    void setaccely(qreal accely);
    void setaccelz(qreal accelz);
    void setAccelTimer(qreal AccelTimer);

    // * Setters - Gyroscope
    void setgyrox(qreal gyrox);
    void setgyroy(qreal gyroy);
    void setgyroz(qreal gyroz);

    // * Setters - Compass/Environment
    void setcompass(qreal compass);
    void setambitemp(qreal ambitemp);
    void setambipress(qreal ambipress);

    // * Setters - Weight
    void setWeight(qreal Weight);

signals:
    // * Signals - Speed & Distance
    void speedChanged(qreal speed);
    void odoChanged(qreal Odo);
    void tripChanged(qreal Trip);
    void mVSSChanged(qreal MVSS);
    void sVSSChanged(qreal SVSS);
    void distancetoemptyChanged(qreal distancetoempty);
    void speedpercentChanged(qreal speedpercent);
    void pulsespermileChanged(qreal pulsespermile);
    void undrivenavgspeedChanged(qreal undrivenavgspeed);
    void drivenavgspeedChanged(qreal drivenavgspeed);

    // * Signals - Gear
    void GearChanged(qreal Gear);
    void GearCalculationChanged(qreal GearCalculation);
    void gearswitchChanged(qreal gearswitch);
    void autogearChanged(const QString &autogear);
    void GearoffsetChanged(qreal Gearoffset);
    void FuelLevelChanged(qreal FuelLevel);

    // * Signals - Wheel Speeds
    void wheelspdftleftChanged(qreal wheelspdftleft);
    void wheelspdftrightChanged(qreal wheelspdftright);
    void wheelspdrearleftChanged(qreal wheelspdrearleft);
    void wheelspdrearrightChanged(qreal wheelspdrearright);
    void wheeldiffChanged(qreal wheeldiff);
    void wheelslipChanged(qreal wheelslip);

    // * Signals - Tire Temperatures
    void TiretempLFChanged(qreal TiretempLF);
    void TiretempRFChanged(qreal TiretempRF);
    void TiretempLRChanged(qreal TiretempLR);
    void TiretempRRChanged(qreal TiretempRR);

    // * Signals - Tire Pressures
    void TirepresLFChanged(qreal TirepresLF);
    void TirepresRFChanged(qreal TirepresRF);
    void TirepresLRChanged(qreal TirepresLR);
    void TirepresRRChanged(qreal TirepresRR);

    // * Signals - Detailed Tire Temps LF
    void LF_Tyre_Temp_01Changed(qreal LF_Tyre_Temp_01);
    void LF_Tyre_Temp_02Changed(qreal LF_Tyre_Temp_02);
    void LF_Tyre_Temp_03Changed(qreal LF_Tyre_Temp_03);
    void LF_Tyre_Temp_04Changed(qreal LF_Tyre_Temp_04);
    void LF_Tyre_Temp_05Changed(qreal LF_Tyre_Temp_05);
    void LF_Tyre_Temp_06Changed(qreal LF_Tyre_Temp_06);
    void LF_Tyre_Temp_07Changed(qreal LF_Tyre_Temp_07);
    void LF_Tyre_Temp_08Changed(qreal LF_Tyre_Temp_08);

    // * Signals - Detailed Tire Temps RF
    void RF_Tyre_Temp_01Changed(qreal RF_Tyre_Temp_01);
    void RF_Tyre_Temp_02Changed(qreal RF_Tyre_Temp_02);
    void RF_Tyre_Temp_03Changed(qreal RF_Tyre_Temp_03);
    void RF_Tyre_Temp_04Changed(qreal RF_Tyre_Temp_04);
    void RF_Tyre_Temp_05Changed(qreal RF_Tyre_Temp_05);
    void RF_Tyre_Temp_06Changed(qreal RF_Tyre_Temp_06);
    void RF_Tyre_Temp_07Changed(qreal RF_Tyre_Temp_07);
    void RF_Tyre_Temp_08Changed(qreal RF_Tyre_Temp_08);

    // * Signals - Detailed Tire Temps LR
    void LR_Tyre_Temp_01Changed(qreal LR_Tyre_Temp_01);
    void LR_Tyre_Temp_02Changed(qreal LR_Tyre_Temp_02);
    void LR_Tyre_Temp_03Changed(qreal LR_Tyre_Temp_03);
    void LR_Tyre_Temp_04Changed(qreal LR_Tyre_Temp_04);
    void LR_Tyre_Temp_05Changed(qreal LR_Tyre_Temp_05);
    void LR_Tyre_Temp_06Changed(qreal LR_Tyre_Temp_06);
    void LR_Tyre_Temp_07Changed(qreal LR_Tyre_Temp_07);
    void LR_Tyre_Temp_08Changed(qreal LR_Tyre_Temp_08);

    // * Signals - Detailed Tire Temps RR
    void RR_Tyre_Temp_01Changed(qreal RR_Tyre_Temp_01);
    void RR_Tyre_Temp_02Changed(qreal RR_Tyre_Temp_02);
    void RR_Tyre_Temp_03Changed(qreal RR_Tyre_Temp_03);
    void RR_Tyre_Temp_04Changed(qreal RR_Tyre_Temp_04);
    void RR_Tyre_Temp_05Changed(qreal RR_Tyre_Temp_05);
    void RR_Tyre_Temp_06Changed(qreal RR_Tyre_Temp_06);
    void RR_Tyre_Temp_07Changed(qreal RR_Tyre_Temp_07);
    void RR_Tyre_Temp_08Changed(qreal RR_Tyre_Temp_08);

    // * Signals - Steering
    void SteeringWheelAngleChanged(qreal SteeringWheelAngle);

    // * Signals - Controls State
    void accelpedposChanged(qreal accelpedpos);
    void clutchswitchstateChanged(qreal clutchswitchstate);
    void handbrakeChanged(qreal handbrake);

    // * Signals - Lights/Indicators
    void highbeamChanged(qreal highbeam);
    void lowBeamChanged(qreal lowBeam);
    void leftindicatorChanged(qreal leftindicator);
    void rightindicatorChanged(qreal rightindicator);

    // * Signals - Accelerometer
    void accelxChanged(qreal accelx);
    void accelyChanged(qreal accely);
    void accelzChanged(qreal accelz);
    void accelTimerChanged(qreal AccelTimer);

    // * Signals - Gyroscope
    void gyroxChanged(qreal gyrox);
    void gyroyChanged(qreal gyroy);
    void gyrozChanged(qreal gyroz);

    // * Signals - Compass/Environment
    void compassChanged(qreal compass);
    void ambitempChanged(qreal ambitemp);
    void ambipressChanged(qreal ambipress);

    // * Signals - Weight
    void weightChanged(qreal Weight);

private:
    // * Speed & Distance
    qreal m_speed = 0;
    qreal m_Odo = 0;
    qreal m_Trip = 0;
    qreal m_MVSS = 0;
    qreal m_SVSS = 0;
    qreal m_distancetoempty = 0;
    qreal m_speedpercent = 0;
    qreal m_pulsespermile = 0;
    qreal m_undrivenavgspeed = 0;
    qreal m_drivenavgspeed = 0;

    // * Gear
    qreal m_Gear = 0;
    qreal m_GearCalculation = 0;
    qreal m_gearswitch = 0;
    QString m_autogear;
    qreal m_Gearoffset = 0;
    qreal m_FuelLevel = 0;

    // * Wheel Speeds
    qreal m_wheelspdftleft = 0;
    qreal m_wheelspdftright = 0;
    qreal m_wheelspdrearleft = 0;
    qreal m_wheelspdrearright = 0;
    qreal m_wheeldiff = 0;
    qreal m_wheelslip = 0;

    // * Tire Temperatures
    qreal m_TiretempLF = 0;
    qreal m_TiretempRF = 0;
    qreal m_TiretempLR = 0;
    qreal m_TiretempRR = 0;

    // * Tire Pressures
    qreal m_TirepresLF = 0;
    qreal m_TirepresRF = 0;
    qreal m_TirepresLR = 0;
    qreal m_TirepresRR = 0;

    // * Detailed Tire Temps LF
    qreal m_LF_Tyre_Temp_01 = 0;
    qreal m_LF_Tyre_Temp_02 = 0;
    qreal m_LF_Tyre_Temp_03 = 0;
    qreal m_LF_Tyre_Temp_04 = 0;
    qreal m_LF_Tyre_Temp_05 = 0;
    qreal m_LF_Tyre_Temp_06 = 0;
    qreal m_LF_Tyre_Temp_07 = 0;
    qreal m_LF_Tyre_Temp_08 = 0;

    // * Detailed Tire Temps RF
    qreal m_RF_Tyre_Temp_01 = 0;
    qreal m_RF_Tyre_Temp_02 = 0;
    qreal m_RF_Tyre_Temp_03 = 0;
    qreal m_RF_Tyre_Temp_04 = 0;
    qreal m_RF_Tyre_Temp_05 = 0;
    qreal m_RF_Tyre_Temp_06 = 0;
    qreal m_RF_Tyre_Temp_07 = 0;
    qreal m_RF_Tyre_Temp_08 = 0;

    // * Detailed Tire Temps LR
    qreal m_LR_Tyre_Temp_01 = 0;
    qreal m_LR_Tyre_Temp_02 = 0;
    qreal m_LR_Tyre_Temp_03 = 0;
    qreal m_LR_Tyre_Temp_04 = 0;
    qreal m_LR_Tyre_Temp_05 = 0;
    qreal m_LR_Tyre_Temp_06 = 0;
    qreal m_LR_Tyre_Temp_07 = 0;
    qreal m_LR_Tyre_Temp_08 = 0;

    // * Detailed Tire Temps RR
    qreal m_RR_Tyre_Temp_01 = 0;
    qreal m_RR_Tyre_Temp_02 = 0;
    qreal m_RR_Tyre_Temp_03 = 0;
    qreal m_RR_Tyre_Temp_04 = 0;
    qreal m_RR_Tyre_Temp_05 = 0;
    qreal m_RR_Tyre_Temp_06 = 0;
    qreal m_RR_Tyre_Temp_07 = 0;
    qreal m_RR_Tyre_Temp_08 = 0;

    // * Steering
    qreal m_SteeringWheelAngle = 0;

    // * Controls State
    qreal m_accelpedpos = 0;
    qreal m_clutchswitchstate = 0;
    qreal m_handbrake = 0;

    // * Lights/Indicators
    qreal m_highbeam = 0;
    qreal m_lowBeam = 0;
    qreal m_leftindicator = 0;
    qreal m_rightindicator = 0;

    // * Accelerometer
    qreal m_accelx = 0;
    qreal m_accely = 0;
    qreal m_accelz = 0;
    qreal m_AccelTimer = 0;

    // * Gyroscope
    qreal m_gyrox = 0;
    qreal m_gyroy = 0;
    qreal m_gyroz = 0;

    // * Compass/Environment
    qreal m_compass = 0;
    qreal m_ambitemp = 0;
    qreal m_ambipress = 0;

    // * Weight
    qreal m_Weight = 0;
};

#endif  // VEHICLEDATA_H
