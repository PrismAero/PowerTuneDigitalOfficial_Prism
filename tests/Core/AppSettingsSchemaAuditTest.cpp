#include "../TestSettingsSupport.h"

#include "../../src/Core/AppSettings.h"

#include <QtTest>

class AppSettingsSchemaAuditTest : public QObject
{
    Q_OBJECT

private slots:
    void migratesLegacyKeysIntoCanonicalSchema();
    void seedsLoggerDefaultsWhenMissing();
};

void AppSettingsSchemaAuditTest::migratesLegacyKeysIntoCanonicalSchema()
{
    ScopedSettingsStore store;
    {
        QSettings settings = store.settings();
        settings.setValue("ui/connectAtStartup", true);
        settings.setValue("ui/dashCount", 0);
        settings.setValue("ExternalSpeed", 4);
        settings.sync();
    }

    AppSettings appSettings;

    QCOMPARE(appSettings.readSettingsSchemaVersion(), 1);
    QCOMPARE(appSettings.readCanAutoConnect(), true);
    QCOMPARE(appSettings.readDashboardCount(), 1);
    QCOMPARE(appSettings.readMainSpeedSourceIndex(), 4);
}

void AppSettingsSchemaAuditTest::seedsLoggerDefaultsWhenMissing()
{
    ScopedSettingsStore store;
    AppSettings appSettings;

    QCOMPARE(appSettings.readLoggerEnabled(), false);
    QCOMPARE(appSettings.readLoggerFilename(), QString("DataLog"));
}

QTEST_MAIN(AppSettingsSchemaAuditTest)

#include "AppSettingsSchemaAuditTest.moc"
