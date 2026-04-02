/**
 * @file EngineData.h
 * @brief Engine-specific data model for PowerTune
 */

#ifndef ENGINEDATA_H
#define ENGINEDATA_H

#include <QObject>

class EngineData : public QObject
{
    Q_OBJECT

    Q_PROPERTY(qreal rpm READ rpm WRITE setrpm NOTIFY rpmChanged)
    Q_PROPERTY(qreal Power READ Power WRITE setPower NOTIFY powerChanged)
    Q_PROPERTY(qreal Torque READ Torque WRITE setTorque NOTIFY torqueChanged)
    Q_PROPERTY(qreal Cylinders READ Cylinders WRITE setCylinders NOTIFY CylindersChanged)
    Q_PROPERTY(qreal Lambdamultiply READ Lambdamultiply WRITE setLambdamultiply NOTIFY LambdamultiplyChanged)

public:
    explicit EngineData(QObject *parent = nullptr);

    qreal rpm() const { return m_rpm; }
    qreal Power() const { return m_Power; }
    qreal Torque() const { return m_Torque; }
    qreal Cylinders() const { return m_Cylinders; }
    qreal Lambdamultiply() const { return m_Lambdamultiply; }

public slots:
    void setrpm(qreal rpm);
    void setPower(qreal Power);
    void setTorque(qreal Torque);
    void setCylinders(qreal Cylinders);
    void setLambdamultiply(qreal Lambdamultiply);

signals:
    void rpmChanged(qreal rpm);
    void powerChanged(qreal Power);
    void torqueChanged(qreal Torque);
    void CylindersChanged(qreal Cylinders);
    void LambdamultiplyChanged(qreal Lambdamultiply);

private:
    qreal m_rpm = 0;
    qreal m_Power = 0;
    qreal m_Torque = 0;
    qreal m_Cylinders = 0;
    qreal m_Lambdamultiply = 0;
};

#endif  // ENGINEDATA_H
