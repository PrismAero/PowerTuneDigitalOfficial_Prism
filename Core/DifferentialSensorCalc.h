#ifndef DIFFERENTIALSENSORCALC_H
#define DIFFERENTIALSENSORCALC_H

#include <QObject>

class ExpanderBoardData;
class SensorRegistry;

class DifferentialSensorCalc : public QObject
{
    Q_OBJECT

public:
    enum Formula { Percentage, Differential, Ratio };
    Q_ENUM(Formula)

    explicit DifferentialSensorCalc(QObject *parent = nullptr);

    void setExpanderBoardData(ExpanderBoardData *data);
    void setSensorRegistry(SensorRegistry *reg) { m_sensorRegistry = reg; }

    void configure(bool enabled, int channelA, int channelB,
                   Formula formula, double offset);

    bool isEnabled() const { return m_enabled; }

private slots:
    void recalculate();

private:
    void disconnectChannels();
    void connectChannels();
    double readChannel(int ch) const;

    ExpanderBoardData *m_data = nullptr;
    SensorRegistry *m_sensorRegistry = nullptr;
    bool m_enabled = false;
    int m_channelA = -1;
    int m_channelB = -1;
    Formula m_formula = Percentage;
    double m_offset = 0.0;

    QMetaObject::Connection m_connA;
    QMetaObject::Connection m_connB;
};

#endif  // DIFFERENTIALSENSORCALC_H
