// Copyright (c) 2026 Kai Wyborny. All rights reserved.

#ifndef SHIFTINDICATORHELPER_H
#define SHIFTINDICATORHELPER_H

#include <QObject>
#include <QVariantList>
#include <QString>

class ShiftIndicatorHelper : public QObject
{
    Q_OBJECT

public:
    explicit ShiftIndicatorHelper(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList pillColors(int pillCount) const;
    Q_INVOKABLE QVariantList activationOrder(int pillCount, const QString &pattern) const;
    Q_INVOKABLE int activeLightCount(double rpmValue, double rpmMax, double shiftPoint, int pillCount) const;
    Q_INVOKABLE bool isPillLit(int index, int activeCount, const QVariantList &order) const;
};

#endif // SHIFTINDICATORHELPER_H
