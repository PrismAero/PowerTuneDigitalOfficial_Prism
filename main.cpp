#include "Core/connect.h"
#include "BuildInfo.h"
#include "Utils/downloadmanager.h"

#include <QDir>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QtQml>

// Modified by Kai Wyborny - 2026 (QGuiApplication migration, memory optimization)

int main(int argc, char *argv[])
{
    // * Set Qt Quick Controls style to Basic for cross-platform consistency
    // * This suppresses native style customization warnings on macOS
    QQuickStyle::setStyle("Basic");
    QGuiApplication app(argc, argv);
    app.setOrganizationName("PowerTune");
    app.setOrganizationDomain("power-tune.org");
    app.setApplicationName("PowerTune");
    app.setApplicationVersion(QString::fromUtf8(kPowerTuneVersionLabel));

    const QDir fontDir(QStringLiteral(":/Resources/fonts"));
    const QStringList fontFiles = fontDir.entryList({QStringLiteral("*.ttf"), QStringLiteral("*.otf")});
    for (const QString &f : fontFiles)
        QFontDatabase::addApplicationFont(fontDir.absoluteFilePath(f));

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("BuildVersion", QString::fromUtf8(kPowerTuneVersionLabel));
    engine.rootContext()->setContextProperty("BuildProfile", QString::fromUtf8(kPowerTuneBuildProfile));
    engine.rootContext()->setContextProperty("BuildDateUtc", QString::fromUtf8(kPowerTuneBuildDateUtc));
    engine.rootContext()->setContextProperty("BuildCommit", QString::fromUtf8(kPowerTuneGitCommit));
    engine.rootContext()->setContextProperty("BuildDependencies", QString::fromUtf8(kPowerTuneBuildDependencies));
    engine.rootContext()->setContextProperty("BuildNotes", QString::fromUtf8(kPowerTuneBuildNotes));

    // * Add QML module import paths for PowerTune modules
    engine.addImportPath("qrc:/qt/qml");

    qmlRegisterType<DownloadManager>("DLM", 1, 0, "DLM");
    qmlRegisterType<Connect>("com.powertune", 1, 0, "ConnectObject");
    engine.rootContext()->setContextProperty("DLM", new DownloadManager(&engine));
    engine.rootContext()->setContextProperty("Connect", new Connect(&engine));
    // * Load main QML from PowerTune.Core module
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/PowerTune/Core/Main.qml")));
    return app.exec();
}
