/**
 * @file dashboard.h
 * @brief Minimal DashBoard coordination class
 *
 * This class has been largely decomposed as part of the God Object refactoring.
 * All sensor/vehicle/engine data properties have been moved to domain models
 * under Core/Models/. All Steinhart-Hart calculation logic has been extracted
 * to Utils/SteinhartCalculator.
 *
 * This class remains only for:
 * - UIState coordination (setUIState)
 * - Holding pointers to service classes for lifecycle management
 *
 * QML context property "Dashboard" is still registered but all active properties
 * are accessed through the domain model context properties (Engine, Vehicle,
 * Settings, Connection, etc.)
 */

#ifndef DASHBOARD_H
#define DASHBOARD_H

#include <QObject>

// * Forward declarations
class UIState;
class SteinhartCalculator;
class SignalSmoother;

/**
 * @brief Minimal coordination shell remaining after God Object decomposition
 *
 * All Q_PROPERTYs have been moved to domain models:
 * - EngineData, VehicleData, SensorData, AnalogInputs, DigitalInputs
 * - ExpanderBoardData, ElectricMotorData, FlagsData, TimingData
 * - ConnectionData, SettingsData, GPSData, UIState
 *
 * All Steinhart-Hart logic has been moved to Utils/SteinhartCalculator.
 */
class DashBoard : public QObject
{
    Q_OBJECT

public:
    DashBoard(QObject *parent = nullptr);

    /**
     * @brief Set UIState model for facade forwarding
     * @param uiState Pointer to UIState model instance
     *
     * This enables backward compatibility by forwarding UI-related properties
     * to the dedicated UIState model. Retained for any future cross-model
     * coordination needs.
     */
    void setUIState(UIState *uiState);

private:
    // * Phase 4: UIState model pointer for facade forwarding
    UIState *m_uiState = nullptr;

    // * Phase 5: Business logic service classes
    SteinhartCalculator *m_steinhartCalc = nullptr;
    SignalSmoother *m_rpmSmoother = nullptr;
    SignalSmoother *m_speedSmoother = nullptr;
};

#endif  // DASHBOARD_H
