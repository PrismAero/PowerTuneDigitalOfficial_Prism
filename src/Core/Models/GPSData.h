/**
 * @file GPSData.h
 * @brief GPS/Location data model for PowerTune
 *
 * Reserved for future GPS hardware integration.
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#ifndef GPSDATA_H
#define GPSDATA_H

#include <QObject>

class GPSData : public QObject
{
    Q_OBJECT

public:
    explicit GPSData(QObject *parent = nullptr);
};

#endif  // GPSDATA_H
