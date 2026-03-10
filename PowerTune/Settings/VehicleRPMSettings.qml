// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

SettingsPage {
    id: root

    property int gercalactive: 0

    ListModel {
        id: shiftStageModel
        ListElement { label: "1"; stageColor: "#4CAF50"; fieldId: "stage1" }
        ListElement { label: "2"; stageColor: "#FFEB3B"; fieldId: "stage2" }
        ListElement { label: "3"; stageColor: "#FF9800"; fieldId: "stage3" }
        ListElement { label: "4"; stageColor: "#F44336"; fieldId: "stage4" }
    }

    Component.onCompleted: {
        watertempwarn.text = AppSettings.getValue("waterwarn", "110")
        boostwarn.text = AppSettings.getValue("boostwarn", "0.9")
        rpmwarn.text = AppSettings.getValue("rpmwarn", "10000")
        knockwarn.text = AppSettings.getValue("knockwarn", "80")
        lambdamultiply.text = AppSettings.getValue("lambdamultiply", "14.7")
        gearcalcselect.checked = AppSettings.getValue("gercalactive", 0) > 0
        maxRPM.text = AppSettings.getValue("Max RPM", "10000")
        stage1.text = AppSettings.getValue("Shift Light1", "3000")
        stage2.text = AppSettings.getValue("Shift Light2", "5500")
        stage3.text = AppSettings.getValue("Shift Light3", "5500")
        stage4.text = AppSettings.getValue("Shift Light4", "7500")
        valgear1.text = AppSettings.getValue("valgear1", "120")
        valgear2.text = AppSettings.getValue("valgear2", "74")
        valgear3.text = AppSettings.getValue("valgear3", "54")
        valgear4.text = AppSettings.getValue("valgear4", "37")
        valgear5.text = AppSettings.getValue("valgear5", "28")
        valgear6.text = AppSettings.getValue("valgear6", "")
        var sp = AppSettings.getValue("Speedcorrection", 1)
        speedpercent.text = String(Math.round(sp * 100))
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.sectionSpacing

        // * LEFT COLUMN: Warnings + Speed
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                title: Translator.translate("Warning Thresholds", Settings.language)
                Layout.fillWidth: true

                SettingsRow {
                    label: Translator.translate("WaterTemp", Settings.language)
                    StyledTextField {
                        id: watertempwarn
                        width: parent.width
                        height: parent.height
                        text: "110"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applyWarnGear.start()
                    }
                }

                SettingsRow {
                    label: Translator.translate("Boost", Settings.language)
                    StyledTextField {
                        id: boostwarn
                        width: parent.width
                        height: parent.height
                        text: "0.9"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applyWarnGear.start()
                    }
                }

                SettingsRow {
                    label: Translator.translate("Revs", Settings.language)
                    StyledTextField {
                        id: rpmwarn
                        width: parent.width
                        height: parent.height
                        text: "10000"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applyWarnGear.start()
                    }
                }

                SettingsRow {
                    label: Translator.translate("Knock", Settings.language)
                    StyledTextField {
                        id: knockwarn
                        width: parent.width
                        height: parent.height
                        text: "80"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applyWarnGear.start()
                    }
                }

                SettingsRow {
                    label: Translator.translate("Lamdamultiply", Settings.language)
                    StyledTextField {
                        id: lambdamultiply
                        width: parent.width
                        height: parent.height
                        text: "14.7"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applyWarnGear.start()
                    }
                }
            }

            SettingsSection {
                title: Translator.translate("SpeedCorrection", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: SettingsTheme.controlGap
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("SpeedCorrection", Settings.language) + " %"
                        font.pixelSize: SettingsTheme.fontLabel
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.preferredWidth: SettingsTheme.labelWidth
                    }

                    StyledTextField {
                        id: speedpercent
                        Layout.fillWidth: true
                        text: "100"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        Component.onCompleted: AppSettings.writeSpeedSettings(speedpercent.text / 100, 100000)
                        onEditingFinished: AppSettings.writeSpeedSettings(speedpercent.text / 100, 100000)
                    }

                    Text {
                        text: "(100 = no correction)"
                        font.pixelSize: SettingsTheme.fontCaption
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPlaceholder
                        font.italic: true
                    }
                }
            }
        }

        // * RIGHT COLUMN: RPM/Shift Lights + Gear Calc
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                title: "RPM / Shift Lights"
                Layout.fillWidth: true

                SettingsRow {
                    label: "MAX RPM"
                    StyledTextField {
                        id: maxRPM
                        width: parent.width
                        height: parent.height
                        text: "10000"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applyRPM.start()
                    }
                }

                RowLayout {
                    spacing: SettingsTheme.sectionPadding
                    Layout.fillWidth: true

                    Repeater {
                        model: shiftStageModel
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 116
                            color: SettingsTheme.controlBg
                            radius: SettingsTheme.radiusLarge
                            border.color: model.stageColor
                            border.width: 2

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: SettingsTheme.sectionPadding
                                spacing: 4

                                Text {
                                    text: Translator.translate("Stage", Settings.language) + " " + model.label
                                    font.pixelSize: SettingsTheme.fontStatus
                                    font.weight: Font.DemiBold
                                    font.family: SettingsTheme.fontFamily
                                    color: model.stageColor
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                StyledTextField {
                                    id: stageField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    font.pixelSize: SettingsTheme.fontControl
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    horizontalAlignment: Text.AlignHCenter
                                    onEditingFinished: applyRPM.start()
                                    Component.onCompleted: {
                                        if (model.fieldId === "stage1") root.stage1Ref = stageField
                                        else if (model.fieldId === "stage2") root.stage2Ref = stageField
                                        else if (model.fieldId === "stage3") root.stage3Ref = stageField
                                        else if (model.fieldId === "stage4") root.stage4Ref = stageField
                                    }
                                }

                                Text {
                                    text: "RPM"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }

            SettingsSection {
                title: Translator.translate("GearCalculation", Settings.language)
                Layout.fillWidth: true

                StyledSwitch {
                    id: gearcalcselect
                    label: gearcalcselect.checked
                        ? Translator.translate("GearCalculation", Settings.language) + " " + Translator.translate("ON", Settings.language)
                        : Translator.translate("GearCalculation", Settings.language) + " " + Translator.translate("OFF", Settings.language)
                    Component.onCompleted: {
                        gercalactive = gearcalcselect.checked ? 1 : 0
                        applyWarnGear.start()
                    }
                    onCheckedChanged: {
                        gercalactive = gearcalcselect.checked ? 1 : 0
                        applyWarnGear.start()
                    }
                }

                GridLayout {
                    columns: 6
                    columnSpacing: SettingsTheme.contentSpacing
                    rowSpacing: SettingsTheme.contentSpacing
                    Layout.fillWidth: true

                    Repeater {
                        model: 6
                        delegate: ColumnLayout {
                            spacing: 4
                            Text {
                                text: Translator.translate("Gear", Settings.language) + " " + (index + 1)
                                font.pixelSize: SettingsTheme.fontStatus
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                                Layout.alignment: Qt.AlignHCenter
                            }
                            StyledTextField {
                                id: gearField
                                Layout.preferredWidth: 90
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                font.pixelSize: SettingsTheme.fontControl
                                horizontalAlignment: Text.AlignHCenter
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onEditingFinished: applyWarnGear.start()
                                Component.onCompleted: {
                                    if (index === 0) { gearField.text = "120"; root.valgear1Ref = gearField }
                                    else if (index === 1) { gearField.text = "74"; root.valgear2Ref = gearField }
                                    else if (index === 2) { gearField.text = "54"; root.valgear3Ref = gearField }
                                    else if (index === 3) { gearField.text = "37"; root.valgear4Ref = gearField }
                                    else if (index === 4) { gearField.text = "28"; root.valgear5Ref = gearField }
                                    else if (index === 5) { gearField.text = ""; root.valgear6Ref = gearField; applyWarnGear.start() }
                                }
                            }
                        }
                    }
                }

                Text {
                    text: "Enter RPM/Speed ratio values for each gear"
                    font.pixelSize: SettingsTheme.fontCaption
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPlaceholder
                    font.italic: true
                }
            }
        }
    }

    // * Alias bridge properties for Settings persistence (Repeater delegates)
    property var stage1Ref: null
    property var stage2Ref: null
    property var stage3Ref: null
    property var stage4Ref: null
    property var valgear1Ref: null
    property var valgear2Ref: null
    property var valgear3Ref: null
    property var valgear4Ref: null
    property var valgear5Ref: null
    property var valgear6Ref: null

    // * Hidden fields for Settings alias binding (aliases need real ids, not dynamic refs)
    StyledTextField { id: stage1; visible: false; text: stage1Ref ? stage1Ref.text : "3000"; onTextChanged: if (stage1Ref && stage1Ref.text !== text) stage1Ref.text = text }
    StyledTextField { id: stage2; visible: false; text: stage2Ref ? stage2Ref.text : "5500"; onTextChanged: if (stage2Ref && stage2Ref.text !== text) stage2Ref.text = text }
    StyledTextField { id: stage3; visible: false; text: stage3Ref ? stage3Ref.text : "5500"; onTextChanged: if (stage3Ref && stage3Ref.text !== text) stage3Ref.text = text }
    StyledTextField { id: stage4; visible: false; text: stage4Ref ? stage4Ref.text : "7500"; onTextChanged: if (stage4Ref && stage4Ref.text !== text) stage4Ref.text = text }
    StyledTextField { id: valgear1; visible: false; text: valgear1Ref ? valgear1Ref.text : "120"; onTextChanged: if (valgear1Ref && valgear1Ref.text !== text) valgear1Ref.text = text }
    StyledTextField { id: valgear2; visible: false; text: valgear2Ref ? valgear2Ref.text : "74"; onTextChanged: if (valgear2Ref && valgear2Ref.text !== text) valgear2Ref.text = text }
    StyledTextField { id: valgear3; visible: false; text: valgear3Ref ? valgear3Ref.text : "54"; onTextChanged: if (valgear3Ref && valgear3Ref.text !== text) valgear3Ref.text = text }
    StyledTextField { id: valgear4; visible: false; text: valgear4Ref ? valgear4Ref.text : "37"; onTextChanged: if (valgear4Ref && valgear4Ref.text !== text) valgear4Ref.text = text }
    StyledTextField { id: valgear5; visible: false; text: valgear5Ref ? valgear5Ref.text : "28"; onTextChanged: if (valgear5Ref && valgear5Ref.text !== text) valgear5Ref.text = text }
    StyledTextField { id: valgear6; visible: false; text: valgear6Ref ? valgear6Ref.text : ""; onTextChanged: if (valgear6Ref && valgear6Ref.text !== text) valgear6Ref.text = text }

    Connections {
        target: stage1Ref
        function onTextChanged() { if (stage1.text !== stage1Ref.text) stage1.text = stage1Ref.text }
    }
    Connections {
        target: stage2Ref
        function onTextChanged() { if (stage2.text !== stage2Ref.text) stage2.text = stage2Ref.text }
    }
    Connections {
        target: stage3Ref
        function onTextChanged() { if (stage3.text !== stage3Ref.text) stage3.text = stage3Ref.text }
    }
    Connections {
        target: stage4Ref
        function onTextChanged() { if (stage4.text !== stage4Ref.text) stage4.text = stage4Ref.text }
    }
    Connections {
        target: valgear1Ref
        function onTextChanged() { if (valgear1.text !== valgear1Ref.text) valgear1.text = valgear1Ref.text }
    }
    Connections {
        target: valgear2Ref
        function onTextChanged() { if (valgear2.text !== valgear2Ref.text) valgear2.text = valgear2Ref.text }
    }
    Connections {
        target: valgear3Ref
        function onTextChanged() { if (valgear3.text !== valgear3Ref.text) valgear3.text = valgear3Ref.text }
    }
    Connections {
        target: valgear4Ref
        function onTextChanged() { if (valgear4.text !== valgear4Ref.text) valgear4.text = valgear4Ref.text }
    }
    Connections {
        target: valgear5Ref
        function onTextChanged() { if (valgear5.text !== valgear5Ref.text) valgear5.text = valgear5Ref.text }
    }
    Connections {
        target: valgear6Ref
        function onTextChanged() { if (valgear6.text !== valgear6Ref.text) valgear6.text = valgear6Ref.text }
    }

    Item {
        visible: false
        id: applyWarnGear
        function start() {
            AppSettings.writeWarnGearSettings(
                watertempwarn.text, boostwarn.text, rpmwarn.text, knockwarn.text,
                gercalactive, lambdamultiply.text,
                valgear1.text, valgear2.text, valgear3.text,
                valgear4.text, valgear5.text, valgear6.text
            )
        }
    }

    Item {
        visible: false
        id: applyRPM
        function start() {
            AppSettings.writeRPMSettings(maxRPM.text, stage1.text, stage2.text, stage3.text, stage4.text)
        }
    }
}
