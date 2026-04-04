#include "../TestSettingsSupport.h"

#include "../../src/Core/AppSettings.h"
#include "../../src/Core/Config/OverlayConfigDefaults.h"
#include "../../src/Core/Config/OverlayConfigService.h"
#include "../../src/Utils/OverlayPositionManager.h"

#include <QtTest>

class OverlayPersistenceTest : public QObject
{
    Q_OBJECT

private slots:
    void migratesLegacyOverlayIdsAndMergesDefaults();
    void roundTripsOverlayPositionsAndReset();
};

void OverlayPersistenceTest::migratesLegacyOverlayIdsAndMergesDefaults()
{
    ScopedSettingsStore store;
    AppSettings appSettings;

    QVariantMap tachLegacy;
    tachLegacy.insert("sensorKey", "RPM");
    tachLegacy.insert("overlaySize", 480);
    appSettings.saveOverlayConfig("racedash", "tachGroup", tachLegacy);

    QVariantMap gearLegacy;
    gearLegacy.insert("gearKey", "EXGear");
    appSettings.saveOverlayConfig("racedash", "gearIndicator", gearLegacy);
    appSettings.setValue("ui/dfiSerial/enabled", true);

    OverlayConfigDefaults defaults;
    defaults.setAppSettings(&appSettings);

    OverlayConfigService service;
    service.setAppSettings(&appSettings);
    service.setDefaults(&defaults);

    const QVariantMap configs = service.migrateAndLoadConfigs(
        "racedash",
        {"tachCluster", "speedCluster", "shiftIndicator", "waterTemp", "oilPressure",
         "statusRow0", "statusRow1", "brakeBias", "bottomBar"});

    const QVariantMap tachCluster = configs.value("tachCluster").toMap();
    QCOMPARE(tachCluster.value("sensorKey").toString(), QString("RPM"));
    QCOMPARE(tachCluster.value("gearKey").toString(), QString("DfiSerialGear"));
    QCOMPARE(appSettings.loadOverlayConfig("racedash", "tachGroup").isEmpty(), true);
    QCOMPARE(appSettings.loadOverlayConfig("racedash", "gearIndicator").isEmpty(), true);
}

void OverlayPersistenceTest::roundTripsOverlayPositionsAndReset()
{
    ScopedSettingsStore store;
    OverlayPositionManager manager;

    manager.savePosition("tachCluster", 123.0, 456.0);
    QTest::qWait(600);

    const QVariantMap stored = manager.getPosition("tachCluster");
    QCOMPARE(stored.value("x").toDouble(), 123.0);
    QCOMPARE(stored.value("y").toDouble(), 456.0);

    manager.resetAllPositions();
    const QVariantMap reset = manager.getPosition("tachCluster");
    QCOMPARE(reset.isEmpty(), true);
}

QTEST_MAIN(OverlayPersistenceTest)

#include "OverlayPersistenceTest.moc"
