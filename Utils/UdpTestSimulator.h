#ifndef UDPTESTSIMULATOR_H
#define UDPTESTSIMULATOR_H

#include <QObject>
#include <QTimer>
#include <QUdpSocket>
#include <QVariantList>

struct SimChannel {
    int ident;
    QString name;
    QString unit;
    qreal minVal;
    qreal maxVal;
    qreal step;
    qreal value;
    bool enabled;
};

class UdpTestSimulator : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)
    Q_PROPERTY(int intervalMs READ intervalMs WRITE setIntervalMs NOTIFY intervalMsChanged)
    Q_PROPERTY(int sweepState READ sweepState NOTIFY sweepStateChanged)
    Q_PROPERTY(bool sweepLooping READ sweepLooping NOTIFY sweepLoopingChanged)
    Q_PROPERTY(QVariantList channels READ channelList NOTIFY channelsChanged)

public:
    explicit UdpTestSimulator(QObject *parent = nullptr);
    ~UdpTestSimulator() override;

    bool running() const;
    void setRunning(bool on);

    int intervalMs() const;
    void setIntervalMs(int ms);

    int sweepState() const;
    bool sweepLooping() const;

    QVariantList channelList() const;

    Q_INVOKABLE void setChannelEnabled(int index, bool enabled);
    Q_INVOKABLE void setChannelValue(int index, qreal value);
    Q_INVOKABLE int channelCount() const;
    Q_INVOKABLE QString channelName(int index) const;
    Q_INVOKABLE QString channelUnit(int index) const;
    Q_INVOKABLE qreal channelMin(int index) const;
    Q_INVOKABLE qreal channelMax(int index) const;
    Q_INVOKABLE qreal channelStep(int index) const;
    Q_INVOKABLE qreal channelValue(int index) const;
    Q_INVOKABLE bool channelEnabled(int index) const;

    Q_INVOKABLE void startSweepTest();
    Q_INVOKABLE void stopSweepTest();

signals:
    void runningChanged();
    void intervalMsChanged();
    void sweepStateChanged();
    void sweepLoopingChanged();
    void channelsChanged();

private slots:
    void sendPackets();
    void advanceSweep();

private:
    void sendDatagram(int ident, qreal value);
    void initChannels();
    void resetSweepChannels();

    QUdpSocket m_socket;
    QTimer m_sendTimer;
    QTimer m_sweepTimer;
    QVector<SimChannel> m_channels;

    bool m_running = false;
    int m_intervalMs = 100;
    bool m_sweepLooping = false;

    enum SweepPhase {
        Idle = 0,
        RampUp,
        Shift1,
        RampDown1,
        RampUp2,
        Shift2,
        RampDown2,
        TempRamp,
        WindDown,
        Done
    };
    SweepPhase m_sweepPhase = Idle;
    int m_sweepTick = 0;

    int findChannel(int ident) const;
};

#endif // UDPTESTSIMULATOR_H
