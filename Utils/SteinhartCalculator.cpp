/**
 * @file SteinhartCalculator.cpp
 * @brief Implementation of Steinhart-Hart equation calculator
 *
 * Phase 5: Extracted from DashBoard God Object for better separation of concerns.
 */

#include "SteinhartCalculator.h"
#include <QDebug>
#include <cmath>

SteinhartCalculator::SteinhartCalculator(QObject *parent)
    : QObject(parent)
{
    // * Initialize all channels as disabled and uncalibrated
    for (int i = 0; i < MAX_CHANNELS; ++i) {
        m_coefficients[i] = SteinhartCoefficients();
        m_channelEnabled[i] = false;
        m_r3Values[i] = 0;
        m_r4Values[i] = 0;
        m_totalResistance[i] = 0;
    }
}

void SteinhartCalculator::calibrateChannel(int channel, qreal T1, qreal T2, qreal T3,
                                           qreal R1, qreal R2, qreal R3)
{
    if (channel < 0 || channel >= MAX_CHANNELS) {
        qWarning() << "SteinhartCalculator: Invalid channel" << channel;
        return;
    }

    // * Calculate logarithms of resistances
    long double L1 = std::log(static_cast<long double>(R1));
    long double L2 = std::log(static_cast<long double>(R2));
    long double L3 = std::log(static_cast<long double>(R3));

    // * Convert temperatures from Celsius to Kelvin and get reciprocals
    long double Y1 = 1.0L / (static_cast<long double>(T1) + 273.15L);
    long double Y2 = 1.0L / (static_cast<long double>(T2) + 273.15L);
    long double Y3 = 1.0L / (static_cast<long double>(T3) + 273.15L);

    // * Calculate intermediate coefficients
    long double V2 = (Y2 - Y1) / (L2 - L1);
    long double V3 = (Y3 - Y1) / (L3 - L1);

    // * Calculate Steinhart-Hart coefficients A, B, C
    // ! Note: Original code had (L1 + L2 + L2) which appears to be a typo for (L1 + L2 + L3)
    // ! Preserving original behavior for backward compatibility
    long double C = ((V3 - V2) / (L3 - L2)) * std::pow((L1 + L2 + L2), -1);
    long double B = V3 - C * (std::pow(L1, 2) + L1 * L2 + std::pow(L2, 2));
    long double A = Y1 - (B + std::pow(L1, 2) * C) * L1;

    m_coefficients[channel].A = A;
    m_coefficients[channel].B = B;
    m_coefficients[channel].C = C;
    m_coefficients[channel].isCalibrated = true;

    qDebug() << "SteinhartCalculator: Channel" << channel << "calibrated with A=" << static_cast<double>(A) << "B=" << static_cast<double>(B) << "C=" << static_cast<double>(C);
}

void SteinhartCalculator::setVoltageDividerParams(int channel, qreal r3Value, qreal r4Value)
{
    if (channel < 0 || channel >= MAX_CHANNELS) {
        qWarning() << "SteinhartCalculator: Invalid channel" << channel;
        return;
    }

    m_r3Values[channel] = r3Value;
    m_r4Values[channel] = r4Value;

    // * Calculate total parallel resistance of voltage divider
    // * Formula: 1/Rtotal = 1/R2 + 1/R3 + 1/R4 (when R3 and R4 are present)
    if (r3Value > 0 && r4Value > 0) {
        m_totalResistance[channel] = 1.0 / ((1.0 / R2_FIXED) + (1.0 / r3Value) + (1.0 / r4Value));
    } else if (r3Value > 0) {
        m_totalResistance[channel] = 1.0 / ((1.0 / R2_FIXED) + (1.0 / r3Value));
    } else if (r4Value > 0) {
        m_totalResistance[channel] = 1.0 / ((1.0 / R2_FIXED) + (1.0 / r4Value));
    } else {
        m_totalResistance[channel] = R2_FIXED;
    }
}

qreal SteinhartCalculator::calculateTotalResistance(int channel) const
{
    if (channel < 0 || channel >= MAX_CHANNELS) {
        return 0;
    }
    return m_totalResistance[channel];
}

qreal SteinhartCalculator::calculateSensorResistance(int channel, qreal voltage, qreal supplyVoltage) const
{
    if (channel < 0 || channel >= MAX_CHANNELS) {
        return 0;
    }

    if (voltage <= 0 || voltage >= supplyVoltage) {
        return 0;  // Invalid reading
    }

    qreal Rtotal = m_totalResistance[channel];
    if (Rtotal <= 0) {
        Rtotal = R2_FIXED;  // Fallback to default
    }

    // * Calculate sensor resistance from voltage divider equation
    // * Vsensor = Vcc * Rsensor / (Rtotal + Rsensor)
    // * Solving for Rsensor: Rsensor = Rtotal * (Vcc - Vsensor) / Vsensor
    qreal resistance = (Rtotal * (supplyVoltage - voltage)) / voltage;

    return resistance;
}

qreal SteinhartCalculator::resistanceToTemperature(int channel, qreal resistance) const
{
    if (channel < 0 || channel >= MAX_CHANNELS) {
        return std::nan("");
    }

    if (!m_coefficients[channel].isCalibrated) {
        qWarning() << "SteinhartCalculator: Channel" << channel << "not calibrated";
        return std::nan("");
    }

    if (resistance <= 0) {
        return std::nan("");
    }

    const auto& coeff = m_coefficients[channel];

    // * Steinhart-Hart equation: 1/T = A + B*ln(R) + C*ln(R)^3
    // * T is in Kelvin, we return Celsius
    long double lnR = std::log(static_cast<long double>(resistance));
    long double tempK = 1.0L / (coeff.A + (coeff.B * lnR) + coeff.C * std::pow(lnR, 3));

    // * Convert from Kelvin to Celsius
    return static_cast<qreal>(tempK - 273.15L);
}

qreal SteinhartCalculator::voltageToTemperature(int channel, qreal voltage, qreal supplyVoltage) const
{
    qreal resistance = calculateSensorResistance(channel, voltage, supplyVoltage);
    if (resistance <= 0) {
        return std::nan("");
    }
    return resistanceToTemperature(channel, resistance);
}

bool SteinhartCalculator::isChannelCalibrated(int channel) const
{
    if (channel < 0 || channel >= MAX_CHANNELS) {
        return false;
    }
    return m_coefficients[channel].isCalibrated;
}

void SteinhartCalculator::setChannelEnabled(int channel, bool enabled)
{
    if (channel < 0 || channel >= MAX_CHANNELS) {
        return;
    }
    m_channelEnabled[channel] = enabled;
}

bool SteinhartCalculator::isChannelEnabled(int channel) const
{
    if (channel < 0 || channel >= MAX_CHANNELS) {
        return false;
    }
    return m_channelEnabled[channel];
}

SteinhartCoefficients SteinhartCalculator::getCoefficients(int channel) const
{
    if (channel < 0 || channel >= MAX_CHANNELS) {
        return SteinhartCoefficients();
    }
    return m_coefficients[channel];
}
