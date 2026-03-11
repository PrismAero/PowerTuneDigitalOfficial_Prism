#ifndef RACEARCITEM_H
#define RACEARCITEM_H

#include <QColor>
#include <QQuickPaintedItem>
#include <QString>

class RaceArcItem : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(qreal progress READ progress WRITE setProgress NOTIFY appearanceChanged)
    Q_PROPERTY(QString shapeMode READ shapeMode WRITE setShapeMode NOTIFY appearanceChanged)
    Q_PROPERTY(qreal warningMix READ warningMix WRITE setWarningMix NOTIFY appearanceChanged)

public:
    explicit RaceArcItem(QQuickItem *parent = nullptr);

    qreal progress() const { return m_progress; }
    void setProgress(qreal value);

    QString shapeMode() const { return m_shapeMode; }
    void setShapeMode(const QString &value);

    qreal warningMix() const { return m_warningMix; }
    void setWarningMix(qreal value);

signals:
    void appearanceChanged();

protected:
    void paint(QPainter *painter) override;

private:
    QColor applyWarningTint(const QColor &color) const;

    qreal m_progress = 0.0;
    QString m_shapeMode = QStringLiteral("tachSvg");
    qreal m_warningMix = 0.0;
};

#endif
