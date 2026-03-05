// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import PowerTune.Settings 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    anchors.fill: parent
    color: "#1a1a2e"

    property int gercalactive: 0

    Item {
        id: warnSettings
        Settings {
            property alias watertempwarning: watertempwarn.text
            property alias boostwarning: boostwarn.text
            property alias rpmwarning: rpmwarn.text
            property alias knockwarning: knockwarn.text
            property alias lambdamultiplier: lambdamultiply.text
            property alias gearcalcselectswitch: gearcalcselect.checked
            property alias gearval1: valgear1.text
            property alias gearval2: valgear2.text
            property alias gearval3: valgear3.text
            property alias gearval4: valgear4.text
            property alias gearval5: valgear5.text
            property alias gearval6: valgear6.text
        }
    }

    Item {
        Settings {
            property alias maxrpm: maxRPM.text
            property alias shift1: stage1.text
            property alias shift2: stage2.text
            property alias shift3: stage3.text
            property alias shift4: stage4.text
        }
    }

    Item {
        id: speedSettings
        Settings {
            property alias speedpercentsetting: speedpercent.text
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // * LEFT COLUMN: Warnings + Speed
        ColumnLayout {
            Layout.preferredWidth: (root.width - 48) / 2
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: 12

            SettingsSection {
                title: Translator.translate("Warning Thresholds", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("WaterTemp", Settings.language)
                        font.pixelSize: 18; font.family: "Lato"; color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: watertempwarn; Layout.fillWidth: true; text: "110"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applyWarnGear.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Boost", Settings.language)
                        font.pixelSize: 18; font.family: "Lato"; color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: boostwarn; Layout.fillWidth: true; text: "0.9"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applyWarnGear.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Revs", Settings.language)
                        font.pixelSize: 18; font.family: "Lato"; color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: rpmwarn; Layout.fillWidth: true; text: "10000"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applyWarnGear.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Knock", Settings.language)
                        font.pixelSize: 18; font.family: "Lato"; color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: knockwarn; Layout.fillWidth: true; text: "80"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applyWarnGear.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Lamdamultiply", Settings.language)
                        font.pixelSize: 18; font.family: "Lato"; color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: lambdamultiply; Layout.fillWidth: true; text: "14.7"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applyWarnGear.start()
                    }
                }
            }

            SettingsSection {
                title: Translator.translate("SpeedCorrection", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("SpeedCorrection", Settings.language) + " %"
                        font.pixelSize: 18; font.family: "Lato"; color: "#FFFFFF"
                        Layout.preferredWidth: 200
                    }

                    StyledTextField {
                        id: speedpercent; Layout.fillWidth: true; text: "100"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        Component.onCompleted: AppSettings.writeSpeedSettings(speedpercent.text / 100, 100000)
                        onEditingFinished: AppSettings.writeSpeedSettings(speedpercent.text / 100, 100000)
                    }

                    Text {
                        text: "(100 = no correction)"
                        font.pixelSize: 16; font.family: "Lato"; color: "#707070"
                        font.italic: true
                    }
                }
            }
        }

        // * RIGHT COLUMN: RPM/Shift Lights + Gear Calc
        ColumnLayout {
            Layout.preferredWidth: (root.width - 48) / 2
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: 12

            SettingsSection {
                title: "RPM / Shift Lights"
                Layout.fillWidth: true

                RowLayout {
                    spacing: 16
                    Layout.fillWidth: true

                    Text {
                        text: "MAX RPM"
                        font.pixelSize: 18; font.weight: Font.DemiBold
                        font.family: "Lato"; color: "#FFFFFF"
                        Layout.preferredWidth: 120
                    }

                    StyledTextField {
                        id: maxRPM; Layout.fillWidth: true; text: "10000"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applyRPM.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Layout.fillWidth: true

                    Repeater {
                        model: [
                            { label: "1", color: "#4CAF50", fieldId: "stage1" },
                            { label: "2", color: "#FFEB3B", fieldId: "stage2" },
                            { label: "3", color: "#FF9800", fieldId: "stage3" },
                            { label: "4", color: "#F44336", fieldId: "stage4" }
                        ]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 100
                            color: "#2D2D2D"
                            radius: 8
                            border.color: modelData.color
                            border.width: 2

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                Text {
                                    text: Translator.translate("Stage", Settings.language) + " " + modelData.label
                                    font.pixelSize: 16; font.weight: Font.DemiBold
                                    font.family: "Lato"; color: modelData.color
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                StyledTextField {
                                    id: stageField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 36
                                    font.pixelSize: 16
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    horizontalAlignment: Text.AlignHCenter
                                    onEditingFinished: applyRPM.start()
                                    Component.onCompleted: {
                                        if (modelData.fieldId === "stage1") root.stage1Ref = stageField
                                        else if (modelData.fieldId === "stage2") root.stage2Ref = stageField
                                        else if (modelData.fieldId === "stage3") root.stage3Ref = stageField
                                        else if (modelData.fieldId === "stage4") root.stage4Ref = stageField
                                    }
                                }

                                Text {
                                    text: "RPM"
                                    font.pixelSize: 14; font.family: "Lato"; color: "#B0B0B0"
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
                    columnSpacing: 8
                    rowSpacing: 8
                    Layout.fillWidth: true

                    Repeater {
                        model: 6
                        delegate: ColumnLayout {
                            spacing: 4
                            Text {
                                text: Translator.translate("Gear", Settings.language) + " " + (index + 1)
                                font.pixelSize: 16; font.family: "Lato"; color: "#B0B0B0"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            StyledTextField {
                                id: gearField
                                Layout.preferredWidth: 90
                                Layout.preferredHeight: 40
                                font.pixelSize: 16
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
                    font.pixelSize: 16; font.family: "Lato"; color: "#707070"
                    font.italic: true
                }
            }
        }
    }

    // Alias bridge properties for Settings persistence (Repeater delegates)
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

    // Hidden fields for Settings alias binding (aliases need real ids, not dynamic refs)
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
        id: applyRPM
        function start() {
            AppSettings.writeRPMSettings(maxRPM.text, stage1.text, stage2.text, stage3.text, stage4.text)
        }
    }
}
