/**
 * @file TimingData.cpp
 * @brief Implementation of the TimingData class
 * 
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#include "TimingData.h"

TimingData::TimingData(QObject *parent)
    : QObject(parent)
{
}

// * Setters - Drag Strip Times
void TimingData::setsixtyfoottime(qreal sixtyfoottime) { if (m_sixtyfoottime != sixtyfoottime) { m_sixtyfoottime = sixtyfoottime; emit sixtyfoottimeChanged(sixtyfoottime); } }
void TimingData::setthreehundredthirtyfoottime(qreal threehundredthirtyfoottime) { if (m_threehundredthirtyfoottime != threehundredthirtyfoottime) { m_threehundredthirtyfoottime = threehundredthirtyfoottime; emit threehundredthirtyfoottimeChanged(threehundredthirtyfoottime); } }
void TimingData::seteightmiletime(qreal eightmiletime) { if (m_eightmiletime != eightmiletime) { m_eightmiletime = eightmiletime; emit eightmiletimeChanged(eightmiletime); } }
void TimingData::setquartermiletime(qreal quartermiletime) { if (m_quartermiletime != quartermiletime) { m_quartermiletime = quartermiletime; emit quartermiletimeChanged(quartermiletime); } }
void TimingData::setthousandfoottime(qreal thousandfoottime) { if (m_thousandfoottime != thousandfoottime) { m_thousandfoottime = thousandfoottime; emit thousandfoottimeChanged(thousandfoottime); } }

// * Setters - Drag Strip Speeds
void TimingData::setsixtyfootspeed(qreal sixtyfootspeed) { if (m_sixtyfootspeed != sixtyfootspeed) { m_sixtyfootspeed = sixtyfootspeed; emit sixtyfootspeedChanged(sixtyfootspeed); } }
void TimingData::setthreehundredthirtyfootspeed(qreal threehundredthirtyfootspeed) { if (m_threehundredthirtyfootspeed != threehundredthirtyfootspeed) { m_threehundredthirtyfootspeed = threehundredthirtyfootspeed; emit threehundredthirtyfootspeedChanged(threehundredthirtyfootspeed); } }
void TimingData::seteightmilespeed(qreal eightmilespeed) { if (m_eightmilespeed != eightmilespeed) { m_eightmilespeed = eightmilespeed; emit eightmilespeedChanged(eightmilespeed); } }
void TimingData::setquartermilespeed(qreal quartermilespeed) { if (m_quartermilespeed != quartermilespeed) { m_quartermilespeed = quartermilespeed; emit quartermilespeedChanged(quartermilespeed); } }
void TimingData::setthousandfootspeed(qreal thousandfootspeed) { if (m_thousandfootspeed != thousandfootspeed) { m_thousandfootspeed = thousandfootspeed; emit thousandfootspeedChanged(thousandfootspeed); } }

// * Setters - Speed Tests
void TimingData::setzerotohundredt(qreal zerotohundredt) { if (m_zerotohundredt != zerotohundredt) { m_zerotohundredt = zerotohundredt; emit zerotohundredtChanged(zerotohundredt); } }
void TimingData::sethundredtotwohundredtime(qreal hundredtotwohundredtime) { if (m_hundredtotwohundredtime != hundredtotwohundredtime) { m_hundredtotwohundredtime = hundredtotwohundredtime; emit hundredtotwohundredtimeChanged(hundredtotwohundredtime); } }
void TimingData::settwohundredtothreehundredtime(qreal twohundredtothreehundredtime) { if (m_twohundredtothreehundredtime != twohundredtothreehundredtime) { m_twohundredtothreehundredtime = twohundredtothreehundredtime; emit twohundredtothreehundredtimeChanged(twohundredtothreehundredtime); } }

// * Setters - Reaction
void TimingData::setreactiontime(qreal reactiontime) { if (m_reactiontime != reactiontime) { m_reactiontime = reactiontime; emit reactiontimeChanged(reactiontime); } }

// * Setters - Lap Timer
void TimingData::setlaptime(const QString &laptime) { if (m_laptime != laptime) { m_laptime = laptime; emit laptimeChanged(laptime); } }
void TimingData::setLastlaptime(const QString &Lastlaptime) { if (m_Lastlaptime != Lastlaptime) { m_Lastlaptime = Lastlaptime; emit LastlaptimeChanged(Lastlaptime); } }
void TimingData::setbestlaptime(const QString &bestlaptime) { if (m_bestlaptime != bestlaptime) { m_bestlaptime = bestlaptime; emit bestlaptimeChanged(bestlaptime); } }
void TimingData::setcurrentLap(int currentLap) { if (m_currentLap != currentLap) { m_currentLap = currentLap; emit currentLapChanged(currentLap); } }
