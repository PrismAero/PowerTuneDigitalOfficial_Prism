#include "dashboard.h"
#include "Models/UIState.h"

#include "math.h"

#include <QDateTime>
#include <QDebug>
#include <QStringList>
#include <QVector>

QVector<int> averageSpeed(0);
QVector<int> averageRPM(0);
QVector<qreal> averageexanaloginput7(0);
int avgspeed;
int avgrpm;
qreal avgexanaloginput7;
qreal R2 = 1430;  // R2 is always Fixed ( Two resistors in line 1100 + 330 Ohms
qreal R3 = 100;   // R2 is always Fixed ( Two resistors in line 1100 + 330 Ohms
qreal R4 = 1000;  // R2 is always Fixed ( Two resistors in line 1100 + 330 Ohms
qreal AN0R3 = 0;
qreal AN1R3 = 0;
qreal AN2R3 = 0;
qreal AN0R4 = 0;
qreal AN1R4 = 0;
qreal AN2R4 = 0;
qreal Rtotalexan0;  // Resistance of all internal Resistors of the EX Board for AN0
qreal Rtotalexan1;  // Resistance of all internal Resistors of the EX Board for AN1
qreal Rtotalexan2;  // Resistance of all internal Resistors of the EX Board for AN2
qreal Rtotalexan3;  // Resistance of all internal Resistors of the EX Board for AN3
qreal Rtotalexan4;  // Resistance of all internal Resistors of the EX Board for AN4
qreal Rtotalexan5;  // Resistance of all internal Resistors of the EX Board for AN5
qreal AN00;
qreal AN05;
qreal AN10;
qreal AN15;
qreal AN20;
qreal AN25;
qreal AN30;
qreal AN35;
qreal AN40;
qreal AN45;
qreal AN50;
qreal AN55;
qreal AN60;
qreal AN65;
qreal AN70;
qreal AN75;
qreal AN80;
qreal AN85;
qreal AN90;
qreal AN95;
qreal AN100;
qreal AN105;
// Ex Board Analog
qreal EXAN00;
qreal EXAN05;
qreal EXAN10;
qreal EXAN15;
qreal EXAN20;
qreal EXAN25;
qreal EXAN30;
qreal EXAN35;
qreal EXAN40;
qreal EXAN45;
qreal EXAN50;
qreal EXAN55;
qreal EXAN60;
qreal EXAN65;
qreal EXAN70;
qreal EXAN75;
qreal ResistanceEXAN0;
qreal ResistanceEXAN1;
qreal ResistanceEXAN2;
qreal ResistanceEXAN3;
qreal ResistanceEXAN4;
qreal ResistanceEXAN5;
int EXsteinhart0;  // Flag to use Steinhart/hart for Analog input 0
int EXsteinhart1;  // Flag to use Steinhart/hart for Analog input 1
int EXsteinhart2;  // Flag to use Steinhart/hart for Analog input 2
int EXsteinhart3;  // Flag to use Steinhart/hart for Analog input 3
int EXsteinhart4;  // Flag to use Steinhart/hart for Analog input 4
int EXsteinhart5;  // Flag to use Steinhart/hart for Analog input 5

qreal lamdamultiplicator = 1;
int brightness;

DashBoard::DashBoard(QObject *parent)
    : QObject(parent),
      m_CBXCountrysave(),
      m_CBXTracksave(),
      m_Gearoffset(0),
      m_smoothexAnalogInput7(0),
      m_BitfieldEngineStatus(0),
      m_Externalrpm(0),
      m_language(0),
      m_uiState(nullptr),
      m_steinhartCalc(nullptr),
      m_rpmSmoother(nullptr),
      m_speedSmoother(nullptr)
{
}

/**
 * @brief Sets UIState model pointer (Phase 4)
 *
 * UI-related properties (draggable, Brightness, Visibledashes, screen,
 * rpmstyle1-3, maindashsetup, dashfiles, dashsetup1-3, backroundpictures)
 * have been fully moved to UIState. This method is retained for any
 * future cross-model coordination needs.
 */
void DashBoard::setUIState(UIState *uiState)
{
    if (m_uiState == uiState)
        return;

    m_uiState = uiState;
}

// Odometer (setOdo moved to VehicleData)
// Tripmeter (setTrip moved to VehicleData)

void DashBoard::setAnalogVal(const qreal &A00, const qreal &A05, const qreal &A10, const qreal &A15, const qreal &A20,
                             const qreal &A25, const qreal &A30, const qreal &A35, const qreal &A40, const qreal &A45,
                             const qreal &A50, const qreal &A55, const qreal &A60, const qreal &A65, const qreal &A70,
                             const qreal &A75, const qreal &A80, const qreal &A85, const qreal &A90, const qreal &A95,
                             const qreal &A100, const qreal &A105)
{
    AN00 = A00;
    AN05 = A05;
    AN10 = A10;
    AN15 = A15;
    AN20 = A20;
    AN25 = A25;
    AN30 = A30;
    AN35 = A35;
    AN40 = A40;
    AN45 = A45;
    AN50 = A50;
    AN55 = A55;
    AN60 = A60;
    AN65 = A65;
    AN70 = A70;
    AN75 = A75;
    AN80 = A80;
    AN85 = A85;
    AN90 = A90;
    AN95 = A95;
    AN100 = A100;
    AN105 = A105;
}
void DashBoard::setEXAnalogVal(const qreal &EXA00, const qreal &EXA05, const qreal &EXA10, const qreal &EXA15,
                               const qreal &EXA20, const qreal &EXA25, const qreal &EXA30, const qreal &EXA35,
                               const qreal &EXA40, const qreal &EXA45, const qreal &EXA50, const qreal &EXA55,
                               const qreal &EXA60, const qreal &EXA65, const qreal &EXA70, const qreal &EXA75,
                               const int &steinhartcalc0on, const int &steinhartcalc1on, const int &steinhartcalc2on,
                               const int &steinhartcalc3on, const int &steinhartcalc4on, const int &steinhartcalc5on,
                               const int &AN0R3VAL, const int &AN0R4VAL, const int &AN1R3VAL, const int &AN1R4VAL,
                               const int &AN2R3VAL, const int &AN2R4VAL, const int &AN3R3VAL, const int &AN3R4VAL,
                               const int &AN4R3VAL, const int &AN4R4VAL, const int &AN5R3VAL, const int &AN5R4VAL)
{
    EXAN00 = EXA00;
    EXAN05 = EXA05;
    EXAN10 = EXA10;
    EXAN15 = EXA15;
    EXAN20 = EXA20;
    EXAN25 = EXA25;
    EXAN30 = EXA30;
    EXAN35 = EXA35;
    EXAN40 = EXA40;
    EXAN45 = EXA45;
    EXAN50 = EXA50;
    EXAN55 = EXA55;
    EXAN60 = EXA60;
    EXAN65 = EXA65;
    EXAN70 = EXA70;
    EXAN75 = EXA75;
    EXsteinhart0 = steinhartcalc0on;
    EXsteinhart1 = steinhartcalc1on;
    EXsteinhart2 = steinhartcalc2on;
    EXsteinhart3 = steinhartcalc3on;
    EXsteinhart4 = steinhartcalc4on;
    EXsteinhart5 = steinhartcalc5on;

    // Calculating the Boad internal resistance of the Voltage divider
    // EX Analog 0
    if (AN0R3VAL != 0 && AN0R4VAL != 0) {
        Rtotalexan0 = 1 / ((1 / R2) + (1 / R3) + (1 / R4));
    }
    if (AN0R3VAL == 0 && AN0R4VAL != 0) {
        Rtotalexan0 = (R2 * R4) / (R2 + R4);
    }
    if (AN0R3VAL != 0 && AN0R4VAL == 0) {
        Rtotalexan0 = (R2 * R3) / (R2 + R3);
    }
    if (AN0R3VAL == 0 && AN0R4VAL == 0) {
        Rtotalexan0 = R2;
    }
    // EX Analog 1
    if (AN1R3VAL != 0 && AN1R4VAL != 0) {
        Rtotalexan1 = 1 / ((1 / R2) + (1 / R3) + (1 / R4));
    }
    if (AN1R3VAL == 0 && AN1R4VAL != 0) {
        Rtotalexan1 = (R2 * R4) / (R2 + R4);
    }
    if (AN1R3VAL != 0 && AN1R4VAL == 0) {
        Rtotalexan1 = (R2 * R3) / (R2 + R3);
    }
    if (AN1R3VAL == 0 && AN1R4VAL == 0) {
        Rtotalexan1 = R2;
    }
    // EX Analog 2
    if (AN2R3VAL != 0 && AN2R4VAL != 0) {
        Rtotalexan2 = 1 / ((1 / R2) + (1 / R3) + (1 / R4));
    }
    if (AN2R3VAL == 0 && AN2R4VAL != 0) {
        Rtotalexan2 = (R2 * R4) / (R2 + R4);
    }
    if (AN2R3VAL != 0 && AN2R4VAL == 0) {
        Rtotalexan2 = (R2 * R3) / (R2 + R3);
    }
    if (AN2R3VAL == 0 && AN2R4VAL == 0) {
        Rtotalexan2 = R2;
    }

    // EX Analog 3
    if (AN3R3VAL != 0 && AN3R4VAL != 0) {
        Rtotalexan3 = 1 / ((1 / R2) + (1 / R3) + (1 / R4));
    }
    if (AN3R3VAL == 0 && AN3R4VAL != 0) {
        Rtotalexan3 = (R2 * R4) / (R2 + R4);
    }
    if (AN3R3VAL != 0 && AN3R4VAL == 0) {
        Rtotalexan3 = (R2 * R3) / (R2 + R3);
    }
    if (AN3R3VAL == 0 && AN3R4VAL == 0) {
        Rtotalexan3 = R2;
    }

    // EX Analog 4
    if (AN4R3VAL != 0 && AN4R4VAL != 0) {
        Rtotalexan4 = 1 / ((1 / R2) + (1 / R3) + (1 / R4));
    }
    if (AN4R3VAL == 0 && AN4R4VAL != 0) {
        Rtotalexan4 = (R2 * R4) / (R2 + R4);
    }
    if (AN4R3VAL != 0 && AN4R4VAL == 0) {
        Rtotalexan4 = (R2 * R3) / (R2 + R3);
    }
    if (AN4R3VAL == 0 && AN4R4VAL == 0) {
        Rtotalexan4 = R2;
    }

    // EX Analog 5
    if (AN5R3VAL != 0 && AN5R4VAL != 0) {
        Rtotalexan5 = 1 / ((1 / R2) + (1 / R3) + (1 / R4));
    }
    if (AN5R3VAL == 0 && AN5R4VAL != 0) {
        Rtotalexan5 = (R2 * R4) / (R2 + R4);
    }
    if (AN5R3VAL != 0 && AN5R4VAL == 0) {
        Rtotalexan5 = (R2 * R3) / (R2 + R3);
    }
    if (AN5R3VAL == 0 && AN5R4VAL == 0) {
        Rtotalexan5 = R2;
    }
    /*
        qDebug() <<"///////////////////////////////////////////////////////////// :" ;
        qDebug() <<AN0R3VAL<<AN0R4VAL<<AN1R3VAL<<AN1R4VAL<<AN2R3VAL<<AN2R4VAL ;
         qDebug() <<"RTotal AN0 :" <<Rtotalexan0 ;
         qDebug() <<"RTotal AN1 :" <<Rtotalexan1 ;
         qDebug() <<"RTotal AN2 :" <<Rtotalexan2 ;
        qDebug() <<"///////////////////////////////////////////////////////////// :" ;
    */
}

void DashBoard::setSteinhartcalc(const qreal &T01, const qreal &T02, const qreal &T03, const qreal &R01,
                                 const qreal &R02, const qreal &R03, const qreal &T11, const qreal &T12,
                                 const qreal &T13, const qreal &R11, const qreal &R12, const qreal &R13,
                                 const qreal &T21, const qreal &T22, const qreal &T23, const qreal &R21,
                                 const qreal &R22, const qreal &R23, const qreal &T31, const qreal &T32,
                                 const qreal &T33, const qreal &R31, const qreal &R32, const qreal &R33,
                                 const qreal &T41, const qreal &T42, const qreal &T43, const qreal &R41,
                                 const qreal &R42, const qreal &R43, const qreal &T51, const qreal &T52,
                                 const qreal &T53, const qreal &R51, const qreal &R52, const qreal &R53)
{
    // EX Analog 0 Calculation
    long double L01 = log(R01);  // Logrythm of Resistance 1
    long double L02 = log(R02);  // Logrythm of Resistance 2
    long double L03 = log(R03);  // Logrythm of Resistance 3

    // Convert Temperature from CELCIUS to Kelvin and get factor
    long double Y01 = 1 / (T01 + 273.15);
    long double Y02 = 1 / (T02 + 273.15);
    long double Y03 = 1 / (T03 + 273.15);

    // Coefficent of L and Y
    long double V02 = (Y02 - Y01) / (L02 - L01);
    long double V03 = (Y03 - Y01) / (L03 - L01);

    // Coefficent Calculations
    C0 = ((V03 - V02) / (L03 - L02)) * (pow((L01 + L02 + L02), -1));
    B0 = (V03 - C0 * (pow(L01, 2) + L01 * L02 + pow(L02, 2)));
    A0 = Y01 - (B0 + pow(L01, 2) * C0) * L01;

    // EX Analog 1 Calculation
    long double L11 = log(R11);  // Logrythm of Resistance 1
    long double L12 = log(R12);  // Logrythm of Resistance 2
    long double L13 = log(R13);  // Logrythm of Resistance 3

    // Convert Temperature from CELCIUS to Kelvin and get factor
    long double Y11 = 1 / (T11 + 273.15);
    long double Y12 = 1 / (T12 + 273.15);
    long double Y13 = 1 / (T13 + 273.15);

    // Coefficent of L and Y
    long double V12 = (Y12 - Y11) / (L12 - L11);
    long double V13 = (Y13 - Y11) / (L13 - L11);

    // Coefficent Calculations
    C1 = ((V13 - V12) / (L13 - L12)) * (pow((L11 + L12 + L12), -1));
    B1 = (V13 - C1 * (pow(L11, 2) + L11 * L12 + pow(L12, 2)));
    A1 = Y11 - (B1 + pow(L11, 2) * C1) * L11;

    // EX Analog 2 Calculation
    long double L21 = log(R21);  // Logrythm of Resistance 1
    long double L22 = log(R22);  // Logrythm of Resistance 2
    long double L23 = log(R23);  // Logrythm of Resistance 3

    // Convert Temperature from CELCIUS to Kelvin and get factor
    long double Y21 = 1 / (T21 + 273.15);
    long double Y22 = 1 / (T22 + 273.15);
    long double Y23 = 1 / (T23 + 273.15);

    // Coefficent of L and Y
    long double V22 = (Y22 - Y21) / (L22 - L21);
    long double V23 = (Y23 - Y21) / (L23 - L21);

    // Coefficent Calculations
    C2 = ((V23 - V22) / (L23 - L22)) * (pow((L21 + L22 + L22), -1));
    B2 = (V23 - C2 * (pow(L21, 2) + L22 * L22 + pow(L22, 2)));
    A2 = Y21 - (B2 + pow(L21, 2) * C2) * L21;

    // EX Analog 3 Calculation
    long double L31 = log(R31);  // Logrythm of Resistance 1
    long double L32 = log(R32);  // Logrythm of Resistance 2
    long double L33 = log(R33);  // Logrythm of Resistance 3

    // Convert Temperature from CELCIUS to Kelvin and get factor
    long double Y31 = 1 / (T31 + 273.15);
    long double Y32 = 1 / (T32 + 273.15);
    long double Y33 = 1 / (T33 + 273.15);

    // Coefficent of L and Y
    long double V32 = (Y32 - Y31) / (L32 - L31);
    long double V33 = (Y33 - Y31) / (L33 - L31);

    // Coefficent Calculations
    C3 = ((V33 - V32) / (L33 - L32)) * (pow((L31 + L32 + L32), -1));
    B3 = (V33 - C3 * (pow(L31, 2) + L32 * L32 + pow(L32, 2)));
    A3 = Y31 - (B3 + pow(L31, 2) * C3) * L31;

    // EX Analog 4 Calculation
    long double L41 = log(R41);  // Logrythm of Resistance 1
    long double L42 = log(R42);  // Logrythm of Resistance 2
    long double L43 = log(R43);  // Logrythm of Resistance 3

    // Convert Temperature from CELCIUS to Kelvin and get factor
    long double Y41 = 1 / (T41 + 273.15);
    long double Y42 = 1 / (T42 + 273.15);
    long double Y43 = 1 / (T43 + 273.15);

    // Coefficent of L and Y
    long double V42 = (Y42 - Y41) / (L42 - L41);
    long double V43 = (Y43 - Y41) / (L43 - L41);

    // Coefficent Calculations
    C4 = ((V43 - V42) / (L43 - L42)) * (pow((L41 + L42 + L42), -1));
    B4 = (V43 - C4 * (pow(L41, 2) + L42 * L42 + pow(L42, 2)));
    A4 = Y41 - (B4 + pow(L41, 2) * C4) * L41;

    // EX Analog 5 Calculation
    long double L51 = log(R51);  // Logrythm of Resistance 1
    long double L52 = log(R52);  // Logrythm of Resistance 2
    long double L53 = log(R53);  // Logrythm of Resistance 3

    // Convert Temperature from CELCIUS to Kelvin and get factor
    long double Y51 = 1 / (T51 + 273.15);
    long double Y52 = 1 / (T52 + 273.15);
    long double Y53 = 1 / (T53 + 273.15);

    // Coefficent of L and Y
    long double V52 = (Y52 - Y51) / (L52 - L51);
    long double V53 = (Y53 - Y51) / (L53 - L51);

    // Coefficent Calculations
    C5 = ((V53 - V52) / (L53 - L52)) * (pow((L51 + L52 + L52), -1));
    B5 = (V53 - C5 * (pow(L51, 2) + L52 * L52 + pow(L52, 2)));
    A5 = Y51 - (B5 + pow(L51, 2) * C5) * L51;
}
// setExternalrpm, setlanguage moved to SettingsData
// setexternalspeedconnectionrequest, setexternalspeedport moved to ConnectionData

// setSpeed moved to VehicleData
// setSerialSpeed moved to ConnectionData

// Boost

// Aux Inputs (setauxcalc1-4 moved to AnalogInputs model)

// Sensor info (setsens1-8 moved to SensorData/AnalogInputs models)

// setPlatform, setSerialStat, setRecvData, setTimeoutStat, setRunStat, setWifiStat, setEthernetStat moved to ConnectionData

void DashBoard::setCBXCountrysave(const QString &CBXCountrysave)
{
    if (m_CBXCountrysave == CBXCountrysave)
        return;
    m_CBXCountrysave = CBXCountrysave;
    emit CBXCountrysaveChanged(CBXCountrysave);
}

void DashBoard::setCBXTracksave(const QString &CBXTracksave)
{
    if (m_CBXTracksave == CBXTracksave)
        return;
    m_CBXTracksave = CBXTracksave;
    emit CBXTracksaveChanged(CBXTracksave);
}

// Units setters moved to SettingsData
// Adaptronic extra

// setMVSS, setSVSS moved to VehicleData

// Qsensors (setaccelx/y/z, setgyrox/y/z, setcompass, setambitemp, setambipress moved to VehicleData)

// Calculations
// setGear moved to VehicleData

void DashBoard::setGearoffset(const qreal &Gearoffset)
{
    if (m_Gearoffset == Gearoffset)
        return;
    m_Gearoffset = Gearoffset;
    emit GearoffsetChanged(Gearoffset);
}

// setGearCalculation, setAccelTimer, setWeight moved to VehicleData

// setscreen, setmaindashsetup, setdashsetup1-3, setdashfiles, setbackroundpictures moved to UIState

// setaccelpedpos, setclutchswitchstate, setdistancetoempty, setgearswitch, sethandbrake, sethighbeam, setlowBeam moved to VehicleData

// setleftindicator moved to VehicleData

// setrightindicator moved to VehicleData

// setwheeldiff, setwheelslip, setwheelspdftleft, setwheelspdftright, setwheelspdrearleft, setwheelspdrearright moved to VehicleData
// setmusicpath, setsupportedReg moved to ConnectionData
// setmaxRPM, setrpmStage1-4, setwaterwarn, setrpmwarn, setknockwarn, setboostwarn, setsmoothrpm, setsmoothspeed moved to SettingsData

void DashBoard::setsmootexAnalogInput7(const int &smoothexAnalogInput7)
{
    // qDebug()<<"Smootg" << smoothexAnalogInput7;
    if (m_smoothexAnalogInput7 == smoothexAnalogInput7)
        return;
    if (smoothexAnalogInput7 != 0) {
        m_smoothexAnalogInput7 = smoothexAnalogInput7 + 1;
    } else {
        m_smoothexAnalogInput7 = smoothexAnalogInput7;
    }
    averageexanaloginput7.resize(m_smoothexAnalogInput7);
    // qDebug()<<"SmoothSpeed" << m_smoothrpm;
    emit smootexAnalogInput7Changed(smoothexAnalogInput7);
}

// setgearcalc1-6, setgearcalcactivation moved to SettingsData

// setecu moved to ConnectionData
// setrpmstyle1, setrpmstyle2, setrpmstyle3 moved to UIState

// setError moved to ConnectionData
// setautogear moved to VehicleData
// setExternalSpeed moved to SettingsData

void DashBoard::setdaemonlicense(const QString &daemonlicense)
{
    if (m_daemonlicense == daemonlicense)
        return;
    m_daemonlicense = daemonlicense;
    emit daemonlicenseChanged(daemonlicense);
}
void DashBoard::setholleyproductid(const QString &holleyproductid)
{
    if (m_holleyproductid == holleyproductid)
        return;
    m_holleyproductid = holleyproductid;
    emit holleyproductidChanged(holleyproductid);
}

// setdraggable moved to UIState
// setwifi, setcan moved to ConnectionData
// setAnalog0-10, setAnalogCalc0-10 moved to AnalogInputs model

// EX Board (setEXAnalogInput0-7, setEXAnalogCalc0-7 moved to ExpanderBoardData model)

// setUserchannel1-12 moved to AnalogInputs model
// setFuelLevel, setSteeringWheelAngle moved to VehicleData

// setBrightness, setVisibledashes moved to UIState

// setIGBT*, setRtdTemp*, setEMotor*, setTorqueShudder, setDigInput*, setElectricalOutFreq, setDeltaResolverFiltered,
// setPhase*Current, setDCBus*, setOutputVoltage, setVABvdVoltage, setVBCvqVoltage moved to ElectricMotorData

// setTiretempLF/RF/RR/LR, setTirepresLF/RF/RR/LR moved to VehicleData

// setDigitalInput1-7, setEXDigitalInput1-8 moved to DigitalInputs model
// setundrivenavgspeed, setdrivenavgspeed moved to VehicleData
// setfrequencyDIEX1, setRPMFrequencyDividerDi1, setDI1RPMEnabled moved to DigitalInputs model
// setLF/RF/LR/RR_Tyre_Temp_01-08 (32 setters) moved to VehicleData

// Megasquirt Advanced

// Odometer (Odo() moved to VehicleData)
// Cylinders() moved to EngineData

// Tripmeter (Trip() moved to VehicleData)

// Advanced Info
// speed() moved to VehicleData

// Boost

// Aux Inputs (auxcalc1-4 getters moved to AnalogInputs model)

// Sensor info (sens1-8 getters moved to SensorData/AnalogInputs models)

// Platform(), SerialStat(), RecvData(), TimeoutStat(), RunStat(), WifiStat(), EthernetStat() moved to ConnectionData

QString DashBoard::CBXCountrysave() const
{
    return m_CBXCountrysave;
}
QString DashBoard::CBXTracksave() const
{
    return m_CBXTracksave;
}

// units() getters moved to SettingsData

// Adaptronic extra

// MVSS(), SVSS() moved to VehicleData

// Qsensors (accelx/y/z(), gyrox/y/z(), compass(), ambitemp(), ambipress() moved to VehicleData)

// calculations
// Gear() moved to VehicleData

qreal DashBoard::Gearoffset() const
{
    return m_Gearoffset;
}

// GearCalculation(), AccelTimer(), Weight() moved to VehicleData

// screen(), maindashsetup(), dashsetup1-3(), dashfiles(), backroundpictures() moved to UIState

// accelpedpos(), clutchswitchstate(), distancetoempty(), gearswitch(), handbrake(), highbeam(), lowBeam(), leftindicator(), rightindicator() moved to VehicleData
// wheeldiff(), wheelslip(), wheelspdftleft(), wheelspdftright(), wheelspdrearleft(), wheelspdrearright() moved to VehicleData

// musicpath(), supportedReg() moved to ConnectionData
// speedpercent(), pulsespermile() moved to VehicleData

// maxRPM(), rpmStage1-4(), waterwarn(), rpmwarn(), knockwarn(), boostwarn(), smoothrpm(), smoothspeed() getters moved to SettingsData
int DashBoard::smootexAnalogInput7() const
{
    return m_smoothexAnalogInput7;
}
// gearcalc1-6(), gearcalcactivation() getters moved to SettingsData
// ecu() moved to ConnectionData
// rpmstyle1(), rpmstyle2(), rpmstyle3() moved to UIState

// Error() moved to ConnectionData
// autogear() moved to VehicleData

QString DashBoard::daemonlicense() const
{
    return m_daemonlicense;
}
QString DashBoard::holleyproductid() const
{
    return m_holleyproductid;
}

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
