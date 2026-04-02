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
        title: "Gear Indicator"
        visible: config.hasGearConfig

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
                    text: "Gear Parameter"
                }

                SensorPicker {
                    id: gearDatasourcePicker

                    Layout.fillWidth: true
                    selectedKey: config.gearSensorKey

                    onSensorSelected: function (key, displayName, unit) {
                        config.gearSensorKey = config.normalizeAnalogSensorKey(key);
                    }
                }
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
                        text: "Text Color"
                    }

                    StyledColorPicker {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        colorValue: config.gearTextColor

                        onColorEdited: function (c) {
                            config.gearTextColor = c;
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 140
                    spacing: 4

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: "Font Size"
                    }

                    StyledSpinBox {
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        Layout.preferredWidth: 140
                        from: 20
                        stepSize: 10
                        to: 300
                        value: config.gearFontSize

                        onValueChanged: config.gearFontSize = value
                    }
                }
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
                        text: "Suffix Size"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.suffixFontSize.toFixed(1)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v > 0)
                                config.suffixFontSize = v;
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
                        text: "Offset X"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.gearOffsetX.toFixed(1)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v))
                                config.gearOffsetX = v;
                        }
                    }
                }
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
                        text: "Offset Y"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.gearOffsetY.toFixed(1)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v))
                                config.gearOffsetY = v;
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
                        text: "Width"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.gearWidth.toFixed(1)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v > 0)
                                config.gearWidth = v;
                        }
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
                    text: "Height"
                }

                StyledTextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: config.gearHeight.toFixed(1)

                    onTextEdited: {
                        var v = parseFloat(text);
                        if (!isNaN(v) && v > 0)
                            config.gearHeight = v;
                    }
                }
            }
        }
    }

    SettingsSection {
        Layout.fillWidth: true
        title: "Shift Lights"
        visible: config.hasShiftConfig

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

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
                        text: "Shift Point (0 - 1)"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.shiftPoint.toFixed(3)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v))
                                config.shiftPoint = v;
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 140
                    spacing: 4

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: "Light Count"
                    }

                    StyledSpinBox {
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        Layout.preferredWidth: 140
                        from: 1
                        to: 15
                        value: config.shiftCount

                        onValueChanged: config.shiftCount = value
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
                    text: "Light Pattern"
                }

                StyledComboBox {
                    id: patternCombo

                    Layout.fillWidth: true
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    currentIndex: {
                        var items = ["center-out", "left-to-right", "right-to-left", "alternating"];
                        var idx = items.indexOf(config.shiftPattern);
                        return idx >= 0 ? idx : 0;
                    }
                    model: ["center-out", "left-to-right", "right-to-left", "alternating"]

                    onActivated: function (idx) {
                        var items = ["center-out", "left-to-right", "right-to-left", "alternating"];
                        if (idx >= 0 && idx < items.length)
                            config.shiftPattern = items[idx];
                    }
                }
            }
        }
    }
}
