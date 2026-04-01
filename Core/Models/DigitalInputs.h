/**
 * @file DigitalInputs.h
 * @brief Digital input data model for PowerTune
 *
 * This class encapsulates digital I/O state data including:
 * - EXDigitalInput1-8 (expansion board)
 * - Frequency/RPM divider inputs
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#ifndef DIGITALINPUTS_H
#define DIGITALINPUTS_H

#include <QObject>

class DigitalInputs : public QObject
{
    Q_OBJECT

    Q_PROPERTY(qreal EXDigitalInput1 READ EXDigitalInput1 WRITE setEXDigitalInput1 NOTIFY EXDigitalInput1Changed)
    Q_PROPERTY(qreal EXDigitalInput2 READ EXDigitalInput2 WRITE setEXDigitalInput2 NOTIFY EXDigitalInput2Changed)
    Q_PROPERTY(qreal EXDigitalInput3 READ EXDigitalInput3 WRITE setEXDigitalInput3 NOTIFY EXDigitalInput3Changed)
    Q_PROPERTY(qreal EXDigitalInput4 READ EXDigitalInput4 WRITE setEXDigitalInput4 NOTIFY EXDigitalInput4Changed)
    Q_PROPERTY(qreal EXDigitalInput5 READ EXDigitalInput5 WRITE setEXDigitalInput5 NOTIFY EXDigitalInput5Changed)
    Q_PROPERTY(qreal EXDigitalInput6 READ EXDigitalInput6 WRITE setEXDigitalInput6 NOTIFY EXDigitalInput6Changed)
    Q_PROPERTY(qreal EXDigitalInput7 READ EXDigitalInput7 WRITE setEXDigitalInput7 NOTIFY EXDigitalInput7Changed)
    Q_PROPERTY(qreal EXDigitalInput8 READ EXDigitalInput8 WRITE setEXDigitalInput8 NOTIFY EXDigitalInput8Changed)

    Q_PROPERTY(qreal RPMFrequencyDividerDi1 READ RPMFrequencyDividerDi1 WRITE setRPMFrequencyDividerDi1 NOTIFY
                   RPMFrequencyDividerDi1Changed)
    Q_PROPERTY(qreal frequencyDIEX1 READ frequencyDIEX1 WRITE setfrequencyDIEX1 NOTIFY frequencyDIEX1Changed)
    Q_PROPERTY(int DI1RPMEnabled READ DI1RPMEnabled WRITE setDI1RPMEnabled NOTIFY DI1RPMEnabledChanged)

public:
    explicit DigitalInputs(QObject *parent = nullptr);

    qreal EXDigitalInput1() const { return m_EXDigitalInput1; }
    qreal EXDigitalInput2() const { return m_EXDigitalInput2; }
    qreal EXDigitalInput3() const { return m_EXDigitalInput3; }
    qreal EXDigitalInput4() const { return m_EXDigitalInput4; }
    qreal EXDigitalInput5() const { return m_EXDigitalInput5; }
    qreal EXDigitalInput6() const { return m_EXDigitalInput6; }
    qreal EXDigitalInput7() const { return m_EXDigitalInput7; }
    qreal EXDigitalInput8() const { return m_EXDigitalInput8; }

    qreal RPMFrequencyDividerDi1() const { return m_RPMFrequencyDividerDi1; }
    qreal frequencyDIEX1() const { return m_frequencyDIEX1; }
    int DI1RPMEnabled() const { return m_DI1RPMEnabled; }

public slots:
    void setEXDigitalInput1(qreal EXDigitalInput1);
    void setEXDigitalInput2(qreal EXDigitalInput2);
    void setEXDigitalInput3(qreal EXDigitalInput3);
    void setEXDigitalInput4(qreal EXDigitalInput4);
    void setEXDigitalInput5(qreal EXDigitalInput5);
    void setEXDigitalInput6(qreal EXDigitalInput6);
    void setEXDigitalInput7(qreal EXDigitalInput7);
    void setEXDigitalInput8(qreal EXDigitalInput8);

    void setRPMFrequencyDividerDi1(qreal RPMFrequencyDividerDi1);
    void setfrequencyDIEX1(qreal frequencyDIEX1);
    void setDI1RPMEnabled(int DI1RPMEnabled);

signals:
    void EXDigitalInput1Changed(qreal EXDigitalInput1);
    void EXDigitalInput2Changed(qreal EXDigitalInput2);
    void EXDigitalInput3Changed(qreal EXDigitalInput3);
    void EXDigitalInput4Changed(qreal EXDigitalInput4);
    void EXDigitalInput5Changed(qreal EXDigitalInput5);
    void EXDigitalInput6Changed(qreal EXDigitalInput6);
    void EXDigitalInput7Changed(qreal EXDigitalInput7);
    void EXDigitalInput8Changed(qreal EXDigitalInput8);

    void RPMFrequencyDividerDi1Changed(qreal RPMFrequencyDividerDi1);
    void frequencyDIEX1Changed(qreal frequencyDIEX1);
    void DI1RPMEnabledChanged(int DI1RPMEnabled);

private:
    qreal m_EXDigitalInput1 = 0;
    qreal m_EXDigitalInput2 = 0;
    qreal m_EXDigitalInput3 = 0;
    qreal m_EXDigitalInput4 = 0;
    qreal m_EXDigitalInput5 = 0;
    qreal m_EXDigitalInput6 = 0;
    qreal m_EXDigitalInput7 = 0;
    qreal m_EXDigitalInput8 = 0;

    qreal m_RPMFrequencyDividerDi1 = 0;
    qreal m_frequencyDIEX1 = 0;
    int m_DI1RPMEnabled = 0;
};

#endif  // DIGITALINPUTS_H
