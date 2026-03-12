#ifndef CANFRAMEMODEL_H
#define CANFRAMEMODEL_H

#include <QAbstractListModel>
#include <QStringList>
#include <QVector>

class ConnectionData;
class Extender;

class CanFrameModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool showAllFrames READ showAllFrames WRITE setShowAllFrames NOTIFY showAllFramesChanged)
    Q_PROPERTY(int messageCount READ messageCount NOTIFY messageCountChanged)

public:
    enum Roles { CanIdRole = Qt::UserRole + 1, PayloadRole };

    explicit CanFrameModel(QObject *parent = nullptr);
    explicit CanFrameModel(ConnectionData *connectionData, Extender *extender, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool showAllFrames() const;
    void setShowAllFrames(bool show);
    int messageCount() const;

signals:
    void showAllFramesChanged();
    void messageCountChanged();

private slots:
    void onCanChanged(const QStringList &can);
    void onBaseIdsChanged();

private:
    struct CanFrame
    {
        QString canId;
        QString payload;
    };

    void rebuildVisible();
    bool isExtenderFrame(const QString &canIdHex) const;

    ConnectionData *m_connectionData = nullptr;
    Extender *m_extender = nullptr;
    bool m_showAllFrames = true;

    QVector<CanFrame> m_allFrames;
    QVector<int> m_visibleIndices;
};

#endif  // CANFRAMEMODEL_H
