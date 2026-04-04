#include "../TestSettingsSupport.h"

#include "../../src/Core/AppSettings.h"
#include "../../src/Core/Config/ExBoardConfigManager.h"
#include "../../src/Core/Config/PTExtenderConfigManager.h"
#include "../../src/Core/Services/DashboardLockService.h"
#include "../../src/Core/Services/DemoModeService.h"

#include <QtTest>

class ServiceAndManagerSettingsTest : public QObject
{
    Q_OBJECT

private slots:
    void dashboardLockRestoresAndPersists();
    void demoModeRemainsSessionOnly();
    void settingsStoreRoundsTripsDisplayAndDfiFamilies();
    void exBoardManagerRoundTripsBoardConfig();
    void ptExtenderManagerRoundTripsStoredConfig();
};

void ServiceAndManagerSettingsTest::dashboardLockRestoresAndPersists()
{
    ScopedSettingsStore store;
    AppSettings appSettings;
    appSettings.writeDashboardLockEnabled(true);

    DashboardLockService lockService;
    lockService.setAppSettings(&appSettings);
    lockService.initialize();
    QCOMPARE(lockService.lockoutEnabled(), true);

    lockService.setLockoutEnabled(false);
    QCOMPARE(appSettings.readDashboardLockEnabled(), false);
}

void ServiceAndManagerSettingsTest::demoModeRemainsSessionOnly()
{
    DemoModeService demoMode;
    QCOMPARE(demoMode.sessionOnly(), true);
    QCOMPARE(demoMode.active(), false);

    demoMode.enterDemoMode();
    QCOMPARE(demoMode.active(), true);

    DemoModeService freshInstance;
    QCOMPARE(freshInstance.active(), false);
    QCOMPARE(freshInstance.sessionOnly(), true);
}

void ServiceAndManagerSettingsTest::settingsStoreRoundsTripsDisplayAndDfiFamilies()
{
    ScopedSettingsStore store;
    AppSettings appSettings;

    appSettings.writeBrightnessPopupEnabled(true);
    appSettings.writeGlobalBrightnessPercent(85);
    appSettings.writeBrightnessDayPreset(70);
    appSettings.writeBrightnessNightPreset(25);
    appSettings.setValue("ui/dfiSerial/port", "COM9");
    appSettings.setValue("ui/dfiSerial/enabled", true);
    appSettings.setValue("ui/dfiSerial/suppressedCodes", "11,12");

    QCOMPARE(appSettings.readBrightnessPopupEnabled(), true);
    QCOMPARE(appSettings.readGlobalBrightnessPercent(), 85);
    QCOMPARE(appSettings.getValue("ui/brightnessDayPreset").toInt(), 70);
    QCOMPARE(appSettings.getValue("ui/brightnessNightPreset").toInt(), 25);
    QCOMPARE(appSettings.getValue("ui/dfiSerial/port").toString(), QString("COM9"));
    QCOMPARE(appSettings.getValue("ui/dfiSerial/enabled").toBool(), true);
    QCOMPARE(appSettings.getValue("ui/dfiSerial/suppressedCodes").toString(), QString("11,12"));
}

void ServiceAndManagerSettingsTest::exBoardManagerRoundTripsBoardConfig()
{
    ScopedSettingsStore store;
    AppSettings appSettings;

    ExBoardConfigManager manager;
    manager.setAppSettings(&appSettings);

    QVariantMap boardConfig;
    boardConfig.insert("selectedValue", 1);
    boardConfig.insert("switchValue", true);
    boardConfig.insert("rpmSource", 2);
    boardConfig.insert("rpmCanVersion", 1);
    boardConfig.insert("an7Damping", 12);
    manager.saveBoardConfig(boardConfig);

    const QVariantMap loaded = manager.loadBoardConfig();
    QCOMPARE(loaded.value("selectedValue").toInt(), 1);
    QCOMPARE(loaded.value("switchValue").toBool(), true);
    QCOMPARE(loaded.value("rpmSource").toInt(), 2);
    QCOMPARE(loaded.value("rpmCanVersion").toInt(), 1);
}

void ServiceAndManagerSettingsTest::ptExtenderManagerRoundTripsStoredConfig()
{
    ScopedSettingsStore store;
    AppSettings appSettings;

    PTExtenderConfigManager manager;
    manager.setAppSettings(&appSettings);

    QVariantMap config;
    config.insert("enabled", true);
    config.insert("canBase", 1536);

    QVariantMap system;
    system.insert("deviceName", "PitNode");
    system.insert("faultEnable", false);
    config.insert("system", system);

    QVariantMap timing;
    timing.insert("crankDuration", 1400);
    timing.insert("runningProofTime", 3500);
    config.insert("timing", timing);

    manager.saveAllSettings(config);

    const QVariantMap loaded = manager.loadAllSettings();
    QCOMPARE(loaded.value("enabled").toBool(), true);
    QCOMPARE(loaded.value("canBase").toInt(), 1536);
    QCOMPARE(loaded.value("system").toMap().value("deviceName").toString(), QString("PitNode"));
    QCOMPARE(loaded.value("timing").toMap().value("crankDuration").toInt(), 1400);
}

QTEST_MAIN(ServiceAndManagerSettingsTest)

#include "ServiceAndManagerSettingsTest.moc"
