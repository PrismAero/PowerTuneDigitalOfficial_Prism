/**
 * @file PropertyRouter.cpp
 * @brief Implementation of PropertyRouter for dynamic property access
 *
 * Provides both snapshot-style getValue() and reactive valueChanged() signal
 * forwarding. At initialization, every Q_PROPERTY NOTIFY signal across all 13
 * domain models is connected to the onModelPropertyChanged() relay slot, which
 * uses senderSignalIndex() to identify the property and emits valueChanged().
 */

#include "PropertyRouter.h"

// * Include all data models
#include "Models/AnalogInputs.h"
#include "Models/ConnectionData.h"
#include "Models/DigitalInputs.h"
#include "Models/ElectricMotorData.h"
#include "Models/EngineData.h"
#include "Models/ExpanderBoardData.h"
#include "Models/FlagsData.h"
#include "Models/GPSData.h"
#include "Models/SensorData.h"
#include "Models/SettingsData.h"
#include "Models/TimingData.h"
#include "Models/UIState.h"
#include "Models/VehicleData.h"

#include <QDebug>
#include <QMetaMethod>
#include <QMetaProperty>

#include <algorithm>

PropertyRouter::PropertyRouter(EngineData *engine, VehicleData *vehicle, GPSData *gps, AnalogInputs *analog,
                               DigitalInputs *digital, ExpanderBoardData *expander, ElectricMotorData *motor,
                               FlagsData *flags, SensorData *sensor, ConnectionData *connection, SettingsData *settings,
                               TimingData *timing, UIState *ui, QObject *parent)
    : QObject(parent),
      m_engine(engine),
      m_vehicle(vehicle),
      m_gps(gps),
      m_analog(analog),
      m_digital(digital),
      m_expander(expander),
      m_motor(motor),
      m_flags(flags),
      m_sensor(sensor),
      m_connection(connection),
      m_settings(settings),
      m_timing(timing),
      m_ui(ui)
{
    initializePropertyMappings();
}

void PropertyRouter::initializePropertyMappings()
{
    // * Build property mappings by scanning each model's meta-object
    // * This approach uses Qt's introspection to automatically map all properties

    auto mapModelProperties = [this](QObject *model, ModelType type) {
        if (!model)
            return;

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

    // * Connect all model NOTIFY signals to our relay slot for reactive binding
    connectModelSignals(m_engine);
    connectModelSignals(m_vehicle);
    connectModelSignals(m_gps);
    connectModelSignals(m_analog);
    connectModelSignals(m_digital);
    connectModelSignals(m_expander);
    connectModelSignals(m_motor);
    connectModelSignals(m_flags);
    connectModelSignals(m_sensor);
    connectModelSignals(m_connection);
    connectModelSignals(m_settings);
    connectModelSignals(m_timing);
    connectModelSignals(m_ui);

    int signalCount = 0;
    for (auto it = m_signalToPropertyMap.constBegin(); it != m_signalToPropertyMap.constEnd(); ++it) {
        signalCount += it.value().size();
    }
    qDebug() << "PropertyRouter: Connected" << signalCount << "NOTIFY signals for reactive binding";
}

void PropertyRouter::connectModelSignals(QObject *model)
{
    if (!model)
        return;

    const QMetaObject *meta = model->metaObject();

    // * Resolve our relay slot once for all connections from this model
    const QMetaMethod relaySlot = metaObject()->method(metaObject()->indexOfSlot("onModelPropertyChanged()"));

    for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
        QMetaProperty prop = meta->property(i);
        if (!prop.hasNotifySignal())
            continue;

        QString propName = QString::fromLatin1(prop.name());
        // * Only connect properties that are in our property map (first-model-wins rule)
        if (!m_propertyModelMap.contains(propName))
            continue;

        QMetaMethod notifySignal = prop.notifySignal();
        int signalIndex = notifySignal.methodIndex();

        // * Record the mapping: (model, signalIndex) -> (propertyName, propertyIndex)
        m_signalToPropertyMap[model][signalIndex] = SignalPropertyInfo{propName, i};

        // * Connect the model's NOTIFY signal to our relay slot
        QObject::connect(model, notifySignal, this, relaySlot);
    }
}

void PropertyRouter::onModelPropertyChanged()
{
    QObject *model = sender();
    if (!model)
        return;

    int signalIdx = senderSignalIndex();
    if (signalIdx < 0)
        return;

    auto modelIt = m_signalToPropertyMap.constFind(model);
    if (modelIt == m_signalToPropertyMap.constEnd())
        return;

    auto propIt = modelIt->constFind(signalIdx);
    if (propIt == modelIt->constEnd())
        return;

    const SignalPropertyInfo &info = propIt.value();
    QVariant val = model->metaObject()->property(info.propertyIndex).read(model);
    emit valueChanged(info.propertyName, val);

    const QStringList aliases = m_reverseAliases.value(info.propertyName);
    for (const QString &aliasKey : aliases)
        emit valueChanged(aliasKey, val);
}

QVariant PropertyRouter::getValue(const QString &propertyName) const
{
    const QString resolvedProperty = resolveAlias(propertyName);
    if (!m_propertyModelMap.contains(resolvedProperty)) {
        qWarning() << "PropertyRouter: Unknown property:" << propertyName;
        return QVariant(0);
    }

    ModelType type = m_propertyModelMap.value(resolvedProperty);
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

    QVariant val = model->property(resolvedProperty.toLatin1().constData());
    if (!val.isValid())
        return QVariant(0);
    return val;
}

QString PropertyRouter::getModelName(const QString &propertyName) const
{
    const QString resolvedProperty = resolveAlias(propertyName);
    if (!m_propertyModelMap.contains(resolvedProperty)) {
        return QString();
    }

    ModelType type = m_propertyModelMap.value(resolvedProperty);

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
    return m_propertyModelMap.contains(resolveAlias(propertyName));
}

QStringList PropertyRouter::availableProperties() const
{
    QStringList properties = m_propertyModelMap.keys();
    properties.append(m_aliases.keys());
    properties.removeDuplicates();
    properties.sort(Qt::CaseInsensitive);
    return properties;
}

void PropertyRouter::aliasProperty(const QString &sourceKey, const QString &aliasKey)
{
    if (sourceKey.isEmpty() || aliasKey.isEmpty() || sourceKey == aliasKey)
        return;

    if (!m_propertyModelMap.contains(sourceKey)) {
        qWarning() << "PropertyRouter: Cannot alias unknown source property:" << sourceKey;
        return;
    }

    removeAlias(aliasKey);

    m_aliases.insert(aliasKey, sourceKey);
    QStringList &aliases = m_reverseAliases[sourceKey];
    if (!aliases.contains(aliasKey))
        aliases.append(aliasKey);
}

void PropertyRouter::removeAlias(const QString &aliasKey)
{
    const auto it = m_aliases.find(aliasKey);
    if (it == m_aliases.end())
        return;

    const QString sourceKey = it.value();
    m_aliases.erase(it);

    auto reverseIt = m_reverseAliases.find(sourceKey);
    if (reverseIt != m_reverseAliases.end()) {
        reverseIt->removeAll(aliasKey);
        if (reverseIt->isEmpty())
            m_reverseAliases.erase(reverseIt);
    }
}

bool PropertyRouter::isAlias(const QString &key) const
{
    return m_aliases.contains(key);
}

QString PropertyRouter::resolveAlias(const QString &key) const
{
    return m_aliases.value(key, key);
}
