// Copyright (c) PowerTune Digital, Kai Wyborny. All rights reserved.
// ExBoardAnalog.qml - EX Board analog input calibration with NTC + linear presets
// Layout: ScrollView with SettingsSection cards

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Utils 1.0
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

Rectangle {
    id: mainWindow
    color: "#1a1a2e"
    property double rpmfrequencydivider

    property int digiValue
    property string digiStringValue
    property int maxBrightnessOnBoot

    readonly property int contentMargin: 16

    readonly property int chanColW: 70
    readonly property int linPresetColW: 145
    readonly property int val0vColW: 75
    readonly property int val5vColW: 75
    readonly property int unitColW: 50
    readonly property int vRangeColW: 48
    readonly property int liveVColW: 80
    readonly property int calibColW: 85
    readonly property int statusColW: 36

    readonly property int ntcCheckColW: 44
    readonly property int ntcPresetColW: 165
    readonly property int shFieldW: 60
    readonly property int divCheckColW: 42

    property var linearPresetNames: {
        var presets = Calibration.linearPresets()
        var names = ["Custom"]
        for (var i = 0; i < presets.length; i++) {
            names.push(presets[i].name)
        }
        return names
    }

    property var ntcPresetNames: {
        var presets = Calibration.ntcPresets()
        var names = ["Custom"]
        for (var i = 0; i < presets.length; i++) {
            names.push(presets[i].name)
        }
        return names
    }

    function applyLinearPreset(presetName, val0vField, val5vField) {
        if (presetName === "Custom") return
        var preset = Calibration.getLinearPreset(presetName)
        if (preset && preset.name) {
            val0vField.text = preset.val0v
            val5vField.text = preset.val5v
            inputs.setInputs()
        }
    }

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

    // Sensor Mapping alias bridge properties (Repeater delegates)
    property var exan0nameRef: null
    property var exan1nameRef: null
    property var exan2nameRef: null
    property var exan3nameRef: null
    property var exan4nameRef: null
    property var exan5nameRef: null
    property var exan6nameRef: null
    property var exan7nameRef: null
    property var exdigi1nameRef: null
    property var exdigi2nameRef: null
    property var exdigi3nameRef: null
    property var exdigi4nameRef: null
    property var exdigi5nameRef: null
    property var exdigi6nameRef: null
    property var exdigi7nameRef: null
    property var exdigi8nameRef: null

    // Hidden fields for Sensor Mapping Settings alias binding
    StyledTextField { id: exan0nameField; visible: false; text: exan0nameRef ? exan0nameRef.text : ""; onTextChanged: if (exan0nameRef && exan0nameRef.text !== text) exan0nameRef.text = text }
    StyledTextField { id: exan1nameField; visible: false; text: exan1nameRef ? exan1nameRef.text : ""; onTextChanged: if (exan1nameRef && exan1nameRef.text !== text) exan1nameRef.text = text }
    StyledTextField { id: exan2nameField; visible: false; text: exan2nameRef ? exan2nameRef.text : ""; onTextChanged: if (exan2nameRef && exan2nameRef.text !== text) exan2nameRef.text = text }
    StyledTextField { id: exan3nameField; visible: false; text: exan3nameRef ? exan3nameRef.text : ""; onTextChanged: if (exan3nameRef && exan3nameRef.text !== text) exan3nameRef.text = text }
    StyledTextField { id: exan4nameField; visible: false; text: exan4nameRef ? exan4nameRef.text : ""; onTextChanged: if (exan4nameRef && exan4nameRef.text !== text) exan4nameRef.text = text }
    StyledTextField { id: exan5nameField; visible: false; text: exan5nameRef ? exan5nameRef.text : ""; onTextChanged: if (exan5nameRef && exan5nameRef.text !== text) exan5nameRef.text = text }
    StyledTextField { id: exan6nameField; visible: false; text: exan6nameRef ? exan6nameRef.text : ""; onTextChanged: if (exan6nameRef && exan6nameRef.text !== text) exan6nameRef.text = text }
    StyledTextField { id: exan7nameField; visible: false; text: exan7nameRef ? exan7nameRef.text : ""; onTextChanged: if (exan7nameRef && exan7nameRef.text !== text) exan7nameRef.text = text }
    StyledTextField { id: exdigi1nameField; visible: false; text: exdigi1nameRef ? exdigi1nameRef.text : ""; onTextChanged: if (exdigi1nameRef && exdigi1nameRef.text !== text) exdigi1nameRef.text = text }
    StyledTextField { id: exdigi2nameField; visible: false; text: exdigi2nameRef ? exdigi2nameRef.text : ""; onTextChanged: if (exdigi2nameRef && exdigi2nameRef.text !== text) exdigi2nameRef.text = text }
    StyledTextField { id: exdigi3nameField; visible: false; text: exdigi3nameRef ? exdigi3nameRef.text : ""; onTextChanged: if (exdigi3nameRef && exdigi3nameRef.text !== text) exdigi3nameRef.text = text }
    StyledTextField { id: exdigi4nameField; visible: false; text: exdigi4nameRef ? exdigi4nameRef.text : ""; onTextChanged: if (exdigi4nameRef && exdigi4nameRef.text !== text) exdigi4nameRef.text = text }
    StyledTextField { id: exdigi5nameField; visible: false; text: exdigi5nameRef ? exdigi5nameRef.text : ""; onTextChanged: if (exdigi5nameRef && exdigi5nameRef.text !== text) exdigi5nameRef.text = text }
    StyledTextField { id: exdigi6nameField; visible: false; text: exdigi6nameRef ? exdigi6nameRef.text : ""; onTextChanged: if (exdigi6nameRef && exdigi6nameRef.text !== text) exdigi6nameRef.text = text }
    StyledTextField { id: exdigi7nameField; visible: false; text: exdigi7nameRef ? exdigi7nameRef.text : ""; onTextChanged: if (exdigi7nameRef && exdigi7nameRef.text !== text) exdigi7nameRef.text = text }
    StyledTextField { id: exdigi8nameField; visible: false; text: exdigi8nameRef ? exdigi8nameRef.text : ""; onTextChanged: if (exdigi8nameRef && exdigi8nameRef.text !== text) exdigi8nameRef.text = text }

    // Hidden backward-compat checkbox for rpmcheckboxsave alias
    StyledCheckBox { id: rpmcheckbox; visible: false }

    Connections {
        target: exan0nameRef
        function onTextChanged() { if (exan0nameField.text !== exan0nameRef.text) exan0nameField.text = exan0nameRef.text }
    }
    Connections {
        target: exan1nameRef
        function onTextChanged() { if (exan1nameField.text !== exan1nameRef.text) exan1nameField.text = exan1nameRef.text }
    }
    Connections {
        target: exan2nameRef
        function onTextChanged() { if (exan2nameField.text !== exan2nameRef.text) exan2nameField.text = exan2nameRef.text }
    }
    Connections {
        target: exan3nameRef
        function onTextChanged() { if (exan3nameField.text !== exan3nameRef.text) exan3nameField.text = exan3nameRef.text }
    }
    Connections {
        target: exan4nameRef
        function onTextChanged() { if (exan4nameField.text !== exan4nameRef.text) exan4nameField.text = exan4nameRef.text }
    }
    Connections {
        target: exan5nameRef
        function onTextChanged() { if (exan5nameField.text !== exan5nameRef.text) exan5nameField.text = exan5nameRef.text }
    }
    Connections {
        target: exan6nameRef
        function onTextChanged() { if (exan6nameField.text !== exan6nameRef.text) exan6nameField.text = exan6nameRef.text }
    }
    Connections {
        target: exan7nameRef
        function onTextChanged() { if (exan7nameField.text !== exan7nameRef.text) exan7nameField.text = exan7nameRef.text }
    }
    Connections {
        target: exdigi1nameRef
        function onTextChanged() { if (exdigi1nameField.text !== exdigi1nameRef.text) exdigi1nameField.text = exdigi1nameRef.text }
    }
    Connections {
        target: exdigi2nameRef
        function onTextChanged() { if (exdigi2nameField.text !== exdigi2nameRef.text) exdigi2nameField.text = exdigi2nameRef.text }
    }
    Connections {
        target: exdigi3nameRef
        function onTextChanged() { if (exdigi3nameField.text !== exdigi3nameRef.text) exdigi3nameField.text = exdigi3nameRef.text }
    }
    Connections {
        target: exdigi4nameRef
        function onTextChanged() { if (exdigi4nameField.text !== exdigi4nameRef.text) exdigi4nameField.text = exdigi4nameRef.text }
    }
    Connections {
        target: exdigi5nameRef
        function onTextChanged() { if (exdigi5nameField.text !== exdigi5nameRef.text) exdigi5nameField.text = exdigi5nameRef.text }
    }
    Connections {
        target: exdigi6nameRef
        function onTextChanged() { if (exdigi6nameField.text !== exdigi6nameRef.text) exdigi6nameField.text = exdigi6nameRef.text }
    }
    Connections {
        target: exdigi7nameRef
        function onTextChanged() { if (exdigi7nameField.text !== exdigi7nameRef.text) exdigi7nameField.text = exdigi7nameRef.text }
    }
    Connections {
        target: exdigi8nameRef
        function onTextChanged() { if (exdigi8nameField.text !== exdigi8nameRef.text) exdigi8nameField.text = exdigi8nameRef.text }
    }

    property int rpmCheckboxSaveValue: AppSettings.getValue("ui/exboard/rpmcheckbox", 0)
    function getRpmCheckboxSaveValue() {
        return rpmCheckboxSaveValue;
    }

    Item {
        id: inputs
        function setInputs() {
            AppSettings.writeExternalrpm(rpmsourceselector.currentIndex > 0);
            AppSettings.writeEXAN7dampingSettings(an7dampingfactor.text);
            AppSettings.writeEXBoardSettings(ex00.text, ex05.text, ex10.text, ex15.text, ex20.text, ex25.text, ex30.text, ex35.text, ex40.text, ex45.text, ex50.text, ex55.text, ex60.text, ex65.text, ex70.text, ex75.text, checkan0ntc.checkState, checkan1ntc.checkState, checkan2ntc.checkState, checkan3ntc.checkState, checkan4ntc.checkState, checkan5ntc.checkState, checkan0100.checkState, checkan01k.checkState, checkan1100.checkState, checkan11k.checkState, checkan2100.checkState, checkan21k.checkState, checkan3100.checkState, checkan31k.checkState, checkan4100.checkState, checkan41k.checkState, checkan5100.checkState, checkan51k.checkState);
            AppSettings.writeSteinhartSettings(t10.text, t20.text, t30.text, r10.text, r20.text, r30.text, t11.text, t21.text, t31.text, r11.text, r21.text, r31.text, t12.text, t22.text, t32.text, r12.text, r22.text, r32.text, t13.text, t23.text, t33.text, r13.text, r23.text, r33.text, t14.text, t24.text, t34.text, r14.text, r24.text, r34.text, t15.text, t25.text, t35.text, r15.text, r25.text, r35.text);
            if (rpmsourceselector.currentIndex === 0) {
                AppSettings.writeRPMFrequencySettings(0, 0);
            } else if (rpmsourceselector.currentIndex === 1) {
                if (rpmcanversionselector.currentIndex == 0) {
                    AppSettings.writeCylinderSettings(cylindercombobox.textAt(cylindercombobox.currentIndex));
                }
                if (rpmcanversionselector.currentIndex == 1) {
                    var multiplier = Calibration.expanderChannelMultiplier(cylindercomboboxv2.currentIndex);
                    AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * multiplier);
                }
                AppSettings.writeRPMFrequencySettings(rpmfrequencydivider, 0);
            } else if (rpmsourceselector.currentIndex === 2) {
                AppSettings.writeRPMFrequencySettings(rpmfrequencydivider, 1);
            }
            AppSettings.setValue("ui/exboard/selectedValue", digitalExtender.currentIndex)
            AppSettings.setValue("ui/exboard/switchValue", maxBrightnessBoot.checked)
            AppSettings.setValue("ui/exboard/rpmSource", rpmsourceselector.currentIndex)
            AppSettings.setValue("ui/exboard/cylinderCombobox", cylindercombobox.currentIndex)
            AppSettings.setValue("ui/exboard/cylinderComboboxV2", cylindercomboboxv2.currentIndex)
            AppSettings.setValue("ui/exboard/cylinderComboboxDi1", cylindercomboboxDi1.currentIndex)
            AppSettings.setValue("ui/exboard/rpmcheckbox", rpmcheckbox.checkState)
            AppSettings.setValue("ui/exboard/exan0name", exan0nameField.text)
            AppSettings.setValue("ui/exboard/exan1name", exan1nameField.text)
            AppSettings.setValue("ui/exboard/exan2name", exan2nameField.text)
            AppSettings.setValue("ui/exboard/exan3name", exan3nameField.text)
            AppSettings.setValue("ui/exboard/exan4name", exan4nameField.text)
            AppSettings.setValue("ui/exboard/exan5name", exan5nameField.text)
            AppSettings.setValue("ui/exboard/exan6name", exan6nameField.text)
            AppSettings.setValue("ui/exboard/exan7name", exan7nameField.text)
            AppSettings.setValue("ui/exboard/exdigi1name", exdigi1nameField.text)
            AppSettings.setValue("ui/exboard/exdigi2name", exdigi2nameField.text)
            AppSettings.setValue("ui/exboard/exdigi3name", exdigi3nameField.text)
            AppSettings.setValue("ui/exboard/exdigi4name", exdigi4nameField.text)
            AppSettings.setValue("ui/exboard/exdigi5name", exdigi5nameField.text)
            AppSettings.setValue("ui/exboard/exdigi6name", exdigi6nameField.text)
            AppSettings.setValue("ui/exboard/exdigi7name", exdigi7nameField.text)
            AppSettings.setValue("ui/exboard/exdigi8name", exdigi8nameField.text)
        }
    }

    Item {
        id: cylindercalcrpmdi1
        function cylindercalcrpmdi1() {
            rpmfrequencydivider = Calibration.frequencyDividerForCylinders(cylindercomboboxDi1.currentIndex);
            inputs.setInputs();
        }
    }

    // =========================================================================
    // MAIN LAYOUT: ScrollView > ColumnLayout with SettingsSection cards
    // =========================================================================
    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.margins: contentMargin
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: scrollView.availableWidth
            spacing: 16

            // =============================================================
            // SECTION 1: Linear Calibration (with live data columns)
            // =============================================================
            SettingsSection {
                title: "Linear Calibration"
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        spacing: 4
                        Text { text: "Channel"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: chanColW }
                        Text { text: "Preset"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: linPresetColW }
                        Text { text: "Val 0V"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: val0vColW }
                        Text { text: "Val 5V"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: val5vColW }
                        Text { text: "Unit"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: unitColW }
                        Text { text: "Min V"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: vRangeColW }
                        Text { text: "Max V"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: vRangeColW }
                        Text { text: "Live V"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: liveVColW }
                        Text { text: "Calibrated"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: calibColW }
                        Text { text: ""; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: statusColW }
                    }

                    // EX AN 0
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 4
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        Text { text: "EX AN 0"; font.pixelSize: 15; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                        StyledComboBox {
                            id: linPreset0
                            model: linearPresetNames
                            Layout.preferredWidth: linPresetColW; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            onActivated: applyLinearPreset(currentText, ex00, ex05)
                        }
                        StyledTextField {
                            id: ex00; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            enabled: !checkan0ntc.checked; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: ex05; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            enabled: !checkan0ntc.checked; onEditingFinished: inputs.setInputs()
                        }
                        Text { text: getLinearUnit(linPreset0.currentText); font.pixelSize: 15; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset0.currentIndex > 0 ? Calibration.getPresetMinVoltage(linPreset0.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset0.currentIndex > 0 ? Calibration.getPresetMaxVoltage(linPreset0.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: (Expander ? Expander.EXAnalogInput0 : 0).toFixed(3); font.pixelSize: 15; color: (Expander ? Expander.EXAnalogInput0 : 0) > 0.001 ? "#4CAF50" : "#606060"; Layout.preferredWidth: liveVColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: checkan0ntc.checked ? "NTC" : (parseFloat(ex00.text) + ((Expander ? Expander.EXAnalogInput0 : 0) / 5.0) * (parseFloat(ex05.text) - parseFloat(ex00.text))).toFixed(2); font.pixelSize: 15; color: "#e0e0e0"; Layout.preferredWidth: calibColW; verticalAlignment: Text.AlignVCenter }
                        Item { Layout.preferredWidth: statusColW; Layout.preferredHeight: 36; Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: (Expander ? Expander.EXAnalogInput0 : 0) > 0.001 ? "#4CAF50" : "#555555" } }
                    }

                    // EX AN 1
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 4
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        Text { text: "EX AN 1"; font.pixelSize: 15; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                        StyledComboBox {
                            id: linPreset1
                            model: linearPresetNames
                            Layout.preferredWidth: linPresetColW; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            onActivated: applyLinearPreset(currentText, ex10, ex15)
                        }
                        StyledTextField {
                            id: ex10; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            enabled: !checkan1ntc.checked; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: ex15; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            enabled: !checkan1ntc.checked; onEditingFinished: inputs.setInputs()
                        }
                        Text { text: getLinearUnit(linPreset1.currentText); font.pixelSize: 15; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset1.currentIndex > 0 ? Calibration.getPresetMinVoltage(linPreset1.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset1.currentIndex > 0 ? Calibration.getPresetMaxVoltage(linPreset1.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: (Expander ? Expander.EXAnalogInput1 : 0).toFixed(3); font.pixelSize: 15; color: (Expander ? Expander.EXAnalogInput1 : 0) > 0.001 ? "#4CAF50" : "#606060"; Layout.preferredWidth: liveVColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: checkan1ntc.checked ? "NTC" : (parseFloat(ex10.text) + ((Expander ? Expander.EXAnalogInput1 : 0) / 5.0) * (parseFloat(ex15.text) - parseFloat(ex10.text))).toFixed(2); font.pixelSize: 15; color: "#e0e0e0"; Layout.preferredWidth: calibColW; verticalAlignment: Text.AlignVCenter }
                        Item { Layout.preferredWidth: statusColW; Layout.preferredHeight: 36; Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: (Expander ? Expander.EXAnalogInput1 : 0) > 0.001 ? "#4CAF50" : "#555555" } }
                    }

                    // EX AN 2
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 4
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        Text { text: "EX AN 2"; font.pixelSize: 15; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                        StyledComboBox {
                            id: linPreset2
                            model: linearPresetNames
                            Layout.preferredWidth: linPresetColW; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            onActivated: applyLinearPreset(currentText, ex20, ex25)
                        }
                        StyledTextField {
                            id: ex20; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            enabled: !checkan2ntc.checked; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: ex25; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            enabled: !checkan2ntc.checked; onEditingFinished: inputs.setInputs()
                        }
                        Text { text: getLinearUnit(linPreset2.currentText); font.pixelSize: 15; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset2.currentIndex > 0 ? Calibration.getPresetMinVoltage(linPreset2.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset2.currentIndex > 0 ? Calibration.getPresetMaxVoltage(linPreset2.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: (Expander ? Expander.EXAnalogInput2 : 0).toFixed(3); font.pixelSize: 15; color: (Expander ? Expander.EXAnalogInput2 : 0) > 0.001 ? "#4CAF50" : "#606060"; Layout.preferredWidth: liveVColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: checkan2ntc.checked ? "NTC" : (parseFloat(ex20.text) + ((Expander ? Expander.EXAnalogInput2 : 0) / 5.0) * (parseFloat(ex25.text) - parseFloat(ex20.text))).toFixed(2); font.pixelSize: 15; color: "#e0e0e0"; Layout.preferredWidth: calibColW; verticalAlignment: Text.AlignVCenter }
                        Item { Layout.preferredWidth: statusColW; Layout.preferredHeight: 36; Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: (Expander ? Expander.EXAnalogInput2 : 0) > 0.001 ? "#4CAF50" : "#555555" } }
                    }

                    // EX AN 3
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 4
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        Text { text: "EX AN 3"; font.pixelSize: 15; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                        StyledComboBox {
                            id: linPreset3
                            model: linearPresetNames
                            Layout.preferredWidth: linPresetColW; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            onActivated: applyLinearPreset(currentText, ex30, ex35)
                        }
                        StyledTextField {
                            id: ex30; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            enabled: !checkan3ntc.checked; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: ex35; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            enabled: !checkan3ntc.checked; onEditingFinished: inputs.setInputs()
                        }
                        Text { text: getLinearUnit(linPreset3.currentText); font.pixelSize: 15; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset3.currentIndex > 0 ? Calibration.getPresetMinVoltage(linPreset3.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset3.currentIndex > 0 ? Calibration.getPresetMaxVoltage(linPreset3.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: (Expander ? Expander.EXAnalogInput3 : 0).toFixed(3); font.pixelSize: 15; color: (Expander ? Expander.EXAnalogInput3 : 0) > 0.001 ? "#4CAF50" : "#606060"; Layout.preferredWidth: liveVColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: checkan3ntc.checked ? "NTC" : (parseFloat(ex30.text) + ((Expander ? Expander.EXAnalogInput3 : 0) / 5.0) * (parseFloat(ex35.text) - parseFloat(ex30.text))).toFixed(2); font.pixelSize: 15; color: "#e0e0e0"; Layout.preferredWidth: calibColW; verticalAlignment: Text.AlignVCenter }
                        Item { Layout.preferredWidth: statusColW; Layout.preferredHeight: 36; Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: (Expander ? Expander.EXAnalogInput3 : 0) > 0.001 ? "#4CAF50" : "#555555" } }
                    }

                    // EX AN 4
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 4
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        Text { text: "EX AN 4"; font.pixelSize: 15; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                        StyledComboBox {
                            id: linPreset4
                            model: linearPresetNames
                            Layout.preferredWidth: linPresetColW; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            onActivated: applyLinearPreset(currentText, ex40, ex45)
                        }
                        StyledTextField {
                            id: ex40; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            enabled: !checkan4ntc.checked; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: ex45; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            enabled: !checkan4ntc.checked; onEditingFinished: inputs.setInputs()
                        }
                        Text { text: getLinearUnit(linPreset4.currentText); font.pixelSize: 15; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset4.currentIndex > 0 ? Calibration.getPresetMinVoltage(linPreset4.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset4.currentIndex > 0 ? Calibration.getPresetMaxVoltage(linPreset4.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: (Expander ? Expander.EXAnalogInput4 : 0).toFixed(3); font.pixelSize: 15; color: (Expander ? Expander.EXAnalogInput4 : 0) > 0.001 ? "#4CAF50" : "#606060"; Layout.preferredWidth: liveVColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: checkan4ntc.checked ? "NTC" : (parseFloat(ex40.text) + ((Expander ? Expander.EXAnalogInput4 : 0) / 5.0) * (parseFloat(ex45.text) - parseFloat(ex40.text))).toFixed(2); font.pixelSize: 15; color: "#e0e0e0"; Layout.preferredWidth: calibColW; verticalAlignment: Text.AlignVCenter }
                        Item { Layout.preferredWidth: statusColW; Layout.preferredHeight: 36; Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: (Expander ? Expander.EXAnalogInput4 : 0) > 0.001 ? "#4CAF50" : "#555555" } }
                    }

                    // EX AN 5
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 4
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        Text { text: "EX AN 5"; font.pixelSize: 15; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                        StyledComboBox {
                            id: linPreset5
                            model: linearPresetNames
                            Layout.preferredWidth: linPresetColW; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            onActivated: applyLinearPreset(currentText, ex50, ex55)
                        }
                        StyledTextField {
                            id: ex50; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            enabled: !checkan5ntc.checked; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: ex55; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            enabled: !checkan5ntc.checked; onEditingFinished: inputs.setInputs()
                        }
                        Text { text: getLinearUnit(linPreset5.currentText); font.pixelSize: 15; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset5.currentIndex > 0 ? Calibration.getPresetMinVoltage(linPreset5.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset5.currentIndex > 0 ? Calibration.getPresetMaxVoltage(linPreset5.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: (Expander ? Expander.EXAnalogInput5 : 0).toFixed(3); font.pixelSize: 15; color: (Expander ? Expander.EXAnalogInput5 : 0) > 0.001 ? "#4CAF50" : "#606060"; Layout.preferredWidth: liveVColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: checkan5ntc.checked ? "NTC" : (parseFloat(ex50.text) + ((Expander ? Expander.EXAnalogInput5 : 0) / 5.0) * (parseFloat(ex55.text) - parseFloat(ex50.text))).toFixed(2); font.pixelSize: 15; color: "#e0e0e0"; Layout.preferredWidth: calibColW; verticalAlignment: Text.AlignVCenter }
                        Item { Layout.preferredWidth: statusColW; Layout.preferredHeight: 36; Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: (Expander ? Expander.EXAnalogInput5 : 0) > 0.001 ? "#4CAF50" : "#555555" } }
                    }

                    // EX AN 6 (no NTC)
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 4
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        Text { text: "EX AN 6"; font.pixelSize: 15; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                        StyledComboBox {
                            id: linPreset6
                            model: linearPresetNames
                            Layout.preferredWidth: linPresetColW; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            onActivated: applyLinearPreset(currentText, ex60, ex65)
                        }
                        StyledTextField {
                            id: ex60; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: ex65; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            onEditingFinished: inputs.setInputs()
                        }
                        Text { text: getLinearUnit(linPreset6.currentText); font.pixelSize: 15; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset6.currentIndex > 0 ? Calibration.getPresetMinVoltage(linPreset6.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset6.currentIndex > 0 ? Calibration.getPresetMaxVoltage(linPreset6.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: (Expander ? Expander.EXAnalogInput6 : 0).toFixed(3); font.pixelSize: 15; color: (Expander ? Expander.EXAnalogInput6 : 0) > 0.001 ? "#4CAF50" : "#606060"; Layout.preferredWidth: liveVColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: (parseFloat(ex60.text) + ((Expander ? Expander.EXAnalogInput6 : 0) / 5.0) * (parseFloat(ex65.text) - parseFloat(ex60.text))).toFixed(2); font.pixelSize: 15; color: "#e0e0e0"; Layout.preferredWidth: calibColW; verticalAlignment: Text.AlignVCenter }
                        Item { Layout.preferredWidth: statusColW; Layout.preferredHeight: 36; Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: (Expander ? Expander.EXAnalogInput6 : 0) > 0.001 ? "#4CAF50" : "#555555" } }
                    }

                    // EX AN 7 (no NTC)
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 4
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        Text { text: "EX AN 7"; font.pixelSize: 15; color: "#FFFFFF"; Layout.preferredWidth: chanColW; verticalAlignment: Text.AlignVCenter }
                        StyledComboBox {
                            id: linPreset7
                            model: linearPresetNames
                            Layout.preferredWidth: linPresetColW; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            onActivated: applyLinearPreset(currentText, ex70, ex75)
                        }
                        StyledTextField {
                            id: ex70; text: "0"; Layout.preferredWidth: val0vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: ex75; text: "5"; Layout.preferredWidth: val5vColW; Layout.preferredHeight: 36
                            font.pixelSize: 15; inputMethodHints: Qt.ImhFormattedNumbersOnly
                            onEditingFinished: inputs.setInputs()
                        }
                        Text { text: getLinearUnit(linPreset7.currentText); font.pixelSize: 15; color: "#a0a0a0"; Layout.preferredWidth: unitColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset7.currentIndex > 0 ? Calibration.getPresetMinVoltage(linPreset7.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: linPreset7.currentIndex > 0 ? Calibration.getPresetMaxVoltage(linPreset7.currentText).toFixed(1) : ""; font.pixelSize: 15; color: "#808080"; Layout.preferredWidth: vRangeColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: (Expander ? Expander.EXAnalogInput7 : 0).toFixed(3); font.pixelSize: 15; color: (Expander ? Expander.EXAnalogInput7 : 0) > 0.001 ? "#4CAF50" : "#606060"; Layout.preferredWidth: liveVColW; verticalAlignment: Text.AlignVCenter }
                        Text { text: (parseFloat(ex70.text) + ((Expander ? Expander.EXAnalogInput7 : 0) / 5.0) * (parseFloat(ex75.text) - parseFloat(ex70.text))).toFixed(2); font.pixelSize: 15; color: "#e0e0e0"; Layout.preferredWidth: calibColW; verticalAlignment: Text.AlignVCenter }
                        Item { Layout.preferredWidth: statusColW; Layout.preferredHeight: 36; Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: (Expander ? Expander.EXAnalogInput7 : 0) > 0.001 ? "#4CAF50" : "#555555" } }
                    }
                }
            }

            // =============================================================
            // SECTION 2: NTC Temperature / Voltage Divider
            // =============================================================
            SettingsSection {
                title: Translator.translate("NTC Temperature / Voltage Divider", Settings.language)
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        spacing: 2
                        Text { text: "NTC"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: ntcCheckColW; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "Preset"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: ntcPresetColW }
                        Text { text: "T1 (C)"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: shFieldW }
                        Text { text: "R1 (O)"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: shFieldW }
                        Text { text: "T2 (C)"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: shFieldW }
                        Text { text: "R2 (O)"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: shFieldW }
                        Text { text: "T3 (C)"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: shFieldW }
                        Text { text: "R3 (O)"; font.pixelSize: 15; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: shFieldW }
                        Text { text: "100O"; font.pixelSize: 12; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: divCheckColW; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "1KO"; font.pixelSize: 12; font.bold: true; color: "#a0a0a0"; Layout.preferredWidth: divCheckColW; horizontalAlignment: Text.AlignHCenter }
                    }

                    // AN 0 NTC row
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 2
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        StyledCheckBox {
                            id: checkan0ntc; Layout.preferredWidth: ntcCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                        StyledComboBox {
                            id: ntcPreset0; model: ntcPresetNames
                            Layout.preferredWidth: ntcPresetColW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan0ntc.checked
                            onActivated: applyNtcPreset(currentText, t10, r10, t20, r20, t30, r30)
                        }
                        StyledTextField {
                            id: t10; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan0ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r10; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan0ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: t20; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan0ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r20; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan0ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: t30; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan0ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r30; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan0ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledCheckBox {
                            id: checkan0100; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                        StyledCheckBox {
                            id: checkan01k; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                    }

                    // AN 1 NTC row
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 2
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        StyledCheckBox {
                            id: checkan1ntc; Layout.preferredWidth: ntcCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                        StyledComboBox {
                            id: ntcPreset1; model: ntcPresetNames
                            Layout.preferredWidth: ntcPresetColW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan1ntc.checked
                            onActivated: applyNtcPreset(currentText, t11, r11, t21, r21, t31, r31)
                        }
                        StyledTextField {
                            id: t11; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan1ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r11; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan1ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: t21; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan1ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r21; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan1ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: t31; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan1ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r31; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan1ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledCheckBox {
                            id: checkan1100; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                        StyledCheckBox {
                            id: checkan11k; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                    }

                    // AN 2 NTC row
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 2
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        StyledCheckBox {
                            id: checkan2ntc; Layout.preferredWidth: ntcCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                        StyledComboBox {
                            id: ntcPreset2; model: ntcPresetNames
                            Layout.preferredWidth: ntcPresetColW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan2ntc.checked
                            onActivated: applyNtcPreset(currentText, t12, r12, t22, r22, t32, r32)
                        }
                        StyledTextField {
                            id: t12; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan2ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r12; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan2ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: t22; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan2ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r22; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan2ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: t32; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan2ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r32; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan2ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledCheckBox {
                            id: checkan2100; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                        StyledCheckBox {
                            id: checkan21k; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                    }

                    // AN 3 NTC row
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 2
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        StyledCheckBox {
                            id: checkan3ntc; Layout.preferredWidth: ntcCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                        StyledComboBox {
                            id: ntcPreset3; model: ntcPresetNames
                            Layout.preferredWidth: ntcPresetColW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan3ntc.checked
                            onActivated: applyNtcPreset(currentText, t13, r13, t23, r23, t33, r33)
                        }
                        StyledTextField {
                            id: t13; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan3ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r13; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan3ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: t23; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan3ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r23; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan3ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: t33; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan3ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r33; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan3ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledCheckBox {
                            id: checkan3100; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                        StyledCheckBox {
                            id: checkan31k; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                    }

                    // AN 4 NTC row
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 2
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        StyledCheckBox {
                            id: checkan4ntc; Layout.preferredWidth: ntcCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                        StyledComboBox {
                            id: ntcPreset4; model: ntcPresetNames
                            Layout.preferredWidth: ntcPresetColW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan4ntc.checked
                            onActivated: applyNtcPreset(currentText, t14, r14, t24, r24, t34, r34)
                        }
                        StyledTextField {
                            id: t14; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan4ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r14; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan4ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: t24; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan4ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r24; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan4ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: t34; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan4ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r34; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan4ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledCheckBox {
                            id: checkan4100; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                        StyledCheckBox {
                            id: checkan41k; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                    }

                    // AN 5 NTC row
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 38; spacing: 2
                        Layout.leftMargin: 12; Layout.rightMargin: 12
                        StyledCheckBox {
                            id: checkan5ntc; Layout.preferredWidth: ntcCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                        StyledComboBox {
                            id: ntcPreset5; model: ntcPresetNames
                            Layout.preferredWidth: ntcPresetColW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan5ntc.checked
                            onActivated: applyNtcPreset(currentText, t15, r15, t25, r25, t35, r35)
                        }
                        StyledTextField {
                            id: t15; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan5ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r15; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan5ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: t25; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan5ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r25; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan5ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: t35; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan5ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledTextField {
                            id: r35; Layout.preferredWidth: shFieldW; Layout.preferredHeight: 36; font.pixelSize: 15
                            enabled: checkan5ntc.checked; inputMethodHints: Qt.ImhFormattedNumbersOnly; onEditingFinished: inputs.setInputs()
                        }
                        StyledCheckBox {
                            id: checkan5100; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                        StyledCheckBox {
                            id: checkan51k; Layout.preferredWidth: divCheckColW; Layout.preferredHeight: 36
                            onCheckStateChanged: inputs.setInputs()
                        }
                    }

                    Text {
                        text: "AN 6-7: No NTC"
                        font.pixelSize: 12; font.italic: true; color: "#606080"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // =============================================================
            // SECTION 3: Board Configuration
            // =============================================================
            SettingsSection {
                title: "Board Configuration"
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        Text {
                            text: "AN7 Damping"
                            font.pixelSize: 18; color: "#FFFFFF"
                            verticalAlignment: Text.AlignVCenter
                        }
                        StyledTextField {
                            id: an7dampingfactor
                            text: "0"
                            Layout.preferredWidth: 80; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: RegularExpressionValidator { regularExpression: /^(?:[1-9]\d{0,2}|1000)$/ }
                            onEditingFinished: inputs.setInputs()
                        }
                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        Text {
                            text: "RPM Source"
                            font.pixelSize: 18; color: "#FFFFFF"
                            Layout.preferredWidth: 160
                        }
                        StyledComboBox {
                            id: rpmsourceselector
                            Layout.preferredHeight: 36
                            font.pixelSize: 15
                            model: ["None", "CAN RPM", "EX Digital 1 Tach"]
                            onActivated: inputs.setInputs()
                        }
                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        visible: rpmsourceselector.currentIndex === 1
                        Text {
                            text: Translator.translate("Version", Settings.language) + ":"
                            font.pixelSize: 15; color: "#FFFFFF"
                            verticalAlignment: Text.AlignVCenter
                        }
                        StyledComboBox {
                            id: rpmcanversionselector
                            Layout.preferredWidth: 80; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            model: ["V1", "V2"]
                            onActivated: inputs.setInputs()
                        }
                        Text {
                            text: Translator.translate("Cylinders", Settings.language) + ":"
                            font.pixelSize: 15; color: "#FFFFFF"
                            verticalAlignment: Text.AlignVCenter
                        }
                        StyledComboBox {
                            id: cylindercombobox
                            visible: rpmcanversionselector.currentIndex == 0
                            Layout.preferredWidth: 90; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            model: ["0.5", "0.6", "0.7", "0.8", "0.9", "1", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "2.9", "3", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9", "4", "4.1", "4.2", "4.3", "4.4", "4.5", "4.6", "4.7", "4.8", "4.9", "5", "5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "5.8", "5.9", "6", "6.1", "6.2", "6.3", "6.4", "6.5", "6.6", "6.7", "6.8", "6.9", "7", "7.1", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7", "7.8", "7.9", "8", "8.1", "8.2", "8.3", "8.4", "8.5", "8.6", "8.7", "8.8", "8.9", "9", "9.1", "9.2", "9.3", "9.4", "9.5", "9.6", "9.7", "9.8", "9.9", "10", "10.1", "10.2", "10.3", "10.4", "10.5", "10.6", "10.7", "10.8", "10.9", "11", "11.1", "11.2", "11.3", "11.4", "11.5", "11.6", "11.7", "11.8", "11.9", "12", "12.1", "12.2", "12.3", "12.4", "12.5", "12.6", "12.7", "12.8", "12.9"]
                            onActivated: inputs.setInputs()
                        }
                        StyledComboBox {
                            id: cylindercomboboxv2
                            visible: rpmcanversionselector.currentIndex == 1
                            Layout.preferredWidth: 90; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            model: ["1", "2", "3", "4", "5", "6", "8", "12"]
                            onActivated: inputs.setInputs()
                        }
                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        visible: rpmsourceselector.currentIndex === 2
                        Text {
                            text: Translator.translate("Cylinders", Settings.language) + ":"
                            font.pixelSize: 15; color: "#FFFFFF"
                            verticalAlignment: Text.AlignVCenter
                        }
                        StyledComboBox {
                            id: cylindercomboboxDi1
                            Layout.preferredWidth: 90; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            model: ["1", "2", "3", "4", "5", "6", "8", "12"]
                            onActivated: cylindercalcrpmdi1.cylindercalcrpmdi1()
                        }
                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        Text {
                            text: "Headlight Channel"
                            font.pixelSize: 18; color: "#FFFFFF"
                            verticalAlignment: Text.AlignVCenter
                        }
                        StyledComboBox {
                            id: digitalExtender
                            model: comboBoxModel
                            textRole: "text"
                            Layout.preferredWidth: 200; Layout.preferredHeight: 36
                            font.pixelSize: 15
                            onCurrentIndexChanged: {
                                digiValue = currentIndex;
                                digiStringValue = "Ex Digital Input " + (currentIndex + 1);
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        Text {
                            text: "CAN/IO Brightness"
                            font.pixelSize: 18; color: "#FFFFFF"
                            verticalAlignment: Text.AlignVCenter
                        }
                        StyledSwitch {
                            id: maxBrightnessBoot
                            text: checked ? "On" : "Off"
                            Layout.preferredWidth: 100
                            onCheckedChanged: inputs.setInputs()
                        }
                        Item { Layout.fillWidth: true }
                    }
                }
            }

            // =============================================================
            // SECTION 4: Sensor Mapping
            // =============================================================
            SettingsSection {
                title: "Sensor Mapping"
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 24

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "Analog Channels"
                            font.pixelSize: 16; font.weight: Font.DemiBold; color: "#009688"
                        }

                        Repeater {
                            model: 8
                            RowLayout {
                                spacing: 8
                                Text {
                                    text: "EX AN " + index
                                    font.pixelSize: 15; color: "#FFFFFF"
                                    Layout.preferredWidth: 80
                                }
                                StyledTextField {
                                    id: anNameField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    font.pixelSize: 15
                                    placeholderText: "Custom name..."
                                    Component.onCompleted: {
                                        if (index === 0) mainWindow.exan0nameRef = anNameField
                                        else if (index === 1) mainWindow.exan1nameRef = anNameField
                                        else if (index === 2) mainWindow.exan2nameRef = anNameField
                                        else if (index === 3) mainWindow.exan3nameRef = anNameField
                                        else if (index === 4) mainWindow.exan4nameRef = anNameField
                                        else if (index === 5) mainWindow.exan5nameRef = anNameField
                                        else if (index === 6) mainWindow.exan6nameRef = anNameField
                                        else if (index === 7) mainWindow.exan7nameRef = anNameField
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "Digital Channels"
                            font.pixelSize: 16; font.weight: Font.DemiBold; color: "#009688"
                        }

                        Repeater {
                            model: 8
                            RowLayout {
                                spacing: 8
                                Text {
                                    text: "EX Digi " + (index + 1)
                                    font.pixelSize: 15; color: "#FFFFFF"
                                    Layout.preferredWidth: 80
                                }
                                StyledTextField {
                                    id: digiNameField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    font.pixelSize: 15
                                    placeholderText: "Custom name..."
                                    Component.onCompleted: {
                                        if (index === 0) mainWindow.exdigi1nameRef = digiNameField
                                        else if (index === 1) mainWindow.exdigi2nameRef = digiNameField
                                        else if (index === 2) mainWindow.exdigi3nameRef = digiNameField
                                        else if (index === 3) mainWindow.exdigi4nameRef = digiNameField
                                        else if (index === 4) mainWindow.exdigi5nameRef = digiNameField
                                        else if (index === 5) mainWindow.exdigi6nameRef = digiNameField
                                        else if (index === 6) mainWindow.exdigi7nameRef = digiNameField
                                        else if (index === 7) mainWindow.exdigi8nameRef = digiNameField
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        ex00.text = AppSettings.getValue("EXA00", "0")
        ex05.text = AppSettings.getValue("EXA05", "5")
        ex10.text = AppSettings.getValue("EXA10", "0")
        ex15.text = AppSettings.getValue("EXA15", "5")
        ex20.text = AppSettings.getValue("EXA20", "0")
        ex25.text = AppSettings.getValue("EXA25", "5")
        ex30.text = AppSettings.getValue("EXA30", "0")
        ex35.text = AppSettings.getValue("EXA35", "5")
        ex40.text = AppSettings.getValue("EXA40", "0")
        ex45.text = AppSettings.getValue("EXA45", "5")
        ex50.text = AppSettings.getValue("EXA50", "0")
        ex55.text = AppSettings.getValue("EXA55", "5")
        ex60.text = AppSettings.getValue("EXA60", "0")
        ex65.text = AppSettings.getValue("EXA65", "5")
        ex70.text = AppSettings.getValue("EXA70", "0")
        ex75.text = AppSettings.getValue("EXA75", "5")
        checkan0ntc.checkState = AppSettings.getValue("steinhartcalc0on", 0)
        checkan1ntc.checkState = AppSettings.getValue("steinhartcalc1on", 0)
        checkan2ntc.checkState = AppSettings.getValue("steinhartcalc2on", 0)
        checkan3ntc.checkState = AppSettings.getValue("steinhartcalc3on", 0)
        checkan4ntc.checkState = AppSettings.getValue("steinhartcalc4on", 0)
        checkan5ntc.checkState = AppSettings.getValue("steinhartcalc5on", 0)
        checkan0100.checkState = AppSettings.getValue("AN0R3VAL", 0)
        checkan01k.checkState = AppSettings.getValue("AN0R4VAL", 0)
        checkan1100.checkState = AppSettings.getValue("AN1R3VAL", 0)
        checkan11k.checkState = AppSettings.getValue("AN1R4VAL", 0)
        checkan2100.checkState = AppSettings.getValue("AN2R3VAL", 0)
        checkan21k.checkState = AppSettings.getValue("AN2R4VAL", 0)
        checkan3100.checkState = AppSettings.getValue("AN3R3VAL", 0)
        checkan31k.checkState = AppSettings.getValue("AN3R4VAL", 0)
        checkan4100.checkState = AppSettings.getValue("AN4R3VAL", 0)
        checkan41k.checkState = AppSettings.getValue("AN4R4VAL", 0)
        checkan5100.checkState = AppSettings.getValue("AN5R3VAL", 0)
        checkan51k.checkState = AppSettings.getValue("AN5R4VAL", 0)
        rpmcheckbox.checkState = AppSettings.getValue("ui/exboard/rpmcheckbox", 0)
        an7dampingfactor.text = AppSettings.getValue("AN7Damping", "0")
        t10.text = AppSettings.getValue("T01", "0")
        t20.text = AppSettings.getValue("T02", "0")
        t30.text = AppSettings.getValue("T03", "0")
        r10.text = AppSettings.getValue("R01", "0")
        r20.text = AppSettings.getValue("R02", "0")
        r30.text = AppSettings.getValue("R03", "0")
        t11.text = AppSettings.getValue("T11", "0")
        t21.text = AppSettings.getValue("T12", "0")
        t31.text = AppSettings.getValue("T13", "0")
        r11.text = AppSettings.getValue("R11", "0")
        r21.text = AppSettings.getValue("R12", "0")
        r31.text = AppSettings.getValue("R13", "0")
        t12.text = AppSettings.getValue("T21", "0")
        t22.text = AppSettings.getValue("T22", "0")
        t32.text = AppSettings.getValue("T23", "0")
        r12.text = AppSettings.getValue("R21", "0")
        r22.text = AppSettings.getValue("R22", "0")
        r32.text = AppSettings.getValue("R23", "0")
        t13.text = AppSettings.getValue("T31", "0")
        t23.text = AppSettings.getValue("T32", "0")
        t33.text = AppSettings.getValue("T33", "0")
        r13.text = AppSettings.getValue("R31", "0")
        r23.text = AppSettings.getValue("R32", "0")
        r33.text = AppSettings.getValue("R33", "0")
        t14.text = AppSettings.getValue("T41", "0")
        t24.text = AppSettings.getValue("T42", "0")
        t34.text = AppSettings.getValue("T43", "0")
        r14.text = AppSettings.getValue("R41", "0")
        r24.text = AppSettings.getValue("R42", "0")
        r34.text = AppSettings.getValue("R43", "0")
        t15.text = AppSettings.getValue("T51", "0")
        t25.text = AppSettings.getValue("T52", "0")
        t35.text = AppSettings.getValue("T53", "0")
        r15.text = AppSettings.getValue("R51", "0")
        r25.text = AppSettings.getValue("R52", "0")
        r35.text = AppSettings.getValue("R53", "0")
        digitalExtender.currentIndex = AppSettings.getValue("ui/exboard/selectedValue", 0)
        maxBrightnessBoot.checked = AppSettings.getValue("ui/exboard/switchValue", false)
        rpmsourceselector.currentIndex = AppSettings.getValue("ui/exboard/rpmSource", 0)
        cylindercombobox.currentIndex = AppSettings.getValue("ui/exboard/cylinderCombobox", 0)
        cylindercomboboxv2.currentIndex = AppSettings.getValue("ui/exboard/cylinderComboboxV2", 0)
        cylindercomboboxDi1.currentIndex = AppSettings.getValue("ui/exboard/cylinderComboboxDi1", 0)
        exan0nameField.text = AppSettings.getValue("ui/exboard/exan0name", "")
        exan1nameField.text = AppSettings.getValue("ui/exboard/exan1name", "")
        exan2nameField.text = AppSettings.getValue("ui/exboard/exan2name", "")
        exan3nameField.text = AppSettings.getValue("ui/exboard/exan3name", "")
        exan4nameField.text = AppSettings.getValue("ui/exboard/exan4name", "")
        exan5nameField.text = AppSettings.getValue("ui/exboard/exan5name", "")
        exan6nameField.text = AppSettings.getValue("ui/exboard/exan6name", "")
        exan7nameField.text = AppSettings.getValue("ui/exboard/exan7name", "")
        exdigi1nameField.text = AppSettings.getValue("ui/exboard/exdigi1name", "")
        exdigi2nameField.text = AppSettings.getValue("ui/exboard/exdigi2name", "")
        exdigi3nameField.text = AppSettings.getValue("ui/exboard/exdigi3name", "")
        exdigi4nameField.text = AppSettings.getValue("ui/exboard/exdigi4name", "")
        exdigi5nameField.text = AppSettings.getValue("ui/exboard/exdigi5name", "")
        exdigi6nameField.text = AppSettings.getValue("ui/exboard/exdigi6name", "")
        exdigi7nameField.text = AppSettings.getValue("ui/exboard/exdigi7name", "")
        exdigi8nameField.text = AppSettings.getValue("ui/exboard/exdigi8name", "")
        inputs.setInputs();
    }

    function executeOnBootAction() {
        if (AppSettings.getValue("ui/exboard/switchValue", false)) {
            maxBrightnessOnBoot = 1;
        }
    }
}
