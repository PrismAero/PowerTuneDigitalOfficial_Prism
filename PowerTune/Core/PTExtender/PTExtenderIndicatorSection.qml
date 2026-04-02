import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

ColumnLayout {
    id: root
    spacing: SettingsTheme.sectionSpacing

    function indicatorKey(profile, suffix) {
        return "ui/ptextender/indicator/" + profile + "/" + suffix;
    }

    readonly property var patternNames: PTExtenderConfig.metadataLoaded ? PTExtenderConfig.ledPatternNames() : ["Off", "Solid", "Blink", "Pulse", "Chase", "Bi-Blink", "Bi-Pulse", "Tri-Cycle", "Strobe", "Breathe"]
    readonly property var ledTypeNames: PTExtenderConfig.metadataLoaded ? PTExtenderConfig.ledTypeNames() : ["Single", "Dual", "RGB"]
    readonly property var stateLabels: ["INIT", "STANDBY", "CRANKING", "RUNNING", "STOPPING", "TESTING", "CONFIG", "FAULT"]
    readonly property var profileTitles: ["System Indicator Profile", "Start/Stop Indicator Profile"]

    Repeater {
        model: 2

        delegate: SettingsSection {
            id: profileSection
            required property int index
            property int profileIndex: index

            Layout.fillWidth: true
            title: root.profileTitles[index]
            collapsible: true
            collapsed: index === 1

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                StyledSwitch {
                    checked: AppSettings.getValue(root.indicatorKey(profileIndex, "enabled"), true)
                    text: "Enabled"
                    onToggled: AppSettings.setValue(root.indicatorKey(profileIndex, "enabled"), checked)
                }

                Text {
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    text: "Type"
                }
                StyledComboBox {
                    model: root.ledTypeNames
                    currentIndex: AppSettings.getValue(root.indicatorKey(profileIndex, "type"), 1) - 1
                    onActivated: AppSettings.setValue(root.indicatorKey(profileIndex, "type"), currentIndex + 1)
                }

                Item { Layout.fillWidth: true }

                StyledButton {
                    enabled: PTExtenderConfig.configModeActive
                    text: "Write Profile"
                    onClicked: PTExtenderConfig.writeIndicatorProfile(profileIndex)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                Text {
                    Layout.preferredWidth: SettingsTheme.labelWidth
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    text: "LED Channel 1"
                }
                StyledSpinBox {
                    from: 0; to: 15
                    value: AppSettings.getValue(root.indicatorKey(profileIndex, "ch1"), profileIndex === 0 ? 1 : 0)
                    onValueChanged: AppSettings.setValue(root.indicatorKey(profileIndex, "ch1"), value)
                }

                Text {
                    Layout.preferredWidth: SettingsTheme.labelWidth
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    text: "LED Channel 2"
                }
                StyledSpinBox {
                    from: 0; to: 15
                    value: AppSettings.getValue(root.indicatorKey(profileIndex, "ch2"), profileIndex === 0 ? 2 : 4)
                    onValueChanged: AppSettings.setValue(root.indicatorKey(profileIndex, "ch2"), value)
                }

                Text {
                    Layout.preferredWidth: SettingsTheme.labelWidth
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    text: "LED Channel 3"
                }
                StyledSpinBox {
                    from: 0; to: 15
                    value: AppSettings.getValue(root.indicatorKey(profileIndex, "ch3"), profileIndex === 0 ? 3 : 5)
                    onValueChanged: AppSettings.setValue(root.indicatorKey(profileIndex, "ch3"), value)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text { Layout.preferredWidth: 80; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; text: "State" }
                Text { Layout.preferredWidth: 120; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; text: "Pattern" }
                Text { Layout.preferredWidth: 80; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; text: "Intensity" }
                Text { Layout.preferredWidth: 100; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; text: "Speed (ms)" }
                Text { Layout.preferredWidth: 100; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; text: "Offset" }
                Text { Layout.preferredWidth: 100; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; text: "Color" }
                Item { Layout.fillWidth: true }
            }

            Rectangle { Layout.fillWidth: true; height: SettingsTheme.borderWidth; color: SettingsTheme.border }

            Repeater {
                model: root.stateLabels
                delegate: RowLayout {
                    id: stateRow
                    required property int index
                    required property string modelData
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        Layout.preferredWidth: 80
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontLabel
                        font.bold: true
                        text: stateRow.modelData
                    }
                    StyledComboBox {
                        Layout.preferredWidth: 120
                        model: root.patternNames
                        currentIndex: AppSettings.getValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/pattern", stateRow.index === 0 ? 3 : 1)
                        onActivated: AppSettings.setValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/pattern", currentIndex)
                    }
                    StyledSpinBox {
                        Layout.preferredWidth: 80
                        from: 0; to: 255
                        value: AppSettings.getValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/intensity", 180)
                        onValueChanged: AppSettings.setValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/intensity", value)
                    }
                    StyledSpinBox {
                        Layout.preferredWidth: 100
                        from: 0; to: 65535
                        value: AppSettings.getValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/p1", 1200)
                        onValueChanged: AppSettings.setValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/p1", value)
                    }
                    StyledSpinBox {
                        Layout.preferredWidth: 100
                        from: 0; to: 65535
                        value: AppSettings.getValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/p2", 0)
                        onValueChanged: AppSettings.setValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/p2", value)
                    }
                    StyledColorPicker {
                        Layout.preferredWidth: 100
                        colorValue: PTExtenderConfig.rgbToHex(
                                        AppSettings.getValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/r", 0),
                                        AppSettings.getValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/g", 0),
                                        AppSettings.getValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/b", 255))
                        onColorEdited: function (newColor) {
                            if (!newColor || newColor.length !== 7)
                                return;
                            AppSettings.setValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/r", parseInt(newColor.substring(1, 3), 16));
                            AppSettings.setValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/g", parseInt(newColor.substring(3, 5), 16));
                            AppSettings.setValue("ui/ptextender/indicator/" + profileSection.profileIndex + "/effect/" + stateRow.index + "/b", parseInt(newColor.substring(5, 7), 16));
                        }
                    }
                    Item { Layout.fillWidth: true }
                    StyledButton {
                        enabled: PTExtenderConfig.configModeActive
                        primary: false
                        text: "Write"
                        onClicked: PTExtenderConfig.writeIndicatorStateEffect(profileSection.profileIndex, stateRow.index)
                    }
                }
            }
        }
    }
}
