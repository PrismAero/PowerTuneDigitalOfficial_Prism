#include "UdpTestSimulator.h"

#include <QHostAddress>
#include <QtMath>

static const int UDP_PORT = 45454;
static const int SWEEP_TICK_MS = 50;

UdpTestSimulator::UdpTestSimulator(QObject *parent)
    : QObject(parent)
{
    initChannels();

    connect(&m_sendTimer, &QTimer::timeout, this, &UdpTestSimulator::sendPackets);
    m_sendTimer.setInterval(m_intervalMs);

    connect(&m_sweepTimer, &QTimer::timeout, this, &UdpTestSimulator::advanceSweep);
    m_sweepTimer.setInterval(SWEEP_TICK_MS);
}

UdpTestSimulator::~UdpTestSimulator()
{
    m_sendTimer.stop();
    m_sweepTimer.stop();
}

void UdpTestSimulator::initChannels()
{
    m_channels = {
        {179, "Engine RPM",       "rpm",  0,     12000, 100,  0,    true},
        {199, "Vehicle Speed",    "mph",  0,     300,   1,    0,    true},
        {106, "Gear",             "",     -1,    8,     1,    0,    true},
        {218, "Water Temp",       "F",    0,     260,   1,    80,   true},
        {169, "Oil Pressure",     "PSI",  0,     100,   0.5,  0,    true},
        {210, "TPS",              "%",    0,     100,   1,    0,    false},
        {6,   "AFR",              "",     8,     20,    0.1,  14.7, false},
        {22,  "Boost Pressure",   "kPa",  0,     300,   1,    0,    false},
        {228, "Battery Voltage",  "V",    0,     16,    0.1,  12.6, false},
        {100, "Fuel Pressure",    "kPa",  0,     100,   0.5,  0,    false},
        {135, "Intake Temp",      "F",    0,     260,   1,    0,    false},
        {46,  "Engine Load",      "%",    0,     100,   1,    0,    false},
        {49,  "Flag1 (Fuel Pump)","",     0,     1,     1,    0,    true},
        {50,  "Flag2 (Cool Fan)", "",     0,     1,     1,    0,    true},
    };
}

bool UdpTestSimulator::running() const { return m_running; }

void UdpTestSimulator::setRunning(bool on)
{
    if (m_running == on)
        return;
    m_running = on;
    if (on)
        m_sendTimer.start();
    else
        m_sendTimer.stop();
    emit runningChanged();
}

int UdpTestSimulator::intervalMs() const { return m_intervalMs; }

void UdpTestSimulator::setIntervalMs(int ms)
{
    ms = qBound(20, ms, 1000);
    if (m_intervalMs == ms)
        return;
    m_intervalMs = ms;
    m_sendTimer.setInterval(ms);
    emit intervalMsChanged();
}

int UdpTestSimulator::sweepState() const { return static_cast<int>(m_sweepPhase); }

bool UdpTestSimulator::sweepLooping() const { return m_sweepLooping; }

QVariantList UdpTestSimulator::channelList() const
{
    QVariantList list;
    for (int i = 0; i < m_channels.size(); ++i) {
        QVariantMap m;
        m["index"]   = i;
        m["ident"]   = m_channels[i].ident;
        m["name"]    = m_channels[i].name;
        m["unit"]    = m_channels[i].unit;
        m["min"]     = m_channels[i].minVal;
        m["max"]     = m_channels[i].maxVal;
        m["step"]    = m_channels[i].step;
        m["value"]   = m_channels[i].value;
        m["enabled"] = m_channels[i].enabled;
        list.append(m);
    }
    return list;
}

int UdpTestSimulator::channelCount() const { return m_channels.size(); }

QString UdpTestSimulator::channelName(int index) const
{
    if (index < 0 || index >= m_channels.size()) return {};
    return m_channels[index].name;
}

QString UdpTestSimulator::channelUnit(int index) const
{
    if (index < 0 || index >= m_channels.size()) return {};
    return m_channels[index].unit;
}

qreal UdpTestSimulator::channelMin(int index) const
{
    if (index < 0 || index >= m_channels.size()) return 0;
    return m_channels[index].minVal;
}

qreal UdpTestSimulator::channelMax(int index) const
{
    if (index < 0 || index >= m_channels.size()) return 0;
    return m_channels[index].maxVal;
}

qreal UdpTestSimulator::channelStep(int index) const
{
    if (index < 0 || index >= m_channels.size()) return 1;
    return m_channels[index].step;
}

qreal UdpTestSimulator::channelValue(int index) const
{
    if (index < 0 || index >= m_channels.size()) return 0;
    return m_channels[index].value;
}

bool UdpTestSimulator::channelEnabled(int index) const
{
    if (index < 0 || index >= m_channels.size()) return false;
    return m_channels[index].enabled;
}

void UdpTestSimulator::setChannelEnabled(int index, bool enabled)
{
    if (index < 0 || index >= m_channels.size()) return;
    if (m_channels[index].enabled == enabled) return;
    m_channels[index].enabled = enabled;
    emit channelsChanged();
}

void UdpTestSimulator::setChannelValue(int index, qreal value)
{
    if (index < 0 || index >= m_channels.size()) return;
    value = qBound(m_channels[index].minVal, value, m_channels[index].maxVal);
    if (qFuzzyCompare(m_channels[index].value, value)) return;
    m_channels[index].value = value;
    emit channelsChanged();
}

void UdpTestSimulator::sendPackets()
{
    for (const auto &ch : m_channels) {
        if (ch.enabled)
            sendDatagram(ch.ident, ch.value);
    }
}

void UdpTestSimulator::sendDatagram(int ident, qreal value)
{
    QByteArray data = QStringLiteral("%1,%2").arg(ident).arg(value, 0, 'f', 3).toUtf8();
    m_socket.writeDatagram(data, QHostAddress::LocalHost, UDP_PORT);
}

int UdpTestSimulator::findChannel(int ident) const
{
    for (int i = 0; i < m_channels.size(); ++i) {
        if (m_channels[i].ident == ident)
            return i;
    }
    return -1;
}

void UdpTestSimulator::startSweepTest()
{
    m_sweepTimer.stop();
    m_sweepLooping = true;
    emit sweepLoopingChanged();
    resetSweepChannels();
    m_sweepPhase = RampUp;
    m_sweepTick = 0;
    setRunning(true);
    m_sweepTimer.start();
    emit sweepStateChanged();
    emit channelsChanged();
}

void UdpTestSimulator::stopSweepTest()
{
    m_sweepTimer.stop();
    m_sweepLooping = false;
    m_sweepPhase = Idle;
    m_sweepTick = 0;
    emit sweepLoopingChanged();
    emit sweepStateChanged();
}

void UdpTestSimulator::resetSweepChannels()
{
    int rpmIdx   = findChannel(179);
    int speedIdx = findChannel(199);
    int gearIdx  = findChannel(106);
    int flag1Idx = findChannel(49);
    int flag2Idx = findChannel(50);
    int wtIdx    = findChannel(218);
    int oilIdx   = findChannel(169);

    if (rpmIdx >= 0)   { m_channels[rpmIdx].value = 0;   m_channels[rpmIdx].enabled = true; }
    if (speedIdx >= 0) { m_channels[speedIdx].value = 0;  m_channels[speedIdx].enabled = true; }
    if (gearIdx >= 0)  { m_channels[gearIdx].value = 1;   m_channels[gearIdx].enabled = true; }
    if (flag1Idx >= 0) { m_channels[flag1Idx].value = 1;  m_channels[flag1Idx].enabled = true; }
    if (flag2Idx >= 0) { m_channels[flag2Idx].value = 1;  m_channels[flag2Idx].enabled = true; }
    if (wtIdx >= 0)    { m_channels[wtIdx].value = 60;    m_channels[wtIdx].enabled = true; }
    if (oilIdx >= 0)   { m_channels[oilIdx].value = 20;   m_channels[oilIdx].enabled = true; }
}

void UdpTestSimulator::advanceSweep()
{
    ++m_sweepTick;
    int rpmIdx   = findChannel(179);
    int speedIdx = findChannel(199);
    int gearIdx  = findChannel(106);
    int wtIdx    = findChannel(218);
    int oilIdx   = findChannel(169);

    const int ticksPerPhase = 60; // 3 seconds at 50ms ticks
    const int shortPhase = 16;    // 0.8 seconds
    qreal t = static_cast<qreal>(m_sweepTick) / ticksPerPhase;

    switch (m_sweepPhase) {
    case RampUp:
        if (rpmIdx >= 0)   m_channels[rpmIdx].value = t * 9000.0;
        if (speedIdx >= 0) m_channels[speedIdx].value = t * 180.0;
        if (m_sweepTick >= ticksPerPhase) { m_sweepPhase = Shift1; m_sweepTick = 0; }
        break;

    case Shift1:
        if (gearIdx >= 0) m_channels[gearIdx].value = 2;
        if (m_sweepTick >= 10) { m_sweepPhase = RampDown1; m_sweepTick = 0; }
        break;

    case RampDown1:
        t = static_cast<qreal>(m_sweepTick) / shortPhase;
        if (rpmIdx >= 0) m_channels[rpmIdx].value = 9000.0 - t * 5000.0;
        if (m_sweepTick >= shortPhase) { m_sweepPhase = RampUp2; m_sweepTick = 0; }
        break;

    case RampUp2:
        t = static_cast<qreal>(m_sweepTick) / 40;
        if (rpmIdx >= 0) m_channels[rpmIdx].value = 4000.0 + t * 4500.0;
        if (m_sweepTick >= 40) { m_sweepPhase = Shift2; m_sweepTick = 0; }
        break;

    case Shift2:
        if (gearIdx >= 0) m_channels[gearIdx].value = 3;
        if (m_sweepTick >= 10) { m_sweepPhase = RampDown2; m_sweepTick = 0; }
        break;

    case RampDown2:
        t = static_cast<qreal>(m_sweepTick) / shortPhase;
        if (rpmIdx >= 0) m_channels[rpmIdx].value = 8500.0 - t * 5000.0;
        if (m_sweepTick >= shortPhase) { m_sweepPhase = TempRamp; m_sweepTick = 0; }
        break;

    case TempRamp:
        t = static_cast<qreal>(m_sweepTick) / 80;
        if (wtIdx >= 0)  m_channels[wtIdx].value  = 60.0 + t * 125.0;
        if (oilIdx >= 0) m_channels[oilIdx].value = 20.0 + t * 34.0;
        if (m_sweepTick >= 80) { m_sweepPhase = WindDown; m_sweepTick = 0; }
        break;

    case WindDown:
        t = static_cast<qreal>(m_sweepTick) / 40;
        if (rpmIdx >= 0)   m_channels[rpmIdx].value   = qMax(0.0, 3500.0 - t * 3500.0);
        if (speedIdx >= 0) m_channels[speedIdx].value = qMax(0.0, 180.0 - t * 180.0);
        if (m_sweepTick >= 40) { m_sweepPhase = Done; m_sweepTick = 0; }
        break;

    case Done:
        if (gearIdx >= 0) m_channels[gearIdx].value = 0;
        if (m_sweepLooping) {
            resetSweepChannels();
            m_sweepPhase = RampUp;
            m_sweepTick = 0;
            emit sweepStateChanged();
        } else {
            stopSweepTest();
            setRunning(false);
        }
        break;

    case Idle:
        break;
    }

    emit channelsChanged();
}
