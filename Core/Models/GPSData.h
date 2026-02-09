/**
 * @file GPSData.h
 * @brief GPS/Location data model for PowerTune
 *
 * This class encapsulates GPS-related sensor data including:
 * - Latitude, longitude, altitude
 * - GPS speed, bearing
 * - Satellite count, HDOP
 * - Fix type, time
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#ifndef GPSDATA_H
#define GPSDATA_H

#include <QObject>
#include <QString>

class GPSData : public QObject
{
    Q_OBJECT

    // * Position
    Q_PROPERTY(qreal gpsLatitude READ gpsLatitude WRITE setgpsLatitude NOTIFY gpsLatitudeChanged)
    Q_PROPERTY(qreal gpsLongitude READ gpsLongitude WRITE setgpsLongitude NOTIFY gpsLongitudeChanged)
    Q_PROPERTY(qreal gpsAltitude READ gpsAltitude WRITE setgpsAltitude NOTIFY gpsAltitudeChanged)

    // * Speed/Direction
    Q_PROPERTY(qreal gpsSpeed READ gpsSpeed WRITE setgpsSpeed NOTIFY gpsSpeedChanged)
    Q_PROPERTY(qreal gpsbearing READ gpsbearing WRITE setgpsbearing NOTIFY gpsbearingChanged)

    // * Quality
    Q_PROPERTY(
        int gpsVisibleSatelites READ gpsVisibleSatelites WRITE setgpsVisibleSatelites NOTIFY gpsVisibleSatelitesChanged)
    Q_PROPERTY(qreal gpsHDOP READ gpsHDOP WRITE setgpsHDOP NOTIFY gpsHDOPChanged)
    Q_PROPERTY(QString gpsFIXtype READ gpsFIXtype WRITE setgpsFIXtype NOTIFY gpsFIXtypeChanged)

    // * Time
    Q_PROPERTY(QString gpsTime READ gpsTime WRITE setgpsTime NOTIFY gpsTimeChanged)

    // * Logging
    Q_PROPERTY(qreal NMEAlog READ NMEAlog WRITE setNMEAlog NOTIFY NMEAlogChanged)

public:
    explicit GPSData(QObject *parent = nullptr);

    // * Getters
    qreal gpsLatitude() const { return m_gpsLatitude; }
    qreal gpsLongitude() const { return m_gpsLongitude; }
    qreal gpsAltitude() const { return m_gpsAltitude; }
    qreal gpsSpeed() const { return m_gpsSpeed; }
    qreal gpsbearing() const { return m_gpsbearing; }
    int gpsVisibleSatelites() const { return m_gpsVisibleSatelites; }
    qreal gpsHDOP() const { return m_gpsHDOP; }
    QString gpsFIXtype() const { return m_gpsFIXtype; }
    QString gpsTime() const { return m_gpsTime; }
    qreal NMEAlog() const { return m_NMEAlog; }

public slots:
    void setgpsLatitude(qreal gpsLatitude);
    void setgpsLongitude(qreal gpsLongitude);
    void setgpsAltitude(qreal gpsAltitude);
    void setgpsSpeed(qreal gpsSpeed);
    void setgpsbearing(qreal gpsbearing);
    void setgpsVisibleSatelites(int gpsVisibleSatelites);
    void setgpsHDOP(qreal gpsHDOP);
    void setgpsFIXtype(const QString &gpsFIXtype);
    void setgpsTime(const QString &gpsTime);
    void setNMEAlog(qreal NMEAlog);

signals:
    void gpsLatitudeChanged(qreal gpsLatitude);
    void gpsLongitudeChanged(qreal gpsLongitude);
    void gpsAltitudeChanged(qreal gpsAltitude);
    void gpsSpeedChanged(qreal gpsSpeed);
    void gpsbearingChanged(qreal gpsbearing);
    void gpsVisibleSatelitesChanged(int gpsVisibleSatelites);
    void gpsHDOPChanged(qreal gpsHDOP);
    void gpsFIXtypeChanged(const QString &gpsFIXtype);
    void gpsTimeChanged(const QString &gpsTime);
    void NMEAlogChanged(qreal NMEAlog);

private:
    qreal m_gpsLatitude = 0;
    qreal m_gpsLongitude = 0;
    qreal m_gpsAltitude = 0;
    qreal m_gpsSpeed = 0;
    qreal m_gpsbearing = 0;
    int m_gpsVisibleSatelites = 0;
    qreal m_gpsHDOP = 0;
    QString m_gpsFIXtype;
    QString m_gpsTime;
    qreal m_NMEAlog = 0;
};

#endif  // GPSDATA_H
