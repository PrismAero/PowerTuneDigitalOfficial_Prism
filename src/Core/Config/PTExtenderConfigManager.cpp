#include "PTExtenderConfigManager.h"

#include "../../Can/Protocols/PTExtenderCan.h"
#include "AppSettings.h"

#include <algorithm>
#include <QColor>

namespace {
static const int kKnownDfiCodes[] = {11, 12, 13, 14, 15, 21, 23, 24, 25, 31, 32, 33, 34, 35,
                                     36, 39, 46, 51, 52, 53, 54, 56, 62, 63, 64, 67, 83};
constexpr int kLedChannelCount = 16;
constexpr int kIndicatorProfileCount = 2;
constexpr int kIndicatorStateCount = 8;
}

PTExtenderConfigManager::PTExtenderConfigManager(QObject *parent) : QObject(parent)
{
    m_rebootTimer.setSingleShot(true);
    m_rebootTimer.setInterval(500);
    connect(&m_rebootTimer, &QTimer::timeout, this, [this]() {
        if (m_ptExtenderCan)
            m_ptExtenderCan->rebootDevice();
        m_configModeActive = false;
        m_metadataLoaded = false;
        m_metadata.clear();
        m_assemblyBuffer.clear();
        emit configModeActiveChanged();
        emit metadataLoadedChanged();
    });
}

void PTExtenderConfigManager::setPTExtenderCan(PTExtenderCan *can)
{
    if (m_ptExtenderCan == can)
        return;

    if (m_ptExtenderCan)
        disconnect(m_ptExtenderCan, nullptr, this, nullptr);
    m_ptExtenderCan = can;

    if (!m_ptExtenderCan)
        return;

    connect(m_ptExtenderCan, &PTExtenderCan::metadataReceived,
            this, &PTExtenderConfigManager::onMetadataReceived);

    if (!m_appSettings)
        return;

    connect(m_ptExtenderCan, &PTExtenderCan::configResponseReceived, this, [this](int group, int index, int sub, const QByteArray &data) {
        if (!m_appSettings)
            return;

        if (group == PTExtenderCan::ConfigGroupLed && index >= 0 && index < 16) {
            const QString base = QStringLiteral("ui/ptextender/led/%1/").arg(index);
            if (sub == 0x00 && data.size() >= 5) {
                m_appSettings->setValue(base + QStringLiteral("rgbGroup"), static_cast<unsigned char>(data[0]));
                m_appSettings->setValue(base + QStringLiteral("rgbChannel"), static_cast<unsigned char>(data[1]));
                m_appSettings->setValue(base + QStringLiteral("onBrightness"), static_cast<unsigned char>(data[2]));
                m_appSettings->setValue(base + QStringLiteral("pattern"), static_cast<unsigned char>(data[3]));
                m_appSettings->setValue(base + QStringLiteral("enabled"), static_cast<unsigned char>(data[4]) != 0);
            } else if (sub == 0x01 && data.size() >= 5) {
                m_appSettings->setValue(base + QStringLiteral("overrideR"), static_cast<unsigned char>(data[0]));
                m_appSettings->setValue(base + QStringLiteral("overrideG"), static_cast<unsigned char>(data[1]));
                m_appSettings->setValue(base + QStringLiteral("overrideB"), static_cast<unsigned char>(data[2]));
                m_appSettings->setValue(base + QStringLiteral("overridePattern"), static_cast<unsigned char>(data[3]));
                m_appSettings->setValue(base + QStringLiteral("overrideScope"), static_cast<unsigned char>(data[4]));
            } else if (sub == 0x02 && data.size() >= 3) {
                m_appSettings->setValue(base + QStringLiteral("overrideR2"), static_cast<unsigned char>(data[0]));
                m_appSettings->setValue(base + QStringLiteral("overrideG2"), static_cast<unsigned char>(data[1]));
                m_appSettings->setValue(base + QStringLiteral("overrideB2"), static_cast<unsigned char>(data[2]));
            } else if (sub == 0x03 && data.size() >= 1) {
                m_appSettings->setValue(base + QStringLiteral("quickBindInput"), static_cast<qint8>(data[0]));
            } else if (sub >= 0x10 && sub <= 0x13 && data.size() >= 1) {
                QString name = m_appSettings->getValue(base + QStringLiteral("name"), QStringLiteral("LED %1").arg(index)).toString();
                if (name.size() < 16)
                    name = name.leftJustified(16, QChar('\0'));
                const int offset = (sub == 0x10) ? 0 : (sub == 0x11) ? 5 : (sub == 0x12) ? 10 : 15;
                const int len = (sub == 0x13) ? 1 : 5;
                QByteArray chunk = data.left(len);
                for (int i = 0; i < len && i < chunk.size(); ++i)
                    name[offset + i] = QChar::fromLatin1(chunk.at(i));
                m_appSettings->setValue(base + QStringLiteral("name"), name.trimmed());
            } else if (sub == 0x20 && data.size() >= 2) {
                m_appSettings->setValue(base + QStringLiteral("rule/enabled"), static_cast<unsigned char>(data[0]) != 0);
                m_appSettings->setValue(base + QStringLiteral("rule/conditionCount"), static_cast<unsigned char>(data[1]));
            } else if (sub >= 0x21 && sub <= 0x24 && data.size() >= 5) {
                const int cond = sub - 0x21;
                m_appSettings->setValue(base + QStringLiteral("rule/cond%1/type").arg(cond), static_cast<unsigned char>(data[0]));
                m_appSettings->setValue(base + QStringLiteral("rule/cond%1/channel").arg(cond), static_cast<unsigned char>(data[1]));
                const int threshold = (static_cast<unsigned char>(data[3]) << 8) | static_cast<unsigned char>(data[2]);
                m_appSettings->setValue(base + QStringLiteral("rule/cond%1/threshold").arg(cond), threshold);
                m_appSettings->setValue(base + QStringLiteral("rule/cond%1/enabled").arg(cond), static_cast<unsigned char>(data[4]) != 0);
            } else if (sub == 0x25 && data.size() >= 3) {
                m_appSettings->setValue(base + QStringLiteral("rule/op0"), static_cast<unsigned char>(data[0]));
                m_appSettings->setValue(base + QStringLiteral("rule/op1"), static_cast<unsigned char>(data[1]));
                m_appSettings->setValue(base + QStringLiteral("rule/op2"), static_cast<unsigned char>(data[2]));
            }
        } else if (group == PTExtenderCan::ConfigGroupIndicator && (index == 0 || index == 1)) {
            const QString pfx = QStringLiteral("ui/ptextender/indicator/%1/").arg(index);
            if (sub == 0x00 && data.size() >= 5) {
                m_appSettings->setValue(pfx + QStringLiteral("enabled"), static_cast<unsigned char>(data[0]) != 0);
                m_appSettings->setValue(pfx + QStringLiteral("type"), static_cast<unsigned char>(data[1]));
                m_appSettings->setValue(pfx + QStringLiteral("ch1"), static_cast<unsigned char>(data[2]));
                m_appSettings->setValue(pfx + QStringLiteral("ch2"), static_cast<unsigned char>(data[3]));
                m_appSettings->setValue(pfx + QStringLiteral("ch3"), static_cast<unsigned char>(data[4]));
            } else if (sub >= 0x10 && sub <= 0x17 && data.size() >= 5) {
                const int state = sub - 0x10;
                const QString epfx = pfx + QStringLiteral("effect/%1/").arg(state);
                m_appSettings->setValue(epfx + QStringLiteral("pattern"), static_cast<unsigned char>(data[0]));
                m_appSettings->setValue(epfx + QStringLiteral("intensity"), static_cast<unsigned char>(data[1]));
                m_appSettings->setValue(epfx + QStringLiteral("r"), static_cast<unsigned char>(data[2]));
                m_appSettings->setValue(epfx + QStringLiteral("g"), static_cast<unsigned char>(data[3]));
                m_appSettings->setValue(epfx + QStringLiteral("b"), static_cast<unsigned char>(data[4]));
            } else if (sub >= 0x20 && sub <= 0x27 && data.size() >= 4) {
                const int state = sub - 0x20;
                const QString epfx = pfx + QStringLiteral("effect/%1/").arg(state);
                const int p1 = (static_cast<unsigned char>(data[1]) << 8) | static_cast<unsigned char>(data[0]);
                const int p2 = (static_cast<unsigned char>(data[3]) << 8) | static_cast<unsigned char>(data[2]);
                m_appSettings->setValue(epfx + QStringLiteral("p1"), p1);
                m_appSettings->setValue(epfx + QStringLiteral("p2"), p2);
            }
        }
        emit configChanged();
    });
}

QVariantMap PTExtenderConfigManager::loadAllSettings() const
{
    if (!m_appSettings)
        return {};

    QVariantMap config;
    config[QStringLiteral("enabled")] = m_appSettings->getValue(QStringLiteral("ui/ptextender/enabled"), false).toBool();
    config[QStringLiteral("canBase")] = m_appSettings->getValue(QStringLiteral("ui/ptextender/canBase"), 0).toInt();

    QVariantMap system;
    system[QStringLiteral("deviceName")] =
        m_appSettings->getValue(QStringLiteral("ui/ptextender/system/deviceName"), QStringLiteral("PTExtender")).toString();
    system[QStringLiteral("faultEnable")] =
        m_appSettings->getValue(QStringLiteral("ui/ptextender/system/faultEnable"), true).toBool();
    config[QStringLiteral("system")] = system;

    QVariantMap timing;
    timing[QStringLiteral("crankDuration")] =
        m_appSettings->getValue(QStringLiteral("ui/ptextender/timing/crankDuration"), 1000).toInt();
    timing[QStringLiteral("runningProofTime")] =
        m_appSettings->getValue(QStringLiteral("ui/ptextender/timing/runningProofTime"), 3000).toInt();
    timing[QStringLiteral("maxCrankTime")] =
        m_appSettings->getValue(QStringLiteral("ui/ptextender/timing/maxCrankTime"), 6000).toInt();
    timing[QStringLiteral("maxStartTime")] =
        m_appSettings->getValue(QStringLiteral("ui/ptextender/timing/maxStartTime"), 10000).toInt();
    config[QStringLiteral("timing")] = timing;

    QVariantList gpi;
    for (int i = 0; i < 4; ++i)
        gpi.append(m_appSettings->getValue(QStringLiteral("ui/ptextender/gpi/%1/function").arg(i), 0).toInt());
    config[QStringLiteral("gpiFunctions")] = gpi;

    QVariantList relay;
    for (int i = 0; i < 4; ++i)
        relay.append(m_appSettings->getValue(QStringLiteral("ui/ptextender/relay/%1/function").arg(i), 0).toInt());
    config[QStringLiteral("relayFunctions")] = relay;

    QVariantList ledChannels;
    for (int ch = 0; ch < 16; ++ch) {
        QVariantMap led;
        const QString base = QStringLiteral("ui/ptextender/led/%1/").arg(ch);
        led[QStringLiteral("name")] = m_appSettings->getValue(base + QStringLiteral("name"), QStringLiteral("LED %1").arg(ch)).toString();
        led[QStringLiteral("rgbGroup")] = m_appSettings->getValue(base + QStringLiteral("rgbGroup"), 0).toInt();
        led[QStringLiteral("rgbChannel")] = m_appSettings->getValue(base + QStringLiteral("rgbChannel"), 0).toInt();
        led[QStringLiteral("onBrightness")] = m_appSettings->getValue(base + QStringLiteral("onBrightness"), 255).toInt();
        led[QStringLiteral("pattern")] = m_appSettings->getValue(base + QStringLiteral("pattern"), 0).toInt();
        led[QStringLiteral("enabled")] = m_appSettings->getValue(base + QStringLiteral("enabled"), ch < 14).toBool();
        led[QStringLiteral("quickBindInput")] = m_appSettings->getValue(base + QStringLiteral("quickBindInput"), -1).toInt();
        led[QStringLiteral("overrideR")] = m_appSettings->getValue(base + QStringLiteral("overrideR"), 255).toInt();
        led[QStringLiteral("overrideG")] = m_appSettings->getValue(base + QStringLiteral("overrideG"), 0).toInt();
        led[QStringLiteral("overrideB")] = m_appSettings->getValue(base + QStringLiteral("overrideB"), 0).toInt();
        led[QStringLiteral("overrideR2")] = m_appSettings->getValue(base + QStringLiteral("overrideR2"), 0).toInt();
        led[QStringLiteral("overrideG2")] = m_appSettings->getValue(base + QStringLiteral("overrideG2"), 0).toInt();
        led[QStringLiteral("overrideB2")] = m_appSettings->getValue(base + QStringLiteral("overrideB2"), 255).toInt();
        led[QStringLiteral("overridePattern")] = m_appSettings->getValue(base + QStringLiteral("overridePattern"), 2).toInt();
        led[QStringLiteral("overrideScope")] = m_appSettings->getValue(base + QStringLiteral("overrideScope"), 1).toInt();

        QVariantMap rule;
        rule[QStringLiteral("enabled")] = m_appSettings->getValue(base + QStringLiteral("rule/enabled"), false).toBool();
        rule[QStringLiteral("conditionCount")] = m_appSettings->getValue(base + QStringLiteral("rule/conditionCount"), 1).toInt();
        QVariantList conditions;
        for (int cond = 0; cond < 4; ++cond) {
            QVariantMap c;
            c[QStringLiteral("type")] = m_appSettings->getValue(base + QStringLiteral("rule/cond%1/type").arg(cond), 0).toInt();
            c[QStringLiteral("channel")] = m_appSettings->getValue(base + QStringLiteral("rule/cond%1/channel").arg(cond), 0).toInt();
            c[QStringLiteral("threshold")] = m_appSettings->getValue(base + QStringLiteral("rule/cond%1/threshold").arg(cond), 0).toInt();
            c[QStringLiteral("enabled")] = m_appSettings->getValue(base + QStringLiteral("rule/cond%1/enabled").arg(cond), cond == 0).toBool();
            conditions.append(c);
        }
        rule[QStringLiteral("conditions")] = conditions;
        QVariantList operators;
        operators.append(m_appSettings->getValue(base + QStringLiteral("rule/op0"), 1).toInt());
        operators.append(m_appSettings->getValue(base + QStringLiteral("rule/op1"), 1).toInt());
        operators.append(m_appSettings->getValue(base + QStringLiteral("rule/op2"), 1).toInt());
        rule[QStringLiteral("operators")] = operators;
        led[QStringLiteral("rule")] = rule;

        ledChannels.append(led);
    }
    config[QStringLiteral("ledChannels")] = ledChannels;

    QVariantList indicators;
    for (int profile = 0; profile < 2; ++profile) {
        QVariantMap profileMap;
        const QString pfx = QStringLiteral("ui/ptextender/indicator/%1/").arg(profile);
        profileMap[QStringLiteral("enabled")] = m_appSettings->getValue(pfx + QStringLiteral("enabled"), true).toBool();
        profileMap[QStringLiteral("type")] = m_appSettings->getValue(pfx + QStringLiteral("type"), 1).toInt();
        profileMap[QStringLiteral("ch1")] = m_appSettings->getValue(pfx + QStringLiteral("ch1"), profile == 0 ? 1 : 0).toInt();
        profileMap[QStringLiteral("ch2")] = m_appSettings->getValue(pfx + QStringLiteral("ch2"), profile == 0 ? 2 : 4).toInt();
        profileMap[QStringLiteral("ch3")] = m_appSettings->getValue(pfx + QStringLiteral("ch3"), profile == 0 ? 3 : 5).toInt();

        QVariantList effects;
        for (int state = 0; state < 8; ++state) {
            QVariantMap effect;
            const QString epfx = pfx + QStringLiteral("effect/%1/").arg(state);
            effect[QStringLiteral("pattern")] = m_appSettings->getValue(epfx + QStringLiteral("pattern"), state == 0 ? 3 : 1).toInt();
            effect[QStringLiteral("intensity")] = m_appSettings->getValue(epfx + QStringLiteral("intensity"), 180).toInt();
            effect[QStringLiteral("r")] = m_appSettings->getValue(epfx + QStringLiteral("r"), 0).toInt();
            effect[QStringLiteral("g")] = m_appSettings->getValue(epfx + QStringLiteral("g"), 0).toInt();
            effect[QStringLiteral("b")] = m_appSettings->getValue(epfx + QStringLiteral("b"), 255).toInt();
            effect[QStringLiteral("p1")] = m_appSettings->getValue(epfx + QStringLiteral("p1"), 1200).toInt();
            effect[QStringLiteral("p2")] = m_appSettings->getValue(epfx + QStringLiteral("p2"), 0).toInt();
            effects.append(effect);
        }
        profileMap[QStringLiteral("effects")] = effects;
        indicators.append(profileMap);
    }
    config[QStringLiteral("indicators")] = indicators;

    config[QStringLiteral("suppressedCodes")] = suppressedCodes();
    return config;
}

void PTExtenderConfigManager::saveAllSettings(const QVariantMap &config)
{
    if (!m_appSettings)
        return;

    if (config.contains(QStringLiteral("enabled")))
        m_appSettings->setValue(QStringLiteral("ui/ptextender/enabled"), config.value(QStringLiteral("enabled")).toBool());
    if (config.contains(QStringLiteral("canBase")))
        m_appSettings->setValue(QStringLiteral("ui/ptextender/canBase"), config.value(QStringLiteral("canBase")).toInt());

    const QVariantMap system = config.value(QStringLiteral("system")).toMap();
    if (!system.isEmpty()) {
        m_appSettings->setValue(QStringLiteral("ui/ptextender/system/deviceName"),
                                system.value(QStringLiteral("deviceName"), QStringLiteral("PTExtender")).toString());
        m_appSettings->setValue(QStringLiteral("ui/ptextender/system/faultEnable"),
                                system.value(QStringLiteral("faultEnable"), true).toBool());
    }

    const QVariantMap timing = config.value(QStringLiteral("timing")).toMap();
    if (!timing.isEmpty()) {
        m_appSettings->setValue(QStringLiteral("ui/ptextender/timing/crankDuration"),
                                timing.value(QStringLiteral("crankDuration"), 1000).toInt());
        m_appSettings->setValue(QStringLiteral("ui/ptextender/timing/runningProofTime"),
                                timing.value(QStringLiteral("runningProofTime"), 3000).toInt());
        m_appSettings->setValue(QStringLiteral("ui/ptextender/timing/maxCrankTime"),
                                timing.value(QStringLiteral("maxCrankTime"), 6000).toInt());
        m_appSettings->setValue(QStringLiteral("ui/ptextender/timing/maxStartTime"),
                                timing.value(QStringLiteral("maxStartTime"), 10000).toInt());
    }

    const QVariantList gpi = config.value(QStringLiteral("gpiFunctions")).toList();
    for (int i = 0; i < qMin(4, gpi.size()); ++i)
        m_appSettings->setValue(QStringLiteral("ui/ptextender/gpi/%1/function").arg(i), gpi.at(i).toInt());

    const QVariantList relay = config.value(QStringLiteral("relayFunctions")).toList();
    for (int i = 0; i < qMin(4, relay.size()); ++i)
        m_appSettings->setValue(QStringLiteral("ui/ptextender/relay/%1/function").arg(i), relay.at(i).toInt());

    const QVariantList ledChannels = config.value(QStringLiteral("ledChannels")).toList();
    for (int ch = 0; ch < ledChannels.size() && ch < 16; ++ch) {
        const QVariantMap led = ledChannels.at(ch).toMap();
        const QString base = QStringLiteral("ui/ptextender/led/%1/").arg(ch);
        m_appSettings->setValue(base + QStringLiteral("name"), led.value(QStringLiteral("name"), QStringLiteral("LED %1").arg(ch)).toString());
        m_appSettings->setValue(base + QStringLiteral("rgbGroup"), led.value(QStringLiteral("rgbGroup"), 0).toInt());
        m_appSettings->setValue(base + QStringLiteral("rgbChannel"), led.value(QStringLiteral("rgbChannel"), 0).toInt());
        m_appSettings->setValue(base + QStringLiteral("onBrightness"), led.value(QStringLiteral("onBrightness"), 255).toInt());
        m_appSettings->setValue(base + QStringLiteral("pattern"), led.value(QStringLiteral("pattern"), 0).toInt());
        m_appSettings->setValue(base + QStringLiteral("enabled"), led.value(QStringLiteral("enabled"), ch < 14).toBool());
        m_appSettings->setValue(base + QStringLiteral("quickBindInput"), led.value(QStringLiteral("quickBindInput"), -1).toInt());
        m_appSettings->setValue(base + QStringLiteral("overrideR"), led.value(QStringLiteral("overrideR"), 255).toInt());
        m_appSettings->setValue(base + QStringLiteral("overrideG"), led.value(QStringLiteral("overrideG"), 0).toInt());
        m_appSettings->setValue(base + QStringLiteral("overrideB"), led.value(QStringLiteral("overrideB"), 0).toInt());
        m_appSettings->setValue(base + QStringLiteral("overrideR2"), led.value(QStringLiteral("overrideR2"), 0).toInt());
        m_appSettings->setValue(base + QStringLiteral("overrideG2"), led.value(QStringLiteral("overrideG2"), 0).toInt());
        m_appSettings->setValue(base + QStringLiteral("overrideB2"), led.value(QStringLiteral("overrideB2"), 255).toInt());
        m_appSettings->setValue(base + QStringLiteral("overridePattern"), led.value(QStringLiteral("overridePattern"), 2).toInt());
        m_appSettings->setValue(base + QStringLiteral("overrideScope"), led.value(QStringLiteral("overrideScope"), 1).toInt());

        const QVariantMap rule = led.value(QStringLiteral("rule")).toMap();
        if (!rule.isEmpty()) {
            m_appSettings->setValue(base + QStringLiteral("rule/enabled"), rule.value(QStringLiteral("enabled"), false).toBool());
            m_appSettings->setValue(base + QStringLiteral("rule/conditionCount"), rule.value(QStringLiteral("conditionCount"), 1).toInt());
            const QVariantList conditions = rule.value(QStringLiteral("conditions")).toList();
            for (int cond = 0; cond < conditions.size() && cond < 4; ++cond) {
                const QVariantMap c = conditions.at(cond).toMap();
                m_appSettings->setValue(base + QStringLiteral("rule/cond%1/type").arg(cond), c.value(QStringLiteral("type"), 0).toInt());
                m_appSettings->setValue(base + QStringLiteral("rule/cond%1/channel").arg(cond), c.value(QStringLiteral("channel"), 0).toInt());
                m_appSettings->setValue(base + QStringLiteral("rule/cond%1/threshold").arg(cond), c.value(QStringLiteral("threshold"), 0).toInt());
                m_appSettings->setValue(base + QStringLiteral("rule/cond%1/enabled").arg(cond), c.value(QStringLiteral("enabled"), cond == 0).toBool());
            }
            const QVariantList operators = rule.value(QStringLiteral("operators")).toList();
            for (int op = 0; op < operators.size() && op < 3; ++op)
                m_appSettings->setValue(base + QStringLiteral("rule/op%1").arg(op), operators.at(op).toInt());
        }
    }

    const QVariantList indicators = config.value(QStringLiteral("indicators")).toList();
    for (int profile = 0; profile < indicators.size() && profile < 2; ++profile) {
        const QVariantMap profileMap = indicators.at(profile).toMap();
        const QString pfx = QStringLiteral("ui/ptextender/indicator/%1/").arg(profile);
        m_appSettings->setValue(pfx + QStringLiteral("enabled"), profileMap.value(QStringLiteral("enabled"), true).toBool());
        m_appSettings->setValue(pfx + QStringLiteral("type"), profileMap.value(QStringLiteral("type"), 1).toInt());
        m_appSettings->setValue(pfx + QStringLiteral("ch1"), profileMap.value(QStringLiteral("ch1"), profile == 0 ? 1 : 0).toInt());
        m_appSettings->setValue(pfx + QStringLiteral("ch2"), profileMap.value(QStringLiteral("ch2"), profile == 0 ? 2 : 4).toInt());
        m_appSettings->setValue(pfx + QStringLiteral("ch3"), profileMap.value(QStringLiteral("ch3"), profile == 0 ? 3 : 5).toInt());
        const QVariantList effects = profileMap.value(QStringLiteral("effects")).toList();
        for (int state = 0; state < effects.size() && state < 8; ++state) {
            const QVariantMap effect = effects.at(state).toMap();
            const QString epfx = pfx + QStringLiteral("effect/%1/").arg(state);
            m_appSettings->setValue(epfx + QStringLiteral("pattern"), effect.value(QStringLiteral("pattern"), state == 0 ? 3 : 1).toInt());
            m_appSettings->setValue(epfx + QStringLiteral("intensity"), effect.value(QStringLiteral("intensity"), 180).toInt());
            m_appSettings->setValue(epfx + QStringLiteral("r"), effect.value(QStringLiteral("r"), 0).toInt());
            m_appSettings->setValue(epfx + QStringLiteral("g"), effect.value(QStringLiteral("g"), 0).toInt());
            m_appSettings->setValue(epfx + QStringLiteral("b"), effect.value(QStringLiteral("b"), 255).toInt());
            m_appSettings->setValue(epfx + QStringLiteral("p1"), effect.value(QStringLiteral("p1"), 1200).toInt());
            m_appSettings->setValue(epfx + QStringLiteral("p2"), effect.value(QStringLiteral("p2"), 0).toInt());
        }
    }

    if (config.contains(QStringLiteral("suppressedCodes"))) {
        QStringList codes;
        const QVariantList list = config.value(QStringLiteral("suppressedCodes")).toList();
        for (const QVariant &v : list)
            codes << QString::number(v.toInt());
        m_appSettings->setValue(QStringLiteral("ui/ptextender/suppressedCodes"), toSuppressedCodesCsv(codes));
        emit suppressedCodesChanged();
    }

    emit configChanged();
}

bool PTExtenderConfigManager::syncToDevice()
{
    if (!m_ptExtenderCan || !m_appSettings)
        return false;

    bool ok = true;
    for (int i = 0; i < 4; ++i) {
        ok = m_ptExtenderCan->setGpiFunction(
                 i, m_appSettings->getValue(QStringLiteral("ui/ptextender/gpi/%1/function").arg(i), 0).toInt())
             && ok;
        ok = m_ptExtenderCan->setRelayFunction(
                 i, m_appSettings->getValue(QStringLiteral("ui/ptextender/relay/%1/function").arg(i), 0).toInt())
             && ok;
    }
    ok = m_ptExtenderCan->setTimingParam(0,
                                         m_appSettings->getValue(QStringLiteral("ui/ptextender/timing/crankDuration"), 1000)
                                             .toInt())
         && ok;
    ok = m_ptExtenderCan->setTimingParam(1, m_appSettings
                                                ->getValue(QStringLiteral("ui/ptextender/timing/runningProofTime"), 3000)
                                                .toInt())
         && ok;
    ok = m_ptExtenderCan->setTimingParam(2,
                                         m_appSettings->getValue(QStringLiteral("ui/ptextender/timing/maxCrankTime"), 6000)
                                             .toInt())
         && ok;
    ok = m_ptExtenderCan->setTimingParam(3,
                                         m_appSettings->getValue(QStringLiteral("ui/ptextender/timing/maxStartTime"), 10000)
                                             .toInt())
         && ok;

    ok = writeAllLedChannels() && ok;

    for (int profile = 0; profile < 2; ++profile) {
        const QString pfx = QStringLiteral("ui/ptextender/indicator/%1/").arg(profile);
        QByteArray profileData(5, '\0');
        profileData[0] = static_cast<char>(m_appSettings->getValue(pfx + QStringLiteral("enabled"), true).toBool() ? 1 : 0);
        profileData[1] = static_cast<char>(m_appSettings->getValue(pfx + QStringLiteral("type"), 1).toInt() & 0xFF);
        profileData[2] = static_cast<char>(m_appSettings->getValue(pfx + QStringLiteral("ch1"), profile == 0 ? 1 : 0).toInt() & 0xFF);
        profileData[3] = static_cast<char>(m_appSettings->getValue(pfx + QStringLiteral("ch2"), profile == 0 ? 2 : 4).toInt() & 0xFF);
        profileData[4] = static_cast<char>(m_appSettings->getValue(pfx + QStringLiteral("ch3"), profile == 0 ? 3 : 5).toInt() & 0xFF);
        ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupIndicator, profile, 0x00, profileData) && ok;

        for (int state = 0; state < 8; ++state) {
            const QString epfx = pfx + QStringLiteral("effect/%1/").arg(state);
            QByteArray effectPrimary(5, '\0');
            effectPrimary[0] = static_cast<char>(m_appSettings->getValue(epfx + QStringLiteral("pattern"), state == 0 ? 3 : 1).toInt() & 0xFF);
            effectPrimary[1] = static_cast<char>(m_appSettings->getValue(epfx + QStringLiteral("intensity"), 180).toInt() & 0xFF);
            effectPrimary[2] = static_cast<char>(m_appSettings->getValue(epfx + QStringLiteral("r"), 0).toInt() & 0xFF);
            effectPrimary[3] = static_cast<char>(m_appSettings->getValue(epfx + QStringLiteral("g"), 0).toInt() & 0xFF);
            effectPrimary[4] = static_cast<char>(m_appSettings->getValue(epfx + QStringLiteral("b"), 255).toInt() & 0xFF);
            ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupIndicator, profile, 0x10 + state, effectPrimary) && ok;

            QByteArray effectTiming(4, '\0');
            const int p1 = m_appSettings->getValue(epfx + QStringLiteral("p1"), 1200).toInt();
            const int p2 = m_appSettings->getValue(epfx + QStringLiteral("p2"), 0).toInt();
            effectTiming[0] = static_cast<char>(p1 & 0xFF);
            effectTiming[1] = static_cast<char>((p1 >> 8) & 0xFF);
            effectTiming[2] = static_cast<char>(p2 & 0xFF);
            effectTiming[3] = static_cast<char>((p2 >> 8) & 0xFF);
            ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupIndicator, profile, 0x20 + state, effectTiming) && ok;
        }
    }
    return ok;
}

bool PTExtenderConfigManager::syncFromDevice()
{
    if (!m_ptExtenderCan)
        return false;

    bool ok = true;
    for (int i = 0; i < 4; ++i) {
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupGpi, i, 0x00) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupRelay, i, 0x00) && ok;
    }
    ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupSystemGlobals, 0x00, 0x00) && ok;
    ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupTiming, 0x00, 0x00) && ok;

    for (int ch = 0; ch < 16; ++ch) {
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x00) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x01) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x02) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x03) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x10) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x11) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x12) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x13) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x20) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x21) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x22) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x23) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x24) && ok;
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupLed, ch, 0x25) && ok;
    }
    for (int profile = 0; profile < 2; ++profile) {
        ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupIndicator, profile, 0x00) && ok;
        for (int state = 0; state < 8; ++state) {
            ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupIndicator, profile, 0x10 + state) && ok;
            ok = m_ptExtenderCan->readConfigRegister(PTExtenderCan::ConfigGroupIndicator, profile, 0x20 + state) && ok;
        }
    }
    return ok;
}

bool PTExtenderConfigManager::saveToDeviceEeprom()
{
    return m_ptExtenderCan ? m_ptExtenderCan->saveDeviceConfig() : false;
}

void PTExtenderConfigManager::suppressCode(int code)
{
    if (!m_appSettings || code <= 0)
        return;

    QStringList codes = suppressedCodesList();
    const QString codeStr = QString::number(code);
    if (!codes.contains(codeStr))
        codes.append(codeStr);
    codes.sort(Qt::CaseInsensitive);
    m_appSettings->setValue(QStringLiteral("ui/ptextender/suppressedCodes"), toSuppressedCodesCsv(codes));
    emit suppressedCodesChanged();
}

void PTExtenderConfigManager::unsuppressCode(int code)
{
    if (!m_appSettings || code <= 0)
        return;

    QStringList codes = suppressedCodesList();
    codes.removeAll(QString::number(code));
    m_appSettings->setValue(QStringLiteral("ui/ptextender/suppressedCodes"), toSuppressedCodesCsv(codes));
    emit suppressedCodesChanged();
}

bool PTExtenderConfigManager::isCodeSuppressed(int code) const
{
    return suppressedCodesList().contains(QString::number(code));
}

QVariantList PTExtenderConfigManager::suppressedCodes() const
{
    QVariantList list;
    const QStringList codes = suppressedCodesList();
    for (const QString &code : codes)
        list.append(code.toInt());
    return list;
}

void PTExtenderConfigManager::suppressAllKnownCodes()
{
    if (!m_appSettings)
        return;

    QStringList codes;
    for (int code : kKnownDfiCodes)
        codes << QString::number(code);
    m_appSettings->setValue(QStringLiteral("ui/ptextender/suppressedCodes"), toSuppressedCodesCsv(codes));
    emit suppressedCodesChanged();
}

void PTExtenderConfigManager::enableAllCodes()
{
    if (!m_appSettings)
        return;
    m_appSettings->setValue(QStringLiteral("ui/ptextender/suppressedCodes"), QString());
    emit suppressedCodesChanged();
}

QStringList PTExtenderConfigManager::suppressedCodesList() const
{
    if (!m_appSettings)
        return {};
    return parseSuppressedCodes(m_appSettings->getValue(QStringLiteral("ui/ptextender/suppressedCodes"), QString()).toString());
}

QStringList PTExtenderConfigManager::parseSuppressedCodes(const QString &csv)
{
    QStringList result;
    const QStringList parts = csv.split(',', Qt::SkipEmptyParts);
    for (const QString &part : parts) {
        bool ok = false;
        const int code = part.trimmed().toInt(&ok);
        if (ok && code > 0)
            result << QString::number(code);
    }
    result.removeDuplicates();
    std::sort(result.begin(), result.end(), [](const QString &a, const QString &b) { return a.toInt() < b.toInt(); });
    return result;
}

QString PTExtenderConfigManager::toSuppressedCodesCsv(const QStringList &codes)
{
    QStringList normalized = codes;
    normalized.removeAll(QString());
    normalized.removeDuplicates();
    std::sort(normalized.begin(), normalized.end(), [](const QString &a, const QString &b) { return a.toInt() < b.toInt(); });
    return normalized.join(QStringLiteral(","));
}

int PTExtenderConfigManager::clampByte(int value)
{
    return qBound(0, value, 255);
}

QString PTExtenderConfigManager::ledStorageKey(int channel, const QString &suffix) const
{
    const int safeChannel = qBound(0, channel, kLedChannelCount - 1);
    return QStringLiteral("ui/ptextender/led/%1/%2").arg(safeChannel).arg(suffix);
}

QString PTExtenderConfigManager::rgbToHex(int r, int g, int b) const
{
    const QColor color(clampByte(r), clampByte(g), clampByte(b));
    return color.name(QColor::HexRgb).toUpper();
}

QVariantMap PTExtenderConfigManager::hexToRgb(const QString &hex, int fallbackR, int fallbackG, int fallbackB) const
{
    QVariantMap rgb;
    QColor color(hex);
    if (!color.isValid()) {
        rgb[QStringLiteral("r")] = clampByte(fallbackR);
        rgb[QStringLiteral("g")] = clampByte(fallbackG);
        rgb[QStringLiteral("b")] = clampByte(fallbackB);
        return rgb;
    }

    rgb[QStringLiteral("r")] = color.red();
    rgb[QStringLiteral("g")] = color.green();
    rgb[QStringLiteral("b")] = color.blue();
    return rgb;
}

bool PTExtenderConfigManager::writeLedChannel(int channel)
{
    if (!m_ptExtenderCan || !m_appSettings || channel < 0 || channel >= kLedChannelCount)
        return false;

    const QString base = QStringLiteral("ui/ptextender/led/%1/").arg(channel);
    const QByteArray name =
        m_appSettings->getValue(base + QStringLiteral("name"), QStringLiteral("LED %1").arg(channel))
            .toString()
            .leftJustified(16, QChar('\0'))
            .left(16)
            .toLatin1();

    QByteArray ledMain(5, '\0');
    ledMain[0] = static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("rgbGroup"), 0).toInt()));
    ledMain[1] =
        static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("rgbChannel"), 0).toInt()));
    ledMain[2] =
        static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("onBrightness"), 255).toInt()));
    ledMain[3] = static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("pattern"), 0).toInt()));
    ledMain[4] =
        static_cast<char>(m_appSettings->getValue(base + QStringLiteral("enabled"), channel < 14).toBool() ? 1 : 0);

    QByteArray ledOverride(5, '\0');
    ledOverride[0] =
        static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("overrideR"), 255).toInt()));
    ledOverride[1] =
        static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("overrideG"), 0).toInt()));
    ledOverride[2] =
        static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("overrideB"), 0).toInt()));
    ledOverride[3] = static_cast<char>(
        clampByte(m_appSettings->getValue(base + QStringLiteral("overridePattern"), 2).toInt()));
    ledOverride[4] =
        static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("overrideScope"), 1).toInt()));

    QByteArray ledOverride2(3, '\0');
    ledOverride2[0] =
        static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("overrideR2"), 0).toInt()));
    ledOverride2[1] =
        static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("overrideG2"), 0).toInt()));
    ledOverride2[2] =
        static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("overrideB2"), 255).toInt()));

    QByteArray ledQuickBind(1, '\0');
    ledQuickBind[0] = static_cast<char>(
        static_cast<qint8>(m_appSettings->getValue(base + QStringLiteral("quickBindInput"), -1).toInt()));

    bool ok = true;
    ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupLed, channel, 0x00, ledMain) && ok;
    ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupLed, channel, 0x01, ledOverride) && ok;
    ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupLed, channel, 0x02, ledOverride2) && ok;
    ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupLed, channel, 0x03, ledQuickBind) && ok;
    ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupLed, channel, 0x10, name.mid(0, 5)) && ok;
    ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupLed, channel, 0x11, name.mid(5, 5)) && ok;
    ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupLed, channel, 0x12, name.mid(10, 5)) && ok;
    ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupLed, channel, 0x13, name.mid(15, 1)) && ok;

    QByteArray ruleMeta(2, '\0');
    ruleMeta[0] =
        static_cast<char>(m_appSettings->getValue(base + QStringLiteral("rule/enabled"), false).toBool() ? 1 : 0);
    ruleMeta[1] = static_cast<char>(
        clampByte(m_appSettings->getValue(base + QStringLiteral("rule/conditionCount"), 1).toInt()));
    ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupLed, channel, 0x20, ruleMeta) && ok;

    for (int cond = 0; cond < 4; ++cond) {
        const int threshold =
            m_appSettings->getValue(base + QStringLiteral("rule/cond%1/threshold").arg(cond), 0).toInt();
        QByteArray condData(5, '\0');
        condData[0] = static_cast<char>(
            clampByte(m_appSettings->getValue(base + QStringLiteral("rule/cond%1/type").arg(cond), 0).toInt()));
        condData[1] = static_cast<char>(
            clampByte(m_appSettings->getValue(base + QStringLiteral("rule/cond%1/channel").arg(cond), 0).toInt()));
        condData[2] = static_cast<char>(threshold & 0xFF);
        condData[3] = static_cast<char>((threshold >> 8) & 0xFF);
        condData[4] = static_cast<char>(
            m_appSettings->getValue(base + QStringLiteral("rule/cond%1/enabled").arg(cond), cond == 0).toBool()
                ? 1
                : 0);
        ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupLed, channel, 0x21 + cond, condData)
             && ok;
    }

    QByteArray opData(3, '\0');
    opData[0] =
        static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("rule/op0"), 1).toInt()));
    opData[1] =
        static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("rule/op1"), 1).toInt()));
    opData[2] =
        static_cast<char>(clampByte(m_appSettings->getValue(base + QStringLiteral("rule/op2"), 1).toInt()));
    ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupLed, channel, 0x25, opData) && ok;

    return ok;
}

bool PTExtenderConfigManager::writeAllLedChannels()
{
    bool ok = true;
    for (int ch = 0; ch < kLedChannelCount; ++ch)
        ok = writeLedChannel(ch) && ok;
    return ok;
}

void PTExtenderConfigManager::enterConfigMode()
{
    if (!m_ptExtenderCan || m_configModeActive)
        return;

    m_ptExtenderCan->enterConfigMode();
    m_configModeActive = true;
    m_metadataLoaded = false;
    m_metadata.clear();
    m_assemblyBuffer.clear();
    for (int i = 0; i < 5; ++i)
        m_expectedCounts[i] = 0;
    emit configModeActiveChanged();
    emit metadataLoadedChanged();

    for (int cat = 0; cat < 5; ++cat)
        m_ptExtenderCan->requestMetadata(cat);
}

void PTExtenderConfigManager::exitConfigMode()
{
    if (!m_ptExtenderCan || !m_configModeActive)
        return;

    m_ptExtenderCan->exitConfigMode();
    m_configModeActive = false;
    m_metadataLoaded = false;
    m_metadata.clear();
    m_assemblyBuffer.clear();
    emit configModeActiveChanged();
    emit metadataLoadedChanged();
}

void PTExtenderConfigManager::saveAndReboot()
{
    if (!m_ptExtenderCan || !m_configModeActive)
        return;

    m_ptExtenderCan->saveDeviceConfig();
    m_rebootTimer.start();
}

void PTExtenderConfigManager::onMetadataReceived(int category, int totalCount, int optionIndex, int chunkIndex, const QByteArray &data)
{
    if (category < 0 || category >= 5)
        return;

    m_expectedCounts[category] = totalCount;

    QMap<int, QString> &catBuffer = m_assemblyBuffer[category];
    QString &partial = catBuffer[optionIndex];

    for (int i = 0; i < data.size(); ++i) {
        const char c = data[i];
        if (c == '\0')
            break;
        partial.append(QChar::fromLatin1(c));
    }

    bool hasNull = false;
    for (int i = 0; i < data.size(); ++i) {
        if (data[i] == '\0') {
            hasNull = true;
            break;
        }
    }

    if (hasNull) {
        QStringList &names = m_metadata[category];
        if (names.size() <= optionIndex)
            names.resize(totalCount);
        names[optionIndex] = partial;
    }

    checkMetadataComplete();
}

void PTExtenderConfigManager::checkMetadataComplete()
{
    for (int cat = 0; cat < 5; ++cat) {
        if (m_expectedCounts[cat] == 0)
            return;
        if (!m_metadata.contains(cat))
            return;
        if (m_metadata[cat].size() < m_expectedCounts[cat])
            return;
        for (const QString &name : m_metadata[cat]) {
            if (name.isEmpty())
                return;
        }
    }

    if (!m_metadataLoaded) {
        m_metadataLoaded = true;
        emit metadataLoadedChanged();
    }
}

QStringList PTExtenderConfigManager::gpiFunctionNames() const
{
    return m_metadata.value(0);
}

QStringList PTExtenderConfigManager::relayFunctionNames() const
{
    return m_metadata.value(1);
}

QStringList PTExtenderConfigManager::logicConditionNames() const
{
    return m_metadata.value(2);
}

QStringList PTExtenderConfigManager::ledPatternNames() const
{
    return m_metadata.value(3);
}

QStringList PTExtenderConfigManager::ledTypeNames() const
{
    return m_metadata.value(4);
}

bool PTExtenderConfigManager::writeIndicatorProfile(int profile)
{
    if (!m_ptExtenderCan || !m_appSettings || profile < 0 || profile >= kIndicatorProfileCount)
        return false;

    const QString pfx = QStringLiteral("ui/ptextender/indicator/%1/").arg(profile);
    QByteArray payload(5, '\0');
    payload[0] = static_cast<char>(m_appSettings->getValue(pfx + QStringLiteral("enabled"), true).toBool() ? 1 : 0);
    payload[1] = static_cast<char>(clampByte(m_appSettings->getValue(pfx + QStringLiteral("type"), 1).toInt()));
    payload[2] = static_cast<char>(clampByte(m_appSettings->getValue(pfx + QStringLiteral("ch1"), profile == 0 ? 1 : 0).toInt()));
    payload[3] = static_cast<char>(clampByte(m_appSettings->getValue(pfx + QStringLiteral("ch2"), profile == 0 ? 2 : 4).toInt()));
    payload[4] = static_cast<char>(clampByte(m_appSettings->getValue(pfx + QStringLiteral("ch3"), profile == 0 ? 3 : 5).toInt()));
    return m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupIndicator, profile, 0x00, payload);
}

bool PTExtenderConfigManager::writeIndicatorStateEffect(int profile, int state)
{
    if (!m_ptExtenderCan || !m_appSettings || profile < 0 || profile >= kIndicatorProfileCount || state < 0 || state >= kIndicatorStateCount)
        return false;

    const QString pfx = QStringLiteral("ui/ptextender/indicator/%1/effect/%2/").arg(profile).arg(state);
    QByteArray payloadA(5, '\0');
    payloadA[0] = static_cast<char>(clampByte(m_appSettings->getValue(pfx + QStringLiteral("pattern"), state == 0 ? 3 : 1).toInt()));
    payloadA[1] = static_cast<char>(clampByte(m_appSettings->getValue(pfx + QStringLiteral("intensity"), 180).toInt()));
    payloadA[2] = static_cast<char>(clampByte(m_appSettings->getValue(pfx + QStringLiteral("r"), 0).toInt()));
    payloadA[3] = static_cast<char>(clampByte(m_appSettings->getValue(pfx + QStringLiteral("g"), 0).toInt()));
    payloadA[4] = static_cast<char>(clampByte(m_appSettings->getValue(pfx + QStringLiteral("b"), 255).toInt()));

    const int p1 = m_appSettings->getValue(pfx + QStringLiteral("p1"), 1200).toInt();
    const int p2 = m_appSettings->getValue(pfx + QStringLiteral("p2"), 0).toInt();
    QByteArray payloadB(4, '\0');
    payloadB[0] = static_cast<char>(p1 & 0xFF);
    payloadB[1] = static_cast<char>((p1 >> 8) & 0xFF);
    payloadB[2] = static_cast<char>(p2 & 0xFF);
    payloadB[3] = static_cast<char>((p2 >> 8) & 0xFF);

    bool ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupIndicator, profile, 0x10 + state, payloadA);
    ok = m_ptExtenderCan->writeConfigRegister(PTExtenderCan::ConfigGroupIndicator, profile, 0x20 + state, payloadB) && ok;
    return ok;
}
