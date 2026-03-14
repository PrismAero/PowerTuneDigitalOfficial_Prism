import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

Popup {
    id: popup

    property var diffConfig: ({})

    signal saved(var config)

    function loadConfig(config) {
        if (!config)
            config = {};
        diffEnabled.checked = config.enabled === true || config.enabled === "true";
        channelACombo.currentIndex = Math.max(0, Math.min(7, parseInt(config.channelA) || 0));
        channelBCombo.currentIndex = Math.max(0, Math.min(7, parseInt(config.channelB) || 1));
        var formulaStr = config.formula || "percentage";
        if (formulaStr === "differential")
            formulaCombo.currentIndex = 1;
        else if (formulaStr === "ratio")
            formulaCombo.currentIndex = 2;
        else
            formulaCombo.currentIndex = 0;
        offsetField.text = config.offset !== undefined ? String(config.offset) : "0.0";
    }

    function buildConfig() {
        var formulaValues = ["percentage", "differential", "ratio"];
        return {
            enabled: diffEnabled.checked,
            channelA: channelACombo.currentIndex,
            channelB: channelBCombo.currentIndex,
            formula: formulaValues[formulaCombo.currentIndex],
            offset: parseFloat(offsetField.text) || 0.0
        };
    }

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    modal: true
    padding: 0
    width: 600
    height: Math.min(contentCol.implicitHeight + 40, parent ? parent.height - 40 : 500)
    x: parent ? (parent.width - width) / 2 : 0
    y: parent ? (parent.height - height) / 2 : 0

    onAboutToShow: loadConfig(diffConfig)

    Overlay.modal: Rectangle {
        color: "#80000000"
    }

    background: Rectangle {
        border.color: SettingsTheme.border
        border.width: 2
        color: SettingsTheme.surfaceElevated
        radius: SettingsTheme.radiusLarge
    }

    ColumnLayout {
        id: contentCol

        anchors.fill: parent
        anchors.margins: 16
        spacing: 0

        RowLayout {
            Layout.bottomMargin: 10
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontLabel
                font.weight: Font.DemiBold
                text: "Differential Sensor"
            }

            Rectangle {
                color: SettingsTheme.surfacePressed
                height: 32
                radius: 16
                width: 32

                Text {
                    anchors.centerIn: parent
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.Bold
                    text: "X"
                }

                TapHandler {
                    onTapped: popup.close()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            color: SettingsTheme.border
            height: 1
        }

        ScrollView {
            id: scrollArea

            Layout.bottomMargin: 10
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.topMargin: 10
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            clip: true
            contentWidth: availableWidth

            ColumnLayout {
                spacing: 10
                width: scrollArea.contentWidth

                SettingsSection {
                    Layout.fillWidth: true
                    title: "Configuration"

                    SettingsRow {
                        label: "Enable"
                        description: "Compute a derived value from two analog channels"

                        StyledSwitch {
                            id: diffEnabled
                            checked: false
                        }
                    }

                    SettingsRow {
                        label: "Channel A"
                        description: "First input channel"
                        visible: diffEnabled.checked

                        StyledComboBox {
                            id: channelACombo
                            model: [
                                "EX Analog 0", "EX Analog 1", "EX Analog 2", "EX Analog 3",
                                "EX Analog 4", "EX Analog 5", "EX Analog 6", "EX Analog 7"
                            ]
                        }
                    }

                    SettingsRow {
                        label: "Channel B"
                        description: "Second input channel"
                        visible: diffEnabled.checked

                        StyledComboBox {
                            id: channelBCombo
                            currentIndex: 1
                            model: [
                                "EX Analog 0", "EX Analog 1", "EX Analog 2", "EX Analog 3",
                                "EX Analog 4", "EX Analog 5", "EX Analog 6", "EX Analog 7"
                            ]
                        }
                    }

                    SettingsRow {
                        label: "Formula"
                        description: "How to combine the two channels"
                        visible: diffEnabled.checked

                        StyledComboBox {
                            id: formulaCombo
                            model: ["Percentage  A/(A+B)*100", "Differential  A-B", "Ratio  A/B"]
                        }
                    }

                    SettingsRow {
                        label: "Offset"
                        description: "Added to the result after calculation"
                        visible: diffEnabled.checked

                        StyledTextField {
                            id: offsetField
                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "0.0"
                        }
                    }
                }

                SettingsSection {
                    Layout.fillWidth: true
                    title: "Live Preview"
                    visible: diffEnabled.checked

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        ColumnLayout {
                            spacing: 4

                            Text {
                                text: "Channel A (AN " + channelACombo.currentIndex + ")"
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontStatus
                            }
                            Text {
                                text: liveCalcValue(channelACombo.currentIndex).toFixed(2)
                                color: SettingsTheme.textPrimary
                                font.family: SettingsTheme.fontFamilyMono
                                font.pixelSize: SettingsTheme.fontLabel
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            spacing: 4

                            Text {
                                text: "Channel B (AN " + channelBCombo.currentIndex + ")"
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontStatus
                            }
                            Text {
                                text: liveCalcValue(channelBCombo.currentIndex).toFixed(2)
                                color: SettingsTheme.textPrimary
                                font.family: SettingsTheme.fontFamilyMono
                                font.pixelSize: SettingsTheme.fontLabel
                                font.bold: true
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            color: SettingsTheme.border
                        }

                        ColumnLayout {
                            spacing: 4

                            Text {
                                text: "Result"
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontStatus
                            }
                            Text {
                                text: computePreview().toFixed(3)
                                color: SettingsTheme.warning
                                font.family: SettingsTheme.fontFamilyMono
                                font.pixelSize: 20
                                font.bold: true
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            color: SettingsTheme.border
            height: 1
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 10
            spacing: SettingsTheme.controlGap

            StyledButton {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight
                primary: true
                text: "Save"

                onClicked: {
                    popup.saved(popup.buildConfig());
                    popup.close();
                }
            }

            StyledButton {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight
                primary: false
                text: "Cancel"

                onClicked: popup.close()
            }
        }
    }

    function liveCalcValue(ch) {
        switch (ch) {
        case 0: return Expander.EXAnalogCalc0;
        case 1: return Expander.EXAnalogCalc1;
        case 2: return Expander.EXAnalogCalc2;
        case 3: return Expander.EXAnalogCalc3;
        case 4: return Expander.EXAnalogCalc4;
        case 5: return Expander.EXAnalogCalc5;
        case 6: return Expander.EXAnalogCalc6;
        case 7: return Expander.EXAnalogCalc7;
        }
        return 0.0;
    }

    function computePreview() {
        var a = liveCalcValue(channelACombo.currentIndex);
        var b = liveCalcValue(channelBCombo.currentIndex);
        var off = parseFloat(offsetField.text) || 0.0;

        switch (formulaCombo.currentIndex) {
        case 0: {
            var sum = a + b;
            return (sum > 0) ? (a / sum) * 100.0 + off : 50.0 + off;
        }
        case 1:
            return a - b + off;
        case 2:
            return (b !== 0) ? (a / b) + off : off;
        }
        return 0.0;
    }
}
