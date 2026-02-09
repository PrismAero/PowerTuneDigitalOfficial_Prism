/**
 * @file SignalSmoother.cpp
 * @brief Implementation of moving average filter for signal smoothing
 *
 * Phase 5: Extracted from DashBoard God Object for better separation of concerns.
 */

#include "SignalSmoother.h"
#include <algorithm>

SignalSmoother::SignalSmoother(QObject *parent)
    : QObject(parent)
    , m_windowSize(1)
    , m_sum(0.0)
    , m_average(0.0)
{
}

SignalSmoother::SignalSmoother(int windowSize, QObject *parent)
    : QObject(parent)
    , m_windowSize(std::max(1, windowSize))
    , m_sum(0.0)
    , m_average(0.0)
{
    m_buffer.reserve(m_windowSize);
}

qreal SignalSmoother::addValue(qreal value)
{
    // * Add new value to buffer
    if (m_buffer.size() >= m_windowSize) {
        // * Remove oldest value from sum and buffer
        m_sum -= m_buffer.first();
        m_buffer.removeFirst();
    }

    m_buffer.append(value);
    m_sum += value;

    // * Calculate new average
    m_average = m_buffer.isEmpty() ? 0.0 : m_sum / m_buffer.size();

    emit smoothedValueChanged(m_average);
    return m_average;
}

int SignalSmoother::addValueInt(int value)
{
    return static_cast<int>(addValue(static_cast<qreal>(value)));
}

qreal SignalSmoother::smoothedValue() const
{
    return m_average;
}

void SignalSmoother::setWindowSize(int size)
{
    int newSize = std::max(1, size);
    if (m_windowSize == newSize) {
        return;
    }

    m_windowSize = newSize;

    // * If buffer is larger than new window, trim it
    while (m_buffer.size() > m_windowSize) {
        m_sum -= m_buffer.first();
        m_buffer.removeFirst();
    }

    recalculateAverage();
    emit windowSizeChanged(m_windowSize);
}

void SignalSmoother::reset()
{
    m_buffer.clear();
    m_sum = 0.0;
    m_average = 0.0;
    emit smoothedValueChanged(m_average);
}

void SignalSmoother::recalculateAverage()
{
    m_sum = 0.0;
    for (qreal val : m_buffer) {
        m_sum += val;
    }
    m_average = m_buffer.isEmpty() ? 0.0 : m_sum / m_buffer.size();
    emit smoothedValueChanged(m_average);
}
