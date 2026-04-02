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
        title: "Bias Gauge"
        visible: config.hasBiasLabels

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

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
                        text: "Left Label"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        text: config.leftLabel

                        onTextEdited: config.leftLabel = text
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: "Right Label"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        text: config.rightLabel

                        onTextEdited: config.rightLabel = text
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                StyledSwitch {
                    checked: config.biasShowSideValues
                    text: "Show Side Values"

                    onToggled: config.biasShowSideValues = checked
                }

                StyledSwitch {
                    checked: config.biasShowCenterValue
                    text: "Show Center Value"

                    onToggled: config.biasShowCenterValue = checked
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
                        text: "Value Unit"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        text: config.biasValueUnit

                        onTextEdited: config.biasValueUnit = text
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 140
                    spacing: 4

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: "Decimals"
                    }

                    StyledSpinBox {
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        Layout.preferredWidth: 140
                        from: 0
                        to: 4
                        value: config.biasValueDecimals

                        onValueChanged: config.biasValueDecimals = value
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
                        text: "Damping Multiplier (0.01 - 1.00)"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.biasDampingMultiplier.toFixed(2)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v >= 0.01 && v <= 1.0)
                                config.biasDampingMultiplier = v;
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
                        text: "Marker Width"
                    }

                    StyledTextField {
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        Layout.preferredWidth: 140
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.biasMarkerWidth.toFixed(1)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v >= 1.0 && v <= 8.0)
                                config.biasMarkerWidth = v;
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                StyledSwitch {
                    checked: config.biasMarkerEnabled
                    text: "Enable Extreme Marker"

                    onToggled: config.biasMarkerEnabled = checked
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: config.biasMarkerEnabled

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: "Marker Color"
                    }

                    StyledColorPicker {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        colorValue: config.biasMarkerColor

                        onColorEdited: function (c) {
                            config.biasMarkerColor = c;
                        }
                    }
                }
            }
        }
    }

    SettingsSection {
        Layout.fillWidth: true
        title: "Display Text"
        visible: config.hasStaticText

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: "Text"
            }

            StyledTextField {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight
                text: config.staticText

                onTextEdited: config.staticText = text
            }

            StyledSwitch {
                checked: config.timeEnabled
                text: "Show Time"

                onToggled: config.timeEnabled = checked
            }
        }
    }
}
