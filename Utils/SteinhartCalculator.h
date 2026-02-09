/**
 * @file SteinhartCalculator.h
 * @brief Steinhart-Hart equation calculator for NTC thermistor temperature conversion
 *
 * The Steinhart-Hart equation provides accurate temperature conversion from
 * thermistor resistance values. This class calculates the A, B, C coefficients
 * from three calibration points (temperature + resistance pairs) and then
 * converts resistance readings to temperature.
 *
 * Phase 5: Extracted from DashBoard God Object for better separation of concerns.
 */

#ifndef STEINHARTCALCULATOR_H
#define STEINHARTCALCULATOR_H

#include <QObject>
#include <cmath>

/**
 * @brief Steinhart-Hart coefficients for a single thermistor channel
 */
struct SteinhartCoefficients {
    long double A = 0.0;
    long double B = 0.0;
    long double C = 0.0;
    bool isCalibrated = false;
};

/**
 * @brief Calculator for Steinhart-Hart thermistor temperature conversion
 *
 * Supports up to 6 independent analog input channels, each with their own
 * calibration coefficients and voltage divider circuit parameters.
 */
class SteinhartCalculator : public QObject
{
    Q_OBJECT

public:
    static constexpr int MAX_CHANNELS = 6;

    explicit SteinhartCalculator(QObject *parent = nullptr);

    /**
     * @brief Calculate Steinhart-Hart coefficients from three calibration points
     * @param channel Channel index (0-5)
     * @param T1 Temperature 1 in Celsius
     * @param T2 Temperature 2 in Celsius
     * @param T3 Temperature 3 in Celsius
     * @param R1 Resistance 1 in Ohms at T1
     * @param R2 Resistance 2 in Ohms at T2
     * @param R3 Resistance 3 in Ohms at T3
     */
    void calibrateChannel(int channel, qreal T1, qreal T2, qreal T3,
                          qreal R1, qreal R2, qreal R3);

    /**
     * @brief Set voltage divider circuit parameters for a channel
     * @param channel Channel index (0-5)
     * @param r3Value R3 resistor value (0 = not installed)
     * @param r4Value R4 resistor value (0 = not installed)
     */
    void setVoltageDividerParams(int channel, qreal r3Value, qreal r4Value);

    /**
     * @brief Calculate the total parallel resistance for a channel's voltage divider
     * @param channel Channel index (0-5)
     * @return Total parallel resistance in Ohms
     */
    qreal calculateTotalResistance(int channel) const;

    /**
     * @brief Convert analog voltage to temperature using Steinhart-Hart equation
     * @param channel Channel index (0-5)
     * @param voltage Measured voltage from ADC
     * @param supplyVoltage Supply voltage (default 5V)
     * @return Temperature in Celsius, or NaN if channel not calibrated
     */
    qreal voltageToTemperature(int channel, qreal voltage, qreal supplyVoltage = 5.0) const;

    /**
     * @brief Calculate sensor resistance from voltage divider reading
     * @param channel Channel index (0-5)
     * @param voltage Measured voltage
     * @param supplyVoltage Supply voltage (default 5V)
     * @return Calculated sensor resistance in Ohms
     */
    qreal calculateSensorResistance(int channel, qreal voltage, qreal supplyVoltage = 5.0) const;

    /**
     * @brief Convert resistance to temperature using Steinhart-Hart equation
     * @param channel Channel index (0-5)
     * @param resistance Sensor resistance in Ohms
     * @return Temperature in Celsius, or NaN if channel not calibrated
     */
    qreal resistanceToTemperature(int channel, qreal resistance) const;

    /**
     * @brief Check if a channel has been calibrated
     * @param channel Channel index (0-5)
     * @return true if calibrated with valid coefficients
     */
    bool isChannelCalibrated(int channel) const;

    /**
     * @brief Enable/disable Steinhart-Hart calculation for a channel
     * @param channel Channel index (0-5)
     * @param enabled true to use Steinhart-Hart, false for linear interpolation
     */
    void setChannelEnabled(int channel, bool enabled);

    /**
     * @brief Check if Steinhart-Hart is enabled for a channel
     * @param channel Channel index (0-5)
     * @return true if Steinhart-Hart mode is enabled
     */
    bool isChannelEnabled(int channel) const;

    /**
     * @brief Get the coefficients for a channel (for debugging/display)
     * @param channel Channel index (0-5)
     * @return SteinhartCoefficients struct
     */
    SteinhartCoefficients getCoefficients(int channel) const;

private:
    // * Fixed resistor values for the voltage divider circuit
    static constexpr qreal R2_FIXED = 1430.0;  // Two resistors in line: 1100 + 330 Ohms
    static constexpr qreal R3_DEFAULT = 100.0;
    static constexpr qreal R4_DEFAULT = 1000.0;

    SteinhartCoefficients m_coefficients[MAX_CHANNELS];
    bool m_channelEnabled[MAX_CHANNELS] = {false};

    // * Per-channel voltage divider parameters
    qreal m_r3Values[MAX_CHANNELS] = {0};
    qreal m_r4Values[MAX_CHANNELS] = {0};
    qreal m_totalResistance[MAX_CHANNELS] = {0};
};

#endif // STEINHARTCALCULATOR_H
