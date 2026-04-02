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

    function toHex(v) {
        const clamped = Math.max(0, Math.min(255, v));
        const h = clamped.toString(16).toUpperCase();
        return h.length < 2 ? "0" + h : h;
    }

    function rgbToHex(r, g, b) {
        return "#" + toHex(r) + toHex(g) + toHex(b);
    }

    function writeProfile(profile) {
        const pfx = "ui/ptextender/indicator/" + profile + "/";
        const payload = String.fromCharCode(AppSettings.getValue(pfx + "enabled", true) ? 1 : 0, AppSettings.getValue(pfx + "type", 1), AppSettings.getValue(pfx + "ch1", profile === 0 ? 1 : 0), AppSettings.getValue(pfx + "ch2", profile === 0 ? 2 : 4), AppSettings.getValue(pfx + "ch3", profile === 0 ? 3 : 5));
        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupIndicator, profile, 0x00, payload);
    }

    function writeStateEffect(profile, state) {
        const pfx = "ui/ptextender/indicator/" + profile + "/effect/" + state + "/";
        const payloadA = String.fromCharCode(AppSettings.getValue(pfx + "pattern", state === 0 ? 3 : 1), AppSettings.getValue(pfx + "intensity", 180), AppSettings.getValue(pfx + "r", 0), AppSettings.getValue(pfx + "g", 0), AppSettings.getValue(pfx + "b", 255));
        const p1 = AppSettings.getValue(pfx + "p1", 1200);
        const p2 = AppSettings.getValue(pfx + "p2", 0);
        const payloadB = String.fromCharCode(p1 & 0xFF, (p1 >> 8) & 0xFF, p2 & 0xFF, (p2 >> 8) & 0xFF);
        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupIndicator, profile, 0x10 + state, payloadA);
        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupIndicator, profile, 0x20 + state, payloadB);
    }

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
                implicitHeight: content.implicitHeight + 12

                ColumnLayout {
                    id: content
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 6

                    Text {
                        color: SettingsTheme.textPrimary
                        font.bold: true
                        text: index === 0 ? "System Indicator Profile" : "Start/Stop Indicator Profile"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        StyledSwitch {
                            checked: AppSettings.getValue(root.indicatorKey(index, "enabled"), true)
                            text: "Enabled"
                            onToggled: AppSettings.setValue(root.indicatorKey(index, "enabled"), checked)
                        }
                        Text {
                            color: SettingsTheme.textSecondary
                            text: "Type"
                        }
                        ComboBox {
                            model: ["Single", "Dual", "RGB"]
                            currentIndex: AppSettings.getValue(root.indicatorKey(index, "type"), 1) - 1
                            onActivated: AppSettings.setValue(root.indicatorKey(index, "type"), currentIndex + 1)
                        }
                        Text {
                            color: SettingsTheme.textSecondary
                            text: "CH1"
                        }
                        SpinBox {
                            from: 0
                            to: 15
                            value: AppSettings.getValue(root.indicatorKey(index, "ch1"), index === 0 ? 1 : 0)
                            onValueModified: AppSettings.setValue(root.indicatorKey(index, "ch1"), value)
                        }
                        Text {
                            color: SettingsTheme.textSecondary
                            text: "CH2"
                        }
                        SpinBox {
                            from: 0
                            to: 15
                            value: AppSettings.getValue(root.indicatorKey(index, "ch2"), index === 0 ? 2 : 4)
                            onValueModified: AppSettings.setValue(root.indicatorKey(index, "ch2"), value)
                        }
                        Text {
                            color: SettingsTheme.textSecondary
                            text: "CH3"
                        }
                        SpinBox {
                            from: 0
                            to: 15
                            value: AppSettings.getValue(root.indicatorKey(index, "ch3"), index === 0 ? 3 : 5)
                            onValueModified: AppSettings.setValue(root.indicatorKey(index, "ch3"), value)
                        }
                        Button {
                            text: "Write Profile"
                            onClicked: root.writeProfile(index)
                        }
                    }

                    Repeater {
                        model: ["INIT", "STANDBY", "CRANKING", "RUNNING", "STOPPING", "TESTING", "CONFIG", "FAULT"]
                        delegate: RowLayout {
                            required property int index
                            required property string modelData
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                color: SettingsTheme.textSecondary
                                text: modelData
                                Layout.preferredWidth: 80
                            }
                            ComboBox {
                                model: ["OFF", "SOLID", "BLINK", "PULSE", "CHASE", "BI BLINK", "BI PULSE", "TRI CYCLE", "STROBE", "BREATHE"]
                                currentIndex: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/pattern", index === 0 ? 3 : 1)
                                onActivated: AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/pattern", currentIndex)
                            }
                            SpinBox {
                                from: 0
                                to: 255
                                value: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/intensity", 180)
                                onValueModified: AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/intensity", value)
                            }
                            SpinBox {
                                from: 0
                                to: 65535
                                value: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/p1", 1200)
                                onValueModified: AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/p1", value)
                            }
                            SpinBox {
                                from: 0
                                to: 65535
                                value: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/p2", 0)
                                onValueModified: AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/p2", value)
                            }
                            StyledColorPicker {
                                Layout.preferredWidth: 130
                                colorValue: root.rgbToHex(AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/r", 0), AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/g", 0), AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/b", 255))
                                onColorEdited: function (newColor) {
                                    if (!newColor || newColor.length !== 7)
                                        return;
                                    AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/r", parseInt(newColor.substring(1, 3), 16));
                                    AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/g", parseInt(newColor.substring(3, 5), 16));
                                    AppSettings.setValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/b", parseInt(newColor.substring(5, 7), 16));
                                }
                            }
                            LedAnimationPreview {
                                colorA: Qt.rgba(AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/r", 0) / 255.0, AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/g", 0) / 255.0, AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/b", 255) / 255.0, 1.0)
                                pattern: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/pattern", index === 0 ? 3 : 1)
                                param1: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/p1", 1200)
                                param2: AppSettings.getValue("ui/ptextender/indicator/" + profileIndex + "/effect/" + index + "/p2", 0)
                            }
                            Button {
                                text: "Write"
                                onClicked: root.writeStateEffect(profileIndex, index)
                            }
                        }
                    }
                }
            }
        }
    }
}
