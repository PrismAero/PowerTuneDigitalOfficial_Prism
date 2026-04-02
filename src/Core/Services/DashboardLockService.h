#ifndef DASHBOARDLOCKSERVICE_H
#define DASHBOARDLOCKSERVICE_H

#include <QObject>
#include <QTimer>

class AppSettings;

class DashboardLockService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool lockoutEnabled READ lockoutEnabled WRITE setLockoutEnabled NOTIFY lockoutEnabledChanged)
    Q_PROPERTY(bool sessionUnlocked READ sessionUnlocked NOTIFY sessionUnlockedChanged)
    Q_PROPERTY(bool swipeAllowed READ swipeAllowed NOTIFY swipeAllowedChanged)
    Q_PROPERTY(bool unlocking READ unlocking NOTIFY unlockingChanged)
    Q_PROPERTY(int holdProgressPercent READ holdProgressPercent NOTIFY holdProgressPercentChanged)

public:
    explicit DashboardLockService(QObject *parent = nullptr);

    void setAppSettings(AppSettings *settings);
    void initialize();

    bool lockoutEnabled() const { return m_lockoutEnabled; }
    bool sessionUnlocked() const { return m_sessionUnlocked; }
    bool swipeAllowed() const { return !m_lockoutEnabled || m_sessionUnlocked; }
    bool unlocking() const { return m_unlocking; }
    int holdProgressPercent() const { return m_holdProgressPercent; }

    Q_INVOKABLE void beginUnlockHold();
    Q_INVOKABLE void cancelUnlockHold();

public slots:
    void setLockoutEnabled(bool enabled);

signals:
    void lockoutEnabledChanged(bool enabled);
    void sessionUnlockedChanged(bool unlocked);
    void swipeAllowedChanged(bool allowed);
    void unlockingChanged(bool unlocking);
    void holdProgressPercentChanged(int percent);

private slots:
    void startUnlockHold();
    void updateHoldProgress();
    void finishUnlock();

private:
    void setSessionUnlocked(bool unlocked);
    void setUnlocking(bool unlocking);
    void setHoldProgressPercent(int percent);

    AppSettings *m_appSettings = nullptr;
    bool m_lockoutEnabled = false;
    bool m_sessionUnlocked = false;
    bool m_unlocking = false;
    int m_holdProgressPercent = 0;
    QTimer m_holdDelayTimer;
    QTimer m_holdProgressTimer;
    QTimer m_unlockTimer;
};

#endif  // DASHBOARDLOCKSERVICE_H
