#include "PTExtenderConfigManager.h"

#include "../Can/Protocols/PTExtenderCan.h"
#include "appsettings.h"

#include <algorithm>

namespace {
static const int kKnownDfiCodes[] = {11, 12, 13, 14, 15, 21, 23, 24, 25, 31, 32, 33, 34, 35,
                                     36, 39, 46, 51, 52, 53, 54, 56, 62, 63, 64, 67, 83};
}

PTExtenderConfigManager::PTExtenderConfigManager(QObject *parent) : QObject(parent) {}

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
