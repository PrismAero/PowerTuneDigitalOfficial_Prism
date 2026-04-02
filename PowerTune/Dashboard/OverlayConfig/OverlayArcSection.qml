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
        title: "Arc Geometry"
        visible: config.hasArcGeometry

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: "Angles use clock-style degrees: 0 at top, 90 at right, 180 at bottom, 270 at left."
                wrapMode: Text.WordWrap
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
                        text: "Start Angle"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.startAngle.toFixed(1)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v))
                                config.startAngle = v;
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
                        text: "End Angle"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.endAngle.toFixed(1)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v))
                                config.endAngle = v;
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
                        text: "Arc Width"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.arcWidth.toFixed(3)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v >= 0.01 && v <= 0.95)
                                config.arcWidth = v;
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
                        text: "Arc Scale"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.arcScale.toFixed(3)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v >= 0.1 && v <= 2.0)
                                config.arcScale = v;
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
                        text: "Arc Offset X"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.arcOffsetX.toFixed(1)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v))
                                config.arcOffsetX = v;
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
                        text: "Arc Offset Y"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.arcOffsetY.toFixed(1)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v))
                                config.arcOffsetY = v;
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
                        text: "Start Seed"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.minimumVisibleFraction.toFixed(3)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v >= 0 && v <= 0.5)
                                config.minimumVisibleFraction = v;
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
                        text: "Value Offset Y"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.valueOffsetY.toFixed(1)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v))
                                config.valueOffsetY = v;
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
                        text: "Start Taper"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.startTaper.toFixed(3)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v >= 0 && v <= 0.49)
                                config.startTaper = v;
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
                        text: "End Taper"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.endTaper.toFixed(3)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v >= 0 && v <= 0.49)
                                config.endTaper = v;
                        }
                    }
                }
            }
        }
    }

    SettingsSection {
        Layout.fillWidth: true
        title: "Arc Colors"
        visible: config.hasArcColors

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

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
                        text: "Start Color"
                    }

                    StyledColorPicker {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        colorValue: config.arcColorStart

                        onColorEdited: function (c) {
                            config.arcColorStart = c;
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
                        text: "Mid Color"
                    }

                    StyledColorPicker {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        colorValue: config.arcColorMid

                        onColorEdited: function (c) {
                            config.arcColorMid = c;
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
                        text: "End Color"
                    }

                    StyledColorPicker {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        colorValue: config.arcColorEnd

                        onColorEdited: function (c) {
                            config.arcColorEnd = c;
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
                        text: "Mid Stop"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.arcColorMidPos.toFixed(2)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v >= 0 && v <= 1)
                                config.arcColorMidPos = v;
                        }
                    }
                }
            }
        }
    }

    SettingsSection {
        Layout.fillWidth: true
        title: "Arc Size"
        visible: config.hasArcOverlaySize

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: "Overlay Size (square)"
            }

            StyledTextField {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: config.overlaySize.toFixed(3)

                onTextEdited: {
                    var v = parseFloat(text);
                    if (!isNaN(v) && v >= 150 && v <= 900)
                        config.overlaySize = v;
                }
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: "Keeps width and height locked together so the arc stays circular."
                wrapMode: Text.WordWrap
            }
        }
    }

    SettingsSection {
        Layout.fillWidth: true
        title: "Readout"
        visible: config.hasReadoutConfig

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
                        text: "Readout Step"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.readoutStep.toString()

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v > 0)
                                config.readoutStep = v;
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
                        text: "Readout Color"
                    }

                    StyledColorPicker {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        colorValue: config.readoutTextColor

                        onColorEdited: function (c) {
                            config.readoutTextColor = c;
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
                        text: "Offset X"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.readoutOffsetX.toFixed(1)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v))
                                config.readoutOffsetX = v;
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
                        text: "Offset Y"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.readoutOffsetY.toFixed(1)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v))
                                config.readoutOffsetY = v;
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
                        text: "Value Scale"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.readoutValueScale.toFixed(3)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v > 0)
                                config.readoutValueScale = v;
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
                        text: "Unit Scale"
                    }

                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: config.readoutUnitScale.toFixed(3)

                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v) && v > 0)
                                config.readoutUnitScale = v;
                        }
                    }
                }
            }
        }
    }

    SettingsSection {
        Layout.fillWidth: true
        title: "Loop Test"
        visible: config.hasArcAlignment

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            StyledSwitch {
                checked: config.testLoopEnabled
                text: "Enable Arc Loop Test"

                onToggled: config.testLoopEnabled = checked
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                visible: config.testLoopEnabled

                Text {
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: "Loop Duration (ms)"
                }

                StyledTextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: config.testLoopDuration.toString()

                    onTextEdited: {
                        var v = parseInt(text);
                        if (!isNaN(v) && v >= 100)
                            config.testLoopDuration = v;
                    }
                }

                Text {
                    Layout.fillWidth: true
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: "Runs the arc from zero to full range and back in place of live sensor input while enabled."
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
