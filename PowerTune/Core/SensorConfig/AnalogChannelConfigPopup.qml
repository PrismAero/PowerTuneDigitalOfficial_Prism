import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Utils 1.0
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

Popup {
    id: popup

    property int channelIndex: -1
    property var channelConfig: ({})
    property real liveRawVoltage: 0.0
    property real liveCalibratedValue: 0.0
    property bool ntcCapable: channelIndex < 6
    property var linearPresetNames: []
    property var ntcPresetNames: []
    property bool loading: false

    signal saved(int channel, var config)
    signal presetApplied(int channel, string presetName, string presetType)

    function comboIndexForValue(model, value) {
        if (!model || !value)
            return 0;
        for (var i = 0; i < model.length; i++) {
            if (model[i] === value)
                return i;
        }
        return 0;
    }

    function loadConfig(config) {
        if (!config)
            config = {};

        loading = true;

        enableSwitch.checked = config.enabled === true || config.enabled === "true";
        nameField.text = config.name !== undefined ? String(config.name) : "";

        var ntcOn = (config.ntcEnabled === true || config.ntcEnabled === "true") && ntcCapable;
        modeCombo.currentIndex = ntcOn ? 1 : 0;

        var lpIdx = comboIndexForValue(linearPresetNames, config.linearPreset);
        linearPresetCombo.currentIndex = lpIdx;

        val0vField.text = config.val0v !== undefined ? String(config.val0v) : "0";
        val5vField.text = config.val5v !== undefined ? String(config.val5v) : "5";
        minVoltageField.text = config.minVoltage !== undefined ? String(config.minVoltage) : "0.0";
        maxVoltageField.text = config.maxVoltage !== undefined ? String(config.maxVoltage) : "5.0";

        var npIdx = comboIndexForValue(ntcPresetNames, config.ntcPreset);
        ntcPresetCombo.currentIndex = npIdx;

        var st = config.steinhartT;
        t1Field.text = (st && st[0] !== undefined) ? String(st[0]) : "25";
        t2Field.text = (st && st[1] !== undefined) ? String(st[1]) : "50";
        t3Field.text = (st && st[2] !== undefined) ? String(st[2]) : "100";

        var sr = config.steinhartR;
        r1Field.text = (sr && sr[0] !== undefined) ? String(sr[0]) : "10000";
        r2Field.text = (sr && sr[1] !== undefined) ? String(sr[1]) : "3950";
        r3Field.text = (sr && sr[2] !== undefined) ? String(sr[2]) : "680";

        divider100Switch.checked = config.divider100 === true || config.divider100 === "true";
        divider1kSwitch.checked = config.divider1k === true || config.divider1k === "true";

        loading = false;
    }

    function buildConfig() {
        return {
            enabled: enableSwitch.checked,
            name: nameField.text,
            linearPreset: linearPresetCombo.currentText,
            val0v: val0vField.text,
            val5v: val5vField.text,
            minVoltage: minVoltageField.text,
            maxVoltage: maxVoltageField.text,
            ntcEnabled: ntcCapable && modeCombo.currentIndex === 1,
            ntcPreset: ntcCapable ? ntcPresetCombo.currentText : "Custom",
            divider100: divider100Switch.checked,
            divider1k: divider1kSwitch.checked,
            steinhartT: [t1Field.text, t2Field.text, t3Field.text],
            steinhartR: [r1Field.text, r2Field.text, r3Field.text]
        };
    }

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    height: Math.min(contentCol.implicitHeight + 40, parent ? parent.height - 40 : 600)
    modal: true
    padding: 0
    width: 700
    x: parent ? (parent.width - width) / 2 : 0
    y: parent ? (parent.height - height) / 2 : 0

    onAboutToShow: loadConfig(channelConfig)
    onChannelConfigChanged: {
        if (visible)
            loadConfig(channelConfig);
    }

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

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    font.weight: Font.DemiBold
                    text: {
                        var title = "Analog Channel " + popup.channelIndex;
                        if (nameField.text.length > 0)
                            title += " - " + nameField.text;
                        return title;
                    }
                }

                Text {
                    Layout.fillWidth: true
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamilyMono
                    font.pixelSize: SettingsTheme.fontCaption
                    text: "Raw: " + popup.liveRawVoltage.toFixed(3) + " V | Calc: " + popup.liveCalibratedValue.toFixed(2)
                }
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
                    title: "Channel Info"

                    SettingsRow {
                        label: "Enable"

                        StyledSwitch {
                            id: enableSwitch

                            checked: false
                        }
                    }

                    SettingsRow {
                        label: "Name"

                        StyledTextField {
                            id: nameField

                            Layout.preferredWidth: 200
                            placeholderText: "Channel " + popup.channelIndex
                        }
                    }
                }

                SettingsSection {
                    Layout.fillWidth: true
                    title: "Calibration Mode"
                    visible: enableSwitch.checked

                    SettingsRow {
                        label: "Mode"

                        StyledComboBox {
                            id: modeCombo

                            model: popup.ntcCapable ? ["Linear", "NTC"] : ["Linear"]
                        }
                    }
                }

                SettingsSection {
                    Layout.fillWidth: true
                    title: "Linear Calibration"
                    visible: enableSwitch.checked && (modeCombo.currentIndex === 0 || !popup.ntcCapable)

                    SettingsRow {
                        label: "Preset"

                        StyledComboBox {
                            id: linearPresetCombo

                            model: popup.linearPresetNames

                            onCurrentIndexChanged: {
                                if (popup.loading)
                                    return;
                                if (currentIndex > 0 && currentText !== "Custom")
                                    popup.presetApplied(popup.channelIndex, currentText, "linear");
                            }
                        }
                    }

                    SettingsRow {
                        label: "Value at 0V"

                        StyledTextField {
                            id: val0vField

                            Layout.preferredWidth: 120
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "0"
                        }
                    }

                    SettingsRow {
                        label: "Value at 5V"

                        StyledTextField {
                            id: val5vField

                            Layout.preferredWidth: 120
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "5"
                        }
                    }

                    SettingsRow {
                        label: "Min Voltage"

                        StyledTextField {
                            id: minVoltageField

                            Layout.preferredWidth: 120
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "0.0"
                        }
                    }

                    SettingsRow {
                        label: "Max Voltage"

                        StyledTextField {
                            id: maxVoltageField

                            Layout.preferredWidth: 120
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "5.0"
                        }
                    }

                    SettingsRow {
                        label: "Voltage Range"

                        Text {
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamilyMono
                            font.pixelSize: SettingsTheme.fontControl
                            text: {
                                var minV = parseFloat(minVoltageField.text);
                                var maxV = parseFloat(maxVoltageField.text);
                                if (isNaN(minV))
                                    minV = 0.0;
                                if (isNaN(maxV))
                                    maxV = 5.0;
                                return minV.toFixed(1) + " - " + maxV.toFixed(1) + " V";
                            }
                        }
                    }
                }

                SettingsSection {
                    Layout.fillWidth: true
                    title: "NTC Calibration"
                    visible: enableSwitch.checked && modeCombo.currentIndex === 1 && popup.ntcCapable

                    SettingsRow {
                        label: "Preset"

                        StyledComboBox {
                            id: ntcPresetCombo

                            model: popup.ntcPresetNames

                            onCurrentIndexChanged: {
                                if (popup.loading)
                                    return;
                                if (currentIndex > 0 && currentText !== "Custom")
                                    popup.presetApplied(popup.channelIndex, currentText, "ntc");
                            }
                        }
                    }

                    SettingsRow {
                        label: "T1 (C)"

                        StyledTextField {
                            id: t1Field

                            Layout.preferredWidth: 120
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "25"
                        }
                    }

                    SettingsRow {
                        label: "R1 (Ohm)"

                        StyledTextField {
                            id: r1Field

                            Layout.preferredWidth: 120
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "10000"
                        }
                    }

                    SettingsRow {
                        label: "T2 (C)"

                        StyledTextField {
                            id: t2Field

                            Layout.preferredWidth: 120
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "50"
                        }
                    }

                    SettingsRow {
                        label: "R2 (Ohm)"

                        StyledTextField {
                            id: r2Field

                            Layout.preferredWidth: 120
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "3950"
                        }
                    }

                    SettingsRow {
                        label: "T3 (C)"

                        StyledTextField {
                            id: t3Field

                            Layout.preferredWidth: 120
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "100"
                        }
                    }

                    SettingsRow {
                        label: "R3 (Ohm)"

                        StyledTextField {
                            id: r3Field

                            Layout.preferredWidth: 120
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "680"
                        }
                    }

                    SettingsRow {
                        label: "100 Ohm Divider"

                        StyledSwitch {
                            id: divider100Switch

                            checked: false
                        }
                    }

                    SettingsRow {
                        label: "1K Ohm Divider"

                        StyledSwitch {
                            id: divider1kSwitch

                            checked: false
                        }
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
            spacing: 10

            StyledButton {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight
                primary: true
                text: "Save"

                onClicked: {
                    popup.saved(popup.channelIndex, popup.buildConfig());
                    popup.close();
                }
            }

            StyledButton {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight
                text: "Cancel"

                onClicked: popup.close()
            }
        }
    }
}
