/**
 * @file DigitalInputs.cpp
 * @brief Implementation of the DigitalInputs class
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#include "DigitalInputs.h"

DigitalInputs::DigitalInputs(QObject *parent) : QObject(parent) {}

void DigitalInputs::setEXDigitalInput1(qreal EXDigitalInput1)
{
    if (m_EXDigitalInput1 != EXDigitalInput1) {
        m_EXDigitalInput1 = EXDigitalInput1;
        emit EXDigitalInput1Changed(EXDigitalInput1);
    }
}
void DigitalInputs::setEXDigitalInput2(qreal EXDigitalInput2)
{
    if (m_EXDigitalInput2 != EXDigitalInput2) {
        m_EXDigitalInput2 = EXDigitalInput2;
        emit EXDigitalInput2Changed(EXDigitalInput2);
    }
}
void DigitalInputs::setEXDigitalInput3(qreal EXDigitalInput3)
{
    if (m_EXDigitalInput3 != EXDigitalInput3) {
        m_EXDigitalInput3 = EXDigitalInput3;
        emit EXDigitalInput3Changed(EXDigitalInput3);
    }
}
void DigitalInputs::setEXDigitalInput4(qreal EXDigitalInput4)
{
    if (m_EXDigitalInput4 != EXDigitalInput4) {
        m_EXDigitalInput4 = EXDigitalInput4;
        emit EXDigitalInput4Changed(EXDigitalInput4);
    }
}
void DigitalInputs::setEXDigitalInput5(qreal EXDigitalInput5)
{
    if (m_EXDigitalInput5 != EXDigitalInput5) {
        m_EXDigitalInput5 = EXDigitalInput5;
        emit EXDigitalInput5Changed(EXDigitalInput5);
    }
}
void DigitalInputs::setEXDigitalInput6(qreal EXDigitalInput6)
{
    if (m_EXDigitalInput6 != EXDigitalInput6) {
        m_EXDigitalInput6 = EXDigitalInput6;
        emit EXDigitalInput6Changed(EXDigitalInput6);
    }
}
void DigitalInputs::setEXDigitalInput7(qreal EXDigitalInput7)
{
    if (m_EXDigitalInput7 != EXDigitalInput7) {
        m_EXDigitalInput7 = EXDigitalInput7;
        emit EXDigitalInput7Changed(EXDigitalInput7);
    }
}
void DigitalInputs::setEXDigitalInput8(qreal EXDigitalInput8)
{
    if (m_EXDigitalInput8 != EXDigitalInput8) {
        m_EXDigitalInput8 = EXDigitalInput8;
        emit EXDigitalInput8Changed(EXDigitalInput8);
    }
}
void DigitalInputs::setPTDigitalInput1(qreal PTDigitalInput1)
{
    if (m_PTDigitalInput1 != PTDigitalInput1) {
        m_PTDigitalInput1 = PTDigitalInput1;
        emit PTDigitalInput1Changed(PTDigitalInput1);
    }
}
void DigitalInputs::setPTDigitalInput2(qreal PTDigitalInput2)
{
    if (m_PTDigitalInput2 != PTDigitalInput2) {
        m_PTDigitalInput2 = PTDigitalInput2;
        emit PTDigitalInput2Changed(PTDigitalInput2);
    }
}
void DigitalInputs::setPTDigitalInput3(qreal PTDigitalInput3)
{
    if (m_PTDigitalInput3 != PTDigitalInput3) {
        m_PTDigitalInput3 = PTDigitalInput3;
        emit PTDigitalInput3Changed(PTDigitalInput3);
    }
}
void DigitalInputs::setPTDigitalInput4(qreal PTDigitalInput4)
{
    if (m_PTDigitalInput4 != PTDigitalInput4) {
        m_PTDigitalInput4 = PTDigitalInput4;
        emit PTDigitalInput4Changed(PTDigitalInput4);
    }
}

void DigitalInputs::setPTRelay1(qreal PTRelay1)
{
    if (m_PTRelay1 != PTRelay1) {
        m_PTRelay1 = PTRelay1;
        emit PTRelay1Changed(PTRelay1);
    }
}
void DigitalInputs::setPTRelay2(qreal PTRelay2)
{
    if (m_PTRelay2 != PTRelay2) {
        m_PTRelay2 = PTRelay2;
        emit PTRelay2Changed(PTRelay2);
    }
}
void DigitalInputs::setPTRelay3(qreal PTRelay3)
{
    if (m_PTRelay3 != PTRelay3) {
        m_PTRelay3 = PTRelay3;
        emit PTRelay3Changed(PTRelay3);
    }
}
void DigitalInputs::setPTRelay4(qreal PTRelay4)
{
    if (m_PTRelay4 != PTRelay4) {
        m_PTRelay4 = PTRelay4;
        emit PTRelay4Changed(PTRelay4);
    }
}
void DigitalInputs::setPTRelayMask(int PTRelayMask)
{
    if (m_PTRelayMask != PTRelayMask) {
        m_PTRelayMask = PTRelayMask;
        emit PTRelayMaskChanged(PTRelayMask);
    }
}
void DigitalInputs::setPTSystemState(int PTSystemState)
{
    if (m_PTSystemState != PTSystemState) {
        m_PTSystemState = PTSystemState;
        emit PTSystemStateChanged(PTSystemState);
    }
}
void DigitalInputs::setPTSystemFault(int PTSystemFault)
{
    if (m_PTSystemFault != PTSystemFault) {
        m_PTSystemFault = PTSystemFault;
        emit PTSystemFaultChanged(PTSystemFault);
    }
}
void DigitalInputs::setPTDfiChecksumErrors(int PTDfiChecksumErrors)
{
    if (m_PTDfiChecksumErrors != PTDfiChecksumErrors) {
        m_PTDfiChecksumErrors = PTDfiChecksumErrors;
        emit PTDfiChecksumErrorsChanged(PTDfiChecksumErrors);
    }
}
void DigitalInputs::setPTCanTxErrors(int PTCanTxErrors)
{
    if (m_PTCanTxErrors != PTCanTxErrors) {
        m_PTCanTxErrors = PTCanTxErrors;
        emit PTCanTxErrorsChanged(PTCanTxErrors);
    }
}
void DigitalInputs::setPTRelayFollowerMask(int PTRelayFollowerMask)
{
    if (m_PTRelayFollowerMask != PTRelayFollowerMask) {
        m_PTRelayFollowerMask = PTRelayFollowerMask;
        emit PTRelayFollowerMaskChanged(PTRelayFollowerMask);
    }
}
void DigitalInputs::setPTRelayInvertMask(int PTRelayInvertMask)
{
    if (m_PTRelayInvertMask != PTRelayInvertMask) {
        m_PTRelayInvertMask = PTRelayInvertMask;
        emit PTRelayInvertMaskChanged(PTRelayInvertMask);
    }
}
void DigitalInputs::setPTRelayBoundTargetsPacked(int PTRelayBoundTargetsPacked)
{
    if (m_PTRelayBoundTargetsPacked != PTRelayBoundTargetsPacked) {
        m_PTRelayBoundTargetsPacked = PTRelayBoundTargetsPacked;
        emit PTRelayBoundTargetsPackedChanged(PTRelayBoundTargetsPacked);
    }
}

void DigitalInputs::setPTGear(int PTGear)
{
    if (m_PTGear != PTGear) {
        m_PTGear = PTGear;
        emit PTGearChanged(PTGear);
    }
}

void DigitalInputs::setPTActiveCodes(const QString &PTActiveCodes)
{
    if (m_PTActiveCodes != PTActiveCodes) {
        m_PTActiveCodes = PTActiveCodes;
        emit PTActiveCodesChanged(PTActiveCodes);
    }
}

void DigitalInputs::setRPMFrequencyDividerDi1(qreal RPMFrequencyDividerDi1)
{
    if (m_RPMFrequencyDividerDi1 != RPMFrequencyDividerDi1) {
        m_RPMFrequencyDividerDi1 = RPMFrequencyDividerDi1;
        emit RPMFrequencyDividerDi1Changed(RPMFrequencyDividerDi1);
    }
}
void DigitalInputs::setfrequencyDIEX1(qreal frequencyDIEX1)
{
    if (m_frequencyDIEX1 != frequencyDIEX1) {
        m_frequencyDIEX1 = frequencyDIEX1;
        emit frequencyDIEX1Changed(frequencyDIEX1);
    }
}
void DigitalInputs::setDI1RPMEnabled(int DI1RPMEnabled)
{
    if (m_DI1RPMEnabled != DI1RPMEnabled) {
        m_DI1RPMEnabled = DI1RPMEnabled;
        emit DI1RPMEnabledChanged(DI1RPMEnabled);
    }
}
