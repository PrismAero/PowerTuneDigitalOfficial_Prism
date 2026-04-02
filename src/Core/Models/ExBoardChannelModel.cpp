#include "ExBoardChannelModel.h"

#include "ExpanderBoardData.h"
#include "ExBoardConfigManager.h"

ExBoardChannelModel::ExBoardChannelModel(QObject *parent) : QAbstractListModel(parent)
{
    m_rows.resize(kChannelCount);
    m_updateTimer.setInterval(kRefreshIntervalMs);
    m_updateTimer.setSingleShot(true);
    connect(&m_updateTimer, &QTimer::timeout, this, &ExBoardChannelModel::flushLiveUpdates);
}

int ExBoardChannelModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return kChannelCount;
}

QVariant ExBoardChannelModel::data(const QModelIndex &index, int role) const
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
    case NtcEnabledRole:
        return cfg.value(QStringLiteral("ntcEnabled"), false).toBool();
    case PresetNameRole:
        if (cfg.value(QStringLiteral("ntcEnabled"), false).toBool())
            return cfg.value(QStringLiteral("ntcPreset"), QStringLiteral("Custom")).toString();
        return cfg.value(QStringLiteral("linearPreset"), QStringLiteral("Custom")).toString();
    case RawVoltageRole:
        return rowData.rawVoltage;
    case CalibratedValueRole:
        return rowData.calibratedValue;
    case RawVoltageTextRole:
        return QString::number(rowData.rawVoltage, 'f', 3);
    case CalibratedValueTextRole:
        return QString::number(rowData.calibratedValue, 'f', 2);
    case VoltageRangeTextRole: {
        const QString minV = cfg.value(QStringLiteral("minVoltage"), QStringLiteral("0.0")).toString();
        const QString maxV = cfg.value(QStringLiteral("maxVoltage"), QStringLiteral("5.0")).toString();
        return minV + QStringLiteral(" - ") + maxV + QStringLiteral(" V");
    }
    case HasSignalRole:
        return rowData.rawVoltage > 0.001;
    default:
        return {};
    }
}

QHash<int, QByteArray> ExBoardChannelModel::roleNames() const
{
    return {
        {ChannelIndexRole, "channelIndex"},
        {NameRole, "name"},
        {ChannelEnabledRole, "channelEnabled"},
        {NtcEnabledRole, "ntcEnabled"},
        {PresetNameRole, "presetName"},
        {RawVoltageRole, "rawVoltage"},
        {CalibratedValueRole, "calibratedValue"},
        {RawVoltageTextRole, "rawVoltageText"},
        {CalibratedValueTextRole, "calibratedValueText"},
        {VoltageRangeTextRole, "voltageRangeText"},
        {HasSignalRole, "hasSignal"},
    };
}

void ExBoardChannelModel::setConfigManager(ExBoardConfigManager *manager)
{
    if (m_configManager == manager)
        return;

    if (m_configManager)
        disconnect(m_configManager, nullptr, this, nullptr);

    m_configManager = manager;

    if (m_configManager)
        connect(m_configManager, &ExBoardConfigManager::configChanged, this, &ExBoardChannelModel::refresh);

    refresh();
}

void ExBoardChannelModel::setExpanderData(ExpanderBoardData *expander)
{
    if (m_expander == expander)
        return;

    if (m_expander)
        disconnect(m_expander, nullptr, this, nullptr);

    m_expander = expander;
    connectExpanderSignals();
    loadLiveValues();
}

QVariantMap ExBoardChannelModel::configAt(int channel) const
{
    if (channel < 0 || channel >= m_rows.size())
        return {};
    return m_rows[channel].config;
}

qreal ExBoardChannelModel::rawVoltageAt(int channel) const
{
    if (channel < 0 || channel >= m_rows.size())
        return 0.0;
    return m_rows[channel].rawVoltage;
}

qreal ExBoardChannelModel::calibratedValueAt(int channel) const
{
    if (channel < 0 || channel >= m_rows.size())
        return 0.0;
    return m_rows[channel].calibratedValue;
}

void ExBoardChannelModel::refresh()
{
    beginResetModel();
    loadConfigs();
    loadLiveValues();
    endResetModel();
}

void ExBoardChannelModel::loadConfigs()
{
    for (int channel = 0; channel < kChannelCount; ++channel) {
        if (m_configManager)
            m_rows[channel].config = m_configManager->getChannelConfig(channel);
        else
            m_rows[channel].config = {};
    }
}

void ExBoardChannelModel::loadLiveValues()
{
    for (int channel = 0; channel < kChannelCount; ++channel) {
        if (!m_expander) {
            m_rows[channel].rawVoltage = 0.0;
            m_rows[channel].calibratedValue = 0.0;
            continue;
        }

        switch (channel) {
        case 0:
            m_rows[channel].rawVoltage = m_expander->EXAnalogInput0();
            m_rows[channel].calibratedValue = m_expander->EXAnalogCalc0();
            break;
        case 1:
            m_rows[channel].rawVoltage = m_expander->EXAnalogInput1();
            m_rows[channel].calibratedValue = m_expander->EXAnalogCalc1();
            break;
        case 2:
            m_rows[channel].rawVoltage = m_expander->EXAnalogInput2();
            m_rows[channel].calibratedValue = m_expander->EXAnalogCalc2();
            break;
        case 3:
            m_rows[channel].rawVoltage = m_expander->EXAnalogInput3();
            m_rows[channel].calibratedValue = m_expander->EXAnalogCalc3();
            break;
        case 4:
            m_rows[channel].rawVoltage = m_expander->EXAnalogInput4();
            m_rows[channel].calibratedValue = m_expander->EXAnalogCalc4();
            break;
        case 5:
            m_rows[channel].rawVoltage = m_expander->EXAnalogInput5();
            m_rows[channel].calibratedValue = m_expander->EXAnalogCalc5();
            break;
        case 6:
            m_rows[channel].rawVoltage = m_expander->EXAnalogInput6();
            m_rows[channel].calibratedValue = m_expander->EXAnalogCalc6();
            break;
        case 7:
            m_rows[channel].rawVoltage = m_expander->EXAnalogInput7();
            m_rows[channel].calibratedValue = m_expander->EXAnalogCalc7();
            break;
        default:
            break;
        }
    }
}

void ExBoardChannelModel::connectExpanderSignals()
{
    if (!m_expander)
        return;

    connect(m_expander, &ExpanderBoardData::EXAnalogInput0Changed, this, [this](qreal value) {
        m_rows[0].rawVoltage = value;
        markLiveDirty(0);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogInput1Changed, this, [this](qreal value) {
        m_rows[1].rawVoltage = value;
        markLiveDirty(1);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogInput2Changed, this, [this](qreal value) {
        m_rows[2].rawVoltage = value;
        markLiveDirty(2);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogInput3Changed, this, [this](qreal value) {
        m_rows[3].rawVoltage = value;
        markLiveDirty(3);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogInput4Changed, this, [this](qreal value) {
        m_rows[4].rawVoltage = value;
        markLiveDirty(4);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogInput5Changed, this, [this](qreal value) {
        m_rows[5].rawVoltage = value;
        markLiveDirty(5);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogInput6Changed, this, [this](qreal value) {
        m_rows[6].rawVoltage = value;
        markLiveDirty(6);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogInput7Changed, this, [this](qreal value) {
        m_rows[7].rawVoltage = value;
        markLiveDirty(7);
    });

    connect(m_expander, &ExpanderBoardData::EXAnalogCalc0Changed, this, [this](qreal value) {
        m_rows[0].calibratedValue = value;
        markLiveDirty(0);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogCalc1Changed, this, [this](qreal value) {
        m_rows[1].calibratedValue = value;
        markLiveDirty(1);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogCalc2Changed, this, [this](qreal value) {
        m_rows[2].calibratedValue = value;
        markLiveDirty(2);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogCalc3Changed, this, [this](qreal value) {
        m_rows[3].calibratedValue = value;
        markLiveDirty(3);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogCalc4Changed, this, [this](qreal value) {
        m_rows[4].calibratedValue = value;
        markLiveDirty(4);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogCalc5Changed, this, [this](qreal value) {
        m_rows[5].calibratedValue = value;
        markLiveDirty(5);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogCalc6Changed, this, [this](qreal value) {
        m_rows[6].calibratedValue = value;
        markLiveDirty(6);
    });
    connect(m_expander, &ExpanderBoardData::EXAnalogCalc7Changed, this, [this](qreal value) {
        m_rows[7].calibratedValue = value;
        markLiveDirty(7);
    });
}

void ExBoardChannelModel::markLiveDirty(int channel)
{
    if (channel < 0 || channel >= m_rows.size())
        return;

    m_dirtyRows.insert(channel);
    if (!m_updateTimer.isActive())
        m_updateTimer.start();
}

void ExBoardChannelModel::flushLiveUpdates()
{
    if (m_dirtyRows.isEmpty())
        return;

    const QList<int> rows = m_dirtyRows.values();
    m_dirtyRows.clear();

    for (int row : rows) {
        if (row < 0 || row >= m_rows.size())
            continue;

        const QModelIndex mi = index(row);
        emit dataChanged(mi, mi,
                         {RawVoltageRole, CalibratedValueRole, RawVoltageTextRole, CalibratedValueTextRole,
                          HasSignalRole});
    }
}
