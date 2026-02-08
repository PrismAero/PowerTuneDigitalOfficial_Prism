/**
 * @file VehicleData.cpp
 * @brief Implementation of the VehicleData class
 * 
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#include "VehicleData.h"

VehicleData::VehicleData(QObject *parent)
    : QObject(parent)
{
}

// * Setters - Speed & Distance
void VehicleData::setSpeed(qreal speed) {
    if (m_speed != speed) { m_speed = speed; emit speedChanged(speed); }
}
void VehicleData::setOdo(qreal Odo) {
    if (m_Odo != Odo) { m_Odo = Odo; emit odoChanged(Odo); }
}
void VehicleData::setTrip(qreal Trip) {
    if (m_Trip != Trip) { m_Trip = Trip; emit tripChanged(Trip); }
}
void VehicleData::setMVSS(qreal MVSS) {
    if (m_MVSS != MVSS) { m_MVSS = MVSS; emit mVSSChanged(MVSS); }
}
void VehicleData::setSVSS(qreal SVSS) {
    if (m_SVSS != SVSS) { m_SVSS = SVSS; emit sVSSChanged(SVSS); }
}
void VehicleData::setdistancetoempty(qreal distancetoempty) {
    if (m_distancetoempty != distancetoempty) { m_distancetoempty = distancetoempty; emit distancetoemptyChanged(distancetoempty); }
}
void VehicleData::setspeedpercent(qreal speedpercent) {
    if (m_speedpercent != speedpercent) { m_speedpercent = speedpercent; emit speedpercentChanged(speedpercent); }
}
void VehicleData::setpulsespermile(qreal pulsespermile) {
    if (m_pulsespermile != pulsespermile) { m_pulsespermile = pulsespermile; emit pulsespermileChanged(pulsespermile); }
}
void VehicleData::setundrivenavgspeed(qreal undrivenavgspeed) {
    if (m_undrivenavgspeed != undrivenavgspeed) { m_undrivenavgspeed = undrivenavgspeed; emit undrivenavgspeedChanged(undrivenavgspeed); }
}
void VehicleData::setdrivenavgspeed(qreal drivenavgspeed) {
    if (m_drivenavgspeed != drivenavgspeed) { m_drivenavgspeed = drivenavgspeed; emit drivenavgspeedChanged(drivenavgspeed); }
}

// * Setters - Gear
void VehicleData::setGear(qreal Gear) {
    if (m_Gear != Gear) { m_Gear = Gear; emit GearChanged(Gear); }
}
void VehicleData::setGearCalculation(qreal GearCalculation) {
    if (m_GearCalculation != GearCalculation) { m_GearCalculation = GearCalculation; emit GearCalculationChanged(GearCalculation); }
}
void VehicleData::setgearswitch(qreal gearswitch) {
    if (m_gearswitch != gearswitch) { m_gearswitch = gearswitch; emit gearswitchChanged(gearswitch); }
}
void VehicleData::setautogear(const QString &autogear) {
    if (m_autogear != autogear) { m_autogear = autogear; emit autogearChanged(autogear); }
}
void VehicleData::setFuelLevel(qreal FuelLevel) {
    if (m_FuelLevel != FuelLevel) { m_FuelLevel = FuelLevel; emit FuelLevelChanged(FuelLevel); }
}

// * Setters - Wheel Speeds
void VehicleData::setwheelspdftleft(qreal wheelspdftleft) {
    if (m_wheelspdftleft != wheelspdftleft) { m_wheelspdftleft = wheelspdftleft; emit wheelspdftleftChanged(wheelspdftleft); }
}
void VehicleData::setwheelspdftright(qreal wheelspdftright) {
    if (m_wheelspdftright != wheelspdftright) { m_wheelspdftright = wheelspdftright; emit wheelspdftrightChanged(wheelspdftright); }
}
void VehicleData::setwheelspdrearleft(qreal wheelspdrearleft) {
    if (m_wheelspdrearleft != wheelspdrearleft) { m_wheelspdrearleft = wheelspdrearleft; emit wheelspdrearleftChanged(wheelspdrearleft); }
}
void VehicleData::setwheelspdrearright(qreal wheelspdrearright) {
    if (m_wheelspdrearright != wheelspdrearright) { m_wheelspdrearright = wheelspdrearright; emit wheelspdrearrightChanged(wheelspdrearright); }
}
void VehicleData::setwheeldiff(qreal wheeldiff) {
    if (m_wheeldiff != wheeldiff) { m_wheeldiff = wheeldiff; emit wheeldiffChanged(wheeldiff); }
}
void VehicleData::setwheelslip(qreal wheelslip) {
    if (m_wheelslip != wheelslip) { m_wheelslip = wheelslip; emit wheelslipChanged(wheelslip); }
}

// * Setters - Tire Temperatures
void VehicleData::setTiretempLF(qreal TiretempLF) {
    if (m_TiretempLF != TiretempLF) { m_TiretempLF = TiretempLF; emit TiretempLFChanged(TiretempLF); }
}
void VehicleData::setTiretempRF(qreal TiretempRF) {
    if (m_TiretempRF != TiretempRF) { m_TiretempRF = TiretempRF; emit TiretempRFChanged(TiretempRF); }
}
void VehicleData::setTiretempLR(qreal TiretempLR) {
    if (m_TiretempLR != TiretempLR) { m_TiretempLR = TiretempLR; emit TiretempLRChanged(TiretempLR); }
}
void VehicleData::setTiretempRR(qreal TiretempRR) {
    if (m_TiretempRR != TiretempRR) { m_TiretempRR = TiretempRR; emit TiretempRRChanged(TiretempRR); }
}

// * Setters - Tire Pressures
void VehicleData::setTirepresLF(qreal TirepresLF) {
    if (m_TirepresLF != TirepresLF) { m_TirepresLF = TirepresLF; emit TirepresLFChanged(TirepresLF); }
}
void VehicleData::setTirepresRF(qreal TirepresRF) {
    if (m_TirepresRF != TirepresRF) { m_TirepresRF = TirepresRF; emit TirepresRFChanged(TirepresRF); }
}
void VehicleData::setTirepresLR(qreal TirepresLR) {
    if (m_TirepresLR != TirepresLR) { m_TirepresLR = TirepresLR; emit TirepresLRChanged(TirepresLR); }
}
void VehicleData::setTirepresRR(qreal TirepresRR) {
    if (m_TirepresRR != TirepresRR) { m_TirepresRR = TirepresRR; emit TirepresRRChanged(TirepresRR); }
}

// * Setters - Detailed Tire Temps LF
void VehicleData::setLF_Tyre_Temp_01(qreal LF_Tyre_Temp_01) {
    if (m_LF_Tyre_Temp_01 != LF_Tyre_Temp_01) { m_LF_Tyre_Temp_01 = LF_Tyre_Temp_01; emit LF_Tyre_Temp_01Changed(LF_Tyre_Temp_01); }
}
void VehicleData::setLF_Tyre_Temp_02(qreal LF_Tyre_Temp_02) {
    if (m_LF_Tyre_Temp_02 != LF_Tyre_Temp_02) { m_LF_Tyre_Temp_02 = LF_Tyre_Temp_02; emit LF_Tyre_Temp_02Changed(LF_Tyre_Temp_02); }
}
void VehicleData::setLF_Tyre_Temp_03(qreal LF_Tyre_Temp_03) {
    if (m_LF_Tyre_Temp_03 != LF_Tyre_Temp_03) { m_LF_Tyre_Temp_03 = LF_Tyre_Temp_03; emit LF_Tyre_Temp_03Changed(LF_Tyre_Temp_03); }
}
void VehicleData::setLF_Tyre_Temp_04(qreal LF_Tyre_Temp_04) {
    if (m_LF_Tyre_Temp_04 != LF_Tyre_Temp_04) { m_LF_Tyre_Temp_04 = LF_Tyre_Temp_04; emit LF_Tyre_Temp_04Changed(LF_Tyre_Temp_04); }
}
void VehicleData::setLF_Tyre_Temp_05(qreal LF_Tyre_Temp_05) {
    if (m_LF_Tyre_Temp_05 != LF_Tyre_Temp_05) { m_LF_Tyre_Temp_05 = LF_Tyre_Temp_05; emit LF_Tyre_Temp_05Changed(LF_Tyre_Temp_05); }
}
void VehicleData::setLF_Tyre_Temp_06(qreal LF_Tyre_Temp_06) {
    if (m_LF_Tyre_Temp_06 != LF_Tyre_Temp_06) { m_LF_Tyre_Temp_06 = LF_Tyre_Temp_06; emit LF_Tyre_Temp_06Changed(LF_Tyre_Temp_06); }
}
void VehicleData::setLF_Tyre_Temp_07(qreal LF_Tyre_Temp_07) {
    if (m_LF_Tyre_Temp_07 != LF_Tyre_Temp_07) { m_LF_Tyre_Temp_07 = LF_Tyre_Temp_07; emit LF_Tyre_Temp_07Changed(LF_Tyre_Temp_07); }
}
void VehicleData::setLF_Tyre_Temp_08(qreal LF_Tyre_Temp_08) {
    if (m_LF_Tyre_Temp_08 != LF_Tyre_Temp_08) { m_LF_Tyre_Temp_08 = LF_Tyre_Temp_08; emit LF_Tyre_Temp_08Changed(LF_Tyre_Temp_08); }
}

// * Setters - Detailed Tire Temps RF
void VehicleData::setRF_Tyre_Temp_01(qreal RF_Tyre_Temp_01) {
    if (m_RF_Tyre_Temp_01 != RF_Tyre_Temp_01) { m_RF_Tyre_Temp_01 = RF_Tyre_Temp_01; emit RF_Tyre_Temp_01Changed(RF_Tyre_Temp_01); }
}
void VehicleData::setRF_Tyre_Temp_02(qreal RF_Tyre_Temp_02) {
    if (m_RF_Tyre_Temp_02 != RF_Tyre_Temp_02) { m_RF_Tyre_Temp_02 = RF_Tyre_Temp_02; emit RF_Tyre_Temp_02Changed(RF_Tyre_Temp_02); }
}
void VehicleData::setRF_Tyre_Temp_03(qreal RF_Tyre_Temp_03) {
    if (m_RF_Tyre_Temp_03 != RF_Tyre_Temp_03) { m_RF_Tyre_Temp_03 = RF_Tyre_Temp_03; emit RF_Tyre_Temp_03Changed(RF_Tyre_Temp_03); }
}
void VehicleData::setRF_Tyre_Temp_04(qreal RF_Tyre_Temp_04) {
    if (m_RF_Tyre_Temp_04 != RF_Tyre_Temp_04) { m_RF_Tyre_Temp_04 = RF_Tyre_Temp_04; emit RF_Tyre_Temp_04Changed(RF_Tyre_Temp_04); }
}
void VehicleData::setRF_Tyre_Temp_05(qreal RF_Tyre_Temp_05) {
    if (m_RF_Tyre_Temp_05 != RF_Tyre_Temp_05) { m_RF_Tyre_Temp_05 = RF_Tyre_Temp_05; emit RF_Tyre_Temp_05Changed(RF_Tyre_Temp_05); }
}
void VehicleData::setRF_Tyre_Temp_06(qreal RF_Tyre_Temp_06) {
    if (m_RF_Tyre_Temp_06 != RF_Tyre_Temp_06) { m_RF_Tyre_Temp_06 = RF_Tyre_Temp_06; emit RF_Tyre_Temp_06Changed(RF_Tyre_Temp_06); }
}
void VehicleData::setRF_Tyre_Temp_07(qreal RF_Tyre_Temp_07) {
    if (m_RF_Tyre_Temp_07 != RF_Tyre_Temp_07) { m_RF_Tyre_Temp_07 = RF_Tyre_Temp_07; emit RF_Tyre_Temp_07Changed(RF_Tyre_Temp_07); }
}
void VehicleData::setRF_Tyre_Temp_08(qreal RF_Tyre_Temp_08) {
    if (m_RF_Tyre_Temp_08 != RF_Tyre_Temp_08) { m_RF_Tyre_Temp_08 = RF_Tyre_Temp_08; emit RF_Tyre_Temp_08Changed(RF_Tyre_Temp_08); }
}

// * Setters - Detailed Tire Temps LR
void VehicleData::setLR_Tyre_Temp_01(qreal LR_Tyre_Temp_01) {
    if (m_LR_Tyre_Temp_01 != LR_Tyre_Temp_01) { m_LR_Tyre_Temp_01 = LR_Tyre_Temp_01; emit LR_Tyre_Temp_01Changed(LR_Tyre_Temp_01); }
}
void VehicleData::setLR_Tyre_Temp_02(qreal LR_Tyre_Temp_02) {
    if (m_LR_Tyre_Temp_02 != LR_Tyre_Temp_02) { m_LR_Tyre_Temp_02 = LR_Tyre_Temp_02; emit LR_Tyre_Temp_02Changed(LR_Tyre_Temp_02); }
}
void VehicleData::setLR_Tyre_Temp_03(qreal LR_Tyre_Temp_03) {
    if (m_LR_Tyre_Temp_03 != LR_Tyre_Temp_03) { m_LR_Tyre_Temp_03 = LR_Tyre_Temp_03; emit LR_Tyre_Temp_03Changed(LR_Tyre_Temp_03); }
}
void VehicleData::setLR_Tyre_Temp_04(qreal LR_Tyre_Temp_04) {
    if (m_LR_Tyre_Temp_04 != LR_Tyre_Temp_04) { m_LR_Tyre_Temp_04 = LR_Tyre_Temp_04; emit LR_Tyre_Temp_04Changed(LR_Tyre_Temp_04); }
}
void VehicleData::setLR_Tyre_Temp_05(qreal LR_Tyre_Temp_05) {
    if (m_LR_Tyre_Temp_05 != LR_Tyre_Temp_05) { m_LR_Tyre_Temp_05 = LR_Tyre_Temp_05; emit LR_Tyre_Temp_05Changed(LR_Tyre_Temp_05); }
}
void VehicleData::setLR_Tyre_Temp_06(qreal LR_Tyre_Temp_06) {
    if (m_LR_Tyre_Temp_06 != LR_Tyre_Temp_06) { m_LR_Tyre_Temp_06 = LR_Tyre_Temp_06; emit LR_Tyre_Temp_06Changed(LR_Tyre_Temp_06); }
}
void VehicleData::setLR_Tyre_Temp_07(qreal LR_Tyre_Temp_07) {
    if (m_LR_Tyre_Temp_07 != LR_Tyre_Temp_07) { m_LR_Tyre_Temp_07 = LR_Tyre_Temp_07; emit LR_Tyre_Temp_07Changed(LR_Tyre_Temp_07); }
}
void VehicleData::setLR_Tyre_Temp_08(qreal LR_Tyre_Temp_08) {
    if (m_LR_Tyre_Temp_08 != LR_Tyre_Temp_08) { m_LR_Tyre_Temp_08 = LR_Tyre_Temp_08; emit LR_Tyre_Temp_08Changed(LR_Tyre_Temp_08); }
}

// * Setters - Detailed Tire Temps RR
void VehicleData::setRR_Tyre_Temp_01(qreal RR_Tyre_Temp_01) {
    if (m_RR_Tyre_Temp_01 != RR_Tyre_Temp_01) { m_RR_Tyre_Temp_01 = RR_Tyre_Temp_01; emit RR_Tyre_Temp_01Changed(RR_Tyre_Temp_01); }
}
void VehicleData::setRR_Tyre_Temp_02(qreal RR_Tyre_Temp_02) {
    if (m_RR_Tyre_Temp_02 != RR_Tyre_Temp_02) { m_RR_Tyre_Temp_02 = RR_Tyre_Temp_02; emit RR_Tyre_Temp_02Changed(RR_Tyre_Temp_02); }
}
void VehicleData::setRR_Tyre_Temp_03(qreal RR_Tyre_Temp_03) {
    if (m_RR_Tyre_Temp_03 != RR_Tyre_Temp_03) { m_RR_Tyre_Temp_03 = RR_Tyre_Temp_03; emit RR_Tyre_Temp_03Changed(RR_Tyre_Temp_03); }
}
void VehicleData::setRR_Tyre_Temp_04(qreal RR_Tyre_Temp_04) {
    if (m_RR_Tyre_Temp_04 != RR_Tyre_Temp_04) { m_RR_Tyre_Temp_04 = RR_Tyre_Temp_04; emit RR_Tyre_Temp_04Changed(RR_Tyre_Temp_04); }
}
void VehicleData::setRR_Tyre_Temp_05(qreal RR_Tyre_Temp_05) {
    if (m_RR_Tyre_Temp_05 != RR_Tyre_Temp_05) { m_RR_Tyre_Temp_05 = RR_Tyre_Temp_05; emit RR_Tyre_Temp_05Changed(RR_Tyre_Temp_05); }
}
void VehicleData::setRR_Tyre_Temp_06(qreal RR_Tyre_Temp_06) {
    if (m_RR_Tyre_Temp_06 != RR_Tyre_Temp_06) { m_RR_Tyre_Temp_06 = RR_Tyre_Temp_06; emit RR_Tyre_Temp_06Changed(RR_Tyre_Temp_06); }
}
void VehicleData::setRR_Tyre_Temp_07(qreal RR_Tyre_Temp_07) {
    if (m_RR_Tyre_Temp_07 != RR_Tyre_Temp_07) { m_RR_Tyre_Temp_07 = RR_Tyre_Temp_07; emit RR_Tyre_Temp_07Changed(RR_Tyre_Temp_07); }
}
void VehicleData::setRR_Tyre_Temp_08(qreal RR_Tyre_Temp_08) {
    if (m_RR_Tyre_Temp_08 != RR_Tyre_Temp_08) { m_RR_Tyre_Temp_08 = RR_Tyre_Temp_08; emit RR_Tyre_Temp_08Changed(RR_Tyre_Temp_08); }
}

// * Setters - Steering
void VehicleData::setSteeringWheelAngle(qreal SteeringWheelAngle) {
    if (m_SteeringWheelAngle != SteeringWheelAngle) { m_SteeringWheelAngle = SteeringWheelAngle; emit SteeringWheelAngleChanged(SteeringWheelAngle); }
}

// * Setters - Controls State
void VehicleData::setaccelpedpos(qreal accelpedpos) {
    if (m_accelpedpos != accelpedpos) { m_accelpedpos = accelpedpos; emit accelpedposChanged(accelpedpos); }
}
void VehicleData::setclutchswitchstate(qreal clutchswitchstate) {
    if (m_clutchswitchstate != clutchswitchstate) { m_clutchswitchstate = clutchswitchstate; emit clutchswitchstateChanged(clutchswitchstate); }
}
void VehicleData::sethandbrake(qreal handbrake) {
    if (m_handbrake != handbrake) { m_handbrake = handbrake; emit handbrakeChanged(handbrake); }
}

// * Setters - Lights/Indicators
void VehicleData::sethighbeam(qreal highbeam) {
    if (m_highbeam != highbeam) { m_highbeam = highbeam; emit highbeamChanged(highbeam); }
}
void VehicleData::setlowBeam(qreal lowBeam) {
    if (m_lowBeam != lowBeam) { m_lowBeam = lowBeam; emit lowBeamChanged(lowBeam); }
}
void VehicleData::setleftindicator(qreal leftindicator) {
    if (m_leftindicator != leftindicator) { m_leftindicator = leftindicator; emit leftindicatorChanged(leftindicator); }
}
void VehicleData::setrightindicator(qreal rightindicator) {
    if (m_rightindicator != rightindicator) { m_rightindicator = rightindicator; emit rightindicatorChanged(rightindicator); }
}

// * Setters - Accelerometer
void VehicleData::setaccelx(qreal accelx) {
    if (m_accelx != accelx) { m_accelx = accelx; emit accelxChanged(accelx); }
}
void VehicleData::setaccely(qreal accely) {
    if (m_accely != accely) { m_accely = accely; emit accelyChanged(accely); }
}
void VehicleData::setaccelz(qreal accelz) {
    if (m_accelz != accelz) { m_accelz = accelz; emit accelzChanged(accelz); }
}
void VehicleData::setAccelTimer(qreal AccelTimer) {
    if (m_AccelTimer != AccelTimer) { m_AccelTimer = AccelTimer; emit accelTimerChanged(AccelTimer); }
}

// * Setters - Gyroscope
void VehicleData::setgyrox(qreal gyrox) {
    if (m_gyrox != gyrox) { m_gyrox = gyrox; emit gyroxChanged(gyrox); }
}
void VehicleData::setgyroy(qreal gyroy) {
    if (m_gyroy != gyroy) { m_gyroy = gyroy; emit gyroyChanged(gyroy); }
}
void VehicleData::setgyroz(qreal gyroz) {
    if (m_gyroz != gyroz) { m_gyroz = gyroz; emit gyrozChanged(gyroz); }
}

// * Setters - Compass/Environment
void VehicleData::setcompass(qreal compass) {
    if (m_compass != compass) { m_compass = compass; emit compassChanged(compass); }
}
void VehicleData::setambitemp(qreal ambitemp) {
    if (m_ambitemp != ambitemp) { m_ambitemp = ambitemp; emit ambitempChanged(ambitemp); }
}
void VehicleData::setambipress(qreal ambipress) {
    if (m_ambipress != ambipress) { m_ambipress = ambipress; emit ambipressChanged(ambipress); }
}

// * Setters - Weight
void VehicleData::setWeight(qreal Weight) {
    if (m_Weight != Weight) { m_Weight = Weight; emit weightChanged(Weight); }
}
