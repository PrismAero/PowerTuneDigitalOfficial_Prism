/**
 * @file AnalogInputs.cpp
 * @brief Implementation of the AnalogInputs class
 * 
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#include "AnalogInputs.h"

AnalogInputs::AnalogInputs(QObject *parent)
    : QObject(parent)
{
}

// * Setters - Raw Analog
void AnalogInputs::setAnalog0(qreal Analog0) { if (m_Analog0 != Analog0) { m_Analog0 = Analog0; emit Analog0Changed(Analog0); } }
void AnalogInputs::setAnalog1(qreal Analog1) { if (m_Analog1 != Analog1) { m_Analog1 = Analog1; emit Analog1Changed(Analog1); } }
void AnalogInputs::setAnalog2(qreal Analog2) { if (m_Analog2 != Analog2) { m_Analog2 = Analog2; emit Analog2Changed(Analog2); } }
void AnalogInputs::setAnalog3(qreal Analog3) { if (m_Analog3 != Analog3) { m_Analog3 = Analog3; emit Analog3Changed(Analog3); } }
void AnalogInputs::setAnalog4(qreal Analog4) { if (m_Analog4 != Analog4) { m_Analog4 = Analog4; emit Analog4Changed(Analog4); } }
void AnalogInputs::setAnalog5(qreal Analog5) { if (m_Analog5 != Analog5) { m_Analog5 = Analog5; emit Analog5Changed(Analog5); } }
void AnalogInputs::setAnalog6(qreal Analog6) { if (m_Analog6 != Analog6) { m_Analog6 = Analog6; emit Analog6Changed(Analog6); } }
void AnalogInputs::setAnalog7(qreal Analog7) { if (m_Analog7 != Analog7) { m_Analog7 = Analog7; emit Analog7Changed(Analog7); } }
void AnalogInputs::setAnalog8(qreal Analog8) { if (m_Analog8 != Analog8) { m_Analog8 = Analog8; emit Analog8Changed(Analog8); } }
void AnalogInputs::setAnalog9(qreal Analog9) { if (m_Analog9 != Analog9) { m_Analog9 = Analog9; emit Analog9Changed(Analog9); } }
void AnalogInputs::setAnalog10(qreal Analog10) { if (m_Analog10 != Analog10) { m_Analog10 = Analog10; emit Analog10Changed(Analog10); } }

// * Setters - Calculated Analog
void AnalogInputs::setAnalogCalc0(qreal AnalogCalc0) { if (m_AnalogCalc0 != AnalogCalc0) { m_AnalogCalc0 = AnalogCalc0; emit AnalogCalc0Changed(AnalogCalc0); } }
void AnalogInputs::setAnalogCalc1(qreal AnalogCalc1) { if (m_AnalogCalc1 != AnalogCalc1) { m_AnalogCalc1 = AnalogCalc1; emit AnalogCalc1Changed(AnalogCalc1); } }
void AnalogInputs::setAnalogCalc2(qreal AnalogCalc2) { if (m_AnalogCalc2 != AnalogCalc2) { m_AnalogCalc2 = AnalogCalc2; emit AnalogCalc2Changed(AnalogCalc2); } }
void AnalogInputs::setAnalogCalc3(qreal AnalogCalc3) { if (m_AnalogCalc3 != AnalogCalc3) { m_AnalogCalc3 = AnalogCalc3; emit AnalogCalc3Changed(AnalogCalc3); } }
void AnalogInputs::setAnalogCalc4(qreal AnalogCalc4) { if (m_AnalogCalc4 != AnalogCalc4) { m_AnalogCalc4 = AnalogCalc4; emit AnalogCalc4Changed(AnalogCalc4); } }
void AnalogInputs::setAnalogCalc5(qreal AnalogCalc5) { if (m_AnalogCalc5 != AnalogCalc5) { m_AnalogCalc5 = AnalogCalc5; emit AnalogCalc5Changed(AnalogCalc5); } }
void AnalogInputs::setAnalogCalc6(qreal AnalogCalc6) { if (m_AnalogCalc6 != AnalogCalc6) { m_AnalogCalc6 = AnalogCalc6; emit AnalogCalc6Changed(AnalogCalc6); } }
void AnalogInputs::setAnalogCalc7(qreal AnalogCalc7) { if (m_AnalogCalc7 != AnalogCalc7) { m_AnalogCalc7 = AnalogCalc7; emit AnalogCalc7Changed(AnalogCalc7); } }
void AnalogInputs::setAnalogCalc8(qreal AnalogCalc8) { if (m_AnalogCalc8 != AnalogCalc8) { m_AnalogCalc8 = AnalogCalc8; emit AnalogCalc8Changed(AnalogCalc8); } }
void AnalogInputs::setAnalogCalc9(qreal AnalogCalc9) { if (m_AnalogCalc9 != AnalogCalc9) { m_AnalogCalc9 = AnalogCalc9; emit AnalogCalc9Changed(AnalogCalc9); } }
void AnalogInputs::setAnalogCalc10(qreal AnalogCalc10) { if (m_AnalogCalc10 != AnalogCalc10) { m_AnalogCalc10 = AnalogCalc10; emit AnalogCalc10Changed(AnalogCalc10); } }

// * Setters - Legacy Sensors
void AnalogInputs::setsens1(qreal sens1) { if (m_sens1 != sens1) { m_sens1 = sens1; emit sens1Changed(sens1); } }
void AnalogInputs::setsens2(qreal sens2) { if (m_sens2 != sens2) { m_sens2 = sens2; emit sens2Changed(sens2); } }
void AnalogInputs::setsens3(qreal sens3) { if (m_sens3 != sens3) { m_sens3 = sens3; emit sens3Changed(sens3); } }
void AnalogInputs::setsens4(qreal sens4) { if (m_sens4 != sens4) { m_sens4 = sens4; emit sens4Changed(sens4); } }
void AnalogInputs::setsens5(qreal sens5) { if (m_sens5 != sens5) { m_sens5 = sens5; emit sens5Changed(sens5); } }
void AnalogInputs::setsens6(qreal sens6) { if (m_sens6 != sens6) { m_sens6 = sens6; emit sens6Changed(sens6); } }
void AnalogInputs::setsens7(qreal sens7) { if (m_sens7 != sens7) { m_sens7 = sens7; emit sens7Changed(sens7); } }
void AnalogInputs::setsens8(qreal sens8) { if (m_sens8 != sens8) { m_sens8 = sens8; emit sens8Changed(sens8); } }

// * Setters - Aux Calculations
void AnalogInputs::setauxcalc1(qreal auxcalc1) { if (m_auxcalc1 != auxcalc1) { m_auxcalc1 = auxcalc1; emit auxcalc1Changed(auxcalc1); } }
void AnalogInputs::setauxcalc2(qreal auxcalc2) { if (m_auxcalc2 != auxcalc2) { m_auxcalc2 = auxcalc2; emit auxcalc2Changed(auxcalc2); } }
void AnalogInputs::setauxcalc3(qreal auxcalc3) { if (m_auxcalc3 != auxcalc3) { m_auxcalc3 = auxcalc3; emit auxcalc3Changed(auxcalc3); } }
void AnalogInputs::setauxcalc4(qreal auxcalc4) { if (m_auxcalc4 != auxcalc4) { m_auxcalc4 = auxcalc4; emit auxcalc4Changed(auxcalc4); } }

// * Setters - User Channels
void AnalogInputs::setUserchannel1(qreal Userchannel1) { if (m_Userchannel1 != Userchannel1) { m_Userchannel1 = Userchannel1; emit Userchannel1Changed(Userchannel1); } }
void AnalogInputs::setUserchannel2(qreal Userchannel2) { if (m_Userchannel2 != Userchannel2) { m_Userchannel2 = Userchannel2; emit Userchannel2Changed(Userchannel2); } }
void AnalogInputs::setUserchannel3(qreal Userchannel3) { if (m_Userchannel3 != Userchannel3) { m_Userchannel3 = Userchannel3; emit Userchannel3Changed(Userchannel3); } }
void AnalogInputs::setUserchannel4(qreal Userchannel4) { if (m_Userchannel4 != Userchannel4) { m_Userchannel4 = Userchannel4; emit Userchannel4Changed(Userchannel4); } }
void AnalogInputs::setUserchannel5(qreal Userchannel5) { if (m_Userchannel5 != Userchannel5) { m_Userchannel5 = Userchannel5; emit Userchannel5Changed(Userchannel5); } }
void AnalogInputs::setUserchannel6(qreal Userchannel6) { if (m_Userchannel6 != Userchannel6) { m_Userchannel6 = Userchannel6; emit Userchannel6Changed(Userchannel6); } }
void AnalogInputs::setUserchannel7(qreal Userchannel7) { if (m_Userchannel7 != Userchannel7) { m_Userchannel7 = Userchannel7; emit Userchannel7Changed(Userchannel7); } }
void AnalogInputs::setUserchannel8(qreal Userchannel8) { if (m_Userchannel8 != Userchannel8) { m_Userchannel8 = Userchannel8; emit Userchannel8Changed(Userchannel8); } }
void AnalogInputs::setUserchannel9(qreal Userchannel9) { if (m_Userchannel9 != Userchannel9) { m_Userchannel9 = Userchannel9; emit Userchannel9Changed(Userchannel9); } }
void AnalogInputs::setUserchannel10(qreal Userchannel10) { if (m_Userchannel10 != Userchannel10) { m_Userchannel10 = Userchannel10; emit Userchannel10Changed(Userchannel10); } }
void AnalogInputs::setUserchannel11(qreal Userchannel11) { if (m_Userchannel11 != Userchannel11) { m_Userchannel11 = Userchannel11; emit Userchannel11Changed(Userchannel11); } }
void AnalogInputs::setUserchannel12(qreal Userchannel12) { if (m_Userchannel12 != Userchannel12) { m_Userchannel12 = Userchannel12; emit Userchannel12Changed(Userchannel12); } }
