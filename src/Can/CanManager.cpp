#include "CanManager.h"

#include "CanInterface.h"
#include "CanTransport.h"

#include <QStringList>

CanManager::CanManager(QObject *parent) : QObject(parent) {}

void CanManager::setTransport(CanTransport *transport)
{
    m_transport = transport;
}

void CanManager::registerModule(CanInterface *module)
{
    if (!module)
        return;

    m_modules.insert(module->moduleBackendId(), module);
}

bool CanManager::hasModule(int backendId) const
{
    const auto it = m_modules.constFind(backendId);
    return it != m_modules.constEnd() && !it.value().isNull();
}

bool CanManager::activateModule(int backendId, const QVariantMap &config)
{
    if (!m_transport) {
        emit activationFailed(QStringLiteral("CAN transport is not configured"));
        return false;
    }

    const auto it = m_modules.constFind(backendId);
    if (it == m_modules.constEnd() || it.value().isNull()) {
        emit activationFailed(QStringLiteral("No CAN module is registered for ECU backend %1").arg(backendId));
        return false;
    }

    QPointer<CanInterface> module = it.value();
    if (module.isNull()) {
        emit activationFailed(QStringLiteral("CAN module for ECU backend %1 is no longer valid").arg(backendId));
        return false;
    }

    module->configureConnection(config);
    module->attachTransport(m_transport);
    m_activeModules.insert(backendId, module);
    emit activeModuleChanged();
    return true;
}

void CanManager::deactivateModule(int backendId)
{
    const auto it = m_activeModules.find(backendId);
    if (it == m_activeModules.end())
        return;

    if (!it.value().isNull())
        it.value()->detachTransport();
    m_activeModules.erase(it);
    emit activeModuleChanged();
}

void CanManager::deactivateAll()
{
    bool hadAny = false;
    for (auto it = m_activeModules.begin(); it != m_activeModules.end(); ++it) {
        if (!it.value().isNull())
            it.value()->detachTransport();
        hadAny = true;
    }
    m_activeModules.clear();
    if (hadAny)
        emit activeModuleChanged();
}

bool CanManager::isModuleActive(int backendId) const
{
    const auto it = m_activeModules.constFind(backendId);
    return it != m_activeModules.constEnd() && !it.value().isNull();
}

QString CanManager::activeModuleName() const
{
    QStringList names;
    for (auto it = m_activeModules.constBegin(); it != m_activeModules.constEnd(); ++it) {
        if (!it.value().isNull())
            names << it.value()->moduleName();
    }
    return names.join(QStringLiteral(", "));
}

QList<CanInterface *> CanManager::activeModules() const
{
    QList<CanInterface *> modules;
    modules.reserve(m_activeModules.size());
    for (auto it = m_activeModules.constBegin(); it != m_activeModules.constEnd(); ++it) {
        if (!it.value().isNull())
            modules.append(it.value());
    }
    return modules;
}
