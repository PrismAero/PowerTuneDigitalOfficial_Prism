
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
#include "../Can/Protocols/PTExtenderCan.h"
#include "../Hardware/Extender.h"
#include "../Utils/Calculations.h"
#include "../Utils/CalibrationHelper.h"
#include "../Utils/DataLogger.h"
#include "../Utils/OverlayPositionManager.h"
#include "../Utils/ShiftIndicatorHelper.h"
#include "../Utils/SteinhartCalculator.h"
#include "../Utils/wifiscanner.h"
#include "DiagnosticsProvider.h"
#include "DashboardLockService.h"
#include "DemoModeService.h"
#include "DifferentialSensorCalc.h"
#include "ExBoardConfigManager.h"
#include "PTExtenderConfigManager.h"
#include "Models/CanFrameModel.h"
#include "Models/DataModels.h"
#include "Models/UIState.h"
#include "OverlayConfigDefaults.h"
#include "PropertyRouter.h"
#include "ScreenControlService.h"
#include "SensorRegistry.h"
#include "UpdateManagerService.h"
#include "appsettings.h"

#include <QByteArrayMatcher>
#include <QCoreApplication>
#include <QDebug>
#include <QDir>
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
namespace {
QString dashboardsDirectoryPath()
{
#ifdef Q_OS_LINUX
    return QStringLiteral("/home/root/UserDashboards");
#else
    const QString appData = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(appData);
    dir.mkpath(QStringLiteral("UserDashboards"));
    return dir.filePath(QStringLiteral("UserDashboards"));
#endif
}
}  // namespace

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
      m_appSettings(nullptr),
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
      m_timingData(nullptr),
      m_connectionData(nullptr),
      m_settingsData(nullptr),
      m_propertyRouter(nullptr),
      m_steinhartCalc(nullptr),
      m_calibrationHelper(nullptr),
      m_sensorRegistry(nullptr),
      m_diagnosticsProvider(nullptr),
      m_screenControlService(nullptr),
      m_dashboardLockService(nullptr),
      m_demoModeService(nullptr),
      m_updateManagerService(nullptr),
      m_canStartupManager(nullptr),
      m_canTransport(nullptr),
      m_canManager(nullptr),
      m_ptExtenderCan(nullptr),
      m_ptExtenderConfigManager(nullptr)

{
    // * Phase 2: Create domain data models
    m_uiState = new UIState(this);

    m_engineData = new EngineData(this);
    m_vehicleData = new VehicleData(this);
    m_gpsData = new GPSData(this);
    m_analogInputs = new AnalogInputs(this);
    m_digitalInputs = new DigitalInputs(this);
    m_expanderBoardData = new ExpanderBoardData(this);
    m_timingData = new TimingData(this);
    m_connectionData = new ConnectionData(this);
    m_settingsData = new SettingsData(this);
    m_appSettings = new AppSettings(m_settingsData, m_uiState, m_vehicleData, m_analogInputs, m_expanderBoardData,
                                    m_engineData, m_connectionData, m_digitalInputs, this);
    m_propertyRouter = new PropertyRouter(m_engineData, m_vehicleData, m_gpsData, m_analogInputs, m_digitalInputs,
                                          m_expanderBoardData, m_connectionData, m_settingsData, m_timingData,
                                          m_uiState, this);
    m_datalogger = new datalogger(m_engineData, m_vehicleData, m_expanderBoardData, m_digitalInputs, m_timingData,
                                  this);
    m_calculations = new calculations(m_vehicleData, m_engineData, m_timingData, m_settingsData, this);
    m_calculations->setExpanderBoardData(m_expanderBoardData);
    m_wifiscanner = new WifiScanner(m_connectionData, this);
    m_extender = new Extender(m_digitalInputs, m_expanderBoardData, m_engineData, m_settingsData, m_vehicleData,
                              m_connectionData, this);
    m_canStartupManager = new CanStartupManager(this);
    m_canTransport = new CanTransport(this);
    m_canManager = new CanManager(this);
    m_canManager->setTransport(m_canTransport);
    m_canManager->registerModule(m_extender);
    m_ptExtenderCan =
        new PTExtenderCan(m_digitalInputs, m_expanderBoardData, m_vehicleData, m_connectionData, this);
    m_canManager->registerModule(m_ptExtenderCan);
    m_steinhartCalc = new SteinhartCalculator(this);
    m_extender->setSteinhartCalculator(m_steinhartCalc);
    m_extender->connectCalibrationSignals();
    m_calibrationHelper = new CalibrationHelper(m_steinhartCalc, this);
    m_sensorRegistry = new SensorRegistry(this);
    m_sensorRegistry->setAppSettings(m_appSettings);
    m_propertyRouter->setSensorRegistry(m_sensorRegistry);
    m_extender->setSensorRegistry(m_sensorRegistry);
    m_ptExtenderCan->setSensorRegistry(m_sensorRegistry);
    m_diagnosticsProvider = new DiagnosticsProvider(this);
    m_diagnosticsProvider->setSensorRegistry(m_sensorRegistry);
    m_diagnosticsProvider->setPropertyRouter(m_propertyRouter);
    m_diagnosticsProvider->setAppSettings(m_appSettings);
    m_extender->setDiagnosticsProvider(m_diagnosticsProvider);
    m_ptExtenderCan->setDiagnosticsProvider(m_diagnosticsProvider);
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
    connect(m_canTransport, &CanTransport::connectionChanged, this, [this](bool connected) {
        if (m_diagnosticsProvider)
            m_diagnosticsProvider->setCanStatus(connected, connected ? activeCanLabel() : QString());
        emit connectionStateChanged(connected, connected ? QStringLiteral("Native CAN active")
                                                         : QStringLiteral("Native CAN disconnected"));
    });
    connect(m_canManager, &CanManager::activationFailed, this, [this](const QString &reason) {
        if (m_diagnosticsProvider)
            m_diagnosticsProvider->addLogMessage(QStringLiteral("ERROR"), reason);
    });
    auto *ptExternalInputTimer = new QTimer(this);
    ptExternalInputTimer->setInterval(200);
    connect(ptExternalInputTimer, &QTimer::timeout, this, [this]() {
        if (!m_canManager || !m_ptExtenderCan || !m_digitalInputs)
            return;
        if (!m_canManager->isModuleActive(PT_EXTENDER_BACKEND_ID))
            return;

        int bitmask = 0;
        if (m_digitalInputs->EXDigitalInput1() > 0.5) bitmask |= (1 << 0);
        if (m_digitalInputs->EXDigitalInput2() > 0.5) bitmask |= (1 << 1);
        if (m_digitalInputs->EXDigitalInput3() > 0.5) bitmask |= (1 << 2);
        if (m_digitalInputs->EXDigitalInput4() > 0.5) bitmask |= (1 << 3);
        if (m_digitalInputs->EXDigitalInput5() > 0.5) bitmask |= (1 << 4);
        if (m_digitalInputs->EXDigitalInput6() > 0.5) bitmask |= (1 << 5);
        if (m_digitalInputs->EXDigitalInput7() > 0.5) bitmask |= (1 << 6);
        if (m_digitalInputs->EXDigitalInput8() > 0.5) bitmask |= (1 << 7);
        m_ptExtenderCan->setExternalInputMask(bitmask);
        m_ptExtenderCan->sendExternalInputState(bitmask);
    });
    ptExternalInputTimer->start();
    m_overlayConfigManager = new OverlayPositionManager(this);
    m_shiftIndicatorHelper = new ShiftIndicatorHelper(this);
    m_canFrameModel = new CanFrameModel(m_connectionData, m_extender, this);
    m_exBoardConfigManager = new ExBoardConfigManager(this);
    m_exBoardConfigManager->setAppSettings(m_appSettings);
    m_exBoardConfigManager->setCalibrationHelper(m_calibrationHelper);
    m_exBoardConfigManager->setSensorRegistry(m_sensorRegistry);
    m_ptExtenderConfigManager = new PTExtenderConfigManager(this);
    m_ptExtenderConfigManager->setAppSettings(m_appSettings);
    m_ptExtenderConfigManager->setPTExtenderCan(m_ptExtenderCan);
    m_ptExtenderCan->setConfigManager(m_ptExtenderConfigManager);
    m_differentialSensorCalc = new DifferentialSensorCalc(this);
    m_differentialSensorCalc->setExpanderBoardData(m_expanderBoardData);
    m_differentialSensorCalc->setSensorRegistry(m_sensorRegistry);
    m_screenControlService = new ScreenControlService(this);
    m_screenControlService->setAppSettings(m_appSettings);
    m_screenControlService->setUIState(m_uiState);
    m_screenControlService->setExBoardConfigManager(m_exBoardConfigManager);
    m_dashboardLockService = new DashboardLockService(this);
    m_dashboardLockService->setAppSettings(m_appSettings);
    m_dashboardLockService->initialize();
    m_demoModeService = new DemoModeService(this);
    m_updateManagerService = new UpdateManagerService(this);
    m_overlayConfigDefaults = new OverlayConfigDefaults(this);
    m_overlayConfigDefaults->setAppSettings(m_appSettings);
    QString mPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(mPath);  // Ensure the directory exists
    dirModel = new QFileSystemModel(this);
    dirModel->setFilter(QDir::NoDotAndDotDot | QDir::AllDirs);
    dirModel->setRootPath(mPath);
    fileModel = new QFileSystemModel(this);
    fileModel->setFilter(QDir::NoDotAndDotDot | QDir::Files);
    fileModel->setRootPath(mPath);

    QQmlApplicationEngine *engine = dynamic_cast<QQmlApplicationEngine *>(parent);
    if (engine == nullptr)
        return;
    // * Phase 2: Expose domain data models to QML
    engine->rootContext()->setContextProperty("UI", m_uiState);
    engine->rootContext()->setContextProperty("Engine", m_engineData);
    engine->rootContext()->setContextProperty("Vehicle", m_vehicleData);
    engine->rootContext()->setContextProperty("GPS", m_gpsData);
    engine->rootContext()->setContextProperty("Analog", m_analogInputs);
    engine->rootContext()->setContextProperty("Digital", m_digitalInputs);
    engine->rootContext()->setContextProperty("Expander", m_expanderBoardData);
    engine->rootContext()->setContextProperty("Timing", m_timingData);
    // * Phase 3: Expose remaining data models to QML
    engine->rootContext()->setContextProperty("Connection", m_connectionData);
    engine->rootContext()->setContextProperty("Settings", m_settingsData);
    // * Phase 3: Expose PropertyRouter for dynamic property access (replaces Dashboard[propName])
    engine->rootContext()->setContextProperty("PropertyRouter", m_propertyRouter);
    engine->rootContext()->setContextProperty("Extender2", m_extender);
    engine->rootContext()->setContextProperty("PTExtenderCan", m_ptExtenderCan);
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
    engine->rootContext()->setContextProperty("ExBoardConfig", m_exBoardConfigManager);
    engine->rootContext()->setContextProperty("PTExtenderConfig", m_ptExtenderConfigManager);
    engine->rootContext()->setContextProperty("ScreenControl", m_screenControlService);
    engine->rootContext()->setContextProperty("DashboardLock", m_dashboardLockService);
    engine->rootContext()->setContextProperty("DemoMode", m_demoModeService);
    engine->rootContext()->setContextProperty("Updater", m_updateManagerService);
    engine->rootContext()->setContextProperty("OverlayDefaults", m_overlayConfigDefaults);
    m_appSettings->setExtender(m_extender);
    m_appSettings->setSteinhartCalculator(m_steinhartCalc);
    m_appSettings->readandApplySettings();
    const auto applyDifferentialConfig = [this]() {
        if (!m_exBoardConfigManager || !m_differentialSensorCalc)
            return;
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
    };
    applyDifferentialConfig();
    connect(m_exBoardConfigManager, &ExBoardConfigManager::configChanged, this, applyDifferentialConfig);
    connect(qApp, &QCoreApplication::aboutToQuit, m_appSettings, &AppSettings::sync);
    // * Phase 7: Populate SensorRegistry with configured extender channels
    m_sensorRegistry->refreshAll();

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

    QFile file(QDir(dashboardsDirectoryPath()).filePath(fullName));
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
    QDir directory(dashboardsDirectoryPath());
    QStringList dashfiles = directory.entryList(QStringList() << "*.txt", QDir::Files);
    m_uiState->setdashfiles(dashfiles);
    // qDebug() <<"files" << dashfiles ;
}

void Connect::readavailablebackrounds()
{
    QStringList dashfiles;

#ifdef Q_OS_LINUX
    // * Linux (Raspberry Pi) - use /home/root/Logo directory
    QDir directory("/home/root/Logo");
    dashfiles = directory.entryList(QStringList() << "*.png" << "*.gif", QDir::Files);
#elif defined(Q_OS_MACOS)
    // * macOS - list bundled graphics resources for development testing
    // * The files are in the qrc, so we provide a static list of available images
    dashfiles << "Logo.png" << "MainDash.png" << "MainDashBlue.png" << "MainDashnew.png"
              << "Racedash.png" << "Racedash800x480.png" << "RPM_BG.png" << "rotary.gif"
              << "test.png" << "StateGIF.gif";
#elif defined(Q_OS_WIN)
    // * Windows - list bundled graphics resources for local UI testing
    dashfiles << "Logo.png" << "MainDash.png" << "MainDashBlue.png" << "MainDashnew.png"
              << "Racedash.png" << "Racedash800x480.png" << "RPM_BG.png" << "rotary.gif"
              << "test.png" << "StateGIF.gif";
#else
    QDir directory("./Logo");
    dashfiles = directory.entryList(QStringList() << "*.png" << "*.gif", QDir::Files);
#endif

    dashfiles.prepend("None");
    m_uiState->setbackroundpictures(dashfiles);
}

void Connect::readMaindashsetup()
{
    const QString path = QDir(dashboardsDirectoryPath()).filePath(QStringLiteral("MainDash.txt"));
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

    const QString path = QDir(dashboardsDirectoryPath()).filePath(filename);
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
        m_canManager->deactivateAll();
    if (m_canTransport)
        m_canTransport->close();

    if (!startCanModules()) {
        if (m_connectionData)
            m_connectionData->setSerialStat(QStringLiteral("Failed to apply CAN bitrate %1").arg(bitrate));
        return;
    }

    if (m_connectionData)
        m_connectionData->setSerialStat(QStringLiteral("Applied CAN bitrate %1").arg(bitrate));
}

void Connect::openConnection()
{
    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"), QStringLiteral("Opening connection (auto module selection)"));
        m_diagnosticsProvider->setCanStatus(false, QString());
    }

    if (!startCanModules()) {
        if (m_connectionData)
            m_connectionData->setSerialStat(QStringLiteral("Native CAN startup failed"));
        emit connectionOpenResult(false, QStringLiteral("Native CAN startup failed"));
        emit connectionStateChanged(false, QStringLiteral("Native CAN startup failed"));
        return;
    }

    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->setCanStatus(true, activeCanLabel());
        m_diagnosticsProvider->setConnectionInfo(false, QString(), 0, QStringLiteral("CAN"));
    }

    if (m_connectionData)
        m_connectionData->setSerialStat(QStringLiteral("Native CAN active"));
    emit connectionOpenResult(true, QStringLiteral("Native CAN active"));
    emit connectionStateChanged(true, QStringLiteral("Native CAN active"));

    if (m_calculations)
        m_calculations->start();
}


void Connect::openConnection(const QString &portName, const int &ecuSelect, const int &canbase, const int &rpmcanbase)
{
    m_selectedPort = portName;
    if (m_appSettings) {
        if (ecuSelect == EX_BOARD_BACKEND_ID) {
            m_appSettings->setValue(QStringLiteral("ui/exboard/enabled"), true);
            m_appSettings->setValue(QStringLiteral("ui/ptextender/enabled"), false);
            m_appSettings->setValue(QStringLiteral("ui/extenderCanBase"), canbase);
            m_appSettings->setValue(QStringLiteral("ui/shiftLightCanBase"), rpmcanbase);
        } else if (ecuSelect == PT_EXTENDER_BACKEND_ID) {
            m_appSettings->setValue(QStringLiteral("ui/exboard/enabled"), false);
            m_appSettings->setValue(QStringLiteral("ui/ptextender/enabled"), true);
            m_appSettings->setValue(QStringLiteral("ui/ptextender/canBase"), canbase);
        }
    }

    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->addLogMessage(
            QStringLiteral("INFO"),
            QStringLiteral("Opening connection (ECU=%1, CAN base=%2)").arg(ecuSelect).arg(canbase));
        m_diagnosticsProvider->setCanStatus(false, QString());
    }

    if (!startCanModules()) {
        if (m_connectionData) {
            m_connectionData->setSerialStat(QStringLiteral("Native CAN startup failed"));
        }
        emit connectionOpenResult(false, QStringLiteral("Native CAN startup failed"));
        emit connectionStateChanged(false, QStringLiteral("Native CAN startup failed"));
        return;
    }

    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->setCanStatus(true, activeCanLabel());
        m_diagnosticsProvider->setConnectionInfo(false, QString(), 0, QStringLiteral("CAN"));
    }

    if (m_connectionData)
        m_connectionData->setSerialStat(QStringLiteral("Native CAN active"));
    emit connectionOpenResult(true, QStringLiteral("Native CAN active"));
    emit connectionStateChanged(true, QStringLiteral("Native CAN active"));

    if (m_calculations)
        m_calculations->start();
}
void Connect::closeConnection()
{
    if (m_canManager)
        m_canManager->deactivateAll();
    if (m_canTransport)
        m_canTransport->close();

    if (m_diagnosticsProvider) {
        m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"), QStringLiteral("Connection closed"));
        m_diagnosticsProvider->setCanStatus(false, QString());
    }
    emit connectionStateChanged(false, QStringLiteral("Native CAN disconnected"));
    m_calculations->stop();
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

bool Connect::startCanModules()
{
    if (!m_canStartupManager || !m_canTransport || !m_canManager)
        return false;

    const bool exEnabled = m_appSettings ? m_appSettings->getValue(QStringLiteral("ui/exboard/enabled"), true).toBool() : true;
    const bool ptEnabled = m_appSettings ? m_appSettings->getValue(QStringLiteral("ui/ptextender/enabled"), true).toBool() : true;
    if (!exEnabled && !ptEnabled)
        return false;

    int bitrateSelection = m_appSettings ? m_appSettings->getValue(QStringLiteral("ui/bitrateSelect"), 0).toInt() : 0;
    if (bitrateSelection < 0 || bitrateSelection > 2)
        bitrateSelection = 0;
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

    bool activatedAny = false;

    if (exEnabled) {
        const int exBase = m_appSettings ? m_appSettings->getValue(QStringLiteral("ui/extenderCanBase"), 0).toInt() : 0;
        const int exRpmBase = m_appSettings ? m_appSettings->getValue(QStringLiteral("ui/shiftLightCanBase"), 0).toInt() : 0;
        const QVariantMap exConfig = {{QStringLiteral("canBaseId"), exBase}, {QStringLiteral("rpmBaseId"), exRpmBase}};
        if (!m_canManager->activateModule(EX_BOARD_BACKEND_ID, exConfig)) {
            m_canTransport->close();
            return false;
        }
        activatedAny = true;
    }

    if (ptEnabled) {
        const int ptBase = m_appSettings ? m_appSettings->getValue(QStringLiteral("ui/ptextender/canBase"), 0).toInt() : 0;
        const QVariantMap ptConfig = {{QStringLiteral("canBaseId"), ptBase}, {QStringLiteral("rpmBaseId"), 0}};
        if (!m_canManager->activateModule(PT_EXTENDER_BACKEND_ID, ptConfig)) {
            m_canTransport->close();
            return false;
        }
        activatedAny = true;
    }

    if (!activatedAny) {
        m_canTransport->close();
        return false;
    }

    return true;
}

QString Connect::activeCanLabel() const
{
    if (!m_canManager)
        return QString();
    const bool exActive = m_canManager->isModuleActive(EX_BOARD_BACKEND_ID);
    const bool ptActive = m_canManager->isModuleActive(PT_EXTENDER_BACKEND_ID);
    if (exActive && ptActive)
        return QStringLiteral("EX Board + PT Extender CAN");
    if (ptActive)
        return QStringLiteral("PT Extender CAN");
    if (exActive)
        return QStringLiteral("EX Board CAN");
    return QString();
}

void Connect::update()
{
    if (m_updateManagerService)
        m_updateManagerService->checkForUpdates();

    if (m_diagnosticsProvider)
        m_diagnosticsProvider->addLogMessage(QStringLiteral("INFO"), QStringLiteral("System update initiated"));
    if (m_connectionData)
        m_connectionData->setSerialStat(QStringLiteral("Checking for updates"));
}

void Connect::changefolderpermission()
{
    QProcess *process = new QProcess(this);
    QString program = "sudo";
    QStringList arguments;
    arguments << "chown" << "-R" << "root:root" << "/home/root/KTracks";

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
    arguments << "cp" << "/home/root/src/config.txt" << "/boot/config.txt";

    process->start(program, arguments);
    process->waitForFinished(600000);  // 10 minutes time before timeout
    reboot();
}

