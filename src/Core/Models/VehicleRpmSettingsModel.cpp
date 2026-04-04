#include "VehicleRpmSettingsModel.h"

#include "../AppSettings.h"

VehicleRpmSettingsModel::VehicleRpmSettingsModel(QObject *parent) : QObject(parent) {}

void VehicleRpmSettingsModel::load()
{
    if (!m_appSettings)
        return;

    setWaterTempWarn(QString::number(m_appSettings->getValue(QStringLiteral("waterwarn"), 110).toDouble()));
    setBoostWarn(QString::number(m_appSettings->getValue(QStringLiteral("boostwarn"), 0.9).toDouble()));
    setRpmWarn(QString::number(m_appSettings->getValue(QStringLiteral("rpmwarn"), 10000).toInt()));
    setKnockWarn(QString::number(m_appSettings->getValue(QStringLiteral("knockwarn"), 80).toInt()));
    setLambdaMultiply(QString::number(m_appSettings->getValue(QStringLiteral("lambdamultiply"), 14.7).toDouble()));
    setGearCalcEnabled(m_appSettings->getValue(QStringLiteral("gercalactive"), 0).toInt() > 0);
    setMaxRpm(QString::number(m_appSettings->getValue(QStringLiteral("Max RPM"), 10000).toInt()));
    setShiftStageText(0, QString::number(m_appSettings->getValue(QStringLiteral("Shift Light1"), 3000).toInt()));
    setShiftStageText(1, QString::number(m_appSettings->getValue(QStringLiteral("Shift Light2"), 5500).toInt()));
    setShiftStageText(2, QString::number(m_appSettings->getValue(QStringLiteral("Shift Light3"), 5500).toInt()));
    setShiftStageText(3, QString::number(m_appSettings->getValue(QStringLiteral("Shift Light4"), 7500).toInt()));
    setGearValueText(0, QString::number(m_appSettings->getValue(QStringLiteral("valgear1"), 120).toInt()));
    setGearValueText(1, QString::number(m_appSettings->getValue(QStringLiteral("valgear2"), 74).toInt()));
    setGearValueText(2, QString::number(m_appSettings->getValue(QStringLiteral("valgear3"), 54).toInt()));
    setGearValueText(3, QString::number(m_appSettings->getValue(QStringLiteral("valgear4"), 37).toInt()));
    setGearValueText(4, QString::number(m_appSettings->getValue(QStringLiteral("valgear5"), 28).toInt()));
    setGearValueText(5, m_appSettings->getValue(QStringLiteral("valgear6"), QString()).toString());

    const double speedCorrection = m_appSettings->getValue(QStringLiteral("Speedcorrection"), 1).toDouble();
    setSpeedPercent(QString::number(qRound(speedCorrection * 100.0)));
}

void VehicleRpmSettingsModel::applyWarnGear()
{
    if (!m_appSettings)
        return;
    m_appSettings->writeWarnGearSettings(m_waterTempWarn.toDouble(), m_boostWarn.toDouble(), m_rpmWarn.toDouble(),
                                         m_knockWarn.toDouble(), m_gearCalcEnabled ? 1 : 0,
                                         m_lambdaMultiply.toDouble(), m_gearValues.at(0).toDouble(),
                                         m_gearValues.at(1).toDouble(), m_gearValues.at(2).toDouble(),
                                         m_gearValues.at(3).toDouble(), m_gearValues.at(4).toDouble(),
                                         m_gearValues.at(5).toDouble());
}

void VehicleRpmSettingsModel::applyRpm()
{
    if (!m_appSettings)
        return;
    m_appSettings->writeRPMSettings(m_maxRpm.toInt(), m_shiftStages.at(0).toInt(), m_shiftStages.at(1).toInt(),
                                    m_shiftStages.at(2).toInt(), m_shiftStages.at(3).toInt());
}

void VehicleRpmSettingsModel::applySpeed()
{
    if (!m_appSettings)
        return;
    const double pulsesPerMile = m_appSettings->getValue(QStringLiteral("Pulsespermile"), 100000).toDouble();
    m_appSettings->writeSpeedSettings(m_speedPercent.toDouble() / 100.0, pulsesPerMile);
}

QString VehicleRpmSettingsModel::shiftStageText(int index) const
{
    if (index < 0 || index >= m_shiftStages.size())
        return QString();
    return m_shiftStages.at(index);
}

void VehicleRpmSettingsModel::setShiftStageText(int index, const QString &value)
{
    if (index < 0 || index >= m_shiftStages.size())
        return;
    if (m_shiftStages[index] == value)
        return;
    m_shiftStages[index] = value;
    emit shiftStagesChanged();
}

QString VehicleRpmSettingsModel::gearValueText(int index) const
{
    if (index < 0 || index >= m_gearValues.size())
        return QString();
    return m_gearValues.at(index);
}

void VehicleRpmSettingsModel::setGearValueText(int index, const QString &value)
{
    if (index < 0 || index >= m_gearValues.size())
        return;
    if (m_gearValues[index] == value)
        return;
    m_gearValues[index] = value;
    emit gearValuesChanged();
}

void VehicleRpmSettingsModel::setWaterTempWarn(const QString &value)
{
    if (m_waterTempWarn == value)
        return;
    m_waterTempWarn = value;
    emit waterTempWarnChanged();
}

void VehicleRpmSettingsModel::setBoostWarn(const QString &value)
{
    if (m_boostWarn == value)
        return;
    m_boostWarn = value;
    emit boostWarnChanged();
}

void VehicleRpmSettingsModel::setRpmWarn(const QString &value)
{
    if (m_rpmWarn == value)
        return;
    m_rpmWarn = value;
    emit rpmWarnChanged();
}

void VehicleRpmSettingsModel::setKnockWarn(const QString &value)
{
    if (m_knockWarn == value)
        return;
    m_knockWarn = value;
    emit knockWarnChanged();
}

void VehicleRpmSettingsModel::setLambdaMultiply(const QString &value)
{
    if (m_lambdaMultiply == value)
        return;
    m_lambdaMultiply = value;
    emit lambdaMultiplyChanged();
}

void VehicleRpmSettingsModel::setGearCalcEnabled(bool value)
{
    if (m_gearCalcEnabled == value)
        return;
    m_gearCalcEnabled = value;
    emit gearCalcEnabledChanged();
}

void VehicleRpmSettingsModel::setMaxRpm(const QString &value)
{
    if (m_maxRpm == value)
        return;
    m_maxRpm = value;
    emit maxRpmChanged();
}

void VehicleRpmSettingsModel::setSpeedPercent(const QString &value)
{
    if (m_speedPercent == value)
        return;
    m_speedPercent = value;
    emit speedPercentChanged();
}
