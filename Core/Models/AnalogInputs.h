/**
 * @file AnalogInputs.h
 * @brief Analog input sensor data model for PowerTune
 * 
 * This class encapsulates analog sensor input data including:
 * - Analog0-10 (raw values)
 * - AnalogCalc0-10 (calculated values)
 * - Sens1-8 (legacy sensor inputs)
 * - AuxCalc1-4 (differential aux calculations)
 * - User channels
 * 
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#ifndef ANALOGINPUTS_H
#define ANALOGINPUTS_H

#include <QObject>

class AnalogInputs : public QObject
{
    Q_OBJECT

    // * Raw Analog Inputs
    Q_PROPERTY(qreal Analog0 READ Analog0 WRITE setAnalog0 NOTIFY Analog0Changed)
    Q_PROPERTY(qreal Analog1 READ Analog1 WRITE setAnalog1 NOTIFY Analog1Changed)
    Q_PROPERTY(qreal Analog2 READ Analog2 WRITE setAnalog2 NOTIFY Analog2Changed)
    Q_PROPERTY(qreal Analog3 READ Analog3 WRITE setAnalog3 NOTIFY Analog3Changed)
    Q_PROPERTY(qreal Analog4 READ Analog4 WRITE setAnalog4 NOTIFY Analog4Changed)
    Q_PROPERTY(qreal Analog5 READ Analog5 WRITE setAnalog5 NOTIFY Analog5Changed)
    Q_PROPERTY(qreal Analog6 READ Analog6 WRITE setAnalog6 NOTIFY Analog6Changed)
    Q_PROPERTY(qreal Analog7 READ Analog7 WRITE setAnalog7 NOTIFY Analog7Changed)
    Q_PROPERTY(qreal Analog8 READ Analog8 WRITE setAnalog8 NOTIFY Analog8Changed)
    Q_PROPERTY(qreal Analog9 READ Analog9 WRITE setAnalog9 NOTIFY Analog9Changed)
    Q_PROPERTY(qreal Analog10 READ Analog10 WRITE setAnalog10 NOTIFY Analog10Changed)

    // * Calculated Analog Values
    Q_PROPERTY(qreal AnalogCalc0 READ AnalogCalc0 WRITE setAnalogCalc0 NOTIFY AnalogCalc0Changed)
    Q_PROPERTY(qreal AnalogCalc1 READ AnalogCalc1 WRITE setAnalogCalc1 NOTIFY AnalogCalc1Changed)
    Q_PROPERTY(qreal AnalogCalc2 READ AnalogCalc2 WRITE setAnalogCalc2 NOTIFY AnalogCalc2Changed)
    Q_PROPERTY(qreal AnalogCalc3 READ AnalogCalc3 WRITE setAnalogCalc3 NOTIFY AnalogCalc3Changed)
    Q_PROPERTY(qreal AnalogCalc4 READ AnalogCalc4 WRITE setAnalogCalc4 NOTIFY AnalogCalc4Changed)
    Q_PROPERTY(qreal AnalogCalc5 READ AnalogCalc5 WRITE setAnalogCalc5 NOTIFY AnalogCalc5Changed)
    Q_PROPERTY(qreal AnalogCalc6 READ AnalogCalc6 WRITE setAnalogCalc6 NOTIFY AnalogCalc6Changed)
    Q_PROPERTY(qreal AnalogCalc7 READ AnalogCalc7 WRITE setAnalogCalc7 NOTIFY AnalogCalc7Changed)
    Q_PROPERTY(qreal AnalogCalc8 READ AnalogCalc8 WRITE setAnalogCalc8 NOTIFY AnalogCalc8Changed)
    Q_PROPERTY(qreal AnalogCalc9 READ AnalogCalc9 WRITE setAnalogCalc9 NOTIFY AnalogCalc9Changed)
    Q_PROPERTY(qreal AnalogCalc10 READ AnalogCalc10 WRITE setAnalogCalc10 NOTIFY AnalogCalc10Changed)

    // * Legacy Sensor Inputs
    Q_PROPERTY(qreal sens1 READ sens1 WRITE setsens1 NOTIFY sens1Changed)
    Q_PROPERTY(qreal sens2 READ sens2 WRITE setsens2 NOTIFY sens2Changed)
    Q_PROPERTY(qreal sens3 READ sens3 WRITE setsens3 NOTIFY sens3Changed)
    Q_PROPERTY(qreal sens4 READ sens4 WRITE setsens4 NOTIFY sens4Changed)
    Q_PROPERTY(qreal sens5 READ sens5 WRITE setsens5 NOTIFY sens5Changed)
    Q_PROPERTY(qreal sens6 READ sens6 WRITE setsens6 NOTIFY sens6Changed)
    Q_PROPERTY(qreal sens7 READ sens7 WRITE setsens7 NOTIFY sens7Changed)
    Q_PROPERTY(qreal sens8 READ sens8 WRITE setsens8 NOTIFY sens8Changed)

    // * Differential Aux Calculations
    Q_PROPERTY(qreal auxcalc1 READ auxcalc1 WRITE setauxcalc1 NOTIFY auxcalc1Changed)
    Q_PROPERTY(qreal auxcalc2 READ auxcalc2 WRITE setauxcalc2 NOTIFY auxcalc2Changed)
    Q_PROPERTY(qreal auxcalc3 READ auxcalc3 WRITE setauxcalc3 NOTIFY auxcalc3Changed)
    Q_PROPERTY(qreal auxcalc4 READ auxcalc4 WRITE setauxcalc4 NOTIFY auxcalc4Changed)

    // * User Channels
    Q_PROPERTY(qreal Userchannel1 READ Userchannel1 WRITE setUserchannel1 NOTIFY Userchannel1Changed)
    Q_PROPERTY(qreal Userchannel2 READ Userchannel2 WRITE setUserchannel2 NOTIFY Userchannel2Changed)
    Q_PROPERTY(qreal Userchannel3 READ Userchannel3 WRITE setUserchannel3 NOTIFY Userchannel3Changed)
    Q_PROPERTY(qreal Userchannel4 READ Userchannel4 WRITE setUserchannel4 NOTIFY Userchannel4Changed)
    Q_PROPERTY(qreal Userchannel5 READ Userchannel5 WRITE setUserchannel5 NOTIFY Userchannel5Changed)
    Q_PROPERTY(qreal Userchannel6 READ Userchannel6 WRITE setUserchannel6 NOTIFY Userchannel6Changed)
    Q_PROPERTY(qreal Userchannel7 READ Userchannel7 WRITE setUserchannel7 NOTIFY Userchannel7Changed)
    Q_PROPERTY(qreal Userchannel8 READ Userchannel8 WRITE setUserchannel8 NOTIFY Userchannel8Changed)
    Q_PROPERTY(qreal Userchannel9 READ Userchannel9 WRITE setUserchannel9 NOTIFY Userchannel9Changed)
    Q_PROPERTY(qreal Userchannel10 READ Userchannel10 WRITE setUserchannel10 NOTIFY Userchannel10Changed)
    Q_PROPERTY(qreal Userchannel11 READ Userchannel11 WRITE setUserchannel11 NOTIFY Userchannel11Changed)
    Q_PROPERTY(qreal Userchannel12 READ Userchannel12 WRITE setUserchannel12 NOTIFY Userchannel12Changed)

public:
    explicit AnalogInputs(QObject *parent = nullptr);

    // * Getters - Raw Analog
    qreal Analog0() const { return m_Analog0; }
    qreal Analog1() const { return m_Analog1; }
    qreal Analog2() const { return m_Analog2; }
    qreal Analog3() const { return m_Analog3; }
    qreal Analog4() const { return m_Analog4; }
    qreal Analog5() const { return m_Analog5; }
    qreal Analog6() const { return m_Analog6; }
    qreal Analog7() const { return m_Analog7; }
    qreal Analog8() const { return m_Analog8; }
    qreal Analog9() const { return m_Analog9; }
    qreal Analog10() const { return m_Analog10; }

    // * Getters - Calculated Analog
    qreal AnalogCalc0() const { return m_AnalogCalc0; }
    qreal AnalogCalc1() const { return m_AnalogCalc1; }
    qreal AnalogCalc2() const { return m_AnalogCalc2; }
    qreal AnalogCalc3() const { return m_AnalogCalc3; }
    qreal AnalogCalc4() const { return m_AnalogCalc4; }
    qreal AnalogCalc5() const { return m_AnalogCalc5; }
    qreal AnalogCalc6() const { return m_AnalogCalc6; }
    qreal AnalogCalc7() const { return m_AnalogCalc7; }
    qreal AnalogCalc8() const { return m_AnalogCalc8; }
    qreal AnalogCalc9() const { return m_AnalogCalc9; }
    qreal AnalogCalc10() const { return m_AnalogCalc10; }

    // * Getters - Legacy Sensors
    qreal sens1() const { return m_sens1; }
    qreal sens2() const { return m_sens2; }
    qreal sens3() const { return m_sens3; }
    qreal sens4() const { return m_sens4; }
    qreal sens5() const { return m_sens5; }
    qreal sens6() const { return m_sens6; }
    qreal sens7() const { return m_sens7; }
    qreal sens8() const { return m_sens8; }

    // * Getters - Aux Calculations
    qreal auxcalc1() const { return m_auxcalc1; }
    qreal auxcalc2() const { return m_auxcalc2; }
    qreal auxcalc3() const { return m_auxcalc3; }
    qreal auxcalc4() const { return m_auxcalc4; }

    // * Getters - User Channels
    qreal Userchannel1() const { return m_Userchannel1; }
    qreal Userchannel2() const { return m_Userchannel2; }
    qreal Userchannel3() const { return m_Userchannel3; }
    qreal Userchannel4() const { return m_Userchannel4; }
    qreal Userchannel5() const { return m_Userchannel5; }
    qreal Userchannel6() const { return m_Userchannel6; }
    qreal Userchannel7() const { return m_Userchannel7; }
    qreal Userchannel8() const { return m_Userchannel8; }
    qreal Userchannel9() const { return m_Userchannel9; }
    qreal Userchannel10() const { return m_Userchannel10; }
    qreal Userchannel11() const { return m_Userchannel11; }
    qreal Userchannel12() const { return m_Userchannel12; }

public slots:
    // * Setters - Raw Analog
    void setAnalog0(qreal Analog0);
    void setAnalog1(qreal Analog1);
    void setAnalog2(qreal Analog2);
    void setAnalog3(qreal Analog3);
    void setAnalog4(qreal Analog4);
    void setAnalog5(qreal Analog5);
    void setAnalog6(qreal Analog6);
    void setAnalog7(qreal Analog7);
    void setAnalog8(qreal Analog8);
    void setAnalog9(qreal Analog9);
    void setAnalog10(qreal Analog10);

    // * Setters - Calculated Analog
    void setAnalogCalc0(qreal AnalogCalc0);
    void setAnalogCalc1(qreal AnalogCalc1);
    void setAnalogCalc2(qreal AnalogCalc2);
    void setAnalogCalc3(qreal AnalogCalc3);
    void setAnalogCalc4(qreal AnalogCalc4);
    void setAnalogCalc5(qreal AnalogCalc5);
    void setAnalogCalc6(qreal AnalogCalc6);
    void setAnalogCalc7(qreal AnalogCalc7);
    void setAnalogCalc8(qreal AnalogCalc8);
    void setAnalogCalc9(qreal AnalogCalc9);
    void setAnalogCalc10(qreal AnalogCalc10);

    // * Setters - Legacy Sensors
    void setsens1(qreal sens1);
    void setsens2(qreal sens2);
    void setsens3(qreal sens3);
    void setsens4(qreal sens4);
    void setsens5(qreal sens5);
    void setsens6(qreal sens6);
    void setsens7(qreal sens7);
    void setsens8(qreal sens8);

    // * Setters - Aux Calculations
    void setauxcalc1(qreal auxcalc1);
    void setauxcalc2(qreal auxcalc2);
    void setauxcalc3(qreal auxcalc3);
    void setauxcalc4(qreal auxcalc4);

    // * Setters - User Channels
    void setUserchannel1(qreal Userchannel1);
    void setUserchannel2(qreal Userchannel2);
    void setUserchannel3(qreal Userchannel3);
    void setUserchannel4(qreal Userchannel4);
    void setUserchannel5(qreal Userchannel5);
    void setUserchannel6(qreal Userchannel6);
    void setUserchannel7(qreal Userchannel7);
    void setUserchannel8(qreal Userchannel8);
    void setUserchannel9(qreal Userchannel9);
    void setUserchannel10(qreal Userchannel10);
    void setUserchannel11(qreal Userchannel11);
    void setUserchannel12(qreal Userchannel12);

signals:
    // * Signals - Raw Analog
    void Analog0Changed(qreal Analog0);
    void Analog1Changed(qreal Analog1);
    void Analog2Changed(qreal Analog2);
    void Analog3Changed(qreal Analog3);
    void Analog4Changed(qreal Analog4);
    void Analog5Changed(qreal Analog5);
    void Analog6Changed(qreal Analog6);
    void Analog7Changed(qreal Analog7);
    void Analog8Changed(qreal Analog8);
    void Analog9Changed(qreal Analog9);
    void Analog10Changed(qreal Analog10);

    // * Signals - Calculated Analog
    void AnalogCalc0Changed(qreal AnalogCalc0);
    void AnalogCalc1Changed(qreal AnalogCalc1);
    void AnalogCalc2Changed(qreal AnalogCalc2);
    void AnalogCalc3Changed(qreal AnalogCalc3);
    void AnalogCalc4Changed(qreal AnalogCalc4);
    void AnalogCalc5Changed(qreal AnalogCalc5);
    void AnalogCalc6Changed(qreal AnalogCalc6);
    void AnalogCalc7Changed(qreal AnalogCalc7);
    void AnalogCalc8Changed(qreal AnalogCalc8);
    void AnalogCalc9Changed(qreal AnalogCalc9);
    void AnalogCalc10Changed(qreal AnalogCalc10);

    // * Signals - Legacy Sensors
    void sens1Changed(qreal sens1);
    void sens2Changed(qreal sens2);
    void sens3Changed(qreal sens3);
    void sens4Changed(qreal sens4);
    void sens5Changed(qreal sens5);
    void sens6Changed(qreal sens6);
    void sens7Changed(qreal sens7);
    void sens8Changed(qreal sens8);

    // * Signals - Aux Calculations
    void auxcalc1Changed(qreal auxcalc1);
    void auxcalc2Changed(qreal auxcalc2);
    void auxcalc3Changed(qreal auxcalc3);
    void auxcalc4Changed(qreal auxcalc4);

    // * Signals - User Channels
    void Userchannel1Changed(qreal Userchannel1);
    void Userchannel2Changed(qreal Userchannel2);
    void Userchannel3Changed(qreal Userchannel3);
    void Userchannel4Changed(qreal Userchannel4);
    void Userchannel5Changed(qreal Userchannel5);
    void Userchannel6Changed(qreal Userchannel6);
    void Userchannel7Changed(qreal Userchannel7);
    void Userchannel8Changed(qreal Userchannel8);
    void Userchannel9Changed(qreal Userchannel9);
    void Userchannel10Changed(qreal Userchannel10);
    void Userchannel11Changed(qreal Userchannel11);
    void Userchannel12Changed(qreal Userchannel12);

private:
    // * Raw Analog
    qreal m_Analog0 = 0;
    qreal m_Analog1 = 0;
    qreal m_Analog2 = 0;
    qreal m_Analog3 = 0;
    qreal m_Analog4 = 0;
    qreal m_Analog5 = 0;
    qreal m_Analog6 = 0;
    qreal m_Analog7 = 0;
    qreal m_Analog8 = 0;
    qreal m_Analog9 = 0;
    qreal m_Analog10 = 0;

    // * Calculated Analog
    qreal m_AnalogCalc0 = 0;
    qreal m_AnalogCalc1 = 0;
    qreal m_AnalogCalc2 = 0;
    qreal m_AnalogCalc3 = 0;
    qreal m_AnalogCalc4 = 0;
    qreal m_AnalogCalc5 = 0;
    qreal m_AnalogCalc6 = 0;
    qreal m_AnalogCalc7 = 0;
    qreal m_AnalogCalc8 = 0;
    qreal m_AnalogCalc9 = 0;
    qreal m_AnalogCalc10 = 0;

    // * Legacy Sensors
    qreal m_sens1 = 0;
    qreal m_sens2 = 0;
    qreal m_sens3 = 0;
    qreal m_sens4 = 0;
    qreal m_sens5 = 0;
    qreal m_sens6 = 0;
    qreal m_sens7 = 0;
    qreal m_sens8 = 0;

    // * Aux Calculations
    qreal m_auxcalc1 = 0;
    qreal m_auxcalc2 = 0;
    qreal m_auxcalc3 = 0;
    qreal m_auxcalc4 = 0;

    // * User Channels
    qreal m_Userchannel1 = 0;
    qreal m_Userchannel2 = 0;
    qreal m_Userchannel3 = 0;
    qreal m_Userchannel4 = 0;
    qreal m_Userchannel5 = 0;
    qreal m_Userchannel6 = 0;
    qreal m_Userchannel7 = 0;
    qreal m_Userchannel8 = 0;
    qreal m_Userchannel9 = 0;
    qreal m_Userchannel10 = 0;
    qreal m_Userchannel11 = 0;
    qreal m_Userchannel12 = 0;
};

#endif // ANALOGINPUTS_H
