#include "DashboardLockService.h"

#include "AppSettings.h"

namespace {
constexpr int kUnlockHoldDelayMs = 500;
constexpr int kUnlockHoldDurationMs = 4 * 1000;
constexpr int kHoldProgressIntervalMs = 100;
}

DashboardLockService::DashboardLockService(QObject *parent) : QObject(parent)
{
    m_holdDelayTimer.setSingleShot(true);
    m_holdDelayTimer.setInterval(kUnlockHoldDelayMs);
    m_holdProgressTimer.setInterval(kHoldProgressIntervalMs);
    m_unlockTimer.setSingleShot(true);
    m_unlockTimer.setInterval(kUnlockHoldDurationMs);

    connect(&m_holdDelayTimer, &QTimer::timeout, this, &DashboardLockService::startUnlockHold);
    connect(&m_holdProgressTimer, &QTimer::timeout, this, &DashboardLockService::updateHoldProgress);
    connect(&m_unlockTimer, &QTimer::timeout, this, &DashboardLockService::finishUnlock);
}

void DashboardLockService::setAppSettings(AppSettings *settings)
{
    m_appSettings = settings;
}

void DashboardLockService::initialize()
{
    m_lockoutEnabled = m_appSettings ? m_appSettings->readDashboardLockEnabled() : false;
    m_sessionUnlocked = false;
    m_unlocking = false;
    m_holdProgressPercent = 0;
}

void DashboardLockService::beginUnlockHold()
{
    if (!m_lockoutEnabled || m_sessionUnlocked || m_unlocking || m_holdDelayTimer.isActive())
        return;

    setHoldProgressPercent(0);
    m_holdDelayTimer.start();
}

void DashboardLockService::cancelUnlockHold()
{
    if (!m_unlocking && !m_holdDelayTimer.isActive())
        return;

    m_holdDelayTimer.stop();
    m_holdProgressTimer.stop();
    m_unlockTimer.stop();
    setUnlocking(false);
    setHoldProgressPercent(0);
}

void DashboardLockService::startUnlockHold()
{
    if (!m_lockoutEnabled || m_sessionUnlocked)
        return;

    setUnlocking(true);
    setHoldProgressPercent(0);
    m_holdProgressTimer.start();
    m_unlockTimer.start();
}

void DashboardLockService::setLockoutEnabled(bool enabled)
{
    if (m_lockoutEnabled == enabled)
        return;

    m_lockoutEnabled = enabled;
    if (m_appSettings)
        m_appSettings->writeDashboardLockEnabled(enabled);

    if (!m_lockoutEnabled) {
        cancelUnlockHold();
        setHoldProgressPercent(0);
        setSessionUnlocked(true);
    } else {
        setHoldProgressPercent(0);
        setSessionUnlocked(false);
    }

    emit lockoutEnabledChanged(m_lockoutEnabled);
    emit swipeAllowedChanged(swipeAllowed());
}

void DashboardLockService::updateHoldProgress()
{
    const int elapsed = kUnlockHoldDurationMs - m_unlockTimer.remainingTime();
    setHoldProgressPercent(qBound(0, static_cast<int>((elapsed / static_cast<double>(kUnlockHoldDurationMs)) * 100.0), 100));
}

void DashboardLockService::finishUnlock()
{
    m_holdProgressTimer.stop();
    setUnlocking(false);
    setHoldProgressPercent(100);
    setSessionUnlocked(true);
    emit swipeAllowedChanged(swipeAllowed());
}

void DashboardLockService::setSessionUnlocked(bool unlocked)
{
    if (m_sessionUnlocked == unlocked)
        return;

    m_sessionUnlocked = unlocked;
    emit sessionUnlockedChanged(m_sessionUnlocked);
}

void DashboardLockService::setUnlocking(bool unlocking)
{
    if (m_unlocking == unlocking)
        return;

    m_unlocking = unlocking;
    emit unlockingChanged(m_unlocking);
}

void DashboardLockService::setHoldProgressPercent(int percent)
{
    if (m_holdProgressPercent == percent)
        return;

    m_holdProgressPercent = percent;
    emit holdProgressPercentChanged(m_holdProgressPercent);
}
