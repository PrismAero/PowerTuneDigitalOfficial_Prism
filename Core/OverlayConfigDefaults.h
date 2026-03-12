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

    Q_INVOKABLE QVariantMap defaultsFor(const QString &configType) const;
    Q_INVOKABLE QVariant defaultValue(const QString &configType, const QString &key) const;
    Q_INVOKABLE QVariantMap arcDefaults(const QString &configType) const;
    Q_INVOKABLE double defaultOverlaySize(const QString &configType) const;

private:
    AppSettings *m_appSettings = nullptr;

    QVariantMap tachClusterDefaults() const;
    QVariantMap speedClusterDefaults() const;
    QVariantMap waterTempDefaults() const;
    QVariantMap oilPressureDefaults() const;
    QVariantMap shiftIndicatorDefaults() const;
    QVariantMap statusRowDefaults() const;
    QVariantMap brakeBiasDefaults() const;
    QVariantMap bottomBarDefaults() const;
    QVariantMap genericDefaults() const;
};

#endif  // OVERLAYCONFIGDEFAULTS_H
