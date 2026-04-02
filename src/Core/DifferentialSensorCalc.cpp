#include "DifferentialSensorCalc.h"

#include "Models/ExpanderBoardData.h"
#include "SensorRegistry.h"

#include <QtMath>

static const char *calcSignalName(int channel)
{
    switch (channel) {
    case 0: return SIGNAL(EXAnalogCalc0Changed(qreal));
    case 1: return SIGNAL(EXAnalogCalc1Changed(qreal));
    case 2: return SIGNAL(EXAnalogCalc2Changed(qreal));
    case 3: return SIGNAL(EXAnalogCalc3Changed(qreal));
    case 4: return SIGNAL(EXAnalogCalc4Changed(qreal));
    case 5: return SIGNAL(EXAnalogCalc5Changed(qreal));
    case 6: return SIGNAL(EXAnalogCalc6Changed(qreal));
    case 7: return SIGNAL(EXAnalogCalc7Changed(qreal));
    default: return nullptr;
    }
}

DifferentialSensorCalc::DifferentialSensorCalc(QObject *parent) : QObject(parent) {}

void DifferentialSensorCalc::setExpanderBoardData(ExpanderBoardData *data)
{
    if (m_data == data)
        return;
    disconnectChannels();
    m_data = data;
    if (m_enabled)
        connectChannels();
}

void DifferentialSensorCalc::configure(bool enabled, int channelA, int channelB,
                                       Formula formula, double offset)
{
    disconnectChannels();

    m_enabled = enabled;
    m_channelA = channelA;
    m_channelB = channelB;
    m_formula = formula;
    m_offset = offset;

    if (m_enabled)
        connectChannels();
}

void DifferentialSensorCalc::disconnectChannels()
{
    if (m_connA)
        disconnect(m_connA);
    if (m_connB)
        disconnect(m_connB);
    m_connA = {};
    m_connB = {};
}

void DifferentialSensorCalc::connectChannels()
{
    if (!m_data || m_channelA < 0 || m_channelA > 7 || m_channelB < 0 || m_channelB > 7)
        return;

    const char *sigA = calcSignalName(m_channelA);
    const char *sigB = calcSignalName(m_channelB);
    if (!sigA || !sigB)
        return;

    m_connA = connect(m_data, sigA, this, SLOT(recalculate()));
    m_connB = connect(m_data, sigB, this, SLOT(recalculate()));

    recalculate();
}

double DifferentialSensorCalc::readChannel(int ch) const
{
    if (!m_data)
        return 0.0;
    switch (ch) {
    case 0: return m_data->EXAnalogCalc0();
    case 1: return m_data->EXAnalogCalc1();
    case 2: return m_data->EXAnalogCalc2();
    case 3: return m_data->EXAnalogCalc3();
    case 4: return m_data->EXAnalogCalc4();
    case 5: return m_data->EXAnalogCalc5();
    case 6: return m_data->EXAnalogCalc6();
    case 7: return m_data->EXAnalogCalc7();
    default: return 0.0;
    }
}

void DifferentialSensorCalc::recalculate()
{
    if (!m_data || !m_enabled)
        return;

    const double a = readChannel(m_channelA);
    const double b = readChannel(m_channelB);
    double result = 0.0;

    switch (m_formula) {
    case Percentage: {
        const double sum = a + b;
        result = (sum > 0.0) ? (a / sum) * 100.0 + m_offset : 50.0 + m_offset;
        break;
    }
    case Differential:
        result = a - b + m_offset;
        break;
    case Ratio:
        result = (qFuzzyIsNull(b)) ? m_offset : (a / b) + m_offset;
        break;
    }

    m_data->setDifferentialSensor(result);

    if (m_sensorRegistry)
        m_sensorRegistry->markCanSensorActive(QStringLiteral("differentialSensor"));
}
