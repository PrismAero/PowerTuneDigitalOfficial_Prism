import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

Popup {
    id: popup

    property var gearConfig: ({})
    property var expanderData: null
    property var unavailableAnalogPorts: []
    property var analogPortValues: []

    signal saved(var config)

    function rebuildAnalogPortModel(selectedPort) {
        var values = [];
        var labels = [];
        for (var i = 0; i < 8; ++i) {
            var blocked = unavailableAnalogPorts.indexOf(i) !== -1;
            if (!blocked || i === selectedPort) {
                values.push(i);
                labels.push("EX Analog " + i);
            }
        }
        if (values.length === 0) {
            values = [selectedPort >= 0 && selectedPort <= 7 ? selectedPort : 0];
            labels = ["EX Analog " + values[0]];
        }
        analogPortValues = values;
        gearSensorPort.model = labels;
        var idx = analogPortValues.indexOf(selectedPort);
        gearSensorPort.currentIndex = idx >= 0 ? idx : 0;
    }

    function loadConfig(config) {
        if (!config)
            config = {};
        gearSensorEnabled.checked = config.enabled === true || config.enabled === "true";
        var selectedPort = Math.max(0, Math.min(7, parseInt(config.port) || 0));
        rebuildAnalogPortModel(selectedPort);
        gearTolerance.text = config.tolerance !== undefined ? String(config.tolerance) : "0.2";
        gearVoltageN.text = config.voltageN !== undefined ? String(config.voltageN) : "0.0";
        gearVoltageR.text = config.voltageR !== undefined ? String(config.voltageR) : "0.5";
        gearVoltage1.text = config.voltage1 !== undefined ? String(config.voltage1) : "1.0";
        gearVoltage2.text = config.voltage2 !== undefined ? String(config.voltage2) : "1.5";
        gearVoltage3.text = config.voltage3 !== undefined ? String(config.voltage3) : "2.0";
        gearVoltage4.text = config.voltage4 !== undefined ? String(config.voltage4) : "2.5";
        gearVoltage5.text = config.voltage5 !== undefined ? String(config.voltage5) : "3.0";
        gearVoltage6.text = config.voltage6 !== undefined ? String(config.voltage6) : "3.5";
    }

    function buildConfig() {
        return {
            enabled: gearSensorEnabled.checked,
            port: analogPortValues.length > 0 ? analogPortValues[Math.max(0, gearSensorPort.currentIndex)] : 0,
            tolerance: parseFloat(gearTolerance.text) || 0.2,
            voltageN: parseFloat(gearVoltageN.text) || 0.0,
            voltageR: parseFloat(gearVoltageR.text) || 0.0,
            voltage1: parseFloat(gearVoltage1.text) || 0.0,
            voltage2: parseFloat(gearVoltage2.text) || 0.0,
            voltage3: parseFloat(gearVoltage3.text) || 0.0,
            voltage4: parseFloat(gearVoltage4.text) || 0.0,
            voltage5: parseFloat(gearVoltage5.text) || 0.0,
            voltage6: parseFloat(gearVoltage6.text) || 0.0
        };
    }

    onUnavailableAnalogPortsChanged: loadConfig(gearConfig || ({}))

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    modal: true
    padding: 0
    width: 600
    height: Math.min(contentCol.implicitHeight + 40, parent ? parent.height - 40 : 500)
    x: parent ? (parent.width - width) / 2 : 0
    y: parent ? (parent.height - height) / 2 : 0

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
                text: "Gear Position Sensor"
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
                            id: gearSensorEnabled

                            checked: false
                        }
                    }

                    SettingsRow {
                        label: "Analog Port"
                        visible: gearSensorEnabled.checked

                        StyledComboBox {
                            id: gearSensorPort

                            model: []
                        }
                    }

                    SettingsRow {
                        label: "Tolerance (V)"
                        visible: gearSensorEnabled.checked

                        StyledTextField {
                            id: gearTolerance

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "0.2"
                        }
                    }
                }

                SettingsSection {
                    Layout.fillWidth: true
                    title: "Voltage Thresholds"
                    visible: gearSensorEnabled.checked

                    SettingsRow {
                        label: "Neutral"

                        StyledTextField {
                            id: gearVoltageN

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "0.0"
                        }
                    }

                    SettingsRow {
                        label: "Reverse"

                        StyledTextField {
                            id: gearVoltageR

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "0.5"
                        }
                    }

                    SettingsRow {
                        label: "1st Gear"

                        StyledTextField {
                            id: gearVoltage1

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "1.0"
                        }
                    }

                    SettingsRow {
                        label: "2nd Gear"

                        StyledTextField {
                            id: gearVoltage2

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "1.5"
                        }
                    }

                    SettingsRow {
                        label: "3rd Gear"

                        StyledTextField {
                            id: gearVoltage3

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "2.0"
                        }
                    }

                    SettingsRow {
                        label: "4th Gear"

                        StyledTextField {
                            id: gearVoltage4

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "2.5"
                        }
                    }

                    SettingsRow {
                        label: "5th Gear"

                        StyledTextField {
                            id: gearVoltage5

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "3.0"
                        }
                    }

                    SettingsRow {
                        label: "6th Gear"

                        StyledTextField {
                            id: gearVoltage6

                            Layout.preferredWidth: 100
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: "3.5"
                        }
                    }
                }

                SettingsSection {
                    Layout.fillWidth: true
                    title: "Live Reading"
                    visible: gearSensorEnabled.checked

                    SettingsRow {
                        label: "Current"

                        Text {
                            id: liveGearText

                            color: SettingsTheme.textPrimary
                            font.family: SettingsTheme.fontFamilyMono
                            font.pixelSize: SettingsTheme.fontControl
                            text: {
                                if (!popup.expanderData)
                                    return "-- V -> Gear ?";
                                var idx = gearSensorPort.currentIndex;
                                var analogKeys = [
                                    "EXAnalogInput0", "EXAnalogInput1", "EXAnalogInput2", "EXAnalogInput3",
                                    "EXAnalogInput4", "EXAnalogInput5", "EXAnalogInput6", "EXAnalogInput7"
                                ];
                                var raw = 0;
                                if (idx >= 0 && idx < analogKeys.length) {
                                    var val = popup.expanderData[analogKeys[idx]];
                                    if (val !== undefined)
                                        raw = val;
                                }
                                var gear = popup.expanderData.EXGear !== undefined ? popup.expanderData.EXGear : -2;
                                var gearStr;
                                if (gear === -2)
                                    gearStr = "?";
                                else if (gear === -1)
                                    gearStr = "R";
                                else if (gear === 0)
                                    gearStr = "N";
                                else
                                    gearStr = String(gear);
                                return raw.toFixed(3) + " V -> Gear " + gearStr;
                            }
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
