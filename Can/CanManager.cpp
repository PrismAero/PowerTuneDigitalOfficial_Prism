#include "CanManager.h"

#include "CanInterface.h"
#include "CanTransport.h"

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

    if (m_activeModule && m_activeModule != it.value())
        m_activeModule->detachTransport();

    m_activeModule = it.value();
    m_activeModule->configureConnection(config);
    m_activeModule->attachTransport(m_transport);
    emit activeModuleChanged();
    return true;
}

void CanManager::deactivateModule()
{
    if (!m_activeModule)
        return;

    m_activeModule->detachTransport();
    m_activeModule = nullptr;
    emit activeModuleChanged();
}

QString CanManager::activeModuleName() const
{
    return m_activeModule ? m_activeModule->moduleName() : QString();
}

CanInterface *CanManager::activeModule() const
{
    return m_activeModule;
}
