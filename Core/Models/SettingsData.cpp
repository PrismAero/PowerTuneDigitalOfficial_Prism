/**
 * @file SettingsData.cpp
 * @brief Implementation of SettingsData model
 */

#include "SettingsData.h"

SettingsData::SettingsData(QObject *parent)
    : QObject(parent)
{
}

// * Setters - Units
void SettingsData::setunits(const QString &units)
{
    if (m_units == units)
        return;
    m_units = units;
    emit unitsChanged(m_units);
}

void SettingsData::setspeedunits(const QString &speedunits)
{
    if (m_speedunits == speedunits)
        return;
    m_speedunits = speedunits;
    emit speedunitsChanged(m_speedunits);
}

void SettingsData::setpressureunits(const QString &pressureunits)
{
    if (m_pressureunits == pressureunits)
        return;
    m_pressureunits = pressureunits;
    emit pressureunitsChanged(m_pressureunits);
}

// * Setters - RPM configuration
void SettingsData::setmaxRPM(int maxRPM)
{
    if (m_maxRPM == maxRPM)
        return;
    m_maxRPM = maxRPM;
    emit maxRPMChanged(m_maxRPM);
}

void SettingsData::setrpmStage1(int rpmStage1)
{
    if (m_rpmStage1 == rpmStage1)
        return;
    m_rpmStage1 = rpmStage1;
    emit rpmStage1Changed(m_rpmStage1);
}

void SettingsData::setrpmStage2(int rpmStage2)
{
    if (m_rpmStage2 == rpmStage2)
        return;
    m_rpmStage2 = rpmStage2;
    emit rpmStage2Changed(m_rpmStage2);
}

void SettingsData::setrpmStage3(int rpmStage3)
{
    if (m_rpmStage3 == rpmStage3)
        return;
    m_rpmStage3 = rpmStage3;
    emit rpmStage3Changed(m_rpmStage3);
}

void SettingsData::setrpmStage4(int rpmStage4)
{
    if (m_rpmStage4 == rpmStage4)
        return;
    m_rpmStage4 = rpmStage4;
    emit rpmStage4Changed(m_rpmStage4);
}

// * Setters - Warning thresholds
void SettingsData::setwaterwarn(int waterwarn)
{
    if (m_waterwarn == waterwarn)
        return;
    m_waterwarn = waterwarn;
    emit waterwarnChanged(m_waterwarn);
}

void SettingsData::setrpmwarn(int rpmwarn)
{
    if (m_rpmwarn == rpmwarn)
        return;
    m_rpmwarn = rpmwarn;
    emit rpmwarnChanged(m_rpmwarn);
}

void SettingsData::setknockwarn(int knockwarn)
{
    if (m_knockwarn == knockwarn)
        return;
    m_knockwarn = knockwarn;
    emit knockwarnChanged(m_knockwarn);
}

void SettingsData::setboostwarn(qreal boostwarn)
{
    if (qFuzzyCompare(m_boostwarn, boostwarn))
        return;
    m_boostwarn = boostwarn;
    emit boostwarnChanged(m_boostwarn);
}

// * Setters - Smoothing
void SettingsData::setsmoothrpm(int smoothrpm)
{
    if (m_smoothrpm == smoothrpm)
        return;
    m_smoothrpm = smoothrpm;
    emit smoothrpmChanged(m_smoothrpm);
}

void SettingsData::setsmoothspeed(int smoothspeed)
{
    if (m_smoothspeed == smoothspeed)
        return;
    m_smoothspeed = smoothspeed;
    emit smoothspeedChanged(m_smoothspeed);
}

// * Setters - Gear calculation parameters
void SettingsData::setgearcalcactivation(int gearcalcactivation)
{
    if (m_gearcalcactivation == gearcalcactivation)
        return;
    m_gearcalcactivation = gearcalcactivation;
    emit gearcalcactivationChanged(m_gearcalcactivation);
}

void SettingsData::setgearcalc1(int gearcalc1)
{
    if (m_gearcalc1 == gearcalc1)
        return;
    m_gearcalc1 = gearcalc1;
    emit gearcalc1Changed(m_gearcalc1);
}

void SettingsData::setgearcalc2(int gearcalc2)
{
    if (m_gearcalc2 == gearcalc2)
        return;
    m_gearcalc2 = gearcalc2;
    emit gearcalc2Changed(m_gearcalc2);
}

void SettingsData::setgearcalc3(int gearcalc3)
{
    if (m_gearcalc3 == gearcalc3)
        return;
    m_gearcalc3 = gearcalc3;
    emit gearcalc3Changed(m_gearcalc3);
}

void SettingsData::setgearcalc4(int gearcalc4)
{
    if (m_gearcalc4 == gearcalc4)
        return;
    m_gearcalc4 = gearcalc4;
    emit gearcalc4Changed(m_gearcalc4);
}

void SettingsData::setgearcalc5(int gearcalc5)
{
    if (m_gearcalc5 == gearcalc5)
        return;
    m_gearcalc5 = gearcalc5;
    emit gearcalc5Changed(m_gearcalc5);
}

void SettingsData::setgearcalc6(int gearcalc6)
{
    if (m_gearcalc6 == gearcalc6)
        return;
    m_gearcalc6 = gearcalc6;
    emit gearcalc6Changed(m_gearcalc6);
}

// * Setters - External speed/rpm
void SettingsData::setExternalSpeed(int ExternalSpeed)
{
    if (m_ExternalSpeed == ExternalSpeed)
        return;
    m_ExternalSpeed = ExternalSpeed;
    emit ExternalSpeedChanged(m_ExternalSpeed);
}

void SettingsData::setExternalrpm(int Externalrpm)
{
    if (m_Externalrpm == Externalrpm)
        return;
    m_Externalrpm = Externalrpm;
    emit ExternalrpmChanged(m_Externalrpm);
}

// * Setters - Speed configuration
void SettingsData::setspeedpercent(qreal speedpercent)
{
    if (qFuzzyCompare(m_speedpercent, speedpercent))
        return;
    m_speedpercent = speedpercent;
    emit speedpercentChanged(m_speedpercent);
}

void SettingsData::setpulsespermile(qreal pulsespermile)
{
    if (qFuzzyCompare(m_pulsespermile, pulsespermile))
        return;
    m_pulsespermile = pulsespermile;
    emit pulsespermileChanged(m_pulsespermile);
}

// * Setters - Language
void SettingsData::setlanguage(int language)
{
    if (m_language == language)
        return;
    m_language = language;
    emit languageChanged(m_language);
}

// * Setters - Country/Track settings
void SettingsData::setCBXCountrysave(const QString &CBXCountrysave)
{
    if (m_CBXCountrysave == CBXCountrysave)
        return;
    m_CBXCountrysave = CBXCountrysave;
    emit CBXCountrysaveChanged(m_CBXCountrysave);
}

void SettingsData::setCBXTracksave(const QString &CBXTracksave)
{
    if (m_CBXTracksave == CBXTracksave)
        return;
    m_CBXTracksave = CBXTracksave;
    emit CBXTracksaveChanged(m_CBXTracksave);
}

// * Setters - License/Product settings
void SettingsData::setdaemonlicense(const QString &daemonlicense)
{
    if (m_daemonlicense == daemonlicense)
        return;
    m_daemonlicense = daemonlicense;
    emit daemonlicenseChanged(m_daemonlicense);
}

void SettingsData::setholleyproductid(const QString &holleyproductid)
{
    if (m_holleyproductid == holleyproductid)
        return;
    m_holleyproductid = holleyproductid;
    emit holleyproductidChanged(m_holleyproductid);
}

// * Setters - Additional smoothing
void SettingsData::setsmootexAnalogInput7(int smootexAnalogInput7)
{
    if (m_smootexAnalogInput7 == smootexAnalogInput7)
        return;
    m_smootexAnalogInput7 = smootexAnalogInput7;
    emit smootexAnalogInput7Changed(m_smootexAnalogInput7);
}
