#ifndef GOPRO_H
#define GOPRO_H

#include <QNetworkReply>
#include <QObject>


class GoPro : public QObject
{
    Q_OBJECT

public:
    GoPro(QObject *parent = nullptr);
    Q_INVOKABLE void goprorec(const QString &record);
    Q_INVOKABLE void goProSettings(const int &goProSelect, const QString &goPropass);


public slots:
    void replyFinished(QNetworkReply *reply);
};

#endif  // GOPRO_H
