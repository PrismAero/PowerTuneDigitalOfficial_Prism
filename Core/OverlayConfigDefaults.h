#ifndef OVERLAYCONFIGDEFAULTS_H
#define OVERLAYCONFIGDEFAULTS_H

#include <QObject>
#include <QVariantMap>

class AppSettings;

class OverlayConfigDefaults : public QObject
{
    Q_OBJECT

public:
    explicit OverlayConfigDefaults(QObject *parent = nullptr);

    void setAppSettings(AppSettings *settings) { m_appSettings = settings; }

    Q_INVOKABLE QVariantMap defaultsFor(const QString &overlayId) const;
    Q_INVOKABLE QVariant defaultValue(const QString &overlayId, const QString &key) const;
    Q_INVOKABLE double defaultOverlaySize(const QString &overlayId) const;

private:
    AppSettings *m_appSettings = nullptr;

    QVariantMap tachClusterDefaults() const;
    QVariantMap speedClusterDefaults() const;
    QVariantMap shiftIndicatorDefaults() const;
    QVariantMap waterTempDefaults() const;
    QVariantMap oilPressureDefaults() const;
    QVariantMap statusRow0Defaults() const;
    QVariantMap statusRow1Defaults() const;
    QVariantMap statusRowBaseDefaults() const;
    QVariantMap brakeBiasDefaults() const;
    QVariantMap bottomBarDefaults() const;
    QVariantMap sensorCardDefaults() const;
    QVariantMap genericDefaults() const;
};

#endif  // OVERLAYCONFIGDEFAULTS_H
