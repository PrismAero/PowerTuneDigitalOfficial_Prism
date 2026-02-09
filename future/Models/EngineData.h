/**
 * @file EngineData.h
 * @brief Engine-specific data model for PowerTune
 *
 * This class encapsulates all engine-related sensor data including:
 * - RPM, boost, MAP, TPS, throttle
 * - Injector duty, pulse width, timing
 * - Fuel correction, trim, pressure
 * - Ignition timing (leading/trailing)
 * - Engine load, dwell, knock
 * - Cylinder-specific data (AFR, O2 correction)
 * - EGT 1-12
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#ifndef ENGINEDATA_H
#define ENGINEDATA_H

#include <QObject>

class EngineData : public QObject
{
    Q_OBJECT

    // * Core Engine Metrics
    Q_PROPERTY(qreal rpm READ rpm WRITE setrpm NOTIFY rpmChanged)
    Q_PROPERTY(qreal Intakepress READ Intakepress WRITE setIntakepress NOTIFY intakepressChanged)
    Q_PROPERTY(qreal PressureV READ PressureV WRITE setPressureV NOTIFY pressureVChanged)
    Q_PROPERTY(qreal ThrottleV READ ThrottleV WRITE setThrottleV NOTIFY throttleVChanged)
    Q_PROPERTY(qreal Primaryinp READ Primaryinp WRITE setPrimaryinp NOTIFY primaryinpChanged)
    Q_PROPERTY(qreal EngLoad READ EngLoad WRITE setEngLoad NOTIFY engLoadChanged)
    Q_PROPERTY(qreal pim READ pim WRITE setpim NOTIFY pimChanged)
    Q_PROPERTY(qreal TPS READ TPS WRITE setTPS NOTIFY tPSChanged)
    Q_PROPERTY(qreal IdleValue READ IdleValue WRITE setIdleValue NOTIFY idleValueChanged)
    Q_PROPERTY(qreal Iscvduty READ Iscvduty WRITE setIscvduty NOTIFY iscvdutyChanged)

    // * Boost/Turbo
    Q_PROPERTY(qreal Boosttp READ Boosttp WRITE setBoosttp NOTIFY boosttpChanged)
    Q_PROPERTY(qreal Boostwg READ Boostwg WRITE setBoostwg NOTIFY boostwgChanged)
    Q_PROPERTY(qreal BoostPres READ BoostPres WRITE setBoostPres NOTIFY BoostPresChanged)
    Q_PROPERTY(qreal BoostPreskpa READ BoostPreskpa WRITE setBoostPreskpa NOTIFY BoostPreskpaChanged)
    Q_PROPERTY(qreal BoostDuty READ BoostDuty WRITE setBoostDuty NOTIFY boostDutyChanged)
    Q_PROPERTY(qreal boostcontrol READ boostcontrol WRITE setboostcontrol NOTIFY boostcontrolChanged)
    Q_PROPERTY(qreal targetbstlelkpa READ targetbstlelkpa WRITE settargetbstlelkpa NOTIFY targetbstlelkpaChanged)
    Q_PROPERTY(qreal wastegatepress READ wastegatepress WRITE setwastegatepress NOTIFY wastegatepressChanged)
    Q_PROPERTY(qreal turborpm READ turborpm WRITE setturborpm NOTIFY turborpmChanged)
    Q_PROPERTY(qreal turborpm2 READ turborpm2 WRITE setturborpm2 NOTIFY turborpm2Changed)
    Q_PROPERTY(qreal BOOSTOFFSET READ BOOSTOFFSET WRITE setBOOSTOFFSET NOTIFY BOOSTOFFSETChanged)
    Q_PROPERTY(qreal activeboosttable READ activeboosttable WRITE setactiveboosttable NOTIFY activeboosttableChanged)

    // * MAP/MAF
    Q_PROPERTY(qreal MAP READ MAP WRITE setMAP NOTIFY mAPChanged)
    Q_PROPERTY(qreal MAP2 READ MAP2 WRITE setMAP2 NOTIFY mAP2Changed)
    Q_PROPERTY(qreal MAF1V READ MAF1V WRITE setMAF1V NOTIFY mAF1VChanged)
    Q_PROPERTY(qreal MAF2V READ MAF2V WRITE setMAF2V NOTIFY mAF2VChanged)
    Q_PROPERTY(qreal MAFactivity READ MAFactivity WRITE setMAFactivity NOTIFY mAFactivityChanged)
    Q_PROPERTY(qreal PANVAC READ PANVAC WRITE setPANVAC NOTIFY PANVACChanged)

    // * Fuel System
    Q_PROPERTY(qreal Fuelc READ Fuelc WRITE setFuelc NOTIFY fuelcChanged)
    Q_PROPERTY(qreal Fueltemp READ Fueltemp WRITE setFueltemp NOTIFY fueltempChanged)
    Q_PROPERTY(qreal FuelPress READ FuelPress WRITE setFuelPress NOTIFY fuelPressChanged)
    Q_PROPERTY(qreal fuelclevel READ fuelclevel WRITE setfuelclevel NOTIFY fuelclevelChanged)
    Q_PROPERTY(qreal fuelcomposition READ fuelcomposition WRITE setfuelcomposition NOTIFY fuelcompositionChanged)
    Q_PROPERTY(qreal fuelconsrate READ fuelconsrate WRITE setfuelconsrate NOTIFY fuelconsrateChanged)
    Q_PROPERTY(qreal fuelcutperc READ fuelcutperc WRITE setfuelcutperc NOTIFY fuelcutpercChanged)
    Q_PROPERTY(qreal fuelflow READ fuelflow WRITE setfuelflow NOTIFY fuelflowChanged)
    Q_PROPERTY(qreal fuelflowdiff READ fuelflowdiff WRITE setfuelflowdiff NOTIFY fuelflowdiffChanged)
    Q_PROPERTY(qreal fuelflowret READ fuelflowret WRITE setfuelflowret NOTIFY fuelflowretChanged)
    Q_PROPERTY(
        qreal fueltrimlongtbank1 READ fueltrimlongtbank1 WRITE setfueltrimlongtbank1 NOTIFY fueltrimlongtbank1Changed)
    Q_PROPERTY(
        qreal fueltrimlongtbank2 READ fueltrimlongtbank2 WRITE setfueltrimlongtbank2 NOTIFY fueltrimlongtbank2Changed)
    Q_PROPERTY(qreal fueltrimshorttbank1 READ fueltrimshorttbank1 WRITE setfueltrimshorttbank1 NOTIFY
                   fueltrimshorttbank1Changed)
    Q_PROPERTY(qreal fueltrimshorttbank2 READ fueltrimshorttbank2 WRITE setfueltrimshorttbank2 NOTIFY
                   fueltrimshorttbank2Changed)
    Q_PROPERTY(qreal totalfueltrim READ totalfueltrim WRITE settotalfueltrim NOTIFY totalfueltrimChanged)
    Q_PROPERTY(qreal avfueleconomy READ avfueleconomy WRITE setavfueleconomy NOTIFY avfueleconomyChanged)

    // * Injectors
    Q_PROPERTY(qreal InjDuty READ InjDuty WRITE setInjDuty NOTIFY injDutyChanged)
    Q_PROPERTY(qreal InjDuty2 READ InjDuty2 WRITE setInjDuty2 NOTIFY injDuty2Changed)
    Q_PROPERTY(qreal InjAngle READ InjAngle WRITE setInjAngle NOTIFY InjAngleChanged)
    Q_PROPERTY(qreal injms READ injms WRITE setinjms NOTIFY injmsChanged)
    Q_PROPERTY(qreal Inj READ Inj WRITE setInj NOTIFY injChanged)
    Q_PROPERTY(qreal Inj1 READ Inj1 WRITE setInj1 NOTIFY inj1Changed)
    Q_PROPERTY(qreal Inj2 READ Inj2 WRITE setInj2 NOTIFY inj2Changed)
    Q_PROPERTY(qreal Inj3 READ Inj3 WRITE setInj3 NOTIFY inj3Changed)
    Q_PROPERTY(qreal Inj4 READ Inj4 WRITE setInj4 NOTIFY inj4Changed)
    Q_PROPERTY(qreal Secinjpulse READ Secinjpulse WRITE setSecinjpulse NOTIFY secinjpulseChanged)
    Q_PROPERTY(qreal pwseq1 READ pwseq1 WRITE setpwseq1 NOTIFY pwseq1Changed)
    Q_PROPERTY(qreal pwseq2 READ pwseq2 WRITE setpwseq2 NOTIFY pwseq2Changed)
    Q_PROPERTY(qreal pwseq3 READ pwseq3 WRITE setpwseq3 NOTIFY pwseq3Changed)
    Q_PROPERTY(qreal pwseq4 READ pwseq4 WRITE setpwseq4 NOTIFY pwseq4Changed)

    // * Ignition
    Q_PROPERTY(qreal Ign READ Ign WRITE setIgn NOTIFY ignChanged)
    Q_PROPERTY(qreal Ign1 READ Ign1 WRITE setIgn1 NOTIFY ign1Changed)
    Q_PROPERTY(qreal Ign2 READ Ign2 WRITE setIgn2 NOTIFY ign2Changed)
    Q_PROPERTY(qreal Ign3 READ Ign3 WRITE setIgn3 NOTIFY ign3Changed)
    Q_PROPERTY(qreal Ign4 READ Ign4 WRITE setIgn4 NOTIFY ign4Changed)
    Q_PROPERTY(qreal Leadingign READ Leadingign WRITE setLeadingign NOTIFY leadingignChanged)
    Q_PROPERTY(qreal Trailingign READ Trailingign WRITE setTrailingign NOTIFY trailingignChanged)
    Q_PROPERTY(qreal Dwell READ Dwell WRITE setDwell NOTIFY dwellChanged)
    Q_PROPERTY(qreal igncut READ igncut WRITE setigncut NOTIFY igncutChanged)
    Q_PROPERTY(qreal totaligncomp READ totaligncomp WRITE settotaligncomp NOTIFY totaligncompChanged)

    // * Cam Angles
    Q_PROPERTY(qreal excamangle1 READ excamangle1 WRITE setexcamangle1 NOTIFY excamangle1Changed)
    Q_PROPERTY(qreal excamangle2 READ excamangle2 WRITE setexcamangle2 NOTIFY excamangle2Changed)
    Q_PROPERTY(qreal incamangle1 READ incamangle1 WRITE setincamangle1 NOTIFY incamangle1Changed)
    Q_PROPERTY(qreal incamangle2 READ incamangle2 WRITE setincamangle2 NOTIFY incamangle2Changed)

    // * Temperatures
    Q_PROPERTY(qreal Watertemp READ Watertemp WRITE setWatertemp NOTIFY watertempChanged)
    Q_PROPERTY(qreal Intaketemp READ Intaketemp WRITE setIntaketemp NOTIFY intaketempChanged)
    Q_PROPERTY(qreal airtempensor2 READ airtempensor2 WRITE setairtempensor2 NOTIFY airtempensor2Changed)
    Q_PROPERTY(qreal oiltemp READ oiltemp WRITE setoiltemp NOTIFY oiltempChanged)
    Q_PROPERTY(qreal transoiltemp READ transoiltemp WRITE settransoiltemp NOTIFY transoiltempChanged)
    Q_PROPERTY(qreal diffoiltemp READ diffoiltemp WRITE setdiffoiltemp NOTIFY diffoiltempChanged)
    Q_PROPERTY(qreal coolantpress READ coolantpress WRITE setcoolantpress NOTIFY coolantpressChanged)
    Q_PROPERTY(qreal AUXT READ AUXT WRITE setAUXT NOTIFY aUXTChanged)
    Q_PROPERTY(int AuxTemp1 READ AuxTemp1 WRITE setAuxTemp1 NOTIFY AuxTemp1Changed)

    // * Pressures
    Q_PROPERTY(qreal oilpres READ oilpres WRITE setoilpres NOTIFY oilpresChanged)
    Q_PROPERTY(qreal Moilp READ Moilp WRITE setMoilp NOTIFY moilpChanged)
    Q_PROPERTY(qreal GearOilPress READ GearOilPress WRITE setGearOilPress NOTIFY GearOilPressChanged)
    Q_PROPERTY(qreal brakepress READ brakepress WRITE setbrakepress NOTIFY brakepressChanged)

    // * O2/Lambda/AFR
    Q_PROPERTY(qreal O2volt READ O2volt WRITE setO2volt NOTIFY o2voltChanged)
    Q_PROPERTY(qreal O2volt_2 READ O2volt_2 WRITE setO2volt_2 NOTIFY o2volt_2Changed)
    Q_PROPERTY(qreal LAMBDA READ LAMBDA WRITE setLAMBDA NOTIFY lAMBDAChanged)
    Q_PROPERTY(qreal LAMBDATarget READ LAMBDATarget WRITE setLAMBDATarget NOTIFY lAMBDATargetChanged)
    Q_PROPERTY(qreal lambda2 READ lambda2 WRITE setlambda2 NOTIFY lambda2Changed)
    Q_PROPERTY(qreal lambda3 READ lambda3 WRITE setlambda3 NOTIFY lambda3Changed)
    Q_PROPERTY(qreal lambda4 READ lambda4 WRITE setlambda4 NOTIFY lambda4Changed)
    Q_PROPERTY(qreal Lambdamultiply READ Lambdamultiply WRITE setLambdamultiply NOTIFY LambdamultiplyChanged)
    Q_PROPERTY(qreal AFR READ AFR WRITE setAFR NOTIFY aFRChanged)
    Q_PROPERTY(
        qreal AFRLEFTBANKTARGET READ AFRLEFTBANKTARGET WRITE setAFRLEFTBANKTARGET NOTIFY AFRLEFTBANKTARGETChanged)
    Q_PROPERTY(
        qreal AFRRIGHTBANKTARGET READ AFRRIGHTBANKTARGET WRITE setAFRRIGHTBANKTARGET NOTIFY AFRRIGHTBANKTARGETChanged)
    Q_PROPERTY(
        qreal AFRLEFTBANKACTUAL READ AFRLEFTBANKACTUAL WRITE setAFRLEFTBANKACTUAL NOTIFY AFRLEFTBANKACTUALChanged)
    Q_PROPERTY(
        qreal AFRRIGHTBANKACTUAL READ AFRRIGHTBANKACTUAL WRITE setAFRRIGHTBANKACTUAL NOTIFY AFRRIGHTBANKACTUALChanged)
    Q_PROPERTY(qreal LEFTBANKO2CORR READ LEFTBANKO2CORR WRITE setLEFTBANKO2CORR NOTIFY LEFTBANKO2CORRChanged)
    Q_PROPERTY(qreal RIGHTBANKO2CORR READ RIGHTBANKO2CORR WRITE setRIGHTBANKO2CORR NOTIFY RIGHTBANKO2CORRChanged)
    Q_PROPERTY(qreal TRIM READ TRIM WRITE setTRIM NOTIFY tRIMChanged)

    // * Per-Cylinder O2 Correction
    Q_PROPERTY(qreal Cyl1_O2_Corr READ Cyl1_O2_Corr WRITE setCyl1_O2_Corr NOTIFY Cyl1_O2_CorrChanged)
    Q_PROPERTY(qreal Cyl2_O2_Corr READ Cyl2_O2_Corr WRITE setCyl2_O2_Corr NOTIFY Cyl2_O2_CorrChanged)
    Q_PROPERTY(qreal Cyl3_O2_Corr READ Cyl3_O2_Corr WRITE setCyl3_O2_Corr NOTIFY Cyl3_O2_CorrChanged)
    Q_PROPERTY(qreal Cyl4_O2_Corr READ Cyl4_O2_Corr WRITE setCyl4_O2_Corr NOTIFY Cyl4_O2_CorrChanged)
    Q_PROPERTY(qreal Cyl5_O2_Corr READ Cyl5_O2_Corr WRITE setCyl5_O2_Corr NOTIFY Cyl5_O2_CorrChanged)
    Q_PROPERTY(qreal Cyl6_O2_Corr READ Cyl6_O2_Corr WRITE setCyl6_O2_Corr NOTIFY Cyl6_O2_CorrChanged)
    Q_PROPERTY(qreal Cyl7_O2_Corr READ Cyl7_O2_Corr WRITE setCyl7_O2_Corr NOTIFY Cyl7_O2_CorrChanged)
    Q_PROPERTY(qreal Cyl8_O2_Corr READ Cyl8_O2_Corr WRITE setCyl8_O2_Corr NOTIFY Cyl8_O2_CorrChanged)
    Q_PROPERTY(qreal EGOcor1 READ EGOcor1 WRITE setEGOcor1 NOTIFY EGOcor1Changed)
    Q_PROPERTY(qreal EGOcor2 READ EGOcor2 WRITE setEGOcor2 NOTIFY EGOcor2Changed)
    Q_PROPERTY(qreal EGOcor3 READ EGOcor3 WRITE setEGOcor3 NOTIFY EGOcor3Changed)
    Q_PROPERTY(qreal EGOcor4 READ EGOcor4 WRITE setEGOcor4 NOTIFY EGOcor4Changed)

    // * Per-Cylinder AFR
    Q_PROPERTY(qreal AFRcyl1 READ AFRcyl1 WRITE setAFRcyl1 NOTIFY AFRcyl1Changed)
    Q_PROPERTY(qreal AFRcyl2 READ AFRcyl2 WRITE setAFRcyl2 NOTIFY AFRcyl2Changed)
    Q_PROPERTY(qreal AFRcyl3 READ AFRcyl3 WRITE setAFRcyl3 NOTIFY AFRcyl3Changed)
    Q_PROPERTY(qreal AFRcyl4 READ AFRcyl4 WRITE setAFRcyl4 NOTIFY AFRcyl4Changed)
    Q_PROPERTY(qreal AFRcyl5 READ AFRcyl5 WRITE setAFRcyl5 NOTIFY AFRcyl5Changed)
    Q_PROPERTY(qreal AFRcyl6 READ AFRcyl6 WRITE setAFRcyl6 NOTIFY AFRcyl6Changed)
    Q_PROPERTY(qreal AFRcyl7 READ AFRcyl7 WRITE setAFRcyl7 NOTIFY AFRcyl7Changed)
    Q_PROPERTY(qreal AFRcyl8 READ AFRcyl8 WRITE setAFRcyl8 NOTIFY AFRcyl8Changed)

    // * Knock
    Q_PROPERTY(qreal Knock READ Knock WRITE setKnock NOTIFY knockChanged)
    Q_PROPERTY(qreal knocklevlogged1 READ knocklevlogged1 WRITE setknocklevlogged1 NOTIFY knocklevlogged1Changed)
    Q_PROPERTY(qreal knocklevlogged2 READ knocklevlogged2 WRITE setknocklevlogged2 NOTIFY knocklevlogged2Changed)
    Q_PROPERTY(qreal knockretardbank1 READ knockretardbank1 WRITE setknockretardbank1 NOTIFY knockretardbank1Changed)
    Q_PROPERTY(qreal knockretardbank2 READ knockretardbank2 WRITE setknockretardbank2 NOTIFY knockretardbank2Changed)
    Q_PROPERTY(qreal knockallpeak READ knockallpeak WRITE setknockallpeak NOTIFY knockallpeakChanged)
    Q_PROPERTY(qreal knockcorr READ knockcorr WRITE setknockcorr NOTIFY knockcorrChanged)
    Q_PROPERTY(qreal knocklastcyl READ knocklastcyl WRITE setknocklastcyl NOTIFY knocklastcylChanged)
    Q_PROPERTY(qreal Knock_cyl1 READ Knock_cyl1 WRITE setKnock_cyl1 NOTIFY Knock_cyl1Changed)
    Q_PROPERTY(qreal Knock_cyl2 READ Knock_cyl2 WRITE setKnock_cyl2 NOTIFY Knock_cyl2Changed)
    Q_PROPERTY(qreal Knock_cyl3 READ Knock_cyl3 WRITE setKnock_cyl3 NOTIFY Knock_cyl3Changed)
    Q_PROPERTY(qreal Knock_cyl4 READ Knock_cyl4 WRITE setKnock_cyl4 NOTIFY Knock_cyl4Changed)

    // * EGT (Exhaust Gas Temperature) 1-12
    Q_PROPERTY(qreal egt1 READ egt1 WRITE setegt1 NOTIFY egt1Changed)
    Q_PROPERTY(qreal egt2 READ egt2 WRITE setegt2 NOTIFY egt2Changed)
    Q_PROPERTY(qreal egt3 READ egt3 WRITE setegt3 NOTIFY egt3Changed)
    Q_PROPERTY(qreal egt4 READ egt4 WRITE setegt4 NOTIFY egt4Changed)
    Q_PROPERTY(qreal egt5 READ egt5 WRITE setegt5 NOTIFY egt5Changed)
    Q_PROPERTY(qreal egt6 READ egt6 WRITE setegt6 NOTIFY egt6Changed)
    Q_PROPERTY(qreal egt7 READ egt7 WRITE setegt7 NOTIFY egt7Changed)
    Q_PROPERTY(qreal egt8 READ egt8 WRITE setegt8 NOTIFY egt8Changed)
    Q_PROPERTY(qreal egt9 READ egt9 WRITE setegt9 NOTIFY egt9Changed)
    Q_PROPERTY(qreal egt10 READ egt10 WRITE setegt10 NOTIFY egt10Changed)
    Q_PROPERTY(qreal egt11 READ egt11 WRITE setegt11 NOTIFY egt11Changed)
    Q_PROPERTY(qreal egt12 READ egt12 WRITE setegt12 NOTIFY egt12Changed)
    Q_PROPERTY(qreal egthighest READ egthighest WRITE setegthighest NOTIFY egthighestChanged)
    Q_PROPERTY(qreal egtdiff READ egtdiff WRITE setegtdiff NOTIFY egtdiffChanged)

    // * Power/Torque
    Q_PROPERTY(qreal Power READ Power WRITE setPower NOTIFY powerChanged)
    Q_PROPERTY(qreal Torque READ Torque WRITE setTorque NOTIFY torqueChanged)

    // * Nitrous
    Q_PROPERTY(qreal nosactive READ nosactive WRITE setnosactive NOTIFY nosactiveChanged)
    Q_PROPERTY(qreal nospress READ nospress WRITE setnospress NOTIFY nospressChanged)
    Q_PROPERTY(qreal nosswitch READ nosswitch WRITE setnosswitch NOTIFY nosswitchChanged)
    Q_PROPERTY(qreal nitrous1_duty READ nitrous1_duty WRITE setnitrous1_duty NOTIFY nitrous1_dutyChanged)
    Q_PROPERTY(qreal nitrous2_duty READ nitrous2_duty WRITE setnitrous2_duty NOTIFY nitrous2_dutyChanged)
    Q_PROPERTY(
        qreal nitrous_timer_out READ nitrous_timer_out WRITE setnitrous_timer_out NOTIFY nitrous_timer_outChanged)
    Q_PROPERTY(qreal n2o_addfuel READ n2o_addfuel WRITE setn2o_addfuel NOTIFY n2o_addfuelChanged)
    Q_PROPERTY(qreal n2o_retard READ n2o_retard WRITE setn2o_retard NOTIFY n2o_retardChanged)

    // * Launch/Antilag Control
    Q_PROPERTY(
        qreal antilaglauchswitch READ antilaglauchswitch WRITE setantilaglauchswitch NOTIFY antilaglauchswitchChanged)
    Q_PROPERTY(qreal antilaglaunchon READ antilaglaunchon WRITE setantilaglaunchon NOTIFY antilaglaunchonChanged)
    Q_PROPERTY(
        qreal auxrevlimitswitch READ auxrevlimitswitch WRITE setauxrevlimitswitch NOTIFY auxrevlimitswitchChanged)
    Q_PROPERTY(
        qreal rallyantilagswitch READ rallyantilagswitch WRITE setrallyantilagswitch NOTIFY rallyantilagswitchChanged)
    Q_PROPERTY(qreal launchcontolfuelenrich READ launchcontolfuelenrich WRITE setlaunchcontolfuelenrich NOTIFY
                   launchcontolfuelenrichChanged)
    Q_PROPERTY(qreal launchctrolignretard READ launchctrolignretard WRITE setlaunchctrolignretard NOTIFY
                   launchctrolignretardChanged)
    Q_PROPERTY(qreal flatshiftstate READ flatshiftstate WRITE setflatshiftstate NOTIFY flatshiftstateChanged)

    // * Rev Limiters
    Q_PROPERTY(qreal REVLIM3STEP READ REVLIM3STEP WRITE setREVLIM3STEP NOTIFY REVLIM3STEPChanged)
    Q_PROPERTY(qreal REVLIM2STEP READ REVLIM2STEP WRITE setREVLIM2STEP NOTIFY REVLIM2STEPChanged)
    Q_PROPERTY(qreal REVLIMGIGHSIDE READ REVLIMGIGHSIDE WRITE setREVLIMGIGHSIDE NOTIFY REVLIMGIGHSIDEChanged)
    Q_PROPERTY(qreal REVLIMBOURNOUT READ REVLIMBOURNOUT WRITE setREVLIMBOURNOUT NOTIFY REVLIMBOURNOUTChanged)

    // * Traction Control
    Q_PROPERTY(qreal tractionControl READ tractionControl WRITE settractionControl NOTIFY tractionControlChanged)
    Q_PROPERTY(
        qreal TRACTIONCTRLOFFSET READ TRACTIONCTRLOFFSET WRITE setTRACTIONCTRLOFFSET NOTIFY TRACTIONCTRLOFFSETChanged)
    Q_PROPERTY(qreal DRIVESHAFTOFFSET READ DRIVESHAFTOFFSET WRITE setDRIVESHAFTOFFSET NOTIFY DRIVESHAFTOFFSETChanged)
    Q_PROPERTY(qreal TCCOMMAND READ TCCOMMAND WRITE setTCCOMMAND NOTIFY TCCOMMANDChanged)
    Q_PROPERTY(qreal FSLCOMMAND READ FSLCOMMAND WRITE setFSLCOMMAND NOTIFY FSLCOMMANDChanged)
    Q_PROPERTY(qreal FSLINDEX READ FSLINDEX WRITE setFSLINDEX NOTIFY FSLINDEXChanged)
    Q_PROPERTY(qreal dsettargetslip READ dsettargetslip WRITE setdsettargetslip NOTIFY dsettargetslipChanged)
    Q_PROPERTY(qreal tractionctlpowerlimit READ tractionctlpowerlimit WRITE settractionctlpowerlimit NOTIFY
                   tractionctlpowerlimitChanged)

    // * ECU State
    Q_PROPERTY(qreal BatteryV READ BatteryV WRITE setBatteryV NOTIFY batteryVChanged)
    Q_PROPERTY(qreal battlight READ battlight WRITE setbattlight NOTIFY battlightChanged)
    Q_PROPERTY(qreal decelcut READ decelcut WRITE setdecelcut NOTIFY decelcutChanged)
    Q_PROPERTY(qreal limpmode READ limpmode WRITE setlimpmode NOTIFY limpmodeChanged)
    Q_PROPERTY(qreal mil READ mil WRITE setmil NOTIFY milChanged)
    Q_PROPERTY(qreal missccount READ missccount WRITE setmissccount NOTIFY missccountChanged)
    Q_PROPERTY(qreal cputempecu READ cputempecu WRITE setcputempecu NOTIFY cputempecuChanged)
    Q_PROPERTY(qreal errorcodecount READ errorcodecount WRITE seterrorcodecount NOTIFY errorcodecountChanged)
    Q_PROPERTY(qreal lostsynccount READ lostsynccount WRITE setlostsynccount NOTIFY lostsynccountChanged)
    Q_PROPERTY(qreal activetunetable READ activetunetable WRITE setactivetunetable NOTIFY activetunetableChanged)
    Q_PROPERTY(qreal genericoutput1 READ genericoutput1 WRITE setgenericoutput1 NOTIFY genericoutput1Changed)

    // * Torque Management
    Q_PROPERTY(
        qreal torqueredcutactive READ torqueredcutactive WRITE settorqueredcutactive NOTIFY torqueredcutactiveChanged)
    Q_PROPERTY(qreal torqueredlevelactive READ torqueredlevelactive WRITE settorqueredlevelactive NOTIFY
                   torqueredlevelactiveChanged)
    Q_PROPERTY(qreal transientthroactive READ transientthroactive WRITE settransientthroactive NOTIFY
                   transientthroactiveChanged)

    // * Timing/Triggers
    Q_PROPERTY(qreal triggerccounter READ triggerccounter WRITE settriggerccounter NOTIFY triggerccounterChanged)
    Q_PROPERTY(qreal triggersrsinceasthome READ triggersrsinceasthome WRITE settriggersrsinceasthome NOTIFY
                   triggersrsinceasthomeChanged)
    Q_PROPERTY(qreal homeccounter READ homeccounter WRITE sethomeccounter NOTIFY homeccounterChanged)
    Q_PROPERTY(qreal timeddutyout1 READ timeddutyout1 WRITE settimeddutyout1 NOTIFY timeddutyout1Changed)
    Q_PROPERTY(qreal timeddutyout2 READ timeddutyout2 WRITE settimeddutyout2 NOTIFY timeddutyout2Changed)
    Q_PROPERTY(qreal timeddutyoutputactive READ timeddutyoutputactive WRITE settimeddutyoutputactive NOTIFY
                   timeddutyoutputactiveChanged)

    // * Misc
    Q_PROPERTY(qreal na1 READ na1 WRITE setna1 NOTIFY na1Changed)
    Q_PROPERTY(qreal na2 READ na2 WRITE setna2 NOTIFY na2Changed)
    Q_PROPERTY(qreal Cylinders READ Cylinders WRITE setCylinders NOTIFY CylindersChanged)
    Q_PROPERTY(int oilpressurelamp READ oilpressurelamp WRITE setoilpressurelamp NOTIFY oilpressurelampChanged)
    Q_PROPERTY(int overtempalarm READ overtempalarm WRITE setovertempalarm NOTIFY overtempalarmChanged)
    Q_PROPERTY(int alternatorfail READ alternatorfail WRITE setalternatorfail NOTIFY alternatorfailChanged)

    // * Trimpots (Calibration)
    Q_PROPERTY(int RotaryTrimpot1 READ RotaryTrimpot1 WRITE setRotaryTrimpot1 NOTIFY RotaryTrimpot1Changed)
    Q_PROPERTY(int RotaryTrimpot2 READ RotaryTrimpot2 WRITE setRotaryTrimpot2 NOTIFY RotaryTrimpot2Changed)
    Q_PROPERTY(int RotaryTrimpot3 READ RotaryTrimpot3 WRITE setRotaryTrimpot3 NOTIFY RotaryTrimpot3Changed)
    Q_PROPERTY(int CalibrationSelect READ CalibrationSelect WRITE setCalibrationSelect NOTIFY CalibrationSelectChanged)

public:
    explicit EngineData(QObject *parent = nullptr);

    // * Getters - Core Engine Metrics
    qreal rpm() const { return m_rpm; }
    qreal Intakepress() const { return m_Intakepress; }
    qreal PressureV() const { return m_PressureV; }
    qreal ThrottleV() const { return m_ThrottleV; }
    qreal Primaryinp() const { return m_Primaryinp; }
    qreal EngLoad() const { return m_EngLoad; }
    qreal pim() const { return m_pim; }
    qreal TPS() const { return m_TPS; }
    qreal IdleValue() const { return m_IdleValue; }
    qreal Iscvduty() const { return m_Iscvduty; }

    // * Getters - Boost/Turbo
    qreal Boosttp() const { return m_Boosttp; }
    qreal Boostwg() const { return m_Boostwg; }
    qreal BoostPres() const { return m_BoostPres; }
    qreal BoostPreskpa() const { return m_BoostPreskpa; }
    qreal BoostDuty() const { return m_BoostDuty; }
    qreal boostcontrol() const { return m_boostcontrol; }
    qreal targetbstlelkpa() const { return m_targetbstlelkpa; }
    qreal wastegatepress() const { return m_wastegatepress; }
    qreal turborpm() const { return m_turborpm; }
    qreal turborpm2() const { return m_turborpm2; }
    qreal BOOSTOFFSET() const { return m_BOOSTOFFSET; }
    qreal activeboosttable() const { return m_activeboosttable; }

    // * Getters - MAP/MAF
    qreal MAP() const { return m_MAP; }
    qreal MAP2() const { return m_MAP2; }
    qreal MAF1V() const { return m_MAF1V; }
    qreal MAF2V() const { return m_MAF2V; }
    qreal MAFactivity() const { return m_MAFactivity; }
    qreal PANVAC() const { return m_PANVAC; }

    // * Getters - Fuel System
    qreal Fuelc() const { return m_Fuelc; }
    qreal Fueltemp() const { return m_Fueltemp; }
    qreal FuelPress() const { return m_FuelPress; }
    qreal fuelclevel() const { return m_fuelclevel; }
    qreal fuelcomposition() const { return m_fuelcomposition; }
    qreal fuelconsrate() const { return m_fuelconsrate; }
    qreal fuelcutperc() const { return m_fuelcutperc; }
    qreal fuelflow() const { return m_fuelflow; }
    qreal fuelflowdiff() const { return m_fuelflowdiff; }
    qreal fuelflowret() const { return m_fuelflowret; }
    qreal fueltrimlongtbank1() const { return m_fueltrimlongtbank1; }
    qreal fueltrimlongtbank2() const { return m_fueltrimlongtbank2; }
    qreal fueltrimshorttbank1() const { return m_fueltrimshorttbank1; }
    qreal fueltrimshorttbank2() const { return m_fueltrimshorttbank2; }
    qreal totalfueltrim() const { return m_totalfueltrim; }
    qreal avfueleconomy() const { return m_avfueleconomy; }

    // * Getters - Injectors
    qreal InjDuty() const { return m_InjDuty; }
    qreal InjDuty2() const { return m_InjDuty2; }
    qreal InjAngle() const { return m_InjAngle; }
    qreal injms() const { return m_injms; }
    qreal Inj() const { return m_Inj; }
    qreal Inj1() const { return m_Inj1; }
    qreal Inj2() const { return m_Inj2; }
    qreal Inj3() const { return m_Inj3; }
    qreal Inj4() const { return m_Inj4; }
    qreal Secinjpulse() const { return m_Secinjpulse; }
    qreal pwseq1() const { return m_pwseq1; }
    qreal pwseq2() const { return m_pwseq2; }
    qreal pwseq3() const { return m_pwseq3; }
    qreal pwseq4() const { return m_pwseq4; }

    // * Getters - Ignition
    qreal Ign() const { return m_Ign; }
    qreal Ign1() const { return m_Ign1; }
    qreal Ign2() const { return m_Ign2; }
    qreal Ign3() const { return m_Ign3; }
    qreal Ign4() const { return m_Ign4; }
    qreal Leadingign() const { return m_Leadingign; }
    qreal Trailingign() const { return m_Trailingign; }
    qreal Dwell() const { return m_Dwell; }
    qreal igncut() const { return m_igncut; }
    qreal totaligncomp() const { return m_totaligncomp; }

    // * Getters - Cam Angles
    qreal excamangle1() const { return m_excamangle1; }
    qreal excamangle2() const { return m_excamangle2; }
    qreal incamangle1() const { return m_incamangle1; }
    qreal incamangle2() const { return m_incamangle2; }

    // * Getters - Temperatures
    qreal Watertemp() const { return m_Watertemp; }
    qreal Intaketemp() const { return m_Intaketemp; }
    qreal airtempensor2() const { return m_airtempensor2; }
    qreal oiltemp() const { return m_oiltemp; }
    qreal transoiltemp() const { return m_transoiltemp; }
    qreal diffoiltemp() const { return m_diffoiltemp; }
    qreal coolantpress() const { return m_coolantpress; }
    qreal AUXT() const { return m_AUXT; }
    int AuxTemp1() const { return m_AuxTemp1; }

    // * Getters - Pressures
    qreal oilpres() const { return m_oilpres; }
    qreal Moilp() const { return m_Moilp; }
    qreal GearOilPress() const { return m_GearOilPress; }
    qreal brakepress() const { return m_brakepress; }

    // * Getters - O2/Lambda/AFR
    qreal O2volt() const { return m_O2volt; }
    qreal O2volt_2() const { return m_O2volt_2; }
    qreal LAMBDA() const { return m_LAMBDA; }
    qreal LAMBDATarget() const { return m_LAMBDATarget; }
    qreal lambda2() const { return m_lambda2; }
    qreal lambda3() const { return m_lambda3; }
    qreal lambda4() const { return m_lambda4; }
    qreal Lambdamultiply() const { return m_Lambdamultiply; }
    qreal AFR() const { return m_AFR; }
    qreal AFRLEFTBANKTARGET() const { return m_AFRLEFTBANKTARGET; }
    qreal AFRRIGHTBANKTARGET() const { return m_AFRRIGHTBANKTARGET; }
    qreal AFRLEFTBANKACTUAL() const { return m_AFRLEFTBANKACTUAL; }
    qreal AFRRIGHTBANKACTUAL() const { return m_AFRRIGHTBANKACTUAL; }
    qreal LEFTBANKO2CORR() const { return m_LEFTBANKO2CORR; }
    qreal RIGHTBANKO2CORR() const { return m_RIGHTBANKO2CORR; }
    qreal TRIM() const { return m_TRIM; }

    // * Getters - Per-Cylinder O2 Correction
    qreal Cyl1_O2_Corr() const { return m_Cyl1_O2_Corr; }
    qreal Cyl2_O2_Corr() const { return m_Cyl2_O2_Corr; }
    qreal Cyl3_O2_Corr() const { return m_Cyl3_O2_Corr; }
    qreal Cyl4_O2_Corr() const { return m_Cyl4_O2_Corr; }
    qreal Cyl5_O2_Corr() const { return m_Cyl5_O2_Corr; }
    qreal Cyl6_O2_Corr() const { return m_Cyl6_O2_Corr; }
    qreal Cyl7_O2_Corr() const { return m_Cyl7_O2_Corr; }
    qreal Cyl8_O2_Corr() const { return m_Cyl8_O2_Corr; }
    qreal EGOcor1() const { return m_EGOcor1; }
    qreal EGOcor2() const { return m_EGOcor2; }
    qreal EGOcor3() const { return m_EGOcor3; }
    qreal EGOcor4() const { return m_EGOcor4; }

    // * Getters - Per-Cylinder AFR
    qreal AFRcyl1() const { return m_AFRcyl1; }
    qreal AFRcyl2() const { return m_AFRcyl2; }
    qreal AFRcyl3() const { return m_AFRcyl3; }
    qreal AFRcyl4() const { return m_AFRcyl4; }
    qreal AFRcyl5() const { return m_AFRcyl5; }
    qreal AFRcyl6() const { return m_AFRcyl6; }
    qreal AFRcyl7() const { return m_AFRcyl7; }
    qreal AFRcyl8() const { return m_AFRcyl8; }

    // * Getters - Knock
    qreal Knock() const { return m_Knock; }
    qreal knocklevlogged1() const { return m_knocklevlogged1; }
    qreal knocklevlogged2() const { return m_knocklevlogged2; }
    qreal knockretardbank1() const { return m_knockretardbank1; }
    qreal knockretardbank2() const { return m_knockretardbank2; }
    qreal knockallpeak() const { return m_knockallpeak; }
    qreal knockcorr() const { return m_knockcorr; }
    qreal knocklastcyl() const { return m_knocklastcyl; }
    qreal Knock_cyl1() const { return m_Knock_cyl1; }
    qreal Knock_cyl2() const { return m_Knock_cyl2; }
    qreal Knock_cyl3() const { return m_Knock_cyl3; }
    qreal Knock_cyl4() const { return m_Knock_cyl4; }

    // * Getters - EGT
    qreal egt1() const { return m_egt1; }
    qreal egt2() const { return m_egt2; }
    qreal egt3() const { return m_egt3; }
    qreal egt4() const { return m_egt4; }
    qreal egt5() const { return m_egt5; }
    qreal egt6() const { return m_egt6; }
    qreal egt7() const { return m_egt7; }
    qreal egt8() const { return m_egt8; }
    qreal egt9() const { return m_egt9; }
    qreal egt10() const { return m_egt10; }
    qreal egt11() const { return m_egt11; }
    qreal egt12() const { return m_egt12; }
    qreal egthighest() const { return m_egthighest; }
    qreal egtdiff() const { return m_egtdiff; }

    // * Getters - Power/Torque
    qreal Power() const { return m_Power; }
    qreal Torque() const { return m_Torque; }

    // * Getters - Nitrous
    qreal nosactive() const { return m_nosactive; }
    qreal nospress() const { return m_nospress; }
    qreal nosswitch() const { return m_nosswitch; }
    qreal nitrous1_duty() const { return m_nitrous1_duty; }
    qreal nitrous2_duty() const { return m_nitrous2_duty; }
    qreal nitrous_timer_out() const { return m_nitrous_timer_out; }
    qreal n2o_addfuel() const { return m_n2o_addfuel; }
    qreal n2o_retard() const { return m_n2o_retard; }

    // * Getters - Launch/Antilag Control
    qreal antilaglauchswitch() const { return m_antilaglauchswitch; }
    qreal antilaglaunchon() const { return m_antilaglaunchon; }
    qreal auxrevlimitswitch() const { return m_auxrevlimitswitch; }
    qreal rallyantilagswitch() const { return m_rallyantilagswitch; }
    qreal launchcontolfuelenrich() const { return m_launchcontolfuelenrich; }
    qreal launchctrolignretard() const { return m_launchctrolignretard; }
    qreal flatshiftstate() const { return m_flatshiftstate; }

    // * Getters - Rev Limiters
    qreal REVLIM3STEP() const { return m_REVLIM3STEP; }
    qreal REVLIM2STEP() const { return m_REVLIM2STEP; }
    qreal REVLIMGIGHSIDE() const { return m_REVLIMGIGHSIDE; }
    qreal REVLIMBOURNOUT() const { return m_REVLIMBOURNOUT; }

    // * Getters - Traction Control
    qreal tractionControl() const { return m_tractionControl; }
    qreal TRACTIONCTRLOFFSET() const { return m_TRACTIONCTRLOFFSET; }
    qreal DRIVESHAFTOFFSET() const { return m_DRIVESHAFTOFFSET; }
    qreal TCCOMMAND() const { return m_TCCOMMAND; }
    qreal FSLCOMMAND() const { return m_FSLCOMMAND; }
    qreal FSLINDEX() const { return m_FSLINDEX; }
    qreal dsettargetslip() const { return m_dsettargetslip; }
    qreal tractionctlpowerlimit() const { return m_tractionctlpowerlimit; }

    // * Getters - ECU State
    qreal BatteryV() const { return m_BatteryV; }
    qreal battlight() const { return m_battlight; }
    qreal decelcut() const { return m_decelcut; }
    qreal limpmode() const { return m_limpmode; }
    qreal mil() const { return m_mil; }
    qreal missccount() const { return m_missccount; }
    qreal cputempecu() const { return m_cputempecu; }
    qreal errorcodecount() const { return m_errorcodecount; }
    qreal lostsynccount() const { return m_lostsynccount; }
    qreal activetunetable() const { return m_activetunetable; }
    qreal genericoutput1() const { return m_genericoutput1; }

    // * Getters - Torque Management
    qreal torqueredcutactive() const { return m_torqueredcutactive; }
    qreal torqueredlevelactive() const { return m_torqueredlevelactive; }
    qreal transientthroactive() const { return m_transientthroactive; }

    // * Getters - Timing/Triggers
    qreal triggerccounter() const { return m_triggerccounter; }
    qreal triggersrsinceasthome() const { return m_triggersrsinceasthome; }
    qreal homeccounter() const { return m_homeccounter; }
    qreal timeddutyout1() const { return m_timeddutyout1; }
    qreal timeddutyout2() const { return m_timeddutyout2; }
    qreal timeddutyoutputactive() const { return m_timeddutyoutputactive; }

    // * Getters - Misc
    qreal na1() const { return m_na1; }
    qreal na2() const { return m_na2; }
    qreal Cylinders() const { return m_Cylinders; }
    int oilpressurelamp() const { return m_oilpressurelamp; }
    int overtempalarm() const { return m_overtempalarm; }
    int alternatorfail() const { return m_alternatorfail; }

    // * Getters - Trimpots
    int RotaryTrimpot1() const { return m_RotaryTrimpot1; }
    int RotaryTrimpot2() const { return m_RotaryTrimpot2; }
    int RotaryTrimpot3() const { return m_RotaryTrimpot3; }
    int CalibrationSelect() const { return m_CalibrationSelect; }

public slots:
    // * Setters - Core Engine Metrics
    void setrpm(qreal rpm);
    void setIntakepress(qreal Intakepress);
    void setPressureV(qreal PressureV);
    void setThrottleV(qreal ThrottleV);
    void setPrimaryinp(qreal Primaryinp);
    void setEngLoad(qreal EngLoad);
    void setpim(qreal pim);
    void setTPS(qreal TPS);
    void setIdleValue(qreal IdleValue);
    void setIscvduty(qreal Iscvduty);

    // * Setters - Boost/Turbo
    void setBoosttp(qreal Boosttp);
    void setBoostwg(qreal Boostwg);
    void setBoostPres(qreal BoostPres);
    void setBoostPreskpa(qreal BoostPreskpa);
    void setBoostDuty(qreal BoostDuty);
    void setboostcontrol(qreal boostcontrol);
    void settargetbstlelkpa(qreal targetbstlelkpa);
    void setwastegatepress(qreal wastegatepress);
    void setturborpm(qreal turborpm);
    void setturborpm2(qreal turborpm2);
    void setBOOSTOFFSET(qreal BOOSTOFFSET);
    void setactiveboosttable(qreal activeboosttable);

    // * Setters - MAP/MAF
    void setMAP(qreal MAP);
    void setMAP2(qreal MAP2);
    void setMAF1V(qreal MAF1V);
    void setMAF2V(qreal MAF2V);
    void setMAFactivity(qreal MAFactivity);
    void setPANVAC(qreal PANVAC);

    // * Setters - Fuel System
    void setFuelc(qreal Fuelc);
    void setFueltemp(qreal Fueltemp);
    void setFuelPress(qreal FuelPress);
    void setfuelclevel(qreal fuelclevel);
    void setfuelcomposition(qreal fuelcomposition);
    void setfuelconsrate(qreal fuelconsrate);
    void setfuelcutperc(qreal fuelcutperc);
    void setfuelflow(qreal fuelflow);
    void setfuelflowdiff(qreal fuelflowdiff);
    void setfuelflowret(qreal fuelflowret);
    void setfueltrimlongtbank1(qreal fueltrimlongtbank1);
    void setfueltrimlongtbank2(qreal fueltrimlongtbank2);
    void setfueltrimshorttbank1(qreal fueltrimshorttbank1);
    void setfueltrimshorttbank2(qreal fueltrimshorttbank2);
    void settotalfueltrim(qreal totalfueltrim);
    void setavfueleconomy(qreal avfueleconomy);

    // * Setters - Injectors
    void setInjDuty(qreal InjDuty);
    void setInjDuty2(qreal InjDuty2);
    void setInjAngle(qreal InjAngle);
    void setinjms(qreal injms);
    void setInj(qreal Inj);
    void setInj1(qreal Inj1);
    void setInj2(qreal Inj2);
    void setInj3(qreal Inj3);
    void setInj4(qreal Inj4);
    void setSecinjpulse(qreal Secinjpulse);
    void setpwseq1(qreal pwseq1);
    void setpwseq2(qreal pwseq2);
    void setpwseq3(qreal pwseq3);
    void setpwseq4(qreal pwseq4);

    // * Setters - Ignition
    void setIgn(qreal Ign);
    void setIgn1(qreal Ign1);
    void setIgn2(qreal Ign2);
    void setIgn3(qreal Ign3);
    void setIgn4(qreal Ign4);
    void setLeadingign(qreal Leadingign);
    void setTrailingign(qreal Trailingign);
    void setDwell(qreal Dwell);
    void setigncut(qreal igncut);
    void settotaligncomp(qreal totaligncomp);

    // * Setters - Cam Angles
    void setexcamangle1(qreal excamangle1);
    void setexcamangle2(qreal excamangle2);
    void setincamangle1(qreal incamangle1);
    void setincamangle2(qreal incamangle2);

    // * Setters - Temperatures
    void setWatertemp(qreal Watertemp);
    void setIntaketemp(qreal Intaketemp);
    void setairtempensor2(qreal airtempensor2);
    void setoiltemp(qreal oiltemp);
    void settransoiltemp(qreal transoiltemp);
    void setdiffoiltemp(qreal diffoiltemp);
    void setcoolantpress(qreal coolantpress);
    void setAUXT(qreal AUXT);
    void setAuxTemp1(int AuxTemp1);

    // * Setters - Pressures
    void setoilpres(qreal oilpres);
    void setMoilp(qreal Moilp);
    void setGearOilPress(qreal GearOilPress);
    void setbrakepress(qreal brakepress);

    // * Setters - O2/Lambda/AFR
    void setO2volt(qreal O2volt);
    void setO2volt_2(qreal O2volt_2);
    void setLAMBDA(qreal LAMBDA);
    void setLAMBDATarget(qreal LAMBDATarget);
    void setlambda2(qreal lambda2);
    void setlambda3(qreal lambda3);
    void setlambda4(qreal lambda4);
    void setLambdamultiply(qreal Lambdamultiply);
    void setAFR(qreal AFR);
    void setAFRLEFTBANKTARGET(qreal AFRLEFTBANKTARGET);
    void setAFRRIGHTBANKTARGET(qreal AFRRIGHTBANKTARGET);
    void setAFRLEFTBANKACTUAL(qreal AFRLEFTBANKACTUAL);
    void setAFRRIGHTBANKACTUAL(qreal AFRRIGHTBANKACTUAL);
    void setLEFTBANKO2CORR(qreal LEFTBANKO2CORR);
    void setRIGHTBANKO2CORR(qreal RIGHTBANKO2CORR);
    void setTRIM(qreal TRIM);

    // * Setters - Per-Cylinder O2 Correction
    void setCyl1_O2_Corr(qreal Cyl1_O2_Corr);
    void setCyl2_O2_Corr(qreal Cyl2_O2_Corr);
    void setCyl3_O2_Corr(qreal Cyl3_O2_Corr);
    void setCyl4_O2_Corr(qreal Cyl4_O2_Corr);
    void setCyl5_O2_Corr(qreal Cyl5_O2_Corr);
    void setCyl6_O2_Corr(qreal Cyl6_O2_Corr);
    void setCyl7_O2_Corr(qreal Cyl7_O2_Corr);
    void setCyl8_O2_Corr(qreal Cyl8_O2_Corr);
    void setEGOcor1(qreal EGOcor1);
    void setEGOcor2(qreal EGOcor2);
    void setEGOcor3(qreal EGOcor3);
    void setEGOcor4(qreal EGOcor4);

    // * Setters - Per-Cylinder AFR
    void setAFRcyl1(qreal AFRcyl1);
    void setAFRcyl2(qreal AFRcyl2);
    void setAFRcyl3(qreal AFRcyl3);
    void setAFRcyl4(qreal AFRcyl4);
    void setAFRcyl5(qreal AFRcyl5);
    void setAFRcyl6(qreal AFRcyl6);
    void setAFRcyl7(qreal AFRcyl7);
    void setAFRcyl8(qreal AFRcyl8);

    // * Setters - Knock
    void setKnock(qreal Knock);
    void setknocklevlogged1(qreal knocklevlogged1);
    void setknocklevlogged2(qreal knocklevlogged2);
    void setknockretardbank1(qreal knockretardbank1);
    void setknockretardbank2(qreal knockretardbank2);
    void setknockallpeak(qreal knockallpeak);
    void setknockcorr(qreal knockcorr);
    void setknocklastcyl(qreal knocklastcyl);
    void setKnock_cyl1(qreal Knock_cyl1);
    void setKnock_cyl2(qreal Knock_cyl2);
    void setKnock_cyl3(qreal Knock_cyl3);
    void setKnock_cyl4(qreal Knock_cyl4);

    // * Setters - EGT
    void setegt1(qreal egt1);
    void setegt2(qreal egt2);
    void setegt3(qreal egt3);
    void setegt4(qreal egt4);
    void setegt5(qreal egt5);
    void setegt6(qreal egt6);
    void setegt7(qreal egt7);
    void setegt8(qreal egt8);
    void setegt9(qreal egt9);
    void setegt10(qreal egt10);
    void setegt11(qreal egt11);
    void setegt12(qreal egt12);
    void setegthighest(qreal egthighest);
    void setegtdiff(qreal egtdiff);

    // * Setters - Power/Torque
    void setPower(qreal Power);
    void setTorque(qreal Torque);

    // * Setters - Nitrous
    void setnosactive(qreal nosactive);
    void setnospress(qreal nospress);
    void setnosswitch(qreal nosswitch);
    void setnitrous1_duty(qreal nitrous1_duty);
    void setnitrous2_duty(qreal nitrous2_duty);
    void setnitrous_timer_out(qreal nitrous_timer_out);
    void setn2o_addfuel(qreal n2o_addfuel);
    void setn2o_retard(qreal n2o_retard);

    // * Setters - Launch/Antilag Control
    void setantilaglauchswitch(qreal antilaglauchswitch);
    void setantilaglaunchon(qreal antilaglaunchon);
    void setauxrevlimitswitch(qreal auxrevlimitswitch);
    void setrallyantilagswitch(qreal rallyantilagswitch);
    void setlaunchcontolfuelenrich(qreal launchcontolfuelenrich);
    void setlaunchctrolignretard(qreal launchctrolignretard);
    void setflatshiftstate(qreal flatshiftstate);

    // * Setters - Rev Limiters
    void setREVLIM3STEP(qreal REVLIM3STEP);
    void setREVLIM2STEP(qreal REVLIM2STEP);
    void setREVLIMGIGHSIDE(qreal REVLIMGIGHSIDE);
    void setREVLIMBOURNOUT(qreal REVLIMBOURNOUT);

    // * Setters - Traction Control
    void settractionControl(qreal tractionControl);
    void setTRACTIONCTRLOFFSET(qreal TRACTIONCTRLOFFSET);
    void setDRIVESHAFTOFFSET(qreal DRIVESHAFTOFFSET);
    void setTCCOMMAND(qreal TCCOMMAND);
    void setFSLCOMMAND(qreal FSLCOMMAND);
    void setFSLINDEX(qreal FSLINDEX);
    void setdsettargetslip(qreal dsettargetslip);
    void settractionctlpowerlimit(qreal tractionctlpowerlimit);

    // * Setters - ECU State
    void setBatteryV(qreal BatteryV);
    void setbattlight(qreal battlight);
    void setdecelcut(qreal decelcut);
    void setlimpmode(qreal limpmode);
    void setmil(qreal mil);
    void setmissccount(qreal missccount);
    void setcputempecu(qreal cputempecu);
    void seterrorcodecount(qreal errorcodecount);
    void setlostsynccount(qreal lostsynccount);
    void setactivetunetable(qreal activetunetable);
    void setgenericoutput1(qreal genericoutput1);

    // * Setters - Torque Management
    void settorqueredcutactive(qreal torqueredcutactive);
    void settorqueredlevelactive(qreal torqueredlevelactive);
    void settransientthroactive(qreal transientthroactive);

    // * Setters - Timing/Triggers
    void settriggerccounter(qreal triggerccounter);
    void settriggersrsinceasthome(qreal triggersrsinceasthome);
    void sethomeccounter(qreal homeccounter);
    void settimeddutyout1(qreal timeddutyout1);
    void settimeddutyout2(qreal timeddutyout2);
    void settimeddutyoutputactive(qreal timeddutyoutputactive);

    // * Setters - Misc
    void setna1(qreal na1);
    void setna2(qreal na2);
    void setCylinders(qreal Cylinders);
    void setoilpressurelamp(int oilpressurelamp);
    void setovertempalarm(int overtempalarm);
    void setalternatorfail(int alternatorfail);

    // * Setters - Trimpots
    void setRotaryTrimpot1(int RotaryTrimpot1);
    void setRotaryTrimpot2(int RotaryTrimpot2);
    void setRotaryTrimpot3(int RotaryTrimpot3);
    void setCalibrationSelect(int CalibrationSelect);

signals:
    // * Signals - Core Engine Metrics
    void rpmChanged(qreal rpm);
    void intakepressChanged(qreal Intakepress);
    void pressureVChanged(qreal PressureV);
    void throttleVChanged(qreal ThrottleV);
    void primaryinpChanged(qreal Primaryinp);
    void engLoadChanged(qreal EngLoad);
    void pimChanged(qreal pim);
    void tPSChanged(qreal TPS);
    void idleValueChanged(qreal IdleValue);
    void iscvdutyChanged(qreal Iscvduty);

    // * Signals - Boost/Turbo
    void boosttpChanged(qreal Boosttp);
    void boostwgChanged(qreal Boostwg);
    void BoostPresChanged(qreal BoostPres);
    void BoostPreskpaChanged(qreal BoostPreskpa);
    void boostDutyChanged(qreal BoostDuty);
    void boostcontrolChanged(qreal boostcontrol);
    void targetbstlelkpaChanged(qreal targetbstlelkpa);
    void wastegatepressChanged(qreal wastegatepress);
    void turborpmChanged(qreal turborpm);
    void turborpm2Changed(qreal turborpm2);
    void BOOSTOFFSETChanged(qreal BOOSTOFFSET);
    void activeboosttableChanged(qreal activeboosttable);

    // * Signals - MAP/MAF
    void mAPChanged(qreal MAP);
    void mAP2Changed(qreal MAP2);
    void mAF1VChanged(qreal MAF1V);
    void mAF2VChanged(qreal MAF2V);
    void mAFactivityChanged(qreal MAFactivity);
    void PANVACChanged(qreal PANVAC);

    // * Signals - Fuel System
    void fuelcChanged(qreal Fuelc);
    void fueltempChanged(qreal Fueltemp);
    void fuelPressChanged(qreal FuelPress);
    void fuelclevelChanged(qreal fuelclevel);
    void fuelcompositionChanged(qreal fuelcomposition);
    void fuelconsrateChanged(qreal fuelconsrate);
    void fuelcutpercChanged(qreal fuelcutperc);
    void fuelflowChanged(qreal fuelflow);
    void fuelflowdiffChanged(qreal fuelflowdiff);
    void fuelflowretChanged(qreal fuelflowret);
    void fueltrimlongtbank1Changed(qreal fueltrimlongtbank1);
    void fueltrimlongtbank2Changed(qreal fueltrimlongtbank2);
    void fueltrimshorttbank1Changed(qreal fueltrimshorttbank1);
    void fueltrimshorttbank2Changed(qreal fueltrimshorttbank2);
    void totalfueltrimChanged(qreal totalfueltrim);
    void avfueleconomyChanged(qreal avfueleconomy);

    // * Signals - Injectors
    void injDutyChanged(qreal InjDuty);
    void injDuty2Changed(qreal InjDuty2);
    void InjAngleChanged(qreal InjAngle);
    void injmsChanged(qreal injms);
    void injChanged(qreal Inj);
    void inj1Changed(qreal Inj1);
    void inj2Changed(qreal Inj2);
    void inj3Changed(qreal Inj3);
    void inj4Changed(qreal Inj4);
    void secinjpulseChanged(qreal Secinjpulse);
    void pwseq1Changed(qreal pwseq1);
    void pwseq2Changed(qreal pwseq2);
    void pwseq3Changed(qreal pwseq3);
    void pwseq4Changed(qreal pwseq4);

    // * Signals - Ignition
    void ignChanged(qreal Ign);
    void ign1Changed(qreal Ign1);
    void ign2Changed(qreal Ign2);
    void ign3Changed(qreal Ign3);
    void ign4Changed(qreal Ign4);
    void leadingignChanged(qreal Leadingign);
    void trailingignChanged(qreal Trailingign);
    void dwellChanged(qreal Dwell);
    void igncutChanged(qreal igncut);
    void totaligncompChanged(qreal totaligncomp);

    // * Signals - Cam Angles
    void excamangle1Changed(qreal excamangle1);
    void excamangle2Changed(qreal excamangle2);
    void incamangle1Changed(qreal incamangle1);
    void incamangle2Changed(qreal incamangle2);

    // * Signals - Temperatures
    void watertempChanged(qreal Watertemp);
    void intaketempChanged(qreal Intaketemp);
    void airtempensor2Changed(qreal airtempensor2);
    void oiltempChanged(qreal oiltemp);
    void transoiltempChanged(qreal transoiltemp);
    void diffoiltempChanged(qreal diffoiltemp);
    void coolantpressChanged(qreal coolantpress);
    void aUXTChanged(qreal AUXT);
    void AuxTemp1Changed(int AuxTemp1);

    // * Signals - Pressures
    void oilpresChanged(qreal oilpres);
    void moilpChanged(qreal Moilp);
    void GearOilPressChanged(qreal GearOilPress);
    void brakepressChanged(qreal brakepress);

    // * Signals - O2/Lambda/AFR
    void o2voltChanged(qreal O2volt);
    void o2volt_2Changed(qreal O2volt_2);
    void lAMBDAChanged(qreal LAMBDA);
    void lAMBDATargetChanged(qreal LAMBDATarget);
    void lambda2Changed(qreal lambda2);
    void lambda3Changed(qreal lambda3);
    void lambda4Changed(qreal lambda4);
    void LambdamultiplyChanged(qreal Lambdamultiply);
    void aFRChanged(qreal AFR);
    void AFRLEFTBANKTARGETChanged(qreal AFRLEFTBANKTARGET);
    void AFRRIGHTBANKTARGETChanged(qreal AFRRIGHTBANKTARGET);
    void AFRLEFTBANKACTUALChanged(qreal AFRLEFTBANKACTUAL);
    void AFRRIGHTBANKACTUALChanged(qreal AFRRIGHTBANKACTUAL);
    void LEFTBANKO2CORRChanged(qreal LEFTBANKO2CORR);
    void RIGHTBANKO2CORRChanged(qreal RIGHTBANKO2CORR);
    void tRIMChanged(qreal TRIM);

    // * Signals - Per-Cylinder O2 Correction
    void Cyl1_O2_CorrChanged(qreal Cyl1_O2_Corr);
    void Cyl2_O2_CorrChanged(qreal Cyl2_O2_Corr);
    void Cyl3_O2_CorrChanged(qreal Cyl3_O2_Corr);
    void Cyl4_O2_CorrChanged(qreal Cyl4_O2_Corr);
    void Cyl5_O2_CorrChanged(qreal Cyl5_O2_Corr);
    void Cyl6_O2_CorrChanged(qreal Cyl6_O2_Corr);
    void Cyl7_O2_CorrChanged(qreal Cyl7_O2_Corr);
    void Cyl8_O2_CorrChanged(qreal Cyl8_O2_Corr);
    void EGOcor1Changed(qreal EGOcor1);
    void EGOcor2Changed(qreal EGOcor2);
    void EGOcor3Changed(qreal EGOcor3);
    void EGOcor4Changed(qreal EGOcor4);

    // * Signals - Per-Cylinder AFR
    void AFRcyl1Changed(qreal AFRcyl1);
    void AFRcyl2Changed(qreal AFRcyl2);
    void AFRcyl3Changed(qreal AFRcyl3);
    void AFRcyl4Changed(qreal AFRcyl4);
    void AFRcyl5Changed(qreal AFRcyl5);
    void AFRcyl6Changed(qreal AFRcyl6);
    void AFRcyl7Changed(qreal AFRcyl7);
    void AFRcyl8Changed(qreal AFRcyl8);

    // * Signals - Knock
    void knockChanged(qreal Knock);
    void knocklevlogged1Changed(qreal knocklevlogged1);
    void knocklevlogged2Changed(qreal knocklevlogged2);
    void knockretardbank1Changed(qreal knockretardbank1);
    void knockretardbank2Changed(qreal knockretardbank2);
    void knockallpeakChanged(qreal knockallpeak);
    void knockcorrChanged(qreal knockcorr);
    void knocklastcylChanged(qreal knocklastcyl);
    void Knock_cyl1Changed(qreal Knock_cyl1);
    void Knock_cyl2Changed(qreal Knock_cyl2);
    void Knock_cyl3Changed(qreal Knock_cyl3);
    void Knock_cyl4Changed(qreal Knock_cyl4);

    // * Signals - EGT
    void egt1Changed(qreal egt1);
    void egt2Changed(qreal egt2);
    void egt3Changed(qreal egt3);
    void egt4Changed(qreal egt4);
    void egt5Changed(qreal egt5);
    void egt6Changed(qreal egt6);
    void egt7Changed(qreal egt7);
    void egt8Changed(qreal egt8);
    void egt9Changed(qreal egt9);
    void egt10Changed(qreal egt10);
    void egt11Changed(qreal egt11);
    void egt12Changed(qreal egt12);
    void egthighestChanged(qreal egthighest);
    void egtdiffChanged(qreal egtdiff);

    // * Signals - Power/Torque
    void powerChanged(qreal Power);
    void torqueChanged(qreal Torque);

    // * Signals - Nitrous
    void nosactiveChanged(qreal nosactive);
    void nospressChanged(qreal nospress);
    void nosswitchChanged(qreal nosswitch);
    void nitrous1_dutyChanged(qreal nitrous1_duty);
    void nitrous2_dutyChanged(qreal nitrous2_duty);
    void nitrous_timer_outChanged(qreal nitrous_timer_out);
    void n2o_addfuelChanged(qreal n2o_addfuel);
    void n2o_retardChanged(qreal n2o_retard);

    // * Signals - Launch/Antilag Control
    void antilaglauchswitchChanged(qreal antilaglauchswitch);
    void antilaglaunchonChanged(qreal antilaglaunchon);
    void auxrevlimitswitchChanged(qreal auxrevlimitswitch);
    void rallyantilagswitchChanged(qreal rallyantilagswitch);
    void launchcontolfuelenrichChanged(qreal launchcontolfuelenrich);
    void launchctrolignretardChanged(qreal launchctrolignretard);
    void flatshiftstateChanged(qreal flatshiftstate);

    // * Signals - Rev Limiters
    void REVLIM3STEPChanged(qreal REVLIM3STEP);
    void REVLIM2STEPChanged(qreal REVLIM2STEP);
    void REVLIMGIGHSIDEChanged(qreal REVLIMGIGHSIDE);
    void REVLIMBOURNOUTChanged(qreal REVLIMBOURNOUT);

    // * Signals - Traction Control
    void tractionControlChanged(qreal tractionControl);
    void TRACTIONCTRLOFFSETChanged(qreal TRACTIONCTRLOFFSET);
    void DRIVESHAFTOFFSETChanged(qreal DRIVESHAFTOFFSET);
    void TCCOMMANDChanged(qreal TCCOMMAND);
    void FSLCOMMANDChanged(qreal FSLCOMMAND);
    void FSLINDEXChanged(qreal FSLINDEX);
    void dsettargetslipChanged(qreal dsettargetslip);
    void tractionctlpowerlimitChanged(qreal tractionctlpowerlimit);

    // * Signals - ECU State
    void batteryVChanged(qreal BatteryV);
    void battlightChanged(qreal battlight);
    void decelcutChanged(qreal decelcut);
    void limpmodeChanged(qreal limpmode);
    void milChanged(qreal mil);
    void missccountChanged(qreal missccount);
    void cputempecuChanged(qreal cputempecu);
    void errorcodecountChanged(qreal errorcodecount);
    void lostsynccountChanged(qreal lostsynccount);
    void activetunetableChanged(qreal activetunetable);
    void genericoutput1Changed(qreal genericoutput1);

    // * Signals - Torque Management
    void torqueredcutactiveChanged(qreal torqueredcutactive);
    void torqueredlevelactiveChanged(qreal torqueredlevelactive);
    void transientthroactiveChanged(qreal transientthroactive);

    // * Signals - Timing/Triggers
    void triggerccounterChanged(qreal triggerccounter);
    void triggersrsinceasthomeChanged(qreal triggersrsinceasthome);
    void homeccounterChanged(qreal homeccounter);
    void timeddutyout1Changed(qreal timeddutyout1);
    void timeddutyout2Changed(qreal timeddutyout2);
    void timeddutyoutputactiveChanged(qreal timeddutyoutputactive);

    // * Signals - Misc
    void na1Changed(qreal na1);
    void na2Changed(qreal na2);
    void CylindersChanged(qreal Cylinders);
    void oilpressurelampChanged(int oilpressurelamp);
    void overtempalarmChanged(int overtempalarm);
    void alternatorfailChanged(int alternatorfail);

    // * Signals - Trimpots
    void RotaryTrimpot1Changed(int RotaryTrimpot1);
    void RotaryTrimpot2Changed(int RotaryTrimpot2);
    void RotaryTrimpot3Changed(int RotaryTrimpot3);
    void CalibrationSelectChanged(int CalibrationSelect);

private:
    // * Core Engine Metrics
    qreal m_rpm = 0;
    qreal m_Intakepress = 0;
    qreal m_PressureV = 0;
    qreal m_ThrottleV = 0;
    qreal m_Primaryinp = 0;
    qreal m_EngLoad = 0;
    qreal m_pim = 0;
    qreal m_TPS = 0;
    qreal m_IdleValue = 0;
    qreal m_Iscvduty = 0;

    // * Boost/Turbo
    qreal m_Boosttp = 0;
    qreal m_Boostwg = 0;
    qreal m_BoostPres = 0;
    qreal m_BoostPreskpa = 0;
    qreal m_BoostDuty = 0;
    qreal m_boostcontrol = 0;
    qreal m_targetbstlelkpa = 0;
    qreal m_wastegatepress = 0;
    qreal m_turborpm = 0;
    qreal m_turborpm2 = 0;
    qreal m_BOOSTOFFSET = 0;
    qreal m_activeboosttable = 0;

    // * MAP/MAF
    qreal m_MAP = 0;
    qreal m_MAP2 = 0;
    qreal m_MAF1V = 0;
    qreal m_MAF2V = 0;
    qreal m_MAFactivity = 0;
    qreal m_PANVAC = 0;

    // * Fuel System
    qreal m_Fuelc = 0;
    qreal m_Fueltemp = 0;
    qreal m_FuelPress = 0;
    qreal m_fuelclevel = 0;
    qreal m_fuelcomposition = 0;
    qreal m_fuelconsrate = 0;
    qreal m_fuelcutperc = 0;
    qreal m_fuelflow = 0;
    qreal m_fuelflowdiff = 0;
    qreal m_fuelflowret = 0;
    qreal m_fueltrimlongtbank1 = 0;
    qreal m_fueltrimlongtbank2 = 0;
    qreal m_fueltrimshorttbank1 = 0;
    qreal m_fueltrimshorttbank2 = 0;
    qreal m_totalfueltrim = 0;
    qreal m_avfueleconomy = 0;

    // * Injectors
    qreal m_InjDuty = 0;
    qreal m_InjDuty2 = 0;
    qreal m_InjAngle = 0;
    qreal m_injms = 0;
    qreal m_Inj = 0;
    qreal m_Inj1 = 0;
    qreal m_Inj2 = 0;
    qreal m_Inj3 = 0;
    qreal m_Inj4 = 0;
    qreal m_Secinjpulse = 0;
    qreal m_pwseq1 = 0;
    qreal m_pwseq2 = 0;
    qreal m_pwseq3 = 0;
    qreal m_pwseq4 = 0;

    // * Ignition
    qreal m_Ign = 0;
    qreal m_Ign1 = 0;
    qreal m_Ign2 = 0;
    qreal m_Ign3 = 0;
    qreal m_Ign4 = 0;
    qreal m_Leadingign = 0;
    qreal m_Trailingign = 0;
    qreal m_Dwell = 0;
    qreal m_igncut = 0;
    qreal m_totaligncomp = 0;

    // * Cam Angles
    qreal m_excamangle1 = 0;
    qreal m_excamangle2 = 0;
    qreal m_incamangle1 = 0;
    qreal m_incamangle2 = 0;

    // * Temperatures
    qreal m_Watertemp = 0;
    qreal m_Intaketemp = 0;
    qreal m_airtempensor2 = 0;
    qreal m_oiltemp = 0;
    qreal m_transoiltemp = 0;
    qreal m_diffoiltemp = 0;
    qreal m_coolantpress = 0;
    qreal m_AUXT = 0;
    int m_AuxTemp1 = 0;

    // * Pressures
    qreal m_oilpres = 0;
    qreal m_Moilp = 0;
    qreal m_GearOilPress = 0;
    qreal m_brakepress = 0;

    // * O2/Lambda/AFR
    qreal m_O2volt = 0;
    qreal m_O2volt_2 = 0;
    qreal m_LAMBDA = 0;
    qreal m_LAMBDATarget = 0;
    qreal m_lambda2 = 0;
    qreal m_lambda3 = 0;
    qreal m_lambda4 = 0;
    qreal m_Lambdamultiply = 0;
    qreal m_AFR = 0;
    qreal m_AFRLEFTBANKTARGET = 0;
    qreal m_AFRRIGHTBANKTARGET = 0;
    qreal m_AFRLEFTBANKACTUAL = 0;
    qreal m_AFRRIGHTBANKACTUAL = 0;
    qreal m_LEFTBANKO2CORR = 0;
    qreal m_RIGHTBANKO2CORR = 0;
    qreal m_TRIM = 0;

    // * Per-Cylinder O2 Correction
    qreal m_Cyl1_O2_Corr = 0;
    qreal m_Cyl2_O2_Corr = 0;
    qreal m_Cyl3_O2_Corr = 0;
    qreal m_Cyl4_O2_Corr = 0;
    qreal m_Cyl5_O2_Corr = 0;
    qreal m_Cyl6_O2_Corr = 0;
    qreal m_Cyl7_O2_Corr = 0;
    qreal m_Cyl8_O2_Corr = 0;
    qreal m_EGOcor1 = 0;
    qreal m_EGOcor2 = 0;
    qreal m_EGOcor3 = 0;
    qreal m_EGOcor4 = 0;

    // * Per-Cylinder AFR
    qreal m_AFRcyl1 = 0;
    qreal m_AFRcyl2 = 0;
    qreal m_AFRcyl3 = 0;
    qreal m_AFRcyl4 = 0;
    qreal m_AFRcyl5 = 0;
    qreal m_AFRcyl6 = 0;
    qreal m_AFRcyl7 = 0;
    qreal m_AFRcyl8 = 0;

    // * Knock
    qreal m_Knock = 0;
    qreal m_knocklevlogged1 = 0;
    qreal m_knocklevlogged2 = 0;
    qreal m_knockretardbank1 = 0;
    qreal m_knockretardbank2 = 0;
    qreal m_knockallpeak = 0;
    qreal m_knockcorr = 0;
    qreal m_knocklastcyl = 0;
    qreal m_Knock_cyl1 = 0;
    qreal m_Knock_cyl2 = 0;
    qreal m_Knock_cyl3 = 0;
    qreal m_Knock_cyl4 = 0;

    // * EGT
    qreal m_egt1 = 0;
    qreal m_egt2 = 0;
    qreal m_egt3 = 0;
    qreal m_egt4 = 0;
    qreal m_egt5 = 0;
    qreal m_egt6 = 0;
    qreal m_egt7 = 0;
    qreal m_egt8 = 0;
    qreal m_egt9 = 0;
    qreal m_egt10 = 0;
    qreal m_egt11 = 0;
    qreal m_egt12 = 0;
    qreal m_egthighest = 0;
    qreal m_egtdiff = 0;

    // * Power/Torque
    qreal m_Power = 0;
    qreal m_Torque = 0;

    // * Nitrous
    qreal m_nosactive = 0;
    qreal m_nospress = 0;
    qreal m_nosswitch = 0;
    qreal m_nitrous1_duty = 0;
    qreal m_nitrous2_duty = 0;
    qreal m_nitrous_timer_out = 0;
    qreal m_n2o_addfuel = 0;
    qreal m_n2o_retard = 0;

    // * Launch/Antilag Control
    qreal m_antilaglauchswitch = 0;
    qreal m_antilaglaunchon = 0;
    qreal m_auxrevlimitswitch = 0;
    qreal m_rallyantilagswitch = 0;
    qreal m_launchcontolfuelenrich = 0;
    qreal m_launchctrolignretard = 0;
    qreal m_flatshiftstate = 0;

    // * Rev Limiters
    qreal m_REVLIM3STEP = 0;
    qreal m_REVLIM2STEP = 0;
    qreal m_REVLIMGIGHSIDE = 0;
    qreal m_REVLIMBOURNOUT = 0;

    // * Traction Control
    qreal m_tractionControl = 0;
    qreal m_TRACTIONCTRLOFFSET = 0;
    qreal m_DRIVESHAFTOFFSET = 0;
    qreal m_TCCOMMAND = 0;
    qreal m_FSLCOMMAND = 0;
    qreal m_FSLINDEX = 0;
    qreal m_dsettargetslip = 0;
    qreal m_tractionctlpowerlimit = 0;

    // * ECU State
    qreal m_BatteryV = 0;
    qreal m_battlight = 0;
    qreal m_decelcut = 0;
    qreal m_limpmode = 0;
    qreal m_mil = 0;
    qreal m_missccount = 0;
    qreal m_cputempecu = 0;
    qreal m_errorcodecount = 0;
    qreal m_lostsynccount = 0;
    qreal m_activetunetable = 0;
    qreal m_genericoutput1 = 0;

    // * Torque Management
    qreal m_torqueredcutactive = 0;
    qreal m_torqueredlevelactive = 0;
    qreal m_transientthroactive = 0;

    // * Timing/Triggers
    qreal m_triggerccounter = 0;
    qreal m_triggersrsinceasthome = 0;
    qreal m_homeccounter = 0;
    qreal m_timeddutyout1 = 0;
    qreal m_timeddutyout2 = 0;
    qreal m_timeddutyoutputactive = 0;

    // * Misc
    qreal m_na1 = 0;
    qreal m_na2 = 0;
    qreal m_Cylinders = 0;
    int m_oilpressurelamp = 0;
    int m_overtempalarm = 0;
    int m_alternatorfail = 0;

    // * Trimpots
    int m_RotaryTrimpot1 = 0;
    int m_RotaryTrimpot2 = 0;
    int m_RotaryTrimpot3 = 0;
    int m_CalibrationSelect = 0;
};

#endif  // ENGINEDATA_H
