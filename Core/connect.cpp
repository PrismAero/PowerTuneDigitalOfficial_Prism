
/*
 * Copyright (C) 2017 Bastian Gschrey & Markus Ippy
 *
 * Digital Gauges for Apexi Power FC for RX7 on Raspberry Pi
 *
 *
 * This software comes under the GPL (GNU Public License)
 * You may freely copy,distribute etc. this as long as the source code
 * is made available for FREE.
 *
 * No warranty is made or implied. You use this program at your own risk.
 */

/*!
  \file Connect.cpp
  \author Bastian Gschrey & Markus Ippy
  \modifier Kai Wyborny
  Copyright (C) 2026 Kai Wyborny - Memory optimization changes
*/

#include "connect.h"

#include "../Hardware/Extender.h"
#include "../Utils/Calculations.h"
#include "../Utils/CalibrationHelper.h"
#include "../Utils/DataLogger.h"
#include "../Utils/SteinhartCalculator.h"
#include "../Utils/UDPReceiver.h"
#include "../Utils/wifiscanner.h"
#include "DiagnosticsProvider.h"
#include "../Utils/UdpTestSimulator.h"
#include "../Utils/OverlayConfigManager.h"
#include "../Utils/ShiftIndicatorHelper.h"
#include "Models/DataModels.h"
#include "Models/UIState.h"
#include "PropertyRouter.h"
#include "SensorRegistry.h"
#include "appsettings.h"
#include "dashboard.h"

#include <QByteArrayMatcher>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QTextStream>
#include <QTime>
#include <QTimer>
#include <QVector>


int ecu;      // 0=apex, 1=adaptronic;2= OBD; 3= Dicktator ECU
int logging;  // 0 Logging off , 1 Logging to file
int connectclicked = 0;
int canbaseadress;
int rpmcanbaseadress;
QByteArray checksumhex;
QByteArray recvchecksumhex;
QString selectedPort;
QVector<QString> dashfilenames(3);

Connect::Connect(QObject *parent)
    : QObject(parent),
      m_dashBoard(nullptr),
      m_udpreceiver(nullptr),
      m_datalogger(nullptr),
      m_calculations(nullptr),
      m_wifiscanner(nullptr),
      m_extender(nullptr),
      m_uiState(nullptr),
      m_engineData(nullptr),
      m_vehicleData(nullptr),
      m_gpsData(nullptr),
      m_analogInputs(nullptr),
      m_digitalInputs(nullptr),
      m_expanderBoardData(nullptr),
      m_electricMotorData(nullptr),
      m_flagsData(nullptr),
      m_timingData(nullptr),
      m_sensorData(nullptr),
      m_connectionData(nullptr),
      m_settingsData(nullptr),
      m_propertyRouter(nullptr),
      m_steinhartCalc(nullptr),
      m_calibrationHelper(nullptr),
      m_sensorRegistry(nullptr),
      m_diagnosticsProvider(nullptr)

{
    m_dashBoard = new DashBoard(this);
    // * Phase 2: Create domain data models
    m_uiState = new UIState(this);

    // * Phase 4: Connect DashBoard to UIState for facade forwarding
    m_dashBoard->setUIState(m_uiState);

    m_engineData = new EngineData(this);
    m_vehicleData = new VehicleData(this);
    m_gpsData = new GPSData(this);
    m_analogInputs = new AnalogInputs(this);
    m_digitalInputs = new DigitalInputs(this);
    m_expanderBoardData = new ExpanderBoardData(this);
    m_electricMotorData = new ElectricMotorData(this);
    m_flagsData = new FlagsData(this);
    m_timingData = new TimingData(this);
    // * Phase 3: Create remaining data models
    m_sensorData = new SensorData(this);
    m_connectionData = new ConnectionData(this);
    m_settingsData = new SettingsData(this);
    // * Phase 5: AppSettings now writes directly to domain models (no Dashboard fallback)
    m_appSettings = new AppSettings(m_dashBoard, m_settingsData, m_uiState, m_vehicleData, m_analogInputs,
                                    m_expanderBoardData, m_engineData, m_connectionData, m_digitalInputs, this);
    // * Phase 3: Create PropertyRouter for dynamic QML property access
    m_propertyRouter = new PropertyRouter(m_engineData, m_vehicleData, m_gpsData, m_analogInputs, m_digitalInputs,
                                          m_expanderBoardData, m_electricMotorData, m_flagsData, m_sensorData,
                                          m_connectionData, m_settingsData, m_timingData, m_uiState, this);
    // * Phase 1: UDPReceiver now writes directly to domain models
    m_udpreceiver =
        new udpreceiver(m_engineData, m_vehicleData, m_gpsData, m_analogInputs, m_digitalInputs, m_expanderBoardData,
                        m_electricMotorData, m_flagsData, m_sensorData, m_connectionData, m_settingsData, this);
    // * Phase 5: DataLogger now reads from domain models
    m_datalogger = new datalogger(m_engineData, m_vehicleData, m_gpsData, m_sensorData, m_flagsData, m_analogInputs,
                                  m_expanderBoardData, m_digitalInputs, m_connectionData, m_timingData, this);
    // * Phase 4: Calculations now writes directly to domain models
    m_calculations = new calculations(m_dashBoard, m_vehicleData, m_engineData, m_timingData, m_settingsData, this);
    m_wifiscanner = new WifiScanner(m_connectionData, this);
    // * Phase 4: Extender now writes directly to domain models
    m_extender = new Extender(m_digitalInputs, m_expanderBoardData, m_engineData, m_settingsData, m_vehicleData,
                              m_connectionData, this);
    // * Phase 6: Create SteinhartCalculator, wire into Extender, connect calibration signals
    m_steinhartCalc = new SteinhartCalculator(this);
    m_extender->setSteinhartCalculator(m_steinhartCalc);
    m_extender->connectCalibrationSignals();
    m_calibrationHelper = new CalibrationHelper(m_steinhartCalc, this);
    // * Phase 7: Create SensorRegistry for runtime sensor tracking
    m_sensorRegistry = new SensorRegistry(this);
    // * Phase 8: Create DiagnosticsProvider and wire to SensorRegistry
    m_diagnosticsProvider = new DiagnosticsProvider(this);
    m_diagnosticsProvider->setSensorRegistry(m_sensorRegistry);
    m_diagnosticsProvider->setPropertyRouter(m_propertyRouter);
    m_testSimulator = new UdpTestSimulator(this);
    m_overlayConfigManager = new OverlayConfigManager(this);
    m_shiftIndicatorHelper = new ShiftIndicatorHelper(this);
    // m_wifiscanner = new WifScanner(this);
    // Use AppDataLocation instead of "/" to prevent QFileSystemModel from
    // indexing the entire filesystem (saves 0.5-2GB+ RAM on macOS dev builds)
    QString mPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(mPath);  // Ensure the directory exists
    // DIRECTORIES
    dirModel = new QFileSystemModel(this);
    // Set filter
    dirModel->setFilter(QDir::NoDotAndDotDot | QDir::AllDirs);
    // QFileSystemModel requires root path
    dirModel->setRootPath(mPath);
    fileModel = new QFileSystemModel(this);
    // Set filter
    fileModel->setFilter(QDir::NoDotAndDotDot | QDir::Files);
    // QFileSystemModel requires root path
    fileModel->setRootPath(mPath);

    QQmlApplicationEngine *engine = dynamic_cast<QQmlApplicationEngine *>(parent);
    if (engine == nullptr)
        return;
    engine->rootContext()->setContextProperty("Dashboard", m_dashBoard);
    // * Phase 2: Expose domain data models to QML
    engine->rootContext()->setContextProperty("UI", m_uiState);
    engine->rootContext()->setContextProperty("Engine", m_engineData);
    engine->rootContext()->setContextProperty("Vehicle", m_vehicleData);
    engine->rootContext()->setContextProperty("GPS", m_gpsData);
    engine->rootContext()->setContextProperty("Analog", m_analogInputs);
    engine->rootContext()->setContextProperty("Digital", m_digitalInputs);
    engine->rootContext()->setContextProperty("Expander", m_expanderBoardData);
    engine->rootContext()->setContextProperty("Motor", m_electricMotorData);
    engine->rootContext()->setContextProperty("Flags", m_flagsData);
    engine->rootContext()->setContextProperty("Timing", m_timingData);
    // * Phase 3: Expose remaining data models to QML
    engine->rootContext()->setContextProperty("Sensor", m_sensorData);
    engine->rootContext()->setContextProperty("Connection", m_connectionData);
    engine->rootContext()->setContextProperty("Settings", m_settingsData);
    // * Phase 3: Expose PropertyRouter for dynamic property access (replaces Dashboard[propName])
    engine->rootContext()->setContextProperty("PropertyRouter", m_propertyRouter);
    engine->rootContext()->setContextProperty("Extender2", m_extender);
    engine->rootContext()->setContextProperty("AppSettings", m_appSettings);
    engine->rootContext()->setContextProperty("Logger", m_datalogger);
    engine->rootContext()->setContextProperty("Calculations", m_calculations);
    engine->rootContext()->setContextProperty("Dirmodel", dirModel);
    engine->rootContext()->setContextProperty("Filemodel", fileModel);
    engine->rootContext()->setContextProperty("Wifiscanner", m_wifiscanner);
    engine->rootContext()->setContextProperty("Calibration", m_calibrationHelper);
    engine->rootContext()->setContextProperty("Steinhart", m_steinhartCalc);
    // * Phase 7: Expose SensorRegistry to QML
    engine->rootContext()->setContextProperty("SensorRegistry", m_sensorRegistry);
    // * Phase 8: Expose DiagnosticsProvider to QML
    engine->rootContext()->setContextProperty("Diagnostics", m_diagnosticsProvider);
    engine->rootContext()->setContextProperty("TestSim", m_testSimulator);
    engine->rootContext()->setContextProperty("OverlayConfig", m_overlayConfigManager);
    engine->rootContext()->setContextProperty("ShiftHelper", m_shiftIndicatorHelper);
    m_appSettings->setExtender(m_extender);
    m_appSettings->setSteinhartCalculator(m_steinhartCalc);
    m_appSettings->readandApplySettings();
    // * Phase 7: Populate SensorRegistry with configured input channels
    m_sensorRegistry->refreshEcuAnalogChannels();
    m_sensorRegistry->refreshExtenderAnalogInputs();
    m_sensorRegistry->refreshExtenderDigitalInputs();
    m_sensorRegistry->refreshEcuDigitalInputs();
}


Connect::~Connect() = default;
void Connect::saveDashtoFile(const QString &filename, const QString &dashstring)
{
    QString fullName = filename;
    if (!filename.contains('.'))
        fullName += ".txt";

    QString fixformat = dashstring;
    if (fullName.endsWith(".txt")) {
        fixformat.replace(",,", ", ,");
    }

    QFile file("/home/pi/UserDashboards/" + fullName);
    file.remove();
    if (file.open(QIODevice::ReadWrite)) {
        QTextStream stream(&file);
        stream << fixformat << Qt::endl;
    }
    file.close();
}
void Connect::setDashFilename(int index, const QString &filename)
{
    if (index < 0)
        return;
    while (dashfilenames.size() <= index)
        dashfilenames.append(QString());
    dashfilenames[index] = filename;
}

void Connect::setRpmStyle(int index, int style)
{
    m_uiState->setRpmStyle(index, style);
}

void Connect::setrpm(const int &dash1, const int &dash2, const int &dash3)
{
    m_uiState->setRpmStyle(0, dash1);
    m_uiState->setRpmStyle(1, dash2);
    m_uiState->setRpmStyle(2, dash3);
}
void Connect::checkifraspberrypi()
{
    static const QString sysfsPath = QStringLiteral("/sys/class/backlight/rpi_backlight/brightness");

    if (QFileInfo::exists(sysfsPath)) {
        QFile inputFile(sysfsPath);
        if (inputFile.open(QIODevice::ReadOnly)) {
            QTextStream in(&inputFile);
            bool ok;
            int val = in.readLine().toInt(&ok);
            if (ok)
                m_uiState->setBrightness(val);
            inputFile.close();
        }
        m_uiState->setscreen(true);
        m_brightnessMethod = BrightnessMethod::Sysfs;
        return;
    }

    if (QFileInfo::exists(QStringLiteral("/usr/bin/ddcutil"))) {
        m_uiState->setscreen(true);
        m_brightnessMethod = BrightnessMethod::DdcUtil;
        return;
    }

    m_uiState->setscreen(false);
    m_brightnessMethod = BrightnessMethod::None;
}
void Connect::readavailabledashfiles()
{
    // QDir directory(""); //for Windows
    QDir directory("/home/pi/UserDashboards");
    QStringList dashfiles = directory.entryList(QStringList() << "*.txt", QDir::Files);
    m_uiState->setdashfiles(dashfiles);
    // qDebug() <<"files" << dashfiles ;
}

void Connect::readavailablebackrounds()
{
    QStringList dashfiles;

#ifdef Q_OS_LINUX
    // * Linux (Raspberry Pi) - use /home/pi/Logo directory
    QDir directory("/home/pi/Logo");
    dashfiles = directory.entryList(QStringList() << "*.png" << "*.gif", QDir::Files);
#elif defined(Q_OS_MACOS)
    // * macOS - list bundled graphics resources for development testing
    // * The files are in the qrc, so we provide a static list of available images
    dashfiles << "Logo.png" << "MainDash.png" << "MainDashBlue.png" << "MainDashnew.png"
              << "Racedash.png" << "Racedash800x480.png" << "RPM_BG.png" << "rotary.gif"
              << "test.png" << "StateGIF.gif";
#elif defined(Q_OS_WIN)
    // * Windows - use C:/Logo directory
    QDir directory("C:/Logo");
    dashfiles = directory.entryList(QStringList() << "*.png" << "*.gif", QDir::Files);
#else
    QDir directory("./Logo");
    dashfiles = directory.entryList(QStringList() << "*.png" << "*.gif", QDir::Files);
#endif

    dashfiles.prepend("None");
    m_uiState->setbackroundpictures(dashfiles);
}

void Connect::readMaindashsetup()
{
    // QString path = "MainDash.txt";//for Windows
    QString path = "/home/pi/UserDashboards/MainDash.txt";
    QFile inputFile(path);
    if (inputFile.open(QIODevice::ReadOnly)) {
        QTextStream in(&inputFile);
        while (!in.atEnd()) {
            QString line = in.readLine();
            QStringList list = line.split(QRegularExpression("\\,"));
            m_uiState->setmaindashsetup(list);
        }
        inputFile.close();
    }
}
void Connect::readDashSetup(int index)
{
    if (index < 0 || index >= dashfilenames.size())
        return;

    const QString &filename = dashfilenames.at(index);
    if (filename.isEmpty())
        return;

    QString path = "/home/pi/UserDashboards/" + filename;
    QFile inputFile(path);
    if (inputFile.open(QIODevice::ReadOnly)) {
        QTextStream in(&inputFile);
        while (!in.atEnd()) {
            QString line = in.readLine();
            QStringList list = line.split(QRegularExpression("\\,"));
            list.removeAll(QString(""));
            m_uiState->setDashSetup(index, list);
        }
        inputFile.close();
    }
}

void Connect::setSreenbrightness(const int &brightness)
{
    switch (m_brightnessMethod) {
    case BrightnessMethod::DdcUtil: {
        QString val = QString::number(brightness);
        QProcess::execute(QStringLiteral("ddcutil"),
                          {QStringLiteral("setvcp"),
                           QStringLiteral("10"), val,
                           QStringLiteral("12"), val,
                           QStringLiteral("13"), val});
        break;
    }
    case BrightnessMethod::Sysfs: {
        QFile f(QStringLiteral("/sys/class/backlight/rpi_backlight/brightness"));
        if (f.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            QTextStream out(&f);
            out << brightness;
            f.close();
        }
        break;
    }
    case BrightnessMethod::None:
        break;
    }
}
void Connect::setSpeedUnits(const int &units1)
{
    switch (units1) {
    case 0:
        m_settingsData->setspeedunits("metric");
        break;
    case 1:
        m_settingsData->setspeedunits("imperial");
        break;

    default:
        break;
    }
}
void Connect::setUnits(const int &units)
{
    switch (units) {
    case 0:
        m_settingsData->setunits("metric");
        break;
    case 1:
        m_settingsData->setunits("imperial");
        break;

    default:
        break;
    }
}
void Connect::setPressUnits(const int &units2)
{
    switch (units2) {
    case 0:
        m_settingsData->setpressureunits("metric");
        break;
    case 1:
        m_settingsData->setpressureunits("imperial");
        break;

    default:
        break;
    }
}

void Connect::setWeight(const int &weight)
{
    m_vehicleData->setWeight(weight);
}

void Connect::setOdometer(const qreal &Odometer)
{
    m_vehicleData->setOdo(Odometer);
    m_calculations->start();
}
void Connect::qmlTreeviewclicked(const QModelIndex &index)
{
    QString mPath = dirModel->fileInfo(index).absoluteFilePath();
    // mPath.remove(0, 2); //this is needed for windows
    QString mPathnew = "file://" + mPath;
    m_connectionData->setmusicpath(mPathnew);
}

// function for flushing all Connect buffers
void Connect::clear() const
{
    // m_Connectport->clear();
}
// Reads the file of supported OBD PIDS and makes it available to QML for the User to select which PIDS should be polled
void Connect::checkOBDReg()
{
    int i = 0;
    bool ok;
    QStringList list;

    QString path = "/home/pi/daemons/OBDPIDS.txt";
    // QString path = "SupportedPIDS.txt";
    QFile inputFile(path);
    if (inputFile.open(QIODevice::ReadOnly)) {
        QTextStream in(&inputFile);
        while (!in.atEnd()) {
            QString line = in.readLine();
            list = line.split(QRegularExpression("\\,"));
        }
        inputFile.close();
    }
    while (i < list.length()) {
        // qDebug()<< "Enter Loop" <<i;
        int pidread = (list[i].toInt(&ok, 16));
        m_connectionData->setsupportedReg(pidread);
        // qDebug()<< "Reading" << list[i];
        i++;
    }
}

void Connect::checkReg()
{
    int i = 0;
    bool ok;
    QStringList list;
    // QString path = "Regs.txt";
    QString path = "/home/pi/daemons/Regs.txt";
    QFile inputFile(path);
    if (inputFile.open(QIODevice::ReadOnly)) {
        QTextStream in(&inputFile);
        while (!in.atEnd()) {
            QString line = in.readLine();
            list = line.split(QRegularExpression("\\,"));
        }
        inputFile.close();
    }
    while (i < list.length()) {
        // qDebug()<< "Read supported Consult Reg" <<list[i];
        switch (list[i].toInt(&ok, 16)) {
        case 0x00:
            m_connectionData->setsupportedReg(0);
            i++;
            break;
        case 0x01:
            m_connectionData->setsupportedReg(1);
            i++;
            break;
        case 0x02:
            m_connectionData->setsupportedReg(2);
            i++;
            break;
        case 0x03:
            m_connectionData->setsupportedReg(3);
            i++;
            break;
        case 0x04:
            m_connectionData->setsupportedReg(4);
            i++;
            break;
        case 0x05:
            m_connectionData->setsupportedReg(5);
            i++;
            break;
        case 0x06:
            m_connectionData->setsupportedReg(6);
            i++;
            break;
        case 0x07:
            m_connectionData->setsupportedReg(7);
            i++;
            break;
        case 0x08:
            m_connectionData->setsupportedReg(8);
            i++;
            break;
        case 0x09:
            m_connectionData->setsupportedReg(9);
            i++;
            break;
        case 0x0a:
            m_connectionData->setsupportedReg(10);
            i++;
            break;
        case 0x0b:
            m_connectionData->setsupportedReg(11);
            i++;
            break;
        case 0x0c:
            m_connectionData->setsupportedReg(12);
            i++;
            break;
        case 0x0d:
            m_connectionData->setsupportedReg(13);
            i++;
            break;
        case 0x0f:
            m_connectionData->setsupportedReg(14);
            i++;
            break;
        case 0x11:
            m_connectionData->setsupportedReg(15);
            i++;
            break;
        case 0x12:
            m_connectionData->setsupportedReg(16);
            i++;
            break;
        case 0x13:
            m_connectionData->setsupportedReg(17);
            i++;
            break;
        case 0x14:
            m_connectionData->setsupportedReg(18);
            i++;
            break;
        case 0x15:
            m_connectionData->setsupportedReg(19);
            i++;
            break;
        case 0x16:
            m_connectionData->setsupportedReg(20);
            i++;
            break;
        case 0x17:
            m_connectionData->setsupportedReg(21);
            i++;
            break;
        case 0x1a:
            m_connectionData->setsupportedReg(22);
            i++;
            break;
        case 0x1b:
            m_connectionData->setsupportedReg(23);
            i++;
            break;
        case 0x1c:
            m_connectionData->setsupportedReg(24);
            i++;
            break;
        case 0x1d:
            m_connectionData->setsupportedReg(25);
            i++;
            break;
        case 0x1e:
            m_connectionData->setsupportedReg(26);
            i++;
            break;
        case 0x1f:
            m_connectionData->setsupportedReg(27);
            i++;
            break;
        case 0x21:
            m_connectionData->setsupportedReg(28);
            i++;
            break;
        case 0x22:
            m_connectionData->setsupportedReg(29);
            i++;
            break;
        case 0x23:
            m_connectionData->setsupportedReg(30);
            i++;
            break;
        case 0x28:
            m_connectionData->setsupportedReg(31);
            i++;
            break;
        case 0x29:  // corrct
            m_connectionData->setsupportedReg(32);
            i++;
            break;
        case 0x2a:  // corrct
            m_connectionData->setsupportedReg(33);
            i++;
            break;
        case 0x2e:  // corrct
            m_connectionData->setsupportedReg(34);
            i++;
            break;
        case 0x25:  // corrct
            m_connectionData->setsupportedReg(35);
            i++;
            break;
        case 0x26:  // corrct
            m_connectionData->setsupportedReg(36);
            i++;
            break;
        case 0x27:  // corrct
            m_connectionData->setsupportedReg(37);
            i++;
            break;
        case 0x2f:
            m_connectionData->setsupportedReg(38);
            i++;
            break;
        case 0x30:
            m_connectionData->setsupportedReg(39);
            i++;
            break;
        case 0x31:
            m_connectionData->setsupportedReg(40);
            i++;
            break;
        case 0x32:
            m_connectionData->setsupportedReg(41);
            i++;
            break;
        case 0x33:
            m_connectionData->setsupportedReg(42);
            i++;
            break;
        case 0x34:
            m_connectionData->setsupportedReg(43);
            i++;
            break;
        case 0x35:
            m_connectionData->setsupportedReg(44);
            i++;
            break;
        case 0x36:
            m_connectionData->setsupportedReg(45);
            i++;
            break;
        case 0x37:
            m_connectionData->setsupportedReg(46);
            i++;
            break;
        case 0x38:
            m_connectionData->setsupportedReg(47);
            i++;
            break;
        case 0x39:
            m_connectionData->setsupportedReg(48);
            i++;
            break;
        case 0x3a:
            m_connectionData->setsupportedReg(49);
            i++;
            break;
        case 0x4a:
            m_connectionData->setsupportedReg(50);
            i++;
            break;
        case 0x52:
            m_connectionData->setsupportedReg(51);
            i++;
            break;
        case 0x53:
            m_connectionData->setsupportedReg(52);
            i++;
            break;
        case 0xFE:
            // Not supported Register
            i++;
            break;

        default:
            break;
        }
    }
}

void Connect::LiveReqMsgOBD(const QString &obdpids)
{
    // qDebug()<< "PIDS" <<obdpids;
    QString Message;
    QStringList list = obdpids.split(",");
    // qDebug()<< "Raw list" <<list;
    QString fileName = "/home/pi/daemons/OBD.cfg";  // This will be the correct path on pi
    // QString fileName = "OBD.cfg";//for testing on windows
    QFile mFile(fileName);
    mFile.open(QIODevice::ReadWrite | QIODevice::Truncate | QIODevice::Text);
    int i = 0;
    while (i < list.length()) {
        if (list[i] == "2") {
            // qDebug()<< "i" <<i;
            QString hexadecimal;
            hexadecimal.setNum(i, 16);
            if (hexadecimal.length() % 2)
                hexadecimal.insert(0, QLatin1String("0"));
            // qDebug()<< "Hex" <<hexadecimal;
            Message.append("0x" + hexadecimal);
            Message.append(",");
        }
        i++;
    }
    Message.remove(Message.length() - 1, 1);  // Remove the last Comma
    // qDebug()<< "PID LST" <<Message;
    QTextStream out(&mFile);
    out << Message;
    mFile.close();

    // Reboot the PI for settings to take Effect
    reboot();
}

void Connect::daemonstartup(const int &daemon)
{
    QString daemonstart;
    switch (daemon) {
    case 0:
        daemonstart = "";
        break;
    case 1:
        daemonstart = "./Haltechd";
        break;
    case 2:
        daemonstart = "./Linkd";
        break;
    case 3:
        daemonstart = "./Microtechd";
        break;
    case 4:
        daemonstart = "./Consult /dev/ttyUSB0";
        break;
    case 5:
        daemonstart = "./M800ADLSet1d";
        break;
    case 6:
        daemonstart = "./OBD /dev/ttyUSB0";
        break;
    case 7:
        daemonstart = "./Hondatad";
        break;
    case 8:
        daemonstart = "./AdaptronicCANd";
        break;
    case 9:
        daemonstart = "./MotecM1d";
        break;
    case 10:
        daemonstart = "./AEMV2d";
        break;
    case 11:
        daemonstart = "./AudiB7d";
        break;
    case 12:
        daemonstart = "./BRZFRS86d";
        break;
    case 13:
        daemonstart = "./EMUCANd";
        break;
    case 14:
        daemonstart = "./AudiB8d";
        break;
    case 15:
        daemonstart = "./Emtrond";
        break;
    case 16:
        daemonstart = "./Holleyd";
        break;
    case 17:
        daemonstart = "./MaxxECUd";
        break;
    case 18:
        daemonstart = "./FordBarraFGMK1CAN";
        break;
    case 19:
        daemonstart = "./FordBarraFGMK1CANOBD";
        break;
    case 20:
        daemonstart = "./FordBarraBXCAN";
        break;
    case 21:
        daemonstart = "./FordBarraBXCANOBD";
        break;
    case 22:
        daemonstart = "./FordBarraFG2xCAN";
        break;
    case 23:
        daemonstart = "./FordBarraFG2XCANOBD";
        break;
    case 24:
        daemonstart = "./EVOXCAN";
        break;
    case 25:
        daemonstart = "./BlackboxM3";
        break;
    case 26:
        daemonstart = "./NISSAN370Z";
        break;
    case 27:
        daemonstart = "./GMCANd";
        break;
    case 28:
        daemonstart = "./NISSAN350Z";
        break;
    case 29:
        daemonstart = "./MegasquirtCan";
        break;
    case 30:
        daemonstart = "./EMSCAN";
        break;
    case 31:
        daemonstart = "./WRX2012";
        break;
    case 32:
        daemonstart = "./M800ADLSet3d";
        break;
    case 33:
        daemonstart = "./Testdaemon";
        break;
    case 34:
        daemonstart = "./ecoboost";
        break;
    case 35:
        daemonstart = "./Emerald";
        break;
    case 36:
        daemonstart = "./WolfEMS";
        break;
    case 37:
        daemonstart = "./GMCANOBD";
        break;
    case 38:
        daemonstart = "";
        break;
    case 39:
        daemonstart = "./HondataS300";
        break;
    case 40:
        daemonstart = "./genericcan";
        break;
    case 41:
        daemonstart = "./ME13";
        break;
    case 42:
        daemonstart = "./FTCAN20";
        break;
    case 43:
        daemonstart = "./Delta";
        break;
    case 44:
        daemonstart = "./BigNET";
        break;
    case 45:
        daemonstart = "./BigNETLamda";
        break;
    case 46:
        daemonstart = "./R35";
        break;
    case 47:
        daemonstart = "./Prado";
        break;
    case 48:
        daemonstart = "./WRX2016";
        break;
    case 49:
        daemonstart = "./LifeRacing";
        break;
    case 50:
        daemonstart = "./DTAFast";
        break;
    case 51:
        daemonstart = "./ProEFI";
        break;
    case 52:
        daemonstart = "./TeslaSDU";
        break;
    case 53:
        daemonstart = "./NeuroBasic";
        break;
    case 54:
        daemonstart = "./GR_Yaris";
        break;
    case 55:
        daemonstart = "./SyvecsS7";
        break;
    case 56:
        daemonstart = "./Rsport";
        break;
    case 57:
        daemonstart = "./Generic";
        break;
    case 58:
        daemonstart = "./Edelbrock";
        break;
    case 59:
        daemonstart = "./Boostec";
        break;
    case 60:
        daemonstart = "./HEFI";
        break;
    }


    QString fileName = "/home/pi/startdaemon.sh";  // This will be the correct path on pi
    // QString fileName = "startdaemon.sh";//for testing on windows
    QFile mFile(fileName);

    if (daemonstart == "./Consult /dev/ttyUSB0") {
        qDebug() << "Consult Selected";
        mFile.open(QIODevice::ReadWrite | QIODevice::Truncate | QIODevice::Text);
        QTextStream out(&mFile);
        out << "#!/bin/sh" << Qt::endl
            << "sudo ifdown can0" << Qt::endl
            << "sudo ifup can0" << Qt::endl
            << "#PLMS Consult Cable drivers" << Qt::endl
            << "sudo modprobe ftdi_sio" << Qt::endl
            << "sudo sh -c 'echo \"0403 c7d9\" > /sys/bus/usb-serial/drivers/ftdi_sio/new_id'" << Qt::endl
            << "sleep 1.5" << Qt::endl
            << "cd /home/pi/daemons" << Qt::endl
            << daemonstart << Qt::endl;
        mFile.close();
    } else {
        qDebug() << "No Consult Selected";
        mFile.open(QIODevice::ReadWrite | QIODevice::Truncate | QIODevice::Text);
        QTextStream out(&mFile);
        out << "#!/bin/sh" << Qt::endl
            << "sudo ifdown can0" << Qt::endl
            << "sudo ifup can0" << Qt::endl
            << "cd /home/pi/daemons" << Qt::endl
            << daemonstart << Qt::endl;
        mFile.close();
    }
}

void Connect::canbitratesetup(const int &cansetting)
{
    QString canbitrate;
    switch (cansetting) {
    case 0:
        canbitrate = "250000";
        break;
    case 1:
        canbitrate = "500000";
        break;
    case 2:
        canbitrate = "1000000";
        break;
    }
    QString fileName = "/etc/network/interfaces";
    QFile mFile(fileName);
    mFile.open(QIODevice::ReadWrite | QIODevice::Truncate | QIODevice::Text);

    QString path = "/etc/wpa_supplicant/";

    if (QFileInfo::exists(path)) {
        QTextStream out(&mFile);
        out << "# interfaces(5) file used by ifup(8) and ifdown(8)" << Qt::endl
            << "# Please note that this file is written to be used with dhcpcd" << Qt::endl
            << "# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'" << Qt::endl
            << "# Include files from /etc/network/interfaces.d:" << Qt::endl
            << "source-directory /etc/network/interfaces.d" << Qt::endl
            << "#Automatically start CAN Interface" << Qt::endl
            << "auto can0" << Qt::endl
            << "iface can0 can static" << Qt::endl
            << "bitrate " << canbitrate << Qt::endl;
    } else {
        // Custo Yocto image

        QTextStream out(&mFile);
        out << "#!/bin/sh" << Qt::endl
            << "# /etc/network/interfaces -- configuration file for ifup(8), ifdown(8)" << Qt::endl
            << "# The loopback interface" << Qt::endl
            << "auto lo" << Qt::endl
            << "iface lo inet loopback" << Qt::endl
            << "# Wireless interfaces" << Qt::endl
            << "auto wlan0" << Qt::endl
            << "    iface wlan0 inet dhcp" << Qt::endl
            << "    hostname PowerTuneDigital" << Qt::endl
            << "    wireless_mode managed" << Qt::endl
            << "   wireless_essid any" << Qt::endl
            << "   wpa-driver wext" << Qt::endl
            << "    wpa-conf /etc/wpa_supplicant.conf" << Qt::endl
            << "    iface atml0 inet dhcp" << Qt::endl
            << "# Wired or wireless interfaces" << Qt::endl
            << "auto eth0" << Qt::endl
            << "    iface eth0 inet dhcp" << Qt::endl
            << "# Automatically start CAN Interface" << Qt::endl
            << "    auto can0" << Qt::endl
            << "   iface can0 inet manual" << Qt::endl
            << "    pre-up /sbin/ip link set can0 type can bitrate " << canbitrate << Qt::endl
            << "    up /sbin/ifconfig can0 up" << Qt::endl
            << "    down /sbin/ifconfig can0 down" << Qt::endl;
    }


    mFile.close();

    // Reboot the PI for settings to take Effect
    reboot();
}


//////////
void Connect::LiveReqMsg(const int &val1, const int &val2, const int &val3, const int &val4, const int &val5,
                         const int &val6, const int &val7, const int &val8, const int &val9, const int &val10,
                         const int &val11, const int &val12, const int &val13, const int &val14, const int &val15,
                         const int &val16, const int &val17, const int &val18, const int &val19, const int &val20,
                         const int &val21, const int &val22, const int &val23, const int &val24, const int &val25,
                         const int &val26, const int &val27, const int &val28, const int &val29, const int &val30,
                         const int &val31, const int &val32, const int &val33, const int &val34, const int &val35,
                         const int &val36, const int &val37, const int &val38, const int &val39, const int &val40,
                         const int &val41, const int &val42, const int &val43, const int &val44, const int &val45)
{
    QString Message;

    if (val1 == 2) {
        Message.append("0x00,0x01,");
    }  // RPM}
    if (val2 == 2) {
        Message.append("0x02,0x03,");
    }  // RPMREF}
    if (val3 == 2) {
        Message.append("0x04,0x05,");
    }  // MAFVoltage}
    if (val4 == 2) {
        Message.append("0x06,0x07,");
    }  // RHMAFVoltage}
    if (val5 == 2) {
        Message.append("0x08,");
    }  // Coolant Temp}
    if (val6 == 2) {
        Message.append("0x09,");
    }  // LH 02 volt}
    if (val7 == 2) {
        Message.append("0x0a,");
    }  // RH 02 volt}
    if (val8 == 2) {
        Message.append("0x0b,");
    }  // Speed}
    if (val9 == 2) {
        Message.append("0x0c,");
    }  // Battery Voltage}
    if (val10 == 2) {
        Message.append("0x0d,");
    }  // TPS Voltage}
    if (val11 == 2) {
        Message.append("0x0f,");
    }  // FuelTemp}
    if (val12 == 2) {
        Message.append("0x11,");
    }  // Intake Temp}
    if (val13 == 2) {
        Message.append("0x12,");
    }  // EGT}
    if (val14 == 2) {
        Message.append("0x13,");
    }  // Digital Bit Register}
    if (val15 == 2) {
        Message.append("0x14,0x15,");
    }  // Injection Time (LH)}
    if (val16 == 2) {
        Message.append("0x16,");
    }  // Ignition Timing}
    if (val17 == 2) {
        Message.append("0x17,");
    }  // AAC Valve (Idle Air Valve %)}
    if (val18 == 2) {
        Message.append("0x1a,");
    }  // A/F ALPHA-LH}
    if (val19 == 2) {
        Message.append("0x1b,");
    }  // A/F ALPHA-RH}
    if (val20 == 2) {
        Message.append("0x1c,");
    }  // A/F ALPHA-LH (SELFLEARN)}
    if (val21 == 2) {
        Message.append("0x1d,");
    }  // A/F ALPHA-RH (SELFLEARN)}
    if (val22 == 2) {
        Message.append("0x1e,");
    }  // Digital Control Register 1}
    if (val23 == 2) {
        Message.append("0x1f,");
    }  // Digital Control Register 2}
    if (val24 == 2) {
        Message.append("0x21,");
    }  // M/R F/C MNT}
    if (val25 == 2) {
        Message.append("0x22,0x23,");
    }  // Injector time (RH)}
    if (val26 == 2) {
        Message.append("0x28,");
    }  // Waste Gate Solenoid %}
    if (val27 == 2) {
        Message.append("0x29,");
    }  // Turbo Boost Sensor, Voltage}
    if (val28 == 2) {
        Message.append("0x2a,");
    }  // Engine Mount On/Off}
    if (val29 == 2) {
        Message.append("0x2e,");
    }  // Position Counter}
    if (val30 == 2) {
        Message.append("0x25,");
    }  // Purg. Vol. Control Valve, Step}
    if (val31 == 2) {
        Message.append("0x26,");
    }  // Tank Fuel Temperature, C}
    if (val32 == 2) {
        Message.append("0x27,");
    }  // FPCM DR, Voltage}
    if (val33 == 2) {
        Message.append("0x2f,");
    }  // Fuel Gauge, Voltage}
    if (val34 == 2) {
        Message.append("0x30,");
    }  // FR O2 Heater-B1}
    if (val35 == 2) {
        Message.append("0x31,");
    }  // FR O2 Heater-B2}
    if (val36 == 2) {
        Message.append("0x32,");
    }  // Ignition Switch}
    if (val37 == 2) {
        Message.append("0x33,");
    }  // CAL/LD Value, %}
    if (val38 == 2) {
        Message.append("0x34,");
    }  // B/Fuel Schedule, mS}
    if (val39 == 2) {
        Message.append("0x35,");
    }  // RR O2 Sensor Voltage}
    if (val40 == 2) {
        Message.append("0x36,");
    }  // RR O2 Sensor-B2 Voltage}
    if (val41 == 2) {
        Message.append("0x37,");
    }  // Absolute Throttle Position, Voltage }
    if (val42 == 2) {
        Message.append("0x38,");
    }  // MAF gm/S}
    if (val43 == 2) {
        Message.append("0x39,");
    }  // Evap System Pressure, Voltage}
    if (val44 == 2) {
        Message.append("0x3a,0x4a,");
    }  // Absolute Pressure Sensor,Voltage}
    if (val45 == 2) {
        Message.append("0x52,0x53,");
    }  // FPCM F/P Voltage}
    Message.remove(Message.length() - 1, 1);  // remove the last comma from string
    // qDebug()<< "write" <<Message;


    QString fileName = "/home/pi/daemons/Consult.cfg";  // This will be the correct path on pi
    // QString fileName = "Consult.cfg";//for testing on windows
    QFile mFile(fileName);
    mFile.open(QIODevice::ReadWrite | QIODevice::Truncate | QIODevice::Text);

    QTextStream out(&mFile);
    out << Message;
    mFile.close();

    // Reboot the PI for settings to take Effect
    reboot();
}

void Connect::openConnection(const QString &portName, const int &ecuSelect, const int &canbase, const int &rpmcanbase)
{
    ecu = ecuSelect;
    selectedPort = portName;
    canbaseadress = canbase;
    rpmcanbaseadress = rpmcanbase;

    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->addLogMessage(
            QStringLiteral("INFO"),
            QStringLiteral("Opening connection (ECU=%1, CAN base=%2)").arg(ecuSelect).arg(canbase));
        m_diagnosticsProvider->setCanStatus(true, QStringLiteral("Generic CAN"));
    }

    m_extender->openCAN(canbaseadress, rpmcanbaseadress);
    m_udpreceiver->startreceiver();
}
void Connect::closeConnection()
{
    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"), QStringLiteral("Connection closed"));
        m_diagnosticsProvider->setCanStatus(false, QString());
    }
    m_calculations->stop();
    m_udpreceiver->closeConnection();
}

void Connect::update()
{
    if (m_diagnosticsProvider)
        m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"), QStringLiteral("System update initiated"));
    QProcess *p = new QProcess(this);

    if (p) {
        p->setEnvironment(QProcess::systemEnvironment());
        p->setProcessChannelMode(QProcess::MergedChannels);
        p->start("/home/pi/src/updatePowerTune.sh", QStringList() << "echo" << "hye");
        p->waitForStarted();

        connect(p, &QProcess::readyReadStandardOutput, this, &Connect::processOutput);
    }
}

void Connect::changefolderpermission()
{
    QProcess *process = new QProcess(this);
    QString program = "sudo";
    QStringList arguments;
    arguments << "chown" << "-R" << "pi:pi" << "/home/pi/KTracks";

    process->start(program, arguments);
    process->waitForFinished(600000);  // 10 minutes time before timeout
    reboot();
}

void Connect::shutdown()
{
    m_connectionData->setSerialStat("Shutting Down");
    if (m_diagnosticsProvider)
        m_diagnosticsProvider->addLogMessage(QStringLiteral("WARN"), QStringLiteral("System shutdown initiated"));
    QProcess::startDetached(QStringLiteral("shutdown"), QStringList() << QStringLiteral("-h") << QStringLiteral("now"));
}

void Connect::reboot()
{
    m_connectionData->setSerialStat("Rebooting");
    if (m_diagnosticsProvider)
        m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"), QStringLiteral("System reboot initiated"));
    QProcess::startDetached(QStringLiteral("reboot"), QStringList());
}

void Connect::turnscreen()
{
    m_connectionData->setSerialStat("Turning Screen");
    QProcess *process = new QProcess(this);
    QString program = "sudo";
    QStringList arguments;
    arguments << "cp" << "/home/pi/src/config.txt" << "/boot/config.txt";

    process->start(program, arguments);
    process->waitForFinished(600000);  // 10 minutes time before timeout
    reboot();
}

void Connect::candump()
{
    QProcess *p = new QProcess(this);

    if (p) {
        p->setEnvironment(QProcess::systemEnvironment());
        p->setProcessChannelMode(QProcess::MergedChannels);
        p->start("/home/pi/daemons/OBD /dev/ttyUSB0", QStringList() << "echo" << "hye");
        p->waitForStarted();

        connect(p, &QProcess::readyReadStandardOutput, this, &Connect::processOutput);
        // connect(p, &QProcess::readyReadStandardError, this, &Connect::ReadErr);
    }
}
void Connect::minicom()
{
    QProcess *p = new QProcess(this);

    if (p) {
        p->setEnvironment(QProcess::systemEnvironment());
        p->setProcessChannelMode(QProcess::MergedChannels);
        p->start("minicom", QStringList() << "echo" << "hye");
        p->waitForStarted();

        connect(p, &QProcess::readyReadStandardOutput, this, &Connect::processOutput);
        // connect(p, &QProcess::readyReadStandardError, this, &Connect::ReadErr);
    }
}


// this gets called whenever the process has something to say...
void Connect::processOutput()
{
    // qDebug() << "processing";
    QProcess *p = dynamic_cast<QProcess *>(sender());

    //  if (p)
    QString output = p->readAllStandardOutput();
    //       qDebug() << "redirecting" << output;
    m_connectionData->setSerialStat(output);
}

void Connect::updatefinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    // qDebug() << "code" <<exitCode;
    // qDebug() << "status" <<exitStatus;
    QString fileName = "/home/pi/build/PowertuneQMLGui";
    QFile file(fileName);
    if (QFileInfo::exists(fileName)) {
        m_connectionData->setSerialStat("Update Successful");
        file.close();
    } else {
        m_connectionData->setSerialStat("Update Unsuccessful");
    }
}

void Connect::RequestLicence()
{
    QProcess *process = new QProcess(this);
    QString program = "/home/pi/licencerequest";
    QStringList arguments;  // No arguments needed for this command

    process->start(program, arguments);
    process->waitForFinished(600000);  // 10 minutes time before timeout

    QString path = "/home/pi/Licrequest.lic";
    QFile inputFile(path);
    if (inputFile.open(QIODevice::ReadOnly)) {
        QTextStream in(&inputFile);
        while (!in.atEnd()) {
            QString line = in.readLine();
            m_connectionData->setSerialStat(line);
        }
        inputFile.close();
    }
}


void Connect::restartDaemon()
{
    if (m_diagnosticsProvider)
        m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"), QStringLiteral("Daemon restart initiated"));
    QProcess *process = new QProcess(this);
    QString program = "/home/pi/startdaemon.sh";
    QStringList arguments;

    process->start(program, arguments);
    connect(process, &QProcess::readyReadStandardOutput, this, &Connect::processOutput);
}
