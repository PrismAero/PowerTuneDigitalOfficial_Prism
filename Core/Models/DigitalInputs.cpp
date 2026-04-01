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
