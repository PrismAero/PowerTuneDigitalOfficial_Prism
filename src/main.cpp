#include "Core/Connect.h"
#include "BuildInfo.h"
#include "Utils/DownloadManager.h"

#include <QDir>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QCoreApplication>
#include <QDateTime>
#include <QFile>
#include <QTextStream>
#include <QQmlApplicationEngine>
#include <QQmlError>
#include <QQmlContext>
#include <QQuickStyle>
#include <QtQml>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

namespace {

QString g_startupLogPath;

QString startupLogPath()
{
    const QString baseDir = QDir::tempPath() + QStringLiteral("/PowerTune");
    QDir dir(baseDir);
    dir.mkpath(QStringLiteral("."));
    return dir.filePath(QStringLiteral("startup.log"));
}

void appendStartupLogLine(const QString &line)
{
    QFile logFile(g_startupLogPath);
    if (!logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text))
        return;

    QTextStream out(&logFile);
    out << line << "\n";
    out.flush();
}

void fileLogMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QFile logFile(g_startupLogPath);
    if (!logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text))
        return;

    QTextStream out(&logFile);
    const char *level = "INFO";
    switch (type) {
    case QtDebugMsg:    level = "DEBUG"; break;
    case QtInfoMsg:     level = "INFO"; break;
    case QtWarningMsg:  level = "WARN"; break;
    case QtCriticalMsg: level = "CRITICAL"; break;
    case QtFatalMsg:    level = "FATAL"; break;
    }

    out << QDateTime::currentDateTimeUtc().toString(Qt::ISODateWithMs)
        << " [" << level << "] "
        << msg;
    if (context.file)
        out << " (" << context.file << ":" << context.line << ")";
    out << "\n";
    out.flush();
}

void installFileLogger()
{
    g_startupLogPath = startupLogPath();
    appendStartupLogLine(QStringLiteral("===== PowerTune startup %1 =====")
                             .arg(QDateTime::currentDateTimeUtc().toString(Qt::ISODateWithMs)));
    appendStartupLogLine(QStringLiteral("Log path: %1").arg(QDir::toNativeSeparators(g_startupLogPath)));
    qInstallMessageHandler(fileLogMessageHandler);
}

void showFatalMessage(const QString &text)
{
#ifdef Q_OS_WIN
    MessageBoxW(nullptr, reinterpret_cast<LPCWSTR>(text.utf16()),
                L"PowerTune startup failed", MB_OK | MB_ICONERROR);
#else
    Q_UNUSED(text);
#endif
}

} // namespace

int main(int argc, char *argv[])
{
    QQuickStyle::setStyle("Basic");
    QGuiApplication app(argc, argv);
    installFileLogger();
    qInfo().noquote() << "Startup log file:" << startupLogPath();
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

    engine.addImportPath("qrc:/qt/qml");

    qmlRegisterType<DownloadManager>("DLM", 1, 0, "DLM");
    qmlRegisterType<Connect>("com.powertune", 1, 0, "ConnectObject");
    engine.rootContext()->setContextProperty("DLM", new DownloadManager(&engine));
    engine.rootContext()->setContextProperty("Connect", new Connect(&engine));

    const QUrl rootQmlUrl(QStringLiteral("qrc:/qt/qml/PowerTune/Core/PowerTune/Core/Main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [rootQmlUrl](QObject *obj, const QUrl &objUrl) {
            if (!obj && objUrl == rootQmlUrl) {
                qCritical().noquote() << "Failed to create root QML object:" << objUrl.toString();
                showFatalMessage(QStringLiteral("Failed to create root QML object:\n%1\n\nSee log:\n%2")
                                     .arg(objUrl.toString(), QDir::toNativeSeparators(g_startupLogPath)));
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection);

    QObject::connect(&engine, &QQmlApplicationEngine::warnings, &app, [](const QList<QQmlError> &warnings) {
        for (const QQmlError &warning : warnings)
            qCritical().noquote() << warning.toString();
    });

    qInfo().noquote() << "Loading root QML:" << rootQmlUrl.toString();
    engine.load(rootQmlUrl);
    if (engine.rootObjects().isEmpty()) {
        qCritical() << "No root QML objects created. Exiting.";
        showFatalMessage(QStringLiteral("No root QML objects were created.\n\nSee log:\n%1")
                             .arg(QDir::toNativeSeparators(g_startupLogPath)));
        return -1;
    }
    return app.exec();
}
