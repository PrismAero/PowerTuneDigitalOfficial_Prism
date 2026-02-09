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

#include <QDataStream>
#include <QHostAddress>
#include <QUdpSocket>

udpreceiver::udpreceiver(QObject *parent)
    : QObject(parent)
    , m_engine(nullptr)
    , m_vehicle(nullptr)
    , m_gps(nullptr)
    , m_analog(nullptr)
    , m_digital(nullptr)
    , m_expander(nullptr)
    , m_motor(nullptr)
    , m_flags(nullptr)
    , m_sensor(nullptr)
    , m_connection(nullptr)
    , m_settings(nullptr)
{
}

udpreceiver::udpreceiver(
    EngineData *engine,
    VehicleData *vehicle,
    GPSData *gps,
    AnalogInputs *analog,
    DigitalInputs *digital,
    ExpanderBoardData *expander,
    ElectricMotorData *motor,
    FlagsData *flags,
    SensorData *sensor,
    ConnectionData *connection,
    SettingsData *settings,
    QObject *parent)
    : QObject(parent)
    , m_engine(engine)
    , m_vehicle(vehicle)
    , m_gps(gps)
    , m_analog(analog)
    , m_digital(digital)
    , m_expander(expander)
    , m_motor(motor)
    , m_flags(flags)
    , m_sensor(sensor)
    , m_connection(connection)
    , m_settings(settings)
{
}

void udpreceiver::startreceiver()
{
    udpSocket = new QUdpSocket(this);
    udpSocket->bind(45454, QUdpSocket::ShareAddress);
    connect(udpSocket, &QUdpSocket::readyRead, this, &udpreceiver::processPendingDatagrams);
}

void udpreceiver::closeConnection()
{
    // TODO: Implement proper cleanup if needed
}

void udpreceiver::processPendingDatagrams()
{
    QByteArray datagram;

    while (udpSocket->hasPendingDatagrams()) {
        datagram.resize(int(udpSocket->pendingDatagramSize()));
        udpSocket->readDatagram(datagram.data(), datagram.size());

        QDataStream in(&datagram, QIODevice::ReadOnly);
        QString raw = datagram.data();

        if (raw.isEmpty()) {
            raw = "0,0";
        }
        if (!raw.contains(",")) {
            raw = "0,0";
        }

        QStringList list = raw.split(",");
        int ident = list[0].toInt();
        float Value = list[1].toFloat();

        switch (ident) {
        // * ==================== VEHICLE DATA (1-5, 27-28, 32, 106-107, 113-119, 150, 160, 168, 178, 194, 199-200, 217, 222-227, 401-402, 826, 864-871) ====================
        case 1:
            if (m_vehicle) m_vehicle->setaccelpedpos(Value);
            break;
        case 2:
            if (m_vehicle) m_vehicle->setAccelTimer(Value);
            break;
        case 3:
            if (m_vehicle) m_vehicle->setaccelx(Value);
            break;
        case 4:
            if (m_vehicle) m_vehicle->setaccely(Value);
            break;
        case 5:
            if (m_vehicle) m_vehicle->setaccelz(Value);
            break;
        case 27:
            if (m_vehicle) m_vehicle->setclutchswitchstate(Value);
            break;
        case 28:
            if (m_vehicle) m_vehicle->setcompass(Value);
            break;
        case 32:
            if (m_vehicle) m_vehicle->setdistancetoempty(Value);
            break;
        case 106:
            if (m_vehicle) m_vehicle->setGear(Value);
            break;
        case 107:
            if (m_vehicle) m_vehicle->setgearswitch(Value);
            break;
        case 113:
            if (m_vehicle) m_vehicle->setlowBeam(Value);
            break;
        case 114:
            if (m_vehicle) m_vehicle->setgyrox(Value);
            break;
        case 115:
            if (m_vehicle) m_vehicle->setgyroy(Value);
            break;
        case 116:
            if (m_vehicle) m_vehicle->setgyroz(Value);
            break;
        case 117:
            if (m_vehicle) m_vehicle->sethandbrake(Value);
            break;
        case 118:
            if (m_vehicle) m_vehicle->sethighbeam(Value);
            break;
        case 150:
            if (m_vehicle) m_vehicle->setleftindicator(Value);
            break;
        case 160:
            if (m_vehicle) m_vehicle->setMVSS(Value);
            break;
        case 168:
            if (m_vehicle) m_vehicle->setOdo(Value);
            break;
        case 178:
            if (m_vehicle) m_vehicle->setrightindicator(Value);
            break;
        case 191:
            if (m_vehicle) m_vehicle->setFuelLevel(Value);
            break;
        case 194:
            if (m_vehicle) m_vehicle->setSteeringWheelAngle(Value);
            break;
        case 199:
            // ! Speed has conditional logic based on ExternalSpeed setting
            if (m_settings && m_settings->ExternalSpeed() == 0) {
                if (m_vehicle) m_vehicle->setSpeed(Value);
            }
            break;
        case 200:
            if (m_vehicle) m_vehicle->setSVSS(Value);
            break;
        case 217:
            if (m_vehicle) m_vehicle->setTrip(Value);
            break;
        case 222:
            if (m_vehicle) m_vehicle->setwheeldiff(Value);
            break;
        case 223:
            if (m_vehicle) m_vehicle->setwheelslip(Value);
            break;
        case 224:
            if (m_vehicle) m_vehicle->setwheelspdftleft(Value);
            break;
        case 225:
            if (m_vehicle) m_vehicle->setwheelspdftright(Value);
            break;
        case 226:
            if (m_vehicle) m_vehicle->setwheelspdrearleft(Value);
            break;
        case 227:
            if (m_vehicle) m_vehicle->setwheelspdrearright(Value);
            break;
        case 401:
            if (m_vehicle) m_vehicle->setundrivenavgspeed(Value);
            break;
        case 402:
            if (m_vehicle) m_vehicle->setdrivenavgspeed(Value);
            break;
        case 826:
            if (m_vehicle) m_vehicle->setautogear(list[1]);
            break;
        case 864:
            if (m_vehicle) m_vehicle->setTiretempLF(Value);
            break;
        case 865:
            if (m_vehicle) m_vehicle->setTiretempRF(Value);
            break;
        case 866:
            if (m_vehicle) m_vehicle->setTiretempLR(Value);
            break;
        case 867:
            if (m_vehicle) m_vehicle->setTiretempRR(Value);
            break;
        case 868:
            if (m_vehicle) m_vehicle->setTirepresLF(Value);
            break;
        case 869:
            if (m_vehicle) m_vehicle->setTirepresRF(Value);
            break;
        case 870:
            if (m_vehicle) m_vehicle->setTirepresLR(Value);
            break;
        case 871:
            if (m_vehicle) m_vehicle->setTirepresRR(Value);
            break;

        // * ==================== ENGINE DATA ====================
        case 6:
            if (m_engine) m_engine->setAFR(Value);
            break;
        case 7:
            if (m_engine) m_engine->setairtempensor2(Value);
            break;
        case 8:
            if (m_vehicle) m_vehicle->setambipress(Value);
            break;
        case 9:
            if (m_vehicle) m_vehicle->setambitemp(Value);
            break;
        case 10:
            if (m_engine) m_engine->setantilaglauchswitch(Value);
            break;
        case 11:
            if (m_engine) m_engine->setantilaglaunchon(Value);
            break;
        case 12:
            if (m_analog) m_analog->setauxcalc1(Value);
            break;
        case 13:
            if (m_analog) m_analog->setauxcalc2(Value);
            break;
        case 14:
            if (m_analog) m_analog->setauxcalc3(Value);
            break;
        case 15:
            if (m_analog) m_analog->setauxcalc4(Value);
            break;
        case 16:
            if (m_engine) m_engine->setauxrevlimitswitch(Value);
            break;
        case 17:
            if (m_engine) m_engine->setAUXT(Value);
            break;
        case 18:
            if (m_engine) m_engine->setavfueleconomy(Value);
            break;
        case 19:
            if (m_engine) m_engine->setbattlight(Value);
            break;
        case 20:
            if (m_engine) m_engine->setboostcontrol(Value);
            break;
        case 21:
            if (m_engine) m_engine->setBoostDuty(Value);
            break;
        case 22:
            if (m_engine) m_engine->setBoostPres(Value);
            break;
        case 23:
            if (m_engine) m_engine->setBoosttp(Value);
            break;
        case 24:
            if (m_engine) m_engine->setBoostwg(Value);
            break;
        case 25:
            // ! Brake pedal state - currently not implemented
            break;
        case 26:
            if (m_engine) m_engine->setbrakepress(Value);
            break;
        case 29:
            if (m_engine) m_engine->setcoolantpress(Value);
            break;
        case 30:
            if (m_engine) m_engine->setdecelcut(Value);
            break;
        case 31:
            if (m_engine) m_engine->setdiffoiltemp(Value);
            break;
        case 33:
            if (m_engine) m_engine->setDwell(Value);
            break;
        case 34:
            if (m_engine) m_engine->setegt1(Value);
            break;
        case 35:
            if (m_engine) m_engine->setegt2(Value);
            break;
        case 36:
            if (m_engine) m_engine->setegt3(Value);
            break;
        case 37:
            if (m_engine) m_engine->setegt4(Value);
            break;
        case 38:
            if (m_engine) m_engine->setegt5(Value);
            break;
        case 39:
            if (m_engine) m_engine->setegt6(Value);
            break;
        case 40:
            if (m_engine) m_engine->setegt7(Value);
            break;
        case 41:
            if (m_engine) m_engine->setegt8(Value);
            break;
        case 42:
            if (m_engine) m_engine->setegt9(Value);
            break;
        case 43:
            if (m_engine) m_engine->setegt10(Value);
            break;
        case 44:
            if (m_engine) m_engine->setegt11(Value);
            break;
        case 45:
            if (m_engine) m_engine->setegt12(Value);
            break;
        case 46:
            if (m_engine) m_engine->setEngLoad(Value);
            break;
        case 47:
            if (m_engine) m_engine->setexcamangle1(Value);
            break;
        case 48:
            if (m_engine) m_engine->setexcamangle2(Value);
            break;

        // * ==================== FLAGS DATA (49-73) ====================
        case 49:
            if (m_flags) m_flags->setFlag1(Value);
            break;
        case 50:
            if (m_flags) m_flags->setFlag2(Value);
            break;
        case 51:
            if (m_flags) m_flags->setFlag3(Value);
            break;
        case 52:
            if (m_flags) m_flags->setFlag4(Value);
            break;
        case 53:
            if (m_flags) m_flags->setFlag5(Value);
            break;
        case 54:
            if (m_flags) m_flags->setFlag6(Value);
            break;
        case 55:
            if (m_flags) m_flags->setFlag7(Value);
            break;
        case 56:
            if (m_flags) m_flags->setFlag8(Value);
            break;
        case 57:
            if (m_flags) m_flags->setFlag9(Value);
            break;
        case 58:
            if (m_flags) m_flags->setFlag10(Value);
            break;
        case 59:
            if (m_flags) m_flags->setFlag11(Value);
            break;
        case 60:
            if (m_flags) m_flags->setFlag12(Value);
            break;
        case 61:
            if (m_flags) m_flags->setFlag13(Value);
            break;
        case 62:
            if (m_flags) m_flags->setFlag14(Value);
            break;
        case 63:
            if (m_flags) m_flags->setFlag15(Value);
            break;
        case 64:
            if (m_flags) m_flags->setFlag16(Value);
            break;
        case 65:
            if (m_flags) m_flags->setFlag17(Value);
            break;
        case 66:
            if (m_flags) m_flags->setFlag18(Value);
            break;
        case 67:
            if (m_flags) m_flags->setFlag19(Value);
            break;
        case 68:
            if (m_flags) m_flags->setFlag20(Value);
            break;
        case 69:
            if (m_flags) m_flags->setFlag21(Value);
            break;
        case 70:
            if (m_flags) m_flags->setFlag22(Value);
            break;
        case 71:
            if (m_flags) m_flags->setFlag23(Value);
            break;
        case 72:
            if (m_flags) m_flags->setFlag24(Value);
            break;
        case 73:
            if (m_flags) m_flags->setFlag25(Value);
            break;

        // * ==================== RESERVED/UNIMPLEMENTED (74-80) ====================
        case 74:
        case 75:
        case 76:
        case 77:
        case 78:
        case 79:
        case 80:
            // ! Ignition Angle / Torque Management - not yet implemented
            break;

        // * ==================== ENGINE DATA CONTINUED ====================
        case 81:
            if (m_engine) m_engine->setflatshiftstate(Value);
            break;
        case 82:
            if (m_engine) m_engine->setFuelc(Value);
            break;
        case 83:
            if (m_engine) m_engine->setfuelclevel(Value);
            break;
        case 84:
            if (m_engine) m_engine->setfuelcomposition(Value);
            break;
        case 85:
            if (m_engine) m_engine->setfuelconsrate(Value);
            break;
        case 86:
            if (m_engine) m_engine->setfuelcutperc(Value);
            break;
        case 87:
            if (m_engine) m_engine->setfuelflow(Value);
            break;
        case 88:
            if (m_engine) m_engine->setfuelflowdiff(Value);
            break;
        case 89:
            if (m_engine) m_engine->setfuelflowret(Value);
            break;
        case 100:
            if (m_engine) m_engine->setFuelPress(Value);
            break;
        case 101:
            if (m_engine) m_engine->setFueltemp(Value);
            break;
        case 102:
            if (m_engine) m_engine->setfueltrimlongtbank1(Value);
            break;
        case 103:
            if (m_engine) m_engine->setfueltrimlongtbank2(Value);
            break;
        case 104:
            if (m_engine) m_engine->setfueltrimshorttbank1(Value);
            break;
        case 105:
            if (m_engine) m_engine->setfueltrimshorttbank2(Value);
            break;

        // * ==================== GPS DATA (108-112) ====================
        case 108:
            // ! GPS Altitude - commented out in original
            break;
        case 109:
            // ! GPS Latitude - commented out in original
            break;
        case 110:
            // ! GPS Longitude - commented out in original
            break;
        case 111:
            if (m_gps) m_gps->setgpsSpeed(Value);
            break;
        case 112:
            // ! GPS Time - commented out in original
            break;

        // * ==================== ENGINE DATA CONTINUED ====================
        case 119:
            if (m_engine) m_engine->sethomeccounter(Value);
            break;
        case 120:
            if (m_engine) m_engine->setIdleValue(Value);
            break;
        case 121:
            if (m_engine) m_engine->setIgn(Value);
            break;
        case 122:
            if (m_engine) m_engine->setIgn1(Value);
            break;
        case 123:
            if (m_engine) m_engine->setIgn2(Value);
            break;
        case 124:
            if (m_engine) m_engine->setIgn3(Value);
            break;
        case 125:
            if (m_engine) m_engine->setIgn4(Value);
            break;
        case 126:
            if (m_engine) m_engine->setincamangle1(Value);
            break;
        case 127:
            if (m_engine) m_engine->setincamangle2(Value);
            break;
        case 128:
            if (m_engine) m_engine->setInj(Value);
            break;
        case 129:
            if (m_engine) m_engine->setInj1(Value);
            break;
        case 130:
            if (m_engine) m_engine->setInj2(Value);
            break;
        case 131:
            if (m_engine) m_engine->setInj3(Value);
            break;
        case 132:
            if (m_engine) m_engine->setInj4(Value);
            break;
        case 133:
            if (m_engine) m_engine->setInjDuty(Value);
            break;
        case 134:
            if (m_engine) m_engine->setinjms(Value);
            break;
        case 135:
            if (m_engine) m_engine->setIntaketemp(Value);
            break;
        case 136:
            if (m_engine) m_engine->setIscvduty(Value);
            break;
        case 137:
            if (m_engine) m_engine->setKnock(Value);
            break;
        case 138:
            if (m_engine) m_engine->setknocklevlogged1(Value);
            break;
        case 139:
            if (m_engine) m_engine->setknocklevlogged2(Value);
            break;
        case 140:
            if (m_engine) m_engine->setknockretardbank1(Value);
            break;
        case 141:
            if (m_engine) m_engine->setknockretardbank2(Value);
            break;
        case 142:
            if (m_engine) m_engine->setLAMBDA(Value);
            break;
        case 143:
            if (m_engine) m_engine->setlambda2(Value);
            break;
        case 144:
            if (m_engine) m_engine->setlambda3(Value);
            break;
        case 145:
            if (m_engine) m_engine->setlambda4(Value);
            break;
        case 146:
            if (m_engine) m_engine->setLAMBDATarget(Value);
            break;
        case 147:
            if (m_engine) m_engine->setlaunchcontolfuelenrich(Value);
            break;
        case 148:
            if (m_engine) m_engine->setlaunchctrolignretard(Value);
            break;
        case 149:
            if (m_engine) m_engine->setLeadingign(Value);
            break;
        case 151:
            if (m_engine) m_engine->setlimpmode(Value);
            break;
        case 152:
            if (m_engine) m_engine->setMAF1V(Value);
            break;
        case 153:
            if (m_engine) m_engine->setMAF2V(Value);
            break;
        case 154:
            if (m_engine) m_engine->setMAFactivity(Value);
            break;
        case 155:
            if (m_engine) m_engine->setMAP(Value);
            break;
        case 156:
            if (m_engine) m_engine->setMAP2(Value);
            break;
        case 157:
            if (m_engine) m_engine->setmil(Value);
            break;
        case 158:
            if (m_engine) m_engine->setmissccount(Value);
            break;
        case 159:
            if (m_engine) m_engine->setMoilp(Value);
            break;
        case 161:
            if (m_engine) m_engine->setna1(Value);
            break;
        case 162:
            if (m_engine) m_engine->setna2(Value);
            break;
        case 163:
            if (m_engine) m_engine->setnosactive(Value);
            break;
        case 164:
            if (m_engine) m_engine->setnospress(Value);
            break;
        case 165:
            if (m_engine) m_engine->setnosswitch(Value);
            break;
        case 166:
            if (m_engine) m_engine->setO2volt(Value);
            break;
        case 167:
            if (m_engine) m_engine->setO2volt_2(Value);
            break;
        case 169:
            if (m_engine) m_engine->setoilpres(Value);
            break;
        case 170:
            if (m_engine) m_engine->setoiltemp(Value);
            break;
        case 171:
            if (m_engine) m_engine->setpim(Value);
            break;
        case 172:
            // ! Platform - commented out in original
            break;
        case 173:
            if (m_engine) m_engine->setPower(Value);
            break;
        case 174:
            if (m_engine) m_engine->setPressureV(Value);
            break;
        case 175:
            if (m_engine) m_engine->setPrimaryinp(Value);
            break;
        case 176:
            if (m_engine) m_engine->setrallyantilagswitch(Value);
            break;
        case 177:
            // ! RecvData - commented out in original
            break;
        case 179:
            if (m_engine) m_engine->setrpm(Value);
            break;
        case 180:
            // ! RunStat - commented out in original
            break;
        case 181:
            if (m_engine) m_engine->setSecinjpulse(Value);
            break;

        // * ==================== ANALOG INPUTS / SENSOR DATA (182-189) ====================
        case 182:
            if (m_analog) m_analog->setsens1(Value);
            break;
        case 183:
            if (m_analog) m_analog->setsens2(Value);
            break;
        case 184:
            if (m_analog) m_analog->setsens3(Value);
            break;
        case 185:
            if (m_analog) m_analog->setsens4(Value);
            break;
        case 186:
            if (m_analog) m_analog->setsens5(Value);
            break;
        case 187:
            if (m_analog) m_analog->setsens6(Value);
            break;
        case 188:
            if (m_analog) m_analog->setsens7(Value);
            break;
        case 189:
            if (m_analog) m_analog->setsens8(Value);
            break;

        // * ==================== ENGINE DATA CONTINUED ====================
        case 190:
            if (m_engine) m_engine->setgenericoutput1(Value);
            break;
        case 192:
        case 193:
            // ! Turbo Timer - not yet implemented
            break;
        case 195:
            // ! Driveshaft RPM - not yet implemented
            break;
        case 196:
        case 197:
        case 198:
            // ! NOS Pressure Sensors 2-4 - not yet implemented
            break;
        case 201:
            if (m_engine) m_engine->settargetbstlelkpa(Value);
            break;
        case 202:
            if (m_engine) m_engine->setThrottleV(Value);
            break;
        case 203:
            if (m_engine) m_engine->settimeddutyout1(Value);
            break;
        case 204:
            if (m_engine) m_engine->settimeddutyout2(Value);
            break;
        case 205:
            if (m_engine) m_engine->settimeddutyoutputactive(Value);
            break;
        case 206:
            // ! TimeoutStat - commented out in original
            break;
        case 207:
            if (m_engine) m_engine->setTorque(Value);
            break;
        case 208:
            if (m_engine) m_engine->settorqueredcutactive(Value);
            break;
        case 209:
            if (m_engine) m_engine->settorqueredlevelactive(Value);
            break;
        case 210:
            if (m_engine) m_engine->setTPS(Value);
            break;
        case 211:
            if (m_engine) m_engine->setTrailingign(Value);
            break;
        case 212:
            if (m_engine) m_engine->settransientthroactive(Value);
            break;
        case 213:
            if (m_engine) m_engine->settransoiltemp(Value);
            break;
        case 214:
            if (m_engine) m_engine->settriggerccounter(Value);
            break;
        case 215:
            if (m_engine) m_engine->settriggersrsinceasthome(Value);
            break;
        case 216:
            if (m_engine) m_engine->setTRIM(Value);
            break;
        case 218:
            if (m_engine) m_engine->setturborpm(Value);
            break;
        case 219:
            if (m_connection) m_connection->setecu(static_cast<int>(Value));
            break;
        case 220:
            if (m_engine) m_engine->setwastegatepress(Value);
            break;
        case 221:
            if (m_engine) m_engine->setWatertemp(Value);
            break;
        case 228:
            if (m_engine) m_engine->setBatteryV(Value);
            break;
        case 229:
            if (m_engine) m_engine->setIntakepress(Value);
            break;

        // * ==================== RESERVED (255, 259) ====================
        case 255:
            // ! CAS REF - not implemented
            break;
        case 259:
            // ! AAC Valve - not implemented
            break;

        // * ==================== ANALOG INPUTS (260-270) ====================
        case 260:
            if (m_analog) m_analog->setAnalog0(Value);
            break;
        case 261:
            if (m_analog) m_analog->setAnalog1(Value);
            break;
        case 262:
            if (m_analog) m_analog->setAnalog2(Value);
            break;
        case 263:
            if (m_analog) m_analog->setAnalog3(Value);
            break;
        case 264:
            if (m_analog) m_analog->setAnalog4(Value);
            break;
        case 265:
            if (m_analog) m_analog->setAnalog5(Value);
            break;
        case 266:
            if (m_analog) m_analog->setAnalog6(Value);
            break;
        case 267:
            if (m_analog) m_analog->setAnalog7(Value);
            break;
        case 268:
            if (m_analog) m_analog->setAnalog8(Value);
            break;
        case 269:
            if (m_analog) m_analog->setAnalog9(Value);
            break;
        case 270:
            if (m_analog) m_analog->setAnalog10(Value);
            break;

        // * ==================== ENGINE DATA CONTINUED ====================
        case 271:
            if (m_engine) m_engine->setGearOilPress(Value);
            break;
        case 272:
        case 273:
        case 274:
            // ! Injection Stage 3 / MAP N/P - not implemented
            break;
        case 275:
            if (m_engine) m_engine->setInjDuty2(Value);
            break;
        case 276:
            if (m_engine) m_engine->setInjAngle(Value);
            break;
        case 277:
            // ! Catalyst Temp - not implemented
            break;
        case 278:
            if (m_engine) m_engine->setBoostPreskpa(Value);
            break;

        // * ==================== DIGITAL INPUTS (279-285) ====================
        case 279:
            if (m_digital) m_digital->setDigitalInput1(Value);
            break;
        case 280:
            if (m_digital) m_digital->setDigitalInput2(Value);
            break;
        case 281:
            if (m_digital) m_digital->setDigitalInput3(Value);
            break;
        case 282:
            if (m_digital) m_digital->setDigitalInput4(Value);
            break;
        case 283:
            if (m_digital) m_digital->setDigitalInput5(Value);
            break;
        case 284:
            if (m_digital) m_digital->setDigitalInput6(Value);
            break;
        case 285:
            if (m_digital) m_digital->setDigitalInput7(Value);
            break;

        // * ==================== USER CHANNELS (286-298) ====================
        case 286:
            if (m_analog) m_analog->setUserchannel1(Value);
            break;
        case 287:
            if (m_analog) m_analog->setUserchannel2(Value);
            break;
        case 288:
            if (m_analog) m_analog->setUserchannel3(Value);
            break;
        case 289:
            if (m_analog) m_analog->setUserchannel4(Value);
            break;
        case 290:
            if (m_engine) m_engine->settractionControl(Value);
            break;
        case 291:
            if (m_analog) m_analog->setUserchannel5(Value);
            break;
        case 292:
            if (m_analog) m_analog->setUserchannel6(Value);
            break;
        case 293:
            if (m_analog) m_analog->setUserchannel7(Value);
            break;
        case 294:
            if (m_analog) m_analog->setUserchannel8(Value);
            break;
        case 295:
            if (m_analog) m_analog->setUserchannel9(Value);
            break;
        case 296:
            if (m_analog) m_analog->setUserchannel10(Value);
            break;
        case 297:
            if (m_analog) m_analog->setUserchannel11(Value);
            break;
        case 298:
            if (m_analog) m_analog->setUserchannel12(Value);
            break;

        // * ==================== ENGINE DATA (400 series) ====================
        case 400:
            if (m_engine) m_engine->setigncut(Value);
            break;
        case 403:
            if (m_engine) m_engine->setdsettargetslip(Value);
            break;
        case 404:
            if (m_engine) m_engine->settractionctlpowerlimit(Value);
            break;
        case 405:
            if (m_engine) m_engine->setknockallpeak(Value);
            break;
        case 406:
            if (m_engine) m_engine->setknockcorr(Value);
            break;
        case 407:
            if (m_engine) m_engine->setknocklastcyl(Value);
            break;
        case 408:
            if (m_engine) m_engine->settotalfueltrim(Value);
            break;
        case 409:
            if (m_engine) m_engine->settotaligncomp(Value);
            break;
        case 410:
            if (m_engine) m_engine->setegthighest(Value);
            break;
        case 411:
            if (m_engine) m_engine->setcputempecu(Value);
            break;
        case 412:
            if (m_engine) m_engine->seterrorcodecount(Value);
            break;
        case 413:
            if (m_engine) m_engine->setlostsynccount(Value);
            break;
        case 414:
            if (m_engine) m_engine->setegtdiff(Value);
            break;
        case 415:
            if (m_engine) m_engine->setactiveboosttable(Value);
            break;
        case 416:
            if (m_engine) m_engine->setactivetunetable(Value);
            break;

        // * ==================== SENSOR STRINGS (800-807) ====================
        case 800:
            if (m_sensor) m_sensor->setSensorString1(list[1]);
            break;
        case 801:
            if (m_sensor) m_sensor->setSensorString2(list[1]);
            break;
        case 802:
            if (m_sensor) m_sensor->setSensorString3(list[1]);
            break;
        case 803:
            if (m_sensor) m_sensor->setSensorString4(list[1]);
            break;
        case 804:
            if (m_sensor) m_sensor->setSensorString5(list[1]);
            break;
        case 805:
            if (m_sensor) m_sensor->setSensorString6(list[1]);
            break;
        case 806:
            if (m_sensor) m_sensor->setSensorString7(list[1]);
            break;
        case 807:
            if (m_sensor) m_sensor->setSensorString8(list[1]);
            break;

        // * ==================== FLAG STRINGS (808-823) ====================
        case 808:
            if (m_flags) m_flags->setFlagString1(list[1]);
            break;
        case 809:
            if (m_flags) m_flags->setFlagString2(list[1]);
            break;
        case 810:
            if (m_flags) m_flags->setFlagString3(list[1]);
            break;
        case 811:
            if (m_flags) m_flags->setFlagString4(list[1]);
            break;
        case 812:
            if (m_flags) m_flags->setFlagString5(list[1]);
            break;
        case 813:
            if (m_flags) m_flags->setFlagString6(list[1]);
            break;
        case 814:
            if (m_flags) m_flags->setFlagString7(list[1]);
            break;
        case 815:
            if (m_flags) m_flags->setFlagString8(list[1]);
            break;
        case 816:
            if (m_flags) m_flags->setFlagString9(list[1]);
            break;
        case 817:
            if (m_flags) m_flags->setFlagString10(list[1]);
            break;
        case 818:
            if (m_flags) m_flags->setFlagString11(list[1]);
            break;
        case 819:
            if (m_flags) m_flags->setFlagString12(list[1]);
            break;
        case 820:
            if (m_flags) m_flags->setFlagString13(list[1]);
            break;
        case 821:
            if (m_flags) m_flags->setFlagString14(list[1]);
            break;
        case 822:
            if (m_flags) m_flags->setFlagString15(list[1]);
            break;
        case 823:
            if (m_flags) m_flags->setFlagString16(list[1]);
            break;

        // * ==================== CONNECTION/ERROR DATA (824-829) ====================
        case 824:
            // ! Model - commented out in original
            break;
        case 825:
            if (m_connection) m_connection->setError(list[1]);
            break;
        case 827:
            if (m_engine) m_engine->setoilpressurelamp(static_cast<int>(Value));
            break;
        case 828:
            if (m_engine) m_engine->setovertempalarm(static_cast<int>(Value));
            break;
        case 829:
            if (m_engine) m_engine->setalternatorfail(static_cast<int>(Value));
            break;

        // * ==================== ENGINE DATA CONTINUED (830-831) ====================
        case 830:
            if (m_engine) m_engine->setturborpm2(Value);
            // ! Note: Original code missing break - fallthrough was unintentional
            break;
        case 831:
            if (m_engine) m_engine->setAuxTemp1(static_cast<int>(Value));
            break;

        // * ==================== ELECTRIC MOTOR DATA (832-863) ====================
        case 832:
            if (m_motor) m_motor->setIGBTPhaseATemp(Value);
            break;
        case 833:
            if (m_motor) m_motor->setIGBTPhaseBTemp(Value);
            break;
        case 834:
            if (m_motor) m_motor->setIGBTPhaseCTemp(Value);
            break;
        case 835:
            if (m_motor) m_motor->setGateDriverTemp(Value);
            break;
        case 836:
            if (m_motor) m_motor->setControlBoardTemp(Value);
            break;
        case 837:
            if (m_motor) m_motor->setRtdTemp1(Value);
            break;
        case 838:
            if (m_motor) m_motor->setRtdTemp2(Value);
            break;
        case 839:
            if (m_motor) m_motor->setRtdTemp3(Value);
            break;
        case 840:
            if (m_motor) m_motor->setRtdTemp4(Value);
            break;
        case 841:
            if (m_motor) m_motor->setRtdTemp5(Value);
            break;
        case 842:
            if (m_motor) m_motor->setEMotorTemperature(Value);
            break;
        case 843:
            if (m_motor) m_motor->setTorqueShudder(Value);
            break;
        case 844:
            if (m_motor) m_motor->setDigInput1FowardSw(Value);
            break;
        case 845:
            if (m_motor) m_motor->setDigInput2ReverseSw(Value);
            break;
        case 846:
            if (m_motor) m_motor->setDigInput3BrakeSw(Value);
            break;
        case 847:
            if (m_motor) m_motor->setDigInput4RegenDisableSw(Value);
            break;
        case 848:
            if (m_motor) m_motor->setDigInput5IgnSw(Value);
            break;
        case 849:
            if (m_motor) m_motor->setDigInput6StartSw(Value);
            break;
        case 850:
            if (m_motor) m_motor->setDigInput7Bool(Value);
            break;
        case 851:
            if (m_motor) m_motor->setDigInput8Bool(Value);
            break;
        case 852:
            if (m_motor) m_motor->setEMotorAngle(Value);
            break;
        case 853:
            if (m_motor) m_motor->setEMotorSpeed(Value);
            break;
        case 854:
            if (m_motor) m_motor->setElectricalOutFreq(Value);
            break;
        case 855:
            if (m_motor) m_motor->setDeltaResolverFiltered(Value);
            break;
        case 856:
            if (m_motor) m_motor->setPhaseACurrent(Value);
            break;
        case 857:
            if (m_motor) m_motor->setPhaseBCurrent(Value);
            break;
        case 858:
            if (m_motor) m_motor->setPhaseCCurrent(Value);
            break;
        case 859:
            if (m_motor) m_motor->setDCBusCurrent(Value);
            break;
        case 860:
            if (m_motor) m_motor->setDCBusVoltage(Value);
            break;
        case 861:
            if (m_motor) m_motor->setOutputVoltage(Value);
            break;
        case 862:
            if (m_motor) m_motor->setVABvdVoltage(Value);
            break;
        case 863:
            if (m_motor) m_motor->setVBCvqVoltage(Value);
            break;

        // * ==================== EXPANDER BOARD DIGITAL INPUTS (900-907) ====================
        case 900:
            if (m_digital) m_digital->setEXDigitalInput1(Value);
            break;
        case 901:
            if (m_digital) m_digital->setEXDigitalInput2(Value);
            break;
        case 902:
            if (m_digital) m_digital->setEXDigitalInput3(Value);
            break;
        case 903:
            if (m_digital) m_digital->setEXDigitalInput4(Value);
            break;
        case 904:
            if (m_digital) m_digital->setEXDigitalInput5(Value);
            break;
        case 905:
            if (m_digital) m_digital->setEXDigitalInput6(Value);
            break;
        case 906:
            if (m_digital) m_digital->setEXDigitalInput7(Value);
            break;
        case 907:
            if (m_digital) m_digital->setEXDigitalInput8(Value);
            break;

        // * ==================== EXPANDER BOARD ANALOG INPUTS (908-915) ====================
        case 908:
            if (m_expander) m_expander->setEXAnalogInput0(Value / 1000);
            break;
        case 909:
            if (m_expander) m_expander->setEXAnalogInput1(Value / 1000);
            break;
        case 910:
            if (m_expander) m_expander->setEXAnalogInput2(Value / 1000);
            break;
        case 911:
            if (m_expander) m_expander->setEXAnalogInput3(Value / 1000);
            break;
        case 912:
            if (m_expander) m_expander->setEXAnalogInput4(Value / 1000);
            break;
        case 913:
            if (m_expander) m_expander->setEXAnalogInput5(Value / 1000);
            break;
        case 914:
            if (m_expander) m_expander->setEXAnalogInput6(Value / 1000);
            break;
        case 915:
            if (m_expander) m_expander->setEXAnalogInput7(Value / 1000);
            break;

        // * ==================== PER-CYLINDER AFR (916-923) ====================
        case 916:
            if (m_engine) m_engine->setAFRcyl1(Value);
            break;
        case 917:
            if (m_engine) m_engine->setAFRcyl2(Value);
            break;
        case 918:
            if (m_engine) m_engine->setAFRcyl3(Value);
            break;
        case 919:
            if (m_engine) m_engine->setAFRcyl4(Value);
            break;
        case 920:
            if (m_engine) m_engine->setAFRcyl5(Value);
            break;
        case 921:
            if (m_engine) m_engine->setAFRcyl6(Value);
            break;
        case 922:
            if (m_engine) m_engine->setAFRcyl7(Value);
            break;
        case 923:
            if (m_engine) m_engine->setAFRcyl8(Value);
            break;

        // * ==================== BIGSTUFF EXTRA (924-953) ====================
        case 924:
            // ! Gearoffset - need to add to VehicleData if needed
            break;
        case 925:
            if (m_engine) m_engine->setAFRLEFTBANKTARGET(Value);
            break;
        case 926:
            if (m_engine) m_engine->setAFRRIGHTBANKTARGET(Value);
            break;
        case 927:
            if (m_engine) m_engine->setAFRLEFTBANKACTUAL(Value);
            break;
        case 928:
            if (m_engine) m_engine->setAFRRIGHTBANKACTUAL(Value);
            break;
        case 929:
            if (m_engine) m_engine->setBOOSTOFFSET(Value);
            break;
        case 930:
            if (m_engine) m_engine->setREVLIM3STEP(Value);
            break;
        case 931:
            if (m_engine) m_engine->setREVLIM2STEP(Value);
            break;
        case 932:
            if (m_engine) m_engine->setREVLIMGIGHSIDE(Value);
            break;
        case 933:
            if (m_engine) m_engine->setREVLIMBOURNOUT(Value);
            break;
        case 934:
            if (m_engine) m_engine->setLEFTBANKO2CORR(Value);
            break;
        case 935:
            if (m_engine) m_engine->setRIGHTBANKO2CORR(Value);
            break;
        case 936:
            if (m_engine) m_engine->setTRACTIONCTRLOFFSET(Value);
            break;
        case 937:
            if (m_engine) m_engine->setDRIVESHAFTOFFSET(Value);
            break;
        case 938:
            if (m_engine) m_engine->setTCCOMMAND(Value);
            break;
        case 939:
            if (m_engine) m_engine->setFSLCOMMAND(Value);
            break;
        case 940:
            if (m_engine) m_engine->setFSLINDEX(Value);
            break;
        case 941:
            if (m_engine) m_engine->setPANVAC(Value);
            break;
        case 942:
            if (m_engine) m_engine->setCyl1_O2_Corr(Value);
            break;
        case 943:
            if (m_engine) m_engine->setCyl2_O2_Corr(Value);
            break;
        case 944:
            if (m_engine) m_engine->setCyl3_O2_Corr(Value);
            break;
        case 945:
            if (m_engine) m_engine->setCyl4_O2_Corr(Value);
            break;
        case 946:
            if (m_engine) m_engine->setCyl5_O2_Corr(Value);
            break;
        case 947:
            if (m_engine) m_engine->setCyl6_O2_Corr(Value);
            break;
        case 948:
            if (m_engine) m_engine->setCyl7_O2_Corr(Value);
            break;
        case 949:
            if (m_engine) m_engine->setCyl8_O2_Corr(Value);
            break;
        case 950:
            if (m_engine) m_engine->setRotaryTrimpot1(static_cast<int>(Value));
            break;
        case 951:
            if (m_engine) m_engine->setRotaryTrimpot2(static_cast<int>(Value));
            break;
        case 952:
            if (m_engine) m_engine->setRotaryTrimpot3(static_cast<int>(Value));
            break;
        case 953:
            if (m_engine) m_engine->setCalibrationSelect(static_cast<int>(Value));
            break;

        // * ==================== FREQUENCY INPUT (999) ====================
        case 999:
            if (m_digital) m_digital->setfrequencyDIEX1(Value);
            break;

        default:
            break;
        }
    }
}
