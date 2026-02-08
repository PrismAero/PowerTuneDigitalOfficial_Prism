/**
 * @file EngineData.cpp
 * @brief Implementation of the EngineData class
 * 
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#include "EngineData.h"

EngineData::EngineData(QObject *parent)
    : QObject(parent)
{
}

// * Setters - Core Engine Metrics
void EngineData::setrpm(qreal rpm) {
    if (m_rpm != rpm) { m_rpm = rpm; emit rpmChanged(rpm); }
}
void EngineData::setIntakepress(qreal Intakepress) {
    if (m_Intakepress != Intakepress) { m_Intakepress = Intakepress; emit intakepressChanged(Intakepress); }
}
void EngineData::setPressureV(qreal PressureV) {
    if (m_PressureV != PressureV) { m_PressureV = PressureV; emit pressureVChanged(PressureV); }
}
void EngineData::setThrottleV(qreal ThrottleV) {
    if (m_ThrottleV != ThrottleV) { m_ThrottleV = ThrottleV; emit throttleVChanged(ThrottleV); }
}
void EngineData::setPrimaryinp(qreal Primaryinp) {
    if (m_Primaryinp != Primaryinp) { m_Primaryinp = Primaryinp; emit primaryinpChanged(Primaryinp); }
}
void EngineData::setEngLoad(qreal EngLoad) {
    if (m_EngLoad != EngLoad) { m_EngLoad = EngLoad; emit engLoadChanged(EngLoad); }
}
void EngineData::setpim(qreal pim) {
    if (m_pim != pim) { m_pim = pim; emit pimChanged(pim); }
}
void EngineData::setTPS(qreal TPS) {
    if (m_TPS != TPS) { m_TPS = TPS; emit tPSChanged(TPS); }
}
void EngineData::setIdleValue(qreal IdleValue) {
    if (m_IdleValue != IdleValue) { m_IdleValue = IdleValue; emit idleValueChanged(IdleValue); }
}
void EngineData::setIscvduty(qreal Iscvduty) {
    if (m_Iscvduty != Iscvduty) { m_Iscvduty = Iscvduty; emit iscvdutyChanged(Iscvduty); }
}

// * Setters - Boost/Turbo
void EngineData::setBoosttp(qreal Boosttp) {
    if (m_Boosttp != Boosttp) { m_Boosttp = Boosttp; emit boosttpChanged(Boosttp); }
}
void EngineData::setBoostwg(qreal Boostwg) {
    if (m_Boostwg != Boostwg) { m_Boostwg = Boostwg; emit boostwgChanged(Boostwg); }
}
void EngineData::setBoostPres(qreal BoostPres) {
    if (m_BoostPres != BoostPres) { m_BoostPres = BoostPres; emit BoostPresChanged(BoostPres); }
}
void EngineData::setBoostPreskpa(qreal BoostPreskpa) {
    if (m_BoostPreskpa != BoostPreskpa) { m_BoostPreskpa = BoostPreskpa; emit BoostPreskpaChanged(BoostPreskpa); }
}
void EngineData::setBoostDuty(qreal BoostDuty) {
    if (m_BoostDuty != BoostDuty) { m_BoostDuty = BoostDuty; emit boostDutyChanged(BoostDuty); }
}
void EngineData::setboostcontrol(qreal boostcontrol) {
    if (m_boostcontrol != boostcontrol) { m_boostcontrol = boostcontrol; emit boostcontrolChanged(boostcontrol); }
}
void EngineData::settargetbstlelkpa(qreal targetbstlelkpa) {
    if (m_targetbstlelkpa != targetbstlelkpa) { m_targetbstlelkpa = targetbstlelkpa; emit targetbstlelkpaChanged(targetbstlelkpa); }
}
void EngineData::setwastegatepress(qreal wastegatepress) {
    if (m_wastegatepress != wastegatepress) { m_wastegatepress = wastegatepress; emit wastegatepressChanged(wastegatepress); }
}
void EngineData::setturborpm(qreal turborpm) {
    if (m_turborpm != turborpm) { m_turborpm = turborpm; emit turborpmChanged(turborpm); }
}
void EngineData::setturborpm2(qreal turborpm2) {
    if (m_turborpm2 != turborpm2) { m_turborpm2 = turborpm2; emit turborpm2Changed(turborpm2); }
}
void EngineData::setBOOSTOFFSET(qreal BOOSTOFFSET) {
    if (m_BOOSTOFFSET != BOOSTOFFSET) { m_BOOSTOFFSET = BOOSTOFFSET; emit BOOSTOFFSETChanged(BOOSTOFFSET); }
}
void EngineData::setactiveboosttable(qreal activeboosttable) {
    if (m_activeboosttable != activeboosttable) { m_activeboosttable = activeboosttable; emit activeboosttableChanged(activeboosttable); }
}

// * Setters - MAP/MAF
void EngineData::setMAP(qreal MAP) {
    if (m_MAP != MAP) { m_MAP = MAP; emit mAPChanged(MAP); }
}
void EngineData::setMAP2(qreal MAP2) {
    if (m_MAP2 != MAP2) { m_MAP2 = MAP2; emit mAP2Changed(MAP2); }
}
void EngineData::setMAF1V(qreal MAF1V) {
    if (m_MAF1V != MAF1V) { m_MAF1V = MAF1V; emit mAF1VChanged(MAF1V); }
}
void EngineData::setMAF2V(qreal MAF2V) {
    if (m_MAF2V != MAF2V) { m_MAF2V = MAF2V; emit mAF2VChanged(MAF2V); }
}
void EngineData::setMAFactivity(qreal MAFactivity) {
    if (m_MAFactivity != MAFactivity) { m_MAFactivity = MAFactivity; emit mAFactivityChanged(MAFactivity); }
}
void EngineData::setPANVAC(qreal PANVAC) {
    if (m_PANVAC != PANVAC) { m_PANVAC = PANVAC; emit PANVACChanged(PANVAC); }
}

// * Setters - Fuel System
void EngineData::setFuelc(qreal Fuelc) {
    if (m_Fuelc != Fuelc) { m_Fuelc = Fuelc; emit fuelcChanged(Fuelc); }
}
void EngineData::setFueltemp(qreal Fueltemp) {
    if (m_Fueltemp != Fueltemp) { m_Fueltemp = Fueltemp; emit fueltempChanged(Fueltemp); }
}
void EngineData::setFuelPress(qreal FuelPress) {
    if (m_FuelPress != FuelPress) { m_FuelPress = FuelPress; emit fuelPressChanged(FuelPress); }
}
void EngineData::setfuelclevel(qreal fuelclevel) {
    if (m_fuelclevel != fuelclevel) { m_fuelclevel = fuelclevel; emit fuelclevelChanged(fuelclevel); }
}
void EngineData::setfuelcomposition(qreal fuelcomposition) {
    if (m_fuelcomposition != fuelcomposition) { m_fuelcomposition = fuelcomposition; emit fuelcompositionChanged(fuelcomposition); }
}
void EngineData::setfuelconsrate(qreal fuelconsrate) {
    if (m_fuelconsrate != fuelconsrate) { m_fuelconsrate = fuelconsrate; emit fuelconsrateChanged(fuelconsrate); }
}
void EngineData::setfuelcutperc(qreal fuelcutperc) {
    if (m_fuelcutperc != fuelcutperc) { m_fuelcutperc = fuelcutperc; emit fuelcutpercChanged(fuelcutperc); }
}
void EngineData::setfuelflow(qreal fuelflow) {
    if (m_fuelflow != fuelflow) { m_fuelflow = fuelflow; emit fuelflowChanged(fuelflow); }
}
void EngineData::setfuelflowdiff(qreal fuelflowdiff) {
    if (m_fuelflowdiff != fuelflowdiff) { m_fuelflowdiff = fuelflowdiff; emit fuelflowdiffChanged(fuelflowdiff); }
}
void EngineData::setfuelflowret(qreal fuelflowret) {
    if (m_fuelflowret != fuelflowret) { m_fuelflowret = fuelflowret; emit fuelflowretChanged(fuelflowret); }
}
void EngineData::setfueltrimlongtbank1(qreal fueltrimlongtbank1) {
    if (m_fueltrimlongtbank1 != fueltrimlongtbank1) { m_fueltrimlongtbank1 = fueltrimlongtbank1; emit fueltrimlongtbank1Changed(fueltrimlongtbank1); }
}
void EngineData::setfueltrimlongtbank2(qreal fueltrimlongtbank2) {
    if (m_fueltrimlongtbank2 != fueltrimlongtbank2) { m_fueltrimlongtbank2 = fueltrimlongtbank2; emit fueltrimlongtbank2Changed(fueltrimlongtbank2); }
}
void EngineData::setfueltrimshorttbank1(qreal fueltrimshorttbank1) {
    if (m_fueltrimshorttbank1 != fueltrimshorttbank1) { m_fueltrimshorttbank1 = fueltrimshorttbank1; emit fueltrimshorttbank1Changed(fueltrimshorttbank1); }
}
void EngineData::setfueltrimshorttbank2(qreal fueltrimshorttbank2) {
    if (m_fueltrimshorttbank2 != fueltrimshorttbank2) { m_fueltrimshorttbank2 = fueltrimshorttbank2; emit fueltrimshorttbank2Changed(fueltrimshorttbank2); }
}
void EngineData::settotalfueltrim(qreal totalfueltrim) {
    if (m_totalfueltrim != totalfueltrim) { m_totalfueltrim = totalfueltrim; emit totalfueltrimChanged(totalfueltrim); }
}
void EngineData::setavfueleconomy(qreal avfueleconomy) {
    if (m_avfueleconomy != avfueleconomy) { m_avfueleconomy = avfueleconomy; emit avfueleconomyChanged(avfueleconomy); }
}

// * Setters - Injectors
void EngineData::setInjDuty(qreal InjDuty) {
    if (m_InjDuty != InjDuty) { m_InjDuty = InjDuty; emit injDutyChanged(InjDuty); }
}
void EngineData::setInjDuty2(qreal InjDuty2) {
    if (m_InjDuty2 != InjDuty2) { m_InjDuty2 = InjDuty2; emit injDuty2Changed(InjDuty2); }
}
void EngineData::setInjAngle(qreal InjAngle) {
    if (m_InjAngle != InjAngle) { m_InjAngle = InjAngle; emit InjAngleChanged(InjAngle); }
}
void EngineData::setinjms(qreal injms) {
    if (m_injms != injms) { m_injms = injms; emit injmsChanged(injms); }
}
void EngineData::setInj(qreal Inj) {
    if (m_Inj != Inj) { m_Inj = Inj; emit injChanged(Inj); }
}
void EngineData::setInj1(qreal Inj1) {
    if (m_Inj1 != Inj1) { m_Inj1 = Inj1; emit inj1Changed(Inj1); }
}
void EngineData::setInj2(qreal Inj2) {
    if (m_Inj2 != Inj2) { m_Inj2 = Inj2; emit inj2Changed(Inj2); }
}
void EngineData::setInj3(qreal Inj3) {
    if (m_Inj3 != Inj3) { m_Inj3 = Inj3; emit inj3Changed(Inj3); }
}
void EngineData::setInj4(qreal Inj4) {
    if (m_Inj4 != Inj4) { m_Inj4 = Inj4; emit inj4Changed(Inj4); }
}
void EngineData::setSecinjpulse(qreal Secinjpulse) {
    if (m_Secinjpulse != Secinjpulse) { m_Secinjpulse = Secinjpulse; emit secinjpulseChanged(Secinjpulse); }
}
void EngineData::setpwseq1(qreal pwseq1) {
    if (m_pwseq1 != pwseq1) { m_pwseq1 = pwseq1; emit pwseq1Changed(pwseq1); }
}
void EngineData::setpwseq2(qreal pwseq2) {
    if (m_pwseq2 != pwseq2) { m_pwseq2 = pwseq2; emit pwseq2Changed(pwseq2); }
}
void EngineData::setpwseq3(qreal pwseq3) {
    if (m_pwseq3 != pwseq3) { m_pwseq3 = pwseq3; emit pwseq3Changed(pwseq3); }
}
void EngineData::setpwseq4(qreal pwseq4) {
    if (m_pwseq4 != pwseq4) { m_pwseq4 = pwseq4; emit pwseq4Changed(pwseq4); }
}

// * Setters - Ignition
void EngineData::setIgn(qreal Ign) {
    if (m_Ign != Ign) { m_Ign = Ign; emit ignChanged(Ign); }
}
void EngineData::setIgn1(qreal Ign1) {
    if (m_Ign1 != Ign1) { m_Ign1 = Ign1; emit ign1Changed(Ign1); }
}
void EngineData::setIgn2(qreal Ign2) {
    if (m_Ign2 != Ign2) { m_Ign2 = Ign2; emit ign2Changed(Ign2); }
}
void EngineData::setIgn3(qreal Ign3) {
    if (m_Ign3 != Ign3) { m_Ign3 = Ign3; emit ign3Changed(Ign3); }
}
void EngineData::setIgn4(qreal Ign4) {
    if (m_Ign4 != Ign4) { m_Ign4 = Ign4; emit ign4Changed(Ign4); }
}
void EngineData::setLeadingign(qreal Leadingign) {
    if (m_Leadingign != Leadingign) { m_Leadingign = Leadingign; emit leadingignChanged(Leadingign); }
}
void EngineData::setTrailingign(qreal Trailingign) {
    if (m_Trailingign != Trailingign) { m_Trailingign = Trailingign; emit trailingignChanged(Trailingign); }
}
void EngineData::setDwell(qreal Dwell) {
    if (m_Dwell != Dwell) { m_Dwell = Dwell; emit dwellChanged(Dwell); }
}
void EngineData::setigncut(qreal igncut) {
    if (m_igncut != igncut) { m_igncut = igncut; emit igncutChanged(igncut); }
}
void EngineData::settotaligncomp(qreal totaligncomp) {
    if (m_totaligncomp != totaligncomp) { m_totaligncomp = totaligncomp; emit totaligncompChanged(totaligncomp); }
}

// * Setters - Cam Angles
void EngineData::setexcamangle1(qreal excamangle1) {
    if (m_excamangle1 != excamangle1) { m_excamangle1 = excamangle1; emit excamangle1Changed(excamangle1); }
}
void EngineData::setexcamangle2(qreal excamangle2) {
    if (m_excamangle2 != excamangle2) { m_excamangle2 = excamangle2; emit excamangle2Changed(excamangle2); }
}
void EngineData::setincamangle1(qreal incamangle1) {
    if (m_incamangle1 != incamangle1) { m_incamangle1 = incamangle1; emit incamangle1Changed(incamangle1); }
}
void EngineData::setincamangle2(qreal incamangle2) {
    if (m_incamangle2 != incamangle2) { m_incamangle2 = incamangle2; emit incamangle2Changed(incamangle2); }
}

// * Setters - Temperatures
void EngineData::setWatertemp(qreal Watertemp) {
    if (m_Watertemp != Watertemp) { m_Watertemp = Watertemp; emit watertempChanged(Watertemp); }
}
void EngineData::setIntaketemp(qreal Intaketemp) {
    if (m_Intaketemp != Intaketemp) { m_Intaketemp = Intaketemp; emit intaketempChanged(Intaketemp); }
}
void EngineData::setairtempensor2(qreal airtempensor2) {
    if (m_airtempensor2 != airtempensor2) { m_airtempensor2 = airtempensor2; emit airtempensor2Changed(airtempensor2); }
}
void EngineData::setoiltemp(qreal oiltemp) {
    if (m_oiltemp != oiltemp) { m_oiltemp = oiltemp; emit oiltempChanged(oiltemp); }
}
void EngineData::settransoiltemp(qreal transoiltemp) {
    if (m_transoiltemp != transoiltemp) { m_transoiltemp = transoiltemp; emit transoiltempChanged(transoiltemp); }
}
void EngineData::setdiffoiltemp(qreal diffoiltemp) {
    if (m_diffoiltemp != diffoiltemp) { m_diffoiltemp = diffoiltemp; emit diffoiltempChanged(diffoiltemp); }
}
void EngineData::setcoolantpress(qreal coolantpress) {
    if (m_coolantpress != coolantpress) { m_coolantpress = coolantpress; emit coolantpressChanged(coolantpress); }
}
void EngineData::setAUXT(qreal AUXT) {
    if (m_AUXT != AUXT) { m_AUXT = AUXT; emit aUXTChanged(AUXT); }
}
void EngineData::setAuxTemp1(int AuxTemp1) {
    if (m_AuxTemp1 != AuxTemp1) { m_AuxTemp1 = AuxTemp1; emit AuxTemp1Changed(AuxTemp1); }
}

// * Setters - Pressures
void EngineData::setoilpres(qreal oilpres) {
    if (m_oilpres != oilpres) { m_oilpres = oilpres; emit oilpresChanged(oilpres); }
}
void EngineData::setMoilp(qreal Moilp) {
    if (m_Moilp != Moilp) { m_Moilp = Moilp; emit moilpChanged(Moilp); }
}
void EngineData::setGearOilPress(qreal GearOilPress) {
    if (m_GearOilPress != GearOilPress) { m_GearOilPress = GearOilPress; emit GearOilPressChanged(GearOilPress); }
}
void EngineData::setbrakepress(qreal brakepress) {
    if (m_brakepress != brakepress) { m_brakepress = brakepress; emit brakepressChanged(brakepress); }
}

// * Setters - O2/Lambda/AFR
void EngineData::setO2volt(qreal O2volt) {
    if (m_O2volt != O2volt) { m_O2volt = O2volt; emit o2voltChanged(O2volt); }
}
void EngineData::setO2volt_2(qreal O2volt_2) {
    if (m_O2volt_2 != O2volt_2) { m_O2volt_2 = O2volt_2; emit o2volt_2Changed(O2volt_2); }
}
void EngineData::setLAMBDA(qreal LAMBDA) {
    if (m_LAMBDA != LAMBDA) { m_LAMBDA = LAMBDA; emit lAMBDAChanged(LAMBDA); }
}
void EngineData::setLAMBDATarget(qreal LAMBDATarget) {
    if (m_LAMBDATarget != LAMBDATarget) { m_LAMBDATarget = LAMBDATarget; emit lAMBDATargetChanged(LAMBDATarget); }
}
void EngineData::setlambda2(qreal lambda2) {
    if (m_lambda2 != lambda2) { m_lambda2 = lambda2; emit lambda2Changed(lambda2); }
}
void EngineData::setlambda3(qreal lambda3) {
    if (m_lambda3 != lambda3) { m_lambda3 = lambda3; emit lambda3Changed(lambda3); }
}
void EngineData::setlambda4(qreal lambda4) {
    if (m_lambda4 != lambda4) { m_lambda4 = lambda4; emit lambda4Changed(lambda4); }
}
void EngineData::setLambdamultiply(qreal Lambdamultiply) {
    if (m_Lambdamultiply != Lambdamultiply) { m_Lambdamultiply = Lambdamultiply; emit LambdamultiplyChanged(Lambdamultiply); }
}
void EngineData::setAFR(qreal AFR) {
    if (m_AFR != AFR) { m_AFR = AFR; emit aFRChanged(AFR); }
}
void EngineData::setAFRLEFTBANKTARGET(qreal AFRLEFTBANKTARGET) {
    if (m_AFRLEFTBANKTARGET != AFRLEFTBANKTARGET) { m_AFRLEFTBANKTARGET = AFRLEFTBANKTARGET; emit AFRLEFTBANKTARGETChanged(AFRLEFTBANKTARGET); }
}
void EngineData::setAFRRIGHTBANKTARGET(qreal AFRRIGHTBANKTARGET) {
    if (m_AFRRIGHTBANKTARGET != AFRRIGHTBANKTARGET) { m_AFRRIGHTBANKTARGET = AFRRIGHTBANKTARGET; emit AFRRIGHTBANKTARGETChanged(AFRRIGHTBANKTARGET); }
}
void EngineData::setAFRLEFTBANKACTUAL(qreal AFRLEFTBANKACTUAL) {
    if (m_AFRLEFTBANKACTUAL != AFRLEFTBANKACTUAL) { m_AFRLEFTBANKACTUAL = AFRLEFTBANKACTUAL; emit AFRLEFTBANKACTUALChanged(AFRLEFTBANKACTUAL); }
}
void EngineData::setAFRRIGHTBANKACTUAL(qreal AFRRIGHTBANKACTUAL) {
    if (m_AFRRIGHTBANKACTUAL != AFRRIGHTBANKACTUAL) { m_AFRRIGHTBANKACTUAL = AFRRIGHTBANKACTUAL; emit AFRRIGHTBANKACTUALChanged(AFRRIGHTBANKACTUAL); }
}
void EngineData::setLEFTBANKO2CORR(qreal LEFTBANKO2CORR) {
    if (m_LEFTBANKO2CORR != LEFTBANKO2CORR) { m_LEFTBANKO2CORR = LEFTBANKO2CORR; emit LEFTBANKO2CORRChanged(LEFTBANKO2CORR); }
}
void EngineData::setRIGHTBANKO2CORR(qreal RIGHTBANKO2CORR) {
    if (m_RIGHTBANKO2CORR != RIGHTBANKO2CORR) { m_RIGHTBANKO2CORR = RIGHTBANKO2CORR; emit RIGHTBANKO2CORRChanged(RIGHTBANKO2CORR); }
}
void EngineData::setTRIM(qreal TRIM) {
    if (m_TRIM != TRIM) { m_TRIM = TRIM; emit tRIMChanged(TRIM); }
}

// * Setters - Per-Cylinder O2 Correction
void EngineData::setCyl1_O2_Corr(qreal Cyl1_O2_Corr) {
    if (m_Cyl1_O2_Corr != Cyl1_O2_Corr) { m_Cyl1_O2_Corr = Cyl1_O2_Corr; emit Cyl1_O2_CorrChanged(Cyl1_O2_Corr); }
}
void EngineData::setCyl2_O2_Corr(qreal Cyl2_O2_Corr) {
    if (m_Cyl2_O2_Corr != Cyl2_O2_Corr) { m_Cyl2_O2_Corr = Cyl2_O2_Corr; emit Cyl2_O2_CorrChanged(Cyl2_O2_Corr); }
}
void EngineData::setCyl3_O2_Corr(qreal Cyl3_O2_Corr) {
    if (m_Cyl3_O2_Corr != Cyl3_O2_Corr) { m_Cyl3_O2_Corr = Cyl3_O2_Corr; emit Cyl3_O2_CorrChanged(Cyl3_O2_Corr); }
}
void EngineData::setCyl4_O2_Corr(qreal Cyl4_O2_Corr) {
    if (m_Cyl4_O2_Corr != Cyl4_O2_Corr) { m_Cyl4_O2_Corr = Cyl4_O2_Corr; emit Cyl4_O2_CorrChanged(Cyl4_O2_Corr); }
}
void EngineData::setCyl5_O2_Corr(qreal Cyl5_O2_Corr) {
    if (m_Cyl5_O2_Corr != Cyl5_O2_Corr) { m_Cyl5_O2_Corr = Cyl5_O2_Corr; emit Cyl5_O2_CorrChanged(Cyl5_O2_Corr); }
}
void EngineData::setCyl6_O2_Corr(qreal Cyl6_O2_Corr) {
    if (m_Cyl6_O2_Corr != Cyl6_O2_Corr) { m_Cyl6_O2_Corr = Cyl6_O2_Corr; emit Cyl6_O2_CorrChanged(Cyl6_O2_Corr); }
}
void EngineData::setCyl7_O2_Corr(qreal Cyl7_O2_Corr) {
    if (m_Cyl7_O2_Corr != Cyl7_O2_Corr) { m_Cyl7_O2_Corr = Cyl7_O2_Corr; emit Cyl7_O2_CorrChanged(Cyl7_O2_Corr); }
}
void EngineData::setCyl8_O2_Corr(qreal Cyl8_O2_Corr) {
    if (m_Cyl8_O2_Corr != Cyl8_O2_Corr) { m_Cyl8_O2_Corr = Cyl8_O2_Corr; emit Cyl8_O2_CorrChanged(Cyl8_O2_Corr); }
}
void EngineData::setEGOcor1(qreal EGOcor1) {
    if (m_EGOcor1 != EGOcor1) { m_EGOcor1 = EGOcor1; emit EGOcor1Changed(EGOcor1); }
}
void EngineData::setEGOcor2(qreal EGOcor2) {
    if (m_EGOcor2 != EGOcor2) { m_EGOcor2 = EGOcor2; emit EGOcor2Changed(EGOcor2); }
}
void EngineData::setEGOcor3(qreal EGOcor3) {
    if (m_EGOcor3 != EGOcor3) { m_EGOcor3 = EGOcor3; emit EGOcor3Changed(EGOcor3); }
}
void EngineData::setEGOcor4(qreal EGOcor4) {
    if (m_EGOcor4 != EGOcor4) { m_EGOcor4 = EGOcor4; emit EGOcor4Changed(EGOcor4); }
}

// * Setters - Per-Cylinder AFR
void EngineData::setAFRcyl1(qreal AFRcyl1) {
    if (m_AFRcyl1 != AFRcyl1) { m_AFRcyl1 = AFRcyl1; emit AFRcyl1Changed(AFRcyl1); }
}
void EngineData::setAFRcyl2(qreal AFRcyl2) {
    if (m_AFRcyl2 != AFRcyl2) { m_AFRcyl2 = AFRcyl2; emit AFRcyl2Changed(AFRcyl2); }
}
void EngineData::setAFRcyl3(qreal AFRcyl3) {
    if (m_AFRcyl3 != AFRcyl3) { m_AFRcyl3 = AFRcyl3; emit AFRcyl3Changed(AFRcyl3); }
}
void EngineData::setAFRcyl4(qreal AFRcyl4) {
    if (m_AFRcyl4 != AFRcyl4) { m_AFRcyl4 = AFRcyl4; emit AFRcyl4Changed(AFRcyl4); }
}
void EngineData::setAFRcyl5(qreal AFRcyl5) {
    if (m_AFRcyl5 != AFRcyl5) { m_AFRcyl5 = AFRcyl5; emit AFRcyl5Changed(AFRcyl5); }
}
void EngineData::setAFRcyl6(qreal AFRcyl6) {
    if (m_AFRcyl6 != AFRcyl6) { m_AFRcyl6 = AFRcyl6; emit AFRcyl6Changed(AFRcyl6); }
}
void EngineData::setAFRcyl7(qreal AFRcyl7) {
    if (m_AFRcyl7 != AFRcyl7) { m_AFRcyl7 = AFRcyl7; emit AFRcyl7Changed(AFRcyl7); }
}
void EngineData::setAFRcyl8(qreal AFRcyl8) {
    if (m_AFRcyl8 != AFRcyl8) { m_AFRcyl8 = AFRcyl8; emit AFRcyl8Changed(AFRcyl8); }
}

// * Setters - Knock
void EngineData::setKnock(qreal Knock) {
    if (m_Knock != Knock) { m_Knock = Knock; emit knockChanged(Knock); }
}
void EngineData::setknocklevlogged1(qreal knocklevlogged1) {
    if (m_knocklevlogged1 != knocklevlogged1) { m_knocklevlogged1 = knocklevlogged1; emit knocklevlogged1Changed(knocklevlogged1); }
}
void EngineData::setknocklevlogged2(qreal knocklevlogged2) {
    if (m_knocklevlogged2 != knocklevlogged2) { m_knocklevlogged2 = knocklevlogged2; emit knocklevlogged2Changed(knocklevlogged2); }
}
void EngineData::setknockretardbank1(qreal knockretardbank1) {
    if (m_knockretardbank1 != knockretardbank1) { m_knockretardbank1 = knockretardbank1; emit knockretardbank1Changed(knockretardbank1); }
}
void EngineData::setknockretardbank2(qreal knockretardbank2) {
    if (m_knockretardbank2 != knockretardbank2) { m_knockretardbank2 = knockretardbank2; emit knockretardbank2Changed(knockretardbank2); }
}
void EngineData::setknockallpeak(qreal knockallpeak) {
    if (m_knockallpeak != knockallpeak) { m_knockallpeak = knockallpeak; emit knockallpeakChanged(knockallpeak); }
}
void EngineData::setknockcorr(qreal knockcorr) {
    if (m_knockcorr != knockcorr) { m_knockcorr = knockcorr; emit knockcorrChanged(knockcorr); }
}
void EngineData::setknocklastcyl(qreal knocklastcyl) {
    if (m_knocklastcyl != knocklastcyl) { m_knocklastcyl = knocklastcyl; emit knocklastcylChanged(knocklastcyl); }
}
void EngineData::setKnock_cyl1(qreal Knock_cyl1) {
    if (m_Knock_cyl1 != Knock_cyl1) { m_Knock_cyl1 = Knock_cyl1; emit Knock_cyl1Changed(Knock_cyl1); }
}
void EngineData::setKnock_cyl2(qreal Knock_cyl2) {
    if (m_Knock_cyl2 != Knock_cyl2) { m_Knock_cyl2 = Knock_cyl2; emit Knock_cyl2Changed(Knock_cyl2); }
}
void EngineData::setKnock_cyl3(qreal Knock_cyl3) {
    if (m_Knock_cyl3 != Knock_cyl3) { m_Knock_cyl3 = Knock_cyl3; emit Knock_cyl3Changed(Knock_cyl3); }
}
void EngineData::setKnock_cyl4(qreal Knock_cyl4) {
    if (m_Knock_cyl4 != Knock_cyl4) { m_Knock_cyl4 = Knock_cyl4; emit Knock_cyl4Changed(Knock_cyl4); }
}

// * Setters - EGT
void EngineData::setegt1(qreal egt1) {
    if (m_egt1 != egt1) { m_egt1 = egt1; emit egt1Changed(egt1); }
}
void EngineData::setegt2(qreal egt2) {
    if (m_egt2 != egt2) { m_egt2 = egt2; emit egt2Changed(egt2); }
}
void EngineData::setegt3(qreal egt3) {
    if (m_egt3 != egt3) { m_egt3 = egt3; emit egt3Changed(egt3); }
}
void EngineData::setegt4(qreal egt4) {
    if (m_egt4 != egt4) { m_egt4 = egt4; emit egt4Changed(egt4); }
}
void EngineData::setegt5(qreal egt5) {
    if (m_egt5 != egt5) { m_egt5 = egt5; emit egt5Changed(egt5); }
}
void EngineData::setegt6(qreal egt6) {
    if (m_egt6 != egt6) { m_egt6 = egt6; emit egt6Changed(egt6); }
}
void EngineData::setegt7(qreal egt7) {
    if (m_egt7 != egt7) { m_egt7 = egt7; emit egt7Changed(egt7); }
}
void EngineData::setegt8(qreal egt8) {
    if (m_egt8 != egt8) { m_egt8 = egt8; emit egt8Changed(egt8); }
}
void EngineData::setegt9(qreal egt9) {
    if (m_egt9 != egt9) { m_egt9 = egt9; emit egt9Changed(egt9); }
}
void EngineData::setegt10(qreal egt10) {
    if (m_egt10 != egt10) { m_egt10 = egt10; emit egt10Changed(egt10); }
}
void EngineData::setegt11(qreal egt11) {
    if (m_egt11 != egt11) { m_egt11 = egt11; emit egt11Changed(egt11); }
}
void EngineData::setegt12(qreal egt12) {
    if (m_egt12 != egt12) { m_egt12 = egt12; emit egt12Changed(egt12); }
}
void EngineData::setegthighest(qreal egthighest) {
    if (m_egthighest != egthighest) { m_egthighest = egthighest; emit egthighestChanged(egthighest); }
}
void EngineData::setegtdiff(qreal egtdiff) {
    if (m_egtdiff != egtdiff) { m_egtdiff = egtdiff; emit egtdiffChanged(egtdiff); }
}

// * Setters - Power/Torque
void EngineData::setPower(qreal Power) {
    if (m_Power != Power) { m_Power = Power; emit powerChanged(Power); }
}
void EngineData::setTorque(qreal Torque) {
    if (m_Torque != Torque) { m_Torque = Torque; emit torqueChanged(Torque); }
}

// * Setters - Nitrous
void EngineData::setnosactive(qreal nosactive) {
    if (m_nosactive != nosactive) { m_nosactive = nosactive; emit nosactiveChanged(nosactive); }
}
void EngineData::setnospress(qreal nospress) {
    if (m_nospress != nospress) { m_nospress = nospress; emit nospressChanged(nospress); }
}
void EngineData::setnosswitch(qreal nosswitch) {
    if (m_nosswitch != nosswitch) { m_nosswitch = nosswitch; emit nosswitchChanged(nosswitch); }
}
void EngineData::setnitrous1_duty(qreal nitrous1_duty) {
    if (m_nitrous1_duty != nitrous1_duty) { m_nitrous1_duty = nitrous1_duty; emit nitrous1_dutyChanged(nitrous1_duty); }
}
void EngineData::setnitrous2_duty(qreal nitrous2_duty) {
    if (m_nitrous2_duty != nitrous2_duty) { m_nitrous2_duty = nitrous2_duty; emit nitrous2_dutyChanged(nitrous2_duty); }
}
void EngineData::setnitrous_timer_out(qreal nitrous_timer_out) {
    if (m_nitrous_timer_out != nitrous_timer_out) { m_nitrous_timer_out = nitrous_timer_out; emit nitrous_timer_outChanged(nitrous_timer_out); }
}
void EngineData::setn2o_addfuel(qreal n2o_addfuel) {
    if (m_n2o_addfuel != n2o_addfuel) { m_n2o_addfuel = n2o_addfuel; emit n2o_addfuelChanged(n2o_addfuel); }
}
void EngineData::setn2o_retard(qreal n2o_retard) {
    if (m_n2o_retard != n2o_retard) { m_n2o_retard = n2o_retard; emit n2o_retardChanged(n2o_retard); }
}

// * Setters - Launch/Antilag Control
void EngineData::setantilaglauchswitch(qreal antilaglauchswitch) {
    if (m_antilaglauchswitch != antilaglauchswitch) { m_antilaglauchswitch = antilaglauchswitch; emit antilaglauchswitchChanged(antilaglauchswitch); }
}
void EngineData::setantilaglaunchon(qreal antilaglaunchon) {
    if (m_antilaglaunchon != antilaglaunchon) { m_antilaglaunchon = antilaglaunchon; emit antilaglaunchonChanged(antilaglaunchon); }
}
void EngineData::setauxrevlimitswitch(qreal auxrevlimitswitch) {
    if (m_auxrevlimitswitch != auxrevlimitswitch) { m_auxrevlimitswitch = auxrevlimitswitch; emit auxrevlimitswitchChanged(auxrevlimitswitch); }
}
void EngineData::setrallyantilagswitch(qreal rallyantilagswitch) {
    if (m_rallyantilagswitch != rallyantilagswitch) { m_rallyantilagswitch = rallyantilagswitch; emit rallyantilagswitchChanged(rallyantilagswitch); }
}
void EngineData::setlaunchcontolfuelenrich(qreal launchcontolfuelenrich) {
    if (m_launchcontolfuelenrich != launchcontolfuelenrich) { m_launchcontolfuelenrich = launchcontolfuelenrich; emit launchcontolfuelenrichChanged(launchcontolfuelenrich); }
}
void EngineData::setlaunchctrolignretard(qreal launchctrolignretard) {
    if (m_launchctrolignretard != launchctrolignretard) { m_launchctrolignretard = launchctrolignretard; emit launchctrolignretardChanged(launchctrolignretard); }
}
void EngineData::setflatshiftstate(qreal flatshiftstate) {
    if (m_flatshiftstate != flatshiftstate) { m_flatshiftstate = flatshiftstate; emit flatshiftstateChanged(flatshiftstate); }
}

// * Setters - Rev Limiters
void EngineData::setREVLIM3STEP(qreal REVLIM3STEP) {
    if (m_REVLIM3STEP != REVLIM3STEP) { m_REVLIM3STEP = REVLIM3STEP; emit REVLIM3STEPChanged(REVLIM3STEP); }
}
void EngineData::setREVLIM2STEP(qreal REVLIM2STEP) {
    if (m_REVLIM2STEP != REVLIM2STEP) { m_REVLIM2STEP = REVLIM2STEP; emit REVLIM2STEPChanged(REVLIM2STEP); }
}
void EngineData::setREVLIMGIGHSIDE(qreal REVLIMGIGHSIDE) {
    if (m_REVLIMGIGHSIDE != REVLIMGIGHSIDE) { m_REVLIMGIGHSIDE = REVLIMGIGHSIDE; emit REVLIMGIGHSIDEChanged(REVLIMGIGHSIDE); }
}
void EngineData::setREVLIMBOURNOUT(qreal REVLIMBOURNOUT) {
    if (m_REVLIMBOURNOUT != REVLIMBOURNOUT) { m_REVLIMBOURNOUT = REVLIMBOURNOUT; emit REVLIMBOURNOUTChanged(REVLIMBOURNOUT); }
}

// * Setters - Traction Control
void EngineData::settractionControl(qreal tractionControl) {
    if (m_tractionControl != tractionControl) { m_tractionControl = tractionControl; emit tractionControlChanged(tractionControl); }
}
void EngineData::setTRACTIONCTRLOFFSET(qreal TRACTIONCTRLOFFSET) {
    if (m_TRACTIONCTRLOFFSET != TRACTIONCTRLOFFSET) { m_TRACTIONCTRLOFFSET = TRACTIONCTRLOFFSET; emit TRACTIONCTRLOFFSETChanged(TRACTIONCTRLOFFSET); }
}
void EngineData::setDRIVESHAFTOFFSET(qreal DRIVESHAFTOFFSET) {
    if (m_DRIVESHAFTOFFSET != DRIVESHAFTOFFSET) { m_DRIVESHAFTOFFSET = DRIVESHAFTOFFSET; emit DRIVESHAFTOFFSETChanged(DRIVESHAFTOFFSET); }
}
void EngineData::setTCCOMMAND(qreal TCCOMMAND) {
    if (m_TCCOMMAND != TCCOMMAND) { m_TCCOMMAND = TCCOMMAND; emit TCCOMMANDChanged(TCCOMMAND); }
}
void EngineData::setFSLCOMMAND(qreal FSLCOMMAND) {
    if (m_FSLCOMMAND != FSLCOMMAND) { m_FSLCOMMAND = FSLCOMMAND; emit FSLCOMMANDChanged(FSLCOMMAND); }
}
void EngineData::setFSLINDEX(qreal FSLINDEX) {
    if (m_FSLINDEX != FSLINDEX) { m_FSLINDEX = FSLINDEX; emit FSLINDEXChanged(FSLINDEX); }
}
void EngineData::setdsettargetslip(qreal dsettargetslip) {
    if (m_dsettargetslip != dsettargetslip) { m_dsettargetslip = dsettargetslip; emit dsettargetslipChanged(dsettargetslip); }
}
void EngineData::settractionctlpowerlimit(qreal tractionctlpowerlimit) {
    if (m_tractionctlpowerlimit != tractionctlpowerlimit) { m_tractionctlpowerlimit = tractionctlpowerlimit; emit tractionctlpowerlimitChanged(tractionctlpowerlimit); }
}

// * Setters - ECU State
void EngineData::setBatteryV(qreal BatteryV) {
    if (m_BatteryV != BatteryV) { m_BatteryV = BatteryV; emit batteryVChanged(BatteryV); }
}
void EngineData::setbattlight(qreal battlight) {
    if (m_battlight != battlight) { m_battlight = battlight; emit battlightChanged(battlight); }
}
void EngineData::setdecelcut(qreal decelcut) {
    if (m_decelcut != decelcut) { m_decelcut = decelcut; emit decelcutChanged(decelcut); }
}
void EngineData::setlimpmode(qreal limpmode) {
    if (m_limpmode != limpmode) { m_limpmode = limpmode; emit limpmodeChanged(limpmode); }
}
void EngineData::setmil(qreal mil) {
    if (m_mil != mil) { m_mil = mil; emit milChanged(mil); }
}
void EngineData::setmissccount(qreal missccount) {
    if (m_missccount != missccount) { m_missccount = missccount; emit missccountChanged(missccount); }
}
void EngineData::setcputempecu(qreal cputempecu) {
    if (m_cputempecu != cputempecu) { m_cputempecu = cputempecu; emit cputempecuChanged(cputempecu); }
}
void EngineData::seterrorcodecount(qreal errorcodecount) {
    if (m_errorcodecount != errorcodecount) { m_errorcodecount = errorcodecount; emit errorcodecountChanged(errorcodecount); }
}
void EngineData::setlostsynccount(qreal lostsynccount) {
    if (m_lostsynccount != lostsynccount) { m_lostsynccount = lostsynccount; emit lostsynccountChanged(lostsynccount); }
}
void EngineData::setactivetunetable(qreal activetunetable) {
    if (m_activetunetable != activetunetable) { m_activetunetable = activetunetable; emit activetunetableChanged(activetunetable); }
}
void EngineData::setgenericoutput1(qreal genericoutput1) {
    if (m_genericoutput1 != genericoutput1) { m_genericoutput1 = genericoutput1; emit genericoutput1Changed(genericoutput1); }
}

// * Setters - Torque Management
void EngineData::settorqueredcutactive(qreal torqueredcutactive) {
    if (m_torqueredcutactive != torqueredcutactive) { m_torqueredcutactive = torqueredcutactive; emit torqueredcutactiveChanged(torqueredcutactive); }
}
void EngineData::settorqueredlevelactive(qreal torqueredlevelactive) {
    if (m_torqueredlevelactive != torqueredlevelactive) { m_torqueredlevelactive = torqueredlevelactive; emit torqueredlevelactiveChanged(torqueredlevelactive); }
}
void EngineData::settransientthroactive(qreal transientthroactive) {
    if (m_transientthroactive != transientthroactive) { m_transientthroactive = transientthroactive; emit transientthroactiveChanged(transientthroactive); }
}

// * Setters - Timing/Triggers
void EngineData::settriggerccounter(qreal triggerccounter) {
    if (m_triggerccounter != triggerccounter) { m_triggerccounter = triggerccounter; emit triggerccounterChanged(triggerccounter); }
}
void EngineData::settriggersrsinceasthome(qreal triggersrsinceasthome) {
    if (m_triggersrsinceasthome != triggersrsinceasthome) { m_triggersrsinceasthome = triggersrsinceasthome; emit triggersrsinceasthomeChanged(triggersrsinceasthome); }
}
void EngineData::sethomeccounter(qreal homeccounter) {
    if (m_homeccounter != homeccounter) { m_homeccounter = homeccounter; emit homeccounterChanged(homeccounter); }
}
void EngineData::settimeddutyout1(qreal timeddutyout1) {
    if (m_timeddutyout1 != timeddutyout1) { m_timeddutyout1 = timeddutyout1; emit timeddutyout1Changed(timeddutyout1); }
}
void EngineData::settimeddutyout2(qreal timeddutyout2) {
    if (m_timeddutyout2 != timeddutyout2) { m_timeddutyout2 = timeddutyout2; emit timeddutyout2Changed(timeddutyout2); }
}
void EngineData::settimeddutyoutputactive(qreal timeddutyoutputactive) {
    if (m_timeddutyoutputactive != timeddutyoutputactive) { m_timeddutyoutputactive = timeddutyoutputactive; emit timeddutyoutputactiveChanged(timeddutyoutputactive); }
}

// * Setters - Misc
void EngineData::setna1(qreal na1) {
    if (m_na1 != na1) { m_na1 = na1; emit na1Changed(na1); }
}
void EngineData::setna2(qreal na2) {
    if (m_na2 != na2) { m_na2 = na2; emit na2Changed(na2); }
}
void EngineData::setCylinders(qreal Cylinders) {
    if (m_Cylinders != Cylinders) { m_Cylinders = Cylinders; emit CylindersChanged(Cylinders); }
}
void EngineData::setoilpressurelamp(int oilpressurelamp) {
    if (m_oilpressurelamp != oilpressurelamp) { m_oilpressurelamp = oilpressurelamp; emit oilpressurelampChanged(oilpressurelamp); }
}
void EngineData::setovertempalarm(int overtempalarm) {
    if (m_overtempalarm != overtempalarm) { m_overtempalarm = overtempalarm; emit overtempalarmChanged(overtempalarm); }
}
void EngineData::setalternatorfail(int alternatorfail) {
    if (m_alternatorfail != alternatorfail) { m_alternatorfail = alternatorfail; emit alternatorfailChanged(alternatorfail); }
}

// * Setters - Trimpots
void EngineData::setRotaryTrimpot1(int RotaryTrimpot1) {
    if (m_RotaryTrimpot1 != RotaryTrimpot1) { m_RotaryTrimpot1 = RotaryTrimpot1; emit RotaryTrimpot1Changed(RotaryTrimpot1); }
}
void EngineData::setRotaryTrimpot2(int RotaryTrimpot2) {
    if (m_RotaryTrimpot2 != RotaryTrimpot2) { m_RotaryTrimpot2 = RotaryTrimpot2; emit RotaryTrimpot2Changed(RotaryTrimpot2); }
}
void EngineData::setRotaryTrimpot3(int RotaryTrimpot3) {
    if (m_RotaryTrimpot3 != RotaryTrimpot3) { m_RotaryTrimpot3 = RotaryTrimpot3; emit RotaryTrimpot3Changed(RotaryTrimpot3); }
}
void EngineData::setCalibrationSelect(int CalibrationSelect) {
    if (m_CalibrationSelect != CalibrationSelect) { m_CalibrationSelect = CalibrationSelect; emit CalibrationSelectChanged(CalibrationSelect); }
}
