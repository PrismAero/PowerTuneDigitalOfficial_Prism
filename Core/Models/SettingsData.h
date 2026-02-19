/**
 * @file SettingsData.h
 * @brief User configuration settings data model for PowerTune
 *
 * This class encapsulates user-configurable settings including:
 * - Units (units, speedunits, pressureunits)
 * - RPM configuration (maxRPM, rpmStage1-4)
 * - Warning thresholds (waterwarn, rpmwarn, knockwarn, boostwarn)
 * - Smoothing (smoothrpm, smoothspeed)
 * - Gear calculation parameters (gearcalc1-6)
 * - External speed/rpm configuration
 * - Pulses per mile
 * - Language selection
 *
 * Part of the DashBoard God Object refactoring (Phase 3)
 */

#ifndef SETTINGSDATA_H
#define SETTINGSDATA_H

#include <QObject>
#include <QString>

class SettingsData : public QObject
{
    Q_OBJECT

    // * Units
    Q_PROPERTY(QString units READ units WRITE setunits NOTIFY unitsChanged)
    Q_PROPERTY(QString speedunits READ speedunits WRITE setspeedunits NOTIFY speedunitsChanged)
    Q_PROPERTY(QString pressureunits READ pressureunits WRITE setpressureunits NOTIFY pressureunitsChanged)

    // * RPM configuration
    Q_PROPERTY(int maxRPM READ maxRPM WRITE setmaxRPM NOTIFY maxRPMChanged)
    Q_PROPERTY(int rpmStage1 READ rpmStage1 WRITE setrpmStage1 NOTIFY rpmStage1Changed)
    Q_PROPERTY(int rpmStage2 READ rpmStage2 WRITE setrpmStage2 NOTIFY rpmStage2Changed)
    Q_PROPERTY(int rpmStage3 READ rpmStage3 WRITE setrpmStage3 NOTIFY rpmStage3Changed)
    Q_PROPERTY(int rpmStage4 READ rpmStage4 WRITE setrpmStage4 NOTIFY rpmStage4Changed)

    // * Warning thresholds
    Q_PROPERTY(int waterwarn READ waterwarn WRITE setwaterwarn NOTIFY waterwarnChanged)
    Q_PROPERTY(int rpmwarn READ rpmwarn WRITE setrpmwarn NOTIFY rpmwarnChanged)
    Q_PROPERTY(int knockwarn READ knockwarn WRITE setknockwarn NOTIFY knockwarnChanged)
    Q_PROPERTY(qreal boostwarn READ boostwarn WRITE setboostwarn NOTIFY boostwarnChanged)

    // * Smoothing
    Q_PROPERTY(int smoothrpm READ smoothrpm WRITE setsmoothrpm NOTIFY smoothrpmChanged)
    Q_PROPERTY(int smoothspeed READ smoothspeed WRITE setsmoothspeed NOTIFY smoothspeedChanged)

    // * Gear calculation parameters
    Q_PROPERTY(int gearcalcactivation READ gearcalcactivation WRITE setgearcalcactivation NOTIFY gearcalcactivationChanged)
    Q_PROPERTY(int gearcalc1 READ gearcalc1 WRITE setgearcalc1 NOTIFY gearcalc1Changed)
    Q_PROPERTY(int gearcalc2 READ gearcalc2 WRITE setgearcalc2 NOTIFY gearcalc2Changed)
    Q_PROPERTY(int gearcalc3 READ gearcalc3 WRITE setgearcalc3 NOTIFY gearcalc3Changed)
    Q_PROPERTY(int gearcalc4 READ gearcalc4 WRITE setgearcalc4 NOTIFY gearcalc4Changed)
    Q_PROPERTY(int gearcalc5 READ gearcalc5 WRITE setgearcalc5 NOTIFY gearcalc5Changed)
    Q_PROPERTY(int gearcalc6 READ gearcalc6 WRITE setgearcalc6 NOTIFY gearcalc6Changed)

    // * External speed/rpm
    Q_PROPERTY(int ExternalSpeed READ ExternalSpeed WRITE setExternalSpeed NOTIFY ExternalSpeedChanged)
    Q_PROPERTY(int Externalrpm READ Externalrpm WRITE setExternalrpm NOTIFY ExternalrpmChanged)

    // * Speed configuration
    Q_PROPERTY(qreal speedpercent READ speedpercent WRITE setspeedpercent NOTIFY speedpercentChanged)
    Q_PROPERTY(qreal pulsespermile READ pulsespermile WRITE setpulsespermile NOTIFY pulsespermileChanged)

    // * Language
    Q_PROPERTY(int language READ language WRITE setlanguage NOTIFY languageChanged)

    // * Country/Track settings
    Q_PROPERTY(QString CBXCountrysave READ CBXCountrysave WRITE setCBXCountrysave NOTIFY CBXCountrysaveChanged)
    Q_PROPERTY(QString CBXTracksave READ CBXTracksave WRITE setCBXTracksave NOTIFY CBXTracksaveChanged)

    // * daemonlicense/holleyproductid moved to ConnectionData

    // * Additional smoothing
    Q_PROPERTY(int smootexAnalogInput7 READ smootexAnalogInput7 WRITE setsmootexAnalogInput7 NOTIFY smootexAnalogInput7Changed)

public:
    explicit SettingsData(QObject *parent = nullptr);

    // * Getters - Units
    QString units() const { return m_units; }
    QString speedunits() const { return m_speedunits; }
    QString pressureunits() const { return m_pressureunits; }

    // * Getters - RPM configuration
    int maxRPM() const { return m_maxRPM; }
    int rpmStage1() const { return m_rpmStage1; }
    int rpmStage2() const { return m_rpmStage2; }
    int rpmStage3() const { return m_rpmStage3; }
    int rpmStage4() const { return m_rpmStage4; }

    // * Getters - Warning thresholds
    int waterwarn() const { return m_waterwarn; }
    int rpmwarn() const { return m_rpmwarn; }
    int knockwarn() const { return m_knockwarn; }
    qreal boostwarn() const { return m_boostwarn; }

    // * Getters - Smoothing
    int smoothrpm() const { return m_smoothrpm; }
    int smoothspeed() const { return m_smoothspeed; }

    // * Getters - Gear calculation parameters
    int gearcalcactivation() const { return m_gearcalcactivation; }
    int gearcalc1() const { return m_gearcalc1; }
    int gearcalc2() const { return m_gearcalc2; }
    int gearcalc3() const { return m_gearcalc3; }
    int gearcalc4() const { return m_gearcalc4; }
    int gearcalc5() const { return m_gearcalc5; }
    int gearcalc6() const { return m_gearcalc6; }

    // * Getters - External speed/rpm
    int ExternalSpeed() const { return m_ExternalSpeed; }
    int Externalrpm() const { return m_Externalrpm; }

    // * Getters - Speed configuration
    qreal speedpercent() const { return m_speedpercent; }
    qreal pulsespermile() const { return m_pulsespermile; }

    // * Getters - Language
    int language() const { return m_language; }

    // * Getters - Country/Track settings
    QString CBXCountrysave() const { return m_CBXCountrysave; }
    QString CBXTracksave() const { return m_CBXTracksave; }

    // * daemonlicense/holleyproductid getters moved to ConnectionData

    // * Getters - Additional smoothing
    int smootexAnalogInput7() const { return m_smootexAnalogInput7; }

public slots:
    // * Setters - Units
    void setunits(const QString &units);
    void setspeedunits(const QString &speedunits);
    void setpressureunits(const QString &pressureunits);

    // * Setters - RPM configuration
    void setmaxRPM(int maxRPM);
    void setrpmStage1(int rpmStage1);
    void setrpmStage2(int rpmStage2);
    void setrpmStage3(int rpmStage3);
    void setrpmStage4(int rpmStage4);

    // * Setters - Warning thresholds
    void setwaterwarn(int waterwarn);
    void setrpmwarn(int rpmwarn);
    void setknockwarn(int knockwarn);
    void setboostwarn(qreal boostwarn);

    // * Setters - Smoothing
    void setsmoothrpm(int smoothrpm);
    void setsmoothspeed(int smoothspeed);

    // * Setters - Gear calculation parameters
    void setgearcalcactivation(int gearcalcactivation);
    void setgearcalc1(int gearcalc1);
    void setgearcalc2(int gearcalc2);
    void setgearcalc3(int gearcalc3);
    void setgearcalc4(int gearcalc4);
    void setgearcalc5(int gearcalc5);
    void setgearcalc6(int gearcalc6);

    // * Setters - External speed/rpm
    void setExternalSpeed(int ExternalSpeed);
    void setExternalrpm(int Externalrpm);

    // * Setters - Speed configuration
    void setspeedpercent(qreal speedpercent);
    void setpulsespermile(qreal pulsespermile);

    // * Setters - Language
    void setlanguage(int language);

    // * Setters - Country/Track settings
    void setCBXCountrysave(const QString &CBXCountrysave);
    void setCBXTracksave(const QString &CBXTracksave);

    // * daemonlicense/holleyproductid setters moved to ConnectionData

    // * Setters - Additional smoothing
    void setsmootexAnalogInput7(int smootexAnalogInput7);

signals:
    // * Signals - Units
    void unitsChanged(const QString &units);
    void speedunitsChanged(const QString &speedunits);
    void pressureunitsChanged(const QString &pressureunits);

    // * Signals - RPM configuration
    void maxRPMChanged(int maxRPM);
    void rpmStage1Changed(int rpmStage1);
    void rpmStage2Changed(int rpmStage2);
    void rpmStage3Changed(int rpmStage3);
    void rpmStage4Changed(int rpmStage4);

    // * Signals - Warning thresholds
    void waterwarnChanged(int waterwarn);
    void rpmwarnChanged(int rpmwarn);
    void knockwarnChanged(int knockwarn);
    void boostwarnChanged(qreal boostwarn);

    // * Signals - Smoothing
    void smoothrpmChanged(int smoothrpm);
    void smoothspeedChanged(int smoothspeed);

    // * Signals - Gear calculation parameters
    void gearcalcactivationChanged(int gearcalcactivation);
    void gearcalc1Changed(int gearcalc1);
    void gearcalc2Changed(int gearcalc2);
    void gearcalc3Changed(int gearcalc3);
    void gearcalc4Changed(int gearcalc4);
    void gearcalc5Changed(int gearcalc5);
    void gearcalc6Changed(int gearcalc6);

    // * Signals - External speed/rpm
    void ExternalSpeedChanged(int ExternalSpeed);
    void ExternalrpmChanged(int Externalrpm);

    // * Signals - Speed configuration
    void speedpercentChanged(qreal speedpercent);
    void pulsespermileChanged(qreal pulsespermile);

    // * Signals - Language
    void languageChanged(int language);

    // * Signals - Country/Track settings
    void CBXCountrysaveChanged(const QString &CBXCountrysave);
    void CBXTracksaveChanged(const QString &CBXTracksave);

    // * daemonlicense/holleyproductid signals moved to ConnectionData

    // * Signals - Additional smoothing
    void smootexAnalogInput7Changed(int smootexAnalogInput7);

private:
    // * Units
    QString m_units;
    QString m_speedunits;
    QString m_pressureunits;

    // * RPM configuration
    int m_maxRPM = 9000;
    int m_rpmStage1 = 6000;
    int m_rpmStage2 = 7000;
    int m_rpmStage3 = 7500;
    int m_rpmStage4 = 8000;

    // * Warning thresholds
    int m_waterwarn = 100;
    int m_rpmwarn = 7500;
    int m_knockwarn = 50;
    qreal m_boostwarn = 1.5;

    // * Smoothing
    int m_smoothrpm = 0;
    int m_smoothspeed = 0;

    // * Gear calculation parameters
    int m_gearcalcactivation = 0;
    int m_gearcalc1 = 0;
    int m_gearcalc2 = 0;
    int m_gearcalc3 = 0;
    int m_gearcalc4 = 0;
    int m_gearcalc5 = 0;
    int m_gearcalc6 = 0;

    // * External speed/rpm
    int m_ExternalSpeed = 0;
    int m_Externalrpm = 0;

    // * Speed configuration
    qreal m_speedpercent = 0;
    qreal m_pulsespermile = 0;

    // * Language
    int m_language = 0;

    // * Country/Track settings
    QString m_CBXCountrysave;
    QString m_CBXTracksave;

    // * daemonlicense/holleyproductid members moved to ConnectionData

    // * Additional smoothing
    int m_smootexAnalogInput7 = 0;
};

#endif  // SETTINGSDATA_H
