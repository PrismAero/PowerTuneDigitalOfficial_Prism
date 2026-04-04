#include "../TestSettingsSupport.h"

#include "../../src/Core/AppSettings.h"
#include "../../src/Core/Models/DataModels.h"

#include <QtTest>

class SettingsBootstrapHydrationTest : public QObject
{
    Q_OBJECT

private slots:
    void hydratesRuntimeModelsFromPersistedSettings();
};

void SettingsBootstrapHydrationTest::hydratesRuntimeModelsFromPersistedSettings()
{
    ScopedSettingsStore store;
    {
        QSettings settings = store.settings();
        settings.setValue("ui/unitSelector", 1);
        settings.setValue("ui/unitSelector1", 1);
        settings.setValue("ui/unitSelector2", 1);
        settings.setValue("ui/dashCount", 4);
        settings.setValue("ui/vehicleWeight", "1325");
        settings.setValue("ui/odometer", "1234.5");
        settings.setValue("ui/tripmeter", "67.8");
        settings.setValue("Language", 2);
        settings.setValue("ui/mainSpeedSource", 6);
        settings.setValue("Max RPM", 9100);
        settings.setValue("Shift Light1", 3200);
        settings.setValue("Shift Light2", 5400);
        settings.setValue("Shift Light3", 6900);
        settings.setValue("Shift Light4", 8200);
        settings.setValue("waterwarn", 115);
        settings.setValue("boostwarn", 1.1);
        settings.setValue("rpmwarn", 8700);
        settings.setValue("knockwarn", 90);
        settings.setValue("lambdamultiply", 14.2);
        settings.setValue("Speedcorrection", 1.23);
        settings.setValue("Pulsespermile", 45678);
        settings.sync();
    }

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

    appSettings.readandApplySettings();

    QCOMPARE(settingsData.units(), QString("imperial"));
    QCOMPARE(settingsData.speedunits(), QString("imperial"));
    QCOMPARE(settingsData.pressureunits(), QString("imperial"));
    QCOMPARE(uiState.dashboardCount(), 4);
    QCOMPARE(uiState.Visibledashes(), 4);
    QCOMPARE(vehicleData.Weight(), 1325);
    QCOMPARE(vehicleData.Odo(), 1234.5);
    QCOMPARE(vehicleData.Trip(), 67.8);
    QCOMPARE(settingsData.language(), 2);
    QCOMPARE(settingsData.ExternalSpeed(), 6);
    QCOMPARE(settingsData.maxRPM(), 9100);
    QCOMPARE(settingsData.rpmwarn(), 8700);
    QCOMPARE(settingsData.boostwarn(), 1.1);
    QCOMPARE(engineData.Lambdamultiply(), 14.2);
    QCOMPARE(settingsData.speedpercent(), 1.23);
    QCOMPARE(settingsData.pulsespermile(), 45678.0);
}

QTEST_MAIN(SettingsBootstrapHydrationTest)

#include "SettingsBootstrapHydrationTest.moc"
