/**
 * @file ElectricMotorData.h
 * @brief Electric motor/EV data model for PowerTune
 * 
 * This class encapsulates electric motor/EV-specific data including:
 * - IGBT phase temperatures
 * - Motor temperature
 * - Phase currents A/B/C
 * - DC bus voltage/current
 * - Motor speed, angle
 * - RTD temps 1-5
 * - Digital switch inputs
 * 
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#ifndef ELECTRICMOTORDATA_H
#define ELECTRICMOTORDATA_H

#include <QObject>

class ElectricMotorData : public QObject
{
    Q_OBJECT

    // * IGBT/Controller Temps
    Q_PROPERTY(qreal IGBTPhaseATemp READ IGBTPhaseATemp WRITE setIGBTPhaseATemp NOTIFY IGBTPhaseATempChanged)
    Q_PROPERTY(qreal IGBTPhaseBTemp READ IGBTPhaseBTemp WRITE setIGBTPhaseBTemp NOTIFY IGBTPhaseBTempChanged)
    Q_PROPERTY(qreal IGBTPhaseCTemp READ IGBTPhaseCTemp WRITE setIGBTPhaseCTemp NOTIFY IGBTPhaseCTempChanged)
    Q_PROPERTY(qreal GateDriverTemp READ GateDriverTemp WRITE setGateDriverTemp NOTIFY GateDriverTempChanged)
    Q_PROPERTY(qreal ControlBoardTemp READ ControlBoardTemp WRITE setControlBoardTemp NOTIFY ControlBoardTempChanged)

    // * RTD Temperatures
    Q_PROPERTY(qreal RtdTemp1 READ RtdTemp1 WRITE setRtdTemp1 NOTIFY RtdTemp1Changed)
    Q_PROPERTY(qreal RtdTemp2 READ RtdTemp2 WRITE setRtdTemp2 NOTIFY RtdTemp2Changed)
    Q_PROPERTY(qreal RtdTemp3 READ RtdTemp3 WRITE setRtdTemp3 NOTIFY RtdTemp3Changed)
    Q_PROPERTY(qreal RtdTemp4 READ RtdTemp4 WRITE setRtdTemp4 NOTIFY RtdTemp4Changed)
    Q_PROPERTY(qreal RtdTemp5 READ RtdTemp5 WRITE setRtdTemp5 NOTIFY RtdTemp5Changed)

    // * Motor
    Q_PROPERTY(qreal EMotorTemperature READ EMotorTemperature WRITE setEMotorTemperature NOTIFY EMotorTemperatureChanged)
    Q_PROPERTY(qreal EMotorAngle READ EMotorAngle WRITE setEMotorAngle NOTIFY EMotorAngleChanged)
    Q_PROPERTY(qreal EMotorSpeed READ EMotorSpeed WRITE setEMotorSpeed NOTIFY EMotorSpeedChanged)
    Q_PROPERTY(qreal TorqueShudder READ TorqueShudder WRITE setTorqueShudder NOTIFY TorqueShudderChanged)

    // * Electrical
    Q_PROPERTY(qreal PhaseACurrent READ PhaseACurrent WRITE setPhaseACurrent NOTIFY PhaseACurrentChanged)
    Q_PROPERTY(qreal PhaseBCurrent READ PhaseBCurrent WRITE setPhaseBCurrent NOTIFY PhaseBCurrentChanged)
    Q_PROPERTY(qreal PhaseCCurrent READ PhaseCCurrent WRITE setPhaseCCurrent NOTIFY PhaseCCurrentChanged)
    Q_PROPERTY(qreal DCBusCurrent READ DCBusCurrent WRITE setDCBusCurrent NOTIFY DCBusCurrentChanged)
    Q_PROPERTY(qreal DCBusVoltage READ DCBusVoltage WRITE setDCBusVoltage NOTIFY DCBusVoltageChanged)
    Q_PROPERTY(qreal OutputVoltage READ OutputVoltage WRITE setOutputVoltage NOTIFY OutputVoltageChanged)
    Q_PROPERTY(qreal VABvdVoltage READ VABvdVoltage WRITE setVABvdVoltage NOTIFY VABvdVoltageChanged)
    Q_PROPERTY(qreal VBCvqVoltage READ VBCvqVoltage WRITE setVBCvqVoltage NOTIFY VBCvqVoltageChanged)
    Q_PROPERTY(qreal ElectricalOutFreq READ ElectricalOutFreq WRITE setElectricalOutFreq NOTIFY ElectricalOutFreqChanged)
    Q_PROPERTY(qreal DeltaResolverFiltered READ DeltaResolverFiltered WRITE setDeltaResolverFiltered NOTIFY DeltaResolverFilteredChanged)

    // * Digital Inputs (EV-specific)
    Q_PROPERTY(qreal DigInput1FowardSw READ DigInput1FowardSw WRITE setDigInput1FowardSw NOTIFY DigInput1FowardSwChanged)
    Q_PROPERTY(qreal DigInput2ReverseSw READ DigInput2ReverseSw WRITE setDigInput2ReverseSw NOTIFY DigInput2ReverseSwChanged)
    Q_PROPERTY(qreal DigInput3BrakeSw READ DigInput3BrakeSw WRITE setDigInput3BrakeSw NOTIFY DigInput3BrakeSwChanged)
    Q_PROPERTY(qreal DigInput4RegenDisableSw READ DigInput4RegenDisableSw WRITE setDigInput4RegenDisableSw NOTIFY DigInput4RegenDisableSwChanged)
    Q_PROPERTY(qreal DigInput5IgnSw READ DigInput5IgnSw WRITE setDigInput5IgnSw NOTIFY DigInput5IgnSwChanged)
    Q_PROPERTY(qreal DigInput6StartSw READ DigInput6StartSw WRITE setDigInput6StartSw NOTIFY DigInput6StartSwChanged)
    Q_PROPERTY(qreal DigInput7Bool READ DigInput7Bool WRITE setDigInput7Bool NOTIFY DigInput7BoolChanged)
    Q_PROPERTY(qreal DigInput8Bool READ DigInput8Bool WRITE setDigInput8Bool NOTIFY DigInput8BoolChanged)

public:
    explicit ElectricMotorData(QObject *parent = nullptr);

    // * Getters - IGBT/Controller Temps
    qreal IGBTPhaseATemp() const { return m_IGBTPhaseATemp; }
    qreal IGBTPhaseBTemp() const { return m_IGBTPhaseBTemp; }
    qreal IGBTPhaseCTemp() const { return m_IGBTPhaseCTemp; }
    qreal GateDriverTemp() const { return m_GateDriverTemp; }
    qreal ControlBoardTemp() const { return m_ControlBoardTemp; }

    // * Getters - RTD Temps
    qreal RtdTemp1() const { return m_RtdTemp1; }
    qreal RtdTemp2() const { return m_RtdTemp2; }
    qreal RtdTemp3() const { return m_RtdTemp3; }
    qreal RtdTemp4() const { return m_RtdTemp4; }
    qreal RtdTemp5() const { return m_RtdTemp5; }

    // * Getters - Motor
    qreal EMotorTemperature() const { return m_EMotorTemperature; }
    qreal EMotorAngle() const { return m_EMotorAngle; }
    qreal EMotorSpeed() const { return m_EMotorSpeed; }
    qreal TorqueShudder() const { return m_TorqueShudder; }

    // * Getters - Electrical
    qreal PhaseACurrent() const { return m_PhaseACurrent; }
    qreal PhaseBCurrent() const { return m_PhaseBCurrent; }
    qreal PhaseCCurrent() const { return m_PhaseCCurrent; }
    qreal DCBusCurrent() const { return m_DCBusCurrent; }
    qreal DCBusVoltage() const { return m_DCBusVoltage; }
    qreal OutputVoltage() const { return m_OutputVoltage; }
    qreal VABvdVoltage() const { return m_VABvdVoltage; }
    qreal VBCvqVoltage() const { return m_VBCvqVoltage; }
    qreal ElectricalOutFreq() const { return m_ElectricalOutFreq; }
    qreal DeltaResolverFiltered() const { return m_DeltaResolverFiltered; }

    // * Getters - Digital Inputs
    qreal DigInput1FowardSw() const { return m_DigInput1FowardSw; }
    qreal DigInput2ReverseSw() const { return m_DigInput2ReverseSw; }
    qreal DigInput3BrakeSw() const { return m_DigInput3BrakeSw; }
    qreal DigInput4RegenDisableSw() const { return m_DigInput4RegenDisableSw; }
    qreal DigInput5IgnSw() const { return m_DigInput5IgnSw; }
    qreal DigInput6StartSw() const { return m_DigInput6StartSw; }
    qreal DigInput7Bool() const { return m_DigInput7Bool; }
    qreal DigInput8Bool() const { return m_DigInput8Bool; }

public slots:
    // * Setters - IGBT/Controller Temps
    void setIGBTPhaseATemp(qreal IGBTPhaseATemp);
    void setIGBTPhaseBTemp(qreal IGBTPhaseBTemp);
    void setIGBTPhaseCTemp(qreal IGBTPhaseCTemp);
    void setGateDriverTemp(qreal GateDriverTemp);
    void setControlBoardTemp(qreal ControlBoardTemp);

    // * Setters - RTD Temps
    void setRtdTemp1(qreal RtdTemp1);
    void setRtdTemp2(qreal RtdTemp2);
    void setRtdTemp3(qreal RtdTemp3);
    void setRtdTemp4(qreal RtdTemp4);
    void setRtdTemp5(qreal RtdTemp5);

    // * Setters - Motor
    void setEMotorTemperature(qreal EMotorTemperature);
    void setEMotorAngle(qreal EMotorAngle);
    void setEMotorSpeed(qreal EMotorSpeed);
    void setTorqueShudder(qreal TorqueShudder);

    // * Setters - Electrical
    void setPhaseACurrent(qreal PhaseACurrent);
    void setPhaseBCurrent(qreal PhaseBCurrent);
    void setPhaseCCurrent(qreal PhaseCCurrent);
    void setDCBusCurrent(qreal DCBusCurrent);
    void setDCBusVoltage(qreal DCBusVoltage);
    void setOutputVoltage(qreal OutputVoltage);
    void setVABvdVoltage(qreal VABvdVoltage);
    void setVBCvqVoltage(qreal VBCvqVoltage);
    void setElectricalOutFreq(qreal ElectricalOutFreq);
    void setDeltaResolverFiltered(qreal DeltaResolverFiltered);

    // * Setters - Digital Inputs
    void setDigInput1FowardSw(qreal DigInput1FowardSw);
    void setDigInput2ReverseSw(qreal DigInput2ReverseSw);
    void setDigInput3BrakeSw(qreal DigInput3BrakeSw);
    void setDigInput4RegenDisableSw(qreal DigInput4RegenDisableSw);
    void setDigInput5IgnSw(qreal DigInput5IgnSw);
    void setDigInput6StartSw(qreal DigInput6StartSw);
    void setDigInput7Bool(qreal DigInput7Bool);
    void setDigInput8Bool(qreal DigInput8Bool);

signals:
    // * Signals - IGBT/Controller Temps
    void IGBTPhaseATempChanged(qreal IGBTPhaseATemp);
    void IGBTPhaseBTempChanged(qreal IGBTPhaseBTemp);
    void IGBTPhaseCTempChanged(qreal IGBTPhaseCTemp);
    void GateDriverTempChanged(qreal GateDriverTemp);
    void ControlBoardTempChanged(qreal ControlBoardTemp);

    // * Signals - RTD Temps
    void RtdTemp1Changed(qreal RtdTemp1);
    void RtdTemp2Changed(qreal RtdTemp2);
    void RtdTemp3Changed(qreal RtdTemp3);
    void RtdTemp4Changed(qreal RtdTemp4);
    void RtdTemp5Changed(qreal RtdTemp5);

    // * Signals - Motor
    void EMotorTemperatureChanged(qreal EMotorTemperature);
    void EMotorAngleChanged(qreal EMotorAngle);
    void EMotorSpeedChanged(qreal EMotorSpeed);
    void TorqueShudderChanged(qreal TorqueShudder);

    // * Signals - Electrical
    void PhaseACurrentChanged(qreal PhaseACurrent);
    void PhaseBCurrentChanged(qreal PhaseBCurrent);
    void PhaseCCurrentChanged(qreal PhaseCCurrent);
    void DCBusCurrentChanged(qreal DCBusCurrent);
    void DCBusVoltageChanged(qreal DCBusVoltage);
    void OutputVoltageChanged(qreal OutputVoltage);
    void VABvdVoltageChanged(qreal VABvdVoltage);
    void VBCvqVoltageChanged(qreal VBCvqVoltage);
    void ElectricalOutFreqChanged(qreal ElectricalOutFreq);
    void DeltaResolverFilteredChanged(qreal DeltaResolverFiltered);

    // * Signals - Digital Inputs
    void DigInput1FowardSwChanged(qreal DigInput1FowardSw);
    void DigInput2ReverseSwChanged(qreal DigInput2ReverseSw);
    void DigInput3BrakeSwChanged(qreal DigInput3BrakeSw);
    void DigInput4RegenDisableSwChanged(qreal DigInput4RegenDisableSw);
    void DigInput5IgnSwChanged(qreal DigInput5IgnSw);
    void DigInput6StartSwChanged(qreal DigInput6StartSw);
    void DigInput7BoolChanged(qreal DigInput7Bool);
    void DigInput8BoolChanged(qreal DigInput8Bool);

private:
    // * IGBT/Controller Temps
    qreal m_IGBTPhaseATemp = 0;
    qreal m_IGBTPhaseBTemp = 0;
    qreal m_IGBTPhaseCTemp = 0;
    qreal m_GateDriverTemp = 0;
    qreal m_ControlBoardTemp = 0;

    // * RTD Temps
    qreal m_RtdTemp1 = 0;
    qreal m_RtdTemp2 = 0;
    qreal m_RtdTemp3 = 0;
    qreal m_RtdTemp4 = 0;
    qreal m_RtdTemp5 = 0;

    // * Motor
    qreal m_EMotorTemperature = 0;
    qreal m_EMotorAngle = 0;
    qreal m_EMotorSpeed = 0;
    qreal m_TorqueShudder = 0;

    // * Electrical
    qreal m_PhaseACurrent = 0;
    qreal m_PhaseBCurrent = 0;
    qreal m_PhaseCCurrent = 0;
    qreal m_DCBusCurrent = 0;
    qreal m_DCBusVoltage = 0;
    qreal m_OutputVoltage = 0;
    qreal m_VABvdVoltage = 0;
    qreal m_VBCvqVoltage = 0;
    qreal m_ElectricalOutFreq = 0;
    qreal m_DeltaResolverFiltered = 0;

    // * Digital Inputs
    qreal m_DigInput1FowardSw = 0;
    qreal m_DigInput2ReverseSw = 0;
    qreal m_DigInput3BrakeSw = 0;
    qreal m_DigInput4RegenDisableSw = 0;
    qreal m_DigInput5IgnSw = 0;
    qreal m_DigInput6StartSw = 0;
    qreal m_DigInput7Bool = 0;
    qreal m_DigInput8Bool = 0;
};

#endif // ELECTRICMOTORDATA_H
