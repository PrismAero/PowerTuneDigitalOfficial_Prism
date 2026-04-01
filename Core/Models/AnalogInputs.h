/**
 * @file AnalogInputs.h
 * @brief Analog input sensor data model for PowerTune
 *
 * Reserved for future CAN/ECU analog channel support.
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#ifndef ANALOGINPUTS_H
#define ANALOGINPUTS_H

#include <QObject>

class AnalogInputs : public QObject
{
    Q_OBJECT

public:
    explicit AnalogInputs(QObject *parent = nullptr);
};

#endif  // ANALOGINPUTS_H
