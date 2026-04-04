#include "../TestSettingsSupport.h"

#include "../../src/Core/AppSettings.h"
#include "../../src/Core/Models/DataModels.h"
#include "../../src/Core/Models/VehicleRpmSettingsModel.h"

#include <QtTest>

class MainAndVehicleSettingsRoundTripTest : public QObject
{
    Q_OBJECT

private slots:
    void roundTripsMainSettingsThroughFreshAppSettingsInstance();
    void vehicleRpmModelPreservesPulseSettingsOnSpeedApply();
};

void MainAndVehicleSettingsRoundTripTest::roundTripsMainSettingsThroughFreshAppSettingsInstance()
{
    ScopedSettingsStore store;
    {
        SettingsData settingsData;
        UIState uiState;
        VehicleData vehicleData;
        AnalogInputs analogInputs;
        ExpanderBoardData expanderBoardData;
        EngineData engineData;
        ConnectionData connectionData;
        DigitalInputs digitalInputs;
        AppSettings appSettings(&settingsData,
                                &uiState,
                                &vehicleData,
                                &analogInputs,
                                &expanderBoardData,
                                &engineData,
                                &connectionData,
                                &digitalInputs);

        appSettings.writeCanAutoConnect(true);
        appSettings.setTempUnitIndex(1);
        appSettings.setSpeedUnitIndex(1);
        appSettings.setPressureUnitIndex(1);
        appSettings.writeVehicleWeight("1180");
        appSettings.writeOdometer("25.5");
        appSettings.writeTripmeter("3.2");
        appSettings.writeDashboardCount(3);
        appSettings.writeSelectedDash(1, 2);
        appSettings.writeLanguage(3);
        appSettings.writeCanBitrateSelection(2);
        appSettings.setMainSpeedSourceIndex(6);
        appSettings.writeLoggerFilename("track_day");
        appSettings.writeLoggerEnabled(true);
    }

    SettingsData settingsData;
    UIState uiState;
    VehicleData vehicleData;
    AnalogInputs analogInputs;
    ExpanderBoardData expanderBoardData;
    EngineData engineData;
    ConnectionData connectionData;
    DigitalInputs digitalInputs;
    AppSettings reloaded(&settingsData,
                         &uiState,
                         &vehicleData,
                         &analogInputs,
                         &expanderBoardData,
                         &engineData,
                         &connectionData,
                         &digitalInputs);

    reloaded.readandApplySettings();

    QCOMPARE(reloaded.readCanAutoConnect(), true);
    QCOMPARE(reloaded.readDashboardCount(), 3);
    QCOMPARE(reloaded.readSelectedDash(1), 2);
    QCOMPARE(reloaded.readLoggerFilename(), QString("track_day"));
    QCOMPARE(reloaded.readLoggerEnabled(), true);
    QCOMPARE(uiState.dashboardCount(), 3);
    QCOMPARE(vehicleData.Weight(), 1180);
    QCOMPARE(vehicleData.Odo(), 25.5);
    QCOMPARE(vehicleData.Trip(), 3.2);
    QCOMPARE(settingsData.language(), 3);
    QCOMPARE(settingsData.ExternalSpeed(), 6);
}

void MainAndVehicleSettingsRoundTripTest::vehicleRpmModelPreservesPulseSettingsOnSpeedApply()
{
    ScopedSettingsStore store;
    {
        QSettings settings = store.settings();
        settings.setValue("Pulsespermile", 54321);
        settings.sync();
    }

    AppSettings appSettings;
    VehicleRpmSettingsModel model;
    model.setAppSettings(&appSettings);
    model.load();
    model.setSpeedPercent("135");
    model.applySpeed();

    QCOMPARE(appSettings.getValue("Pulsespermile").toInt(), 54321);
    QCOMPARE(appSettings.getValue("Speedcorrection").toDouble(), 1.35);
}

QTEST_MAIN(MainAndVehicleSettingsRoundTripTest)

#include "MainAndVehicleSettingsRoundTripTest.moc"
