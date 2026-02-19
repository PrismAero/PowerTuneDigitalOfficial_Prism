/**
 * @file CalibrationHelper.cpp
 * @brief Implementation of CalibrationHelper - sensor preset data and calibration calculations
 *
 * Provides QML-accessible methods for linear sensor presets, NTC thermistor
 * presets, voltage divider calculations, and Steinhart-Hart temperature
 * conversion via delegation to SteinhartCalculator.
 */

#include "CalibrationHelper.h"
#include "SteinhartCalculator.h"
#include <QDebug>
#include <cmath>

CalibrationHelper::CalibrationHelper(SteinhartCalculator *steinhartCalc, QObject *parent)
    : QObject(parent)
    , m_steinhartCalc(steinhartCalc)
{
    initLinearPresets();
    initNtcPresets();
}

// ---------------------------------------------------------------------------
// Linear Sensor Presets
// ---------------------------------------------------------------------------

/**
 * @brief Populate the built-in linear sensor preset table
 *
 * Each preset defines a sensor's output range mapped to 0-5V input.
 * The "Custom" preset defaults to raw voltage passthrough.
 */
void CalibrationHelper::initLinearPresets()
{
    m_linearPresets = {
        {QStringLiteral("Custom"),                0,   5,   QStringLiteral("V")},
        {QStringLiteral("0-100 PSI Pressure"),    0,   100, QStringLiteral("PSI")},
        {QStringLiteral("0-150 PSI Pressure"),    0,   150, QStringLiteral("PSI")},
        {QStringLiteral("0-200 PSI Pressure"),    0,   200, QStringLiteral("PSI")},
        {QStringLiteral("0-5 Bar Pressure"),      0,   5,   QStringLiteral("Bar")},
        {QStringLiteral("0-10 Bar Pressure"),     0,   10,  QStringLiteral("Bar")},
        {QStringLiteral("0-100% Wideband O2"),    0,   100, QStringLiteral("%")},
        {QStringLiteral("0-1V Narrowband O2"),    0,   1,   QStringLiteral("V")},
        {QStringLiteral("GM 1-Bar MAP"),          10,  105, QStringLiteral("kPa")},
        {QStringLiteral("GM 2-Bar MAP"),          10,  210, QStringLiteral("kPa")},
        {QStringLiteral("GM 3-Bar MAP"),          10,  315, QStringLiteral("kPa")},
        {QStringLiteral("AEM 3.5 Bar MAP"),       0,   350, QStringLiteral("kPa")},
    };
}

/**
 * @brief Populate the built-in NTC thermistor preset table
 *
 * Each preset provides three calibration points (temperature in Celsius,
 * resistance in Ohms) for Steinhart-Hart coefficient calculation.
 */
void CalibrationHelper::initNtcPresets()
{
    m_ntcPresets = {
        {QStringLiteral("Custom"),                    5,    2000,    25,   4000,   45,    7000},
        {QStringLiteral("10K NTC (B=3950)"),         -20,   97070,   25,   10000,  100,   680},
        {QStringLiteral("2.2K NTC"),                 -20,   21370,   25,   2200,   100,   150},
        {QStringLiteral("Bosch NTC (0280130039)"),   -10,   9397,    25,   2500,   80,    323},
        {QStringLiteral("GM Coolant Temp"),          -40,   100700,  25,   2238,   120,   72},
        {QStringLiteral("AEM 30-2012 Water Temp"),    0,    5896,    50,   811,    100,   177},
    };
}

/**
 * @brief Return all linear presets as a QVariantList for QML consumption
 * @return List of QVariantMap objects with keys: name, val0v, val5v, unit
 */
QVariantList CalibrationHelper::linearPresets() const
{
    QVariantList result;
    result.reserve(m_linearPresets.size());
    for (const auto &p : m_linearPresets) {
        QVariantMap map;
        map[QStringLiteral("name")]  = p.name;
        map[QStringLiteral("val0v")] = p.val0v;
        map[QStringLiteral("val5v")] = p.val5v;
        map[QStringLiteral("unit")]  = p.unit;
        result.append(map);
    }
    return result;
}

/**
 * @brief Look up a linear preset by name
 * @param name Preset name (case-sensitive)
 * @return QVariantMap with preset data, or empty map if not found
 */
QVariantMap CalibrationHelper::getLinearPreset(const QString &name) const
{
    for (const auto &p : m_linearPresets) {
        if (p.name == name) {
            QVariantMap map;
            map[QStringLiteral("name")]  = p.name;
            map[QStringLiteral("val0v")] = p.val0v;
            map[QStringLiteral("val5v")] = p.val5v;
            map[QStringLiteral("unit")]  = p.unit;
            return map;
        }
    }
    qWarning() << "CalibrationHelper: Linear preset not found:" << name;
    return {};
}

/**
 * @brief Linearly interpolate a sensor value from raw voltage
 *
 * Maps voltage in the 0-5V range to the sensor value range [val0v, val5v].
 * Formula: value = val0v + (voltage / 5.0) * (val5v - val0v)
 *
 * @param voltage Measured voltage (0-5V)
 * @param val0v Sensor value at 0V
 * @param val5v Sensor value at 5V
 * @return Interpolated sensor value
 */
qreal CalibrationHelper::calculateLinearValue(qreal voltage, qreal val0v, qreal val5v) const
{
    return val0v + (voltage / VCC) * (val5v - val0v);
}

// ---------------------------------------------------------------------------
// NTC Temperature Sensor Presets
// ---------------------------------------------------------------------------

/**
 * @brief Return all NTC presets as a QVariantList for QML consumption
 * @return List of QVariantMap objects with keys: name, t1, r1, t2, r2, t3, r3
 */
QVariantList CalibrationHelper::ntcPresets() const
{
    QVariantList result;
    result.reserve(m_ntcPresets.size());
    for (const auto &p : m_ntcPresets) {
        QVariantMap map;
        map[QStringLiteral("name")] = p.name;
        map[QStringLiteral("t1")]   = p.t1;
        map[QStringLiteral("r1")]   = p.r1;
        map[QStringLiteral("t2")]   = p.t2;
        map[QStringLiteral("r2")]   = p.r2;
        map[QStringLiteral("t3")]   = p.t3;
        map[QStringLiteral("r3")]   = p.r3;
        result.append(map);
    }
    return result;
}

/**
 * @brief Look up an NTC preset by name
 * @param name Preset name (case-sensitive)
 * @return QVariantMap with preset data, or empty map if not found
 */
QVariantMap CalibrationHelper::getNtcPreset(const QString &name) const
{
    for (const auto &p : m_ntcPresets) {
        if (p.name == name) {
            QVariantMap map;
            map[QStringLiteral("name")] = p.name;
            map[QStringLiteral("t1")]   = p.t1;
            map[QStringLiteral("r1")]   = p.r1;
            map[QStringLiteral("t2")]   = p.t2;
            map[QStringLiteral("r2")]   = p.r2;
            map[QStringLiteral("t3")]   = p.t3;
            map[QStringLiteral("r3")]   = p.r3;
            return map;
        }
    }
    qWarning() << "CalibrationHelper: NTC preset not found:" << name;
    return {};
}

/**
 * @brief Calculate temperature from resistance using Steinhart-Hart equation
 *
 * Calibrates channel 0 of the SteinhartCalculator with the provided three-point
 * data, then converts the given resistance to temperature. This is a one-shot
 * calculation intended for UI preview; persistent channel calibration should use
 * SteinhartCalculator directly.
 *
 * @param resistance Sensor resistance in Ohms
 * @param t1 Temperature point 1 (Celsius)
 * @param r1 Resistance at t1 (Ohms)
 * @param t2 Temperature point 2 (Celsius)
 * @param r2 Resistance at t2 (Ohms)
 * @param t3 Temperature point 3 (Celsius)
 * @param r3 Resistance at t3 (Ohms)
 * @return Temperature in Celsius, NaN on error
 */
qreal CalibrationHelper::calculateTemperature(qreal resistance,
                                              qreal t1, qreal r1,
                                              qreal t2, qreal r2,
                                              qreal t3, qreal r3) const
{
    if (!m_steinhartCalc) {
        qWarning() << "CalibrationHelper: No SteinhartCalculator available";
        return std::nan("");
    }

    // * Calibrate scratch channel 0 with the provided points
    m_steinhartCalc->calibrateChannel(0, t1, t2, t3, r1, r2, r3);

    // * Convert resistance to temperature
    return m_steinhartCalc->resistanceToTemperature(0, resistance);
}

// ---------------------------------------------------------------------------
// Voltage Divider Calculations
// ---------------------------------------------------------------------------

/**
 * @brief Calculate effective parallel resistance of the EX Board voltage divider
 *
 * The board has three fixed resistors:
 *   R2 = 1430 Ohm (always in circuit)
 *   R3 = 100 Ohm  (connected when jumper100ohm is installed)
 *   R4 = 1000 Ohm (connected when jumper1kohm is installed)
 *
 * The effective resistance is the parallel combination:
 *   1/Reff = 1/R2 [+ 1/R3] [+ 1/R4]
 *
 * @param jumper100ohm true if the 100 Ohm jumper is installed
 * @param jumper1kohm true if the 1k Ohm jumper is installed
 * @return Effective parallel resistance in Ohms
 */
qreal CalibrationHelper::calculateDividerResistance(bool jumper100ohm, bool jumper1kohm) const
{
    qreal reciprocal = 1.0 / BOARD_R2;

    if (jumper100ohm) {
        reciprocal += 1.0 / BOARD_R3;
    }
    if (jumper1kohm) {
        reciprocal += 1.0 / BOARD_R4;
    }

    return 1.0 / reciprocal;
}

/**
 * @brief Calculate NTC resistance from measured voltage and known divider resistance
 *
 * Voltage divider equation solved for the NTC (upper) resistance:
 *   V = Vcc * Rdiv / (Rntc + Rdiv)
 *   Rntc = Rdiv * (Vcc - V) / V
 *
 * @param voltage Measured voltage at the divider midpoint (0 < V < Vcc)
 * @param dividerResistance Effective parallel resistance of the fixed divider
 * @return NTC resistance in Ohms, or 0 if voltage is out of valid range
 */
qreal CalibrationHelper::calculateNtcResistance(qreal voltage, qreal dividerResistance) const
{
    if (voltage <= 0.0 || voltage >= VCC) {
        return 0.0;
    }
    if (dividerResistance <= 0.0) {
        return 0.0;
    }

    return dividerResistance * (VCC - voltage) / voltage;
}

/**
 * @brief Get detailed voltage divider configuration info for a jumper setting
 *
 * Returns a map containing:
 *   "resistance"     - effective parallel resistance (Ohms)
 *   "minResistance"  - approximate minimum measurable NTC resistance
 *   "maxResistance"  - approximate maximum measurable NTC resistance
 *   "description"    - human-readable summary
 *
 * Min/max resistance are estimated from voltage thresholds of 0.1V and 4.9V
 * which represent practical ADC limits.
 *
 * @param jumper100ohm true if the 100 Ohm jumper is installed
 * @param jumper1kohm true if the 1k Ohm jumper is installed
 * @return QVariantMap with divider info
 */
QVariantMap CalibrationHelper::voltageDividerInfo(bool jumper100ohm, bool jumper1kohm) const
{
    qreal resistance = calculateDividerResistance(jumper100ohm, jumper1kohm);

    // * Estimate measurable NTC range from practical ADC voltage limits
    // * At V=0.1V (near ground): Rntc = Rdiv * (5.0 - 0.1) / 0.1 = Rdiv * 49
    // * At V=4.9V (near Vcc):    Rntc = Rdiv * (5.0 - 4.9) / 4.9 = Rdiv * 0.0204
    constexpr qreal V_LOW  = 0.1;
    constexpr qreal V_HIGH = 4.9;
    qreal maxR = resistance * (VCC - V_LOW) / V_LOW;
    qreal minR = resistance * (VCC - V_HIGH) / V_HIGH;

    // * Build human-readable description
    QString desc;
    if (jumper100ohm && jumper1kohm) {
        desc = QStringLiteral("R2(1430) || R3(100) || R4(1000) - Low resistance NTC sensors");
    } else if (jumper100ohm) {
        desc = QStringLiteral("R2(1430) || R3(100) - Very low resistance NTC sensors");
    } else if (jumper1kohm) {
        desc = QStringLiteral("R2(1430) || R4(1000) - Medium resistance NTC sensors");
    } else {
        desc = QStringLiteral("R2(1430) only - High resistance NTC sensors");
    }

    QVariantMap info;
    info[QStringLiteral("resistance")]    = resistance;
    info[QStringLiteral("minResistance")] = minR;
    info[QStringLiteral("maxResistance")] = maxR;
    info[QStringLiteral("description")]   = desc;
    return info;
}
