/**
 * @file FlagsData.h
 * @brief ECU status flags data model for PowerTune
 *
 * This class encapsulates ECU flag/status data including:
 * - Flag1-25 (numeric flags)
 * - FlagString1-16 (text flags)
 * - SensorString1-8 (sensor labels)
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#ifndef FLAGSDATA_H
#define FLAGSDATA_H

#include <QObject>
#include <QString>

class FlagsData : public QObject
{
    Q_OBJECT

    // * Numeric Flags
    Q_PROPERTY(qreal Flag1 READ Flag1 WRITE setFlag1 NOTIFY flag1Changed)
    Q_PROPERTY(qreal Flag2 READ Flag2 WRITE setFlag2 NOTIFY flag2Changed)
    Q_PROPERTY(qreal Flag3 READ Flag3 WRITE setFlag3 NOTIFY flag3Changed)
    Q_PROPERTY(qreal Flag4 READ Flag4 WRITE setFlag4 NOTIFY flag4Changed)
    Q_PROPERTY(qreal Flag5 READ Flag5 WRITE setFlag5 NOTIFY flag5Changed)
    Q_PROPERTY(qreal Flag6 READ Flag6 WRITE setFlag6 NOTIFY flag6Changed)
    Q_PROPERTY(qreal Flag7 READ Flag7 WRITE setFlag7 NOTIFY flag7Changed)
    Q_PROPERTY(qreal Flag8 READ Flag8 WRITE setFlag8 NOTIFY flag8Changed)
    Q_PROPERTY(qreal Flag9 READ Flag9 WRITE setFlag9 NOTIFY flag9Changed)
    Q_PROPERTY(qreal Flag10 READ Flag10 WRITE setFlag10 NOTIFY flag10Changed)
    Q_PROPERTY(qreal Flag11 READ Flag11 WRITE setFlag11 NOTIFY flag11Changed)
    Q_PROPERTY(qreal Flag12 READ Flag12 WRITE setFlag12 NOTIFY flag12Changed)
    Q_PROPERTY(qreal Flag13 READ Flag13 WRITE setFlag13 NOTIFY flag13Changed)
    Q_PROPERTY(qreal Flag14 READ Flag14 WRITE setFlag14 NOTIFY flag14Changed)
    Q_PROPERTY(qreal Flag15 READ Flag15 WRITE setFlag15 NOTIFY flag15Changed)
    Q_PROPERTY(qreal Flag16 READ Flag16 WRITE setFlag16 NOTIFY flag16Changed)
    Q_PROPERTY(qreal Flag17 READ Flag17 WRITE setFlag17 NOTIFY flag17Changed)
    Q_PROPERTY(qreal Flag18 READ Flag18 WRITE setFlag18 NOTIFY flag18Changed)
    Q_PROPERTY(qreal Flag19 READ Flag19 WRITE setFlag19 NOTIFY flag19Changed)
    Q_PROPERTY(qreal Flag20 READ Flag20 WRITE setFlag20 NOTIFY flag20Changed)
    Q_PROPERTY(qreal Flag21 READ Flag21 WRITE setFlag21 NOTIFY flag21Changed)
    Q_PROPERTY(qreal Flag22 READ Flag22 WRITE setFlag22 NOTIFY flag22Changed)
    Q_PROPERTY(qreal Flag23 READ Flag23 WRITE setFlag23 NOTIFY flag23Changed)
    Q_PROPERTY(qreal Flag24 READ Flag24 WRITE setFlag24 NOTIFY flag24Changed)
    Q_PROPERTY(qreal Flag25 READ Flag25 WRITE setFlag25 NOTIFY flag25Changed)

    // * String Flags
    Q_PROPERTY(QString FlagString1 READ FlagString1 WRITE setFlagString1 NOTIFY flagString1Changed)
    Q_PROPERTY(QString FlagString2 READ FlagString2 WRITE setFlagString2 NOTIFY flagString2Changed)
    Q_PROPERTY(QString FlagString3 READ FlagString3 WRITE setFlagString3 NOTIFY flagString3Changed)
    Q_PROPERTY(QString FlagString4 READ FlagString4 WRITE setFlagString4 NOTIFY flagString4Changed)
    Q_PROPERTY(QString FlagString5 READ FlagString5 WRITE setFlagString5 NOTIFY flagString5Changed)
    Q_PROPERTY(QString FlagString6 READ FlagString6 WRITE setFlagString6 NOTIFY flagString6Changed)
    Q_PROPERTY(QString FlagString7 READ FlagString7 WRITE setFlagString7 NOTIFY flagString7Changed)
    Q_PROPERTY(QString FlagString8 READ FlagString8 WRITE setFlagString8 NOTIFY flagString8Changed)
    Q_PROPERTY(QString FlagString9 READ FlagString9 WRITE setFlagString9 NOTIFY flagString9Changed)
    Q_PROPERTY(QString FlagString10 READ FlagString10 WRITE setFlagString10 NOTIFY flagString10Changed)
    Q_PROPERTY(QString FlagString11 READ FlagString11 WRITE setFlagString11 NOTIFY flagString11Changed)
    Q_PROPERTY(QString FlagString12 READ FlagString12 WRITE setFlagString12 NOTIFY flagString12Changed)
    Q_PROPERTY(QString FlagString13 READ FlagString13 WRITE setFlagString13 NOTIFY flagString13Changed)
    Q_PROPERTY(QString FlagString14 READ FlagString14 WRITE setFlagString14 NOTIFY flagString14Changed)
    Q_PROPERTY(QString FlagString15 READ FlagString15 WRITE setFlagString15 NOTIFY flagString15Changed)
    Q_PROPERTY(QString FlagString16 READ FlagString16 WRITE setFlagString16 NOTIFY flagString16Changed)

    // * Sensor Strings
    Q_PROPERTY(QString SensorString1 READ SensorString1 WRITE setSensorString1 NOTIFY sensorString1Changed)
    Q_PROPERTY(QString SensorString2 READ SensorString2 WRITE setSensorString2 NOTIFY sensorString2Changed)
    Q_PROPERTY(QString SensorString3 READ SensorString3 WRITE setSensorString3 NOTIFY sensorString3Changed)
    Q_PROPERTY(QString SensorString4 READ SensorString4 WRITE setSensorString4 NOTIFY sensorString4Changed)
    Q_PROPERTY(QString SensorString5 READ SensorString5 WRITE setSensorString5 NOTIFY sensorString5Changed)
    Q_PROPERTY(QString SensorString6 READ SensorString6 WRITE setSensorString6 NOTIFY sensorString6Changed)
    Q_PROPERTY(QString SensorString7 READ SensorString7 WRITE setSensorString7 NOTIFY sensorString7Changed)
    Q_PROPERTY(QString SensorString8 READ SensorString8 WRITE setSensorString8 NOTIFY sensorString8Changed)

public:
    explicit FlagsData(QObject *parent = nullptr);

    // * Getters - Numeric Flags
    qreal Flag1() const { return m_Flag1; }
    qreal Flag2() const { return m_Flag2; }
    qreal Flag3() const { return m_Flag3; }
    qreal Flag4() const { return m_Flag4; }
    qreal Flag5() const { return m_Flag5; }
    qreal Flag6() const { return m_Flag6; }
    qreal Flag7() const { return m_Flag7; }
    qreal Flag8() const { return m_Flag8; }
    qreal Flag9() const { return m_Flag9; }
    qreal Flag10() const { return m_Flag10; }
    qreal Flag11() const { return m_Flag11; }
    qreal Flag12() const { return m_Flag12; }
    qreal Flag13() const { return m_Flag13; }
    qreal Flag14() const { return m_Flag14; }
    qreal Flag15() const { return m_Flag15; }
    qreal Flag16() const { return m_Flag16; }
    qreal Flag17() const { return m_Flag17; }
    qreal Flag18() const { return m_Flag18; }
    qreal Flag19() const { return m_Flag19; }
    qreal Flag20() const { return m_Flag20; }
    qreal Flag21() const { return m_Flag21; }
    qreal Flag22() const { return m_Flag22; }
    qreal Flag23() const { return m_Flag23; }
    qreal Flag24() const { return m_Flag24; }
    qreal Flag25() const { return m_Flag25; }

    // * Getters - String Flags
    QString FlagString1() const { return m_FlagString1; }
    QString FlagString2() const { return m_FlagString2; }
    QString FlagString3() const { return m_FlagString3; }
    QString FlagString4() const { return m_FlagString4; }
    QString FlagString5() const { return m_FlagString5; }
    QString FlagString6() const { return m_FlagString6; }
    QString FlagString7() const { return m_FlagString7; }
    QString FlagString8() const { return m_FlagString8; }
    QString FlagString9() const { return m_FlagString9; }
    QString FlagString10() const { return m_FlagString10; }
    QString FlagString11() const { return m_FlagString11; }
    QString FlagString12() const { return m_FlagString12; }
    QString FlagString13() const { return m_FlagString13; }
    QString FlagString14() const { return m_FlagString14; }
    QString FlagString15() const { return m_FlagString15; }
    QString FlagString16() const { return m_FlagString16; }

    // * Getters - Sensor Strings
    QString SensorString1() const { return m_SensorString1; }
    QString SensorString2() const { return m_SensorString2; }
    QString SensorString3() const { return m_SensorString3; }
    QString SensorString4() const { return m_SensorString4; }
    QString SensorString5() const { return m_SensorString5; }
    QString SensorString6() const { return m_SensorString6; }
    QString SensorString7() const { return m_SensorString7; }
    QString SensorString8() const { return m_SensorString8; }

public slots:
    // * Setters - Numeric Flags
    void setFlag1(qreal Flag1);
    void setFlag2(qreal Flag2);
    void setFlag3(qreal Flag3);
    void setFlag4(qreal Flag4);
    void setFlag5(qreal Flag5);
    void setFlag6(qreal Flag6);
    void setFlag7(qreal Flag7);
    void setFlag8(qreal Flag8);
    void setFlag9(qreal Flag9);
    void setFlag10(qreal Flag10);
    void setFlag11(qreal Flag11);
    void setFlag12(qreal Flag12);
    void setFlag13(qreal Flag13);
    void setFlag14(qreal Flag14);
    void setFlag15(qreal Flag15);
    void setFlag16(qreal Flag16);
    void setFlag17(qreal Flag17);
    void setFlag18(qreal Flag18);
    void setFlag19(qreal Flag19);
    void setFlag20(qreal Flag20);
    void setFlag21(qreal Flag21);
    void setFlag22(qreal Flag22);
    void setFlag23(qreal Flag23);
    void setFlag24(qreal Flag24);
    void setFlag25(qreal Flag25);

    // * Setters - String Flags
    void setFlagString1(const QString &FlagString1);
    void setFlagString2(const QString &FlagString2);
    void setFlagString3(const QString &FlagString3);
    void setFlagString4(const QString &FlagString4);
    void setFlagString5(const QString &FlagString5);
    void setFlagString6(const QString &FlagString6);
    void setFlagString7(const QString &FlagString7);
    void setFlagString8(const QString &FlagString8);
    void setFlagString9(const QString &FlagString9);
    void setFlagString10(const QString &FlagString10);
    void setFlagString11(const QString &FlagString11);
    void setFlagString12(const QString &FlagString12);
    void setFlagString13(const QString &FlagString13);
    void setFlagString14(const QString &FlagString14);
    void setFlagString15(const QString &FlagString15);
    void setFlagString16(const QString &FlagString16);

    // * Setters - Sensor Strings
    void setSensorString1(const QString &SensorString1);
    void setSensorString2(const QString &SensorString2);
    void setSensorString3(const QString &SensorString3);
    void setSensorString4(const QString &SensorString4);
    void setSensorString5(const QString &SensorString5);
    void setSensorString6(const QString &SensorString6);
    void setSensorString7(const QString &SensorString7);
    void setSensorString8(const QString &SensorString8);

signals:
    // * Signals - Numeric Flags
    void flag1Changed(qreal Flag1);
    void flag2Changed(qreal Flag2);
    void flag3Changed(qreal Flag3);
    void flag4Changed(qreal Flag4);
    void flag5Changed(qreal Flag5);
    void flag6Changed(qreal Flag6);
    void flag7Changed(qreal Flag7);
    void flag8Changed(qreal Flag8);
    void flag9Changed(qreal Flag9);
    void flag10Changed(qreal Flag10);
    void flag11Changed(qreal Flag11);
    void flag12Changed(qreal Flag12);
    void flag13Changed(qreal Flag13);
    void flag14Changed(qreal Flag14);
    void flag15Changed(qreal Flag15);
    void flag16Changed(qreal Flag16);
    void flag17Changed(qreal Flag17);
    void flag18Changed(qreal Flag18);
    void flag19Changed(qreal Flag19);
    void flag20Changed(qreal Flag20);
    void flag21Changed(qreal Flag21);
    void flag22Changed(qreal Flag22);
    void flag23Changed(qreal Flag23);
    void flag24Changed(qreal Flag24);
    void flag25Changed(qreal Flag25);

    // * Signals - String Flags
    void flagString1Changed(const QString &FlagString1);
    void flagString2Changed(const QString &FlagString2);
    void flagString3Changed(const QString &FlagString3);
    void flagString4Changed(const QString &FlagString4);
    void flagString5Changed(const QString &FlagString5);
    void flagString6Changed(const QString &FlagString6);
    void flagString7Changed(const QString &FlagString7);
    void flagString8Changed(const QString &FlagString8);
    void flagString9Changed(const QString &FlagString9);
    void flagString10Changed(const QString &FlagString10);
    void flagString11Changed(const QString &FlagString11);
    void flagString12Changed(const QString &FlagString12);
    void flagString13Changed(const QString &FlagString13);
    void flagString14Changed(const QString &FlagString14);
    void flagString15Changed(const QString &FlagString15);
    void flagString16Changed(const QString &FlagString16);

    // * Signals - Sensor Strings
    void sensorString1Changed(const QString &SensorString1);
    void sensorString2Changed(const QString &SensorString2);
    void sensorString3Changed(const QString &SensorString3);
    void sensorString4Changed(const QString &SensorString4);
    void sensorString5Changed(const QString &SensorString5);
    void sensorString6Changed(const QString &SensorString6);
    void sensorString7Changed(const QString &SensorString7);
    void sensorString8Changed(const QString &SensorString8);

private:
    // * Numeric Flags
    qreal m_Flag1 = 0;
    qreal m_Flag2 = 0;
    qreal m_Flag3 = 0;
    qreal m_Flag4 = 0;
    qreal m_Flag5 = 0;
    qreal m_Flag6 = 0;
    qreal m_Flag7 = 0;
    qreal m_Flag8 = 0;
    qreal m_Flag9 = 0;
    qreal m_Flag10 = 0;
    qreal m_Flag11 = 0;
    qreal m_Flag12 = 0;
    qreal m_Flag13 = 0;
    qreal m_Flag14 = 0;
    qreal m_Flag15 = 0;
    qreal m_Flag16 = 0;
    qreal m_Flag17 = 0;
    qreal m_Flag18 = 0;
    qreal m_Flag19 = 0;
    qreal m_Flag20 = 0;
    qreal m_Flag21 = 0;
    qreal m_Flag22 = 0;
    qreal m_Flag23 = 0;
    qreal m_Flag24 = 0;
    qreal m_Flag25 = 0;

    // * String Flags
    QString m_FlagString1;
    QString m_FlagString2;
    QString m_FlagString3;
    QString m_FlagString4;
    QString m_FlagString5;
    QString m_FlagString6;
    QString m_FlagString7;
    QString m_FlagString8;
    QString m_FlagString9;
    QString m_FlagString10;
    QString m_FlagString11;
    QString m_FlagString12;
    QString m_FlagString13;
    QString m_FlagString14;
    QString m_FlagString15;
    QString m_FlagString16;

    // * Sensor Strings
    QString m_SensorString1;
    QString m_SensorString2;
    QString m_SensorString3;
    QString m_SensorString4;
    QString m_SensorString5;
    QString m_SensorString6;
    QString m_SensorString7;
    QString m_SensorString8;
};

#endif  // FLAGSDATA_H
