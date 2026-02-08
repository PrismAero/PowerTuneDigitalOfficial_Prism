/**
 * @file ElectricMotorData.cpp
 * @brief Implementation of the ElectricMotorData class
 * 
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#include "ElectricMotorData.h"

ElectricMotorData::ElectricMotorData(QObject *parent)
    : QObject(parent)
{
}

// * Setters - IGBT/Controller Temps
void ElectricMotorData::setIGBTPhaseATemp(qreal IGBTPhaseATemp) { if (m_IGBTPhaseATemp != IGBTPhaseATemp) { m_IGBTPhaseATemp = IGBTPhaseATemp; emit IGBTPhaseATempChanged(IGBTPhaseATemp); } }
void ElectricMotorData::setIGBTPhaseBTemp(qreal IGBTPhaseBTemp) { if (m_IGBTPhaseBTemp != IGBTPhaseBTemp) { m_IGBTPhaseBTemp = IGBTPhaseBTemp; emit IGBTPhaseBTempChanged(IGBTPhaseBTemp); } }
void ElectricMotorData::setIGBTPhaseCTemp(qreal IGBTPhaseCTemp) { if (m_IGBTPhaseCTemp != IGBTPhaseCTemp) { m_IGBTPhaseCTemp = IGBTPhaseCTemp; emit IGBTPhaseCTempChanged(IGBTPhaseCTemp); } }
void ElectricMotorData::setGateDriverTemp(qreal GateDriverTemp) { if (m_GateDriverTemp != GateDriverTemp) { m_GateDriverTemp = GateDriverTemp; emit GateDriverTempChanged(GateDriverTemp); } }
void ElectricMotorData::setControlBoardTemp(qreal ControlBoardTemp) { if (m_ControlBoardTemp != ControlBoardTemp) { m_ControlBoardTemp = ControlBoardTemp; emit ControlBoardTempChanged(ControlBoardTemp); } }

// * Setters - RTD Temps
void ElectricMotorData::setRtdTemp1(qreal RtdTemp1) { if (m_RtdTemp1 != RtdTemp1) { m_RtdTemp1 = RtdTemp1; emit RtdTemp1Changed(RtdTemp1); } }
void ElectricMotorData::setRtdTemp2(qreal RtdTemp2) { if (m_RtdTemp2 != RtdTemp2) { m_RtdTemp2 = RtdTemp2; emit RtdTemp2Changed(RtdTemp2); } }
void ElectricMotorData::setRtdTemp3(qreal RtdTemp3) { if (m_RtdTemp3 != RtdTemp3) { m_RtdTemp3 = RtdTemp3; emit RtdTemp3Changed(RtdTemp3); } }
void ElectricMotorData::setRtdTemp4(qreal RtdTemp4) { if (m_RtdTemp4 != RtdTemp4) { m_RtdTemp4 = RtdTemp4; emit RtdTemp4Changed(RtdTemp4); } }
void ElectricMotorData::setRtdTemp5(qreal RtdTemp5) { if (m_RtdTemp5 != RtdTemp5) { m_RtdTemp5 = RtdTemp5; emit RtdTemp5Changed(RtdTemp5); } }

// * Setters - Motor
void ElectricMotorData::setEMotorTemperature(qreal EMotorTemperature) { if (m_EMotorTemperature != EMotorTemperature) { m_EMotorTemperature = EMotorTemperature; emit EMotorTemperatureChanged(EMotorTemperature); } }
void ElectricMotorData::setEMotorAngle(qreal EMotorAngle) { if (m_EMotorAngle != EMotorAngle) { m_EMotorAngle = EMotorAngle; emit EMotorAngleChanged(EMotorAngle); } }
void ElectricMotorData::setEMotorSpeed(qreal EMotorSpeed) { if (m_EMotorSpeed != EMotorSpeed) { m_EMotorSpeed = EMotorSpeed; emit EMotorSpeedChanged(EMotorSpeed); } }
void ElectricMotorData::setTorqueShudder(qreal TorqueShudder) { if (m_TorqueShudder != TorqueShudder) { m_TorqueShudder = TorqueShudder; emit TorqueShudderChanged(TorqueShudder); } }

// * Setters - Electrical
void ElectricMotorData::setPhaseACurrent(qreal PhaseACurrent) { if (m_PhaseACurrent != PhaseACurrent) { m_PhaseACurrent = PhaseACurrent; emit PhaseACurrentChanged(PhaseACurrent); } }
void ElectricMotorData::setPhaseBCurrent(qreal PhaseBCurrent) { if (m_PhaseBCurrent != PhaseBCurrent) { m_PhaseBCurrent = PhaseBCurrent; emit PhaseBCurrentChanged(PhaseBCurrent); } }
void ElectricMotorData::setPhaseCCurrent(qreal PhaseCCurrent) { if (m_PhaseCCurrent != PhaseCCurrent) { m_PhaseCCurrent = PhaseCCurrent; emit PhaseCCurrentChanged(PhaseCCurrent); } }
void ElectricMotorData::setDCBusCurrent(qreal DCBusCurrent) { if (m_DCBusCurrent != DCBusCurrent) { m_DCBusCurrent = DCBusCurrent; emit DCBusCurrentChanged(DCBusCurrent); } }
void ElectricMotorData::setDCBusVoltage(qreal DCBusVoltage) { if (m_DCBusVoltage != DCBusVoltage) { m_DCBusVoltage = DCBusVoltage; emit DCBusVoltageChanged(DCBusVoltage); } }
void ElectricMotorData::setOutputVoltage(qreal OutputVoltage) { if (m_OutputVoltage != OutputVoltage) { m_OutputVoltage = OutputVoltage; emit OutputVoltageChanged(OutputVoltage); } }
void ElectricMotorData::setVABvdVoltage(qreal VABvdVoltage) { if (m_VABvdVoltage != VABvdVoltage) { m_VABvdVoltage = VABvdVoltage; emit VABvdVoltageChanged(VABvdVoltage); } }
void ElectricMotorData::setVBCvqVoltage(qreal VBCvqVoltage) { if (m_VBCvqVoltage != VBCvqVoltage) { m_VBCvqVoltage = VBCvqVoltage; emit VBCvqVoltageChanged(VBCvqVoltage); } }
void ElectricMotorData::setElectricalOutFreq(qreal ElectricalOutFreq) { if (m_ElectricalOutFreq != ElectricalOutFreq) { m_ElectricalOutFreq = ElectricalOutFreq; emit ElectricalOutFreqChanged(ElectricalOutFreq); } }
void ElectricMotorData::setDeltaResolverFiltered(qreal DeltaResolverFiltered) { if (m_DeltaResolverFiltered != DeltaResolverFiltered) { m_DeltaResolverFiltered = DeltaResolverFiltered; emit DeltaResolverFilteredChanged(DeltaResolverFiltered); } }

// * Setters - Digital Inputs
void ElectricMotorData::setDigInput1FowardSw(qreal DigInput1FowardSw) { if (m_DigInput1FowardSw != DigInput1FowardSw) { m_DigInput1FowardSw = DigInput1FowardSw; emit DigInput1FowardSwChanged(DigInput1FowardSw); } }
void ElectricMotorData::setDigInput2ReverseSw(qreal DigInput2ReverseSw) { if (m_DigInput2ReverseSw != DigInput2ReverseSw) { m_DigInput2ReverseSw = DigInput2ReverseSw; emit DigInput2ReverseSwChanged(DigInput2ReverseSw); } }
void ElectricMotorData::setDigInput3BrakeSw(qreal DigInput3BrakeSw) { if (m_DigInput3BrakeSw != DigInput3BrakeSw) { m_DigInput3BrakeSw = DigInput3BrakeSw; emit DigInput3BrakeSwChanged(DigInput3BrakeSw); } }
void ElectricMotorData::setDigInput4RegenDisableSw(qreal DigInput4RegenDisableSw) { if (m_DigInput4RegenDisableSw != DigInput4RegenDisableSw) { m_DigInput4RegenDisableSw = DigInput4RegenDisableSw; emit DigInput4RegenDisableSwChanged(DigInput4RegenDisableSw); } }
void ElectricMotorData::setDigInput5IgnSw(qreal DigInput5IgnSw) { if (m_DigInput5IgnSw != DigInput5IgnSw) { m_DigInput5IgnSw = DigInput5IgnSw; emit DigInput5IgnSwChanged(DigInput5IgnSw); } }
void ElectricMotorData::setDigInput6StartSw(qreal DigInput6StartSw) { if (m_DigInput6StartSw != DigInput6StartSw) { m_DigInput6StartSw = DigInput6StartSw; emit DigInput6StartSwChanged(DigInput6StartSw); } }
void ElectricMotorData::setDigInput7Bool(qreal DigInput7Bool) { if (m_DigInput7Bool != DigInput7Bool) { m_DigInput7Bool = DigInput7Bool; emit DigInput7BoolChanged(DigInput7Bool); } }
void ElectricMotorData::setDigInput8Bool(qreal DigInput8Bool) { if (m_DigInput8Bool != DigInput8Bool) { m_DigInput8Bool = DigInput8Bool; emit DigInput8BoolChanged(DigInput8Bool); } }
