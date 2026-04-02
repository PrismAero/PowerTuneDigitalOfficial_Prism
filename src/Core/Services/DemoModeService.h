#ifndef DEMOMODESERVICE_H
#define DEMOMODESERVICE_H

#include <QObject>

class DemoModeService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)

public:
    explicit DemoModeService(QObject *parent = nullptr);

    bool active() const { return m_active; }

    Q_INVOKABLE void enterDemoMode();

signals:
    void activeChanged(bool active);

private:
    bool m_active = false;
};

#endif  // DEMOMODESERVICE_H
