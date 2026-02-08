/**
 * @file TimingData.h
 * @brief Performance timing/drag strip data model for PowerTune
 * 
 * This class encapsulates drag strip and performance timing data including:
 * - 60ft, 330ft, 1/8 mile, 1/4 mile times/speeds
 * - 0-100, 100-200, 200-300 times
 * - Reaction time
 * - Lap timing data
 * 
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#ifndef TIMINGDATA_H
#define TIMINGDATA_H

#include <QObject>
#include <QString>

class TimingData : public QObject
{
    Q_OBJECT

    // * Drag Strip - Times
    Q_PROPERTY(qreal sixtyfoottime READ sixtyfoottime WRITE setsixtyfoottime NOTIFY sixtyfoottimeChanged)
    Q_PROPERTY(qreal threehundredthirtyfoottime READ threehundredthirtyfoottime WRITE setthreehundredthirtyfoottime NOTIFY threehundredthirtyfoottimeChanged)
    Q_PROPERTY(qreal eightmiletime READ eightmiletime WRITE seteightmiletime NOTIFY eightmiletimeChanged)
    Q_PROPERTY(qreal quartermiletime READ quartermiletime WRITE setquartermiletime NOTIFY quartermiletimeChanged)
    Q_PROPERTY(qreal thousandfoottime READ thousandfoottime WRITE setthousandfoottime NOTIFY thousandfoottimeChanged)

    // * Drag Strip - Speeds
    Q_PROPERTY(qreal sixtyfootspeed READ sixtyfootspeed WRITE setsixtyfootspeed NOTIFY sixtyfootspeedChanged)
    Q_PROPERTY(qreal threehundredthirtyfootspeed READ threehundredthirtyfootspeed WRITE setthreehundredthirtyfootspeed NOTIFY threehundredthirtyfootspeedChanged)
    Q_PROPERTY(qreal eightmilespeed READ eightmilespeed WRITE seteightmilespeed NOTIFY eightmilespeedChanged)
    Q_PROPERTY(qreal quartermilespeed READ quartermilespeed WRITE setquartermilespeed NOTIFY quartermilespeedChanged)
    Q_PROPERTY(qreal thousandfootspeed READ thousandfootspeed WRITE setthousandfootspeed NOTIFY thousandfootspeedChanged)

    // * Speed Tests
    Q_PROPERTY(qreal zerotohundredt READ zerotohundredt WRITE setzerotohundredt NOTIFY zerotohundredtChanged)
    Q_PROPERTY(qreal hundredtotwohundredtime READ hundredtotwohundredtime WRITE sethundredtotwohundredtime NOTIFY hundredtotwohundredtimeChanged)
    Q_PROPERTY(qreal twohundredtothreehundredtime READ twohundredtothreehundredtime WRITE settwohundredtothreehundredtime NOTIFY twohundredtothreehundredtimeChanged)

    // * Reaction
    Q_PROPERTY(qreal reactiontime READ reactiontime WRITE setreactiontime NOTIFY reactiontimeChanged)

    // * Lap Timer
    Q_PROPERTY(QString laptime READ laptime WRITE setlaptime NOTIFY laptimeChanged)
    Q_PROPERTY(QString Lastlaptime READ Lastlaptime WRITE setLastlaptime NOTIFY LastlaptimeChanged)
    Q_PROPERTY(QString bestlaptime READ bestlaptime WRITE setbestlaptime NOTIFY bestlaptimeChanged)
    Q_PROPERTY(int currentLap READ currentLap WRITE setcurrentLap NOTIFY currentLapChanged)

public:
    explicit TimingData(QObject *parent = nullptr);

    // * Getters - Drag Strip Times
    qreal sixtyfoottime() const { return m_sixtyfoottime; }
    qreal threehundredthirtyfoottime() const { return m_threehundredthirtyfoottime; }
    qreal eightmiletime() const { return m_eightmiletime; }
    qreal quartermiletime() const { return m_quartermiletime; }
    qreal thousandfoottime() const { return m_thousandfoottime; }

    // * Getters - Drag Strip Speeds
    qreal sixtyfootspeed() const { return m_sixtyfootspeed; }
    qreal threehundredthirtyfootspeed() const { return m_threehundredthirtyfootspeed; }
    qreal eightmilespeed() const { return m_eightmilespeed; }
    qreal quartermilespeed() const { return m_quartermilespeed; }
    qreal thousandfootspeed() const { return m_thousandfootspeed; }

    // * Getters - Speed Tests
    qreal zerotohundredt() const { return m_zerotohundredt; }
    qreal hundredtotwohundredtime() const { return m_hundredtotwohundredtime; }
    qreal twohundredtothreehundredtime() const { return m_twohundredtothreehundredtime; }

    // * Getters - Reaction
    qreal reactiontime() const { return m_reactiontime; }

    // * Getters - Lap Timer
    QString laptime() const { return m_laptime; }
    QString Lastlaptime() const { return m_Lastlaptime; }
    QString bestlaptime() const { return m_bestlaptime; }
    int currentLap() const { return m_currentLap; }

public slots:
    // * Setters - Drag Strip Times
    void setsixtyfoottime(qreal sixtyfoottime);
    void setthreehundredthirtyfoottime(qreal threehundredthirtyfoottime);
    void seteightmiletime(qreal eightmiletime);
    void setquartermiletime(qreal quartermiletime);
    void setthousandfoottime(qreal thousandfoottime);

    // * Setters - Drag Strip Speeds
    void setsixtyfootspeed(qreal sixtyfootspeed);
    void setthreehundredthirtyfootspeed(qreal threehundredthirtyfootspeed);
    void seteightmilespeed(qreal eightmilespeed);
    void setquartermilespeed(qreal quartermilespeed);
    void setthousandfootspeed(qreal thousandfootspeed);

    // * Setters - Speed Tests
    void setzerotohundredt(qreal zerotohundredt);
    void sethundredtotwohundredtime(qreal hundredtotwohundredtime);
    void settwohundredtothreehundredtime(qreal twohundredtothreehundredtime);

    // * Setters - Reaction
    void setreactiontime(qreal reactiontime);

    // * Setters - Lap Timer
    void setlaptime(const QString &laptime);
    void setLastlaptime(const QString &Lastlaptime);
    void setbestlaptime(const QString &bestlaptime);
    void setcurrentLap(int currentLap);

signals:
    // * Signals - Drag Strip Times
    void sixtyfoottimeChanged(qreal sixtyfoottime);
    void threehundredthirtyfoottimeChanged(qreal threehundredthirtyfoottime);
    void eightmiletimeChanged(qreal eightmiletime);
    void quartermiletimeChanged(qreal quartermiletime);
    void thousandfoottimeChanged(qreal thousandfoottime);

    // * Signals - Drag Strip Speeds
    void sixtyfootspeedChanged(qreal sixtyfootspeed);
    void threehundredthirtyfootspeedChanged(qreal threehundredthirtyfootspeed);
    void eightmilespeedChanged(qreal eightmilespeed);
    void quartermilespeedChanged(qreal quartermilespeed);
    void thousandfootspeedChanged(qreal thousandfootspeed);

    // * Signals - Speed Tests
    void zerotohundredtChanged(qreal zerotohundredt);
    void hundredtotwohundredtimeChanged(qreal hundredtotwohundredtime);
    void twohundredtothreehundredtimeChanged(qreal twohundredtothreehundredtime);

    // * Signals - Reaction
    void reactiontimeChanged(qreal reactiontime);

    // * Signals - Lap Timer
    void laptimeChanged(const QString &laptime);
    void LastlaptimeChanged(const QString &Lastlaptime);
    void bestlaptimeChanged(const QString &bestlaptime);
    void currentLapChanged(int currentLap);

private:
    // * Drag Strip Times
    qreal m_sixtyfoottime = 0;
    qreal m_threehundredthirtyfoottime = 0;
    qreal m_eightmiletime = 0;
    qreal m_quartermiletime = 0;
    qreal m_thousandfoottime = 0;

    // * Drag Strip Speeds
    qreal m_sixtyfootspeed = 0;
    qreal m_threehundredthirtyfootspeed = 0;
    qreal m_eightmilespeed = 0;
    qreal m_quartermilespeed = 0;
    qreal m_thousandfootspeed = 0;

    // * Speed Tests
    qreal m_zerotohundredt = 0;
    qreal m_hundredtotwohundredtime = 0;
    qreal m_twohundredtothreehundredtime = 0;

    // * Reaction
    qreal m_reactiontime = 0;

    // * Lap Timer
    QString m_laptime;
    QString m_Lastlaptime;
    QString m_bestlaptime;
    int m_currentLap = 0;
};

#endif // TIMINGDATA_H
