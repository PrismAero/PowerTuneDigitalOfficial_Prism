/**
 * @file SignalSmoother.h
 * @brief Moving average filter for smoothing sensor signals (RPM, speed, etc.)
 *
 * Phase 5: Extracted from DashBoard God Object for better separation of concerns.
 */

#ifndef SIGNALSMOOTHER_H
#define SIGNALSMOOTHER_H

#include <QObject>
#include <QVector>

/**
 * @brief Moving average filter for signal smoothing
 *
 * Implements a simple moving average (SMA) filter that maintains a buffer
 * of recent values and returns their average. Useful for reducing noise
 * in sensor readings like RPM and vehicle speed.
 */
class SignalSmoother : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int windowSize READ windowSize WRITE setWindowSize NOTIFY windowSizeChanged)
    Q_PROPERTY(qreal smoothedValue READ smoothedValue NOTIFY smoothedValueChanged)

public:
    explicit SignalSmoother(QObject *parent = nullptr);
    explicit SignalSmoother(int windowSize, QObject *parent = nullptr);

    /**
     * @brief Add a new value to the moving average
     * @param value New raw value to add
     * @return Smoothed (averaged) value
     */
    qreal addValue(qreal value);

    /**
     * @brief Add a new integer value to the moving average
     * @param value New raw value to add
     * @return Smoothed (averaged) value as integer
     */
    int addValueInt(int value);

    /**
     * @brief Get the current smoothed value without adding a new sample
     * @return Current smoothed value
     */
    qreal smoothedValue() const;

    /**
     * @brief Get the window size (number of samples to average)
     * @return Current window size
     */
    int windowSize() const { return m_windowSize; }

    /**
     * @brief Set the window size (number of samples to average)
     * @param size New window size (minimum 1)
     *
     * If the new size is smaller than the current buffer, excess values are removed.
     * If larger, the buffer will grow as new values are added.
     */
    void setWindowSize(int size);

    /**
     * @brief Reset the smoother, clearing all buffered values
     */
    void reset();

    /**
     * @brief Check if the buffer is fully populated
     * @return true if buffer has windowSize samples
     */
    bool isWarmedUp() const { return m_buffer.size() >= m_windowSize; }

    /**
     * @brief Get the number of samples currently in the buffer
     * @return Current buffer size
     */
    int sampleCount() const { return m_buffer.size(); }

signals:
    void windowSizeChanged(int size);
    void smoothedValueChanged(qreal value);

private:
    void recalculateAverage();

    QVector<qreal> m_buffer;
    int m_windowSize;
    qreal m_sum;
    qreal m_average;
};

#endif // SIGNALSMOOTHER_H
