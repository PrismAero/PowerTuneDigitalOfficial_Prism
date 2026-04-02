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
        title: "Data Source"
        visible: config.hasDatasource

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: "Parameter"
            }

            SensorPicker {
                id: datasourcePicker

                Layout.fillWidth: true
                selectedKey: config.sensorKey

                onSensorSelected: function (key, displayName, unit) {
                    config.sensorKey = config.normalizeAnalogSensorKey(key);
                }
            }
        }
    }

    SettingsSection {
        Layout.fillWidth: true
        title: "Label"
        visible: config.hasLabel

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: "Display Label"
            }

            StyledTextField {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight
                text: config.labelText

                onTextEdited: config.labelText = text
            }
        }
    }

    SettingsSection {
        Layout.fillWidth: true
        title: "Unit + Decimals"
        visible: config.hasUnitDecimals

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
                    text: "Unit"
                }

                StyledTextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    text: config.unitText

                    onTextEdited: config.unitText = text
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 140
                spacing: 4

                Text {
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: "Decimal Places"
                }

                StyledSpinBox {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 140
                    from: 0
                    to: 4
                    value: config.decimals

                    onValueChanged: config.decimals = value
                }
            }
        }
    }

    SettingsSection {
        Layout.fillWidth: true
        title: "Value Range"
        visible: config.hasValueRange

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
                    text: "Min Value"
                }

                StyledTextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: config.minValue.toString()

                    onTextEdited: {
                        var v = parseFloat(text);
                        if (!isNaN(v))
                            config.minValue = v;
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
                    text: "Max Value"
                }

                StyledTextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: config.maxValue.toString()

                    onTextEdited: {
                        var v = parseFloat(text);
                        if (!isNaN(v))
                            config.maxValue = v;
                    }
                }
            }
        }
    }
}
