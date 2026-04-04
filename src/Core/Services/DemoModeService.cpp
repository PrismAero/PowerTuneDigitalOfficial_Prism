#include "DemoModeService.h"

DemoModeService::DemoModeService(QObject *parent) : QObject(parent)
{
}

void DemoModeService::enterDemoMode()
{
    if (m_active)
        return;

    // Demo mode is intentionally session-only and must never be restored from persisted settings.
    m_active = true;
    emit activeChanged(m_active);
}
