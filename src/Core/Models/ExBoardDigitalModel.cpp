#include "ExBoardDigitalModel.h"

#include "DigitalInputs.h"
#include "ExBoardConfigManager.h"

#include <QtMath>

ExBoardDigitalModel::ExBoardDigitalModel(QObject *parent) : QAbstractListModel(parent)
{
    m_rows.resize(kChannelCount);
    m_updateTimer.setInterval(kRefreshIntervalMs);
    m_updateTimer.setSingleShot(true);
    connect(&m_updateTimer, &QTimer::timeout, this, &ExBoardDigitalModel::flushLiveUpdates);
}

int ExBoardDigitalModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return kChannelCount;
}

QVariant ExBoardDigitalModel::data(const QModelIndex &index, int role) const
{
    const int row = index.row();
    if (!index.isValid() || row < 0 || row >= m_rows.size())
        return {};

    const RowData &rowData = m_rows[row];
    const QVariantMap &cfg = rowData.config;

    switch (role) {
    case ChannelIndexRole:
        return row;
    case NameRole:
        return cfg.value(QStringLiteral("name"), QStringLiteral("---")).toString();
    case ChannelEnabledRole:
        return cfg.value(QStringLiteral("enabled"), true).toBool();
    case StateHighRole:
        return rowData.high;
    case StateTextRole:
        return rowData.high ? QStringLiteral("HIGH") : QStringLiteral("LOW");
    default:
        return {};
    }
}

QHash<int, QByteArray> ExBoardDigitalModel::roleNames() const
{
    return {
        {ChannelIndexRole, "channelIndex"},
        {NameRole, "name"},
        {ChannelEnabledRole, "channelEnabled"},
        {StateHighRole, "stateHigh"},
        {StateTextRole, "stateText"},
    };
}

void ExBoardDigitalModel::setConfigManager(ExBoardConfigManager *manager)
{
    if (m_configManager == manager)
        return;

    if (m_configManager)
        disconnect(m_configManager, nullptr, this, nullptr);

    m_configManager = manager;

    if (m_configManager)
        connect(m_configManager, &ExBoardConfigManager::configChanged, this, &ExBoardDigitalModel::refresh);

    refresh();
}

void ExBoardDigitalModel::setDigitalInputs(DigitalInputs *digitalInputs)
{
    if (m_digitalInputs == digitalInputs)
        return;

    if (m_digitalInputs)
        disconnect(m_digitalInputs, nullptr, this, nullptr);

    m_digitalInputs = digitalInputs;
    connectDigitalSignals();
    loadLiveValues();
}

QVariantMap ExBoardDigitalModel::configAt(int channel) const
{
    if (channel < 0 || channel >= m_rows.size())
        return {};
    return m_rows[channel].config;
}

bool ExBoardDigitalModel::stateHighAt(int channel) const
{
    if (channel < 0 || channel >= m_rows.size())
        return false;
    return m_rows[channel].high;
}

QString ExBoardDigitalModel::tachRpmText() const
{
    return QString::number(qRound(m_tachRpm)) + QStringLiteral(" rpm");
}

void ExBoardDigitalModel::refresh()
{
    beginResetModel();
    loadConfigs();
    loadLiveValues();
    endResetModel();
}

void ExBoardDigitalModel::loadConfigs()
{
    for (int channel = 0; channel < kChannelCount; ++channel) {
        if (m_configManager)
            m_rows[channel].config = m_configManager->getDigitalChannelConfig(channel);
        else
            m_rows[channel].config = {};
    }
}

void ExBoardDigitalModel::loadLiveValues()
{
    if (!m_digitalInputs) {
        for (int i = 0; i < m_rows.size(); ++i)
            m_rows[i].high = false;
        const qreal previousTach = m_tachRpm;
        m_tachRpm = 0.0;
        if (!qFuzzyCompare(previousTach + 1.0, m_tachRpm + 1.0))
            emit tachRpmTextChanged();
        return;
    }

    m_rows[0].high = m_digitalInputs->EXDigitalInput1() > 0.5;
    m_rows[1].high = m_digitalInputs->EXDigitalInput2() > 0.5;
    m_rows[2].high = m_digitalInputs->EXDigitalInput3() > 0.5;
    m_rows[3].high = m_digitalInputs->EXDigitalInput4() > 0.5;
    m_rows[4].high = m_digitalInputs->EXDigitalInput5() > 0.5;
    m_rows[5].high = m_digitalInputs->EXDigitalInput6() > 0.5;
    m_rows[6].high = m_digitalInputs->EXDigitalInput7() > 0.5;
    m_rows[7].high = m_digitalInputs->EXDigitalInput8() > 0.5;
    const qreal previousTach = m_tachRpm;
    m_tachRpm = m_digitalInputs->frequencyDIEX1();
    if (!qFuzzyCompare(previousTach + 1.0, m_tachRpm + 1.0))
        emit tachRpmTextChanged();
}

void ExBoardDigitalModel::connectDigitalSignals()
{
    if (!m_digitalInputs)
        return;

    connect(m_digitalInputs, &DigitalInputs::EXDigitalInput1Changed, this, [this](qreal value) {
        m_rows[0].high = value > 0.5;
        markLiveDirty(0);
    });
    connect(m_digitalInputs, &DigitalInputs::EXDigitalInput2Changed, this, [this](qreal value) {
        m_rows[1].high = value > 0.5;
        markLiveDirty(1);
    });
    connect(m_digitalInputs, &DigitalInputs::EXDigitalInput3Changed, this, [this](qreal value) {
        m_rows[2].high = value > 0.5;
        markLiveDirty(2);
    });
    connect(m_digitalInputs, &DigitalInputs::EXDigitalInput4Changed, this, [this](qreal value) {
        m_rows[3].high = value > 0.5;
        markLiveDirty(3);
    });
    connect(m_digitalInputs, &DigitalInputs::EXDigitalInput5Changed, this, [this](qreal value) {
        m_rows[4].high = value > 0.5;
        markLiveDirty(4);
    });
    connect(m_digitalInputs, &DigitalInputs::EXDigitalInput6Changed, this, [this](qreal value) {
        m_rows[5].high = value > 0.5;
        markLiveDirty(5);
    });
    connect(m_digitalInputs, &DigitalInputs::EXDigitalInput7Changed, this, [this](qreal value) {
        m_rows[6].high = value > 0.5;
        markLiveDirty(6);
    });
    connect(m_digitalInputs, &DigitalInputs::EXDigitalInput8Changed, this, [this](qreal value) {
        m_rows[7].high = value > 0.5;
        markLiveDirty(7);
    });
    connect(m_digitalInputs, &DigitalInputs::frequencyDIEX1Changed, this, [this](qreal value) {
        m_tachRpm = value;
        emit tachRpmTextChanged();
    });
}

void ExBoardDigitalModel::markLiveDirty(int channel)
{
    if (channel < 0 || channel >= m_rows.size())
        return;

    m_dirtyRows.insert(channel);
    if (!m_updateTimer.isActive())
        m_updateTimer.start();
}

void ExBoardDigitalModel::flushLiveUpdates()
{
    if (m_dirtyRows.isEmpty())
        return;

    const QList<int> rows = m_dirtyRows.values();
    m_dirtyRows.clear();

    for (int row : rows) {
        if (row < 0 || row >= m_rows.size())
            continue;
        const QModelIndex mi = index(row);
        emit dataChanged(mi, mi, {StateHighRole, StateTextRole});
    }
}
