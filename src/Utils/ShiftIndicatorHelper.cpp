// Copyright (c) 2026 Kai Wyborny. All rights reserved.

#include "ShiftIndicatorHelper.h"

#include <QtMath>

ShiftIndicatorHelper::ShiftIndicatorHelper(QObject *parent) : QObject(parent) {}

QVariantList ShiftIndicatorHelper::pillColors(int pillCount) const
{
    QVariantList colors;
    if (pillCount <= 0)
        return colors;

    int greenZone = qFloor(pillCount * 0.27);
    int yellowZone = qFloor(pillCount * 0.18);

    for (int i = 0; i < pillCount; ++i) {
        if (i < greenZone || i >= pillCount - greenZone)
            colors.append(QStringLiteral("#1ED033"));
        else if (i < greenZone + yellowZone || i >= pillCount - greenZone - yellowZone)
            colors.append(QStringLiteral("#F1E83C"));
        else
            colors.append(QStringLiteral("#FF0909"));
    }
    return colors;
}

QVariantList ShiftIndicatorHelper::activationOrder(int pillCount, const QString &pattern) const
{
    QVariantList order;
    if (pillCount <= 0)
        return order;

    if (pattern == QLatin1String("left-to-right")) {
        for (int i = 0; i < pillCount; ++i)
            order.append(i);
    } else if (pattern == QLatin1String("right-to-left")) {
        for (int i = pillCount - 1; i >= 0; --i)
            order.append(i);
    } else if (pattern == QLatin1String("alternating")) {
        int lo = 0, hi = pillCount - 1;
        while (lo <= hi) {
            order.append(lo++);
            if (lo <= hi)
                order.append(hi--);
        }
    } else {
        int mid = pillCount / 2;
        for (int step = 0; step < pillCount; ++step) {
            if (step == 0) {
                order.append(mid);
            } else {
                int below = mid - step;
                int above = mid + step;
                if (below >= 0)
                    order.append(below);
                if (above < pillCount)
                    order.append(above);
            }
        }
    }
    return order;
}

int ShiftIndicatorHelper::activeLightCount(double rpmValue, double rpmMax, double shiftPoint, int pillCount) const
{
    if (pillCount <= 0 || rpmMax <= 0.0)
        return 0;

    double ratio = rpmValue / rpmMax;
    double startRatio = shiftPoint * 0.7;
    if (ratio < startRatio)
        return 0;

    double normalized = (ratio - startRatio) / (1.0 - startRatio);
    return qMin(pillCount, static_cast<int>(qCeil(normalized * pillCount)));
}

bool ShiftIndicatorHelper::isPillLit(int index, int activeCount, const QVariantList &order) const
{
    for (int i = 0; i < activeCount && i < order.size(); ++i) {
        if (order.at(i).toInt() == index)
            return true;
    }
    return false;
}

QString ShiftIndicatorHelper::gearMainText(double gearValue) const
{
    const int rounded = static_cast<int>(qRound(gearValue));
    if (rounded <= -90)
        return QStringLiteral("ERR");
    if (rounded < 0)
        return QStringLiteral("R");
    if (rounded <= 0)
        return QStringLiteral("N");
    if (rounded > 8)
        return QStringLiteral("ERR");
    return QString::number(rounded);
}

QString ShiftIndicatorHelper::gearSuffixText(double gearValue) const
{
    const int rounded = static_cast<int>(qRound(gearValue));
    if (rounded <= 0 || rounded > 8)
        return QString();

    const int mod10 = rounded % 10;
    const int mod100 = rounded % 100;
    if (mod10 == 1 && mod100 != 11)
        return QStringLiteral("st");
    if (mod10 == 2 && mod100 != 12)
        return QStringLiteral("nd");
    if (mod10 == 3 && mod100 != 13)
        return QStringLiteral("rd");
    return QStringLiteral("th");
}
