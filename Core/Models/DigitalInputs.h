/**
 * @file DigitalInputs.h
 * @brief Digital input data model for PowerTune
 *
 * This class encapsulates digital I/O state data including:
 * - EXDigitalInput1-8 (CAN ExBoard extender)
 * - PTDigitalInput1-4 and PTRelay1-4 (PT_Extender CAN protocol)
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
    Q_PROPERTY(qreal PTDigitalInput1 READ PTDigitalInput1 WRITE setPTDigitalInput1 NOTIFY PTDigitalInput1Changed)
    Q_PROPERTY(qreal PTDigitalInput2 READ PTDigitalInput2 WRITE setPTDigitalInput2 NOTIFY PTDigitalInput2Changed)
    Q_PROPERTY(qreal PTDigitalInput3 READ PTDigitalInput3 WRITE setPTDigitalInput3 NOTIFY PTDigitalInput3Changed)
    Q_PROPERTY(qreal PTDigitalInput4 READ PTDigitalInput4 WRITE setPTDigitalInput4 NOTIFY PTDigitalInput4Changed)

    Q_PROPERTY(qreal PTRelay1 READ PTRelay1 WRITE setPTRelay1 NOTIFY PTRelay1Changed)
    Q_PROPERTY(qreal PTRelay2 READ PTRelay2 WRITE setPTRelay2 NOTIFY PTRelay2Changed)
    Q_PROPERTY(qreal PTRelay3 READ PTRelay3 WRITE setPTRelay3 NOTIFY PTRelay3Changed)
    Q_PROPERTY(qreal PTRelay4 READ PTRelay4 WRITE setPTRelay4 NOTIFY PTRelay4Changed)
    Q_PROPERTY(int PTRelayMask READ PTRelayMask WRITE setPTRelayMask NOTIFY PTRelayMaskChanged)
    Q_PROPERTY(int PTSystemState READ PTSystemState WRITE setPTSystemState NOTIFY PTSystemStateChanged)
    Q_PROPERTY(int PTSystemFault READ PTSystemFault WRITE setPTSystemFault NOTIFY PTSystemFaultChanged)
    Q_PROPERTY(int PTDfiChecksumErrors READ PTDfiChecksumErrors WRITE setPTDfiChecksumErrors NOTIFY PTDfiChecksumErrorsChanged)
    Q_PROPERTY(int PTCanTxErrors READ PTCanTxErrors WRITE setPTCanTxErrors NOTIFY PTCanTxErrorsChanged)
    Q_PROPERTY(int PTRelayFollowerMask READ PTRelayFollowerMask WRITE setPTRelayFollowerMask NOTIFY PTRelayFollowerMaskChanged)
    Q_PROPERTY(int PTRelayInvertMask READ PTRelayInvertMask WRITE setPTRelayInvertMask NOTIFY PTRelayInvertMaskChanged)
    Q_PROPERTY(int PTRelayBoundTargetsPacked READ PTRelayBoundTargetsPacked WRITE setPTRelayBoundTargetsPacked NOTIFY PTRelayBoundTargetsPackedChanged)

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
    qreal PTDigitalInput1() const { return m_PTDigitalInput1; }
    qreal PTDigitalInput2() const { return m_PTDigitalInput2; }
    qreal PTDigitalInput3() const { return m_PTDigitalInput3; }
    qreal PTDigitalInput4() const { return m_PTDigitalInput4; }

    qreal PTRelay1() const { return m_PTRelay1; }
    qreal PTRelay2() const { return m_PTRelay2; }
    qreal PTRelay3() const { return m_PTRelay3; }
    qreal PTRelay4() const { return m_PTRelay4; }
    int PTRelayMask() const { return m_PTRelayMask; }
    int PTSystemState() const { return m_PTSystemState; }
    int PTSystemFault() const { return m_PTSystemFault; }
    int PTDfiChecksumErrors() const { return m_PTDfiChecksumErrors; }
    int PTCanTxErrors() const { return m_PTCanTxErrors; }
    int PTRelayFollowerMask() const { return m_PTRelayFollowerMask; }
    int PTRelayInvertMask() const { return m_PTRelayInvertMask; }
    int PTRelayBoundTargetsPacked() const { return m_PTRelayBoundTargetsPacked; }

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
    void setPTDigitalInput1(qreal PTDigitalInput1);
    void setPTDigitalInput2(qreal PTDigitalInput2);
    void setPTDigitalInput3(qreal PTDigitalInput3);
    void setPTDigitalInput4(qreal PTDigitalInput4);

    void setPTRelay1(qreal PTRelay1);
    void setPTRelay2(qreal PTRelay2);
    void setPTRelay3(qreal PTRelay3);
    void setPTRelay4(qreal PTRelay4);
    void setPTRelayMask(int PTRelayMask);
    void setPTSystemState(int PTSystemState);
    void setPTSystemFault(int PTSystemFault);
    void setPTDfiChecksumErrors(int PTDfiChecksumErrors);
    void setPTCanTxErrors(int PTCanTxErrors);
    void setPTRelayFollowerMask(int PTRelayFollowerMask);
    void setPTRelayInvertMask(int PTRelayInvertMask);
    void setPTRelayBoundTargetsPacked(int PTRelayBoundTargetsPacked);

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
    void PTDigitalInput1Changed(qreal PTDigitalInput1);
    void PTDigitalInput2Changed(qreal PTDigitalInput2);
    void PTDigitalInput3Changed(qreal PTDigitalInput3);
    void PTDigitalInput4Changed(qreal PTDigitalInput4);

    void PTRelay1Changed(qreal PTRelay1);
    void PTRelay2Changed(qreal PTRelay2);
    void PTRelay3Changed(qreal PTRelay3);
    void PTRelay4Changed(qreal PTRelay4);
    void PTRelayMaskChanged(int PTRelayMask);
    void PTSystemStateChanged(int PTSystemState);
    void PTSystemFaultChanged(int PTSystemFault);
    void PTDfiChecksumErrorsChanged(int PTDfiChecksumErrors);
    void PTCanTxErrorsChanged(int PTCanTxErrors);
    void PTRelayFollowerMaskChanged(int PTRelayFollowerMask);
    void PTRelayInvertMaskChanged(int PTRelayInvertMask);
    void PTRelayBoundTargetsPackedChanged(int PTRelayBoundTargetsPacked);

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
    qreal m_PTDigitalInput1 = 0;
    qreal m_PTDigitalInput2 = 0;
    qreal m_PTDigitalInput3 = 0;
    qreal m_PTDigitalInput4 = 0;
    qreal m_PTRelay1 = 0;
    qreal m_PTRelay2 = 0;
    qreal m_PTRelay3 = 0;
    qreal m_PTRelay4 = 0;
    int m_PTRelayMask = 0;
    int m_PTSystemState = 0;
    int m_PTSystemFault = 0;
    int m_PTDfiChecksumErrors = 0;
    int m_PTCanTxErrors = 0;
    int m_PTRelayFollowerMask = 0;
    int m_PTRelayInvertMask = 0;
    int m_PTRelayBoundTargetsPacked = 0;

    qreal m_RPMFrequencyDividerDi1 = 0;
    qreal m_frequencyDIEX1 = 0;
    int m_DI1RPMEnabled = 0;
};

#endif  // DIGITALINPUTS_H
