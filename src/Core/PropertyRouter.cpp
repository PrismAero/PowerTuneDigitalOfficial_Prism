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
#include "Models/EngineData.h"
#include "Models/ExpanderBoardData.h"
#include "Models/GPSData.h"
#include "Models/SettingsData.h"
#include "Models/TimingData.h"
#include "Models/UIState.h"
#include "Models/VehicleData.h"
#include "SensorRegistry.h"

#include <QDebug>
#include <QMetaMethod>
#include <QMetaProperty>

#include <algorithm>

PropertyRouter::PropertyRouter(EngineData *engine, VehicleData *vehicle, GPSData *gps, AnalogInputs *analog,
                               DigitalInputs *digital, ExpanderBoardData *expander, ConnectionData *connection,
                               SettingsData *settings, TimingData *timing, UIState *ui, QObject *parent)
    : QObject(parent),
      m_engine(engine),
      m_vehicle(vehicle),
      m_gps(gps),
      m_analog(analog),
      m_digital(digital),
      m_expander(expander),
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
    mapModelProperties(m_connection, ModelType::Connection);
    mapModelProperties(m_settings, ModelType::Settings);
    mapModelProperties(m_timing, ModelType::Timing);
    mapModelProperties(m_ui, ModelType::UI);

    qDebug() << "PropertyRouter: Initialized with" << m_propertyModelMap.size() << "properties";
    qDebug() << "PropertyRouter: Deferring NOTIFY signal wiring until first property access";
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

void PropertyRouter::disconnectModelSignals(QObject *model)
{
    if (!model)
        return;
    QObject::disconnect(model, nullptr, this, nullptr);
    m_signalToPropertyMap.remove(model);
}

void PropertyRouter::connectModel(QObject *model)
{
    if (!model || m_connectedModels.contains(model))
        return;
    connectModelSignals(model);
    m_connectedModels.insert(model);
}

void PropertyRouter::disconnectModel(QObject *model)
{
    if (!model || !m_connectedModels.contains(model))
        return;
    disconnectModelSignals(model);
    m_connectedModels.remove(model);
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
    if (!m_activeProperties.contains(info.propertyName))
        return;

    QVariant val = model->metaObject()->property(info.propertyIndex).read(model);
    emit valueChanged(info.propertyName, val);

    const QStringList aliases = m_reverseAliases.value(info.propertyName);
    for (const QString &aliasKey : aliases)
        emit valueChanged(aliasKey, val);
}

QVariant PropertyRouter::getValue(const QString &propertyName) const
{
    const QString resolvedProperty = resolveAlias(propertyName);
    m_activeProperties.insert(resolvedProperty);
    if (!m_propertyModelMap.contains(resolvedProperty)) {
        qWarning() << "PropertyRouter: Unknown property:" << propertyName;
        return QVariant(0);
    }

    const ModelType type = m_propertyModelMap.value(resolvedProperty);
    QObject *model = modelForType(type);

    if (!model) {
        qWarning() << "PropertyRouter: Model is null for property:" << propertyName;
        return QVariant(0);
    }

    const_cast<PropertyRouter *>(this)->connectModel(model);
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

void PropertyRouter::clearActiveProperties()
{
    m_activeProperties.clear();
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

void PropertyRouter::setSensorRegistry(SensorRegistry *sensorRegistry)
{
    m_sensorRegistry = sensorRegistry;
}

QObject *PropertyRouter::modelForType(ModelType type) const
{
    switch (type) {
    case ModelType::Engine:
        return m_engine;
    case ModelType::Vehicle:
        return m_vehicle;
    case ModelType::GPS:
        return m_gps;
    case ModelType::Analog:
        return m_analog;
    case ModelType::Digital:
        return m_digital;
    case ModelType::Expander:
        return m_expander;
    case ModelType::Connection:
        return m_connection;
    case ModelType::Settings:
        return m_settings;
    case ModelType::Timing:
        return m_timing;
    case ModelType::UI:
        return m_ui;
    default:
        return nullptr;
    }
}
