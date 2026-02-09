/**
 * @file DigitalInputs.h
 * @brief Digital input data model for PowerTune
 *
 * This class encapsulates digital I/O state data including:
 * - DigitalInput1-7 (main board)
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

    // * Main Board Digital Inputs
    Q_PROPERTY(qreal DigitalInput1 READ DigitalInput1 WRITE setDigitalInput1 NOTIFY DigitalInput1Changed)
    Q_PROPERTY(qreal DigitalInput2 READ DigitalInput2 WRITE setDigitalInput2 NOTIFY DigitalInput2Changed)
    Q_PROPERTY(qreal DigitalInput3 READ DigitalInput3 WRITE setDigitalInput3 NOTIFY DigitalInput3Changed)
    Q_PROPERTY(qreal DigitalInput4 READ DigitalInput4 WRITE setDigitalInput4 NOTIFY DigitalInput4Changed)
    Q_PROPERTY(qreal DigitalInput5 READ DigitalInput5 WRITE setDigitalInput5 NOTIFY DigitalInput5Changed)
    Q_PROPERTY(qreal DigitalInput6 READ DigitalInput6 WRITE setDigitalInput6 NOTIFY DigitalInput6Changed)
    Q_PROPERTY(qreal DigitalInput7 READ DigitalInput7 WRITE setDigitalInput7 NOTIFY DigitalInput7Changed)

    // * Expansion Board Digital Inputs
    Q_PROPERTY(qreal EXDigitalInput1 READ EXDigitalInput1 WRITE setEXDigitalInput1 NOTIFY EXDigitalInput1Changed)
    Q_PROPERTY(qreal EXDigitalInput2 READ EXDigitalInput2 WRITE setEXDigitalInput2 NOTIFY EXDigitalInput2Changed)
    Q_PROPERTY(qreal EXDigitalInput3 READ EXDigitalInput3 WRITE setEXDigitalInput3 NOTIFY EXDigitalInput3Changed)
    Q_PROPERTY(qreal EXDigitalInput4 READ EXDigitalInput4 WRITE setEXDigitalInput4 NOTIFY EXDigitalInput4Changed)
    Q_PROPERTY(qreal EXDigitalInput5 READ EXDigitalInput5 WRITE setEXDigitalInput5 NOTIFY EXDigitalInput5Changed)
    Q_PROPERTY(qreal EXDigitalInput6 READ EXDigitalInput6 WRITE setEXDigitalInput6 NOTIFY EXDigitalInput6Changed)
    Q_PROPERTY(qreal EXDigitalInput7 READ EXDigitalInput7 WRITE setEXDigitalInput7 NOTIFY EXDigitalInput7Changed)
    Q_PROPERTY(qreal EXDigitalInput8 READ EXDigitalInput8 WRITE setEXDigitalInput8 NOTIFY EXDigitalInput8Changed)

    // * Frequency/RPM Inputs
    Q_PROPERTY(qreal RPMFrequencyDividerDi1 READ RPMFrequencyDividerDi1 WRITE setRPMFrequencyDividerDi1 NOTIFY
                   RPMFrequencyDividerDi1Changed)
    Q_PROPERTY(qreal frequencyDIEX1 READ frequencyDIEX1 WRITE setfrequencyDIEX1 NOTIFY frequencyDIEX1Changed)
    Q_PROPERTY(int DI1RPMEnabled READ DI1RPMEnabled WRITE setDI1RPMEnabled NOTIFY DI1RPMEnabledChanged)

public:
    explicit DigitalInputs(QObject *parent = nullptr);

    // * Getters - Main Board
    qreal DigitalInput1() const { return m_DigitalInput1; }
    qreal DigitalInput2() const { return m_DigitalInput2; }
    qreal DigitalInput3() const { return m_DigitalInput3; }
    qreal DigitalInput4() const { return m_DigitalInput4; }
    qreal DigitalInput5() const { return m_DigitalInput5; }
    qreal DigitalInput6() const { return m_DigitalInput6; }
    qreal DigitalInput7() const { return m_DigitalInput7; }

    // * Getters - Expansion Board
    qreal EXDigitalInput1() const { return m_EXDigitalInput1; }
    qreal EXDigitalInput2() const { return m_EXDigitalInput2; }
    qreal EXDigitalInput3() const { return m_EXDigitalInput3; }
    qreal EXDigitalInput4() const { return m_EXDigitalInput4; }
    qreal EXDigitalInput5() const { return m_EXDigitalInput5; }
    qreal EXDigitalInput6() const { return m_EXDigitalInput6; }
    qreal EXDigitalInput7() const { return m_EXDigitalInput7; }
    qreal EXDigitalInput8() const { return m_EXDigitalInput8; }

    // * Getters - Frequency/RPM
    qreal RPMFrequencyDividerDi1() const { return m_RPMFrequencyDividerDi1; }
    qreal frequencyDIEX1() const { return m_frequencyDIEX1; }
    int DI1RPMEnabled() const { return m_DI1RPMEnabled; }

public slots:
    // * Setters - Main Board
    void setDigitalInput1(qreal DigitalInput1);
    void setDigitalInput2(qreal DigitalInput2);
    void setDigitalInput3(qreal DigitalInput3);
    void setDigitalInput4(qreal DigitalInput4);
    void setDigitalInput5(qreal DigitalInput5);
    void setDigitalInput6(qreal DigitalInput6);
    void setDigitalInput7(qreal DigitalInput7);

    // * Setters - Expansion Board
    void setEXDigitalInput1(qreal EXDigitalInput1);
    void setEXDigitalInput2(qreal EXDigitalInput2);
    void setEXDigitalInput3(qreal EXDigitalInput3);
    void setEXDigitalInput4(qreal EXDigitalInput4);
    void setEXDigitalInput5(qreal EXDigitalInput5);
    void setEXDigitalInput6(qreal EXDigitalInput6);
    void setEXDigitalInput7(qreal EXDigitalInput7);
    void setEXDigitalInput8(qreal EXDigitalInput8);

    // * Setters - Frequency/RPM
    void setRPMFrequencyDividerDi1(qreal RPMFrequencyDividerDi1);
    void setfrequencyDIEX1(qreal frequencyDIEX1);
    void setDI1RPMEnabled(int DI1RPMEnabled);

signals:
    // * Signals - Main Board
    void DigitalInput1Changed(qreal DigitalInput1);
    void DigitalInput2Changed(qreal DigitalInput2);
    void DigitalInput3Changed(qreal DigitalInput3);
    void DigitalInput4Changed(qreal DigitalInput4);
    void DigitalInput5Changed(qreal DigitalInput5);
    void DigitalInput6Changed(qreal DigitalInput6);
    void DigitalInput7Changed(qreal DigitalInput7);

    // * Signals - Expansion Board
    void EXDigitalInput1Changed(qreal EXDigitalInput1);
    void EXDigitalInput2Changed(qreal EXDigitalInput2);
    void EXDigitalInput3Changed(qreal EXDigitalInput3);
    void EXDigitalInput4Changed(qreal EXDigitalInput4);
    void EXDigitalInput5Changed(qreal EXDigitalInput5);
    void EXDigitalInput6Changed(qreal EXDigitalInput6);
    void EXDigitalInput7Changed(qreal EXDigitalInput7);
    void EXDigitalInput8Changed(qreal EXDigitalInput8);

    // * Signals - Frequency/RPM
    void RPMFrequencyDividerDi1Changed(qreal RPMFrequencyDividerDi1);
    void frequencyDIEX1Changed(qreal frequencyDIEX1);
    void DI1RPMEnabledChanged(int DI1RPMEnabled);

private:
    // * Main Board
    qreal m_DigitalInput1 = 0;
    qreal m_DigitalInput2 = 0;
    qreal m_DigitalInput3 = 0;
    qreal m_DigitalInput4 = 0;
    qreal m_DigitalInput5 = 0;
    qreal m_DigitalInput6 = 0;
    qreal m_DigitalInput7 = 0;

    // * Expansion Board
    qreal m_EXDigitalInput1 = 0;
    qreal m_EXDigitalInput2 = 0;
    qreal m_EXDigitalInput3 = 0;
    qreal m_EXDigitalInput4 = 0;
    qreal m_EXDigitalInput5 = 0;
    qreal m_EXDigitalInput6 = 0;
    qreal m_EXDigitalInput7 = 0;
    qreal m_EXDigitalInput8 = 0;

    // * Frequency/RPM
    qreal m_RPMFrequencyDividerDi1 = 0;
    qreal m_frequencyDIEX1 = 0;
    int m_DI1RPMEnabled = 0;
};

#endif  // DIGITALINPUTS_H
