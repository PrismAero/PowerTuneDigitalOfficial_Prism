#include "ScreenControlService.h"

#include "ExBoardConfigManager.h"
#include "Models/UIState.h"
#include "appsettings.h"

#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QTextStream>

namespace {
constexpr int kMaxSysfsBrightness = 255;
constexpr int kDefaultDisplayBrightnessPercent = 100;
constexpr int kOverrideTimeoutMs = 10 * 60 * 1000;
const QString kSysfsBrightnessPath = QStringLiteral("/sys/class/backlight/rpi_backlight/brightness");
const QString kDdcutilBinary = QStringLiteral("/usr/bin/ddcutil");
}

ScreenControlService::ScreenControlService(QObject *parent) : QObject(parent)
{
    m_overrideTimer.setSingleShot(true);
    m_overrideTimer.setInterval(kOverrideTimeoutMs);
    connect(&m_overrideTimer, &QTimer::timeout, this, &ScreenControlService::onOverrideTimeout);
}

void ScreenControlService::setAppSettings(AppSettings *settings)
{
    m_appSettings = settings;
    refreshConfig();
    refreshStartupPopupVisible();
}

void ScreenControlService::setUIState(UIState *state)
{
    m_uiState = state;
}

void ScreenControlService::setExBoardConfigManager(ExBoardConfigManager *manager)
{
    if (m_exBoardConfigManager == manager)
        return;

    if (m_exBoardConfigManager)
        disconnect(m_exBoardConfigManager, nullptr, this, nullptr);

    m_exBoardConfigManager = manager;
    if (m_exBoardConfigManager)
        connect(m_exBoardConfigManager, &ExBoardConfigManager::configChanged, this, &ScreenControlService::refreshConfig);

    refreshConfig();
}

QString ScreenControlService::backendName() const
{
    switch (m_backend) {
    case Backend::Sysfs:
        return QStringLiteral("Sysfs");
    case Backend::DdcUtil:
        return QStringLiteral("DDC/CI");
    case Backend::None:
    default:
        return QStringLiteral("None");
    }
}

int ScreenControlService::globalMaxPercent() const
{
    if (!m_appSettings)
        return 100;
    return m_appSettings->readGlobalBrightnessPercent();
}

int ScreenControlService::dayPresetPercent() const
{
    if (!m_appSettings)
        return 70;
    return qBound(0, m_appSettings->getValue(QStringLiteral("ui/brightnessDayPreset"), 70).toInt(), 100);
}

int ScreenControlService::nightPresetPercent() const
{
    if (!m_appSettings)
        return 20;
    return qBound(0, m_appSettings->getValue(QStringLiteral("ui/brightnessNightPreset"), 20).toInt(), 100);
}

bool ScreenControlService::popupEnabled() const
{
    if (!m_appSettings)
        return false;
    return m_appSettings->readBrightnessPopupEnabled();
}

void ScreenControlService::detectBackend()
{
    const Backend priorBackend = m_backend;

    if (m_ddcProbe) {
        disconnect(m_ddcProbe, nullptr, this, nullptr);
        if (m_ddcProbe->state() != QProcess::NotRunning)
            m_ddcProbe->kill();
        m_ddcProbe->deleteLater();
        m_ddcProbe = nullptr;
    }

    if (QFileInfo::exists(kSysfsBrightnessPath)) {
        m_backend = Backend::Sysfs;
        setLastError(QString());

        QFile inputFile(kSysfsBrightnessPath);
        if (inputFile.open(QIODevice::ReadOnly)) {
            QTextStream in(&inputFile);
            bool ok = false;
            const int value = in.readLine().toInt(&ok);
            if (ok)
                setCurrentPercent(hardwareToPercent(value));
        }
    } else if (QFileInfo::exists(kDdcutilBinary)) {
        m_backend = Backend::None;
        m_ddcProbe = new QProcess(this);
        connect(m_ddcProbe,
                qOverload<int, QProcess::ExitStatus>(&QProcess::finished),
                this,
                &ScreenControlService::onDdcProbeFinished);
        m_ddcProbe->start(kDdcutilBinary, {QStringLiteral("detect")});
    } else {
        m_backend = Backend::None;
        setLastError(QStringLiteral("No supported screen brightness backend detected."));
    }

    if (priorBackend != m_backend)
        emit capabilityChanged();

    if (!m_ddcProbe) {
        refreshConfig();
        refreshStartupPopupVisible();
    }
}

void ScreenControlService::restoreStartupBrightness()
{
    if (!hasBrightnessControl())
        return;

    if (presetControlsVisible()) {
        applyPreset(lastPreset(), false);
        return;
    }

    if (m_appSettings)
        applyManualOverride(m_appSettings->readDisplayBrightnessPercent());
}

void ScreenControlService::applyManualOverride(int percent)
{
    if (!hasBrightnessControl())
        return;

    const int requested = clampPercent(percent);
    const int effective = effectivePercent(requested);
    writeHardwareBrightness(percentToHardware(effective));
    if (m_appSettings)
        m_appSettings->writeDisplayBrightnessPercent(effective);
    m_overrideTimer.start();
}

void ScreenControlService::applyDayPreset()
{
    applyPreset(QStringLiteral("day"), true);
}

void ScreenControlService::applyNightPreset()
{
    applyPreset(QStringLiteral("night"), true);
}

bool ScreenControlService::shouldShowPopupOnStartup() const
{
    return startupPopupVisible();
}

void ScreenControlService::applyHardwareBrightness(int value)
{
    if (!hasBrightnessControl())
        return;

    writeHardwareBrightness(value);
    if (m_appSettings)
        m_appSettings->writeDisplayBrightnessPercent(hardwareToPercent(value));
    m_overrideTimer.start();
}

void ScreenControlService::setGlobalMaxPercent(int percent)
{
    if (!m_appSettings)
        return;

    const int clamped = clampPercent(percent);
    if (clamped == globalMaxPercent())
        return;

    m_appSettings->writeGlobalBrightnessPercent(clamped);
    emit globalMaxPercentChanged(clamped);

    if (m_currentBrightnessPercent > clamped)
        applyManualOverride(clamped);
}

void ScreenControlService::setDayPresetPercent(int percent)
{
    if (!m_appSettings)
        return;

    const int clamped = clampPercent(percent);
    if (clamped == dayPresetPercent())
        return;

    m_appSettings->writeBrightnessDayPreset(clamped);
    emit dayPresetPercentChanged(clamped);
}

void ScreenControlService::setNightPresetPercent(int percent)
{
    if (!m_appSettings)
        return;

    const int clamped = clampPercent(percent);
    if (clamped == nightPresetPercent())
        return;

    m_appSettings->writeBrightnessNightPreset(clamped);
    emit nightPresetPercentChanged(clamped);
}

void ScreenControlService::setPopupEnabled(bool enabled)
{
    if (!m_appSettings)
        return;

    if (enabled == popupEnabled())
        return;

    m_appSettings->writeBrightnessPopupEnabled(enabled);
    emit popupEnabledChanged(enabled);
    refreshStartupPopupVisible();
}

void ScreenControlService::refreshConfig()
{
    const bool visible = m_appSettings
                         && (m_appSettings->getValue(QStringLiteral("ui/exboard/brightness/discreteEnabled"), false).toBool()
                             || m_appSettings->getValue(QStringLiteral("ui/exboard/brightness/canIoEnabled"), false).toBool()
                             || m_appSettings->getValue(QStringLiteral("ui/exboard/brightness/analogEnabled"), false).toBool());
    if (m_presetControlsVisible == visible)
        return;

    m_presetControlsVisible = visible;
    emit presetControlsVisibleChanged(m_presetControlsVisible);
    refreshStartupPopupVisible();
}

void ScreenControlService::onOverrideTimeout()
{
    if (!presetControlsVisible())
        return;

    applyPreset(lastPreset(), false);
}

void ScreenControlService::onDdcProbeFinished(int exitCode, QProcess::ExitStatus status)
{
    if (!m_ddcProbe)
        return;

    const Backend priorBackend = m_backend;
    const QString stderrText = QString::fromUtf8(m_ddcProbe->readAllStandardError()).trimmed();
    const QString stdoutText = QString::fromUtf8(m_ddcProbe->readAllStandardOutput()).trimmed();

    if (status == QProcess::NormalExit && exitCode == 0) {
        m_backend = Backend::DdcUtil;
        setLastError(QString());
        if (m_appSettings)
            setCurrentPercent(m_appSettings->readDisplayBrightnessPercent());
    } else {
        m_backend = Backend::None;
        if (status == QProcess::CrashExit) {
            setLastError(QStringLiteral("ddcutil detect crashed while probing display support."));
        } else if (!stderrText.isEmpty()) {
            setLastError(stderrText);
        } else if (!stdoutText.isEmpty()) {
            setLastError(stdoutText);
        } else {
            setLastError(QStringLiteral("ddcutil detect failed."));
        }
    }

    if (priorBackend != m_backend)
        emit capabilityChanged();

    m_ddcProbe->deleteLater();
    m_ddcProbe = nullptr;
    refreshConfig();
    refreshStartupPopupVisible();
}

void ScreenControlService::refreshStartupPopupVisible()
{
    const bool visible = hasBrightnessControl() && popupEnabled() && presetControlsVisible();
    if (m_startupPopupVisible == visible)
        return;

    m_startupPopupVisible = visible;
    emit startupPopupVisibleChanged(m_startupPopupVisible);
}

int ScreenControlService::clampPercent(int percent) const
{
    return qBound(0, percent, 100);
}

int ScreenControlService::effectivePercent(int percent) const
{
    return qMin(clampPercent(percent), globalMaxPercent());
}

int ScreenControlService::percentToHardware(int percent) const
{
    const int clamped = clampPercent(percent);
    if (m_backend == Backend::Sysfs)
        return qRound((clamped / 100.0) * kMaxSysfsBrightness);
    return clamped;
}

int ScreenControlService::hardwareToPercent(int value) const
{
    if (m_backend == Backend::Sysfs)
        return clampPercent(qRound((value / static_cast<double>(kMaxSysfsBrightness)) * 100.0));
    return clampPercent(value);
}

void ScreenControlService::setLastError(const QString &message)
{
    if (m_lastError == message)
        return;

    m_lastError = message;
    emit lastErrorChanged(m_lastError);
}

void ScreenControlService::setCurrentPercent(int percent)
{
    const int clamped = clampPercent(percent);
    if (m_currentBrightnessPercent == clamped)
        return;

    m_currentBrightnessPercent = clamped;
    emit currentBrightnessPercentChanged(m_currentBrightnessPercent);
}

void ScreenControlService::writeHardwareBrightness(int value)
{
    int boundedValue = value;

    switch (m_backend) {
    case Backend::DdcUtil: {
        boundedValue = clampPercent(value);
        const int exitCode =
                QProcess::execute(kDdcutilBinary,
                                  {QStringLiteral("setvcp"), QStringLiteral("10"), QString::number(boundedValue)});
        if (exitCode != 0) {
            setLastError(QStringLiteral("ddcutil setvcp 10 failed with exit code %1.").arg(exitCode));
            return;
        }
        setLastError(QString());
        break;
    }
    case Backend::Sysfs: {
        boundedValue = qBound(0, value, kMaxSysfsBrightness);
        QFile outputFile(kSysfsBrightnessPath);
        if (outputFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            QTextStream out(&outputFile);
            out << boundedValue;
            setLastError(QString());
        } else {
            setLastError(QStringLiteral("Unable to write sysfs brightness path."));
            return;
        }
        break;
    }
    case Backend::None:
        return;
    }

    setCurrentPercent(hardwareToPercent(boundedValue));
    if (m_uiState)
        m_uiState->setBrightness(boundedValue);
    if (m_appSettings)
        m_appSettings->writebrightnessettings(boundedValue);
}

void ScreenControlService::applyPreset(const QString &presetName, bool persistSelection)
{
    if (!hasBrightnessControl())
        return;

    const QString normalized = (presetName == QLatin1String("night")) ? QStringLiteral("night") : QStringLiteral("day");
    const int percent = (normalized == QLatin1String("night")) ? nightPresetPercent() : dayPresetPercent();

    writeHardwareBrightness(percentToHardware(effectivePercent(percent)));
    if (m_appSettings) {
        m_appSettings->writeDisplayBrightnessPercent(effectivePercent(percent));
        if (persistSelection)
            m_appSettings->writeLastBrightnessPreset(normalized);
    }
    m_overrideTimer.stop();
}

QString ScreenControlService::lastPreset() const
{
    if (!m_appSettings)
        return QStringLiteral("day");
    const QString preset = m_appSettings->readLastBrightnessPreset();
    return preset == QLatin1String("night") ? preset : QStringLiteral("day");
}
