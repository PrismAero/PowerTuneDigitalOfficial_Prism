import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsSection {
    id: root
    title: "Indicator Profiles"

    function indicatorKey(profile, suffix) {
        return "ui/ptextender/indicator/" + profile + "/" + suffix;
    }

    readonly property var patternNames: PTExtenderConfig.metadataLoaded ? PTExtenderConfig.ledPatternNames() : ["Off", "Solid", "Blink", "Pulse", "Chase", "Bi-Blink", "Bi-Pulse", "Tri-Cycle", "Strobe", "Breathe"]
    readonly property var ledTypeNames: PTExtenderConfig.metadataLoaded ? PTExtenderConfig.ledTypeNames() : ["Single", "Dual", "RGB"]
    readonly property var stateLabels: ["INIT", "STANDBY", "CRANKING", "RUNNING", "STOPPING", "TESTING", "CONFIG", "FAULT"]

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: 2
            delegate: Rectangle {
                required property int index
                property int profileIndex: index
                Layout.fillWidth: true
                color: SettingsTheme.surfaceElevated
                border.color: SettingsTheme.border
                border.width: SettingsTheme.borderWidth
                radius: SettingsTheme.radiusSmall
                implicitHeight: profileContent.implicitHeight + 12

                ColumnLayout {
                    id: profileContent
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 6

                    Text {
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontLabel
                        font.bold: true
                        text: index === 0 ? "System Indicator Profile" : "Start/Stop Indicator Profile"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: SettingsTheme.controlGap

                        StyledSwitch {
                            checked: AppSettings.getValue(root.indicatorKey(index, "enabled"), true)
                            text: "Enabled"
                            onToggled: AppSettings.setValue(root.indicatorKey(index, "enabled"), checked)
                        }
                        Text { color: SettingsTheme.textSecondary; text: "Type" }
                        StyledComboBox {
                            model: root.ledTypeNames
                            currentIndex: AppSettings.getValue(root.indicatorKey(index, "type"), 1) - 1
                            onActivated: AppSettings.setValue(root.indicatorKey(index, "type"), currentIndex + 1)
                        }
                        Text { color: SettingsTheme.textSecondary; text: "CH1" }
                        StyledSpinBox {
                            from: 0; to: 15
                            value: AppSettings.getValue(root.indicatorKey(index, "ch1"), index === 0 ? 1 : 0)
                            onValueChanged: AppSettings.setValue(root.indicatorKey(index, "ch1"), value)
                        }
                        Text { color: SettingsTheme.textSecondary; text: "CH2" }
                        StyledSpinBox {
                            from: 0; to: 15
                            value: AppSettings.getValue(root.indicatorKey(index, "ch2"), index === 0 ? 2 : 4)
                            onValueChanged: AppSettings.setValue(root.indicatorKey(index, "ch2"), value)
                        }
                        Text { color: SettingsTheme.textSecondary; text: "CH3" }
                        StyledSpinBox {
                            from: 0; to: 15
                            value: AppSettings.getValue(root.indicatorKey(index, "ch3"), index === 0 ? 3 : 5)
                            onValueChanged: AppSettings.setValue(root.indicatorKey(index, "ch3"), value)
                        }
                        StyledButton {
                            enabled: PTExtenderConfig.configModeActive
                            text: "Write Profile"
                            onClicked: PTExtenderConfig.writeIndicatorProfile(index)
                        }
                    }

                    Repeater {
                        model: root.stateLabels
                        delegate: RowLayout {
                            required property int index
                            required property string modelData
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                Layout.preferredWidth: 80
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontControl
                                text: modelData
                            }
                            StyledComboBox {
                                model: root.patternNames
                                currentIndex: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/pattern", index === 0 ? 3 : 1)
                                onActivated: AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/pattern", currentIndex)
                            }
                            StyledSpinBox {
                                from: 0; to: 255
                                value: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/intensity", 180)
                                onValueChanged: AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/intensity", value)
                            }
                            StyledSpinBox {
                                from: 0; to: 65535
                                value: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/p1", 1200)
                                onValueChanged: AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/p1", value)
                            }
                            StyledSpinBox {
                                from: 0; to: 65535
                                value: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/p2", 0)
                                onValueChanged: AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/p2", value)
                            }
                            StyledColorPicker {
                                Layout.preferredWidth: 130
                                colorValue: PTExtenderConfig.rgbToHex(
                                                AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/r", 0),
                                                AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/g", 0),
                                                AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/b", 255))
                                onColorEdited: function (newColor) {
                                    if (!newColor || newColor.length !== 7)
                                        return;
                                    AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/r", parseInt(newColor.substring(1, 3), 16));
                                    AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/g", parseInt(newColor.substring(3, 5), 16));
                                    AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/b", parseInt(newColor.substring(5, 7), 16));
                                }
                            }
                            LedAnimationPreview {
                                colorA: Qt.rgba(
                                            AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/r", 0) / 255.0,
                                            AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/g", 0) / 255.0,
                                            AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/b", 255) / 255.0, 1.0)
                                pattern: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/pattern", index === 0 ? 3 : 1)
                                param1: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/p1", 1200)
                                param2: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/p2", 0)
                            }
                            StyledButton {
                                enabled: PTExtenderConfig.configModeActive
                                text: "Write"
                                onClicked: PTExtenderConfig.writeIndicatorStateEffect(profileIndex, index)
                            }
                        }
                    }
                }
            }
        }
    }
}
