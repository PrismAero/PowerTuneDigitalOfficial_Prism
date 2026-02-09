/**
 * @file PropertyRouter.cpp
 * @brief Implementation of PropertyRouter for dynamic property access
 */

#include "PropertyRouter.h"

// * Include all data models
#include "Models/EngineData.h"
#include "Models/VehicleData.h"
#include "Models/GPSData.h"
#include "Models/AnalogInputs.h"
#include "Models/DigitalInputs.h"
#include "Models/ExpanderBoardData.h"
#include "Models/ElectricMotorData.h"
#include "Models/FlagsData.h"
#include "Models/SensorData.h"
#include "Models/ConnectionData.h"
#include "Models/SettingsData.h"
#include "Models/TimingData.h"
#include "Models/UIState.h"

#include <QMetaProperty>
#include <QDebug>

PropertyRouter::PropertyRouter(
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
    QObject *parent)
    : QObject(parent)
    , m_engine(engine)
    , m_vehicle(vehicle)
    , m_gps(gps)
    , m_analog(analog)
    , m_digital(digital)
    , m_expander(expander)
    , m_motor(motor)
    , m_flags(flags)
    , m_sensor(sensor)
    , m_connection(connection)
    , m_settings(settings)
    , m_timing(timing)
    , m_ui(ui)
{
    initializePropertyMappings();
}

void PropertyRouter::initializePropertyMappings()
{
    // * Build property mappings by scanning each model's meta-object
    // * This approach uses Qt's introspection to automatically map all properties

    auto mapModelProperties = [this](QObject *model, ModelType type) {
        if (!model) return;

        const QMetaObject *metaObj = model->metaObject();
        for (int i = metaObj->propertyOffset(); i < metaObj->propertyCount(); ++i) {
            QMetaProperty prop = metaObj->property(i);
            QString propName = QString::fromLatin1(prop.name());
            // * Don't overwrite if already mapped (first model wins)
            if (!m_propertyModelMap.contains(propName)) {
                m_propertyModelMap.insert(propName, type);
            }
        }
    };

    // * Map all model properties
    mapModelProperties(m_engine, ModelType::Engine);
    mapModelProperties(m_vehicle, ModelType::Vehicle);
    mapModelProperties(m_gps, ModelType::GPS);
    mapModelProperties(m_analog, ModelType::Analog);
    mapModelProperties(m_digital, ModelType::Digital);
    mapModelProperties(m_expander, ModelType::Expander);
    mapModelProperties(m_motor, ModelType::Motor);
    mapModelProperties(m_flags, ModelType::Flags);
    mapModelProperties(m_sensor, ModelType::Sensor);
    mapModelProperties(m_connection, ModelType::Connection);
    mapModelProperties(m_settings, ModelType::Settings);
    mapModelProperties(m_timing, ModelType::Timing);
    mapModelProperties(m_ui, ModelType::UI);

    qDebug() << "PropertyRouter: Initialized with" << m_propertyModelMap.size() << "properties";
}

QVariant PropertyRouter::getValue(const QString &propertyName) const
{
    if (!m_propertyModelMap.contains(propertyName)) {
        qWarning() << "PropertyRouter: Unknown property:" << propertyName;
        return QVariant(0);
    }

    ModelType type = m_propertyModelMap.value(propertyName);
    QObject *model = nullptr;

    switch (type) {
    case ModelType::Engine:
        model = m_engine;
        break;
    case ModelType::Vehicle:
        model = m_vehicle;
        break;
    case ModelType::GPS:
        model = m_gps;
        break;
    case ModelType::Analog:
        model = m_analog;
        break;
    case ModelType::Digital:
        model = m_digital;
        break;
    case ModelType::Expander:
        model = m_expander;
        break;
    case ModelType::Motor:
        model = m_motor;
        break;
    case ModelType::Flags:
        model = m_flags;
        break;
    case ModelType::Sensor:
        model = m_sensor;
        break;
    case ModelType::Connection:
        model = m_connection;
        break;
    case ModelType::Settings:
        model = m_settings;
        break;
    case ModelType::Timing:
        model = m_timing;
        break;
    case ModelType::UI:
        model = m_ui;
        break;
    default:
        qWarning() << "PropertyRouter: No model for type";
        return QVariant(0);
    }

    if (!model) {
        qWarning() << "PropertyRouter: Model is null for property:" << propertyName;
        return QVariant(0);
    }

    return model->property(propertyName.toLatin1().constData());
}

QString PropertyRouter::getModelName(const QString &propertyName) const
{
    if (!m_propertyModelMap.contains(propertyName)) {
        return QString();
    }

    ModelType type = m_propertyModelMap.value(propertyName);

    switch (type) {
    case ModelType::Engine:
        return QStringLiteral("Engine");
    case ModelType::Vehicle:
        return QStringLiteral("Vehicle");
    case ModelType::GPS:
        return QStringLiteral("GPS");
    case ModelType::Analog:
        return QStringLiteral("Analog");
    case ModelType::Digital:
        return QStringLiteral("Digital");
    case ModelType::Expander:
        return QStringLiteral("Expander");
    case ModelType::Motor:
        return QStringLiteral("Motor");
    case ModelType::Flags:
        return QStringLiteral("Flags");
    case ModelType::Sensor:
        return QStringLiteral("Sensor");
    case ModelType::Connection:
        return QStringLiteral("Connection");
    case ModelType::Settings:
        return QStringLiteral("Settings");
    case ModelType::Timing:
        return QStringLiteral("Timing");
    case ModelType::UI:
        return QStringLiteral("UI");
    default:
        return QString();
    }
}

bool PropertyRouter::hasProperty(const QString &propertyName) const
{
    return m_propertyModelMap.contains(propertyName);
}
