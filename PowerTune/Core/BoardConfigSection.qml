// Copyright (c) PowerTune Digital, Kai Wyborny. All rights reserved.
// BoardConfigSection.qml - Extracted board configuration section
// Communicates via boardConfig property and configChanged signal only.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Utils 1.0
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

Item {
    id: root

    property var boardConfig: ({})
    property var reservedAnalogPorts: []
    property var reservedDigitalPorts: []
    property bool loading: false
    property var speedAnalogPortValues: []
    property var speedDigitalPortValues: []

    signal configChanged(var config)

    Layout.fillWidth: true
    implicitHeight: section.implicitHeight
    implicitWidth: section.implicitWidth

    function buildConfig() {
        var speedAnalogPort = speedAnalogPortValues.length > 0 ? speedAnalogPortValues[Math.max(0, speedAnalogPort.currentIndex)] : 0;
        var speedDigitalPort = speedDigitalPortValues.length > 0 ? speedDigitalPortValues[Math.max(0, speedDigitalPort.currentIndex)] : 0;
        return {
            selectedValue: digitalExtender.currentIndex,
            switchValue: discreteBrightnessEnabled.checked || canIoBrightnessEnabled.checked,
            rpmSource: rpmsourceselector.currentIndex,
            rpmCanVersion: rpmcanversionselector.currentIndex,
            cylinderCombobox: cylindercombobox.currentIndex,
            cylinderComboboxValue: parseFloat(cylindercombobox.currentText),
            cylinderComboboxV2: cylindercomboboxv2.currentIndex,
            cylinderComboboxV2Value: parseFloat(cylindercomboboxv2.currentText),
            cylinderComboboxDi1: cylindercomboboxDi1.currentIndex,
            an7Damping: an7dampingfactor.text,
            brightness: {
                manualEnabled: brightnessManualEnabled.checked,
                discreteEnabled: discreteBrightnessEnabled.checked,
                canIoEnabled: canIoBrightnessEnabled.checked,
                analogEnabled: analogBrightnessEnabled.checked,
                headlightChannel: digitalExtender.currentIndex,
                analogChannel: analogBrightnessChannel.currentIndex
            },
            speedSensor: {
                enabled: speedSensorEnabled.checked,
                sourceType: speedSourceType.currentIndex === 0 ? "analog" : (speedSourceType.currentIndex === 1 ? "analogsquare" : "digital"),
                analogPort: speedAnalogPort,
                digitalPort: speedDigitalPort,
                pulsesPerRev: parseFloat(speedPulsesPerRev.text) || 4.0,
                voltageMultiplier: parseFloat(speedVoltageMultiplier.text) || 1.0,
                frequencyThreshold: parseFloat(speedFrequencyThreshold.text) || 1.2,
                frequencyHysteresis: parseFloat(speedFrequencyHysteresis.text) || 0.2,
                tireCircumference: parseFloat(speedTireCircumference.text) || 2.06,
                finalDriveRatio: parseFloat(speedFinalDriveRatio.text) || 1.0,
                unit: speedUnit.currentIndex === 0 ? "MPH" : "KPH"
            }
        };
    }

    function loadConfig(config) {
        var board = config || {};
        var brightnessConfig = board.brightness || {};
        var speedConfig = board.speedSensor || {};

        loading = true;

        an7dampingfactor.text = board.an7Damping !== undefined && board.an7Damping !== null ? String(board.an7Damping) : "0";

        rpmsourceselector.currentIndex = board.rpmSource !== undefined ? board.rpmSource : 0;
        rpmcanversionselector.currentIndex = board.rpmCanVersion !== undefined ? board.rpmCanVersion : 0;
        cylindercombobox.currentIndex = board.cylinderCombobox !== undefined ? board.cylinderCombobox : 0;
        cylindercomboboxv2.currentIndex = board.cylinderComboboxV2 !== undefined ? board.cylinderComboboxV2 : 0;
        cylindercomboboxDi1.currentIndex = board.cylinderComboboxDi1 !== undefined ? board.cylinderComboboxDi1 : 0;

        brightnessManualEnabled.checked = brightnessConfig.manualEnabled !== undefined ? !!brightnessConfig.manualEnabled : true;

        discreteBrightnessEnabled.checked = brightnessConfig.discreteEnabled !== undefined ? !!brightnessConfig.discreteEnabled : (board.switchValue !== undefined ? !!board.switchValue : false);

        canIoBrightnessEnabled.checked = brightnessConfig.canIoEnabled !== undefined ? !!brightnessConfig.canIoEnabled : false;

        analogBrightnessEnabled.checked = brightnessConfig.analogEnabled !== undefined ? !!brightnessConfig.analogEnabled : false;

        digitalExtender.currentIndex = brightnessConfig.headlightChannel !== undefined ? brightnessConfig.headlightChannel : (board.selectedValue !== undefined ? board.selectedValue : 0);

        analogBrightnessChannel.currentIndex = brightnessConfig.analogChannel !== undefined ? brightnessConfig.analogChannel : 0;

        speedSensorEnabled.checked = speedConfig.enabled !== undefined ? !!speedConfig.enabled : false;
        var sourceType = speedConfig.sourceType !== undefined ? String(speedConfig.sourceType).toLowerCase() : "analog";
        if (sourceType === "analogsquare" || sourceType === "analogfrequency")
            speedSourceType.currentIndex = 1;
        else if (sourceType === "digital" || sourceType === "squarewave" || sourceType === "digitalfrequency")
            speedSourceType.currentIndex = 2;
        else
            speedSourceType.currentIndex = 0;
        var selectedSpeedAnalogPort = speedConfig.analogPort !== undefined ? speedConfig.analogPort : 0;
        var selectedSpeedDigitalPort = speedConfig.digitalPort !== undefined ? speedConfig.digitalPort : 0;
        rebuildSpeedPortModels(selectedSpeedAnalogPort, selectedSpeedDigitalPort);
        speedPulsesPerRev.text = speedConfig.pulsesPerRev !== undefined ? String(speedConfig.pulsesPerRev) : "4.0";
        speedVoltageMultiplier.text = speedConfig.voltageMultiplier !== undefined ? String(speedConfig.voltageMultiplier) : "1.0";
        speedFrequencyThreshold.text = speedConfig.frequencyThreshold !== undefined ? String(speedConfig.frequencyThreshold) : "1.2";
        speedFrequencyHysteresis.text = speedConfig.frequencyHysteresis !== undefined ? String(speedConfig.frequencyHysteresis) : "0.2";
        speedTireCircumference.text = speedConfig.tireCircumference !== undefined ? String(speedConfig.tireCircumference) : "2.06";
        speedFinalDriveRatio.text = speedConfig.finalDriveRatio !== undefined ? String(speedConfig.finalDriveRatio) : "1.0";
        speedUnit.currentIndex = speedConfig.unit === "KPH" ? 1 : 0;

        loading = false;
    }

    function rebuildSpeedPortModels(selectedAnalog, selectedDigital) {
        var analogValues = [];
        var analogLabels = [];
        var digitalValues = [];
        var digitalLabels = [];

        for (var i = 0; i < 8; ++i) {
            var analogBlocked = reservedAnalogPorts.indexOf(i) !== -1;
            if (!analogBlocked || i === selectedAnalog) {
                analogValues.push(i);
                analogLabels.push("EX Analog " + i);
            }

            var digitalBlocked = reservedDigitalPorts.indexOf(i) !== -1;
            if (!digitalBlocked || i === selectedDigital) {
                digitalValues.push(i);
                digitalLabels.push("EX Digital " + (i + 1));
            }
        }

        if (analogValues.length === 0) {
            analogValues = [selectedAnalog >= 0 && selectedAnalog <= 7 ? selectedAnalog : 0];
            analogLabels = ["EX Analog " + analogValues[0]];
        }
        if (digitalValues.length === 0) {
            digitalValues = [selectedDigital >= 0 && selectedDigital <= 7 ? selectedDigital : 0];
            digitalLabels = ["EX Digital " + (digitalValues[0] + 1)];
        }

        speedAnalogPortValues = analogValues;
        speedDigitalPortValues = digitalValues;
        speedAnalogPort.model = analogLabels;
        speedDigitalPort.model = digitalLabels;
        var idxA = speedAnalogPortValues.indexOf(selectedAnalog);
        var idxD = speedDigitalPortValues.indexOf(selectedDigital);
        speedAnalogPort.currentIndex = idxA >= 0 ? idxA : 0;
        speedDigitalPort.currentIndex = idxD >= 0 ? idxD : 0;
    }

    function notifyChanged() {
        if (!loading)
            configChanged(buildConfig());
    }

    onReservedAnalogPortsChanged: {
        if (!loading)
            rebuildSpeedPortModels(speedAnalogPortValues[Math.max(0, speedAnalogPort.currentIndex)] || 0,
                                   speedDigitalPortValues[Math.max(0, speedDigitalPort.currentIndex)] || 0);
    }
    onReservedDigitalPortsChanged: {
        if (!loading)
            rebuildSpeedPortModels(speedAnalogPortValues[Math.max(0, speedAnalogPort.currentIndex)] || 0,
                                   speedDigitalPortValues[Math.max(0, speedDigitalPort.currentIndex)] || 0);
    }

    SettingsSection {
        id: section

        anchors.left: parent.left
        anchors.right: parent.right
        title: "Board Configuration"

        ColumnLayout {
            id: content

            readonly property int boardConfigLabelW: 140

            Layout.fillWidth: true
            spacing: SettingsTheme.sectionPadding

            SettingsRow {
                label: "AN7 Damping"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledTextField {
                    id: an7dampingfactor

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 80
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "0"

                    validator: RegularExpressionValidator {
                        regularExpression: /^(?:[1-9]\d{0,2}|1000)$/
                    }

                    onEditingFinished: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "RPM Source"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledComboBox {
                    id: rpmsourceselector

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    model: ["None", "CAN RPM", "EX Digital 1 Tach"]

                    onActivated: root.notifyChanged()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.sectionPadding
                visible: rpmsourceselector.currentIndex === 1

                Text {
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    text: Translator.translate("Version", Settings.language) + ":"
                    verticalAlignment: Text.AlignVCenter
                }

                StyledComboBox {
                    id: rpmcanversionselector

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 80
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["V1", "V2"]

                    onActivated: root.notifyChanged()
                }

                Text {
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    text: Translator.translate("Cylinders", Settings.language) + ":"
                    verticalAlignment: Text.AlignVCenter
                }

                StyledComboBox {
                    id: cylindercombobox

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 90
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["0.5", "0.6", "0.7", "0.8", "0.9", "1", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "2.9", "3", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9", "4", "4.1", "4.2", "4.3", "4.4", "4.5", "4.6", "4.7", "4.8", "4.9", "5", "5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "5.8", "5.9", "6", "6.1", "6.2", "6.3", "6.4", "6.5", "6.6", "6.7", "6.8", "6.9", "7", "7.1", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7", "7.8", "7.9", "8", "8.1", "8.2", "8.3", "8.4", "8.5", "8.6", "8.7", "8.8", "8.9", "9", "9.1", "9.2", "9.3", "9.4", "9.5", "9.6", "9.7", "9.8", "9.9", "10", "10.1", "10.2", "10.3", "10.4", "10.5", "10.6", "10.7", "10.8", "10.9", "11", "11.1", "11.2", "11.3", "11.4", "11.5", "11.6", "11.7", "11.8", "11.9", "12", "12.1", "12.2", "12.3", "12.4", "12.5", "12.6", "12.7", "12.8", "12.9"]
                    visible: rpmcanversionselector.currentIndex === 0

                    onActivated: root.notifyChanged()
                }

                StyledComboBox {
                    id: cylindercomboboxv2

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 90
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["1", "2", "3", "4", "5", "6", "8", "12"]
                    visible: rpmcanversionselector.currentIndex === 1

                    onActivated: root.notifyChanged()
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.sectionPadding
                visible: rpmsourceselector.currentIndex === 2

                Text {
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    text: Translator.translate("Cylinders", Settings.language) + ":"
                    verticalAlignment: Text.AlignVCenter
                }

                StyledComboBox {
                    id: cylindercomboboxDi1

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 90
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["1", "2", "3", "4", "5", "6", "8", "12"]

                    onActivated: root.notifyChanged()
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            SettingsRow {
                description: "Future runtime source toggle"
                label: "On-Screen Brightness"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledSwitch {
                    id: brightnessManualEnabled

                    Layout.preferredWidth: 100
                    text: checked ? "On" : "Off"

                    onCheckedChanged: root.notifyChanged()
                }
            }

            SettingsRow {
                description: "Future runtime source toggle"
                label: "Discrete Brightness Source"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledSwitch {
                    id: discreteBrightnessEnabled

                    Layout.preferredWidth: 100
                    text: checked ? "On" : "Off"

                    onCheckedChanged: root.notifyChanged()
                }
            }

            SettingsRow {
                description: "Future runtime source toggle"
                label: "CAN/IO Brightness Source"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledSwitch {
                    id: canIoBrightnessEnabled

                    Layout.preferredWidth: 100
                    text: checked ? "On" : "Off"

                    onCheckedChanged: root.notifyChanged()
                }
            }

            SettingsRow {
                description: "Future runtime source toggle"
                label: "Analog Brightness Source"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledSwitch {
                    id: analogBrightnessEnabled

                    Layout.preferredWidth: 100
                    text: checked ? "On" : "Off"

                    onCheckedChanged: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "Headlight Channel"
                visible: discreteBrightnessEnabled.checked || canIoBrightnessEnabled.checked

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledComboBox {
                    id: digitalExtender

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 200
                    model: ["Ex Digital Input 1", "Ex Digital Input 2", "Ex Digital Input 3", "Ex Digital Input 4", "Ex Digital Input 5", "Ex Digital Input 6", "Ex Digital Input 7", "Ex Digital Input 8"]

                    onActivated: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "Analog Brightness Channel"
                visible: analogBrightnessEnabled.checked

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledComboBox {
                    id: analogBrightnessChannel

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 200
                    model: ["Ex Analog Input 1", "Ex Analog Input 2", "Ex Analog Input 3", "Ex Analog Input 4", "Ex Analog Input 5", "Ex Analog Input 6", "Ex Analog Input 7", "Ex Analog Input 8"]

                    onActivated: root.notifyChanged()
                }
            }

            Rectangle { Layout.fillWidth: true; height: SettingsTheme.borderWidth; color: SettingsTheme.border }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontLabel
                font.weight: Font.DemiBold
                text: "Speed Sensor (EX Board)"
            }

            SettingsRow {
                label: "Enable Speed Sensor"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledSwitch {
                    id: speedSensorEnabled

                    Layout.preferredWidth: 100
                    text: checked ? "On" : "Off"

                    onCheckedChanged: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "Source Type"
                visible: speedSensorEnabled.checked

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledComboBox {
                    id: speedSourceType

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 220
                    model: ["Analog Voltage", "Analog Square Wave", "Digital Square Wave"]

                    onActivated: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "Analog Port"
                visible: speedSensorEnabled.checked && (speedSourceType.currentIndex === 0 || speedSourceType.currentIndex === 1)

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledComboBox {
                    id: speedAnalogPort

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 220
                    model: []

                    onActivated: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "Digital Port"
                visible: speedSensorEnabled.checked && speedSourceType.currentIndex === 2

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledComboBox {
                    id: speedDigitalPort

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 220
                    model: []

                    onActivated: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "Pulses / Rev"
                visible: speedSensorEnabled.checked && (speedSourceType.currentIndex === 1 || speedSourceType.currentIndex === 2)

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledTextField {
                    id: speedPulsesPerRev

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 120
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "4.0"

                    onEditingFinished: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "Voltage Multiplier"
                visible: speedSensorEnabled.checked && speedSourceType.currentIndex === 0

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledTextField {
                    id: speedVoltageMultiplier

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 120
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "1.0"

                    onEditingFinished: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "Threshold (V)"
                visible: speedSensorEnabled.checked && speedSourceType.currentIndex === 1

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledTextField {
                    id: speedFrequencyThreshold

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 120
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "1.2"

                    onEditingFinished: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "Hysteresis (V)"
                visible: speedSensorEnabled.checked && speedSourceType.currentIndex === 1

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledTextField {
                    id: speedFrequencyHysteresis

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 120
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "0.2"

                    onEditingFinished: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "Tire Circumference (m)"
                visible: speedSensorEnabled.checked

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledTextField {
                    id: speedTireCircumference

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 120
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "2.06"

                    onEditingFinished: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "Final Drive Ratio"
                visible: speedSensorEnabled.checked

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledTextField {
                    id: speedFinalDriveRatio

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 120
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "1.0"

                    onEditingFinished: root.notifyChanged()
                }
            }

            SettingsRow {
                label: "Unit"
                visible: speedSensorEnabled.checked

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledComboBox {
                    id: speedUnit

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 120
                    model: ["MPH", "KPH"]

                    onActivated: root.notifyChanged()
                }
            }
        }
    }

    Component.onCompleted: {
        if (boardConfig && Object.keys(boardConfig).length > 0)
            loadConfig(boardConfig);
    }

    onBoardConfigChanged: {
        if (!loading && boardConfig)
            loadConfig(boardConfig);
    }
}
