import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

SettingsPage {
    id: root

    property bool settingsLoaded: false
    readonly property string bootLoopVideoSource: "file:///home/pi/bootvideo.mp4"

    function adjustBrightness(delta) {
        var next = ScreenControl.currentBrightnessPercent + (delta * 5);
        ScreenControl.applyManualOverride(Math.max(0, Math.min(100, next)));
    }

    Component.onCompleted: settingsLoaded = true

    ColumnLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.sectionPadding

        SettingsSection {
            Layout.fillWidth: true
            title: Translator.translate("Display", Settings.language)

            SettingsRow {
                Layout.fillWidth: true
                description: ScreenControl.lastError
                label: Translator.translate("Display Backend", Settings.language)

                Text {
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontControl
                    text: ScreenControl.backendName
                }
            }

            SettingsRow {
                Layout.fillWidth: true
                description: Translator.translate("Maximum brightness allowed for all display controls", Settings.language)
                label: Translator.translate("Global Max Brightness %", Settings.language)
                visible: ScreenControl.hasBrightnessControl

                StyledSpinBox {
                    from: 0
                    stepSize: 5
                    to: 100
                    value: ScreenControl.globalMaxPercent

                    onValueChanged: {
                        if (root.settingsLoaded)
                            ScreenControl.setGlobalMaxPercent(value);
                    }
                }
            }

            SettingsRow {
                Layout.fillWidth: true
                description: Translator.translate("Used by the Day popup button", Settings.language)
                label: Translator.translate("Day Preset %", Settings.language)
                visible: ScreenControl.presetControlsVisible

                StyledSpinBox {
                    from: 0
                    stepSize: 5
                    to: 100
                    value: ScreenControl.dayPresetPercent

                    onValueChanged: {
                        if (root.settingsLoaded)
                            ScreenControl.setDayPresetPercent(value);
                    }
                }
            }

            SettingsRow {
                Layout.fillWidth: true
                description: Translator.translate("Used by the Night popup button", Settings.language)
                label: Translator.translate("Night Preset %", Settings.language)
                visible: ScreenControl.presetControlsVisible

                StyledSpinBox {
                    from: 0
                    stepSize: 5
                    to: 100
                    value: ScreenControl.nightPresetPercent

                    onValueChanged: {
                        if (root.settingsLoaded)
                            ScreenControl.setNightPresetPercent(value);
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap
                visible: ScreenControl.hasBrightnessControl

                Text {
                    Layout.preferredWidth: SettingsTheme.labelWidth
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    text: Translator.translate("Brightness Override", Settings.language)
                }

                StyledButton {
                    implicitHeight: SettingsTheme.controlHeight
                    implicitWidth: 36
                    primary: false
                    text: "-"

                    onClicked: root.adjustBrightness(-1)
                }

                Slider {
                    id: brightnessSlider

                    Layout.fillWidth: true
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    from: 0
                    stepSize: 5
                    to: 100
                    value: ScreenControl.currentBrightnessPercent

                    onMoved: ScreenControl.applyManualOverride(value)

                    Connections {
                        function onCurrentBrightnessPercentChanged(percent) {
                            brightnessSlider.value = percent;
                        }

                        target: ScreenControl
                    }
                }

                StyledButton {
                    implicitHeight: SettingsTheme.controlHeight
                    implicitWidth: 36
                    primary: false
                    text: "+"

                    onClicked: root.adjustBrightness(1)
                }
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontStatus
                text: Translator.translate("Temporary manual override. When presets are active, it reverts after 10 minutes.", Settings.language)
                visible: ScreenControl.hasBrightnessControl
                wrapMode: Text.WordWrap
            }

            StyledSwitch {
                checked: ScreenControl.popupEnabled
                label: Translator.translate("Brightness Pop Up At Boot", Settings.language)
                visible: ScreenControl.presetControlsVisible

                onCheckedChanged: {
                    if (root.settingsLoaded)
                        ScreenControl.setPopupEnabled(checked);
                }
            }
        }

        SettingsSection {
            Layout.fillWidth: true
            title: Translator.translate("Dashboard Lock", Settings.language)

            StyledSwitch {
                checked: DashboardLock.lockoutEnabled
                label: Translator.translate("Enable Dashboard Lock", Settings.language)

                onCheckedChanged: {
                    if (root.settingsLoaded)
                        DashboardLock.setLockoutEnabled(checked);
                }
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontStatus
                text: DashboardLock.lockoutEnabled
                      ? Translator.translate("All swiping is locked. Hold either bottom corner for 4 seconds to unlock until reboot.", Settings.language)
                      : Translator.translate("Swiping is always available while dashboard lock is disabled.", Settings.language)
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontLabel
                text: DashboardLock.sessionUnlocked
                      ? Translator.translate("Unlocked for this boot session", Settings.language)
                      : Translator.translate("Locked until bottom-corner hold completes", Settings.language)
                visible: DashboardLock.lockoutEnabled
            }

            ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: DashboardLock.holdProgressPercent
                visible: DashboardLock.lockoutEnabled && DashboardLock.unlocking
            }
        }

        SettingsSection {
            Layout.fillWidth: true
            title: Translator.translate("Demo Mode", Settings.language)

            StyledButton {
                enabled: !DemoMode.active
                primary: !DemoMode.active
                text: DemoMode.active
                      ? Translator.translate("Demo Mode Active (until reboot)", Settings.language)
                      : Translator.translate("Enter Demo Mode", Settings.language)

                onClicked: {
                    if (root.settingsLoaded && !DemoMode.active)
                        DemoMode.enterDemoMode();
                }
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontStatus
                text: DemoMode.active
                      ? Translator.translate("Demo mode is locked for this boot session. Reboot to exit.", Settings.language)
                      : Translator.translate("Demo mode hides all normal UI and loops the same boot splash video.", Settings.language)
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                border.color: SettingsTheme.border
                border.width: SettingsTheme.borderWidth
                color: SettingsTheme.surfaceElevated
                radius: SettingsTheme.radiusMedium

                VideoOutput {
                    id: previewOutput
                    anchors.fill: parent
                    anchors.margins: 1
                    fillMode: VideoOutput.PreserveAspectCrop
                    visible: previewPlayer.mediaStatus !== MediaPlayer.InvalidMedia
                             && previewPlayer.mediaStatus !== MediaPlayer.NoMedia
                    z: 1
                }

                MediaPlayer {
                    id: previewPlayer
                    autoPlay: true
                    loops: MediaPlayer.Infinite
                    source: root.bootLoopVideoSource
                    videoOutput: previewOutput
                }

                Text {
                    anchors.centerIn: parent
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: Translator.translate("Boot splash video preview unavailable", Settings.language)
                    visible: previewPlayer.mediaStatus === MediaPlayer.InvalidMedia
                             || previewPlayer.mediaStatus === MediaPlayer.NoMedia
                    z: 2
                }
            }
        }
    }
}
