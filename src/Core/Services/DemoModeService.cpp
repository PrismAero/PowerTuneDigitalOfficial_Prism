#include "DemoModeService.h"

DemoModeService::DemoModeService(QObject *parent) : QObject(parent)
{
}

void DemoModeService::enterDemoMode()
{
    if (m_active)
        return;

    m_active = true;
    emit activeChanged(m_active);
}
