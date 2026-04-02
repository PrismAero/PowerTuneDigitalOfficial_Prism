#ifndef VEHICLERPMSETTINGSMODEL_H
#define VEHICLERPMSETTINGSMODEL_H

#include <QObject>
#include <QStringList>

class AppSettings;

class VehicleRpmSettingsModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString waterTempWarn READ waterTempWarn WRITE setWaterTempWarn NOTIFY waterTempWarnChanged)
    Q_PROPERTY(QString boostWarn READ boostWarn WRITE setBoostWarn NOTIFY boostWarnChanged)
    Q_PROPERTY(QString rpmWarn READ rpmWarn WRITE setRpmWarn NOTIFY rpmWarnChanged)
    Q_PROPERTY(QString knockWarn READ knockWarn WRITE setKnockWarn NOTIFY knockWarnChanged)
    Q_PROPERTY(QString lambdaMultiply READ lambdaMultiply WRITE setLambdaMultiply NOTIFY lambdaMultiplyChanged)
    Q_PROPERTY(bool gearCalcEnabled READ gearCalcEnabled WRITE setGearCalcEnabled NOTIFY gearCalcEnabledChanged)
    Q_PROPERTY(QString maxRpm READ maxRpm WRITE setMaxRpm NOTIFY maxRpmChanged)
    Q_PROPERTY(QString speedPercent READ speedPercent WRITE setSpeedPercent NOTIFY speedPercentChanged)

public:
    explicit VehicleRpmSettingsModel(QObject *parent = nullptr);

    void setAppSettings(AppSettings *settings) { m_appSettings = settings; }

    Q_INVOKABLE void load();
    Q_INVOKABLE void applyWarnGear();
    Q_INVOKABLE void applyRpm();
    Q_INVOKABLE void applySpeed();

    Q_INVOKABLE QString shiftStageText(int index) const;
    Q_INVOKABLE void setShiftStageText(int index, const QString &value);
    Q_INVOKABLE QString gearValueText(int index) const;
    Q_INVOKABLE void setGearValueText(int index, const QString &value);

    QString waterTempWarn() const { return m_waterTempWarn; }
    void setWaterTempWarn(const QString &value);
    QString boostWarn() const { return m_boostWarn; }
    void setBoostWarn(const QString &value);
    QString rpmWarn() const { return m_rpmWarn; }
    void setRpmWarn(const QString &value);
    QString knockWarn() const { return m_knockWarn; }
    void setKnockWarn(const QString &value);
    QString lambdaMultiply() const { return m_lambdaMultiply; }
    void setLambdaMultiply(const QString &value);
    bool gearCalcEnabled() const { return m_gearCalcEnabled; }
    void setGearCalcEnabled(bool value);
    QString maxRpm() const { return m_maxRpm; }
    void setMaxRpm(const QString &value);
    QString speedPercent() const { return m_speedPercent; }
    void setSpeedPercent(const QString &value);

signals:
    void waterTempWarnChanged();
    void boostWarnChanged();
    void rpmWarnChanged();
    void knockWarnChanged();
    void lambdaMultiplyChanged();
    void gearCalcEnabledChanged();
    void maxRpmChanged();
    void speedPercentChanged();
    void shiftStagesChanged();
    void gearValuesChanged();

private:
    AppSettings *m_appSettings = nullptr;
    QString m_waterTempWarn = QStringLiteral("110");
    QString m_boostWarn = QStringLiteral("0.9");
    QString m_rpmWarn = QStringLiteral("10000");
    QString m_knockWarn = QStringLiteral("80");
    QString m_lambdaMultiply = QStringLiteral("14.7");
    bool m_gearCalcEnabled = false;
    QString m_maxRpm = QStringLiteral("10000");
    QString m_speedPercent = QStringLiteral("100");
    QStringList m_shiftStages{QStringLiteral("3000"), QStringLiteral("5500"), QStringLiteral("5500"),
                              QStringLiteral("7500")};
    QStringList m_gearValues{QStringLiteral("120"), QStringLiteral("74"), QStringLiteral("54"), QStringLiteral("37"),
                             QStringLiteral("28"), QStringLiteral("")};
};

#endif  // VEHICLERPMSETTINGSMODEL_H
