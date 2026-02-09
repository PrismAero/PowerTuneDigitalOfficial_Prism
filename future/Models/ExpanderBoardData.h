/**
 * @file ExpanderBoardData.h
 * @brief External expansion board data model for PowerTune
 *
 * This class encapsulates expansion board sensor data including:
 * - EXAnalogInput0-7 (raw values)
 * - EXAnalogCalc0-7 (calculated values)
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#ifndef EXPANDERBOARDDATA_H
#define EXPANDERBOARDDATA_H

#include <QObject>

class ExpanderBoardData : public QObject
{
    Q_OBJECT

    // * Expansion Board Analog Inputs (Raw)
    Q_PROPERTY(qreal EXAnalogInput0 READ EXAnalogInput0 WRITE setEXAnalogInput0 NOTIFY EXAnalogInput0Changed)
    Q_PROPERTY(qreal EXAnalogInput1 READ EXAnalogInput1 WRITE setEXAnalogInput1 NOTIFY EXAnalogInput1Changed)
    Q_PROPERTY(qreal EXAnalogInput2 READ EXAnalogInput2 WRITE setEXAnalogInput2 NOTIFY EXAnalogInput2Changed)
    Q_PROPERTY(qreal EXAnalogInput3 READ EXAnalogInput3 WRITE setEXAnalogInput3 NOTIFY EXAnalogInput3Changed)
    Q_PROPERTY(qreal EXAnalogInput4 READ EXAnalogInput4 WRITE setEXAnalogInput4 NOTIFY EXAnalogInput4Changed)
    Q_PROPERTY(qreal EXAnalogInput5 READ EXAnalogInput5 WRITE setEXAnalogInput5 NOTIFY EXAnalogInput5Changed)
    Q_PROPERTY(qreal EXAnalogInput6 READ EXAnalogInput6 WRITE setEXAnalogInput6 NOTIFY EXAnalogInput6Changed)
    Q_PROPERTY(qreal EXAnalogInput7 READ EXAnalogInput7 WRITE setEXAnalogInput7 NOTIFY EXAnalogInput7Changed)

    // * Expansion Board Analog Inputs (Calculated)
    Q_PROPERTY(qreal EXAnalogCalc0 READ EXAnalogCalc0 WRITE setEXAnalogCalc0 NOTIFY EXAnalogCalc0Changed)
    Q_PROPERTY(qreal EXAnalogCalc1 READ EXAnalogCalc1 WRITE setEXAnalogCalc1 NOTIFY EXAnalogCalc1Changed)
    Q_PROPERTY(qreal EXAnalogCalc2 READ EXAnalogCalc2 WRITE setEXAnalogCalc2 NOTIFY EXAnalogCalc2Changed)
    Q_PROPERTY(qreal EXAnalogCalc3 READ EXAnalogCalc3 WRITE setEXAnalogCalc3 NOTIFY EXAnalogCalc3Changed)
    Q_PROPERTY(qreal EXAnalogCalc4 READ EXAnalogCalc4 WRITE setEXAnalogCalc4 NOTIFY EXAnalogCalc4Changed)
    Q_PROPERTY(qreal EXAnalogCalc5 READ EXAnalogCalc5 WRITE setEXAnalogCalc5 NOTIFY EXAnalogCalc5Changed)
    Q_PROPERTY(qreal EXAnalogCalc6 READ EXAnalogCalc6 WRITE setEXAnalogCalc6 NOTIFY EXAnalogCalc6Changed)
    Q_PROPERTY(qreal EXAnalogCalc7 READ EXAnalogCalc7 WRITE setEXAnalogCalc7 NOTIFY EXAnalogCalc7Changed)

public:
    explicit ExpanderBoardData(QObject *parent = nullptr);

    // * Getters - Raw
    qreal EXAnalogInput0() const { return m_EXAnalogInput0; }
    qreal EXAnalogInput1() const { return m_EXAnalogInput1; }
    qreal EXAnalogInput2() const { return m_EXAnalogInput2; }
    qreal EXAnalogInput3() const { return m_EXAnalogInput3; }
    qreal EXAnalogInput4() const { return m_EXAnalogInput4; }
    qreal EXAnalogInput5() const { return m_EXAnalogInput5; }
    qreal EXAnalogInput6() const { return m_EXAnalogInput6; }
    qreal EXAnalogInput7() const { return m_EXAnalogInput7; }

    // * Getters - Calculated
    qreal EXAnalogCalc0() const { return m_EXAnalogCalc0; }
    qreal EXAnalogCalc1() const { return m_EXAnalogCalc1; }
    qreal EXAnalogCalc2() const { return m_EXAnalogCalc2; }
    qreal EXAnalogCalc3() const { return m_EXAnalogCalc3; }
    qreal EXAnalogCalc4() const { return m_EXAnalogCalc4; }
    qreal EXAnalogCalc5() const { return m_EXAnalogCalc5; }
    qreal EXAnalogCalc6() const { return m_EXAnalogCalc6; }
    qreal EXAnalogCalc7() const { return m_EXAnalogCalc7; }

public slots:
    // * Setters - Raw
    void setEXAnalogInput0(qreal EXAnalogInput0);
    void setEXAnalogInput1(qreal EXAnalogInput1);
    void setEXAnalogInput2(qreal EXAnalogInput2);
    void setEXAnalogInput3(qreal EXAnalogInput3);
    void setEXAnalogInput4(qreal EXAnalogInput4);
    void setEXAnalogInput5(qreal EXAnalogInput5);
    void setEXAnalogInput6(qreal EXAnalogInput6);
    void setEXAnalogInput7(qreal EXAnalogInput7);

    // * Setters - Calculated
    void setEXAnalogCalc0(qreal EXAnalogCalc0);
    void setEXAnalogCalc1(qreal EXAnalogCalc1);
    void setEXAnalogCalc2(qreal EXAnalogCalc2);
    void setEXAnalogCalc3(qreal EXAnalogCalc3);
    void setEXAnalogCalc4(qreal EXAnalogCalc4);
    void setEXAnalogCalc5(qreal EXAnalogCalc5);
    void setEXAnalogCalc6(qreal EXAnalogCalc6);
    void setEXAnalogCalc7(qreal EXAnalogCalc7);

signals:
    // * Signals - Raw
    void EXAnalogInput0Changed(qreal EXAnalogInput0);
    void EXAnalogInput1Changed(qreal EXAnalogInput1);
    void EXAnalogInput2Changed(qreal EXAnalogInput2);
    void EXAnalogInput3Changed(qreal EXAnalogInput3);
    void EXAnalogInput4Changed(qreal EXAnalogInput4);
    void EXAnalogInput5Changed(qreal EXAnalogInput5);
    void EXAnalogInput6Changed(qreal EXAnalogInput6);
    void EXAnalogInput7Changed(qreal EXAnalogInput7);

    // * Signals - Calculated
    void EXAnalogCalc0Changed(qreal EXAnalogCalc0);
    void EXAnalogCalc1Changed(qreal EXAnalogCalc1);
    void EXAnalogCalc2Changed(qreal EXAnalogCalc2);
    void EXAnalogCalc3Changed(qreal EXAnalogCalc3);
    void EXAnalogCalc4Changed(qreal EXAnalogCalc4);
    void EXAnalogCalc5Changed(qreal EXAnalogCalc5);
    void EXAnalogCalc6Changed(qreal EXAnalogCalc6);
    void EXAnalogCalc7Changed(qreal EXAnalogCalc7);

private:
    // * Raw
    qreal m_EXAnalogInput0 = 0;
    qreal m_EXAnalogInput1 = 0;
    qreal m_EXAnalogInput2 = 0;
    qreal m_EXAnalogInput3 = 0;
    qreal m_EXAnalogInput4 = 0;
    qreal m_EXAnalogInput5 = 0;
    qreal m_EXAnalogInput6 = 0;
    qreal m_EXAnalogInput7 = 0;

    // * Calculated
    qreal m_EXAnalogCalc0 = 0;
    qreal m_EXAnalogCalc1 = 0;
    qreal m_EXAnalogCalc2 = 0;
    qreal m_EXAnalogCalc3 = 0;
    qreal m_EXAnalogCalc4 = 0;
    qreal m_EXAnalogCalc5 = 0;
    qreal m_EXAnalogCalc6 = 0;
    qreal m_EXAnalogCalc7 = 0;
};

#endif  // EXPANDERBOARDDATA_H
