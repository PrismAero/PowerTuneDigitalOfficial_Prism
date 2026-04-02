#include "VehicleRpmSettingsModel.h"

#include "../AppSettings.h"

VehicleRpmSettingsModel::VehicleRpmSettingsModel(QObject *parent) : QObject(parent) {}

void VehicleRpmSettingsModel::load()
{
    if (!m_appSettings)
        return;

    setWaterTempWarn(m_appSettings->getValue(QStringLiteral("waterwarn"), QStringLiteral("110")).toString());
    setBoostWarn(m_appSettings->getValue(QStringLiteral("boostwarn"), QStringLiteral("0.9")).toString());
    setRpmWarn(m_appSettings->getValue(QStringLiteral("rpmwarn"), QStringLiteral("10000")).toString());
    setKnockWarn(m_appSettings->getValue(QStringLiteral("knockwarn"), QStringLiteral("80")).toString());
    setLambdaMultiply(m_appSettings->getValue(QStringLiteral("lambdamultiply"), QStringLiteral("14.7")).toString());
    setGearCalcEnabled(m_appSettings->getValue(QStringLiteral("gercalactive"), 0).toInt() > 0);
    setMaxRpm(m_appSettings->getValue(QStringLiteral("Max RPM"), QStringLiteral("10000")).toString());
    setShiftStageText(0, m_appSettings->getValue(QStringLiteral("Shift Light1"), QStringLiteral("3000")).toString());
    setShiftStageText(1, m_appSettings->getValue(QStringLiteral("Shift Light2"), QStringLiteral("5500")).toString());
    setShiftStageText(2, m_appSettings->getValue(QStringLiteral("Shift Light3"), QStringLiteral("5500")).toString());
    setShiftStageText(3, m_appSettings->getValue(QStringLiteral("Shift Light4"), QStringLiteral("7500")).toString());
    setGearValueText(0, m_appSettings->getValue(QStringLiteral("valgear1"), QStringLiteral("120")).toString());
    setGearValueText(1, m_appSettings->getValue(QStringLiteral("valgear2"), QStringLiteral("74")).toString());
    setGearValueText(2, m_appSettings->getValue(QStringLiteral("valgear3"), QStringLiteral("54")).toString());
    setGearValueText(3, m_appSettings->getValue(QStringLiteral("valgear4"), QStringLiteral("37")).toString());
    setGearValueText(4, m_appSettings->getValue(QStringLiteral("valgear5"), QStringLiteral("28")).toString());
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
    m_appSettings->writeSpeedSettings(m_speedPercent.toDouble() / 100.0, 100000);
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
