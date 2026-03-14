
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

#include "../Can/CanManager.h"
#include "../Can/CanStartupManager.h"
#include "../Can/CanTransport.h"
#include "../Hardware/Extender.h"
#include "../Utils/Calculations.h"
#include "../Utils/CalibrationHelper.h"
#include "../Utils/DataLogger.h"
#include "../Utils/OverlayConfigManager.h"
#include "../Utils/ShiftIndicatorHelper.h"
#include "../Utils/SteinhartCalculator.h"
#include "../Utils/UDPReceiver.h"
#include "../Utils/wifiscanner.h"
#include "DiagnosticsProvider.h"
#include "DashboardLockService.h"
#include "DifferentialSensorCalc.h"
#include "ExBoardConfigManager.h"
#include "Models/CanFrameModel.h"
#include "Models/DataModels.h"
#include "Models/UIState.h"
#include "OverlayConfigDefaults.h"
#include "PropertyRouter.h"
#include "ScreenControlService.h"
#include "SensorRegistry.h"
#include "appsettings.h"
#include "dashboard.h"

#include <QByteArrayMatcher>
#include <QCoreApplication>
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


// File-scope globals migrated to Connect class members (Phase 5.3)

bool Connect::hasDdcBrightness() const
{
    return m_screenControlService && m_screenControlService->isDdc();
}

bool Connect::hasBrightnessControl() const
{
    return m_screenControlService && m_screenControlService->hasBrightnessControl();
}

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
      m_diagnosticsProvider(nullptr),
      m_screenControlService(nullptr),
      m_dashboardLockService(nullptr),
      m_canStartupManager(nullptr),
      m_canTransport(nullptr),
      m_canManager(nullptr)

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
    m_canStartupManager = new CanStartupManager(this);
    m_canTransport = new CanTransport(this);
    m_canManager = new CanManager(this);
    m_canManager->setTransport(m_canTransport);
    m_canManager->registerModule(m_extender);
    // * Phase 6: Create SteinhartCalculator, wire into Extender, connect calibration signals
    m_steinhartCalc = new SteinhartCalculator(this);
    m_extender->setSteinhartCalculator(m_steinhartCalc);
    m_extender->connectCalibrationSignals();
    m_calibrationHelper = new CalibrationHelper(m_steinhartCalc, this);
    // * Phase 7: Create SensorRegistry for runtime sensor tracking
    m_sensorRegistry = new SensorRegistry(this);
    m_udpreceiver->setSensorRegistry(m_sensorRegistry);
    m_extender->setSensorRegistry(m_sensorRegistry);
    // * Phase 8: Create DiagnosticsProvider and wire to SensorRegistry + Extender
    m_diagnosticsProvider = new DiagnosticsProvider(this);
    m_diagnosticsProvider->setSensorRegistry(m_sensorRegistry);
    m_diagnosticsProvider->setPropertyRouter(m_propertyRouter);
    m_diagnosticsProvider->setAppSettings(m_appSettings);
    m_extender->setDiagnosticsProvider(m_diagnosticsProvider);
    connect(m_canStartupManager, &CanStartupManager::startupFailed, this, [this](const QString &reason) {
        if (m_diagnosticsProvider) {
            m_diagnosticsProvider->addLogMessage(QStringLiteral("ERROR"), reason);
            m_diagnosticsProvider->recordCanError();
        }
    });
    connect(m_canTransport, &CanTransport::errorOccurred, this, [this](const QString &message) {
        if (m_diagnosticsProvider) {
            m_diagnosticsProvider->addLogMessage(QStringLiteral("ERROR"), message);
            m_diagnosticsProvider->recordCanError();
        }
    });
    connect(m_canManager, &CanManager::activationFailed, this, [this](const QString &reason) {
        if (m_diagnosticsProvider)
            m_diagnosticsProvider->addLogMessage(QStringLiteral("ERROR"), reason);
    });
    m_overlayConfigManager = new OverlayConfigManager(this);
    m_shiftIndicatorHelper = new ShiftIndicatorHelper(this);
    m_canFrameModel = new CanFrameModel(m_connectionData, m_extender, this);
    m_exBoardConfigManager = new ExBoardConfigManager(this);
    m_exBoardConfigManager->setAppSettings(m_appSettings);
    m_exBoardConfigManager->setCalibrationHelper(m_calibrationHelper);
    m_exBoardConfigManager->setSensorRegistry(m_sensorRegistry);
    m_differentialSensorCalc = new DifferentialSensorCalc(this);
    m_differentialSensorCalc->setExpanderBoardData(m_expanderBoardData);
    m_differentialSensorCalc->setSensorRegistry(m_sensorRegistry);
    {
        const QVariantMap diffCfg = m_exBoardConfigManager->getDifferentialSensorConfig();
        const QString formulaStr = diffCfg.value(QStringLiteral("formula"), QStringLiteral("percentage")).toString();
        DifferentialSensorCalc::Formula formula = DifferentialSensorCalc::Percentage;
        if (formulaStr == QLatin1String("differential"))
            formula = DifferentialSensorCalc::Differential;
        else if (formulaStr == QLatin1String("ratio"))
            formula = DifferentialSensorCalc::Ratio;
        m_differentialSensorCalc->configure(
            diffCfg.value(QStringLiteral("enabled"), false).toBool(),
            diffCfg.value(QStringLiteral("channelA"), 0).toInt(),
            diffCfg.value(QStringLiteral("channelB"), 1).toInt(),
            formula,
            diffCfg.value(QStringLiteral("offset"), 0.0).toDouble());
    }
    m_screenControlService = new ScreenControlService(this);
    m_screenControlService->setAppSettings(m_appSettings);
    m_screenControlService->setUIState(m_uiState);
    m_screenControlService->setExBoardConfigManager(m_exBoardConfigManager);
    m_dashboardLockService = new DashboardLockService(this);
    m_dashboardLockService->setAppSettings(m_appSettings);
    m_dashboardLockService->initialize();
    m_overlayConfigDefaults = new OverlayConfigDefaults(this);
    m_overlayConfigDefaults->setAppSettings(m_appSettings);
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
    engine->rootContext()->setContextProperty("OverlayConfig", m_overlayConfigManager);
    engine->rootContext()->setContextProperty("ShiftHelper", m_shiftIndicatorHelper);
    engine->rootContext()->setContextProperty("CanMonitorModel", m_canFrameModel);
    engine->rootContext()->setContextProperty("ExBoardConfig", m_exBoardConfigManager);
    engine->rootContext()->setContextProperty("ScreenControl", m_screenControlService);
    engine->rootContext()->setContextProperty("DashboardLock", m_dashboardLockService);
    engine->rootContext()->setContextProperty("OverlayDefaults", m_overlayConfigDefaults);
    m_appSettings->setExtender(m_extender);
    m_appSettings->setSteinhartCalculator(m_steinhartCalc);
    m_appSettings->readandApplySettings();
    connect(qApp, &QCoreApplication::aboutToQuit, m_appSettings, &AppSettings::sync);
    // * Phase 7: Populate SensorRegistry with configured input channels
    m_sensorRegistry->refreshEcuAnalogChannels();
    m_sensorRegistry->refreshExtenderAnalogInputs();
    m_sensorRegistry->refreshExtenderDigitalInputs();
    m_sensorRegistry->refreshEcuDigitalInputs();

    checkifraspberrypi();
    m_screenControlService->restoreStartupBrightness();
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
    while (m_dashFilenames.size() <= index)
        m_dashFilenames.append(QString());
    m_dashFilenames[index] = filename;
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
    if (!m_screenControlService) {
        m_uiState->setscreen(false);
        m_brightnessMethod = BrightnessMethod::None;
        return;
    }

    m_screenControlService->detectBackend();
    m_uiState->setscreen(m_screenControlService->hasBrightnessControl());

    if (m_screenControlService->isDdc())
        m_brightnessMethod = BrightnessMethod::DdcUtil;
    else if (m_screenControlService->hasBrightnessControl())
        m_brightnessMethod = BrightnessMethod::Sysfs;
    else
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
    if (index < 0 || index >= m_dashFilenames.size())
        return;

    const QString &filename = m_dashFilenames.at(index);
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
    if (m_screenControlService)
        m_screenControlService->applyHardwareBrightness(brightness);
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

static const QHash<int, int> s_registerMap = {
    {0x00, 0},  {0x01, 1},  {0x02, 2},  {0x03, 3},  {0x04, 4},  {0x05, 5},  {0x06, 6},  {0x07, 7},  {0x08, 8},
    {0x09, 9},  {0x0a, 10}, {0x0b, 11}, {0x0c, 12}, {0x0d, 13}, {0x0f, 14}, {0x11, 15}, {0x12, 16}, {0x13, 17},
    {0x14, 18}, {0x15, 19}, {0x16, 20}, {0x17, 21}, {0x1a, 22}, {0x1b, 23}, {0x1c, 24}, {0x1d, 25}, {0x1e, 26},
    {0x1f, 27}, {0x21, 28}, {0x22, 29}, {0x23, 30}, {0x25, 35}, {0x26, 36}, {0x27, 37}, {0x28, 31}, {0x29, 32},
    {0x2a, 33}, {0x2e, 34}, {0x2f, 38}, {0x30, 39}, {0x31, 40}, {0x32, 41}, {0x33, 42}, {0x34, 43}, {0x35, 44},
    {0x36, 45}, {0x37, 46}, {0x38, 47}, {0x39, 48}, {0x3a, 49}, {0x4a, 50}, {0x52, 51}, {0x53, 52},
};

void Connect::checkReg()
{
    bool ok;
    QStringList list;
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
    for (int i = 0; i < list.length(); ++i) {
        int hexVal = list[i].toInt(&ok, 16);
        if (!ok || hexVal == 0xFE)
            continue;
        auto it = s_registerMap.constFind(hexVal);
        if (it != s_registerMap.constEnd())
            m_connectionData->setsupportedReg(it.value());
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

void Connect::canbitratesetup(const int &cansetting)
{
    if (m_appSettings)
        m_appSettings->setValue(QStringLiteral("ui/bitrateSelect"), cansetting);

    const int bitrate = canBitrateForSelection(cansetting);
    if (bitrate <= 0) {
        if (m_connectionData)
            m_connectionData->setSerialStat(QStringLiteral("Unsupported CAN bitrate selection"));
        return;
    }

    if (!m_canTransport || !m_canTransport->isConnected()) {
        if (m_connectionData)
            m_connectionData->setSerialStat(QStringLiteral("CAN bitrate saved and will apply on next connection"));
        if (m_diagnosticsProvider) {
            m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"),
                                                 QStringLiteral("Saved CAN bitrate %1 for next startup").arg(bitrate));
        }
        return;
    }

    if (m_canManager)
        m_canManager->deactivateModule();
    if (m_canTransport)
        m_canTransport->close();

    if (!startActiveCanModule()) {
        if (m_connectionData)
            m_connectionData->setSerialStat(QStringLiteral("Failed to apply CAN bitrate %1").arg(bitrate));
        return;
    }

    if (m_connectionData)
        m_connectionData->setSerialStat(QStringLiteral("Applied CAN bitrate %1").arg(bitrate));
}


//////////
struct ConsultRegDef
{
    const char *hexCodes;
};

static const ConsultRegDef s_consultRegs[] = {
    {"0x00,0x01"},  //  0: RPM
    {"0x02,0x03"},  //  1: RPM Reference
    {"0x04,0x05"},  //  2: MAF Voltage
    {"0x06,0x07"},  //  3: RH MAF Voltage
    {"0x08"},       //  4: Coolant Temp
    {"0x09"},       //  5: LH O2 Voltage
    {"0x0a"},       //  6: RH O2 Voltage
    {"0x0b"},       //  7: Speed
    {"0x0c"},       //  8: Battery Voltage
    {"0x0d"},       //  9: TPS Voltage
    {"0x0f"},       // 10: Fuel Temp
    {"0x11"},       // 11: Intake Temp
    {"0x12"},       // 12: EGT
    {"0x13"},       // 13: Digital Bit Register
    {"0x14,0x15"},  // 14: Injection Time (LH)
    {"0x16"},       // 15: Ignition Timing
    {"0x17"},       // 16: AAC Valve (Idle Air Valve %)
    {"0x1a"},       // 17: A/F Alpha LH
    {"0x1b"},       // 18: A/F Alpha RH
    {"0x1c"},       // 19: A/F Alpha LH (SelfLearn)
    {"0x1d"},       // 20: A/F Alpha RH (SelfLearn)
    {"0x1e"},       // 21: Digital Control Register 1
    {"0x1f"},       // 22: Digital Control Register 2
    {"0x21"},       // 23: M/R F/C MNT
    {"0x22,0x23"},  // 24: Injector Time (RH)
    {"0x28"},       // 25: Waste Gate Solenoid %
    {"0x29"},       // 26: Turbo Boost Sensor Voltage
    {"0x2a"},       // 27: Engine Mount On/Off
    {"0x2e"},       // 28: Position Counter
    {"0x25"},       // 29: Purg. Vol. Control Valve Step
    {"0x26"},       // 30: Tank Fuel Temperature C
    {"0x27"},       // 31: FPCM DR Voltage
    {"0x2f"},       // 32: Fuel Gauge Voltage
    {"0x30"},       // 33: FR O2 Heater B1
    {"0x31"},       // 34: FR O2 Heater B2
    {"0x32"},       // 35: Ignition Switch
    {"0x33"},       // 36: CAL/LD Value %
    {"0x34"},       // 37: B/Fuel Schedule mS
    {"0x35"},       // 38: RR O2 Sensor Voltage
    {"0x36"},       // 39: RR O2 Sensor B2 Voltage
    {"0x37"},       // 40: Absolute Throttle Position Voltage
    {"0x38"},       // 41: MAF gm/S
    {"0x39"},       // 42: Evap System Pressure Voltage
    {"0x3a,0x4a"},  // 43: Absolute Pressure Sensor Voltage
    {"0x52,0x53"},  // 44: FPCM F/P Voltage
};

static constexpr int kConsultRegCount = sizeof(s_consultRegs) / sizeof(s_consultRegs[0]);

void Connect::LiveReqMsg(const QVariantList &values)
{
    QString message;

    const int count = qMin(values.size(), kConsultRegCount);
    for (int i = 0; i < count; ++i) {
        if (values.at(i).toInt() == 2) {
            if (!message.isEmpty())
                message.append(QLatin1Char(','));
            message.append(QLatin1String(s_consultRegs[i].hexCodes));
        }
    }

    if (message.isEmpty())
        return;

    QString fileName = "/home/pi/daemons/Consult.cfg";
    QFile mFile(fileName);
    mFile.open(QIODevice::ReadWrite | QIODevice::Truncate | QIODevice::Text);

    QTextStream out(&mFile);
    out << message;
    mFile.close();

    reboot();
}

void Connect::openConnection(const QString &portName, const int &ecuSelect, const int &canbase, const int &rpmcanbase)
{
    m_ecu = ecuSelect;
    m_selectedPort = portName;
    m_canBaseAddress = canbase;
    m_rpmCanBaseAddress = rpmcanbase;

    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->addLogMessage(
            QStringLiteral("INFO"),
            QStringLiteral("Opening connection (ECU=%1, CAN base=%2)").arg(ecuSelect).arg(canbase));
        m_diagnosticsProvider->setCanStatus(false, QString());
    }

    if (!startActiveCanModule()) {
        if (m_connectionData)
            m_connectionData->setSerialStat(QStringLiteral("Native CAN startup failed"));
        return;
    }

    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->setCanStatus(true, QStringLiteral("EX Board CAN"));
        m_diagnosticsProvider->setConnectionInfo(false, QString(), 0, QStringLiteral("CAN"));
    }

    if (m_connectionData)
        m_connectionData->setSerialStat(QStringLiteral("Native CAN active"));
}
void Connect::closeConnection()
{
    if (m_canManager)
        m_canManager->deactivateModule();
    if (m_canTransport)
        m_canTransport->close();

    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"), QStringLiteral("Connection closed"));
        m_diagnosticsProvider->setCanStatus(false, QString());
    }
    m_calculations->stop();
    m_udpreceiver->closeConnection();
}

int Connect::canBitrateForSelection(int selection) const
{
    switch (selection) {
    case 0:
        return 250000;
    case 1:
        return 500000;
    case 2:
        return 1000000;
    default:
        return 0;
    }
}

bool Connect::startActiveCanModule()
{
    if (!m_canStartupManager || !m_canTransport || !m_canManager)
        return false;

    if (!m_canManager->hasModule(m_ecu)) {
        if (m_diagnosticsProvider) {
            m_diagnosticsProvider->addLogMessage(
                QStringLiteral("ERROR"),
                QStringLiteral("ECU backend %1 does not have a native CAN module in this phase").arg(m_ecu));
        }
        return false;
    }

    const int bitrateSelection = m_appSettings ? m_appSettings->getValue(QStringLiteral("ui/bitrateSelect"), 2).toInt() : 2;
    const int bitrate = canBitrateForSelection(bitrateSelection);
    if (bitrate <= 0) {
        if (m_diagnosticsProvider)
            m_diagnosticsProvider->addLogMessage(QStringLiteral("ERROR"), QStringLiteral("Invalid CAN bitrate setting"));
        return false;
    }

    if (!m_canStartupManager->prepareInterface(QStringLiteral("can0"), bitrate))
        return false;

    m_canTransport->setInterfaceName(QStringLiteral("can0"));
    if (!m_canTransport->open())
        return false;

    const QVariantMap moduleConfig = {{QStringLiteral("canBaseId"), m_canBaseAddress},
                                      {QStringLiteral("rpmBaseId"), m_rpmCanBaseAddress}};

    if (!m_canManager->activateModule(m_ecu, moduleConfig)) {
        m_canTransport->close();
        return false;
    }

    return true;
}

void Connect::update()
{
    if (m_diagnosticsProvider)
        m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"), QStringLiteral("System update initiated"));

    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->addLogMessage(
            QStringLiteral("WARN"),
            QStringLiteral("In-app update is unavailable: no updater script is configured in this repository"));
    }

    if (m_connectionData) {
        m_connectionData->setSerialStat(
            QStringLiteral("Update unavailable: use the documented CMake/Yocto deployment workflow"));
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
    if (m_appSettings)
        m_appSettings->sync();
    QProcess::startDetached(QStringLiteral("shutdown"), QStringList() << QStringLiteral("-h") << QStringLiteral("now"));
}

void Connect::reboot()
{
    m_connectionData->setSerialStat("Rebooting");
    if (m_diagnosticsProvider)
        m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"), QStringLiteral("System reboot initiated"));
    if (m_appSettings)
        m_appSettings->sync();
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

