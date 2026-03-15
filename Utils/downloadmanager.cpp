/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "downloadmanager.h"

#include <QDebug>
#include <QTextStream>

using namespace std;


bool resetFlag = false;
DownloadManager::DownloadManager(QObject *parent) : QObject(parent) {}

void DownloadManager::append(const QStringList &urls)
{
    qDebug() << "URLs " << urls;
    for (const QString &urlAsString : urls)
        append(QUrl::fromEncoded(urlAsString.toLocal8Bit()));

    if (downloadQueue.isEmpty())
        QTimer::singleShot(0, this, &DownloadManager::finished);
}

void DownloadManager::append(const QUrl &url)
{
    qDebug() << "Single URL " << url;
    if (downloadQueue.isEmpty())
        QTimer::singleShot(0, this, &DownloadManager::startNextDownload);

    downloadQueue.enqueue(url);
    ++totalCount;
}

QString DownloadManager::saveFileName(const QUrl &url)
{
    QString path = url.path();
    QString basename = QFileInfo(path).fileName();

    if (basename.isEmpty())
        basename = "download";

    if (QFile::exists(basename)) {
        QFile::remove(basename);
    }

    return basename;
}

void DownloadManager::setDownloadStatus(const QString &downloadStatus)
{
    if (m_downloadStatus == downloadStatus) {
        return;
    }
    m_downloadStatus = downloadStatus;
    emit downloadStatusChanged(downloadStatus);
}
void DownloadManager::setDownloadFilename(const QString &downloadFilename)
{
    if (m_downloadFilename == downloadFilename) {
        return;
    }
    m_downloadFilename = downloadFilename;
    emit downloadFilenameChanged(downloadFilename);
}

QString DownloadManager::downloadStatus() const
{
    return m_downloadStatus;
}
QString DownloadManager::downloadFilename() const
{
    return m_downloadFilename;
}
void DownloadManager::startNextDownload()
{
    if (downloadQueue.isEmpty()) {
        qDebug() << downloadedCount << "/" << totalCount << "files downloaded successfully";
        emit finished();
        setDownloadStatus("Finished");
        return;
    }

    QUrl url = downloadQueue.dequeue();

    QString filename = saveFileName(url);
    output.setFileName(filename);
    if (!output.open(QIODevice::WriteOnly)) {
        fprintf(stderr, "Problem opening save file '%s' for download '%s': %s\n", qPrintable(filename),
                url.toEncoded().constData(), qPrintable(output.errorString()));

        startNextDownload();
        return;  // skip this download
    }

    QNetworkRequest request(url);
    currentDownload = manager.get(request);
    connect(currentDownload, &QNetworkReply::downloadProgress, this, &DownloadManager::downloadProgress);
    connect(currentDownload, &QNetworkReply::finished, this, &DownloadManager::downloadFinished);
    connect(currentDownload, &QNetworkReply::readyRead, this, &DownloadManager::downloadReadyRead);

    // prepare the output
    qDebug() << "Downloading" << url.toEncoded();
    setDownloadFilename(QStringLiteral("Downloading %1...\n").arg(QString::fromUtf8(url.toEncoded())));
    downloadTimer.start();
}

void DownloadManager::downloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    setProgressStatus(bytesReceived, bytesTotal);

    // calculate the download speed
    double speed = bytesReceived * 1000.0 / downloadTimer.elapsed();
    QString unit;
    if (speed < 1024) {
        unit = "bytes/sec";
    } else if (speed < 1024 * 1024) {
        speed /= 1024;
        unit = "kB/s";
    } else {
        speed /= 1024 * 1024;
        unit = "MB/s";
    }

    setProgressMessage(QString::fromLatin1("%1 %2").arg(speed, 3, 'f', 1).arg(unit));
    updateProgress();
    setDownloadStatus((QString::fromLatin1("%1 %2").arg(speed, 3, 'f', 1).arg(unit)));
}

void DownloadManager::downloadFinished()
{
    clearProgress();
    output.close();

    if (currentDownload->error()) {
        // download failed
        fprintf(stderr, "Failed: %s\n", qPrintable(currentDownload->errorString()));
        output.remove();
    } else {
        // let's check if it was actually a redirect
        if (isHttpRedirect()) {
            reportRedirect();
            output.remove();
        } else {
            printf("Succeeded.\n");
            ++downloadedCount;
        }
    }

    currentDownload->deleteLater();


    if (downloadQueue.size() <= 1 && resetFlag == false) {
        append(readTrackData());
        resetFlag = true;
    }

    if (downloadQueue.isEmpty()) {
        qDebug() << "READ TRACK DATA AND SORT FILES ";
        readTrackData();
        sortDownloadedFiles();
    }


    startNextDownload();
}

void DownloadManager::downloadReadyRead()
{
    output.write(currentDownload->readAll());
}


bool DownloadManager::isHttpRedirect() const
{
    int statusCode = currentDownload->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    return statusCode == 301 || statusCode == 302 || statusCode == 303 || statusCode == 305 || statusCode == 307 ||
           statusCode == 308;
}

void DownloadManager::reportRedirect()
{
    int statusCode = currentDownload->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QUrl requestUrl = currentDownload->request().url();
    QTextStream(stderr) << "Request: " << requestUrl.toDisplayString() << " was redirected with code: " << statusCode
                        << '\n';

    QVariant target = currentDownload->attribute(QNetworkRequest::RedirectionTargetAttribute);
    if (!target.isValid())
        return;
    QUrl redirectUrl = target.toUrl();
    if (redirectUrl.isRelative())
        redirectUrl = requestUrl.resolved(redirectUrl);
    QTextStream(stderr) << "Redirected to: " << redirectUrl.toDisplayString() << '\n';
}

QList<QString> DownloadManager::readTrackData()
{
    QList<QPair<QString, QString>> parsedPairs;
    QString pathString;

#ifdef __linux__
    pathString = QStringLiteral("/opt/PowerTune/repo.txt");
#elif _WIN32
    pathString = QCoreApplication::applicationFilePath().remove("release/PowertuneQMLGui.exe") + "repo.txt";
#else
    pathString.clear();
#endif

    QFile inputFile(pathString);
    if (inputFile.open(QIODevice::ReadOnly)) {
        QTextStream in(&inputFile);
        while (!in.atEnd()) {
            const QString line = in.readLine();
            const QList<QString> splitList = line.split(':');
            if (splitList.size() < 2)
                continue;
            parsedPairs.append(qMakePair(splitList[0], splitList[1]));
        }
        inputFile.flush();
        inputFile.close();
    }

    m_trackPairs = parsedPairs;
    QList<QString> urls;
    for (const auto &pair : parsedPairs) {
        urls.append(QStringLiteral("https://gitlab.com/PowerTuneDigital/PowertuneTracks/-/raw/main/Tracks/") + pair.first
                    + QStringLiteral("/") + pair.second);
    }
    return urls;
}

void DownloadManager::sortDownloadedFiles()
{
    QString sourceRoot;
    QString destinationRoot;
    QDir dir;

#ifdef __linux__
    sourceRoot = QStringLiteral("/opt/PowerTune/");
    destinationRoot = QStringLiteral("/home/pi/KTracks/");
#elif _WIN32
    sourceRoot = QCoreApplication::applicationDirPath() + "/";
    destinationRoot = sourceRoot;
#else
    return;
#endif

    for (const auto &pair : m_trackPairs) {
        const QFileInfo outputDir(destinationRoot + pair.first);
        const QFileInfo outputFile(destinationRoot + pair.first + "/" + pair.second);

        if (!outputDir.exists())
            dir.mkpath(destinationRoot + pair.first);

        if (outputFile.exists())
            dir.remove(destinationRoot + pair.first + "/" + pair.second);

        QFile::copy(sourceRoot + pair.second, destinationRoot + pair.first + "/" + pair.second);
        QFile::remove(sourceRoot + pair.second);
    }
}

void DownloadManager::clearProgress()
{
    m_progressValue = 0;
    m_progressMaximum = -1;
    m_progressIteration = 0;
}

void DownloadManager::updateProgress()
{
    ++m_progressIteration;
    if (m_progressMaximum > 0) {
        const int percent = static_cast<int>((m_progressValue * 100) / m_progressMaximum);
        qDebug() << "Download progress:" << percent << "%" << m_progressMessage;
    } else {
        qDebug() << "Download progress:" << m_progressMessage;
    }
}

void DownloadManager::setProgressMessage(const QString &message)
{
    m_progressMessage = message;
}

void DownloadManager::setProgressStatus(qint64 value, qint64 maximum)
{
    m_progressValue = value;
    m_progressMaximum = maximum;
}
