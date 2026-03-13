#ifndef RACEDASH_RACEARCITEM_H
#define RACEDASH_RACEARCITEM_H

#include <QColor>
#include <QQuickItem>
#include <QString>
#include <qqmlintegration.h>

class QSGNode;

class RaceArcItem : public QQuickItem
{
    Q_OBJECT
    QML_NAMED_ELEMENT(RaceArcItem)

    Q_PROPERTY(qreal progress READ progress WRITE setProgress NOTIFY appearanceChanged)
    Q_PROPERTY(QString shapeMode READ shapeMode WRITE setShapeMode NOTIFY appearanceChanged)
    Q_PROPERTY(qreal warningMix READ warningMix WRITE setWarningMix NOTIFY appearanceChanged)
    Q_PROPERTY(qreal startAngle READ startAngle WRITE setStartAngle NOTIFY appearanceChanged)
    Q_PROPERTY(qreal endAngle READ endAngle WRITE setEndAngle NOTIFY appearanceChanged)
    Q_PROPERTY(qreal arcWidth READ arcWidth WRITE setArcWidth NOTIFY appearanceChanged)
    Q_PROPERTY(qreal arcScale READ arcScale WRITE setArcScale NOTIFY appearanceChanged)
    Q_PROPERTY(qreal centerOffsetX READ centerOffsetX WRITE setCenterOffsetX NOTIFY appearanceChanged)
    Q_PROPERTY(qreal centerOffsetY READ centerOffsetY WRITE setCenterOffsetY NOTIFY appearanceChanged)
    Q_PROPERTY(qreal minimumVisibleFraction READ minimumVisibleFraction WRITE setMinimumVisibleFraction NOTIFY
                   appearanceChanged)
    Q_PROPERTY(qreal startTaper READ startTaper WRITE setStartTaper NOTIFY appearanceChanged)
    Q_PROPERTY(qreal endTaper READ endTaper WRITE setEndTaper NOTIFY appearanceChanged)
    Q_PROPERTY(QColor startColor READ startColor WRITE setStartColor NOTIFY appearanceChanged)
    Q_PROPERTY(QColor midColor READ midColor WRITE setMidColor NOTIFY appearanceChanged)
    Q_PROPERTY(qreal midColorStop READ midColorStop WRITE setMidColorStop NOTIFY appearanceChanged)
    Q_PROPERTY(QColor endColor READ endColor WRITE setEndColor NOTIFY appearanceChanged)

public:
    explicit RaceArcItem(QQuickItem *parent = nullptr);

    qreal progress() const { return m_progress; }
    void setProgress(qreal value);

    QString shapeMode() const { return m_shapeMode; }
    void setShapeMode(const QString &value);

    qreal warningMix() const { return m_warningMix; }
    void setWarningMix(qreal value);

    qreal startAngle() const { return m_startAngle; }
    void setStartAngle(qreal value);

    qreal endAngle() const { return m_endAngle; }
    void setEndAngle(qreal value);

    qreal arcWidth() const { return m_arcWidth; }
    void setArcWidth(qreal value);

    qreal arcScale() const { return m_arcScale; }
    void setArcScale(qreal value);

    qreal centerOffsetX() const { return m_centerOffsetX; }
    void setCenterOffsetX(qreal value);

    qreal centerOffsetY() const { return m_centerOffsetY; }
    void setCenterOffsetY(qreal value);

    qreal minimumVisibleFraction() const { return m_minimumVisibleFraction; }
    void setMinimumVisibleFraction(qreal value);

    qreal startTaper() const { return m_startTaper; }
    void setStartTaper(qreal value);

    qreal endTaper() const { return m_endTaper; }
    void setEndTaper(qreal value);

    QColor startColor() const { return m_startColor; }
    void setStartColor(const QColor &value);

    QColor midColor() const { return m_midColor; }
    void setMidColor(const QColor &value);

    qreal midColorStop() const { return m_midColorStop; }
    void setMidColorStop(qreal value);

    QColor endColor() const { return m_endColor; }
    void setEndColor(const QColor &value);

signals:
    void appearanceChanged();

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) override;

private:
    void scheduleUpdate();

    qreal m_progress = 0.0;
    QString m_shapeMode = QStringLiteral("tachSvg");
    qreal m_warningMix = 0.0;
    qreal m_startAngle = 225.0;
    qreal m_endAngle = 56.0;
    qreal m_arcWidth = 0.285;
    qreal m_arcScale = 0.945;
    qreal m_centerOffsetX = 5.0;
    qreal m_centerOffsetY = 0.0;
    qreal m_minimumVisibleFraction = 0.08;
    qreal m_startTaper = 0.18;
    qreal m_endTaper = 0.18;
    QColor m_startColor = QColor(QStringLiteral("#8F4D17"));
    QColor m_midColor = QColor(QStringLiteral("#FF8A00"));
    qreal m_midColorStop = 0.65;
    QColor m_endColor = QColor(QStringLiteral("#B00000"));
};

#endif
