/**
 * @file PropertyRouter.h
 * @brief Provides dynamic property access across all data models
 * 
 * This class serves as a bridge for QML components that need to access
 * properties dynamically by name (e.g., Dashboard[propertyName] pattern).
 * It routes property requests to the appropriate domain model.
 */

#ifndef PROPERTYROUTER_H
#define PROPERTYROUTER_H

#include <QObject>
#include <QVariant>
#include <QString>
#include <QSet>
#include <QHash>

// * Forward declarations for all data models
class EngineData;
class VehicleData;
class GPSData;
class AnalogInputs;
class DigitalInputs;
class ExpanderBoardData;
class ElectricMotorData;
class FlagsData;
class SensorData;
class ConnectionData;
class SettingsData;
class TimingData;
class UIState;

/**
 * @class PropertyRouter
 * @brief Routes dynamic property access to the appropriate data model
 * 
 * QML components that previously used Dashboard[propertyName] for dynamic
 * property binding can now use PropertyRouter.getValue(propertyName) instead.
 * This maintains backward compatibility with the dynamic access pattern while
 * directing the property lookup to the correct domain model.
 */
class PropertyRouter : public QObject
{
    Q_OBJECT

public:
    explicit PropertyRouter(
        EngineData *engine,
        VehicleData *vehicle,
        GPSData *gps,
        AnalogInputs *analog,
        DigitalInputs *digital,
        ExpanderBoardData *expander,
        ElectricMotorData *motor,
        FlagsData *flags,
        SensorData *sensor,
        ConnectionData *connection,
        SettingsData *settings,
        TimingData *timing,
        UIState *ui,
        QObject *parent = nullptr
    );

    /**
     * @brief Get a property value by name from the appropriate model
     * @param propertyName The name of the property to retrieve
     * @return The property value as QVariant, or 0 if not found
     * 
     * Usage in QML:
     *   PropertyRouter.getValue("rpm")      // Returns Engine.rpm
     *   PropertyRouter.getValue("speed")    // Returns Vehicle.speed
     *   PropertyRouter.getValue("Flag1")    // Returns Flags.Flag1
     */
    Q_INVOKABLE QVariant getValue(const QString &propertyName) const;

    /**
     * @brief Get the model name that owns a given property
     * @param propertyName The name of the property
     * @return The model name (e.g., "Engine", "Vehicle") or empty if not found
     */
    Q_INVOKABLE QString getModelName(const QString &propertyName) const;

    /**
     * @brief Check if a property exists in any model
     * @param propertyName The name of the property
     * @return true if the property exists, false otherwise
     */
    Q_INVOKABLE bool hasProperty(const QString &propertyName) const;

private:
    // * Initialize the property to model mappings
    void initializePropertyMappings();

    // * Model pointers
    EngineData *m_engine = nullptr;
    VehicleData *m_vehicle = nullptr;
    GPSData *m_gps = nullptr;
    AnalogInputs *m_analog = nullptr;
    DigitalInputs *m_digital = nullptr;
    ExpanderBoardData *m_expander = nullptr;
    ElectricMotorData *m_motor = nullptr;
    FlagsData *m_flags = nullptr;
    SensorData *m_sensor = nullptr;
    ConnectionData *m_connection = nullptr;
    SettingsData *m_settings = nullptr;
    TimingData *m_timing = nullptr;
    UIState *m_ui = nullptr;

    // * Property to model enum mapping
    enum class ModelType {
        None,
        Engine,
        Vehicle,
        GPS,
        Analog,
        Digital,
        Expander,
        Motor,
        Flags,
        Sensor,
        Connection,
        Settings,
        Timing,
        UI
    };

    // * Maps property names to their owning model
    QHash<QString, ModelType> m_propertyModelMap;
};

#endif // PROPERTYROUTER_H
