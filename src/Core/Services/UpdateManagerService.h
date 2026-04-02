#ifndef UPDATEMANAGERSERVICE_H
#define UPDATEMANAGERSERVICE_H

#include <QObject>
#include <QUrl>

class QNetworkAccessManager;
class QNetworkReply;

class UpdateManagerService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(QString currentVersion READ currentVersion NOTIFY currentVersionChanged)
    Q_PROPERTY(QString latestVersion READ latestVersion NOTIFY latestVersionChanged)
    Q_PROPERTY(bool updateAvailable READ updateAvailable NOTIFY updateAvailableChanged)
    Q_PROPERTY(bool downloadReady READ downloadReady NOTIFY downloadReadyChanged)
    Q_PROPERTY(bool hasAuthToken READ hasAuthToken NOTIFY hasAuthTokenChanged)
    Q_PROPERTY(int downloadProgressPercent READ downloadProgressPercent NOTIFY downloadProgressPercentChanged)

public:
    explicit UpdateManagerService(QObject *parent = nullptr);
    ~UpdateManagerService() override;

    QString status() const { return m_status; }
    QString statusMessage() const { return m_statusMessage; }
    QString currentVersion() const { return m_currentVersion; }
    QString latestVersion() const { return m_latestVersion; }
    bool updateAvailable() const { return m_updateAvailable; }
    bool downloadReady() const { return m_downloadReady; }
    bool hasAuthToken() const { return !m_githubToken.isEmpty(); }
    int downloadProgressPercent() const { return m_downloadProgressPercent; }

    Q_INVOKABLE void checkForUpdates();
    Q_INVOKABLE void downloadUpdate();
    Q_INVOKABLE void installUpdate();
    Q_INVOKABLE void refreshAuthState();

signals:
    void statusChanged(const QString &status);
    void statusMessageChanged(const QString &message);
    void currentVersionChanged(const QString &version);
    void latestVersionChanged(const QString &version);
    void updateAvailableChanged(bool available);
    void downloadReadyChanged(bool ready);
    void hasAuthTokenChanged(bool hasToken);
    void downloadProgressPercentChanged(int percent);

private:
    void setStatus(const QString &status, const QString &message = QString());
    void setCurrentVersion(const QString &version);
    void setLatestVersion(const QString &version);
    void setUpdateAvailable(bool available);
    void setDownloadReady(bool ready);
    void setDownloadProgressPercent(int percent);
    void setGithubToken(const QString &token);

    void loadAuthConfig();
    bool validateReleaseResponse(const QByteArray &payload, QString &errorMessage);
    void handleReleaseResponse(const QByteArray &payload);
    bool parseVersionNewer(const QString &latest, const QString &current) const;
    QString stripVersionPrefix(const QString &version) const;
    bool verifyDownloadedBundle();

    QString findAssetUrl(const QString &assetName) const;
    QString findFirstAssetBySuffix(const QString &suffix) const;

    QString m_status = QStringLiteral("idle");
    QString m_statusMessage;
    QString m_currentVersion = QStringLiteral("0.0.0");
    QString m_latestVersion;
    bool m_updateAvailable = false;
    bool m_downloadReady = false;
    int m_downloadProgressPercent = 0;

    QString m_repoSlug;
    QString m_githubToken;
    QString m_manifestUrl;
    QString m_bundleUrl;
    QString m_checksumUrl;
    QString m_expectedSha256;
    QString m_downloadedBundlePath;
    QByteArray m_latestReleasePayload;

    QNetworkAccessManager *m_networkManager = nullptr;
};

#endif  // UPDATEMANAGERSERVICE_H
