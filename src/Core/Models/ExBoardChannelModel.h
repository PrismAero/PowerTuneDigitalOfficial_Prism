#ifndef EXBOARDCHANNELMODEL_H
#define EXBOARDCHANNELMODEL_H

#include <QAbstractListModel>
#include <QSet>
#include <QTimer>
#include <QVector>

class ExBoardConfigManager;
class ExpanderBoardData;

class ExBoardChannelModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        ChannelIndexRole = Qt::UserRole + 1,
        NameRole,
        ChannelEnabledRole,
        NtcEnabledRole,
        PresetNameRole,
        RawVoltageRole,
        CalibratedValueRole,
        RawVoltageTextRole,
        CalibratedValueTextRole,
        VoltageRangeTextRole,
        HasSignalRole
    };

    explicit ExBoardChannelModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setConfigManager(ExBoardConfigManager *manager);
    void setExpanderData(ExpanderBoardData *expander);

    Q_INVOKABLE QVariantMap configAt(int channel) const;
    Q_INVOKABLE qreal rawVoltageAt(int channel) const;
    Q_INVOKABLE qreal calibratedValueAt(int channel) const;
    Q_INVOKABLE void refresh();

private:
    struct RowData
    {
        QVariantMap config;
        qreal rawVoltage = 0.0;
        qreal calibratedValue = 0.0;
    };

    static constexpr int kChannelCount = 8;
    static constexpr int kRefreshIntervalMs = 100;

    ExBoardConfigManager *m_configManager = nullptr;
    ExpanderBoardData *m_expander = nullptr;
    QVector<RowData> m_rows;
    QSet<int> m_dirtyRows;
    QTimer m_updateTimer;

    void loadConfigs();
    void loadLiveValues();
    void connectExpanderSignals();
    void markLiveDirty(int channel);
    void flushLiveUpdates();
};

#endif  // EXBOARDCHANNELMODEL_H
