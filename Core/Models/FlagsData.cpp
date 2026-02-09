/**
 * @file FlagsData.cpp
 * @brief Implementation of the FlagsData class
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#include "FlagsData.h"

FlagsData::FlagsData(QObject *parent) : QObject(parent) {}

// * Setters - Numeric Flags
void FlagsData::setFlag1(qreal Flag1)
{
    if (m_Flag1 != Flag1) {
        m_Flag1 = Flag1;
        emit flag1Changed(Flag1);
    }
}
void FlagsData::setFlag2(qreal Flag2)
{
    if (m_Flag2 != Flag2) {
        m_Flag2 = Flag2;
        emit flag2Changed(Flag2);
    }
}
void FlagsData::setFlag3(qreal Flag3)
{
    if (m_Flag3 != Flag3) {
        m_Flag3 = Flag3;
        emit flag3Changed(Flag3);
    }
}
void FlagsData::setFlag4(qreal Flag4)
{
    if (m_Flag4 != Flag4) {
        m_Flag4 = Flag4;
        emit flag4Changed(Flag4);
    }
}
void FlagsData::setFlag5(qreal Flag5)
{
    if (m_Flag5 != Flag5) {
        m_Flag5 = Flag5;
        emit flag5Changed(Flag5);
    }
}
void FlagsData::setFlag6(qreal Flag6)
{
    if (m_Flag6 != Flag6) {
        m_Flag6 = Flag6;
        emit flag6Changed(Flag6);
    }
}
void FlagsData::setFlag7(qreal Flag7)
{
    if (m_Flag7 != Flag7) {
        m_Flag7 = Flag7;
        emit flag7Changed(Flag7);
    }
}
void FlagsData::setFlag8(qreal Flag8)
{
    if (m_Flag8 != Flag8) {
        m_Flag8 = Flag8;
        emit flag8Changed(Flag8);
    }
}
void FlagsData::setFlag9(qreal Flag9)
{
    if (m_Flag9 != Flag9) {
        m_Flag9 = Flag9;
        emit flag9Changed(Flag9);
    }
}
void FlagsData::setFlag10(qreal Flag10)
{
    if (m_Flag10 != Flag10) {
        m_Flag10 = Flag10;
        emit flag10Changed(Flag10);
    }
}
void FlagsData::setFlag11(qreal Flag11)
{
    if (m_Flag11 != Flag11) {
        m_Flag11 = Flag11;
        emit flag11Changed(Flag11);
    }
}
void FlagsData::setFlag12(qreal Flag12)
{
    if (m_Flag12 != Flag12) {
        m_Flag12 = Flag12;
        emit flag12Changed(Flag12);
    }
}
void FlagsData::setFlag13(qreal Flag13)
{
    if (m_Flag13 != Flag13) {
        m_Flag13 = Flag13;
        emit flag13Changed(Flag13);
    }
}
void FlagsData::setFlag14(qreal Flag14)
{
    if (m_Flag14 != Flag14) {
        m_Flag14 = Flag14;
        emit flag14Changed(Flag14);
    }
}
void FlagsData::setFlag15(qreal Flag15)
{
    if (m_Flag15 != Flag15) {
        m_Flag15 = Flag15;
        emit flag15Changed(Flag15);
    }
}
void FlagsData::setFlag16(qreal Flag16)
{
    if (m_Flag16 != Flag16) {
        m_Flag16 = Flag16;
        emit flag16Changed(Flag16);
    }
}
void FlagsData::setFlag17(qreal Flag17)
{
    if (m_Flag17 != Flag17) {
        m_Flag17 = Flag17;
        emit flag17Changed(Flag17);
    }
}
void FlagsData::setFlag18(qreal Flag18)
{
    if (m_Flag18 != Flag18) {
        m_Flag18 = Flag18;
        emit flag18Changed(Flag18);
    }
}
void FlagsData::setFlag19(qreal Flag19)
{
    if (m_Flag19 != Flag19) {
        m_Flag19 = Flag19;
        emit flag19Changed(Flag19);
    }
}
void FlagsData::setFlag20(qreal Flag20)
{
    if (m_Flag20 != Flag20) {
        m_Flag20 = Flag20;
        emit flag20Changed(Flag20);
    }
}
void FlagsData::setFlag21(qreal Flag21)
{
    if (m_Flag21 != Flag21) {
        m_Flag21 = Flag21;
        emit flag21Changed(Flag21);
    }
}
void FlagsData::setFlag22(qreal Flag22)
{
    if (m_Flag22 != Flag22) {
        m_Flag22 = Flag22;
        emit flag22Changed(Flag22);
    }
}
void FlagsData::setFlag23(qreal Flag23)
{
    if (m_Flag23 != Flag23) {
        m_Flag23 = Flag23;
        emit flag23Changed(Flag23);
    }
}
void FlagsData::setFlag24(qreal Flag24)
{
    if (m_Flag24 != Flag24) {
        m_Flag24 = Flag24;
        emit flag24Changed(Flag24);
    }
}
void FlagsData::setFlag25(qreal Flag25)
{
    if (m_Flag25 != Flag25) {
        m_Flag25 = Flag25;
        emit flag25Changed(Flag25);
    }
}

// * Setters - String Flags
void FlagsData::setFlagString1(const QString &FlagString1)
{
    if (m_FlagString1 != FlagString1) {
        m_FlagString1 = FlagString1;
        emit flagString1Changed(FlagString1);
    }
}
void FlagsData::setFlagString2(const QString &FlagString2)
{
    if (m_FlagString2 != FlagString2) {
        m_FlagString2 = FlagString2;
        emit flagString2Changed(FlagString2);
    }
}
void FlagsData::setFlagString3(const QString &FlagString3)
{
    if (m_FlagString3 != FlagString3) {
        m_FlagString3 = FlagString3;
        emit flagString3Changed(FlagString3);
    }
}
void FlagsData::setFlagString4(const QString &FlagString4)
{
    if (m_FlagString4 != FlagString4) {
        m_FlagString4 = FlagString4;
        emit flagString4Changed(FlagString4);
    }
}
void FlagsData::setFlagString5(const QString &FlagString5)
{
    if (m_FlagString5 != FlagString5) {
        m_FlagString5 = FlagString5;
        emit flagString5Changed(FlagString5);
    }
}
void FlagsData::setFlagString6(const QString &FlagString6)
{
    if (m_FlagString6 != FlagString6) {
        m_FlagString6 = FlagString6;
        emit flagString6Changed(FlagString6);
    }
}
void FlagsData::setFlagString7(const QString &FlagString7)
{
    if (m_FlagString7 != FlagString7) {
        m_FlagString7 = FlagString7;
        emit flagString7Changed(FlagString7);
    }
}
void FlagsData::setFlagString8(const QString &FlagString8)
{
    if (m_FlagString8 != FlagString8) {
        m_FlagString8 = FlagString8;
        emit flagString8Changed(FlagString8);
    }
}
void FlagsData::setFlagString9(const QString &FlagString9)
{
    if (m_FlagString9 != FlagString9) {
        m_FlagString9 = FlagString9;
        emit flagString9Changed(FlagString9);
    }
}
void FlagsData::setFlagString10(const QString &FlagString10)
{
    if (m_FlagString10 != FlagString10) {
        m_FlagString10 = FlagString10;
        emit flagString10Changed(FlagString10);
    }
}
void FlagsData::setFlagString11(const QString &FlagString11)
{
    if (m_FlagString11 != FlagString11) {
        m_FlagString11 = FlagString11;
        emit flagString11Changed(FlagString11);
    }
}
void FlagsData::setFlagString12(const QString &FlagString12)
{
    if (m_FlagString12 != FlagString12) {
        m_FlagString12 = FlagString12;
        emit flagString12Changed(FlagString12);
    }
}
void FlagsData::setFlagString13(const QString &FlagString13)
{
    if (m_FlagString13 != FlagString13) {
        m_FlagString13 = FlagString13;
        emit flagString13Changed(FlagString13);
    }
}
void FlagsData::setFlagString14(const QString &FlagString14)
{
    if (m_FlagString14 != FlagString14) {
        m_FlagString14 = FlagString14;
        emit flagString14Changed(FlagString14);
    }
}
void FlagsData::setFlagString15(const QString &FlagString15)
{
    if (m_FlagString15 != FlagString15) {
        m_FlagString15 = FlagString15;
        emit flagString15Changed(FlagString15);
    }
}
void FlagsData::setFlagString16(const QString &FlagString16)
{
    if (m_FlagString16 != FlagString16) {
        m_FlagString16 = FlagString16;
        emit flagString16Changed(FlagString16);
    }
}

// * Setters - Sensor Strings
void FlagsData::setSensorString1(const QString &SensorString1)
{
    if (m_SensorString1 != SensorString1) {
        m_SensorString1 = SensorString1;
        emit sensorString1Changed(SensorString1);
    }
}
void FlagsData::setSensorString2(const QString &SensorString2)
{
    if (m_SensorString2 != SensorString2) {
        m_SensorString2 = SensorString2;
        emit sensorString2Changed(SensorString2);
    }
}
void FlagsData::setSensorString3(const QString &SensorString3)
{
    if (m_SensorString3 != SensorString3) {
        m_SensorString3 = SensorString3;
        emit sensorString3Changed(SensorString3);
    }
}
void FlagsData::setSensorString4(const QString &SensorString4)
{
    if (m_SensorString4 != SensorString4) {
        m_SensorString4 = SensorString4;
        emit sensorString4Changed(SensorString4);
    }
}
void FlagsData::setSensorString5(const QString &SensorString5)
{
    if (m_SensorString5 != SensorString5) {
        m_SensorString5 = SensorString5;
        emit sensorString5Changed(SensorString5);
    }
}
void FlagsData::setSensorString6(const QString &SensorString6)
{
    if (m_SensorString6 != SensorString6) {
        m_SensorString6 = SensorString6;
        emit sensorString6Changed(SensorString6);
    }
}
void FlagsData::setSensorString7(const QString &SensorString7)
{
    if (m_SensorString7 != SensorString7) {
        m_SensorString7 = SensorString7;
        emit sensorString7Changed(SensorString7);
    }
}
void FlagsData::setSensorString8(const QString &SensorString8)
{
    if (m_SensorString8 != SensorString8) {
        m_SensorString8 = SensorString8;
        emit sensorString8Changed(SensorString8);
    }
}
