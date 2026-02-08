/**
 * @file DigitalInputs.cpp
 * @brief Implementation of the DigitalInputs class
 * 
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#include "DigitalInputs.h"

DigitalInputs::DigitalInputs(QObject *parent)
    : QObject(parent)
{
}

// * Setters - Main Board
void DigitalInputs::setDigitalInput1(qreal DigitalInput1) { if (m_DigitalInput1 != DigitalInput1) { m_DigitalInput1 = DigitalInput1; emit DigitalInput1Changed(DigitalInput1); } }
void DigitalInputs::setDigitalInput2(qreal DigitalInput2) { if (m_DigitalInput2 != DigitalInput2) { m_DigitalInput2 = DigitalInput2; emit DigitalInput2Changed(DigitalInput2); } }
void DigitalInputs::setDigitalInput3(qreal DigitalInput3) { if (m_DigitalInput3 != DigitalInput3) { m_DigitalInput3 = DigitalInput3; emit DigitalInput3Changed(DigitalInput3); } }
void DigitalInputs::setDigitalInput4(qreal DigitalInput4) { if (m_DigitalInput4 != DigitalInput4) { m_DigitalInput4 = DigitalInput4; emit DigitalInput4Changed(DigitalInput4); } }
void DigitalInputs::setDigitalInput5(qreal DigitalInput5) { if (m_DigitalInput5 != DigitalInput5) { m_DigitalInput5 = DigitalInput5; emit DigitalInput5Changed(DigitalInput5); } }
void DigitalInputs::setDigitalInput6(qreal DigitalInput6) { if (m_DigitalInput6 != DigitalInput6) { m_DigitalInput6 = DigitalInput6; emit DigitalInput6Changed(DigitalInput6); } }
void DigitalInputs::setDigitalInput7(qreal DigitalInput7) { if (m_DigitalInput7 != DigitalInput7) { m_DigitalInput7 = DigitalInput7; emit DigitalInput7Changed(DigitalInput7); } }

// * Setters - Expansion Board
void DigitalInputs::setEXDigitalInput1(qreal EXDigitalInput1) { if (m_EXDigitalInput1 != EXDigitalInput1) { m_EXDigitalInput1 = EXDigitalInput1; emit EXDigitalInput1Changed(EXDigitalInput1); } }
void DigitalInputs::setEXDigitalInput2(qreal EXDigitalInput2) { if (m_EXDigitalInput2 != EXDigitalInput2) { m_EXDigitalInput2 = EXDigitalInput2; emit EXDigitalInput2Changed(EXDigitalInput2); } }
void DigitalInputs::setEXDigitalInput3(qreal EXDigitalInput3) { if (m_EXDigitalInput3 != EXDigitalInput3) { m_EXDigitalInput3 = EXDigitalInput3; emit EXDigitalInput3Changed(EXDigitalInput3); } }
void DigitalInputs::setEXDigitalInput4(qreal EXDigitalInput4) { if (m_EXDigitalInput4 != EXDigitalInput4) { m_EXDigitalInput4 = EXDigitalInput4; emit EXDigitalInput4Changed(EXDigitalInput4); } }
void DigitalInputs::setEXDigitalInput5(qreal EXDigitalInput5) { if (m_EXDigitalInput5 != EXDigitalInput5) { m_EXDigitalInput5 = EXDigitalInput5; emit EXDigitalInput5Changed(EXDigitalInput5); } }
void DigitalInputs::setEXDigitalInput6(qreal EXDigitalInput6) { if (m_EXDigitalInput6 != EXDigitalInput6) { m_EXDigitalInput6 = EXDigitalInput6; emit EXDigitalInput6Changed(EXDigitalInput6); } }
void DigitalInputs::setEXDigitalInput7(qreal EXDigitalInput7) { if (m_EXDigitalInput7 != EXDigitalInput7) { m_EXDigitalInput7 = EXDigitalInput7; emit EXDigitalInput7Changed(EXDigitalInput7); } }
void DigitalInputs::setEXDigitalInput8(qreal EXDigitalInput8) { if (m_EXDigitalInput8 != EXDigitalInput8) { m_EXDigitalInput8 = EXDigitalInput8; emit EXDigitalInput8Changed(EXDigitalInput8); } }

// * Setters - Frequency/RPM
void DigitalInputs::setRPMFrequencyDividerDi1(qreal RPMFrequencyDividerDi1) { if (m_RPMFrequencyDividerDi1 != RPMFrequencyDividerDi1) { m_RPMFrequencyDividerDi1 = RPMFrequencyDividerDi1; emit RPMFrequencyDividerDi1Changed(RPMFrequencyDividerDi1); } }
void DigitalInputs::setfrequencyDIEX1(qreal frequencyDIEX1) { if (m_frequencyDIEX1 != frequencyDIEX1) { m_frequencyDIEX1 = frequencyDIEX1; emit frequencyDIEX1Changed(frequencyDIEX1); } }
void DigitalInputs::setDI1RPMEnabled(int DI1RPMEnabled) { if (m_DI1RPMEnabled != DI1RPMEnabled) { m_DI1RPMEnabled = DI1RPMEnabled; emit DI1RPMEnabledChanged(DI1RPMEnabled); } }
