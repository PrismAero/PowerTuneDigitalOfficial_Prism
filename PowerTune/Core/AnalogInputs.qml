// Copyright (c) PowerTune Digital, Kai Wyborny. All rights reserved.
// AnalogInputs.qml - Analog input calibration with sensor preset selection
// Layout: 1600x684 (after 56px tab bar), no scrolling

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import PowerTune.Utils 1.0
import PowerTune.Settings 1.0

Rectangle {
    anchors.fill: parent
    color: "#1a1a2e"
    id: main

    // * Dense layout constants for 1600x684 content area
    readonly property int rowHeight: 32
    readonly property int rowSpacing: 4
    readonly property int labelWidth: 120
    readonly property int presetWidth: 200
    readonly property int fieldWidth: 120
    readonly property int unitWidth: 80
    readonly property int vRangeWidth: 70
    readonly property int fontSize: 13
    readonly property int contentMargin: 16

    // * Preset names list built from CalibrationHelper
    property var presetNames: {
        var presets = Calibration.linearPresets()
        var names = ["Custom"]
        for (var i = 0; i < presets.length; i++) {
            names.push(presets[i].name)
        }
        return names
    }

    // * Apply a preset to val0v/val5v fields for a given row
    function applyPreset(presetName, val0vField, val5vField) {
        if (presetName === "Custom") return
        var preset = Calibration.getLinearPreset(presetName)
        if (preset && preset.name) {
            val0vField.text = preset.val0v
            val5vField.text = preset.val5v
            inputs.setInputs()
        }
    }

    // * Get the unit string for a preset name
    function getPresetUnit(presetName) {
        if (presetName === "Custom") return ""
        var preset = Calibration.getLinearPreset(presetName)
        return (preset && preset.unit) ? preset.unit : ""
    }

    Item {
        id: dashSettings
        Settings {
            // * Analog input value aliases (used by appsettings.cpp)
            property alias an00save : an00.text
            property alias an05save : an05.text
            property alias an10save : an10.text
            property alias an15save : an15.text
            property alias an20save : an20.text
            property alias an25save : an25.text
            property alias an30save : an30.text
            property alias an35save : an35.text
            property alias an40save : an40.text
            property alias an45save : an45.text
            property alias an50save : an50.text
            property alias an55save : an55.text
            property alias an60save : an60.text
            property alias an65save : an65.text
            property alias an70save : an70.text
            property alias an75save : an75.text
            property alias an80save : an80.text
            property alias an85save : an85.text
            property alias an90save : an90.text
            property alias an95save : an95.text
            property alias an100save : an100.text
            property alias an105save : an105.text

            // * Preset selector persistence
            property alias preset0save : preset0.currentIndex
            property alias preset1save : preset1.currentIndex
            property alias preset2save : preset2.currentIndex
            property alias preset3save : preset3.currentIndex
            property alias preset4save : preset4.currentIndex
            property alias preset5save : preset5.currentIndex
            property alias preset6save : preset6.currentIndex
            property alias preset7save : preset7.currentIndex
            property alias preset8save : preset8.currentIndex
            property alias preset9save : preset9.currentIndex
            property alias preset10save : preset10.currentIndex
        }
    }

    Item {
        id: inputs
        function setInputs() {
            AppSettings.writeAnalogSettings(
                an00.text, an05.text, an10.text, an15.text,
                an20.text, an25.text, an30.text, an35.text,
                an40.text, an45.text, an50.text, an55.text,
                an60.text, an65.text, an70.text, an75.text,
                an80.text, an85.text, an90.text, an95.text,
                an100.text, an105.text
            )
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: contentMargin
        spacing: 0

        // * Header row
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight
            Layout.bottomMargin: rowSpacing

            Text {
                Layout.preferredWidth: labelWidth
                text: "Input"
                font.pixelSize: fontSize
                font.bold: true
                color: "#B0B0B0"
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                Layout.preferredWidth: presetWidth
                text: "Sensor Preset"
                font.pixelSize: fontSize
                font.bold: true
                color: "#B0B0B0"
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                Layout.preferredWidth: fieldWidth
                text: "Val. @ 0V"
                font.pixelSize: fontSize
                font.bold: true
                color: "#B0B0B0"
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                Layout.preferredWidth: fieldWidth
                text: "Val. @ 5V"
                font.pixelSize: fontSize
                font.bold: true
                color: "#B0B0B0"
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                Layout.preferredWidth: unitWidth
                text: "Unit"
                font.pixelSize: fontSize
                font.bold: true
                color: "#B0B0B0"
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                Layout.preferredWidth: vRangeWidth
                text: "Min V"
                font.pixelSize: fontSize
                font.bold: true
                color: "#B0B0B0"
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                Layout.preferredWidth: vRangeWidth
                text: "Max V"
                font.pixelSize: fontSize
                font.bold: true
                color: "#B0B0B0"
                verticalAlignment: Text.AlignVCenter
            }
            Item { Layout.fillWidth: true }
        }

        // * Separator line
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.bottomMargin: rowSpacing
            color: "#3D3D3D"
        }

        // --- Analog 0 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight
            Layout.bottomMargin: rowSpacing

            Text {
                Layout.preferredWidth: labelWidth
                text: Translator.translate("Analog", Settings.language) + " 0"
                font.pixelSize: fontSize
                color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: preset0
                Layout.preferredWidth: presetWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                model: presetNames
                onCurrentIndexChanged: {
                    if (currentIndex > 0) applyPreset(currentText, an00, an05)
                }
            }
            StyledTextField {
                id: an00
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "0"
                enabled: preset0.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            StyledTextField {
                id: an05
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "5"
                enabled: preset0.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            Text {
                Layout.preferredWidth: unitWidth
                text: getPresetUnit(preset0.currentText)
                font.pixelSize: fontSize
                color: "#808080"
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset0.currentIndex > 0 ? Calibration.getPresetMinVoltage(preset0.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset0.currentIndex > 0 ? Calibration.getPresetMaxVoltage(preset0.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            Item { Layout.fillWidth: true }
        }

        // --- Analog 1 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight
            Layout.bottomMargin: rowSpacing

            Text {
                Layout.preferredWidth: labelWidth
                text: Translator.translate("Analog", Settings.language) + " 1"
                font.pixelSize: fontSize
                color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: preset1
                Layout.preferredWidth: presetWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                model: presetNames
                onCurrentIndexChanged: {
                    if (currentIndex > 0) applyPreset(currentText, an10, an15)
                }
            }
            StyledTextField {
                id: an10
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "0"
                enabled: preset1.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            StyledTextField {
                id: an15
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "5"
                enabled: preset1.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            Text {
                Layout.preferredWidth: unitWidth
                text: getPresetUnit(preset1.currentText)
                font.pixelSize: fontSize
                color: "#808080"
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset1.currentIndex > 0 ? Calibration.getPresetMinVoltage(preset1.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset1.currentIndex > 0 ? Calibration.getPresetMaxVoltage(preset1.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            Item { Layout.fillWidth: true }
        }

        // --- Analog 2 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight
            Layout.bottomMargin: rowSpacing

            Text {
                Layout.preferredWidth: labelWidth
                text: Translator.translate("Analog", Settings.language) + " 2"
                font.pixelSize: fontSize
                color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: preset2
                Layout.preferredWidth: presetWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                model: presetNames
                onCurrentIndexChanged: {
                    if (currentIndex > 0) applyPreset(currentText, an20, an25)
                }
            }
            StyledTextField {
                id: an20
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "0"
                enabled: preset2.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            StyledTextField {
                id: an25
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "5"
                enabled: preset2.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            Text {
                Layout.preferredWidth: unitWidth
                text: getPresetUnit(preset2.currentText)
                font.pixelSize: fontSize
                color: "#808080"
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset2.currentIndex > 0 ? Calibration.getPresetMinVoltage(preset2.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset2.currentIndex > 0 ? Calibration.getPresetMaxVoltage(preset2.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            Item { Layout.fillWidth: true }
        }

        // --- Analog 3 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight
            Layout.bottomMargin: rowSpacing

            Text {
                Layout.preferredWidth: labelWidth
                text: Translator.translate("Analog", Settings.language) + " 3"
                font.pixelSize: fontSize
                color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: preset3
                Layout.preferredWidth: presetWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                model: presetNames
                onCurrentIndexChanged: {
                    if (currentIndex > 0) applyPreset(currentText, an30, an35)
                }
            }
            StyledTextField {
                id: an30
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "0"
                enabled: preset3.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            StyledTextField {
                id: an35
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "5"
                enabled: preset3.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            Text {
                Layout.preferredWidth: unitWidth
                text: getPresetUnit(preset3.currentText)
                font.pixelSize: fontSize
                color: "#808080"
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset3.currentIndex > 0 ? Calibration.getPresetMinVoltage(preset3.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset3.currentIndex > 0 ? Calibration.getPresetMaxVoltage(preset3.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            Item { Layout.fillWidth: true }
        }

        // --- Analog 4 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight
            Layout.bottomMargin: rowSpacing

            Text {
                Layout.preferredWidth: labelWidth
                text: Translator.translate("Analog", Settings.language) + " 4"
                font.pixelSize: fontSize
                color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: preset4
                Layout.preferredWidth: presetWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                model: presetNames
                onCurrentIndexChanged: {
                    if (currentIndex > 0) applyPreset(currentText, an40, an45)
                }
            }
            StyledTextField {
                id: an40
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "0"
                enabled: preset4.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            StyledTextField {
                id: an45
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "5"
                enabled: preset4.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            Text {
                Layout.preferredWidth: unitWidth
                text: getPresetUnit(preset4.currentText)
                font.pixelSize: fontSize
                color: "#808080"
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset4.currentIndex > 0 ? Calibration.getPresetMinVoltage(preset4.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset4.currentIndex > 0 ? Calibration.getPresetMaxVoltage(preset4.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            Item { Layout.fillWidth: true }
        }

        // --- Analog 5 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight
            Layout.bottomMargin: rowSpacing

            Text {
                Layout.preferredWidth: labelWidth
                text: Translator.translate("Analog", Settings.language) + " 5"
                font.pixelSize: fontSize
                color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: preset5
                Layout.preferredWidth: presetWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                model: presetNames
                onCurrentIndexChanged: {
                    if (currentIndex > 0) applyPreset(currentText, an50, an55)
                }
            }
            StyledTextField {
                id: an50
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "0"
                enabled: preset5.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            StyledTextField {
                id: an55
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "5"
                enabled: preset5.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            Text {
                Layout.preferredWidth: unitWidth
                text: getPresetUnit(preset5.currentText)
                font.pixelSize: fontSize
                color: "#808080"
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset5.currentIndex > 0 ? Calibration.getPresetMinVoltage(preset5.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset5.currentIndex > 0 ? Calibration.getPresetMaxVoltage(preset5.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            Item { Layout.fillWidth: true }
        }

        // --- Analog 6 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight
            Layout.bottomMargin: rowSpacing

            Text {
                Layout.preferredWidth: labelWidth
                text: Translator.translate("Analog", Settings.language) + " 6"
                font.pixelSize: fontSize
                color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: preset6
                Layout.preferredWidth: presetWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                model: presetNames
                onCurrentIndexChanged: {
                    if (currentIndex > 0) applyPreset(currentText, an60, an65)
                }
            }
            StyledTextField {
                id: an60
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "0"
                enabled: preset6.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            StyledTextField {
                id: an65
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "5"
                enabled: preset6.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            Text {
                Layout.preferredWidth: unitWidth
                text: getPresetUnit(preset6.currentText)
                font.pixelSize: fontSize
                color: "#808080"
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset6.currentIndex > 0 ? Calibration.getPresetMinVoltage(preset6.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset6.currentIndex > 0 ? Calibration.getPresetMaxVoltage(preset6.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            Item { Layout.fillWidth: true }
        }

        // --- Analog 7 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight
            Layout.bottomMargin: rowSpacing

            Text {
                Layout.preferredWidth: labelWidth
                text: Translator.translate("Analog", Settings.language) + " 7"
                font.pixelSize: fontSize
                color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: preset7
                Layout.preferredWidth: presetWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                model: presetNames
                onCurrentIndexChanged: {
                    if (currentIndex > 0) applyPreset(currentText, an70, an75)
                }
            }
            StyledTextField {
                id: an70
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "0"
                enabled: preset7.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            StyledTextField {
                id: an75
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "5"
                enabled: preset7.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            Text {
                Layout.preferredWidth: unitWidth
                text: getPresetUnit(preset7.currentText)
                font.pixelSize: fontSize
                color: "#808080"
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset7.currentIndex > 0 ? Calibration.getPresetMinVoltage(preset7.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset7.currentIndex > 0 ? Calibration.getPresetMaxVoltage(preset7.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            Item { Layout.fillWidth: true }
        }

        // --- Analog 8 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight
            Layout.bottomMargin: rowSpacing

            Text {
                Layout.preferredWidth: labelWidth
                text: Translator.translate("Analog", Settings.language) + " 8"
                font.pixelSize: fontSize
                color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: preset8
                Layout.preferredWidth: presetWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                model: presetNames
                onCurrentIndexChanged: {
                    if (currentIndex > 0) applyPreset(currentText, an80, an85)
                }
            }
            StyledTextField {
                id: an80
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "0"
                enabled: preset8.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            StyledTextField {
                id: an85
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "5"
                enabled: preset8.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            Text {
                Layout.preferredWidth: unitWidth
                text: getPresetUnit(preset8.currentText)
                font.pixelSize: fontSize
                color: "#808080"
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset8.currentIndex > 0 ? Calibration.getPresetMinVoltage(preset8.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset8.currentIndex > 0 ? Calibration.getPresetMaxVoltage(preset8.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            Item { Layout.fillWidth: true }
        }

        // --- Analog 9 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight
            Layout.bottomMargin: rowSpacing

            Text {
                Layout.preferredWidth: labelWidth
                text: Translator.translate("Analog", Settings.language) + " 9"
                font.pixelSize: fontSize
                color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: preset9
                Layout.preferredWidth: presetWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                model: presetNames
                onCurrentIndexChanged: {
                    if (currentIndex > 0) applyPreset(currentText, an90, an95)
                }
            }
            StyledTextField {
                id: an90
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "0"
                enabled: preset9.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            StyledTextField {
                id: an95
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "5"
                enabled: preset9.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            Text {
                Layout.preferredWidth: unitWidth
                text: getPresetUnit(preset9.currentText)
                font.pixelSize: fontSize
                color: "#808080"
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset9.currentIndex > 0 ? Calibration.getPresetMinVoltage(preset9.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset9.currentIndex > 0 ? Calibration.getPresetMaxVoltage(preset9.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            Item { Layout.fillWidth: true }
        }

        // --- Analog 10 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight
            Layout.bottomMargin: rowSpacing

            Text {
                Layout.preferredWidth: labelWidth
                text: Translator.translate("Analog", Settings.language) + " 10"
                font.pixelSize: fontSize
                color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: preset10
                Layout.preferredWidth: presetWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                model: presetNames
                onCurrentIndexChanged: {
                    if (currentIndex > 0) applyPreset(currentText, an100, an105)
                }
            }
            StyledTextField {
                id: an100
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "0"
                enabled: preset10.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
            }
            StyledTextField {
                id: an105
                Layout.preferredWidth: fieldWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: "5"
                enabled: preset10.currentIndex === 0
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onEditingFinished: inputs.setInputs()
                Component.onCompleted: inputs.setInputs()
            }
            Text {
                Layout.preferredWidth: unitWidth
                text: getPresetUnit(preset10.currentText)
                font.pixelSize: fontSize
                color: "#808080"
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset10.currentIndex > 0 ? Calibration.getPresetMinVoltage(preset10.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            StyledTextField {
                Layout.preferredWidth: vRangeWidth
                Layout.preferredHeight: rowHeight
                font.pixelSize: fontSize
                text: preset10.currentIndex > 0 ? Calibration.getPresetMaxVoltage(preset10.currentText).toFixed(1) : ""
                readOnly: true; enabled: false
            }
            Item { Layout.fillWidth: true }
        }

        // * Spacer to absorb remaining vertical space
        Item { Layout.fillHeight: true }
    }
}
