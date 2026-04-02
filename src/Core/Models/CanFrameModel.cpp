#include "CanFrameModel.h"

#include "../../Hardware/Extender.h"
#include "ConnectionData.h"

CanFrameModel::CanFrameModel(QObject *parent) : QAbstractListModel(parent) {}

CanFrameModel::CanFrameModel(ConnectionData *connectionData, Extender *extender, QObject *parent)
    : QAbstractListModel(parent), m_connectionData(connectionData), m_extender(extender)
{
    if (m_connectionData)
        connect(m_connectionData, &ConnectionData::canChanged, this, &CanFrameModel::onCanChanged);
    if (m_extender)
        connect(m_extender, &Extender::baseIdsChanged, this, &CanFrameModel::onBaseIdsChanged);
}

int CanFrameModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_showAllFrames ? m_allFrames.size() : m_visibleIndices.size();
}

QVariant CanFrameModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return {};

    int row = index.row();
    const CanFrame *frame = nullptr;

    if (m_showAllFrames) {
        if (row < 0 || row >= m_allFrames.size())
            return {};
        frame = &m_allFrames[row];
    } else {
        if (row < 0 || row >= m_visibleIndices.size())
            return {};
        int allIdx = m_visibleIndices[row];
        if (allIdx < 0 || allIdx >= m_allFrames.size())
            return {};
        frame = &m_allFrames[allIdx];
    }

    switch (role) {
    case CanIdRole:
        return frame->canId;
    case PayloadRole:
        return frame->payload;
    }
    return {};
}

QHash<int, QByteArray> CanFrameModel::roleNames() const
{
    return {{CanIdRole, "canId"}, {PayloadRole, "payload"}};
}

bool CanFrameModel::showAllFrames() const
{
    return m_showAllFrames;
}

void CanFrameModel::setShowAllFrames(bool show)
{
    if (m_showAllFrames == show)
        return;
    m_showAllFrames = show;
    emit showAllFramesChanged();
    rebuildVisible();
}

int CanFrameModel::messageCount() const
{
    return rowCount();
}

void CanFrameModel::onCanChanged(const QStringList &can)
{
    if (can.size() < 2)
        return;

    const QString &canId = can[0];
    const QString &payload = can[1];
    if (canId.isEmpty())
        return;

    int existingIdx = -1;
    for (int i = 0; i < m_allFrames.size(); ++i) {
        if (m_allFrames[i].canId == canId) {
            existingIdx = i;
            break;
        }
    }

    if (existingIdx >= 0) {
        m_allFrames[existingIdx].payload = payload;

        if (m_showAllFrames) {
            QModelIndex mi = index(existingIdx);
            emit dataChanged(mi, mi, {PayloadRole});
        } else {
            for (int v = 0; v < m_visibleIndices.size(); ++v) {
                if (m_visibleIndices[v] == existingIdx) {
                    QModelIndex mi = index(v);
                    emit dataChanged(mi, mi, {PayloadRole});
                    break;
                }
            }
        }
    } else {
        bool extFrame = isExtenderFrame(canId);

        if (m_showAllFrames) {
            beginInsertRows(QModelIndex(), m_allFrames.size(), m_allFrames.size());
            m_allFrames.append({canId, payload});
            endInsertRows();
        } else {
            m_allFrames.append({canId, payload});
            if (extFrame) {
                int newVisRow = m_visibleIndices.size();
                beginInsertRows(QModelIndex(), newVisRow, newVisRow);
                m_visibleIndices.append(m_allFrames.size() - 1);
                endInsertRows();
            }
        }
        emit messageCountChanged();
    }
}

void CanFrameModel::onBaseIdsChanged()
{
    if (!m_showAllFrames)
        rebuildVisible();
}

void CanFrameModel::rebuildVisible()
{
    beginResetModel();
    m_visibleIndices.clear();
    if (!m_showAllFrames) {
        for (int i = 0; i < m_allFrames.size(); ++i) {
            if (isExtenderFrame(m_allFrames[i].canId))
                m_visibleIndices.append(i);
        }
    }
    endResetModel();
    emit messageCountChanged();
}

bool CanFrameModel::isExtenderFrame(const QString &canIdHex) const
{
    if (!m_extender)
        return false;

    int base = m_extender->extenderBaseId();
    int rpmBase = m_extender->rpmBaseId();

    bool ok = false;
    QString stripped = canIdHex;
    if (stripped.startsWith(QLatin1String("0x"), Qt::CaseInsensitive))
        stripped = stripped.mid(2);
    unsigned int id = stripped.toUInt(&ok, 16);
    if (!ok)
        return false;

    if (static_cast<int>(id) == base + 1 || static_cast<int>(id) == base + 2 || static_cast<int>(id) == base + 3)
        return true;

    if (rpmBase > 0 && static_cast<int>(id) == rpmBase + 1)
        return true;

    return false;
}
