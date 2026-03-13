#ifndef SCREENCONTROLSERVICE_H
#define SCREENCONTROLSERVICE_H

#include <QObject>
#include <QString>
#include <QTimer>

class AppSettings;
class UIState;
class ExBoardConfigManager;

class ScreenControlService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool hasBrightnessControl READ hasBrightnessControl NOTIFY capabilityChanged)
    Q_PROPERTY(bool isDdc READ isDdc NOTIFY capabilityChanged)
    Q_PROPERTY(QString backendName READ backendName NOTIFY capabilityChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
    Q_PROPERTY(int currentBrightnessPercent READ currentBrightnessPercent NOTIFY currentBrightnessPercentChanged)
    Q_PROPERTY(int globalMaxPercent READ globalMaxPercent WRITE setGlobalMaxPercent NOTIFY globalMaxPercentChanged)
    Q_PROPERTY(int dayPresetPercent READ dayPresetPercent WRITE setDayPresetPercent NOTIFY dayPresetPercentChanged)
    Q_PROPERTY(int nightPresetPercent READ nightPresetPercent WRITE setNightPresetPercent NOTIFY nightPresetPercentChanged)
    Q_PROPERTY(bool popupEnabled READ popupEnabled WRITE setPopupEnabled NOTIFY popupEnabledChanged)
    Q_PROPERTY(bool presetControlsVisible READ presetControlsVisible NOTIFY presetControlsVisibleChanged)

public:
    enum class Backend { None, Sysfs, DdcUtil };
    Q_ENUM(Backend)

    explicit ScreenControlService(QObject *parent = nullptr);

    void setAppSettings(AppSettings *settings);
    void setUIState(UIState *state);
    void setExBoardConfigManager(ExBoardConfigManager *manager);

    bool hasBrightnessControl() const { return m_backend != Backend::None; }
    bool isDdc() const { return m_backend == Backend::DdcUtil; }
    QString backendName() const;
    QString lastError() const { return m_lastError; }
    int currentBrightnessPercent() const { return m_currentBrightnessPercent; }
    int globalMaxPercent() const;
    int dayPresetPercent() const;
    int nightPresetPercent() const;
    bool popupEnabled() const;
    bool presetControlsVisible() const { return m_presetControlsVisible; }
    Backend backend() const { return m_backend; }

    Q_INVOKABLE void detectBackend();
    Q_INVOKABLE void restoreStartupBrightness();
    Q_INVOKABLE void applyManualOverride(int percent);
    Q_INVOKABLE void applyDayPreset();
    Q_INVOKABLE void applyNightPreset();
    Q_INVOKABLE bool shouldShowPopupOnStartup() const;

    void applyHardwareBrightness(int value);

public slots:
    void setGlobalMaxPercent(int percent);
    void setDayPresetPercent(int percent);
    void setNightPresetPercent(int percent);
    void setPopupEnabled(bool enabled);
    void refreshConfig();

signals:
    void capabilityChanged();
    void lastErrorChanged(const QString &message);
    void currentBrightnessPercentChanged(int percent);
    void globalMaxPercentChanged(int percent);
    void dayPresetPercentChanged(int percent);
    void nightPresetPercentChanged(int percent);
    void popupEnabledChanged(bool enabled);
    void presetControlsVisibleChanged(bool visible);

private slots:
    void onOverrideTimeout();

private:
    int clampPercent(int percent) const;
    int effectivePercent(int percent) const;
    int percentToHardware(int percent) const;
    int hardwareToPercent(int value) const;
    void setLastError(const QString &message);
    void setCurrentPercent(int percent);
    void writeHardwareBrightness(int value);
    void applyPreset(const QString &presetName, bool persistSelection);
    QString lastPreset() const;

    AppSettings *m_appSettings = nullptr;
    UIState *m_uiState = nullptr;
    ExBoardConfigManager *m_exBoardConfigManager = nullptr;
    Backend m_backend = Backend::None;
    QString m_lastError;
    int m_currentBrightnessPercent = 100;
    bool m_presetControlsVisible = false;
    QTimer m_overrideTimer;
};

#endif  // SCREENCONTROLSERVICE_H
