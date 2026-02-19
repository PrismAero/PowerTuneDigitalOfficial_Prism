/**
 * @file CalibrationHelper.h
 * @brief QObject-based helper providing sensor preset data and calibration calculations to QML
 *
 * Provides linear sensor presets, NTC thermistor presets, and voltage divider
 * calculations for the EX Board analog input configuration UI. Delegates
 * Steinhart-Hart math to SteinhartCalculator.
 *
 * Copyright (c) 2026 Kai Wyborny. All rights reserved.
 */

#ifndef CALIBRATIONHELPER_H
#define CALIBRATIONHELPER_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>

class SteinhartCalculator;

/**
 * @brief Helper class exposing sensor calibration presets and calculations to QML
 *
 * This class serves as the bridge between the QML calibration UI and the
 * underlying math. It holds preset tables for common linear sensors and NTC
 * thermistors, and provides voltage divider resistance calculations for the
 * EX Board hardware.
 */
class CalibrationHelper : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief Construct a CalibrationHelper
     * @param steinhartCalc Pointer to the shared SteinhartCalculator instance
     * @param parent QObject parent for ownership
     */
    explicit CalibrationHelper(SteinhartCalculator *steinhartCalc, QObject *parent = nullptr);

    // -----------------------------------------------------------------------
    // Linear Sensor Presets
    // -----------------------------------------------------------------------

    /**
     * @brief Get all available linear sensor presets
     * @return QVariantList where each element is a QVariantMap with keys:
     *         "name" (QString), "val0v" (qreal), "val5v" (qreal), "unit" (QString)
     */
    Q_INVOKABLE QVariantList linearPresets() const;

    /**
     * @brief Look up a single linear preset by name
     * @param name The preset name to search for (case-sensitive)
     * @return QVariantMap with keys "name", "val0v", "val5v", "unit".
     *         Returns an empty map if the name is not found.
     */
    Q_INVOKABLE QVariantMap getLinearPreset(const QString &name) const;

    /**
     * @brief Calculate the display value from a raw voltage using linear interpolation
     * @param voltage Measured voltage (0-5V range)
     * @param val0v The sensor value at 0V
     * @param val5v The sensor value at 5V
     * @return Linearly interpolated sensor value
     */
    Q_INVOKABLE qreal calculateLinearValue(qreal voltage, qreal val0v, qreal val5v) const;

    /**
     * @brief Calculate a linear sensor value with automatic voltage range scaling
     *
     * Looks up the preset by name, normalizes the raw voltage from the sensor's
     * actual output range to 0-5V, then applies the standard linear interpolation.
     *
     * @param presetName The name of the linear preset to use
     * @param rawVoltage The raw measured voltage from the sensor
     * @return Scaled sensor value, or 0.0 if the preset is not found
     */
    Q_INVOKABLE double calculateLinearValueScaled(const QString &presetName, double rawVoltage);

    /**
     * @brief Normalize a raw voltage from a sensor's actual range to 0-5V
     *
     * Clamps the raw voltage to [sensorMin, sensorMax], then linearly maps it
     * to the 0-5V range. Returns 0.0 if sensorMax equals sensorMin to avoid
     * division by zero.
     *
     * @param rawVoltage The raw measured voltage
     * @param sensorMin The sensor's minimum output voltage
     * @param sensorMax The sensor's maximum output voltage
     * @return Normalized voltage in the 0-5V range
     */
    Q_INVOKABLE double normalizeVoltage(double rawVoltage, double sensorMin, double sensorMax);

    /**
     * @brief Get the minimum voltage output for a named preset
     *
     * Searches both linear and NTC preset tables. Returns 0.0 if not found.
     *
     * @param presetName The preset name to look up
     * @return Minimum voltage of the preset, or 0.0 if not found
     */
    Q_INVOKABLE double getPresetMinVoltage(const QString &presetName);

    /**
     * @brief Get the maximum voltage output for a named preset
     *
     * Searches both linear and NTC preset tables. Returns 5.0 if not found.
     *
     * @param presetName The preset name to look up
     * @return Maximum voltage of the preset, or 5.0 if not found
     */
    Q_INVOKABLE double getPresetMaxVoltage(const QString &presetName);

    /**
     * @brief Get the value-at-0V for a named linear preset
     *
     * Convenience method that returns only the val0v field from the preset.
     *
     * @param presetName The preset name to look up (case-sensitive)
     * @return The sensor value at 0V, or 0.0 if not found
     */
    Q_INVOKABLE double getLinearPresetValueAt0V(const QString &presetName) const;

    /**
     * @brief Get the value-at-5V for a named linear preset
     *
     * Convenience method that returns only the val5v field from the preset.
     *
     * @param presetName The preset name to look up (case-sensitive)
     * @return The sensor value at 5V, or 0.0 if not found
     */
    Q_INVOKABLE double getLinearPresetValueAt5V(const QString &presetName) const;

    /**
     * @brief Get the unit string for a named linear preset
     *
     * Convenience method that returns only the unit field from the preset.
     *
     * @param presetName The preset name to look up (case-sensitive)
     * @return The unit string (e.g. "kPa", "PSI"), or empty string if not found
     */
    Q_INVOKABLE QString getLinearPresetUnit(const QString &presetName) const;

    // -----------------------------------------------------------------------
    // Expander Board Helpers
    // -----------------------------------------------------------------------

    /**
     * @brief Get the CAN v2 cylinder multiplier for a given combo box index
     *
     * The EX Board CAN v2 protocol requires different multipliers depending
     * on the cylinder count selection. Most indices use 2x, except index 5
     * which uses 4x.
     *
     * @param channelIndex The combo box index (0-8)
     * @return The multiplier (2 or 4), or 1 if the index is out of range
     */
    Q_INVOKABLE int expanderChannelMultiplier(int channelIndex) const;

    /**
     * @brief Get the RPM frequency divider for a given cylinder count index
     *
     * Maps the cylinder count combo box index to the corresponding frequency
     * divider value used for RPM calculation from a digital input signal.
     *
     * Index mapping: 0->0.25, 1->0.5, 2->0.75, 3->1.0, 4->1.25,
     *                5->1.5, 6->2.0, 7->2.5, 8->3.0
     *
     * @param cylinderIndex The combo box index (0-8)
     * @return The frequency divider value, or 1.0 if the index is out of range
     */
    Q_INVOKABLE double frequencyDividerForCylinders(int cylinderIndex) const;

    // -----------------------------------------------------------------------
    // NTC Temperature Sensor Presets
    // -----------------------------------------------------------------------

    /**
     * @brief Get all available NTC thermistor presets
     * @return QVariantList where each element is a QVariantMap with keys:
     *         "name" (QString), "t1"/"r1"/"t2"/"r2"/"t3"/"r3" (qreal)
     *         Temperatures are in Celsius, resistances in Ohms.
     */
    Q_INVOKABLE QVariantList ntcPresets() const;

    /**
     * @brief Look up a single NTC preset by name
     * @param name The preset name to search for (case-sensitive)
     * @return QVariantMap with keys "name", "t1", "r1", "t2", "r2", "t3", "r3".
     *         Returns an empty map if the name is not found.
     */
    Q_INVOKABLE QVariantMap getNtcPreset(const QString &name) const;

    /**
     * @brief Calculate temperature from resistance using the Steinhart-Hart equation
     *
     * Delegates computation to SteinhartCalculator. Uses channel 0 internally
     * as a scratch channel for one-shot calculations from the UI.
     *
     * @param resistance Sensor resistance in Ohms
     * @param t1 Calibration temperature 1 (Celsius)
     * @param r1 Calibration resistance 1 (Ohms)
     * @param t2 Calibration temperature 2 (Celsius)
     * @param r2 Calibration resistance 2 (Ohms)
     * @param t3 Calibration temperature 3 (Celsius)
     * @param r3 Calibration resistance 3 (Ohms)
     * @return Temperature in Celsius, or NaN on error
     */
    Q_INVOKABLE qreal calculateTemperature(qreal resistance,
                                           qreal t1, qreal r1,
                                           qreal t2, qreal r2,
                                           qreal t3, qreal r3) const;

    // -----------------------------------------------------------------------
    // Voltage Divider Calculations
    // -----------------------------------------------------------------------

    /**
     * @brief Calculate the effective parallel resistance of the EX Board voltage divider
     *
     * The EX Board has fixed resistors: R2=1430 Ohm, R3=100 Ohm, R4=1000 Ohm.
     * Jumpers control which of R3 and R4 are in circuit.
     * The effective resistance is the parallel combination of R2 with whichever
     * of R3/R4 are enabled by jumpers.
     *
     * @param jumper100ohm true if the 100 Ohm jumper (R3) is installed
     * @param jumper1kohm true if the 1k Ohm jumper (R4) is installed
     * @return Effective parallel resistance in Ohms
     */
    Q_INVOKABLE qreal calculateDividerResistance(bool jumper100ohm, bool jumper1kohm) const;

    /**
     * @brief Calculate NTC sensor resistance from measured voltage and divider resistance
     *
     * Uses the voltage divider equation:
     *   V = Vcc * Rdivider / (Rntc + Rdivider)
     * Solved for Rntc:
     *   Rntc = Rdivider * (Vcc - V) / V
     *
     * Assumes Vcc = 5.0V.
     *
     * @param voltage Measured voltage at the divider midpoint
     * @param dividerResistance Effective parallel resistance of the divider (from calculateDividerResistance)
     * @return Calculated NTC resistance in Ohms, or 0 if voltage is out of range
     */
    Q_INVOKABLE qreal calculateNtcResistance(qreal voltage, qreal dividerResistance) const;

    /**
     * @brief Get voltage divider configuration info for a given jumper setting
     *
     * Returns a map with keys:
     *   "resistance" - effective parallel resistance (Ohms)
     *   "minResistance" - minimum measurable NTC resistance (approx)
     *   "maxResistance" - maximum measurable NTC resistance (approx)
     *   "description" - human-readable description of the configuration
     *
     * @param jumper100ohm true if the 100 Ohm jumper (R3) is installed
     * @param jumper1kohm true if the 1k Ohm jumper (R4) is installed
     * @return QVariantMap with divider configuration details
     */
    Q_INVOKABLE QVariantMap voltageDividerInfo(bool jumper100ohm, bool jumper1kohm) const;

private:
    // * Pointer to the shared SteinhartCalculator for temperature math
    SteinhartCalculator *m_steinhartCalc;

    // * Fixed EX Board resistor values (Ohms)
    static constexpr qreal BOARD_R2 = 1430.0;
    static constexpr qreal BOARD_R3 = 100.0;
    static constexpr qreal BOARD_R4 = 1000.0;

    // * Supply voltage for voltage divider calculations
    static constexpr qreal VCC = 5.0;

    /**
     * @brief Internal struct for storing linear sensor preset data
     */
    struct LinearPreset {
        QString name;
        qreal val0v;
        qreal val5v;
        QString unit;
        double minVoltage = 0.0;  ///< Actual minimum voltage output of sensor
        double maxVoltage = 5.0;  ///< Actual maximum voltage output of sensor
    };

    /**
     * @brief Internal struct for storing NTC thermistor preset data
     */
    struct NtcPreset {
        QString name;
        qreal t1;
        qreal r1;
        qreal t2;
        qreal r2;
        qreal t3;
        qreal r3;
        double minVoltage = 0.0;  ///< Actual minimum voltage output of sensor
        double maxVoltage = 5.0;  ///< Actual maximum voltage output of sensor
    };

    // * Preset data tables (populated in constructor)
    QList<LinearPreset> m_linearPresets;
    QList<NtcPreset> m_ntcPresets;

    /**
     * @brief Initialize the built-in linear sensor preset table
     */
    void initLinearPresets();

    /**
     * @brief Initialize the built-in NTC thermistor preset table
     */
    void initNtcPresets();
};

#endif // CALIBRATIONHELPER_H
