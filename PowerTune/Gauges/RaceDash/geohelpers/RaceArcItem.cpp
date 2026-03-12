#include "RaceArcItem.h"

#include <QSGGeometry>
#include <QSGGeometryNode>
#include <QSGVertexColorMaterial>
#include <QtMath>

namespace {

QColor lerpColor(const QColor &a, const QColor &b, qreal t)
{
    const qreal clamped = qBound(0.0, t, 1.0);
    return QColor::fromRgbF(a.redF() + ((b.redF() - a.redF()) * clamped),
                            a.greenF() + ((b.greenF() - a.greenF()) * clamped),
                            a.blueF() + ((b.blueF() - a.blueF()) * clamped),
                            a.alphaF() + ((b.alphaF() - a.alphaF()) * clamped));
}

QColor withScaledAlpha(const QColor &color, qreal alphaScale)
{
    QColor adjusted(color);
    adjusted.setAlphaF(qBound(0.0, adjusted.alphaF() * alphaScale, 1.0));
    return adjusted;
}

QColor shadedColor(const QColor &color, qreal darkness)
{
    return lerpColor(color, QColor(QStringLiteral("#050505")), qBound(0.0, darkness, 1.0));
}

QColor brightenedColor(const QColor &color, qreal amount)
{
    return lerpColor(color, QColor(QStringLiteral("#ffffff")), qBound(0.0, amount, 1.0));
}

QColor warningTinted(const QColor &color, qreal warningMix)
{
    if (warningMix <= 0.0)
        return color;

    return lerpColor(color, QColor(QStringLiteral("#ff0000")), warningMix);
}

qreal normalizeClockAngle(qreal degrees)
{
    qreal normalized = std::fmod(degrees, 360.0);
    if (normalized < 0.0)
        normalized += 360.0;
    return normalized;
}

qreal clockwiseSweep(qreal startAngle, qreal endAngle)
{
    const qreal start = normalizeClockAngle(startAngle);
    const qreal end = normalizeClockAngle(endAngle);
    qreal sweep = end - start;
    if (sweep < 0.0)
        sweep += 360.0;
    if (qFuzzyIsNull(sweep))
        sweep = 359.999;
    return sweep;
}

QPointF pointForClockAngle(const QPointF &center, qreal radius, qreal clockDegrees)
{
    const qreal radians = qDegreesToRadians(clockDegrees);
    return QPointF(center.x() + (qSin(radians) * radius),
                   center.y() - (qCos(radians) * radius));
}

QColor colorAtFraction(const QColor &startColor,
                       const QColor &midColor,
                       qreal midStop,
                       const QColor &endColor,
                       qreal fraction)
{
    const qreal clamped = qBound(0.0, fraction, 1.0);
    const qreal safeMidStop = qBound(0.0, midStop, 1.0);
    if (!midColor.isValid() || qFuzzyCompare(safeMidStop, 0.0) || qFuzzyCompare(safeMidStop, 1.0))
        return lerpColor(startColor, endColor, clamped);

    if (clamped <= safeMidStop)
        return lerpColor(startColor, midColor, clamped / safeMidStop);

    return lerpColor(midColor, endColor, (clamped - safeMidStop) / (1.0 - safeMidStop));
}

int segmentCountForArc(qreal outerRadius, qreal sweepDegrees)
{
    const qreal arcLength = outerRadius * qDegreesToRadians(qAbs(sweepDegrees));
    return qMax(18, static_cast<int>(qCeil(arcLength / 3.0)));
}

struct ArcSampleProfile
{
    qreal angleFraction;
    qreal widthScale;
    qreal alphaScale;
};

ArcSampleProfile sampleProfileAt(qreal fraction, qreal startTaper, qreal endTaper)
{
    const qreal clampedFraction = qBound(0.0, fraction, 1.0);
    const qreal clampedStartTaper = qBound(0.0, startTaper, 0.49);
    const qreal clampedEndTaper = qBound(0.0, endTaper, 0.49);
    const qreal bodyFraction = qMax(0.0001, 1.0 - clampedStartTaper - clampedEndTaper);

    if (clampedStartTaper > 0.0 && clampedFraction < clampedStartTaper) {
        const qreal local = clampedFraction / clampedStartTaper;
        const qreal eased = qSin(local * (M_PI_2));
        return {0.0, eased, eased};
    }

    if (clampedEndTaper > 0.0 && clampedFraction > (1.0 - clampedEndTaper)) {
        const qreal local = (1.0 - clampedFraction) / clampedEndTaper;
        const qreal eased = qSin(qBound(0.0, local, 1.0) * (M_PI_2));
        return {1.0, eased, eased};
    }

    return {
        qBound(0.0, (clampedFraction - clampedStartTaper) / bodyFraction, 1.0),
        1.0,
        1.0
    };
}

qreal bodyOpacityAt(qreal fraction, const QString &shapeMode)
{
    const qreal clamped = qBound(0.0, fraction, 1.0);
    const qreal ramp = qSin(qMin(1.0, clamped / (shapeMode == QStringLiteral("speedSvg") ? 0.32 : 0.38)) * M_PI_2);
    const qreal startOpacity = shapeMode == QStringLiteral("speedSvg") ? 0.28 : 0.34;
    return qBound(0.0, startOpacity + ((1.0 - startOpacity) * ramp), 1.0);
}

} // namespace

RaceArcItem::RaceArcItem(QQuickItem *parent)
    : QQuickItem(parent)
{
    setFlag(ItemHasContents, true);
    setAntialiasing(true);
}

void RaceArcItem::scheduleUpdate()
{
    update();
    emit appearanceChanged();
}

void RaceArcItem::setProgress(qreal value)
{
    const qreal clamped = qBound(0.0, value, 1.0);
    if (qFuzzyCompare(m_progress, clamped))
        return;

    m_progress = clamped;
    scheduleUpdate();
}

void RaceArcItem::setShapeMode(const QString &value)
{
    if (m_shapeMode == value)
        return;

    m_shapeMode = value;
    scheduleUpdate();
}

void RaceArcItem::setWarningMix(qreal value)
{
    const qreal clamped = qBound(0.0, value, 1.0);
    if (qFuzzyCompare(m_warningMix, clamped))
        return;

    m_warningMix = clamped;
    scheduleUpdate();
}

void RaceArcItem::setStartAngle(qreal value)
{
    if (qFuzzyCompare(m_startAngle, value))
        return;

    m_startAngle = value;
    scheduleUpdate();
}

void RaceArcItem::setEndAngle(qreal value)
{
    if (qFuzzyCompare(m_endAngle, value))
        return;

    m_endAngle = value;
    scheduleUpdate();
}

void RaceArcItem::setArcWidth(qreal value)
{
    const qreal clamped = qBound(0.01, value, 0.95);
    if (qFuzzyCompare(m_arcWidth, clamped))
        return;

    m_arcWidth = clamped;
    scheduleUpdate();
}

void RaceArcItem::setArcScale(qreal value)
{
    const qreal clamped = qBound(0.1, value, 2.0);
    if (qFuzzyCompare(m_arcScale, clamped))
        return;

    m_arcScale = clamped;
    scheduleUpdate();
}

void RaceArcItem::setCenterOffsetX(qreal value)
{
    if (qFuzzyCompare(m_centerOffsetX, value))
        return;

    m_centerOffsetX = value;
    scheduleUpdate();
}

void RaceArcItem::setCenterOffsetY(qreal value)
{
    if (qFuzzyCompare(m_centerOffsetY, value))
        return;

    m_centerOffsetY = value;
    scheduleUpdate();
}

void RaceArcItem::setMinimumVisibleFraction(qreal value)
{
    const qreal clamped = qBound(0.0, value, 0.5);
    if (qFuzzyCompare(m_minimumVisibleFraction, clamped))
        return;

    m_minimumVisibleFraction = clamped;
    scheduleUpdate();
}

void RaceArcItem::setStartTaper(qreal value)
{
    const qreal clamped = qBound(0.0, value, 0.49);
    if (qFuzzyCompare(m_startTaper, clamped))
        return;

    m_startTaper = clamped;
    scheduleUpdate();
}

void RaceArcItem::setEndTaper(qreal value)
{
    const qreal clamped = qBound(0.0, value, 0.49);
    if (qFuzzyCompare(m_endTaper, clamped))
        return;

    m_endTaper = clamped;
    scheduleUpdate();
}

void RaceArcItem::setStartColor(const QColor &value)
{
    if (m_startColor == value)
        return;

    m_startColor = value;
    scheduleUpdate();
}

void RaceArcItem::setMidColor(const QColor &value)
{
    if (m_midColor == value)
        return;

    m_midColor = value;
    scheduleUpdate();
}

void RaceArcItem::setMidColorStop(qreal value)
{
    const qreal clamped = qBound(0.0, value, 1.0);
    if (qFuzzyCompare(m_midColorStop, clamped))
        return;

    m_midColorStop = clamped;
    scheduleUpdate();
}

void RaceArcItem::setEndColor(const QColor &value)
{
    if (m_endColor == value)
        return;

    m_endColor = value;
    scheduleUpdate();
}

QSGNode *RaceArcItem::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *)
{
    auto *node = static_cast<QSGGeometryNode *>(oldNode);
    if (!node) {
        node = new QSGGeometryNode();
        auto *geometry = new QSGGeometry(QSGGeometry::defaultAttributes_ColoredPoint2D(), 0);
        geometry->setDrawingMode(QSGGeometry::DrawTriangleStrip);
        node->setGeometry(geometry);
        node->setFlag(QSGNode::OwnsGeometry, true);

        auto *material = new QSGVertexColorMaterial();
        material->setFlag(QSGMaterial::Blending, true);
        node->setMaterial(material);
        node->setFlag(QSGNode::OwnsMaterial, true);
    }

    auto *geometry = node->geometry();
    const QRectF bounds = boundingRect();
    const qreal minDimension = qMin(bounds.width(), bounds.height());
    const qreal outerRadius = (minDimension * 0.5) * qMax(0.1, m_arcScale);
    const qreal innerRadius = qMax(0.0, outerRadius * (1.0 - qBound(0.01, m_arcWidth, 0.95)));
    const qreal centerRadius = 0.5 * (outerRadius + innerRadius);
    const qreal baseHalfWidth = 0.5 * (outerRadius - innerRadius);
    const qreal sweepDegrees = clockwiseSweep(m_startAngle, m_endAngle);
    const qreal visibleFraction = qBound(0.0,
                                         qMax(m_progress, m_minimumVisibleFraction),
                                         1.0);

    if (outerRadius <= 0.0 || visibleFraction <= 0.0) {
        geometry->allocate(0);
        node->markDirty(QSGNode::DirtyGeometry);
        return node;
    }

    const QPointF center(bounds.center().x() + m_centerOffsetX,
                         bounds.center().y() + m_centerOffsetY);
    const qreal visibleSweep = sweepDegrees * visibleFraction;
    const int segments = segmentCountForArc(outerRadius, visibleSweep);
    const int vertexCount = (segments + 1) * 2;

    geometry->allocate(vertexCount);
    auto *vertices = geometry->vertexDataAsColoredPoint2D();

    const QColor tintedStartColor = warningTinted(m_startColor, m_warningMix);
    const QColor tintedMidColor = warningTinted(m_midColor, m_warningMix);
    const QColor tintedEndColor = warningTinted(m_endColor, m_warningMix);

    for (int i = 0; i <= segments; ++i) {
        const qreal fraction = static_cast<qreal>(i) / static_cast<qreal>(segments);
        const ArcSampleProfile profile = sampleProfileAt(fraction, m_startTaper, m_endTaper);
        const qreal angle = m_startAngle + (visibleSweep * profile.angleFraction);
        const qreal halfWidth = baseHalfWidth * profile.widthScale;
        const qreal taperedOuterRadius = centerRadius + halfWidth;
        const qreal taperedInnerRadius = qMax(0.0, centerRadius - halfWidth);
        const QPointF outerPoint = pointForClockAngle(center, taperedOuterRadius, angle);
        const QPointF innerPoint = pointForClockAngle(center, taperedInnerRadius, angle);
        const QColor baseColor = colorAtFraction(tintedStartColor, tintedMidColor, m_midColorStop, tintedEndColor, profile.angleFraction);
        const qreal bodyOpacity = bodyOpacityAt(fraction, m_shapeMode) * profile.alphaScale;
        const QColor outerColor = withScaledAlpha(brightenedColor(baseColor, m_shapeMode == QStringLiteral("speedSvg") ? 0.06 : 0.04),
                                                  bodyOpacity);
        const QColor innerColor = withScaledAlpha(shadedColor(baseColor, m_shapeMode == QStringLiteral("speedSvg") ? 0.5 : 0.4),
                                                  bodyOpacity * (m_shapeMode == QStringLiteral("speedSvg") ? 0.18 : 0.24));

        vertices[(i * 2)].set(outerPoint.x(), outerPoint.y(),
                              static_cast<uchar>(outerColor.red()),
                              static_cast<uchar>(outerColor.green()),
                              static_cast<uchar>(outerColor.blue()),
                              static_cast<uchar>(outerColor.alpha()));
        vertices[(i * 2) + 1].set(innerPoint.x(), innerPoint.y(),
                                  static_cast<uchar>(innerColor.red()),
                                  static_cast<uchar>(innerColor.green()),
                                  static_cast<uchar>(innerColor.blue()),
                                  static_cast<uchar>(innerColor.alpha()));
    }

    node->markDirty(QSGNode::DirtyGeometry);
    return node;
}
