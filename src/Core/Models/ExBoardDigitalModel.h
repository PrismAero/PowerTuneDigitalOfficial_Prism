#ifndef EXBOARDDIGITALMODEL_H
#define EXBOARDDIGITALMODEL_H

#include <QAbstractListModel>
#include <QSet>
#include <QTimer>
#include <QVector>

class DigitalInputs;
class ExBoardConfigManager;

class ExBoardDigitalModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString tachRpmText READ tachRpmText NOTIFY tachRpmTextChanged)

public:
    enum Roles {
        ChannelIndexRole = Qt::UserRole + 1,
        NameRole,
        ChannelEnabledRole,
        StateHighRole,
        StateTextRole
    };

    explicit ExBoardDigitalModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setConfigManager(ExBoardConfigManager *manager);
    void setDigitalInputs(DigitalInputs *digitalInputs);

    Q_INVOKABLE QVariantMap configAt(int channel) const;
    Q_INVOKABLE bool stateHighAt(int channel) const;
    Q_INVOKABLE QString tachRpmText() const;
    Q_INVOKABLE void refresh();

signals:
    void tachRpmTextChanged();

private:
    struct RowData
    {
        QVariantMap config;
        bool high = false;
    };

    static constexpr int kChannelCount = 8;
    static constexpr int kRefreshIntervalMs = 100;

    ExBoardConfigManager *m_configManager = nullptr;
    DigitalInputs *m_digitalInputs = nullptr;
    QVector<RowData> m_rows;
    QSet<int> m_dirtyRows;
    QTimer m_updateTimer;
    qreal m_tachRpm = 0.0;

    void loadConfigs();
    void loadLiveValues();
    void connectDigitalSignals();
    void markLiveDirty(int channel);
    void flushLiveUpdates();
};

#endif  // EXBOARDDIGITALMODEL_H
