/**
 * @file PropertyRouter.h
 * @brief Provides dynamic property access across all data models
 *
 * This class serves as a bridge for QML components that need to access
 * properties dynamically by name (e.g., Dashboard[propertyName] pattern).
 * It routes property requests to the appropriate domain model.
 *
 * Reactive binding: The valueChanged() signal fires whenever any model
 * property with a NOTIFY signal changes. QML overlays use a Connections
 * block to filter by property name and update their local value cache.
 */

#ifndef PROPERTYROUTER_H
#define PROPERTYROUTER_H

#include <QHash>
#include <QMetaProperty>
#include <QObject>
#include <QSet>
#include <QString>
#include <QStringList>
#include <QVariant>

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
 *
 * For reactive (auto-updating) bindings, QML components should use:
 * @code
 * Connections {
 *     target: PropertyRouter
 *     function onValueChanged(propertyName, value) {
 *         if (propertyName === overlay.datasource)
 *             overlay.currentValue = value
 *     }
 * }
 * @endcode
 */
class PropertyRouter : public QObject
{
    Q_OBJECT

public:
    explicit PropertyRouter(EngineData *engine, VehicleData *vehicle, GPSData *gps, AnalogInputs *analog,
                            DigitalInputs *digital, ExpanderBoardData *expander, ElectricMotorData *motor,
                            FlagsData *flags, SensorData *sensor, ConnectionData *connection, SettingsData *settings,
                            TimingData *timing, UIState *ui, QObject *parent = nullptr);

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

    /**
     * @brief Get the sorted list of all available property names
     * @return QStringList of property names across all domain models
     *
     * Useful for sensor picker dropdowns in overlay configuration UI.
     */
    Q_INVOKABLE QStringList availableProperties() const;
    Q_INVOKABLE void aliasProperty(const QString &sourceKey, const QString &aliasKey);
    Q_INVOKABLE void removeAlias(const QString &aliasKey);
    Q_INVOKABLE bool isAlias(const QString &key) const;
    Q_INVOKABLE QString resolveAlias(const QString &key) const;

signals:
    /**
     * @brief Emitted when any model property with a NOTIFY signal changes
     * @param propertyName The name of the property that changed
     * @param value The new value of the property
     *
     * This signal enables reactive QML bindings. Each model's Q_PROPERTY
     * NOTIFY signals are forwarded through this single signal, allowing
     * QML Connections blocks to filter by property name.
     */
    void valueChanged(const QString &propertyName, const QVariant &value);

private slots:
    /**
     * @brief Relay slot invoked by all connected model NOTIFY signals
     *
     * Uses QObject::senderSignalIndex() to identify which property changed,
     * reads the current value, and emits valueChanged().
     */
    void onModelPropertyChanged();

private:
    // * Initialize the property to model mappings
    void initializePropertyMappings();

    /**
     * @brief Connect all NOTIFY signals from a model to onModelPropertyChanged()
     * @param model The model QObject whose properties to connect
     *
     * For each Q_PROPERTY with a NOTIFY signal, connects the signal to our
     * relay slot and records the (model pointer, signal index) -> property name
     * mapping so onModelPropertyChanged() can identify which property fired.
     */
    void connectModelSignals(QObject *model);

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
    QHash<QString, QString> m_aliases;             // aliasKey -> sourceKey
    QHash<QString, QStringList> m_reverseAliases;  // sourceKey -> alias keys

    /**
     * @struct SignalPropertyInfo
     * @brief Holds the property name and index for a connected NOTIFY signal
     */
    struct SignalPropertyInfo
    {
        QString propertyName;
        int propertyIndex;
    };

    /**
     * Maps (model pointer, NOTIFY signal method index) -> property info.
     * Used by onModelPropertyChanged() to look up which property changed.
     */
    QHash<QObject *, QHash<int, SignalPropertyInfo>> m_signalToPropertyMap;
};

#endif  // PROPERTYROUTER_H
