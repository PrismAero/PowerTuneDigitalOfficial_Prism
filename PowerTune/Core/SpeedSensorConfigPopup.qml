import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

Popup {
    id: popup

    property var speedConfig: ({})
    property var expanderData: null

    signal saved(var config)

    function buildConfig() {
        return {
            enabled: enableSwitch.checked,
            sourceType: sourceTypeCombo.currentIndex === 0 ? "Analog" : "Digital",
            analogPort: analogPortCombo.currentIndex,
            digitalPort: digitalPortCombo.currentIndex,
            pulsesPerRev: parseFloat(pulsesPerRevField.text) || 4.0,
            voltageMultiplier: parseFloat(voltageMultiplierField.text) || 1.0,
            tireCircumference: parseFloat(tireCircumferenceField.text) || 2.06,
            finalDriveRatio: parseFloat(finalDriveRatioField.text) || 1.0,
            unit: unitCombo.currentIndex === 0 ? "MPH" : "KPH"
        };
    }

    function loadConfig(config) {
        if (!config)
            return;

        enableSwitch.checked = config.enabled === true || config.enabled === "true";

        if (config.sourceType === "Digital")
            sourceTypeCombo.currentIndex = 1;
        else
            sourceTypeCombo.currentIndex = 0;

        var aPort = parseInt(config.analogPort);
        if (!isNaN(aPort) && aPort >= 0 && aPort <= 7)
            analogPortCombo.currentIndex = aPort;
        else
            analogPortCombo.currentIndex = 0;

        var dPort = parseInt(config.digitalPort);
        if (!isNaN(dPort) && dPort >= 0 && dPort <= 7)
            digitalPortCombo.currentIndex = dPort;
        else
            digitalPortCombo.currentIndex = 0;

        var ppr = parseFloat(config.pulsesPerRev);
        pulsesPerRevField.text = !isNaN(ppr) ? ppr.toString() : "4.0";

        var vm = parseFloat(config.voltageMultiplier);
        voltageMultiplierField.text = !isNaN(vm) ? vm.toString() : "1.0";

        var tc = parseFloat(config.tireCircumference);
        tireCircumferenceField.text = !isNaN(tc) ? tc.toString() : "2.06";

        var fdr = parseFloat(config.finalDriveRatio);
        finalDriveRatioField.text = !isNaN(fdr) ? fdr.toString() : "1.0";

        if (config.unit === "KPH")
            unitCombo.currentIndex = 1;
        else
            unitCombo.currentIndex = 0;
    }

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    height: Math.min(contentCol.implicitHeight + 40, parent ? parent.height - 40 : 500)
    modal: true
    padding: 0
    width: 600
    x: parent ? (parent.width - width) / 2 : 0
    y: parent ? (parent.height - height) / 2 : 0

    onAboutToShow: loadConfig(speedConfig)

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
                text: "Speed Sensor"
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
                    title: "General"

                    SettingsRow {
                        label: "Enable"

                        StyledSwitch {
                            id: enableSwitch

                            checked: false
                        }
                    }

                    SettingsRow {
                        label: "Source Type"
                        visible: enableSwitch.checked

                        StyledComboBox {
                            id: sourceTypeCombo

                            model: ["Analog", "Digital"]
                        }
                    }
                }

                SettingsSection {
                    Layout.fillWidth: true
                    title: "Port Configuration"
                    visible: enableSwitch.checked

                    SettingsRow {
                        label: "Analog Port"
                        visible: sourceTypeCombo.currentIndex === 0

                        StyledComboBox {
                            id: analogPortCombo

                            model: [
                                "EX Analog 0", "EX Analog 1", "EX Analog 2", "EX Analog 3",
                                "EX Analog 4", "EX Analog 5", "EX Analog 6", "EX Analog 7"
                            ]
                        }
                    }

                    SettingsRow {
                        label: "Digital Port"
                        visible: sourceTypeCombo.currentIndex === 1

                        StyledComboBox {
                            id: digitalPortCombo

                            model: [
                                "EX Digital 1", "EX Digital 2", "EX Digital 3", "EX Digital 4",
                                "EX Digital 5", "EX Digital 6", "EX Digital 7", "EX Digital 8"
                            ]
                        }
                    }

                    SettingsRow {
                        label: "Pulses/Rev"
                        visible: sourceTypeCombo.currentIndex === 1

                        StyledTextField {
                            id: pulsesPerRevField

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "4.0"
                        }
                    }

                    SettingsRow {
                        label: "Voltage Multiplier"
                        visible: sourceTypeCombo.currentIndex === 0

                        StyledTextField {
                            id: voltageMultiplierField

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "1.0"
                        }
                    }
                }

                SettingsSection {
                    Layout.fillWidth: true
                    title: "Calibration"
                    visible: enableSwitch.checked

                    SettingsRow {
                        label: "Tire Circumference (m)"

                        StyledTextField {
                            id: tireCircumferenceField

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "2.06"
                        }
                    }

                    SettingsRow {
                        label: "Final Drive Ratio"

                        StyledTextField {
                            id: finalDriveRatioField

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "1.0"
                        }
                    }

                    SettingsRow {
                        label: "Unit"

                        StyledComboBox {
                            id: unitCombo

                            model: ["MPH", "KPH"]
                        }
                    }
                }

                SettingsSection {
                    Layout.fillWidth: true
                    title: "Live Data"
                    visible: enableSwitch.checked

                    SettingsRow {
                        label: "Current Speed"

                        Text {
                            readonly property real liveSpeed: {
                                if (popup.expanderData && popup.expanderData.EXSpeed !== undefined)
                                    return Number(popup.expanderData.EXSpeed);
                                return 0;
                            }

                            color: SettingsTheme.textPrimary
                            font.family: SettingsTheme.fontFamilyMono
                            font.pixelSize: SettingsTheme.fontControl
                            text: liveSpeed.toFixed(1) + " " + (unitCombo.currentIndex === 0 ? "MPH" : "KPH")
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
                    popup.saved(popup.buildConfig());
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
