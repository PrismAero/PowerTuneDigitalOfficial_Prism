/**
 * @file GPSData.cpp
 * @brief Implementation of the GPSData class
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 */

#include "GPSData.h"

GPSData::GPSData(QObject *parent) : QObject(parent) {}

void GPSData::setgpsLatitude(qreal gpsLatitude)
{
    if (m_gpsLatitude != gpsLatitude) {
        m_gpsLatitude = gpsLatitude;
        emit gpsLatitudeChanged(gpsLatitude);
    }
}

void GPSData::setgpsLongitude(qreal gpsLongitude)
{
    if (m_gpsLongitude != gpsLongitude) {
        m_gpsLongitude = gpsLongitude;
        emit gpsLongitudeChanged(gpsLongitude);
    }
}

void GPSData::setgpsAltitude(qreal gpsAltitude)
{
    if (m_gpsAltitude != gpsAltitude) {
        m_gpsAltitude = gpsAltitude;
        emit gpsAltitudeChanged(gpsAltitude);
    }
}

void GPSData::setgpsSpeed(qreal gpsSpeed)
{
    if (m_gpsSpeed != gpsSpeed) {
        m_gpsSpeed = gpsSpeed;
        emit gpsSpeedChanged(gpsSpeed);
    }
}

void GPSData::setgpsbearing(qreal gpsbearing)
{
    if (m_gpsbearing != gpsbearing) {
        m_gpsbearing = gpsbearing;
        emit gpsbearingChanged(gpsbearing);
    }
}

void GPSData::setgpsVisibleSatelites(int gpsVisibleSatelites)
{
    if (m_gpsVisibleSatelites != gpsVisibleSatelites) {
        m_gpsVisibleSatelites = gpsVisibleSatelites;
        emit gpsVisibleSatelitesChanged(gpsVisibleSatelites);
    }
}

void GPSData::setgpsHDOP(qreal gpsHDOP)
{
    if (m_gpsHDOP != gpsHDOP) {
        m_gpsHDOP = gpsHDOP;
        emit gpsHDOPChanged(gpsHDOP);
    }
}

void GPSData::setgpsFIXtype(const QString &gpsFIXtype)
{
    if (m_gpsFIXtype != gpsFIXtype) {
        m_gpsFIXtype = gpsFIXtype;
        emit gpsFIXtypeChanged(gpsFIXtype);
    }
}

void GPSData::setgpsTime(const QString &gpsTime)
{
    if (m_gpsTime != gpsTime) {
        m_gpsTime = gpsTime;
        emit gpsTimeChanged(gpsTime);
    }
}

void GPSData::setNMEAlog(qreal NMEAlog)
{
    if (m_NMEAlog != NMEAlog) {
        m_NMEAlog = NMEAlog;
        emit NMEAlogChanged(NMEAlog);
    }
}
