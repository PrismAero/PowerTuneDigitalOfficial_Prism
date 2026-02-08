/**
 * @file ExpanderBoardData.cpp
 * @brief Implementation of the ExpanderBoardData class
 * 
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#include "ExpanderBoardData.h"

ExpanderBoardData::ExpanderBoardData(QObject *parent)
    : QObject(parent)
{
}

// * Setters - Raw
void ExpanderBoardData::setEXAnalogInput0(qreal EXAnalogInput0) { if (m_EXAnalogInput0 != EXAnalogInput0) { m_EXAnalogInput0 = EXAnalogInput0; emit EXAnalogInput0Changed(EXAnalogInput0); } }
void ExpanderBoardData::setEXAnalogInput1(qreal EXAnalogInput1) { if (m_EXAnalogInput1 != EXAnalogInput1) { m_EXAnalogInput1 = EXAnalogInput1; emit EXAnalogInput1Changed(EXAnalogInput1); } }
void ExpanderBoardData::setEXAnalogInput2(qreal EXAnalogInput2) { if (m_EXAnalogInput2 != EXAnalogInput2) { m_EXAnalogInput2 = EXAnalogInput2; emit EXAnalogInput2Changed(EXAnalogInput2); } }
void ExpanderBoardData::setEXAnalogInput3(qreal EXAnalogInput3) { if (m_EXAnalogInput3 != EXAnalogInput3) { m_EXAnalogInput3 = EXAnalogInput3; emit EXAnalogInput3Changed(EXAnalogInput3); } }
void ExpanderBoardData::setEXAnalogInput4(qreal EXAnalogInput4) { if (m_EXAnalogInput4 != EXAnalogInput4) { m_EXAnalogInput4 = EXAnalogInput4; emit EXAnalogInput4Changed(EXAnalogInput4); } }
void ExpanderBoardData::setEXAnalogInput5(qreal EXAnalogInput5) { if (m_EXAnalogInput5 != EXAnalogInput5) { m_EXAnalogInput5 = EXAnalogInput5; emit EXAnalogInput5Changed(EXAnalogInput5); } }
void ExpanderBoardData::setEXAnalogInput6(qreal EXAnalogInput6) { if (m_EXAnalogInput6 != EXAnalogInput6) { m_EXAnalogInput6 = EXAnalogInput6; emit EXAnalogInput6Changed(EXAnalogInput6); } }
void ExpanderBoardData::setEXAnalogInput7(qreal EXAnalogInput7) { if (m_EXAnalogInput7 != EXAnalogInput7) { m_EXAnalogInput7 = EXAnalogInput7; emit EXAnalogInput7Changed(EXAnalogInput7); } }

// * Setters - Calculated
void ExpanderBoardData::setEXAnalogCalc0(qreal EXAnalogCalc0) { if (m_EXAnalogCalc0 != EXAnalogCalc0) { m_EXAnalogCalc0 = EXAnalogCalc0; emit EXAnalogCalc0Changed(EXAnalogCalc0); } }
void ExpanderBoardData::setEXAnalogCalc1(qreal EXAnalogCalc1) { if (m_EXAnalogCalc1 != EXAnalogCalc1) { m_EXAnalogCalc1 = EXAnalogCalc1; emit EXAnalogCalc1Changed(EXAnalogCalc1); } }
void ExpanderBoardData::setEXAnalogCalc2(qreal EXAnalogCalc2) { if (m_EXAnalogCalc2 != EXAnalogCalc2) { m_EXAnalogCalc2 = EXAnalogCalc2; emit EXAnalogCalc2Changed(EXAnalogCalc2); } }
void ExpanderBoardData::setEXAnalogCalc3(qreal EXAnalogCalc3) { if (m_EXAnalogCalc3 != EXAnalogCalc3) { m_EXAnalogCalc3 = EXAnalogCalc3; emit EXAnalogCalc3Changed(EXAnalogCalc3); } }
void ExpanderBoardData::setEXAnalogCalc4(qreal EXAnalogCalc4) { if (m_EXAnalogCalc4 != EXAnalogCalc4) { m_EXAnalogCalc4 = EXAnalogCalc4; emit EXAnalogCalc4Changed(EXAnalogCalc4); } }
void ExpanderBoardData::setEXAnalogCalc5(qreal EXAnalogCalc5) { if (m_EXAnalogCalc5 != EXAnalogCalc5) { m_EXAnalogCalc5 = EXAnalogCalc5; emit EXAnalogCalc5Changed(EXAnalogCalc5); } }
void ExpanderBoardData::setEXAnalogCalc6(qreal EXAnalogCalc6) { if (m_EXAnalogCalc6 != EXAnalogCalc6) { m_EXAnalogCalc6 = EXAnalogCalc6; emit EXAnalogCalc6Changed(EXAnalogCalc6); } }
void ExpanderBoardData::setEXAnalogCalc7(qreal EXAnalogCalc7) { if (m_EXAnalogCalc7 != EXAnalogCalc7) { m_EXAnalogCalc7 = EXAnalogCalc7; emit EXAnalogCalc7Changed(EXAnalogCalc7); } }
