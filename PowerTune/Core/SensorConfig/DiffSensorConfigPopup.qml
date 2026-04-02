import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

Popup {
    id: popup

    property var diffConfig: ({})
    property var unavailableAnalogPorts: []
    property var channelAValues: []
    property var channelBValues: []

    signal saved(var config)

    function rebuildChannelModels(selectedA, selectedB) {
        var valsA = [];
        var labelsA = [];
        var valsB = [];
        var labelsB = [];
        for (var i = 0; i < 8; ++i) {
            var blocked = unavailableAnalogPorts.indexOf(i) !== -1;
            if (!blocked || i === selectedA || i === selectedB) {
                valsA.push(i);
                labelsA.push("EX Analog " + i);
                valsB.push(i);
                labelsB.push("EX Analog " + i);
            }
        }
        if (valsA.length === 0) {
            valsA = [selectedA >= 0 && selectedA <= 7 ? selectedA : 0];
            labelsA = ["EX Analog " + valsA[0]];
        }
        if (valsB.length === 0) {
            valsB = [selectedB >= 0 && selectedB <= 7 ? selectedB : 1];
            labelsB = ["EX Analog " + valsB[0]];
        }

        channelAValues = valsA;
        channelBValues = valsB;
        channelACombo.model = labelsA;
        channelBCombo.model = labelsB;

        var idxA = channelAValues.indexOf(selectedA);
        var idxB = channelBValues.indexOf(selectedB);
        channelACombo.currentIndex = idxA >= 0 ? idxA : 0;
        channelBCombo.currentIndex = idxB >= 0 ? idxB : 0;
    }

    function loadConfig(config) {
        if (!config)
            config = {};
        diffEnabled.checked = config.enabled === true || config.enabled === "true";
        var selectedA = Math.max(0, Math.min(7, parseInt(config.channelA) || 0));
        var selectedB = Math.max(0, Math.min(7, parseInt(config.channelB) || 1));
        rebuildChannelModels(selectedA, selectedB);
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
            channelA: channelAValues.length > 0 ? channelAValues[Math.max(0, channelACombo.currentIndex)] : 0,
            channelB: channelBValues.length > 0 ? channelBValues[Math.max(0, channelBCombo.currentIndex)] : 1,
            formula: formulaValues[formulaCombo.currentIndex],
            offset: parseFloat(offsetField.text) || 0.0
        };
    }

    onUnavailableAnalogPortsChanged: loadConfig(diffConfig || ({}))

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
                            model: []
                        }
                    }

                    SettingsRow {
                        label: "Channel B"
                        description: "Second input channel"
                        visible: diffEnabled.checked

                        StyledComboBox {
                            id: channelBCombo
                            currentIndex: 1
                            model: []
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
