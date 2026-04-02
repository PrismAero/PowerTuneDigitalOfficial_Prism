import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

ColumnLayout {
    id: root

    required property var config

    Layout.fillWidth: true
    spacing: 10

    SettingsSection {
        Layout.fillWidth: true
        title: "Warning"
        visible: config.hasWarning

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            StyledSwitch {
                id: warningSwitch

                checked: config.warningEnabled
                text: "Enable Warning"

                onToggled: config.warningEnabled = checked
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: config.warningEnabled

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: "Threshold"
                        }

                        StyledTextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: config.warningThreshold.toString()

                            onTextEdited: {
                                var v = parseFloat(text);
                                if (!isNaN(v))
                                    config.warningThreshold = v;
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        visible: config.isSensor

                        Text {
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: "Warning Color"
                        }

                        StyledColorPicker {
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            colorValue: config.warningColor

                            onColorEdited: function (c) {
                                config.warningColor = c;
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: config.isSensor

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: "Warning Direction"
                    }

                    StyledComboBox {
                        id: directionCombo

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        currentIndex: config.warningDirection === "below" ? 1 : 0
                        model: ["above", "below"]

                        onActivated: function (idx) {
                            config.warningDirection = idx === 1 ? "below" : "above";
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: config.isSensor

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: "Normal Color"
                    }

                    StyledColorPicker {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        colorValue: config.normalColor

                        onColorEdited: function (c) {
                            config.normalColor = c;
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: config.isArc || config.isSensor

                    StyledSwitch {
                        checked: config.warningFlash
                        text: "Flash"

                        onToggled: config.warningFlash = checked
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 140
                        spacing: 4
                        visible: config.warningFlash

                        Text {
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: "Flash Rate (ms)"
                        }

                        StyledSpinBox {
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            Layout.preferredWidth: 140
                            from: 50
                            stepSize: 50
                            to: 1000
                            value: config.warningFlashRate

                            onValueChanged: config.warningFlashRate = value
                        }
                    }
                }
            }
        }
    }

    SettingsSection {
        Layout.fillWidth: true
        title: "Status Configuration"
        visible: config.hasStatusConfig

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: "ON/OFF Threshold (trip point)"
                }

                StyledTextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: config.threshold.toString()

                    onTextEdited: {
                        var v = parseFloat(text);
                        if (!isNaN(v))
                            config.threshold = v;
                    }
                }
            }

            StyledSwitch {
                checked: config.invertLogic
                text: "Invert Logic"

                onToggled: config.invertLogic = checked
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: "ON Color"
                    }

                    StyledColorPicker {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        colorValue: config.onColor

                        onColorEdited: function (c) {
                            config.onColor = c;
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: "OFF Color"
                    }

                    StyledColorPicker {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        colorValue: config.offColor

                        onColorEdited: function (c) {
                            config.offColor = c;
                        }
                    }
                }
            }
        }
    }
}
