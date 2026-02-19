// Copyright (c) PowerTune Digital, Kai Wyborny. All rights reserved.
// ExBoardAnalog.qml - EX Board analog input calibration with NTC + linear presets
// Layout: 1600x684 (after 56px tab bar), no scrolling, two-panel design

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import PowerTune.Utils 1.0
import PowerTune.Settings 1.0

Rectangle {
    id: mainWindow
    anchors.fill: parent
    color: "#1a1a2e"
    property double rpmfrequencydivider

    property int digiValue
    property string digiStringValue
    property int maxBrightnessOnBoot

    // * Dense layout constants for 1600x684 content area
    readonly property int rowHeight: 32
    readonly property int rowSpacing: 4
    readonly property int fontSize: 13
    readonly property int contentMargin: 16
    readonly property int headerHeight: 24

    // * Left panel column widths
    readonly property int chanColW: 70
    readonly property int linPresetColW: 150
    readonly property int val0vColW: 80
    readonly property int val5vColW: 80
    readonly property int unitColW: 50

    // * Right panel column widths
    readonly property int ntcCheckColW: 40
    readonly property int ntcPresetColW: 145
    readonly property int shFieldW: 52
    readonly property int divCheckColW: 38

    // * Linear preset names list from CalibrationHelper
    property var linearPresetNames: {
        var presets = Calibration.linearPresets()
        var names = ["Custom"]
        for (var i = 0; i < presets.length; i++) {
            names.push(presets[i].name)
        }
        return names
    }

    // * NTC preset names list from CalibrationHelper
    property var ntcPresetNames: {
        var presets = Calibration.ntcPresets()
        var names = ["Custom"]
        for (var i = 0; i < presets.length; i++) {
            names.push(presets[i].name)
        }
        return names
    }

    // * Apply a linear preset to val0v/val5v fields for a given channel
    function applyLinearPreset(presetName, val0vField, val5vField) {
        if (presetName === "Custom") return
        var preset = Calibration.getLinearPreset(presetName)
        if (preset && preset.name) {
            val0vField.text = preset.val0v
            val5vField.text = preset.val5v
            inputs.setInputs()
        }
    }

    // * Apply an NTC preset to T1/R1/T2/R2/T3/R3 fields for a given channel
    function applyNtcPreset(presetName, t1f, r1f, t2f, r2f, t3f, r3f) {
        if (presetName === "Custom") return
        var preset = Calibration.getNtcPreset(presetName)
        if (preset && preset.name) {
            t1f.text = preset.t1
            r1f.text = preset.r1
            t2f.text = preset.t2
            r2f.text = preset.r2
            t3f.text = preset.t3
            r3f.text = preset.r3
            inputs.setInputs()
        }
    }

    // * Get unit string for a linear preset name
    function getLinearUnit(presetName) {
        if (presetName === "Custom") return ""
        var preset = Calibration.getLinearPreset(presetName)
        return (preset && preset.unit) ? preset.unit : ""
    }

    ListModel {
        id: comboBoxModel
        ListElement { text: "Ex Digital Input 1" }
        ListElement { text: "Ex Digital Input 2" }
        ListElement { text: "Ex Digital Input 3" }
        ListElement { text: "Ex Digital Input 4" }
        ListElement { text: "Ex Digital Input 5" }
        ListElement { text: "Ex Digital Input 6" }
        ListElement { text: "Ex Digital Input 7" }
        ListElement { text: "Ex Digital Input 8" }
    }

    // * Settings persistence block - preserves ALL property aliases
    Item {
        id: exsave
        Settings {
            id: settings
            // Linear calibration values (0V and 5V for each of 8 channels)
            property alias ex00save: ex00.text
            property alias ex05save: ex05.text
            property alias ex10save: ex10.text
            property alias ex15save: ex15.text
            property alias ex20save: ex20.text
            property alias ex25save: ex25.text
            property alias ex30save: ex30.text
            property alias ex35save: ex35.text
            property alias ex40save: ex40.text
            property alias ex45save: ex45.text
            property alias ex50save: ex50.text
            property alias ex55save: ex55.text
            property alias ex60save: ex60.text
            property alias ex65save: ex65.text
            property alias ex70save: ex70.text
            property alias ex75save: ex75.text

            // NTC enable checkboxes (AN 0-5)
            property alias checkan0ntcsave: checkan0ntc.checkState
            property alias checkan1ntcsave: checkan1ntc.checkState
            property alias checkan2ntcsave: checkan2ntc.checkState
            property alias checkan3ntcsave: checkan3ntc.checkState
            property alias checkan4ntcsave: checkan4ntc.checkState
            property alias checkan5ntcsave: checkan5ntc.checkState

            // Voltage divider jumper checkboxes (AN 0-5)
            property alias checkan0100save: checkan0100.checkState
            property alias checkan01Ksave: checkan01k.checkState
            property alias checkan1100save: checkan1100.checkState
            property alias checkan11Ksave: checkan11k.checkState
            property alias checkan2100save: checkan2100.checkState
            property alias checkan21Ksave: checkan21k.checkState
            property alias checkan3100save: checkan3100.checkState
            property alias checkan31Ksave: checkan31k.checkState
            property alias checkan4100save: checkan4100.checkState
            property alias checkan41Ksave: checkan41k.checkState
            property alias checkan5100save: checkan5100.checkState
            property alias checkan51Ksave: checkan51k.checkState

            // RPM CAN settings
            property alias rpmcheckboxsave: rpmcheckbox.checkState
            property alias cylindercomboboxsave: cylindercombobox.currentIndex
            property alias cylindercomboboxv2save: cylindercomboboxv2.currentIndex
            property alias rpmcanversionselectorsave: rpmcanversionselector.currentIndex

            // Steinhart-Hart calibration values (AN 0-5, 3 temp/resistance pairs each)
            property alias t10save: t10.text
            property alias r10save: r10.text
            property alias t20save: t20.text
            property alias r20save: r20.text
            property alias t30save: t30.text
            property alias r30save: r30.text
            property alias t11save: t11.text
            property alias r11save: r11.text
            property alias t21save: t21.text
            property alias r21save: r21.text
            property alias t31save: t31.text
            property alias r31save: r31.text
            property alias t12save: t12.text
            property alias r12save: r12.text
            property alias t22save: t22.text
            property alias r22save: r22.text
            property alias t32save: t32.text
            property alias r32save: r32.text
            property alias t13save: t13.text
            property alias r13save: r13.text
            property alias t23save: t23.text
            property alias r23save: r23.text
            property alias t33save: t33.text
            property alias r33save: r33.text
            property alias t14save: t14.text
            property alias r14save: r14.text
            property alias t24save: t24.text
            property alias r24save: r24.text
            property alias t34save: t34.text
            property alias r34save: r34.text
            property alias t15save: t15.text
            property alias r15save: r15.text
            property alias t25save: t25.text
            property alias r25save: r25.text
            property alias t35save: t35.text
            property alias r35save: r35.text

            // AN 7 damping factor
            property alias an7dampingfactorsave: an7dampingfactor.text

            // Bottom bar settings
            property alias selectedValue: digitalExtender.currentIndex
            property alias switchValue: maxBrightnessBoot.checked
        }
    }

    property int rpmCheckboxSaveValue: settings.rpmcheckboxsave
    function getRpmCheckboxSaveValue() {
        return rpmCheckboxSaveValue;
    }

    // * Core data write function - calls AppSettings with all field values
    Item {
        id: inputs
        function setInputs() {
            AppSettings.writeExternalrpm(rpmcheckbox.checked);
            AppSettings.writeEXAN7dampingSettings(an7dampingfactor.text);
            AppSettings.writeEXBoardSettings(ex00.text, ex05.text, ex10.text, ex15.text, ex20.text, ex25.text, ex30.text, ex35.text, ex40.text, ex45.text, ex50.text, ex55.text, ex60.text, ex65.text, ex70.text, ex75.text, checkan0ntc.checkState, checkan1ntc.checkState, checkan2ntc.checkState, checkan3ntc.checkState, checkan4ntc.checkState, checkan5ntc.checkState, checkan0100.checkState, checkan01k.checkState, checkan1100.checkState, checkan11k.checkState, checkan2100.checkState, checkan21k.checkState, checkan3100.checkState, checkan31k.checkState, checkan4100.checkState, checkan41k.checkState, checkan5100.checkState, checkan51k.checkState);
            AppSettings.writeSteinhartSettings(t10.text, t20.text, t30.text, r10.text, r20.text, r30.text, t11.text, t21.text, t31.text, r11.text, r21.text, r31.text, t12.text, t22.text, t32.text, r12.text, r22.text, r32.text, t13.text, t23.text, t33.text, r13.text, r23.text, r33.text, t14.text, t24.text, t34.text, r14.text, r24.text, r34.text, t15.text, t25.text, t35.text, r15.text, r25.text, r35.text);
            if (rpmcheckbox.checked == true) {
                if (rpmcanversionselector.currentIndex == 0) {
                    AppSettings.writeCylinderSettings(cylindercombobox.textAt(cylindercombobox.currentIndex));
                }
                if (rpmcanversionselector.currentIndex == 1) {
                    switch (cylindercomboboxv2.currentIndex) {
                    case 0:
                        AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                        break;
                    case 1:
                        AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                        break;
                    case 2:
                        AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                        break;
                    case 3:
                        AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                        break;
                    case 4:
                        AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                        break;
                    case 5:
                        AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 4);
                        break;
                    case 6:
                        AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                        break;
                    case 7:
                        AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                        break;
                    case 8:
                        AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                        break;
                    }
                }
                AppSettings.writeRPMFrequencySettings(rpmfrequencydivider, 0);
            }
        }
    }

    // * Cylinder RPM frequency divider calculator
    Item {
        id: cylindercalcrpmdi1
        function cylindercalcrpmdi1() {
            switch (cylindercomboboxDi1.currentIndex) {
            case 0: rpmfrequencydivider = 0.25; break;
            case 1: rpmfrequencydivider = 0.5; break;
            case 2: rpmfrequencydivider = 0.75; break;
            case 3: rpmfrequencydivider = 1; break;
            case 4: rpmfrequencydivider = 1.25; break;
            case 5: rpmfrequencydivider = 1.5; break;
            case 6: rpmfrequencydivider = 2; break;
            case 7: rpmfrequencydivider = 2.5; break;
            case 8: rpmfrequencydivider = 3; break;
            }
            inputs.setInputs();
        }
    }

    // =========================================================================
    // MAIN LAYOUT: ColumnLayout with two-panel top + bottom bar
    // =========================================================================
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: contentMargin
        spacing: 8

        // * Two-panel area: left (linear) + right (NTC)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            // =================================================================
            // LEFT PANEL: Linear Calibration (Channel | Preset | Val@0V | Val@5V | Unit)
            // =================================================================
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: 470
                spacing: 0

                // * Left panel header
                Text {
                    text: "Linear Calibration"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#e0e0e0"
                    Layout.fillWidth: true
                    Layout.preferredHeight: headerHeight
                    verticalAlignment: Text.AlignVCenter
                }

                // * Left column headers
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: headerHeight
                    spacing: 4
                    Text { text: "Channel"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: chanColW }
                    Text { text: "Preset"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: linPresetColW }
                    Text { text: "Val @0V"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: val0vColW }
                    Text { text: "Val @5V"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: val5vColW }
                    Text { text: "Unit"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: unitColW }
                }

                // * EX AN 0
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 4
                    Text { text: "EX AN 0"; font.pixelSize: fontSize; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                    StyledComboBox {
                        id: linPreset0
                        model: linearPresetNames
                        Layout.preferredWidth: linPresetColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: 11
                        onActivated: applyLinearPreset(currentText, ex00, ex05)
                    }
                    StyledTextField {
                        id: ex00; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        enabled: !checkan0ntc.checked; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: ex05; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        enabled: !checkan0ntc.checked; onEditingFinished: inputs.setInputs()
                    }
                    Text { text: getLinearUnit(linPreset0.currentText); font.pixelSize: 11; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                }

                // * EX AN 1
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 4
                    Text { text: "EX AN 1"; font.pixelSize: fontSize; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                    StyledComboBox {
                        id: linPreset1
                        model: linearPresetNames
                        Layout.preferredWidth: linPresetColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: 11
                        onActivated: applyLinearPreset(currentText, ex10, ex15)
                    }
                    StyledTextField {
                        id: ex10; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        enabled: !checkan1ntc.checked; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: ex15; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        enabled: !checkan1ntc.checked; onEditingFinished: inputs.setInputs()
                    }
                    Text { text: getLinearUnit(linPreset1.currentText); font.pixelSize: 11; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                }

                // * EX AN 2
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 4
                    Text { text: "EX AN 2"; font.pixelSize: fontSize; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                    StyledComboBox {
                        id: linPreset2
                        model: linearPresetNames
                        Layout.preferredWidth: linPresetColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: 11
                        onActivated: applyLinearPreset(currentText, ex20, ex25)
                    }
                    StyledTextField {
                        id: ex20; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        enabled: !checkan2ntc.checked; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: ex25; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        enabled: !checkan2ntc.checked; onEditingFinished: inputs.setInputs()
                    }
                    Text { text: getLinearUnit(linPreset2.currentText); font.pixelSize: 11; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                }

                // * EX AN 3
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 4
                    Text { text: "EX AN 3"; font.pixelSize: fontSize; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                    StyledComboBox {
                        id: linPreset3
                        model: linearPresetNames
                        Layout.preferredWidth: linPresetColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: 11
                        onActivated: applyLinearPreset(currentText, ex30, ex35)
                    }
                    StyledTextField {
                        id: ex30; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        enabled: !checkan3ntc.checked; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: ex35; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        enabled: !checkan3ntc.checked; onEditingFinished: inputs.setInputs()
                    }
                    Text { text: getLinearUnit(linPreset3.currentText); font.pixelSize: 11; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                }

                // * EX AN 4
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 4
                    Text { text: "EX AN 4"; font.pixelSize: fontSize; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                    StyledComboBox {
                        id: linPreset4
                        model: linearPresetNames
                        Layout.preferredWidth: linPresetColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: 11
                        onActivated: applyLinearPreset(currentText, ex40, ex45)
                    }
                    StyledTextField {
                        id: ex40; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        enabled: !checkan4ntc.checked; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: ex45; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        enabled: !checkan4ntc.checked; onEditingFinished: inputs.setInputs()
                    }
                    Text { text: getLinearUnit(linPreset4.currentText); font.pixelSize: 11; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                }

                // * EX AN 5
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 4
                    Text { text: "EX AN 5"; font.pixelSize: fontSize; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                    StyledComboBox {
                        id: linPreset5
                        model: linearPresetNames
                        Layout.preferredWidth: linPresetColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: 11
                        onActivated: applyLinearPreset(currentText, ex50, ex55)
                    }
                    StyledTextField {
                        id: ex50; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        enabled: !checkan5ntc.checked; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: ex55; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        enabled: !checkan5ntc.checked; onEditingFinished: inputs.setInputs()
                    }
                    Text { text: getLinearUnit(linPreset5.currentText); font.pixelSize: 11; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                }

                // * EX AN 6 (no NTC)
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 4
                    Text { text: "EX AN 6"; font.pixelSize: fontSize; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                    StyledComboBox {
                        id: linPreset6
                        model: linearPresetNames
                        Layout.preferredWidth: linPresetColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: 11
                        onActivated: applyLinearPreset(currentText, ex60, ex65)
                    }
                    StyledTextField {
                        id: ex60; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: ex65; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: inputs.setInputs()
                    }
                    Text { text: getLinearUnit(linPreset6.currentText); font.pixelSize: 11; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                }

                // * EX AN 7 (no NTC)
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 4
                    Text { text: "EX AN 7"; font.pixelSize: fontSize; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                    StyledComboBox {
                        id: linPreset7
                        model: linearPresetNames
                        Layout.preferredWidth: linPresetColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: 11
                        onActivated: applyLinearPreset(currentText, ex70, ex75)
                    }
                    StyledTextField {
                        id: ex70; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: ex75; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: rowHeight
                        font.pixelSize: fontSize; inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: inputs.setInputs()
                    }
                    Text { text: getLinearUnit(linPreset7.currentText); font.pixelSize: 11; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                }

                Item { Layout.fillHeight: true }
            }

            // * Vertical divider between panels
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                color: "#3a3a5e"
            }

            // =================================================================
            // RIGHT PANEL: NTC Temperature Config
            // NTC(check) | Preset | T1 | R1 | T2 | R2 | T3 | R3 | 100ohm | 1Kohm
            // =================================================================
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 0

                // * Right panel header
                Text {
                    text: Translator.translate("NTC Temperature / Voltage Divider", Settings.language)
                    font.pixelSize: 14
                    font.bold: true
                    color: "#e0e0e0"
                    Layout.fillWidth: true
                    Layout.preferredHeight: headerHeight
                    verticalAlignment: Text.AlignVCenter
                }

                // * Right column headers
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: headerHeight
                    spacing: 2
                    Text { text: "NTC"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: ntcCheckColW; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "Preset"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: ntcPresetColW }
                    Text { text: "T1 (C)"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: shFieldW }
                    Text { text: "R1 (O)"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: shFieldW }
                    Text { text: "T2 (C)"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: shFieldW }
                    Text { text: "R2 (O)"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: shFieldW }
                    Text { text: "T3 (C)"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: shFieldW }
                    Text { text: "R3 (O)"; font.pixelSize: 11; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: shFieldW }
                    Text { text: "100O"; font.pixelSize: 10; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: divCheckColW; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "1KO"; font.pixelSize: 10; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: divCheckColW; horizontalAlignment: Text.AlignHCenter }
                }

                // * AN 0 NTC row
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 2
                    StyledCheckBox {
                        id: checkan0ntc; Layout.preferredWidth: ntcCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                    StyledComboBox {
                        id: ntcPreset0; model: ntcPresetNames
                        Layout.preferredWidth: ntcPresetColW; Layout.preferredHeight: rowHeight; font.pixelSize: 11
                        enabled: checkan0ntc.checked
                        onActivated: applyNtcPreset(currentText, t10, r10, t20, r20, t30, r30)
                    }
                    StyledTextField {
                        id: t10; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan0ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r10; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan0ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t20; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan0ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r20; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan0ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t30; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan0ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r30; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan0ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledCheckBox {
                        id: checkan0100; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                    StyledCheckBox {
                        id: checkan01k; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                // * AN 1 NTC row
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 2
                    StyledCheckBox {
                        id: checkan1ntc; Layout.preferredWidth: ntcCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                    StyledComboBox {
                        id: ntcPreset1; model: ntcPresetNames
                        Layout.preferredWidth: ntcPresetColW; Layout.preferredHeight: rowHeight; font.pixelSize: 11
                        enabled: checkan1ntc.checked
                        onActivated: applyNtcPreset(currentText, t11, r11, t21, r21, t31, r31)
                    }
                    StyledTextField {
                        id: t11; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan1ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r11; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan1ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t21; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan1ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r21; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan1ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t31; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan1ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r31; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan1ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledCheckBox {
                        id: checkan1100; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                    StyledCheckBox {
                        id: checkan11k; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                // * AN 2 NTC row
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 2
                    StyledCheckBox {
                        id: checkan2ntc; Layout.preferredWidth: ntcCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                    StyledComboBox {
                        id: ntcPreset2; model: ntcPresetNames
                        Layout.preferredWidth: ntcPresetColW; Layout.preferredHeight: rowHeight; font.pixelSize: 11
                        enabled: checkan2ntc.checked
                        onActivated: applyNtcPreset(currentText, t12, r12, t22, r22, t32, r32)
                    }
                    StyledTextField {
                        id: t12; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan2ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r12; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan2ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t22; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan2ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r22; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan2ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t32; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan2ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r32; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan2ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledCheckBox {
                        id: checkan2100; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                    StyledCheckBox {
                        id: checkan21k; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                // * AN 3 NTC row
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 2
                    StyledCheckBox {
                        id: checkan3ntc; Layout.preferredWidth: ntcCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                    StyledComboBox {
                        id: ntcPreset3; model: ntcPresetNames
                        Layout.preferredWidth: ntcPresetColW; Layout.preferredHeight: rowHeight; font.pixelSize: 11
                        enabled: checkan3ntc.checked
                        onActivated: applyNtcPreset(currentText, t13, r13, t23, r23, t33, r33)
                    }
                    StyledTextField {
                        id: t13; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan3ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r13; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan3ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t23; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan3ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r23; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan3ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t33; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan3ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r33; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan3ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledCheckBox {
                        id: checkan3100; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                    StyledCheckBox {
                        id: checkan31k; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                // * AN 4 NTC row
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 2
                    StyledCheckBox {
                        id: checkan4ntc; Layout.preferredWidth: ntcCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                    StyledComboBox {
                        id: ntcPreset4; model: ntcPresetNames
                        Layout.preferredWidth: ntcPresetColW; Layout.preferredHeight: rowHeight; font.pixelSize: 11
                        enabled: checkan4ntc.checked
                        onActivated: applyNtcPreset(currentText, t14, r14, t24, r24, t34, r34)
                    }
                    StyledTextField {
                        id: t14; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan4ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r14; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan4ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t24; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan4ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r24; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan4ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t34; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan4ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r34; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan4ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledCheckBox {
                        id: checkan4100; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                    StyledCheckBox {
                        id: checkan41k; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                // * AN 5 NTC row
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 2
                    StyledCheckBox {
                        id: checkan5ntc; Layout.preferredWidth: ntcCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                    StyledComboBox {
                        id: ntcPreset5; model: ntcPresetNames
                        Layout.preferredWidth: ntcPresetColW; Layout.preferredHeight: rowHeight; font.pixelSize: 11
                        enabled: checkan5ntc.checked
                        onActivated: applyNtcPreset(currentText, t15, r15, t25, r25, t35, r35)
                    }
                    StyledTextField {
                        id: t15; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan5ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r15; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan5ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t25; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan5ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r25; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan5ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t35; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan5ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r35; Layout.preferredWidth: shFieldW; Layout.preferredHeight: rowHeight; font.pixelSize: fontSize
                        enabled: checkan5ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                    }
                    StyledCheckBox {
                        id: checkan5100; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                    StyledCheckBox {
                        id: checkan51k; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: rowHeight
                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                // * AN 6 placeholder row (no NTC for channels 6-7)
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 2
                    Text {
                        text: "AN 6-7: No NTC"
                        font.pixelSize: 11; font.italic: true; color: "#606080"
                        Layout.fillWidth: true; verticalAlignment: Text.AlignVCenter
                    }
                }

                // * AN 7 placeholder row
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: rowHeight; spacing: 2
                    Item { Layout.fillWidth: true }
                }

                Item { Layout.fillHeight: true }
            }
        }

        // * Separator line above bottom bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#3a3a5e"
        }

        // =====================================================================
        // BOTTOM BAR: Damping, RPM CAN, Digital Input, CAN/IO Brightness
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            spacing: 12

            // * EX AN 7 Damping
            Text {
                text: "AN7 Damping:"
                font.pixelSize: fontSize; font.bold: true; color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextField {
                id: an7dampingfactor
                text: "0"
                Layout.preferredWidth: 60; Layout.preferredHeight: 30
                font.pixelSize: fontSize
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                validator: RegularExpressionValidator { regularExpression: /^(?:[1-9]\d{0,2}|1000)$/ }
                onEditingFinished: inputs.setInputs()
            }

            // * Spacer
            Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: "#3a3a5e" }

            // * RPM CAN checkbox
            Text {
                text: "RPM CAN:"
                font.pixelSize: fontSize; font.bold: true; color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledCheckBox {
                id: rpmcheckbox
                Layout.preferredWidth: 30; Layout.preferredHeight: 30
                onCheckStateChanged: inputs.setInputs()
            }

            // * RPM CAN Version selector (visible when RPM CAN enabled)
            Text {
                text: Translator.translate("Version", Settings.language) + ":"
                font.pixelSize: 11; color: "#FFFFFF"
                visible: rpmcheckbox.checked
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: rpmcanversionselector
                visible: rpmcheckbox.checked
                Layout.preferredWidth: 70; Layout.preferredHeight: 30
                font.pixelSize: 11
                model: ["V1", "V2"]
                onActivated: inputs.setInputs()
            }

            // * Cylinder selector V1 (visible when V1 selected)
            Text {
                text: Translator.translate("Cylinders", Settings.language) + ":"
                font.pixelSize: 11; color: "#FFFFFF"
                visible: rpmcheckbox.checked
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: cylindercombobox
                visible: rpmcanversionselector.currentIndex == 0 && rpmcheckbox.checked
                Layout.preferredWidth: 80; Layout.preferredHeight: 30
                font.pixelSize: 11
                model: ["0.5", "0.6", "0.7", "0.8", "0.9", "1", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "2.9", "3", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9", "4", "4.1", "4.2", "4.3", "4.4", "4.5", "4.6", "4.7", "4.8", "4.9", "5", "5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "5.8", "5.9", "6", "6.1", "6.2", "6.3", "6.4", "6.5", "6.6", "6.7", "6.8", "6.9", "7", "7.1", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7", "7.8", "7.9", "8", "8.1", "8.2", "8.3", "8.4", "8.5", "8.6", "8.7", "8.8", "8.9", "9", "9.1", "9.2", "9.3", "9.4", "9.5", "9.6", "9.7", "9.8", "9.9", "10", "10.1", "10.2", "10.3", "10.4", "10.5", "10.6", "10.7", "10.8", "10.9", "11", "11.1", "11.2", "11.3", "11.4", "11.5", "11.6", "11.7", "11.8", "11.9", "12", "12.1", "12.2", "12.3", "12.4", "12.5", "12.6", "12.7", "12.8", "12.9"]
                onActivated: inputs.setInputs()
            }

            // * Cylinder selector V2 (visible when V2 selected)
            StyledComboBox {
                id: cylindercomboboxv2
                visible: rpmcanversionselector.currentIndex == 1 && rpmcheckbox.checked
                Layout.preferredWidth: 80; Layout.preferredHeight: 30
                font.pixelSize: 11
                model: ["1", "2", "3", "4", "5", "6", "8", "12"]
                onActivated: inputs.setInputs()
            }

            // * Spacer
            Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: "#3a3a5e" }

            // * Digital input headlight channel
            Text {
                text: "Headlight Ch:"
                font.pixelSize: fontSize; font.bold: true; color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledComboBox {
                id: digitalExtender
                model: comboBoxModel
                textRole: "text"
                Layout.preferredWidth: 170; Layout.preferredHeight: 30
                font.pixelSize: 11
                onCurrentIndexChanged: {
                    digiValue = currentIndex;
                    digiStringValue = "Ex Digital Input " + (currentIndex + 1);
                }
            }

            // * Spacer
            Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: "#3a3a5e" }

            // * CAN/IO Brightness Function
            Text {
                text: "CAN/IO Brightness:"
                font.pixelSize: fontSize; font.bold: true; color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
            }
            StyledSwitch {
                id: maxBrightnessBoot
                text: checked ? "On" : "Off"
                checked: settings.value("switchChecked", false)
                Layout.preferredWidth: 80
                onClicked: {
                    settings.setValue("switchChecked", checked);
                    maxBrightnessBoot.text = checked ? "On" : "Off";
                }
            }

            Item { Layout.fillWidth: true }
        }
    }

    Component.onCompleted: {
        inputs.setInputs();
    }

    function executeOnBootAction() {
        if (settings.switchValue) {
            maxBrightnessOnBoot = 1;
        }
    }
}
