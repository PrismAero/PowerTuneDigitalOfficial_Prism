#include "Core/connect.h"
#include "Hardware/Extender.h"
#include "Utils/downloadmanager.h"

#include <QGuiApplication>
#include <QDateTime>
#include <QDebug>
#include <QFileSystemModel>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QtQml>

#include <cstdio>

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
    QQmlApplicationEngine engine;
    
    // * Add QML module import paths for PowerTune modules
    engine.addImportPath("qrc:/qt/qml");
    
    qmlRegisterType<DownloadManager>("DLM", 1, 0, "DLM");
    qmlRegisterType<Connect>("com.powertune", 1, 0, "ConnectObject");
    engine.rootContext()->setContextProperty("DLM", new DownloadManager(&engine));
    engine.rootContext()->setContextProperty("Connect", new Connect(&engine));
    engine.rootContext()->setContextProperty("Extender2", new Extender(&engine));
#ifdef HAVE_DDCUTIL
    engine.rootContext()->setContextProperty("HAVE_DDCUTIL", true);
#else
    engine.rootContext()->setContextProperty("HAVE_DDCUTIL", false);
#endif
    // * Load main QML from PowerTune.Core module
    // ! Resource path includes both prefix and source path due to qt_add_qml_module behavior
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/PowerTune/Core/PowerTune/Core/Main.qml")));
    return app.exec();
}
