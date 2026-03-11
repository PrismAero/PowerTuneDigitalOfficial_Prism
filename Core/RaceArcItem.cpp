#include "RaceArcItem.h"

#include <QConicalGradient>
#include <QPainter>
#include <QPainterPath>
#include <QtMath>

namespace {

struct CubicSegment
{
    QPointF control1;
    QPointF control2;
    QPointF endPoint;
};

struct GradientStop
{
    qreal position;
    QColor color;
};

struct ShapeDefinition
{
    QSizeF viewBoxSize;
    QPointF gradientCenter;
    qreal gradientAngleDeg;
    QPointF outerStart;
    QVector<CubicSegment> outerSegments;
    QPointF innerStart;
    QVector<CubicSegment> innerSegments;
    QVector<GradientStop> gradientStops;
};

QColor lerpColor(const QColor &a, const QColor &b, qreal t)
{
    const qreal clamped = qBound(0.0, t, 1.0);
    return QColor::fromRgbF(a.redF() + ((b.redF() - a.redF()) * clamped),
                            a.greenF() + ((b.greenF() - a.greenF()) * clamped),
                            a.blueF() + ((b.blueF() - a.blueF()) * clamped),
                            a.alphaF() + ((b.alphaF() - a.alphaF()) * clamped));
}

QPointF cubicPoint(const QPointF &p0, const QPointF &c1, const QPointF &c2, const QPointF &p1, qreal t)
{
    const qreal oneMinusT = 1.0 - t;
    const qreal oneMinusTSquared = oneMinusT * oneMinusT;
    const qreal tSquared = t * t;
    return (p0 * (oneMinusTSquared * oneMinusT))
        + (c1 * (3.0 * oneMinusTSquared * t))
        + (c2 * (3.0 * oneMinusT * tSquared))
        + (p1 * (tSquared * t));
}

QVector<QPointF> cubicPolyline(const QPointF &startPoint, const QVector<CubicSegment> &segments, int subdivisions = 24)
{
    QVector<QPointF> points;
    points.reserve(1 + (segments.size() * subdivisions));
    points.push_back(startPoint);

    QPointF currentPoint = startPoint;
    for (const CubicSegment &segment : segments) {
        for (int i = 1; i <= subdivisions; ++i) {
            const qreal t = static_cast<qreal>(i) / static_cast<qreal>(subdivisions);
            points.push_back(cubicPoint(currentPoint, segment.control1, segment.control2, segment.endPoint, t));
        }
        currentPoint = segment.endPoint;
    }

    return points;
}

QVector<QPointF> polylineSlice(const QVector<QPointF> &points, qreal startFraction, qreal endFraction)
{
    QVector<QPointF> sliced;
    if (points.size() < 2)
        return sliced;

    const qreal clampedStart = qBound(0.0, startFraction, 1.0);
    const qreal clampedEnd = qBound(0.0, endFraction, 1.0);
    if (clampedEnd <= clampedStart)
        return sliced;

    const qreal maxIndex = static_cast<qreal>(points.size() - 1);

    auto pointAtFraction = [&](qreal fraction) {
        const qreal scaledIndex = qBound(0.0, fraction, 1.0) * maxIndex;
        const int index = qFloor(scaledIndex);
        const int nextIndex = qMin(index + 1, points.size() - 1);
        const qreal localT = scaledIndex - static_cast<qreal>(index);
        return points[index] + ((points[nextIndex] - points[index]) * localT);
    };

    const qreal startScaled = clampedStart * maxIndex;
    const qreal endScaled = clampedEnd * maxIndex;
    const int firstInteriorIndex = qCeil(startScaled);
    const int lastInteriorIndex = qFloor(endScaled);

    sliced.push_back(pointAtFraction(clampedStart));
    for (int i = firstInteriorIndex; i <= lastInteriorIndex; ++i) {
        if (i > 0 && i < points.size() - 1)
            sliced.push_back(points[i]);
    }
    sliced.push_back(pointAtFraction(clampedEnd));

    return sliced;
}

QTransform fittedTransform(const QRectF &bounds, const QSizeF &viewBoxSize)
{
    const qreal scale = qMin(bounds.width() / viewBoxSize.width(), bounds.height() / viewBoxSize.height());
    const qreal xOffset = bounds.x() + ((bounds.width() - (viewBoxSize.width() * scale)) * 0.5);
    const qreal yOffset = bounds.y() + ((bounds.height() - (viewBoxSize.height() * scale)) * 0.5);

    QTransform transform;
    transform.translate(xOffset, yOffset);
    transform.scale(scale, scale);
    return transform;
}

qreal minimumVisibleFractionForShape(const QString &shapeMode)
{
    if (shapeMode == QLatin1String("tachSvg"))
        return 0.2115081126;
    if (shapeMode == QLatin1String("speedSvg"))
        return 0.06;
    return 0.0;
}

QPainterPath buildTrimmedSvgPath(const ShapeDefinition &definition, const QRectF &bounds, qreal progress)
{
    if (progress <= 0.0)
        return {};

    const qreal clampedProgress = qBound(0.0, progress, 1.0);
    const QVector<QPointF> outerPoints = polylineSlice(cubicPolyline(definition.outerStart, definition.outerSegments), 0.0, clampedProgress);
    const QVector<QPointF> innerPoints = polylineSlice(cubicPolyline(definition.innerStart, definition.innerSegments), 0.0, clampedProgress);
    if (outerPoints.size() < 2 || innerPoints.size() < 2)
        return {};

    const int pointCount = qMin(outerPoints.size(), innerPoints.size());
    if (pointCount < 2)
        return {};

    const QTransform fitTransform = fittedTransform(bounds, definition.viewBoxSize);
    auto mapPoint = [&](const QPointF &point) { return fitTransform.map(point); };

    QPainterPath path;
    path.moveTo(mapPoint(outerPoints.first()));
    for (int i = 1; i < pointCount; ++i)
        path.lineTo(mapPoint(outerPoints[i]));

    for (int i = pointCount - 1; i >= 0; --i) {
        path.lineTo(mapPoint(innerPoints[i]));
    }

    path.closeSubpath();
    return path;
    return path;
}

QColor warningTinted(const QColor &color, qreal warningMix)
{
    if (warningMix <= 0.0)
        return color;

    return lerpColor(color, QColor(QStringLiteral("#ff0000")), warningMix);
}

QConicalGradient buildGradient(const ShapeDefinition &definition, const QRectF &bounds, qreal warningMix)
{
    const QTransform transform = fittedTransform(bounds, definition.viewBoxSize);
    QConicalGradient gradient(transform.map(definition.gradientCenter), definition.gradientAngleDeg);

    for (const GradientStop &stop : definition.gradientStops)
        gradient.setColorAt(stop.position, warningTinted(stop.color, warningMix));

    return gradient;
}

const ShapeDefinition &tachShapeDefinition()
{
    static const ShapeDefinition definition {
        QSizeF(548.0, 544.0),
        QPointF(279.0, 272.0),
        90.0,
        QPointF(97.1725, 453.827),
        QVector<CubicSegment> {
            {QPointF(94.9409, 456.059), QPointF(91.3179, 456.063), QPointF(89.1353, 453.784)},
            {QPointF(65.1812, 428.765), QPointF(46.3944, 399.243), QPointF(33.8746, 366.908)},
            {QPointF(20.6667, 332.794), QPointF(14.7245, 296.3), QPointF(16.428, 259.759)},
            {QPointF(18.1316, 223.218), QPointF(27.4434, 187.435), QPointF(43.7678, 154.698)},
            {QPointF(60.0923, 121.962), QPointF(83.0699, 92.9932), QPointF(111.231, 69.6454)},
            {QPointF(139.392, 46.2976), QPointF(172.116, 29.0848), QPointF(207.31, 19.1079)},
            {QPointF(242.504, 9.1311), QPointF(279.393, 6.60997), QPointF(315.617, 11.7058)},
            {QPointF(351.841, 16.8017), QPointF(386.603, 29.4023), QPointF(417.679, 48.7017)},
            {QPointF(447.135, 66.9955), QPointF(472.665, 90.9264), QPointF(492.813, 119.101)},
            {QPointF(494.648, 121.668), QPointF(493.973, 125.228), QPointF(491.367, 127.007)}
        },
        QPointF(431.459, 167.909),
        QVector<CubicSegment> {
            {QPointF(428.853, 169.688), QPointF(425.305, 169.012), QPointF(423.443, 166.464)},
            {QPointF(409.901, 147.93), QPointF(392.908, 132.161), QPointF(373.379, 120.032)},
            {QPointF(352.23, 106.898), QPointF(328.573, 98.3224), QPointF(303.92, 94.8543)},
            {QPointF(279.267, 91.3863), QPointF(254.162, 93.1021), QPointF(230.211, 99.8919)},
            {QPointF(206.259, 106.682), QPointF(183.988, 118.396), QPointF(164.823, 134.286)},
            {QPointF(145.658, 150.175), QPointF(130.02, 169.89), QPointF(118.911, 192.169)},
            {QPointF(107.801, 214.448), QPointF(101.463, 238.801), QPointF(100.304, 263.669)},
            {QPointF(99.1448, 288.538), QPointF(103.189, 313.374), QPointF(112.178, 336.59)},
            {QPointF(120.478, 358.029), QPointF(132.826, 377.649), QPointF(148.53, 394.39)},
            {QPointF(150.689, 396.691), QPointF(150.697, 400.303), QPointF(148.465, 402.535)}
        },
        QVector<GradientStop> {
            {0.0, QColor(142, 62, 62, 0)},
            {0.1272270232, QColor(142, 62, 62, 0)},
            {0.4711538553, QColor(255, 123, 9)},
            {0.6490384340, QColor(156, 0, 0)},
            {0.6875, QColor(153, 0, 0, 0)},
            {1.0, QColor(142, 62, 62, 0)}
        }
    };
    return definition;
}

const ShapeDefinition &speedShapeDefinition()
{
    static const ShapeDefinition definition {
        QSizeF(480.0, 476.0),
        QPointF(245.0, 238.0),
        90.0,
        QPointF(85.901, 397.099),
        QVector<CubicSegment> {
            {QPointF(83.9484, 399.052), QPointF(80.7782, 399.055), QPointF(78.8685, 397.061)},
            {QPointF(59.1536, 376.47), QPointF(43.4281, 352.381), QPointF(32.5077, 326.017)},
            {QPointF(20.9491, 298.112), QPointF(15.0, 268.204), QPointF(15.0, 238.0)},
            {QPointF(15.0, 207.796), QPointF(20.9491, 177.888), QPointF(32.5077, 149.983)},
            {QPointF(43.4281, 123.619), QPointF(59.1537, 99.5304), QPointF(78.8685, 78.9392)},
            {QPointF(80.7782, 76.9446), QPointF(83.9484, 76.9483), QPointF(85.901, 78.9009)}
        },
        QPointF(130.782, 123.782),
        QVector<CubicSegment> {
            {QPointF(132.735, 125.735), QPointF(132.728, 128.895), QPointF(130.839, 130.909)},
            {QPointF(117.935, 144.664), QPointF(107.614, 160.649), QPointF(100.386, 178.099)},
            {QPointF(92.5201, 197.09), QPointF(88.4713, 217.444), QPointF(88.4713, 238.0)},
            {QPointF(88.4713, 258.556), QPointF(92.52, 278.91), QPointF(100.386, 297.901)},
            {QPointF(107.614, 315.351), QPointF(117.935, 331.336), QPointF(130.839, 345.091)},
            {QPointF(132.728, 347.105), QPointF(132.735, 350.265), QPointF(130.782, 352.218)}
        },
        QVector<GradientStop> {
            {0.0, QColor(142, 62, 62, 0)},
            {0.1272270232, QColor(142, 62, 62, 0)},
            {0.4711538553, QColor(255, 9, 9)},
            {0.6490384340, QColor(156, 0, 0)},
            {0.6875, QColor(153, 0, 0, 0)},
            {1.0, QColor(142, 62, 62, 0)}
        }
    };
    return definition;
}

} // namespace

RaceArcItem::RaceArcItem(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    setAntialiasing(true);
    setOpaquePainting(false);
}

void RaceArcItem::setProgress(qreal value)
{
    const qreal clamped = qBound(0.0, value, 1.0);
    if (qFuzzyCompare(m_progress, clamped))
        return;

    m_progress = clamped;
    update();
    emit appearanceChanged();
}

void RaceArcItem::setShapeMode(const QString &value)
{
    if (m_shapeMode == value)
        return;

    m_shapeMode = value;
    update();
    emit appearanceChanged();
}

void RaceArcItem::setWarningMix(qreal value)
{
    const qreal clamped = qBound(0.0, value, 1.0);
    if (qFuzzyCompare(m_warningMix, clamped))
        return;

    m_warningMix = clamped;
    update();
    emit appearanceChanged();
}

QColor RaceArcItem::applyWarningTint(const QColor &color) const
{
    if (m_warningMix <= 0.0)
        return color;

    return lerpColor(color, QColor(QStringLiteral("#ff0000")), m_warningMix);
}

void RaceArcItem::paint(QPainter *painter)
{
    if (!painter)
        return;

    const QRectF bounds(0.0, 0.0, width(), height());
    if (bounds.width() <= 1.0 || bounds.height() <= 1.0)
        return;

    painter->setRenderHint(QPainter::Antialiasing, true);
    painter->setPen(Qt::NoPen);

    const ShapeDefinition &shapeDefinition = m_shapeMode == QLatin1String("speedSvg")
        ? speedShapeDefinition()
        : tachShapeDefinition();

    const qreal minimumVisibleFraction = minimumVisibleFractionForShape(m_shapeMode);
    const qreal effectiveProgress = minimumVisibleFraction
        + ((1.0 - minimumVisibleFraction) * qBound(0.0, m_progress, 1.0));

    const QPainterPath fillPath = buildTrimmedSvgPath(shapeDefinition, bounds, effectiveProgress);
    if (fillPath.isEmpty())
        return;

    painter->fillPath(fillPath, buildGradient(shapeDefinition, bounds, m_warningMix));
}
