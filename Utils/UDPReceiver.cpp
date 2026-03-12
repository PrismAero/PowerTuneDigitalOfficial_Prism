/**
 * @file UDPReceiver.cpp
 * @brief UDP data receiver implementation for PowerTune telemetry
 *
 * Receives UDP packets on port 45454 containing comma-separated data in format "ident,value"
 * and routes data to appropriate domain models.
 *
 * Part of the Dashboard Modularization - Phase 1
 */

#include "UDPReceiver.h"

#include "../Core/Models/AnalogInputs.h"
#include "../Core/Models/ConnectionData.h"
#include "../Core/Models/DigitalInputs.h"
#include "../Core/Models/ElectricMotorData.h"
#include "../Core/Models/EngineData.h"
#include "../Core/Models/ExpanderBoardData.h"
#include "../Core/Models/FlagsData.h"
#include "../Core/Models/GPSData.h"
#include "../Core/Models/SensorData.h"
#include "../Core/Models/SettingsData.h"
#include "../Core/Models/VehicleData.h"
#include "../Core/SensorRegistry.h"

#include <QHostAddress>
#include <QUdpSocket>

QHash<int, QString> udpreceiver::buildIdentToSensorKeyMap()
{
    return {
        // Engine
        {179, QStringLiteral("rpm")},
        {22, QStringLiteral("BoostPres")},
        {278, QStringLiteral("BoostPreskpa")},
        {155, QStringLiteral("MAP")},
        {210, QStringLiteral("TPS")},
        {135, QStringLiteral("Intaketemp")},
        {221, QStringLiteral("Watertemp")},
        {6, QStringLiteral("AFR")},
        {142, QStringLiteral("LAMBDA")},
        {133, QStringLiteral("InjDuty")},
        {121, QStringLiteral("Ign")},
        {46, QStringLiteral("EngLoad")},
        {137, QStringLiteral("Knock")},
        {33, QStringLiteral("Dwell")},
        {21, QStringLiteral("BoostDuty")},
        {229, QStringLiteral("Intakepress")},
        {173, QStringLiteral("Power")},
        {207, QStringLiteral("Torque")},
        {26, QStringLiteral("brakepress")},
        {29, QStringLiteral("coolantpress")},
        {156, QStringLiteral("MAP2")},
        {218, QStringLiteral("turborpm")},
        {220, QStringLiteral("wastegatepress")},
        {1, QStringLiteral("accelpedpos")},

        // Vehicle
        {199, QStringLiteral("speed")},
        {106, QStringLiteral("Gear")},
        {168, QStringLiteral("Odo")},
        {228, QStringLiteral("BatteryV")},
        {191, QStringLiteral("FuelLevel")},
        {194, QStringLiteral("SteeringWheelAngle")},
        {224, QStringLiteral("wheelspdftleft")},
        {225, QStringLiteral("wheelspdftright")},
        {226, QStringLiteral("wheelspdrearleft")},
        {227, QStringLiteral("wheelspdrearright")},

        // Fuel
        {100, QStringLiteral("FuelPress")},
        {101, QStringLiteral("Fueltemp")},
        {83, QStringLiteral("fuelclevel")},
        {87, QStringLiteral("fuelflow")},
        {85, QStringLiteral("fuelconsrate")},

        // Oil
        {169, QStringLiteral("oilpres")},
        {170, QStringLiteral("oiltemp")},
        {213, QStringLiteral("transoiltemp")},
        {31, QStringLiteral("diffoiltemp")},
        {271, QStringLiteral("GearOilPress")},
        {159, QStringLiteral("Moilp")},

        // Exhaust (EGT 1-12)
        {34, QStringLiteral("egt1")},
        {35, QStringLiteral("egt2")},
        {36, QStringLiteral("egt3")},
        {37, QStringLiteral("egt4")},
        {38, QStringLiteral("egt5")},
        {39, QStringLiteral("egt6")},
        {40, QStringLiteral("egt7")},
        {41, QStringLiteral("egt8")},
        {42, QStringLiteral("egt9")},
        {43, QStringLiteral("egt10")},
        {44, QStringLiteral("egt11")},
        {45, QStringLiteral("egt12")},
        {410, QStringLiteral("egthighest")},

        // Tires
        {864, QStringLiteral("TiretempLF")},
        {865, QStringLiteral("TiretempRF")},
        {866, QStringLiteral("TiretempLR")},
        {867, QStringLiteral("TiretempRR")},
        {868, QStringLiteral("TirepresLF")},
        {869, QStringLiteral("TirepresRF")},
        {870, QStringLiteral("TirepresLR")},
        {871, QStringLiteral("TirepresRR")},

        // Electrical
        {166, QStringLiteral("O2volt")},
        {167, QStringLiteral("O2volt_2")},

        // SenseHat / Built-in Sensors
        {3, QStringLiteral("accelx")},
        {4, QStringLiteral("accely")},
        {5, QStringLiteral("accelz")},
        {28, QStringLiteral("compass")},
        {114, QStringLiteral("gyrox")},
        {115, QStringLiteral("gyroy")},
        {116, QStringLiteral("gyroz")},
        {8, QStringLiteral("ambipress")},
        {9, QStringLiteral("ambitemp")},

        // GPS (idents disabled in switch but mapped for liveness)
        {108, QStringLiteral("gpsAltitude")},
        {109, QStringLiteral("gpsLatitude")},
        {110, QStringLiteral("gpsLongitude")},
        {111, QStringLiteral("gpsSpeed")},
        {112, QStringLiteral("gpsbearing")},

        // Analog Inputs
        {260, QStringLiteral("Analog0")},
        {261, QStringLiteral("Analog1")},
        {262, QStringLiteral("Analog2")},
        {263, QStringLiteral("Analog3")},
        {264, QStringLiteral("Analog4")},
        {265, QStringLiteral("Analog5")},
        {266, QStringLiteral("Analog6")},
        {267, QStringLiteral("Analog7")},
        {268, QStringLiteral("Analog8")},
        {269, QStringLiteral("Analog9")},
        {270, QStringLiteral("Analog10")},

        // Digital Inputs
        {279, QStringLiteral("DigitalInput1")},
        {280, QStringLiteral("DigitalInput2")},
        {281, QStringLiteral("DigitalInput3")},
        {282, QStringLiteral("DigitalInput4")},
        {283, QStringLiteral("DigitalInput5")},
        {284, QStringLiteral("DigitalInput6")},
        {285, QStringLiteral("DigitalInput7")},

        // Expander Board Analog Inputs
        {908, QStringLiteral("EXAnalogInput0")},
        {909, QStringLiteral("EXAnalogInput1")},
        {910, QStringLiteral("EXAnalogInput2")},
        {911, QStringLiteral("EXAnalogInput3")},
        {912, QStringLiteral("EXAnalogInput4")},
        {913, QStringLiteral("EXAnalogInput5")},
        {914, QStringLiteral("EXAnalogInput6")},
        {915, QStringLiteral("EXAnalogInput7")},

        // Expander Board Digital Inputs
        {900, QStringLiteral("EXDigitalInput1")},
        {901, QStringLiteral("EXDigitalInput2")},
        {902, QStringLiteral("EXDigitalInput3")},
        {903, QStringLiteral("EXDigitalInput4")},
        {904, QStringLiteral("EXDigitalInput5")},
        {905, QStringLiteral("EXDigitalInput6")},
        {906, QStringLiteral("EXDigitalInput7")},
        {907, QStringLiteral("EXDigitalInput8")},
    };
}

const QHash<int, QString> udpreceiver::s_identToSensorKey = udpreceiver::buildIdentToSensorKeyMap();

udpreceiver::udpreceiver(QObject *parent)
    : QObject(parent),
      m_engine(nullptr),
      m_vehicle(nullptr),
      m_gps(nullptr),
      m_analog(nullptr),
      m_digital(nullptr),
      m_expander(nullptr),
      m_motor(nullptr),
      m_flags(nullptr),
      m_sensor(nullptr),
      m_connection(nullptr),
      m_settings(nullptr)
{
    buildDispatchTables();
}

udpreceiver::udpreceiver(EngineData *engine, VehicleData *vehicle, GPSData *gps, AnalogInputs *analog,
                         DigitalInputs *digital, ExpanderBoardData *expander, ElectricMotorData *motor,
                         FlagsData *flags, SensorData *sensor, ConnectionData *connection, SettingsData *settings,
                         QObject *parent)
    : QObject(parent),
      m_engine(engine),
      m_vehicle(vehicle),
      m_gps(gps),
      m_analog(analog),
      m_digital(digital),
      m_expander(expander),
      m_motor(motor),
      m_flags(flags),
      m_sensor(sensor),
      m_connection(connection),
      m_settings(settings)
{
    buildDispatchTables();
}

void udpreceiver::buildDispatchTables()
{
    m_floatDispatchTable.clear();
    m_stringDispatchTable.clear();

    auto registerFloat = [this](int ident, auto modelMember, auto setter) {
        m_floatDispatchTable.insert(ident, [this, modelMember, setter](float value) {
            if (auto *model = this->*modelMember)
                (model->*setter)(value);
        });
    };

    auto registerInt = [this](int ident, auto modelMember, auto setter) {
        m_floatDispatchTable.insert(ident, [this, modelMember, setter](float value) {
            if (auto *model = this->*modelMember)
                (model->*setter)(static_cast<int>(value));
        });
    };

    auto registerScaledFloat = [this](int ident, auto modelMember, auto setter, float divisor) {
        m_floatDispatchTable.insert(ident, [this, modelMember, setter, divisor](float value) {
            if (auto *model = this->*modelMember)
                (model->*setter)(value / divisor);
        });
    };

    auto registerString = [this](int ident, auto modelMember, auto setter) {
        m_stringDispatchTable.insert(ident, [this, modelMember, setter](const QString &value) {
            if (auto *model = this->*modelMember)
                (model->*setter)(value);
        });
    };

    auto registerNoopFloat = [this](int ident) { m_floatDispatchTable.insert(ident, [](float) {}); };

    auto registerNoopString = [this](int ident) { m_stringDispatchTable.insert(ident, [](const QString &) {}); };

    // Vehicle data
    registerFloat(1, &udpreceiver::m_vehicle, &VehicleData::setaccelpedpos);
    registerFloat(2, &udpreceiver::m_vehicle, &VehicleData::setAccelTimer);
    registerFloat(3, &udpreceiver::m_vehicle, &VehicleData::setaccelx);
    registerFloat(4, &udpreceiver::m_vehicle, &VehicleData::setaccely);
    registerFloat(5, &udpreceiver::m_vehicle, &VehicleData::setaccelz);
    registerFloat(27, &udpreceiver::m_vehicle, &VehicleData::setclutchswitchstate);
    registerFloat(28, &udpreceiver::m_vehicle, &VehicleData::setcompass);
    registerFloat(32, &udpreceiver::m_vehicle, &VehicleData::setdistancetoempty);
    registerFloat(106, &udpreceiver::m_vehicle, &VehicleData::setGear);
    registerFloat(107, &udpreceiver::m_vehicle, &VehicleData::setgearswitch);
    registerFloat(113, &udpreceiver::m_vehicle, &VehicleData::setlowBeam);
    registerFloat(114, &udpreceiver::m_vehicle, &VehicleData::setgyrox);
    registerFloat(115, &udpreceiver::m_vehicle, &VehicleData::setgyroy);
    registerFloat(116, &udpreceiver::m_vehicle, &VehicleData::setgyroz);
    registerFloat(117, &udpreceiver::m_vehicle, &VehicleData::sethandbrake);
    registerFloat(118, &udpreceiver::m_vehicle, &VehicleData::sethighbeam);
    registerFloat(150, &udpreceiver::m_vehicle, &VehicleData::setleftindicator);
    registerFloat(160, &udpreceiver::m_vehicle, &VehicleData::setMVSS);
    registerFloat(168, &udpreceiver::m_vehicle, &VehicleData::setOdo);
    registerFloat(178, &udpreceiver::m_vehicle, &VehicleData::setrightindicator);
    registerFloat(191, &udpreceiver::m_vehicle, &VehicleData::setFuelLevel);
    registerFloat(194, &udpreceiver::m_vehicle, &VehicleData::setSteeringWheelAngle);
    m_floatDispatchTable.insert(199, [this](float value) {
        if (m_settings && m_settings->ExternalSpeed() == 0) {
            if (m_vehicle)
                m_vehicle->setSpeed(value);
        }
    });
    registerFloat(200, &udpreceiver::m_vehicle, &VehicleData::setSVSS);
    registerFloat(217, &udpreceiver::m_vehicle, &VehicleData::setTrip);
    registerFloat(222, &udpreceiver::m_vehicle, &VehicleData::setwheeldiff);
    registerFloat(223, &udpreceiver::m_vehicle, &VehicleData::setwheelslip);
    registerFloat(224, &udpreceiver::m_vehicle, &VehicleData::setwheelspdftleft);
    registerFloat(225, &udpreceiver::m_vehicle, &VehicleData::setwheelspdftright);
    registerFloat(226, &udpreceiver::m_vehicle, &VehicleData::setwheelspdrearleft);
    registerFloat(227, &udpreceiver::m_vehicle, &VehicleData::setwheelspdrearright);
    registerFloat(401, &udpreceiver::m_vehicle, &VehicleData::setundrivenavgspeed);
    registerFloat(402, &udpreceiver::m_vehicle, &VehicleData::setdrivenavgspeed);
    registerString(826, &udpreceiver::m_vehicle, &VehicleData::setautogear);
    registerFloat(864, &udpreceiver::m_vehicle, &VehicleData::setTiretempLF);
    registerFloat(865, &udpreceiver::m_vehicle, &VehicleData::setTiretempRF);
    registerFloat(866, &udpreceiver::m_vehicle, &VehicleData::setTiretempLR);
    registerFloat(867, &udpreceiver::m_vehicle, &VehicleData::setTiretempRR);
    registerFloat(868, &udpreceiver::m_vehicle, &VehicleData::setTirepresLF);
    registerFloat(869, &udpreceiver::m_vehicle, &VehicleData::setTirepresRF);
    registerFloat(870, &udpreceiver::m_vehicle, &VehicleData::setTirepresLR);
    registerFloat(871, &udpreceiver::m_vehicle, &VehicleData::setTirepresRR);

    // Engine, analog, connection, and related data
    registerFloat(6, &udpreceiver::m_engine, &EngineData::setAFR);
    registerFloat(7, &udpreceiver::m_engine, &EngineData::setairtempensor2);
    registerFloat(8, &udpreceiver::m_vehicle, &VehicleData::setambipress);
    registerFloat(9, &udpreceiver::m_vehicle, &VehicleData::setambitemp);
    registerFloat(10, &udpreceiver::m_engine, &EngineData::setantilaglauchswitch);
    registerFloat(11, &udpreceiver::m_engine, &EngineData::setantilaglaunchon);
    registerFloat(12, &udpreceiver::m_analog, &AnalogInputs::setauxcalc1);
    registerFloat(13, &udpreceiver::m_analog, &AnalogInputs::setauxcalc2);
    registerFloat(14, &udpreceiver::m_analog, &AnalogInputs::setauxcalc3);
    registerFloat(15, &udpreceiver::m_analog, &AnalogInputs::setauxcalc4);
    registerFloat(16, &udpreceiver::m_engine, &EngineData::setauxrevlimitswitch);
    registerFloat(17, &udpreceiver::m_engine, &EngineData::setAUXT);
    registerFloat(18, &udpreceiver::m_engine, &EngineData::setavfueleconomy);
    registerFloat(19, &udpreceiver::m_engine, &EngineData::setbattlight);
    registerFloat(20, &udpreceiver::m_engine, &EngineData::setboostcontrol);
    registerFloat(21, &udpreceiver::m_engine, &EngineData::setBoostDuty);
    registerFloat(22, &udpreceiver::m_engine, &EngineData::setBoostPres);
    registerFloat(23, &udpreceiver::m_engine, &EngineData::setBoosttp);
    registerFloat(24, &udpreceiver::m_engine, &EngineData::setBoostwg);
    registerNoopFloat(25);
    registerFloat(26, &udpreceiver::m_engine, &EngineData::setbrakepress);
    registerFloat(29, &udpreceiver::m_engine, &EngineData::setcoolantpress);
    registerFloat(30, &udpreceiver::m_engine, &EngineData::setdecelcut);
    registerFloat(31, &udpreceiver::m_engine, &EngineData::setdiffoiltemp);
    registerFloat(33, &udpreceiver::m_engine, &EngineData::setDwell);
    registerFloat(34, &udpreceiver::m_engine, &EngineData::setegt1);
    registerFloat(35, &udpreceiver::m_engine, &EngineData::setegt2);
    registerFloat(36, &udpreceiver::m_engine, &EngineData::setegt3);
    registerFloat(37, &udpreceiver::m_engine, &EngineData::setegt4);
    registerFloat(38, &udpreceiver::m_engine, &EngineData::setegt5);
    registerFloat(39, &udpreceiver::m_engine, &EngineData::setegt6);
    registerFloat(40, &udpreceiver::m_engine, &EngineData::setegt7);
    registerFloat(41, &udpreceiver::m_engine, &EngineData::setegt8);
    registerFloat(42, &udpreceiver::m_engine, &EngineData::setegt9);
    registerFloat(43, &udpreceiver::m_engine, &EngineData::setegt10);
    registerFloat(44, &udpreceiver::m_engine, &EngineData::setegt11);
    registerFloat(45, &udpreceiver::m_engine, &EngineData::setegt12);
    registerFloat(46, &udpreceiver::m_engine, &EngineData::setEngLoad);
    registerFloat(47, &udpreceiver::m_engine, &EngineData::setexcamangle1);
    registerFloat(48, &udpreceiver::m_engine, &EngineData::setexcamangle2);

    // Flags
    registerFloat(49, &udpreceiver::m_flags, &FlagsData::setFlag1);
    registerFloat(50, &udpreceiver::m_flags, &FlagsData::setFlag2);
    registerFloat(51, &udpreceiver::m_flags, &FlagsData::setFlag3);
    registerFloat(52, &udpreceiver::m_flags, &FlagsData::setFlag4);
    registerFloat(53, &udpreceiver::m_flags, &FlagsData::setFlag5);
    registerFloat(54, &udpreceiver::m_flags, &FlagsData::setFlag6);
    registerFloat(55, &udpreceiver::m_flags, &FlagsData::setFlag7);
    registerFloat(56, &udpreceiver::m_flags, &FlagsData::setFlag8);
    registerFloat(57, &udpreceiver::m_flags, &FlagsData::setFlag9);
    registerFloat(58, &udpreceiver::m_flags, &FlagsData::setFlag10);
    registerFloat(59, &udpreceiver::m_flags, &FlagsData::setFlag11);
    registerFloat(60, &udpreceiver::m_flags, &FlagsData::setFlag12);
    registerFloat(61, &udpreceiver::m_flags, &FlagsData::setFlag13);
    registerFloat(62, &udpreceiver::m_flags, &FlagsData::setFlag14);
    registerFloat(63, &udpreceiver::m_flags, &FlagsData::setFlag15);
    registerFloat(64, &udpreceiver::m_flags, &FlagsData::setFlag16);
    registerFloat(65, &udpreceiver::m_flags, &FlagsData::setFlag17);
    registerFloat(66, &udpreceiver::m_flags, &FlagsData::setFlag18);
    registerFloat(67, &udpreceiver::m_flags, &FlagsData::setFlag19);
    registerFloat(68, &udpreceiver::m_flags, &FlagsData::setFlag20);
    registerFloat(69, &udpreceiver::m_flags, &FlagsData::setFlag21);
    registerFloat(70, &udpreceiver::m_flags, &FlagsData::setFlag22);
    registerFloat(71, &udpreceiver::m_flags, &FlagsData::setFlag23);
    registerFloat(72, &udpreceiver::m_flags, &FlagsData::setFlag24);
    registerFloat(73, &udpreceiver::m_flags, &FlagsData::setFlag25);

    registerFloat(81, &udpreceiver::m_engine, &EngineData::setflatshiftstate);
    registerFloat(82, &udpreceiver::m_engine, &EngineData::setFuelc);
    registerFloat(83, &udpreceiver::m_engine, &EngineData::setfuelclevel);
    registerFloat(84, &udpreceiver::m_engine, &EngineData::setfuelcomposition);
    registerFloat(85, &udpreceiver::m_engine, &EngineData::setfuelconsrate);
    registerFloat(86, &udpreceiver::m_engine, &EngineData::setfuelcutperc);
    registerFloat(87, &udpreceiver::m_engine, &EngineData::setfuelflow);
    registerFloat(88, &udpreceiver::m_engine, &EngineData::setfuelflowdiff);
    registerFloat(89, &udpreceiver::m_engine, &EngineData::setfuelflowret);
    registerFloat(100, &udpreceiver::m_engine, &EngineData::setFuelPress);
    registerFloat(101, &udpreceiver::m_engine, &EngineData::setFueltemp);
    registerFloat(102, &udpreceiver::m_engine, &EngineData::setfueltrimlongtbank1);
    registerFloat(103, &udpreceiver::m_engine, &EngineData::setfueltrimlongtbank2);
    registerFloat(104, &udpreceiver::m_engine, &EngineData::setfueltrimshorttbank1);
    registerFloat(105, &udpreceiver::m_engine, &EngineData::setfueltrimshorttbank2);
    registerNoopFloat(108);
    registerNoopFloat(109);
    registerNoopFloat(110);
    registerNoopFloat(111);
    registerNoopFloat(112);
    registerFloat(119, &udpreceiver::m_engine, &EngineData::sethomeccounter);
    registerFloat(120, &udpreceiver::m_engine, &EngineData::setIdleValue);
    registerFloat(121, &udpreceiver::m_engine, &EngineData::setIgn);
    registerFloat(122, &udpreceiver::m_engine, &EngineData::setIgn1);
    registerFloat(123, &udpreceiver::m_engine, &EngineData::setIgn2);
    registerFloat(124, &udpreceiver::m_engine, &EngineData::setIgn3);
    registerFloat(125, &udpreceiver::m_engine, &EngineData::setIgn4);
    registerFloat(126, &udpreceiver::m_engine, &EngineData::setincamangle1);
    registerFloat(127, &udpreceiver::m_engine, &EngineData::setincamangle2);
    registerFloat(128, &udpreceiver::m_engine, &EngineData::setInj);
    registerFloat(129, &udpreceiver::m_engine, &EngineData::setInj1);
    registerFloat(130, &udpreceiver::m_engine, &EngineData::setInj2);
    registerFloat(131, &udpreceiver::m_engine, &EngineData::setInj3);
    registerFloat(132, &udpreceiver::m_engine, &EngineData::setInj4);
    registerFloat(133, &udpreceiver::m_engine, &EngineData::setInjDuty);
    registerFloat(134, &udpreceiver::m_engine, &EngineData::setinjms);
    registerFloat(135, &udpreceiver::m_engine, &EngineData::setIntaketemp);
    registerFloat(136, &udpreceiver::m_engine, &EngineData::setIscvduty);
    registerFloat(137, &udpreceiver::m_engine, &EngineData::setKnock);
    registerFloat(138, &udpreceiver::m_engine, &EngineData::setknocklevlogged1);
    registerFloat(139, &udpreceiver::m_engine, &EngineData::setknocklevlogged2);
    registerFloat(140, &udpreceiver::m_engine, &EngineData::setknockretardbank1);
    registerFloat(141, &udpreceiver::m_engine, &EngineData::setknockretardbank2);
    registerFloat(142, &udpreceiver::m_engine, &EngineData::setLAMBDA);
    registerFloat(143, &udpreceiver::m_engine, &EngineData::setlambda2);
    registerFloat(144, &udpreceiver::m_engine, &EngineData::setlambda3);
    registerFloat(145, &udpreceiver::m_engine, &EngineData::setlambda4);
    registerFloat(146, &udpreceiver::m_engine, &EngineData::setLAMBDATarget);
    registerFloat(147, &udpreceiver::m_engine, &EngineData::setlaunchcontolfuelenrich);
    registerFloat(148, &udpreceiver::m_engine, &EngineData::setlaunchctrolignretard);
    registerFloat(149, &udpreceiver::m_engine, &EngineData::setLeadingign);
    registerFloat(151, &udpreceiver::m_engine, &EngineData::setlimpmode);
    registerFloat(152, &udpreceiver::m_engine, &EngineData::setMAF1V);
    registerFloat(153, &udpreceiver::m_engine, &EngineData::setMAF2V);
    registerFloat(154, &udpreceiver::m_engine, &EngineData::setMAFactivity);
    registerFloat(155, &udpreceiver::m_engine, &EngineData::setMAP);
    registerFloat(156, &udpreceiver::m_engine, &EngineData::setMAP2);
    registerFloat(157, &udpreceiver::m_engine, &EngineData::setmil);
    registerFloat(158, &udpreceiver::m_engine, &EngineData::setmissccount);
    registerFloat(159, &udpreceiver::m_engine, &EngineData::setMoilp);
    registerFloat(161, &udpreceiver::m_engine, &EngineData::setna1);
    registerFloat(162, &udpreceiver::m_engine, &EngineData::setna2);
    registerFloat(163, &udpreceiver::m_engine, &EngineData::setnosactive);
    registerFloat(164, &udpreceiver::m_engine, &EngineData::setnospress);
    registerFloat(165, &udpreceiver::m_engine, &EngineData::setnosswitch);
    registerFloat(166, &udpreceiver::m_engine, &EngineData::setO2volt);
    registerFloat(167, &udpreceiver::m_engine, &EngineData::setO2volt_2);
    registerFloat(169, &udpreceiver::m_engine, &EngineData::setoilpres);
    registerFloat(170, &udpreceiver::m_engine, &EngineData::setoiltemp);
    registerFloat(171, &udpreceiver::m_engine, &EngineData::setpim);
    registerFloat(173, &udpreceiver::m_engine, &EngineData::setPower);
    registerFloat(174, &udpreceiver::m_engine, &EngineData::setPressureV);
    registerFloat(175, &udpreceiver::m_engine, &EngineData::setPrimaryinp);
    registerFloat(176, &udpreceiver::m_engine, &EngineData::setrallyantilagswitch);
    registerFloat(179, &udpreceiver::m_engine, &EngineData::setrpm);
    registerFloat(181, &udpreceiver::m_engine, &EngineData::setSecinjpulse);

    // Analog inputs and user channels
    registerFloat(182, &udpreceiver::m_analog, &AnalogInputs::setsens1);
    registerFloat(183, &udpreceiver::m_analog, &AnalogInputs::setsens2);
    registerFloat(184, &udpreceiver::m_analog, &AnalogInputs::setsens3);
    registerFloat(185, &udpreceiver::m_analog, &AnalogInputs::setsens4);
    registerFloat(186, &udpreceiver::m_analog, &AnalogInputs::setsens5);
    registerFloat(187, &udpreceiver::m_analog, &AnalogInputs::setsens6);
    registerFloat(188, &udpreceiver::m_analog, &AnalogInputs::setsens7);
    registerFloat(189, &udpreceiver::m_analog, &AnalogInputs::setsens8);
    registerFloat(190, &udpreceiver::m_engine, &EngineData::setgenericoutput1);
    registerFloat(201, &udpreceiver::m_engine, &EngineData::settargetbstlelkpa);
    registerFloat(202, &udpreceiver::m_engine, &EngineData::setThrottleV);
    registerFloat(203, &udpreceiver::m_engine, &EngineData::settimeddutyout1);
    registerFloat(204, &udpreceiver::m_engine, &EngineData::settimeddutyout2);
    registerFloat(205, &udpreceiver::m_engine, &EngineData::settimeddutyoutputactive);
    registerFloat(207, &udpreceiver::m_engine, &EngineData::setTorque);
    registerFloat(208, &udpreceiver::m_engine, &EngineData::settorqueredcutactive);
    registerFloat(209, &udpreceiver::m_engine, &EngineData::settorqueredlevelactive);
    registerFloat(210, &udpreceiver::m_engine, &EngineData::setTPS);
    registerFloat(211, &udpreceiver::m_engine, &EngineData::setTrailingign);
    registerFloat(212, &udpreceiver::m_engine, &EngineData::settransientthroactive);
    registerFloat(213, &udpreceiver::m_engine, &EngineData::settransoiltemp);
    registerFloat(214, &udpreceiver::m_engine, &EngineData::settriggerccounter);
    registerFloat(215, &udpreceiver::m_engine, &EngineData::settriggersrsinceasthome);
    registerFloat(216, &udpreceiver::m_engine, &EngineData::setTRIM);
    registerFloat(218, &udpreceiver::m_engine, &EngineData::setturborpm);
    registerInt(219, &udpreceiver::m_connection, &ConnectionData::setecu);
    registerFloat(220, &udpreceiver::m_engine, &EngineData::setwastegatepress);
    registerFloat(221, &udpreceiver::m_engine, &EngineData::setWatertemp);
    registerFloat(228, &udpreceiver::m_engine, &EngineData::setBatteryV);
    registerFloat(229, &udpreceiver::m_engine, &EngineData::setIntakepress);
    registerFloat(260, &udpreceiver::m_analog, &AnalogInputs::setAnalog0);
    registerFloat(261, &udpreceiver::m_analog, &AnalogInputs::setAnalog1);
    registerFloat(262, &udpreceiver::m_analog, &AnalogInputs::setAnalog2);
    registerFloat(263, &udpreceiver::m_analog, &AnalogInputs::setAnalog3);
    registerFloat(264, &udpreceiver::m_analog, &AnalogInputs::setAnalog4);
    registerFloat(265, &udpreceiver::m_analog, &AnalogInputs::setAnalog5);
    registerFloat(266, &udpreceiver::m_analog, &AnalogInputs::setAnalog6);
    registerFloat(267, &udpreceiver::m_analog, &AnalogInputs::setAnalog7);
    registerFloat(268, &udpreceiver::m_analog, &AnalogInputs::setAnalog8);
    registerFloat(269, &udpreceiver::m_analog, &AnalogInputs::setAnalog9);
    registerFloat(270, &udpreceiver::m_analog, &AnalogInputs::setAnalog10);
    registerFloat(271, &udpreceiver::m_engine, &EngineData::setGearOilPress);
    registerFloat(275, &udpreceiver::m_engine, &EngineData::setInjDuty2);
    registerFloat(276, &udpreceiver::m_engine, &EngineData::setInjAngle);
    registerFloat(278, &udpreceiver::m_engine, &EngineData::setBoostPreskpa);
    registerFloat(279, &udpreceiver::m_digital, &DigitalInputs::setDigitalInput1);
    registerFloat(280, &udpreceiver::m_digital, &DigitalInputs::setDigitalInput2);
    registerFloat(281, &udpreceiver::m_digital, &DigitalInputs::setDigitalInput3);
    registerFloat(282, &udpreceiver::m_digital, &DigitalInputs::setDigitalInput4);
    registerFloat(283, &udpreceiver::m_digital, &DigitalInputs::setDigitalInput5);
    registerFloat(284, &udpreceiver::m_digital, &DigitalInputs::setDigitalInput6);
    registerFloat(285, &udpreceiver::m_digital, &DigitalInputs::setDigitalInput7);
    registerFloat(286, &udpreceiver::m_analog, &AnalogInputs::setUserchannel1);
    registerFloat(287, &udpreceiver::m_analog, &AnalogInputs::setUserchannel2);
    registerFloat(288, &udpreceiver::m_analog, &AnalogInputs::setUserchannel3);
    registerFloat(289, &udpreceiver::m_analog, &AnalogInputs::setUserchannel4);
    registerFloat(290, &udpreceiver::m_engine, &EngineData::settractionControl);
    registerFloat(291, &udpreceiver::m_analog, &AnalogInputs::setUserchannel5);
    registerFloat(292, &udpreceiver::m_analog, &AnalogInputs::setUserchannel6);
    registerFloat(293, &udpreceiver::m_analog, &AnalogInputs::setUserchannel7);
    registerFloat(294, &udpreceiver::m_analog, &AnalogInputs::setUserchannel8);
    registerFloat(295, &udpreceiver::m_analog, &AnalogInputs::setUserchannel9);
    registerFloat(296, &udpreceiver::m_analog, &AnalogInputs::setUserchannel10);
    registerFloat(297, &udpreceiver::m_analog, &AnalogInputs::setUserchannel11);
    registerFloat(298, &udpreceiver::m_analog, &AnalogInputs::setUserchannel12);

    // Engine 400 series
    registerFloat(400, &udpreceiver::m_engine, &EngineData::setigncut);
    registerFloat(403, &udpreceiver::m_engine, &EngineData::setdsettargetslip);
    registerFloat(404, &udpreceiver::m_engine, &EngineData::settractionctlpowerlimit);
    registerFloat(405, &udpreceiver::m_engine, &EngineData::setknockallpeak);
    registerFloat(406, &udpreceiver::m_engine, &EngineData::setknockcorr);
    registerFloat(407, &udpreceiver::m_engine, &EngineData::setknocklastcyl);
    registerFloat(408, &udpreceiver::m_engine, &EngineData::settotalfueltrim);
    registerFloat(409, &udpreceiver::m_engine, &EngineData::settotaligncomp);
    registerFloat(410, &udpreceiver::m_engine, &EngineData::setegthighest);
    registerFloat(411, &udpreceiver::m_engine, &EngineData::setcputempecu);
    registerFloat(412, &udpreceiver::m_engine, &EngineData::seterrorcodecount);
    registerFloat(413, &udpreceiver::m_engine, &EngineData::setlostsynccount);
    registerFloat(414, &udpreceiver::m_engine, &EngineData::setegtdiff);
    registerFloat(415, &udpreceiver::m_engine, &EngineData::setactiveboosttable);
    registerFloat(416, &udpreceiver::m_engine, &EngineData::setactivetunetable);

    // String payloads
    registerString(800, &udpreceiver::m_sensor, &SensorData::setSensorString1);
    registerString(801, &udpreceiver::m_sensor, &SensorData::setSensorString2);
    registerString(802, &udpreceiver::m_sensor, &SensorData::setSensorString3);
    registerString(803, &udpreceiver::m_sensor, &SensorData::setSensorString4);
    registerString(804, &udpreceiver::m_sensor, &SensorData::setSensorString5);
    registerString(805, &udpreceiver::m_sensor, &SensorData::setSensorString6);
    registerString(806, &udpreceiver::m_sensor, &SensorData::setSensorString7);
    registerString(807, &udpreceiver::m_sensor, &SensorData::setSensorString8);
    registerString(808, &udpreceiver::m_flags, &FlagsData::setFlagString1);
    registerString(809, &udpreceiver::m_flags, &FlagsData::setFlagString2);
    registerString(810, &udpreceiver::m_flags, &FlagsData::setFlagString3);
    registerString(811, &udpreceiver::m_flags, &FlagsData::setFlagString4);
    registerString(812, &udpreceiver::m_flags, &FlagsData::setFlagString5);
    registerString(813, &udpreceiver::m_flags, &FlagsData::setFlagString6);
    registerString(814, &udpreceiver::m_flags, &FlagsData::setFlagString7);
    registerString(815, &udpreceiver::m_flags, &FlagsData::setFlagString8);
    registerString(816, &udpreceiver::m_flags, &FlagsData::setFlagString9);
    registerString(817, &udpreceiver::m_flags, &FlagsData::setFlagString10);
    registerString(818, &udpreceiver::m_flags, &FlagsData::setFlagString11);
    registerString(819, &udpreceiver::m_flags, &FlagsData::setFlagString12);
    registerString(820, &udpreceiver::m_flags, &FlagsData::setFlagString13);
    registerString(821, &udpreceiver::m_flags, &FlagsData::setFlagString14);
    registerString(822, &udpreceiver::m_flags, &FlagsData::setFlagString15);
    registerString(823, &udpreceiver::m_flags, &FlagsData::setFlagString16);
    registerNoopString(824);
    registerString(825, &udpreceiver::m_connection, &ConnectionData::setError);

    // Remaining engine and motor data
    registerInt(827, &udpreceiver::m_engine, &EngineData::setoilpressurelamp);
    registerInt(828, &udpreceiver::m_engine, &EngineData::setovertempalarm);
    registerInt(829, &udpreceiver::m_engine, &EngineData::setalternatorfail);
    registerFloat(830, &udpreceiver::m_engine, &EngineData::setturborpm2);
    registerInt(831, &udpreceiver::m_engine, &EngineData::setAuxTemp1);
    registerFloat(832, &udpreceiver::m_motor, &ElectricMotorData::setIGBTPhaseATemp);
    registerFloat(833, &udpreceiver::m_motor, &ElectricMotorData::setIGBTPhaseBTemp);
    registerFloat(834, &udpreceiver::m_motor, &ElectricMotorData::setIGBTPhaseCTemp);
    registerFloat(835, &udpreceiver::m_motor, &ElectricMotorData::setGateDriverTemp);
    registerFloat(836, &udpreceiver::m_motor, &ElectricMotorData::setControlBoardTemp);
    registerFloat(837, &udpreceiver::m_motor, &ElectricMotorData::setRtdTemp1);
    registerFloat(838, &udpreceiver::m_motor, &ElectricMotorData::setRtdTemp2);
    registerFloat(839, &udpreceiver::m_motor, &ElectricMotorData::setRtdTemp3);
    registerFloat(840, &udpreceiver::m_motor, &ElectricMotorData::setRtdTemp4);
    registerFloat(841, &udpreceiver::m_motor, &ElectricMotorData::setRtdTemp5);
    registerFloat(842, &udpreceiver::m_motor, &ElectricMotorData::setEMotorTemperature);
    registerFloat(843, &udpreceiver::m_motor, &ElectricMotorData::setTorqueShudder);
    registerFloat(844, &udpreceiver::m_motor, &ElectricMotorData::setDigInput1FowardSw);
    registerFloat(845, &udpreceiver::m_motor, &ElectricMotorData::setDigInput2ReverseSw);
    registerFloat(846, &udpreceiver::m_motor, &ElectricMotorData::setDigInput3BrakeSw);
    registerFloat(847, &udpreceiver::m_motor, &ElectricMotorData::setDigInput4RegenDisableSw);
    registerFloat(848, &udpreceiver::m_motor, &ElectricMotorData::setDigInput5IgnSw);
    registerFloat(849, &udpreceiver::m_motor, &ElectricMotorData::setDigInput6StartSw);
    registerFloat(850, &udpreceiver::m_motor, &ElectricMotorData::setDigInput7Bool);
    registerFloat(851, &udpreceiver::m_motor, &ElectricMotorData::setDigInput8Bool);
    registerFloat(852, &udpreceiver::m_motor, &ElectricMotorData::setEMotorAngle);
    registerFloat(853, &udpreceiver::m_motor, &ElectricMotorData::setEMotorSpeed);
    registerFloat(854, &udpreceiver::m_motor, &ElectricMotorData::setElectricalOutFreq);
    registerFloat(855, &udpreceiver::m_motor, &ElectricMotorData::setDeltaResolverFiltered);
    registerFloat(856, &udpreceiver::m_motor, &ElectricMotorData::setPhaseACurrent);
    registerFloat(857, &udpreceiver::m_motor, &ElectricMotorData::setPhaseBCurrent);
    registerFloat(858, &udpreceiver::m_motor, &ElectricMotorData::setPhaseCCurrent);
    registerFloat(859, &udpreceiver::m_motor, &ElectricMotorData::setDCBusCurrent);
    registerFloat(860, &udpreceiver::m_motor, &ElectricMotorData::setDCBusVoltage);
    registerFloat(861, &udpreceiver::m_motor, &ElectricMotorData::setOutputVoltage);
    registerFloat(862, &udpreceiver::m_motor, &ElectricMotorData::setVABvdVoltage);
    registerFloat(863, &udpreceiver::m_motor, &ElectricMotorData::setVBCvqVoltage);
    registerFloat(900, &udpreceiver::m_digital, &DigitalInputs::setEXDigitalInput1);
    registerFloat(901, &udpreceiver::m_digital, &DigitalInputs::setEXDigitalInput2);
    registerFloat(902, &udpreceiver::m_digital, &DigitalInputs::setEXDigitalInput3);
    registerFloat(903, &udpreceiver::m_digital, &DigitalInputs::setEXDigitalInput4);
    registerFloat(904, &udpreceiver::m_digital, &DigitalInputs::setEXDigitalInput5);
    registerFloat(905, &udpreceiver::m_digital, &DigitalInputs::setEXDigitalInput6);
    registerFloat(906, &udpreceiver::m_digital, &DigitalInputs::setEXDigitalInput7);
    registerFloat(907, &udpreceiver::m_digital, &DigitalInputs::setEXDigitalInput8);
    registerScaledFloat(908, &udpreceiver::m_expander, &ExpanderBoardData::setEXAnalogInput0, 1000.0f);
    registerScaledFloat(909, &udpreceiver::m_expander, &ExpanderBoardData::setEXAnalogInput1, 1000.0f);
    registerScaledFloat(910, &udpreceiver::m_expander, &ExpanderBoardData::setEXAnalogInput2, 1000.0f);
    registerScaledFloat(911, &udpreceiver::m_expander, &ExpanderBoardData::setEXAnalogInput3, 1000.0f);
    registerScaledFloat(912, &udpreceiver::m_expander, &ExpanderBoardData::setEXAnalogInput4, 1000.0f);
    registerScaledFloat(913, &udpreceiver::m_expander, &ExpanderBoardData::setEXAnalogInput5, 1000.0f);
    registerScaledFloat(914, &udpreceiver::m_expander, &ExpanderBoardData::setEXAnalogInput6, 1000.0f);
    registerScaledFloat(915, &udpreceiver::m_expander, &ExpanderBoardData::setEXAnalogInput7, 1000.0f);
    registerFloat(916, &udpreceiver::m_engine, &EngineData::setAFRcyl1);
    registerFloat(917, &udpreceiver::m_engine, &EngineData::setAFRcyl2);
    registerFloat(918, &udpreceiver::m_engine, &EngineData::setAFRcyl3);
    registerFloat(919, &udpreceiver::m_engine, &EngineData::setAFRcyl4);
    registerFloat(920, &udpreceiver::m_engine, &EngineData::setAFRcyl5);
    registerFloat(921, &udpreceiver::m_engine, &EngineData::setAFRcyl6);
    registerFloat(922, &udpreceiver::m_engine, &EngineData::setAFRcyl7);
    registerFloat(923, &udpreceiver::m_engine, &EngineData::setAFRcyl8);
    registerFloat(925, &udpreceiver::m_engine, &EngineData::setAFRLEFTBANKTARGET);
    registerFloat(926, &udpreceiver::m_engine, &EngineData::setAFRRIGHTBANKTARGET);
    registerFloat(927, &udpreceiver::m_engine, &EngineData::setAFRLEFTBANKACTUAL);
    registerFloat(928, &udpreceiver::m_engine, &EngineData::setAFRRIGHTBANKACTUAL);
    registerFloat(929, &udpreceiver::m_engine, &EngineData::setBOOSTOFFSET);
    registerFloat(930, &udpreceiver::m_engine, &EngineData::setREVLIM3STEP);
    registerFloat(931, &udpreceiver::m_engine, &EngineData::setREVLIM2STEP);
    registerFloat(932, &udpreceiver::m_engine, &EngineData::setREVLIMGIGHSIDE);
    registerFloat(933, &udpreceiver::m_engine, &EngineData::setREVLIMBOURNOUT);
    registerFloat(934, &udpreceiver::m_engine, &EngineData::setLEFTBANKO2CORR);
    registerFloat(935, &udpreceiver::m_engine, &EngineData::setRIGHTBANKO2CORR);
    registerFloat(936, &udpreceiver::m_engine, &EngineData::setTRACTIONCTRLOFFSET);
    registerFloat(937, &udpreceiver::m_engine, &EngineData::setDRIVESHAFTOFFSET);
    registerFloat(938, &udpreceiver::m_engine, &EngineData::setTCCOMMAND);
    registerFloat(939, &udpreceiver::m_engine, &EngineData::setFSLCOMMAND);
    registerFloat(940, &udpreceiver::m_engine, &EngineData::setFSLINDEX);
    registerFloat(941, &udpreceiver::m_engine, &EngineData::setPANVAC);
    registerFloat(942, &udpreceiver::m_engine, &EngineData::setCyl1_O2_Corr);
    registerFloat(943, &udpreceiver::m_engine, &EngineData::setCyl2_O2_Corr);
    registerFloat(944, &udpreceiver::m_engine, &EngineData::setCyl3_O2_Corr);
    registerFloat(945, &udpreceiver::m_engine, &EngineData::setCyl4_O2_Corr);
    registerFloat(946, &udpreceiver::m_engine, &EngineData::setCyl5_O2_Corr);
    registerFloat(947, &udpreceiver::m_engine, &EngineData::setCyl6_O2_Corr);
    registerFloat(948, &udpreceiver::m_engine, &EngineData::setCyl7_O2_Corr);
    registerFloat(949, &udpreceiver::m_engine, &EngineData::setCyl8_O2_Corr);
    registerInt(950, &udpreceiver::m_engine, &EngineData::setRotaryTrimpot1);
    registerInt(951, &udpreceiver::m_engine, &EngineData::setRotaryTrimpot2);
    registerInt(952, &udpreceiver::m_engine, &EngineData::setRotaryTrimpot3);
    registerInt(953, &udpreceiver::m_engine, &EngineData::setCalibrationSelect);
    registerFloat(999, &udpreceiver::m_digital, &DigitalInputs::setfrequencyDIEX1);
}

void udpreceiver::startreceiver()
{
    if (udpSocket) {
        udpSocket->close();
        udpSocket->deleteLater();
        udpSocket = nullptr;
    }
    udpSocket = new QUdpSocket(this);
    udpSocket->bind(45454, QUdpSocket::ShareAddress);
    connect(udpSocket, &QUdpSocket::readyRead, this, &udpreceiver::processPendingDatagrams);
}

void udpreceiver::closeConnection()
{
    if (udpSocket) {
        udpSocket->close();
        udpSocket->deleteLater();
        udpSocket = nullptr;
    }
}

void udpreceiver::processPendingDatagrams()
{
    QByteArray datagram;

    while (udpSocket->hasPendingDatagrams()) {
        datagram.resize(int(udpSocket->pendingDatagramSize()));
        udpSocket->readDatagram(datagram.data(), datagram.size());

        QString raw = datagram.data();

        if (raw.isEmpty() || !raw.contains(","))
            continue;

        QStringList list = raw.split(",");
        if (list.size() < 2)
            continue;
        const int ident = list[0].toInt();
        const QString &rawValue = list[1];
        const float value = rawValue.toFloat();

        const auto stringHandler = m_stringDispatchTable.constFind(ident);
        if (stringHandler != m_stringDispatchTable.constEnd()) {
            stringHandler.value()(rawValue);
        } else {
            const auto floatHandler = m_floatDispatchTable.constFind(ident);
            if (floatHandler != m_floatDispatchTable.constEnd())
                floatHandler.value()(value);
        }

        if (m_sensorRegistry) {
            auto it = s_identToSensorKey.constFind(ident);
            if (it != s_identToSensorKey.constEnd())
                m_sensorRegistry->markCanSensorActive(it.value());
        }
    }
}
