#ifndef CONNECT_H
#define CONNECT_H

/*
 * Copyright (C) 2016 Markus Ippy, Bastian Gschrey, Jan
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

/*
  \file serial.h
  \
  \author Bastian Gschrey & Markus Ippy
  \modifier Kai Wyborny
 */

#include "../Utils/Calculations.h"

#include <QFileSystemModel>
#include <QModbusDataUnit>
#include <QObject>
#include <QProcess>
#include <QTimer>


class datalogger;
class calculations;
class AppSettings;
class WifiScanner;
class Extender;
class UIState;
class EngineData;
class VehicleData;
class GPSData;
class AnalogInputs;
class DigitalInputs;
class ExpanderBoardData;
class TimingData;
class ConnectionData;
class SettingsData;
class PropertyRouter;
class SteinhartCalculator;
class CalibrationHelper;
class SensorRegistry;
class DiagnosticsProvider;
class OverlayPositionManager;
class ShiftIndicatorHelper;
class CanFrameModel;
class DifferentialSensorCalc;
class ExBoardConfigManager;
class OverlayConfigDefaults;
class ScreenControlService;
class DashboardLockService;
class DemoModeService;
class UpdateManagerService;
class CanStartupManager;
class CanTransport;
class CanManager;

class Connect : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList portsNames READ portsNames WRITE setPortsNames NOTIFY sig_portsNamesChanged)
    Q_PROPERTY(bool hasDdcBrightness READ hasDdcBrightness CONSTANT)
    Q_PROPERTY(bool hasBrightnessControl READ hasBrightnessControl CONSTANT)

public:
    enum class BrightnessMethod { None, Sysfs, DdcUtil };

    bool hasDdcBrightness() const;
    bool hasBrightnessControl() const;

    ~Connect() override;
    explicit Connect(QObject *parent = nullptr);
    Q_INVOKABLE void saveDashtoFile(const QString &filename, const QString &dashstring);
    // Indexed dashboard methods (Phase 5 - dynamic dashboard support)
    Q_INVOKABLE void setDashFilename(int index, const QString &filename);
    Q_INVOKABLE void readDashSetup(int index);
    Q_INVOKABLE void setRpmStyle(int index, int style);

    // Legacy methods delegate to indexed versions
    Q_INVOKABLE void setfilename1(const QString &file1) { setDashFilename(0, file1); }
    Q_INVOKABLE void setfilename2(const QString &file2) { setDashFilename(1, file2); }
    Q_INVOKABLE void setfilename3(const QString &file3) { setDashFilename(2, file3); }
    Q_INVOKABLE void readdashsetup1() { readDashSetup(0); }
    Q_INVOKABLE void readdashsetup2() { readDashSetup(1); }
    Q_INVOKABLE void readdashsetup3() { readDashSetup(2); }
    Q_INVOKABLE void setrpm(const int &dash1, const int &dash2, const int &dash3);

    Q_INVOKABLE void checkifraspberrypi();
    Q_INVOKABLE void readavailabledashfiles();
    Q_INVOKABLE void readavailablebackrounds();
    Q_INVOKABLE void readMaindashsetup();
    Q_INVOKABLE void setSreenbrightness(const int &brightness);
    Q_INVOKABLE void setSpeedUnits(const int &units1);
    Q_INVOKABLE void setUnits(const int &units);
    Q_INVOKABLE void setPressUnits(const int &units2);
    Q_INVOKABLE void setWeight(const int &weight);
    Q_INVOKABLE void setOdometer(const qreal &Odometer);
    Q_INVOKABLE void qmlTreeviewclicked(const QModelIndex &index);
    Q_INVOKABLE void clear() const;
    Q_INVOKABLE void canbitratesetup(const int &cansetting);
    Q_INVOKABLE void openConnection(const QString &portName, const int &ecuSelect, const int &canbase,
                                    const int &rpmcanbase);
    Q_INVOKABLE void closeConnection();
    Q_INVOKABLE void update();
    Q_INVOKABLE void changefolderpermission();
    Q_INVOKABLE void shutdown();
    Q_INVOKABLE void reboot();
    Q_INVOKABLE void turnscreen();


public:
    QStringList portsNames() const { return m_portsNames; }

private:
    int canBitrateForSelection(int selection) const;
    bool startActiveCanModule();

    AppSettings *m_appSettings;
    datalogger *m_datalogger;
    calculations *m_calculations;
    QStringList m_portsNames;
    QStringList *m_ecuList;
    QFileSystemModel *dirModel;
    QFileSystemModel *fileModel;
    WifiScanner *m_wifiscanner;
    Extender *m_extender;
    // * Data Models (Phase 2 & 3 - Modularization)
    UIState *m_uiState;
    EngineData *m_engineData;
    VehicleData *m_vehicleData;
    GPSData *m_gpsData;
    AnalogInputs *m_analogInputs;
    DigitalInputs *m_digitalInputs;
    ExpanderBoardData *m_expanderBoardData;
    TimingData *m_timingData;
    ConnectionData *m_connectionData;
    SettingsData *m_settingsData;
    PropertyRouter *m_propertyRouter;
    SteinhartCalculator *m_steinhartCalc;
    CalibrationHelper *m_calibrationHelper;
    SensorRegistry *m_sensorRegistry;
    DiagnosticsProvider *m_diagnosticsProvider;
    OverlayPositionManager *m_overlayConfigManager;
    ShiftIndicatorHelper *m_shiftIndicatorHelper;
    CanFrameModel *m_canFrameModel;
    DifferentialSensorCalc *m_differentialSensorCalc;
    ExBoardConfigManager *m_exBoardConfigManager;
    OverlayConfigDefaults *m_overlayConfigDefaults;
    ScreenControlService *m_screenControlService;
    DashboardLockService *m_dashboardLockService;
    DemoModeService *m_demoModeService;
    UpdateManagerService *m_updateManagerService;
    CanStartupManager *m_canStartupManager;
    CanTransport *m_canTransport;
    CanManager *m_canManager;
    BrightnessMethod m_brightnessMethod = BrightnessMethod::None;

    int m_ecu = 0;
    int m_logging = 0;
    int m_connectClicked = 0;
    int m_canBaseAddress = 0;
    int m_rpmCanBaseAddress = 0;
    QByteArray m_checksumHex;
    QByteArray m_recvChecksumHex;
    QString m_selectedPort;
    QVector<QString> m_dashFilenames{3};


signals:
    void sig_portsNamesChanged(QStringList portsNames);
    void connectionOpenResult(bool success, const QString &message);
    void connectionStateChanged(bool connected, const QString &statusMessage);

public slots:
    void setPortsNames(QStringList portsNames)
    {
        if (m_portsNames == portsNames)
            return;

        m_portsNames = portsNames;
        emit sig_portsNamesChanged(portsNames);
    }
};


#endif  // CONNECT_H
