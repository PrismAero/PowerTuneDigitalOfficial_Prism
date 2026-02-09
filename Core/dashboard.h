#ifndef DASHBOARD_H
#define DASHBOARD_H

#include <QObject>
#include <QStringList>

// * Forward declarations for Phase 4/5 modularization
class UIState;
class SteinhartCalculator;
class SignalSmoother;

class DashBoard : public QObject
{
    Q_OBJECT

    // Odometer (Odo moved to VehicleData)
    // Tripmeter (Trip moved to VehicleData)
    // Advanced Info
    // speed moved to VehicleData

    // Sensor Voltage (sens1-8, auxcalc1-4 moved to SensorData/AnalogInputs models)

    // Platform, SerialStat, RecvData, TimeoutStat, RunStat, WifiStat, EthernetStat moved to ConnectionData

    Q_PROPERTY(QString CBXCountrysave READ CBXCountrysave WRITE setCBXCountrysave NOTIFY CBXCountrysaveChanged)
    Q_PROPERTY(QString CBXTracksave READ CBXTracksave WRITE setCBXTracksave NOTIFY CBXTracksaveChanged)

    // Adaptronic extra - moved to EngineData

    // MVSS/SVSS moved to VehicleData

    // Units moved to SettingsData
    // Qsensors (accelx/y/z, gyrox/y/z, compass, ambitemp, ambipress moved to VehicleData)

    // Calculations (Gear, GearCalculation, AccelTimer, Weight moved to VehicleData)
    Q_PROPERTY(qreal Gearoffset READ Gearoffset WRITE setGearoffset NOTIFY GearoffsetChanged)

    // screen, maindashsetup, dashsetup1-3, dashfiles, backroundpictures moved to UIState

    // accelpedpos moved to VehicleData
    // antilaglauchswitch, auxrevlimitswitch moved to EngineData
    // clutchswitchstate moved to VehicleData
    // distancetoempty moved to VehicleData
    // fueltrimlongtbank1, fueltrimlongtbank2 moved to EngineData
    // gearswitch, handbrake, highbeam, lowBeam moved to VehicleData
    // leftindicator moved to VehicleData
    // rallyantilagswitch moved to EngineData
    // rightindicator moved to VehicleData
    // torqueredcutactive moved to EngineData
    // wheeldiff, wheelslip, wheelspdftleft, wheelspdftright, wheelspdrearleft, wheelspdrearright moved to VehicleData
    // musicpath, supportedReg moved to ConnectionData
    // speedpercent, pulsespermile moved to VehicleData

    // maxRPM, rpmStage1-4, waterwarn, rpmwarn, knockwarn, boostwarn, smoothrpm, smoothspeed moved to SettingsData
    Q_PROPERTY(int smootexAnalogInput7 READ smootexAnalogInput7 WRITE setsmootexAnalogInput7 NOTIFY smootexAnalogInput7Changed)

    // gearcalc1-6, gearcalcactivation moved to SettingsData

    // ecu moved to ConnectionData

    // rpmstyle1, rpmstyle2, rpmstyle3 moved to UIState

    // Error moved to ConnectionData
    // autogear moved to VehicleData

    // ExternalSpeed moved to SettingsData
    Q_PROPERTY(QString daemonlicense READ daemonlicense WRITE setdaemonlicense NOTIFY daemonlicenseChanged)
    Q_PROPERTY(QString holleyproductid READ holleyproductid WRITE setholleyproductid NOTIFY holleyproductidChanged)

    // draggable moved to UIState
    // wifi, can moved to ConnectionData

    // Analog0-10, AnalogCalc0-10, EXAnalogCalc0-7, Userchannel1-12 moved to AnalogInputs/ExpanderBoardData models

    // nitrous_timer_out moved to EngineData

    // FuelLevel moved to VehicleData
    // SteeringWheelAngle moved to VehicleData
    // Brightness, Visibledashes moved to UIState

    // IGBT temps, RTD temps, EMotor properties, DigInput switches, Phase currents, DC bus, Output voltage moved to ElectricMotorData

    // TirepresLF/RF/LR/RR, TiretempLF/RF/LR/RR moved to VehicleData

    // DigitalInput1-7, EXDigitalInput1-8, EXAnalogInput0-7 moved to DigitalInputs/ExpanderBoardData models
    // frequencyDIEX1, RPMFrequencyDividerDi1, DI1RPMEnabled moved to DigitalInputs model
    // Externalrpm, language moved to SettingsData
    // externalspeedconnectionrequest, externalspeedport moved to ConnectionData

    // Q_PROPERTY(int Seconds_ECU_ON READ Seconds_ECU_ON WRITE setSeconds_ECU_ON NOTIFY Seconds_ECU_ONChanged FINAL)

public:
    DashBoard(QObject *parent = nullptr);

    /**
     * @brief Set UIState model for facade forwarding (Phase 4)
     * @param uiState Pointer to UIState model instance
     *
     * This enables backward compatibility by forwarding UI-related properties
     * (draggable, Brightness, Visibledashes, screen, rpmstyle1-3) to the
     * dedicated UIState model. QML code using Dashboard.draggable will
     * continue to work while new code can use UI.draggable directly.
     */
    void setUIState(UIState *uiState);

    // Steinhart Hart
    long R01 = 2000;
    long R02 = 4000;
    long R03 = 7000;
    long double T01 = 5;
    long double T02 = 25;
    long double T03 = 45;

    long double A0;
    long double B0;
    long double C0;

    long R11 = 2000;
    long R12 = 4000;
    long R13 = 7000;
    long double T11 = 5;
    long double T12 = 25;
    long double T13 = 45;

    long double A1;
    long double B1;
    long double C1;

    long R21 = 2000;
    long R22 = 4000;
    long R23 = 7000;
    long double T21 = 5;
    long double T22 = 25;
    long double T23 = 45;

    long double A2;
    long double B2;
    long double C2;

    long R31 = 2000;
    long R32 = 4000;
    long R33 = 7000;
    long double T31 = 5;
    long double T32 = 25;
    long double T33 = 45;

    long double A3;
    long double B3;
    long double C3;

    long R41 = 2000;
    long R42 = 4000;
    long R43 = 7000;
    long double T41 = 5;
    long double T42 = 25;
    long double T43 = 45;

    long double A4;
    long double B4;
    long double C4;

    long R51 = 2000;
    long R52 = 4000;
    long R53 = 7000;
    long double T51 = 5;
    long double T52 = 25;
    long double T53 = 45;

    long double A5;
    long double B5;
    long double C5;
    // Odometer (setOdo moved to VehicleData)
    // Tripmeter (setTrip moved to VehicleData)
    Q_INVOKABLE void setAnalogVal(const qreal &A00, const qreal &A05, const qreal &A10, const qreal &A15,
                                  const qreal &A20, const qreal &A25, const qreal &A30, const qreal &A35,
                                  const qreal &A40, const qreal &A45, const qreal &A50, const qreal &A55,
                                  const qreal &A60, const qreal &A65, const qreal &A70, const qreal &A75,
                                  const qreal &A80, const qreal &A85, const qreal &A90, const qreal &A95,
                                  const qreal &A100, const qreal &A105);
    Q_INVOKABLE void setEXAnalogVal(const qreal &EXA00, const qreal &EXA05, const qreal &EXA10, const qreal &EXA15,
                                    const qreal &EXA20, const qreal &EXA25, const qreal &EXA30, const qreal &EXA35,
                                    const qreal &EXA40, const qreal &EXA45, const qreal &EXA50, const qreal &EXA55,
                                    const qreal &EXA60, const qreal &EXA65, const qreal &EXA70, const qreal &EXA75,
                                    const int &steinhartcalc0on, const int &steinhartcalc1on,
                                    const int &steinhartcalc2on, const int &steinhartcalc3on,
                                    const int &steinhartcalc4on, const int &steinhartcalc5on, const int &AN0R3VAL,
                                    const int &AN0R4VAL, const int &AN1R3VAL, const int &AN1R4VAL, const int &AN2R3VAL,
                                    const int &AN2R4VAL, const int &AN3R3VAL, const int &AN3R4VAL, const int &AN4R3VAL,
                                    const int &AN4R4VAL, const int &AN5R3VAL, const int &AN5R4VAL);
    Q_INVOKABLE void setSteinhartcalc(const qreal &T01, const qreal &T02, const qreal &T03, const qreal &R01,
                                      const qreal &R02, const qreal &R03, const qreal &T11, const qreal &T12,
                                      const qreal &T13, const qreal &R11, const qreal &R12, const qreal &R13,
                                      const qreal &T21, const qreal &T22, const qreal &T23, const qreal &R21,
                                      const qreal &R22, const qreal &R23, const qreal &T31, const qreal &T32,
                                      const qreal &T33, const qreal &R31, const qreal &R32, const qreal &R33,
                                      const qreal &T41, const qreal &T42, const qreal &T43, const qreal &R41,
                                      const qreal &R42, const qreal &R43, const qreal &T51, const qreal &T52,
                                      const qreal &T53, const qreal &R51, const qreal &R52, const qreal &R53);

    // Advanced Info
    // setSerialSpeed moved to ConnectionData
    // setSpeed moved to VehicleData

    // Boost

    // Aux Differential inputs (setauxcalc1-4 moved to AnalogInputs model)
    // Sensor Info (setsens1-8 moved to SensorData/AnalogInputs models)

    // Platform, SerialStat, RecvData, TimeoutStat, RunStat, WifiStat, EthernetStat setters moved to ConnectionData

    void setCBXCountrysave(const QString &CBXCountrysave);
    void setCBXTracksave(const QString &CBXTracksave);

    // Units setters moved to SettingsData

    // Adaptronic extra

    // setMVSS, setSVSS moved to VehicleData

    // qsensors (setaccelx/y/z, setgyrox/y/z, setcompass, setambitemp, setambipress moved to VehicleData)

    // calculations (setGear, setGearCalculation, setAccelTimer, setWeight moved to VehicleData)
    void setGearoffset(const qreal &Gearoffset);

    // setscreen, setmaindashsetup, setdashsetup1-3, setdashfiles, setbackroundpictures moved to UIState

    // setaccelpedpos moved to VehicleData
    // setclutchswitchstate moved to VehicleData
    // setdistancetoempty moved to VehicleData
    // setgearswitch, sethandbrake, sethighbeam, setlowBeam moved to VehicleData

    // setleftindicator moved to VehicleData
    // setrightindicator moved to VehicleData
    // setwheeldiff, setwheelslip, setwheelspdftleft, setwheelspdftright, setwheelspdrearleft, setwheelspdrearright moved to VehicleData
    // setmusicpath, setsupportedReg, setecu moved to ConnectionData

    // setrpmstyle1, setrpmstyle2, setrpmstyle3 moved to UIState

    // setError moved to ConnectionData
    // setautogear moved to VehicleData
    void setdaemonlicense(const QString &daemonlicense);
    void setholleyproductid(const QString &holleyproductid);

    // setExternalSpeed, setmaxRPM, setrpmStage1-4, setwaterwarn, setrpmwarn, setknockwarn, setboostwarn, setsmoothrpm, setsmoothspeed moved to SettingsData
    Q_INVOKABLE void setsmootexAnalogInput7(const int &smootexAnalogInput7);

    // setgearcalc1-6, setgearcalcactivation moved to SettingsData

    // setdraggable moved to UIState
    // setwifi, setcan moved to ConnectionData

    // setAnalog0-10, setAnalogCalc0-10, setEXAnalogCalc0-7, setUserchannel1-12 moved to AnalogInputs/ExpanderBoardData models

    // setFuelLevel, setSteeringWheelAngle moved to VehicleData
    // setBrightness, setVisibledashes moved to UIState

    // setIGBT*, setRtdTemp*, setEMotor*, setTorqueShudder, setDigInput*, setElectricalOutFreq, setDeltaResolverFiltered,
    // setPhase*Current, setDCBus*, setOutputVoltage, setVABvdVoltage, setVBCvqVoltage moved to ElectricMotorData

    // setTirepresLF/RF/RR/LR, setTiretempLF/RF/RR/LR moved to VehicleData

    // setDigitalInput1-7, setEXDigitalInput1-8 moved to DigitalInputs model
    // setEXAnalogInput0-7 moved to ExpanderBoardData model
    // setundrivenavgspeed, setdrivenavgspeed moved to VehicleData
    // setfrequencyDIEX1, setRPMFrequencyDividerDi1, setDI1RPMEnabled moved to DigitalInputs model
    // setLF/RF/LR/RR_Tyre_Temp_01-08 (32 setters) moved to VehicleData
    // setExternalrpm, setlanguage moved to SettingsData
    // setexternalspeedconnectionrequest, setexternalspeedport moved to ConnectionData

    // Megasquirt Advanced

    // Odo() moved to VehicleData

    // Tripmeter
    // Trip() moved to VehicleData
    // Advanced Info FD3S
    // speed() moved to VehicleData

    // Boost

    // Aux Differential (auxcalc1-4 getters moved to AnalogInputs model)
    // Sensor Voltages (sens1-8 getters moved to SensorData/AnalogInputs models)

    // Platform, SerialStat, RecvData, TimeoutStat, RunStat, WifiStat, EthernetStat getters moved to ConnectionData

    QString CBXCountrysave() const;
    QString CBXTracksave() const;

    // units() getters moved to SettingsData

    // Adaptronic extra

    // MVSS(), SVSS() moved to VehicleData

    // qsensors (accelx/y/z, gyrox/y/z, compass, ambitemp, ambipress moved to VehicleData)

    // calculations (Gear, GearCalculation, AccelTimer, Weight moved to VehicleData)
    qreal Gearoffset() const;

    // screen(), maindashsetup(), dashsetup1-3(), dashfiles(), backroundpictures() moved to UIState

    // accelpedpos() moved to VehicleData
    // clutchswitchstate() moved to VehicleData
    // distancetoempty() moved to VehicleData
    // gearswitch(), handbrake(), highbeam(), lowBeam() moved to VehicleData

    // leftindicator() moved to VehicleData
    // rightindicator() moved to VehicleData
    // wheeldiff(), wheelslip(), wheelspdftleft(), wheelspdftright(), wheelspdrearleft(), wheelspdrearright() moved to VehicleData
    // musicpath(), supportedReg() moved to ConnectionData
    // speedpercent(), pulsespermile() moved to VehicleData

    // maxRPM(), rpmStage1-4(), waterwarn(), rpmwarn(), knockwarn(), boostwarn(), smoothrpm(), smoothspeed() moved to SettingsData
    int smootexAnalogInput7() const;

    // gearcalc1-6, gearcalcactivation getters moved to SettingsData
    // ecu() moved to ConnectionData
    // rpmstyle1(), rpmstyle2(), rpmstyle3() moved to UIState

    // Error() moved to ConnectionData
    // autogear() moved to VehicleData
    QString daemonlicense() const;
    QString holleyproductid() const;

    // ExternalSpeed() getter moved to SettingsData

    // draggable() moved to UIState
    // wifi(), can() moved to ConnectionData

    // Analog0-10, AnalogCalc0-10, EXAnalogCalc0-7, Userchannel1-12 getters moved to AnalogInputs/ExpanderBoardData models

    // FuelLevel(), SteeringWheelAngle() moved to VehicleData
    // Brightness(), Visibledashes() moved to UIState

    // IGBT*(), RtdTemp*(), EMotor*(), TorqueShudder(), DigInput*(), ElectricalOutFreq(), DeltaResolverFiltered(),
    // Phase*Current(), DCBus*(), OutputVoltage(), VABvdVoltage(), VBCvqVoltage() moved to ElectricMotorData

    // TirepresLF/RF/RR/LR(), TiretempLF/RF/RR/LR() moved to VehicleData

    // DigitalInput1-7, EXDigitalInput1-8 getters moved to DigitalInputs model
    // EXAnalogInput0-7 getters moved to ExpanderBoardData model
    // undrivenavgspeed(), drivenavgspeed() moved to VehicleData
    // frequencyDIEX1, RPMFrequencyDividerDi1, DI1RPMEnabled getters moved to DigitalInputs model
    // LF/RF/LR/RR_Tyre_Temp_01-08() (32 getters) moved to VehicleData
    // Externalrpm(), language() getters moved to SettingsData
    // externalspeedconnectionrequest(), externalspeedport() moved to ConnectionData

    // Megasquirt Advanced

signals:

    // Odometer (odoChanged moved to VehicleData)

    // Tripmeter (tripChanged moved to VehicleData)

    // Advanced Info
    // speedChanged moved to VehicleData

    // Boost

    // Aux Inputs (auxcalc1-4 signals moved to AnalogInputs model)

    // Sensor Voltages (sens1-8 signals moved to SensorData/AnalogInputs models)

    // platformChanged, serialStatChanged, recvDataChanged, timeoutStatChanged, runStatChanged, WifiStatChanged, EthernetStatChanged moved to ConnectionData

    void CBXCountrysaveChanged(QString CBXCountrysave);
    void CBXTracksaveChanged(QString CBXTracksave);

    // units signals moved to SettingsData

    // Adaptronic extra

    // mVSSChanged, sVSSChanged moved to VehicleData

    // accelx/y/z, gyrox/y/z, compass, ambitemp, ambipress Changed signals moved to VehicleData

    // calculations (GearChanged, GearCalculationChanged, accelTimerChanged, weightChanged moved to VehicleData)
    void GearoffsetChanged(qreal Gearoffset);

    // screenChanged, maindashsetupChanged, dashsetup1-3Changed, dashfilesChanged, backroundpicturesChanged moved to UIState

    // accelpedposChanged moved to VehicleData
    // clutchswitchstateChanged moved to VehicleData
    // distancetoemptyChanged moved to VehicleData
    // gearswitchChanged, handbrakeChanged, highbeamChanged, lowBeamChanged moved to VehicleData
    // leftindicatorChanged moved to VehicleData
    // rightindicatorChanged moved to VehicleData
    // wheeldiffChanged, wheelslipChanged, wheelspdftleftChanged, wheelspdftrightChanged, wheelspdrearleftChanged, wheelspdrearrightChanged moved to VehicleData
    // musicpathChanged, supportedRegChanged moved to ConnectionData
    // maxRPMChanged, rpmStage1-4Changed, waterwarnChanged, rpmwarnChanged, knockwarnChanged, boostwarnChanged, smoothspeedChanged moved to SettingsData
    void smootexAnalogInput7Changed(int smootexAnalogInput7);

    void gearcalc1Changed(int gearcalc1);
    void gearcalc2Changed(int gearcalc2);
    void gearcalc3Changed(int gearcalc3);
    void gearcalc4Changed(int gearcalc4);
    void gearcalc5Changed(int gearcalc5);
    void gearcalc6Changed(int gearcalc6);
    void gearcalcactivationChanged(int gearcalcactivation);
    // ecuChanged moved to ConnectionData
    // rpmstyle1Changed, rpmstyle2Changed, rpmstyle3Changed moved to UIState

    // ErrorChanged moved to ConnectionData
    // autogearChanged moved to VehicleData
    void daemonlicenseChanged(QString daemonlicense);
    void holleyproductidChanged(QString holleyproductid);

    void ExternalSpeedChanged(int ExternalSpeed);
    void externalspeedport(QString externalspeedport);

    // draggableChanged moved to UIState
    // wifiChanged, canChanged moved to ConnectionData

    // Analog0-10Changed, AnalogCalc0-10Changed, EXAnalogCalc0-7Changed, Userchannel1-12Changed signals moved to AnalogInputs/ExpanderBoardData models

    // udp 299 300 301
    void BitfieldEngineStatusChanged(qreal BitfieldEngineStatus);

    void FuelLevelChanged(qreal FuelLevel);
    void SteeringWheelAngleChanged(qreal SteeringWheelAngle);
    // BrightnessChanged, VisibledashesChanged moved to UIState

    // IGBT*TempChanged, RtdTemp*Changed, EMotor*Changed, TorqueShudderChanged, DigInput*Changed,
    // ElectricalOutFreqChanged, DeltaResolverFilteredChanged, Phase*CurrentChanged, DCBus*Changed,
    // OutputVoltageChanged, VABvdVoltageChanged, VBCvqVoltageChanged moved to ElectricMotorData

    // TirepresLF/RF/RR/LRChanged, TiretempLF/RF/RR/LRChanged moved to VehicleData

    // DigitalInput1-7Changed, EXDigitalInput1-8Changed signals moved to DigitalInputs model
    // EXAnalogInput0-7Changed signals moved to ExpanderBoardData model
    // undrivenavgspeedChanged, drivenavgspeedChanged moved to VehicleData
    // frequencyDIEX1Changed, RPMFrequencyDividerDi1Changed, DI1RPMEnabledChanged signals moved to DigitalInputs model
    // LF/RF/LR/RR_Tyre_Temp_01-08Changed (32 signals) moved to VehicleData
    // languageChanged moved to SettingsData
    // externalspeedconnectionrequestChanged, externalspeedportChanged moved to ConnectionData

    // Megasquirt Advanced

private:
    // Odometer (m_Odo moved to VehicleData)

    // Tripmeter (m_Trip moved to VehicleData)
    // Advanced Info
    // m_speed moved to VehicleData

    // Boost

    // Aux Inputs (m_auxcalc1-4 moved to AnalogInputs model)

    // Sensor Voltage (m_sens1-8 moved to SensorData/AnalogInputs models)

    // m_Platform, m_SerialStat, m_RecvData, m_TimeoutStat, m_RunStat, m_WifiStat, m_EthernetStat moved to ConnectionData

    QString m_CBXCountrysave;
    QString m_CBXTracksave;

    // Adaptronic extra

    //

    // m_MVSS, m_SVSS moved to VehicleData

    // Units member variables moved to SettingsData

    // qsensors (m_accelx/y/z, m_gyrox/y/z, m_compass, m_ambitemp, m_ambipress moved to VehicleData)

    // calculations (m_Gear, m_GearCalculation, m_AccelTimer, m_Weight moved to VehicleData)
    qreal m_Gearoffset;

    // m_screen, m_maindashsetup, m_dashsetup1-3, m_dashfiles, m_backroundpictures moved to UIState

    // m_accelpedpos moved to VehicleData
    // m_clutchswitchstate moved to VehicleData
    // m_distancetoempty moved to VehicleData
    // m_gearswitch, m_handbrake, m_highbeam, m_lowBeam moved to VehicleData
    // m_leftindicator moved to VehicleData
    // m_rightindicator moved to VehicleData
    // m_wheeldiff, m_wheelslip, m_wheelspdftleft, m_wheelspdftright, m_wheelspdrearleft, m_wheelspdrearright moved to VehicleData
    // m_musicpath, m_supportedReg moved to ConnectionData
    // m_speedpercent, m_pulsespermile moved to VehicleData

    // m_maxRPM, m_rpmStage1-4, m_waterwarn, m_rpmwarn, m_knockwarn, m_boostwarn, m_smoothrpm, m_smoothspeed moved to SettingsData
    int m_smoothexAnalogInput7;
    // m_gearcalc1-6, m_gearcalcactivation moved to SettingsData
    // m_ecu moved to ConnectionData
    // m_rpmstyle1, m_rpmstyle2, m_rpmstyle3 moved to UIState

    // m_Error moved to ConnectionData
    // m_autogear moved to VehicleData
    QString m_daemonlicense;
    QString m_holleyproductid;

    // m_ExternalSpeed moved to SettingsData

    // m_draggable moved to UIState
    // m_wifi, m_can moved to ConnectionData

    // m_Analog0-10, m_AnalogCalc0-10, m_EXAnalogCalc0-7, m_Userchannel1-12 moved to AnalogInputs/ExpanderBoardData models

    // udp 298 Mega squirt Advanced
    qreal m_BitfieldEngineStatus;

    // m_FuelLevel, m_SteeringWheelAngle moved to VehicleData
    // m_Brightness, m_Visibledashes moved to UIState

    // m_IGBT*, m_RtdTemp*, m_EMotor*, m_TorqueShudder, m_DigInput*, m_ElectricalOutFreq, m_DeltaResolverFiltered,
    // m_Phase*Current, m_DCBus*, m_OutputVoltage, m_VABvdVoltage, m_VBCvqVoltage moved to ElectricMotorData

    // m_TirepresLF/RF/RR/LR, m_TiretempLF/RF/RR/LR moved to VehicleData

    // m_DigitalInput1-7, m_EXDigitalInput1-8 moved to DigitalInputs model
    // m_EXAnalogInput0-7 moved to ExpanderBoardData model
    // m_undrivenavgspeed, m_drivenavgspeed moved to VehicleData
    // m_frequencyDIEX1, m_RPMFrequencyDividerDi1, m_DI1RPMEnabled moved to DigitalInputs model
    // m_LF/RF/LR/RR_Tyre_Temp_01-08 (32 variables) moved to VehicleData
    int m_Externalrpm;
    int m_language;
    // m_externalspeedconnectionrequest, m_externalspeedport moved to ConnectionData

    // Megasquirt Advanced

    // * Phase 4: UIState model pointer for facade forwarding
    UIState *m_uiState = nullptr;

    // * Phase 5: Business logic service classes
    SteinhartCalculator *m_steinhartCalc = nullptr;
    SignalSmoother *m_rpmSmoother = nullptr;
    SignalSmoother *m_speedSmoother = nullptr;

    // * Phase 5: Analog input calibration values (moved from global variables)
    qreal m_AN_calibration[22] = {0};   // AN00 through AN105
    qreal m_EXAN_calibration[16] = {0}; // EXAN00 through EXAN75
};

#endif  // DASHBOARD_H
