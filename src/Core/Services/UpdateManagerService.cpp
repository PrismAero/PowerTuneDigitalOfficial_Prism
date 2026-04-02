#include "UpdateManagerService.h"

#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QProcess>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QTextStream>

namespace {
const QString kDefaultRepo = QStringLiteral("PowerTuneDigital/PowerTuneDigital_Prism");
const QString kDefaultInstaller = QStringLiteral("/opt/PowerTune/Scripts/install-app-update.sh");
}

UpdateManagerService::UpdateManagerService(QObject *parent) : QObject(parent), m_networkManager(new QNetworkAccessManager(this))
{
    setCurrentVersion(QCoreApplication::applicationVersion().isEmpty() ? QStringLiteral("0.0.0")
                                                                       : QCoreApplication::applicationVersion());
    loadAuthConfig();
}

UpdateManagerService::~UpdateManagerService() = default;

void UpdateManagerService::setStatus(const QString &status, const QString &message)
{
    if (m_status != status) {
        m_status = status;
        emit statusChanged(m_status);
    }
    if (m_statusMessage != message) {
        m_statusMessage = message;
        emit statusMessageChanged(m_statusMessage);
    }
}

void UpdateManagerService::setCurrentVersion(const QString &version)
{
    if (m_currentVersion == version)
        return;
    m_currentVersion = version;
    emit currentVersionChanged(m_currentVersion);
}

void UpdateManagerService::setLatestVersion(const QString &version)
{
    if (m_latestVersion == version)
        return;
    m_latestVersion = version;
    emit latestVersionChanged(m_latestVersion);
}

void UpdateManagerService::setUpdateAvailable(bool available)
{
    if (m_updateAvailable == available)
        return;
    m_updateAvailable = available;
    emit updateAvailableChanged(m_updateAvailable);
}

void UpdateManagerService::setDownloadReady(bool ready)
{
    if (m_downloadReady == ready)
        return;
    m_downloadReady = ready;
    emit downloadReadyChanged(m_downloadReady);
}

void UpdateManagerService::setDownloadProgressPercent(int percent)
{
    const int bounded = qBound(0, percent, 100);
    if (m_downloadProgressPercent == bounded)
        return;
    m_downloadProgressPercent = bounded;
    emit downloadProgressPercentChanged(m_downloadProgressPercent);
}

void UpdateManagerService::setGithubToken(const QString &token)
{
    const bool oldState = hasAuthToken();
    m_githubToken = token.trimmed();
    const bool newState = hasAuthToken();
    if (oldState != newState)
        emit hasAuthTokenChanged(newState);
}

void UpdateManagerService::loadAuthConfig()
{
    m_repoSlug = qEnvironmentVariable("POWERTUNE_GH_REPO");
    if (m_repoSlug.isEmpty())
        m_repoSlug = kDefaultRepo;

    QString token = qEnvironmentVariable("POWERTUNE_GH_TOKEN");
    if (token.isEmpty()) {
        const QString tokenFile = qEnvironmentVariable(
            "POWERTUNE_GH_TOKEN_FILE",
            QStringLiteral("/home/root/.config/PowerTune/github-token"));
        QFile f(tokenFile);
        if (f.exists() && f.open(QIODevice::ReadOnly | QIODevice::Text))
            token = QString::fromUtf8(f.readAll()).trimmed();
    }
    setGithubToken(token);
}

void UpdateManagerService::refreshAuthState()
{
    loadAuthConfig();
    setStatus(QStringLiteral("idle"), hasAuthToken() ? QStringLiteral("Auth token loaded")
                                                     : QStringLiteral("No GitHub token configured"));
}

void UpdateManagerService::checkForUpdates()
{
    loadAuthConfig();
    setDownloadReady(false);
    setUpdateAvailable(false);
    setDownloadProgressPercent(0);

    if (!hasAuthToken()) {
        setStatus(QStringLiteral("error"), QStringLiteral("Missing GitHub token"));
        return;
    }

    setStatus(QStringLiteral("checking"), QStringLiteral("Checking GitHub Releases"));
    const QUrl url(QStringLiteral("https://api.github.com/repos/%1/releases/latest").arg(m_repoSlug));
    QNetworkRequest request(url);
    request.setRawHeader("Accept", "application/vnd.github+json");
    request.setRawHeader("Authorization", QByteArray("Bearer ") + m_githubToken.toUtf8());
    request.setRawHeader("X-GitHub-Api-Version", "2022-11-28");

    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        const QByteArray payload = reply->readAll();
        const QString errorText = reply->error() == QNetworkReply::NoError ? QString()
                                                                            : reply->errorString();
        reply->deleteLater();

        if (!errorText.isEmpty()) {
            setStatus(QStringLiteral("error"), QStringLiteral("Update check failed: %1").arg(errorText));
            return;
        }

        QString validationError;
        if (!validateReleaseResponse(payload, validationError)) {
            setStatus(QStringLiteral("error"), validationError);
            return;
        }
        handleReleaseResponse(payload);
    });
}

bool UpdateManagerService::validateReleaseResponse(const QByteArray &payload, QString &errorMessage)
{
    const QJsonParseError parseError{};
    const QJsonDocument doc = QJsonDocument::fromJson(payload);
    if (!doc.isObject()) {
        errorMessage = QStringLiteral("Invalid release response");
        return false;
    }
    const QJsonObject root = doc.object();
    if (!root.contains(QStringLiteral("tag_name"))) {
        errorMessage = QStringLiteral("Release missing tag_name");
        return false;
    }
    if (!root.contains(QStringLiteral("assets")) || !root.value(QStringLiteral("assets")).isArray()) {
        errorMessage = QStringLiteral("Release missing assets");
        return false;
    }
    Q_UNUSED(parseError);
    return true;
}

void UpdateManagerService::handleReleaseResponse(const QByteArray &payload)
{
    m_latestReleasePayload = payload;
    const QJsonDocument doc = QJsonDocument::fromJson(payload);
    const QJsonObject root = doc.object();
    const QString tag = root.value(QStringLiteral("tag_name")).toString();
    setLatestVersion(tag);

    m_manifestUrl = findAssetUrl(QStringLiteral("release-manifest.json"));
    if (m_manifestUrl.isEmpty()) {
        setStatus(QStringLiteral("error"), QStringLiteral("release-manifest.json not found in release assets"));
        return;
    }

    setUpdateAvailable(parseVersionNewer(tag, m_currentVersion));
    if (!m_updateAvailable) {
        setStatus(QStringLiteral("idle"), QStringLiteral("No update available"));
        return;
    }

    setStatus(QStringLiteral("available"), QStringLiteral("Update %1 available").arg(tag));
}

QString UpdateManagerService::findAssetUrl(const QString &assetName) const
{
    if (m_latestReleasePayload.isEmpty())
        return QString();
    const QJsonDocument doc = QJsonDocument::fromJson(m_latestReleasePayload);
    const QJsonArray assets = doc.object().value(QStringLiteral("assets")).toArray();
    for (const QJsonValue &v : assets) {
        const QJsonObject obj = v.toObject();
        if (obj.value(QStringLiteral("name")).toString() == assetName)
            return obj.value(QStringLiteral("browser_download_url")).toString();
    }
    return QString();
}

QString UpdateManagerService::findFirstAssetBySuffix(const QString &suffix) const
{
    if (m_latestReleasePayload.isEmpty())
        return QString();
    const QJsonDocument doc = QJsonDocument::fromJson(m_latestReleasePayload);
    const QJsonArray assets = doc.object().value(QStringLiteral("assets")).toArray();
    for (const QJsonValue &v : assets) {
        const QJsonObject obj = v.toObject();
        const QString name = obj.value(QStringLiteral("name")).toString();
        if (name.endsWith(suffix))
            return obj.value(QStringLiteral("browser_download_url")).toString();
    }
    return QString();
}

QString UpdateManagerService::stripVersionPrefix(const QString &version) const
{
    QString s = version.trimmed();
    if (s.startsWith(QLatin1Char('v'), Qt::CaseInsensitive))
        s.remove(0, 1);
    return s;
}

bool UpdateManagerService::parseVersionNewer(const QString &latest, const QString &current) const
{
    const QString l = stripVersionPrefix(latest);
    const QString c = stripVersionPrefix(current);
    const QStringList ls = l.split('.');
    const QStringList cs = c.split('.');
    const int maxParts = qMax(ls.size(), cs.size());
    for (int i = 0; i < maxParts; ++i) {
        const int lv = i < ls.size() ? ls[i].toInt() : 0;
        const int cv = i < cs.size() ? cs[i].toInt() : 0;
        if (lv > cv)
            return true;
        if (lv < cv)
            return false;
    }
    return false;
}

void UpdateManagerService::downloadUpdate()
{
    if (!m_updateAvailable) {
        setStatus(QStringLiteral("error"), QStringLiteral("No update is available to download"));
        return;
    }
    if (m_manifestUrl.isEmpty()) {
        setStatus(QStringLiteral("error"), QStringLiteral("Manifest URL unavailable"));
        return;
    }

    setStatus(QStringLiteral("downloading"), QStringLiteral("Downloading release manifest"));
    QNetworkRequest manifestReq{QUrl(m_manifestUrl)};
    manifestReq.setRawHeader("Authorization", QByteArray("Bearer ") + m_githubToken.toUtf8());
    QNetworkReply *manifestReply = m_networkManager->get(manifestReq);
    connect(manifestReply, &QNetworkReply::finished, this, [this, manifestReply]() {
        const QByteArray manifestPayload = manifestReply->readAll();
        const QString errorText = manifestReply->error() == QNetworkReply::NoError ? QString()
                                                                                    : manifestReply->errorString();
        manifestReply->deleteLater();
        if (!errorText.isEmpty()) {
            setStatus(QStringLiteral("error"), QStringLiteral("Manifest download failed: %1").arg(errorText));
            return;
        }

        const QJsonDocument manifestDoc = QJsonDocument::fromJson(manifestPayload);
        if (!manifestDoc.isObject()) {
            setStatus(QStringLiteral("error"), QStringLiteral("Invalid release manifest"));
            return;
        }

        const QJsonObject manifest = manifestDoc.object();
        const QString bundleName = manifest.value(QStringLiteral("bundle_file")).toString();
        const QString checksumName = manifest.value(QStringLiteral("checksum_file")).toString();
        m_expectedSha256 = manifest.value(QStringLiteral("sha256")).toString().trimmed();

        m_bundleUrl = bundleName.isEmpty() ? findFirstAssetBySuffix(QStringLiteral(".tar.gz")) : findAssetUrl(bundleName);
        m_checksumUrl = checksumName.isEmpty() ? findFirstAssetBySuffix(QStringLiteral(".sha256")) : findAssetUrl(checksumName);
        if (m_bundleUrl.isEmpty()) {
            setStatus(QStringLiteral("error"), QStringLiteral("Bundle asset not found"));
            return;
        }
        if (m_checksumUrl.isEmpty()) {
            setStatus(QStringLiteral("error"), QStringLiteral("Checksum asset not found"));
            return;
        }

        QDir stageDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation));
        stageDir.mkpath(QStringLiteral("powertune-updates"));
        const QString bundlePath = stageDir.filePath(QStringLiteral("powertune-updates/%1").arg(
            QFileInfo(QUrl(m_bundleUrl).path()).fileName()));
        m_downloadedBundlePath = bundlePath;

        setStatus(QStringLiteral("downloading"), QStringLiteral("Downloading app bundle"));
        QNetworkRequest bundleReq{QUrl(m_bundleUrl)};
        bundleReq.setRawHeader("Authorization", QByteArray("Bearer ") + m_githubToken.toUtf8());
        QNetworkReply *bundleReply = m_networkManager->get(bundleReq);

        connect(bundleReply, &QNetworkReply::downloadProgress, this, [this](qint64 received, qint64 total) {
            if (total > 0)
                setDownloadProgressPercent(static_cast<int>((received * 100) / total));
        });

        connect(bundleReply, &QNetworkReply::finished, this, [this, bundleReply, bundlePath]() {
            const QByteArray bundleBytes = bundleReply->readAll();
            const QString errorText = bundleReply->error() == QNetworkReply::NoError ? QString()
                                                                                      : bundleReply->errorString();
            bundleReply->deleteLater();
            if (!errorText.isEmpty()) {
                setStatus(QStringLiteral("error"), QStringLiteral("Bundle download failed: %1").arg(errorText));
                return;
            }
            QFile out(bundlePath);
            if (!out.open(QIODevice::WriteOnly)) {
                setStatus(QStringLiteral("error"), QStringLiteral("Failed to write bundle to disk"));
                return;
            }
            out.write(bundleBytes);
            out.close();

            setStatus(QStringLiteral("verifying"), QStringLiteral("Verifying update checksum"));
            if (!verifyDownloadedBundle()) {
                setStatus(QStringLiteral("error"), QStringLiteral("Checksum verification failed"));
                return;
            }
            setDownloadReady(true);
            setStatus(QStringLiteral("ready"), QStringLiteral("Update downloaded and verified"));
        });
    });
}

bool UpdateManagerService::verifyDownloadedBundle()
{
    QFile f(m_downloadedBundlePath);
    if (!f.open(QIODevice::ReadOnly))
        return false;
    QCryptographicHash hash(QCryptographicHash::Sha256);
    if (!hash.addData(&f))
        return false;
    const QString actual = QString::fromLatin1(hash.result().toHex());
    if (m_expectedSha256.isEmpty())
        return true;
    return actual.compare(m_expectedSha256, Qt::CaseInsensitive) == 0;
}

void UpdateManagerService::installUpdate()
{
    if (!m_downloadReady || m_downloadedBundlePath.isEmpty()) {
        setStatus(QStringLiteral("error"), QStringLiteral("No downloaded update is ready for install"));
        return;
    }

    const QString installerPath = qEnvironmentVariable("POWERTUNE_UPDATE_INSTALLER", kDefaultInstaller);
    if (!QFileInfo::exists(installerPath)) {
        setStatus(QStringLiteral("error"), QStringLiteral("Installer script not found: %1").arg(installerPath));
        return;
    }

    setStatus(QStringLiteral("installing"), QStringLiteral("Installing update bundle"));
    QProcess installer;
    installer.start(installerPath, {m_downloadedBundlePath, m_latestVersion});
    if (!installer.waitForFinished(-1)) {
        setStatus(QStringLiteral("error"), QStringLiteral("Installer execution failed"));
        return;
    }

    if (installer.exitStatus() != QProcess::NormalExit || installer.exitCode() != 0) {
        const QString stderrText = QString::fromUtf8(installer.readAllStandardError()).trimmed();
        setStatus(QStringLiteral("error"), QStringLiteral("Install failed: %1").arg(stderrText));
        return;
    }

    setCurrentVersion(m_latestVersion);
    setUpdateAvailable(false);
    setDownloadReady(false);
    setStatus(QStringLiteral("success"), QStringLiteral("Update installed successfully. Reboot required."));
}
