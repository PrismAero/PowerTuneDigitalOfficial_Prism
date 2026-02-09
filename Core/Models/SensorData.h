/**
 * @file SensorData.h
 * @brief Generic sensor voltage data model for PowerTune
 *
 * This class encapsulates generic sensor-related data including:
 * - Raw sensor voltages (sens1-sens8)
 * - Sensor labels (SensorString1-8)
 * - Differential aux calculations (auxcalc1-4)
 *
 * Part of the DashBoard God Object refactoring (Phase 3)
 */

#ifndef SENSORDATA_H
#define SENSORDATA_H

#include <QObject>
#include <QString>

class SensorData : public QObject
{
    Q_OBJECT

    // * Raw sensor voltages
    Q_PROPERTY(qreal sens1 READ sens1 WRITE setsens1 NOTIFY sens1Changed)
    Q_PROPERTY(qreal sens2 READ sens2 WRITE setsens2 NOTIFY sens2Changed)
    Q_PROPERTY(qreal sens3 READ sens3 WRITE setsens3 NOTIFY sens3Changed)
    Q_PROPERTY(qreal sens4 READ sens4 WRITE setsens4 NOTIFY sens4Changed)
    Q_PROPERTY(qreal sens5 READ sens5 WRITE setsens5 NOTIFY sens5Changed)
    Q_PROPERTY(qreal sens6 READ sens6 WRITE setsens6 NOTIFY sens6Changed)
    Q_PROPERTY(qreal sens7 READ sens7 WRITE setsens7 NOTIFY sens7Changed)
    Q_PROPERTY(qreal sens8 READ sens8 WRITE setsens8 NOTIFY sens8Changed)

    // * Sensor labels
    Q_PROPERTY(QString SensorString1 READ SensorString1 WRITE setSensorString1 NOTIFY sensorString1Changed)
    Q_PROPERTY(QString SensorString2 READ SensorString2 WRITE setSensorString2 NOTIFY sensorString2Changed)
    Q_PROPERTY(QString SensorString3 READ SensorString3 WRITE setSensorString3 NOTIFY sensorString3Changed)
    Q_PROPERTY(QString SensorString4 READ SensorString4 WRITE setSensorString4 NOTIFY sensorString4Changed)
    Q_PROPERTY(QString SensorString5 READ SensorString5 WRITE setSensorString5 NOTIFY sensorString5Changed)
    Q_PROPERTY(QString SensorString6 READ SensorString6 WRITE setSensorString6 NOTIFY sensorString6Changed)
    Q_PROPERTY(QString SensorString7 READ SensorString7 WRITE setSensorString7 NOTIFY sensorString7Changed)
    Q_PROPERTY(QString SensorString8 READ SensorString8 WRITE setSensorString8 NOTIFY sensorString8Changed)

    // * Differential aux calculations
    Q_PROPERTY(qreal auxcalc1 READ auxcalc1 WRITE setauxcalc1 NOTIFY auxcalc1Changed)
    Q_PROPERTY(qreal auxcalc2 READ auxcalc2 WRITE setauxcalc2 NOTIFY auxcalc2Changed)
    Q_PROPERTY(qreal auxcalc3 READ auxcalc3 WRITE setauxcalc3 NOTIFY auxcalc3Changed)
    Q_PROPERTY(qreal auxcalc4 READ auxcalc4 WRITE setauxcalc4 NOTIFY auxcalc4Changed)

public:
    explicit SensorData(QObject *parent = nullptr);

    // * Getters - Raw sensor voltages
    qreal sens1() const { return m_sens1; }
    qreal sens2() const { return m_sens2; }
    qreal sens3() const { return m_sens3; }
    qreal sens4() const { return m_sens4; }
    qreal sens5() const { return m_sens5; }
    qreal sens6() const { return m_sens6; }
    qreal sens7() const { return m_sens7; }
    qreal sens8() const { return m_sens8; }

    // * Getters - Sensor labels
    QString SensorString1() const { return m_SensorString1; }
    QString SensorString2() const { return m_SensorString2; }
    QString SensorString3() const { return m_SensorString3; }
    QString SensorString4() const { return m_SensorString4; }
    QString SensorString5() const { return m_SensorString5; }
    QString SensorString6() const { return m_SensorString6; }
    QString SensorString7() const { return m_SensorString7; }
    QString SensorString8() const { return m_SensorString8; }

    // * Getters - Aux calculations
    qreal auxcalc1() const { return m_auxcalc1; }
    qreal auxcalc2() const { return m_auxcalc2; }
    qreal auxcalc3() const { return m_auxcalc3; }
    qreal auxcalc4() const { return m_auxcalc4; }

public slots:
    // * Setters - Raw sensor voltages
    void setsens1(qreal sens1);
    void setsens2(qreal sens2);
    void setsens3(qreal sens3);
    void setsens4(qreal sens4);
    void setsens5(qreal sens5);
    void setsens6(qreal sens6);
    void setsens7(qreal sens7);
    void setsens8(qreal sens8);

    // * Setters - Sensor labels
    void setSensorString1(const QString &SensorString1);
    void setSensorString2(const QString &SensorString2);
    void setSensorString3(const QString &SensorString3);
    void setSensorString4(const QString &SensorString4);
    void setSensorString5(const QString &SensorString5);
    void setSensorString6(const QString &SensorString6);
    void setSensorString7(const QString &SensorString7);
    void setSensorString8(const QString &SensorString8);

    // * Setters - Aux calculations
    void setauxcalc1(qreal auxcalc1);
    void setauxcalc2(qreal auxcalc2);
    void setauxcalc3(qreal auxcalc3);
    void setauxcalc4(qreal auxcalc4);

signals:
    // * Signals - Raw sensor voltages
    void sens1Changed(qreal sens1);
    void sens2Changed(qreal sens2);
    void sens3Changed(qreal sens3);
    void sens4Changed(qreal sens4);
    void sens5Changed(qreal sens5);
    void sens6Changed(qreal sens6);
    void sens7Changed(qreal sens7);
    void sens8Changed(qreal sens8);

    // * Signals - Sensor labels
    void sensorString1Changed(const QString &SensorString1);
    void sensorString2Changed(const QString &SensorString2);
    void sensorString3Changed(const QString &SensorString3);
    void sensorString4Changed(const QString &SensorString4);
    void sensorString5Changed(const QString &SensorString5);
    void sensorString6Changed(const QString &SensorString6);
    void sensorString7Changed(const QString &SensorString7);
    void sensorString8Changed(const QString &SensorString8);

    // * Signals - Aux calculations
    void auxcalc1Changed(qreal auxcalc1);
    void auxcalc2Changed(qreal auxcalc2);
    void auxcalc3Changed(qreal auxcalc3);
    void auxcalc4Changed(qreal auxcalc4);

private:
    // * Raw sensor voltages
    qreal m_sens1 = 0;
    qreal m_sens2 = 0;
    qreal m_sens3 = 0;
    qreal m_sens4 = 0;
    qreal m_sens5 = 0;
    qreal m_sens6 = 0;
    qreal m_sens7 = 0;
    qreal m_sens8 = 0;

    // * Sensor labels
    QString m_SensorString1;
    QString m_SensorString2;
    QString m_SensorString3;
    QString m_SensorString4;
    QString m_SensorString5;
    QString m_SensorString6;
    QString m_SensorString7;
    QString m_SensorString8;

    // * Aux calculations
    qreal m_auxcalc1 = 0;
    qreal m_auxcalc2 = 0;
    qreal m_auxcalc3 = 0;
    qreal m_auxcalc4 = 0;
};

#endif  // SENSORDATA_H
