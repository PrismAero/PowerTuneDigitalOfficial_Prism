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
    property bool settingsLoaded: false
    property bool suppressWrites: true

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

    Component.onCompleted: {
        if (settingsLoaded)
            return;
        watertempwarn.text = AppSettings.getValue("waterwarn", "110");
        boostwarn.text = AppSettings.getValue("boostwarn", "0.9");
        rpmwarn.text = AppSettings.getValue("rpmwarn", "10000");
        knockwarn.text = AppSettings.getValue("knockwarn", "80");
        lambdamultiply.text = AppSettings.getValue("lambdamultiply", "14.7");
        gearcalcselect.checked = AppSettings.getValue("gercalactive", 0) > 0;
        maxRPM.text = AppSettings.getValue("Max RPM", "10000");
        stage1.text = AppSettings.getValue("Shift Light1", "3000");
        stage2.text = AppSettings.getValue("Shift Light2", "5500");
        stage3.text = AppSettings.getValue("Shift Light3", "5500");
        stage4.text = AppSettings.getValue("Shift Light4", "7500");
        valgear1.text = AppSettings.getValue("valgear1", "120");
        valgear2.text = AppSettings.getValue("valgear2", "74");
        valgear3.text = AppSettings.getValue("valgear3", "54");
        valgear4.text = AppSettings.getValue("valgear4", "37");
        valgear5.text = AppSettings.getValue("valgear5", "28");
        valgear6.text = AppSettings.getValue("valgear6", "");
        var sp = AppSettings.getValue("Speedcorrection", 1);
        speedpercent.text = String(Math.round(sp * 100));
        settingsLoaded = true;
        suppressWrites = false;
    }

    ListModel {
        id: shiftStageModel

        ListElement {
            fieldId: "stage1"
            label: "1"
            stageColor: "#4CAF50"
        }

        ListElement {
            fieldId: "stage2"
            label: "2"
            stageColor: "#FFEB3B"
        }

        ListElement {
            fieldId: "stage3"
            label: "3"
            stageColor: "#FF9800"
        }

        ListElement {
            fieldId: "stage4"
            label: "4"
            stageColor: "#F44336"
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.sectionSpacing

        // * LEFT COLUMN: Warnings + Speed
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Warning Thresholds", Settings.language)

                SettingsRow {
                    label: Translator.translate("WaterTemp", Settings.language)

                    StyledTextField {
                        id: watertempwarn

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "110"
                        width: parent.width

                        onEditingFinished: applyWarnGear.start()
                    }
                }

                SettingsRow {
                    label: Translator.translate("Boost", Settings.language)

                    StyledTextField {
                        id: boostwarn

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "0.9"
                        width: parent.width

                        onEditingFinished: applyWarnGear.start()
                    }
                }

                SettingsRow {
                    label: Translator.translate("Revs", Settings.language)

                    StyledTextField {
                        id: rpmwarn

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "10000"
                        width: parent.width

                        onEditingFinished: applyWarnGear.start()
                    }
                }

                SettingsRow {
                    label: Translator.translate("Knock", Settings.language)

                    StyledTextField {
                        id: knockwarn

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "80"
                        width: parent.width

                        onEditingFinished: applyWarnGear.start()
                    }
                }

                SettingsRow {
                    label: Translator.translate("Lamdamultiply", Settings.language)

                    StyledTextField {
                        id: lambdamultiply

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "14.7"
                        width: parent.width

                        onEditingFinished: applyWarnGear.start()
                    }
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("SpeedCorrection", Settings.language)

                SettingsRow {
                    description: "(100 = no correction)"
                    label: Translator.translate("SpeedCorrection", Settings.language) + " %"

                    StyledTextField {
                        id: speedpercent

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "100"
                        width: parent.width

                        onEditingFinished: AppSettings.writeSpeedSettings(speedpercent.text / 100, 100000)
                    }
                }
            }
        }

        // * RIGHT COLUMN: RPM/Shift Lights + Gear Calc
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                Layout.fillWidth: true
                title: "RPM / Shift Lights"

                SettingsRow {
                    label: "MAX RPM"

                    StyledTextField {
                        id: maxRPM

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "10000"
                        width: parent.width

                        onEditingFinished: applyRPM.start()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: SettingsTheme.sectionPadding

                    Repeater {
                        model: shiftStageModel

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 104
                            border.color: model.stageColor
                            border.width: 2
                            color: SettingsTheme.controlBg
                            radius: SettingsTheme.radiusLarge

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: SettingsTheme.sectionPadding
                                spacing: 4

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    color: model.stageColor
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontStatus
                                    font.weight: Font.DemiBold
                                    text: Translator.translate("Stage", Settings.language) + " " + model.label
                                }

                                StyledTextField {
                                    id: stageField

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    font.pixelSize: SettingsTheme.fontControl
                                    horizontalAlignment: Text.AlignHCenter
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                                    Component.onCompleted: {
                                        if (model.fieldId === "stage1")
                                            root.stage1Ref = stageField;
                                        else if (model.fieldId === "stage2")
                                            root.stage2Ref = stageField;
                                        else if (model.fieldId === "stage3")
                                            root.stage3Ref = stageField;
                                        else if (model.fieldId === "stage4")
                                            root.stage4Ref = stageField;
                                    }
                                    onEditingFinished: applyRPM.start()
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "RPM"
                                }
                            }
                        }
                    }
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("GearCalculation", Settings.language)

                StyledSwitch {
                    id: gearcalcselect

                    label: gearcalcselect.checked ? Translator.translate("GearCalculation", Settings.language) + " "
                                                    + Translator.translate("ON", Settings.language) :
                                                    Translator.translate("GearCalculation", Settings.language) + " "
                                                    + Translator.translate("OFF", Settings.language)

                    Component.onCompleted: {
                        gercalactive = gearcalcselect.checked ? 1 : 0;
                    }
                    onCheckedChanged: {
                        if (!settingsLoaded || suppressWrites)
                            return;
                        gercalactive = gearcalcselect.checked ? 1 : 0;
                        applyWarnGear.start();
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columnSpacing: SettingsTheme.contentSpacing
                    columns: 6
                    rowSpacing: SettingsTheme.contentSpacing

                    Repeater {
                        model: 6

                        delegate: ColumnLayout {
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontStatus
                                text: Translator.translate("Gear", Settings.language) + " " + (index + 1)
                            }

                            StyledTextField {
                                id: gearField

                                Layout.preferredHeight: SettingsTheme.controlHeight
                                Layout.preferredWidth: 90
                                font.pixelSize: SettingsTheme.fontControl
                                horizontalAlignment: Text.AlignHCenter
                                inputMethodHints: Qt.ImhFormattedNumbersOnly

                                Component.onCompleted: {
                                    if (index === 0) {
                                        gearField.text = "120";
                                        root.valgear1Ref = gearField;
                                    } else if (index === 1) {
                                        gearField.text = "74";
                                        root.valgear2Ref = gearField;
                                    } else if (index === 2) {
                                        gearField.text = "54";
                                        root.valgear3Ref = gearField;
                                    } else if (index === 3) {
                                        gearField.text = "37";
                                        root.valgear4Ref = gearField;
                                    } else if (index === 4) {
                                        gearField.text = "28";
                                        root.valgear5Ref = gearField;
                                    } else if (index === 5) {
                                        gearField.text = "";
                                        root.valgear6Ref = gearField;
                                    }
                                }
                                onEditingFinished: applyWarnGear.start()
                            }
                        }
                    }
                }

                Text {
                    color: SettingsTheme.textPlaceholder
                    font.family: SettingsTheme.fontFamily
                    font.italic: true
                    font.pixelSize: SettingsTheme.fontCaption
                    text: "Enter RPM/Speed ratio values for each gear"
                }
            }
        }
    }

    // * Hidden fields for Settings alias binding (aliases need real ids, not dynamic refs)
    StyledTextField {
        id: stage1

        text: stage1Ref ? stage1Ref.text : "3000"
        visible: false

        onTextChanged: if (stage1Ref && stage1Ref.text !== text)
                           stage1Ref.text = text
    }

    StyledTextField {
        id: stage2

        text: stage2Ref ? stage2Ref.text : "5500"
        visible: false

        onTextChanged: if (stage2Ref && stage2Ref.text !== text)
                           stage2Ref.text = text
    }

    StyledTextField {
        id: stage3

        text: stage3Ref ? stage3Ref.text : "5500"
        visible: false

        onTextChanged: if (stage3Ref && stage3Ref.text !== text)
                           stage3Ref.text = text
    }

    StyledTextField {
        id: stage4

        text: stage4Ref ? stage4Ref.text : "7500"
        visible: false

        onTextChanged: if (stage4Ref && stage4Ref.text !== text)
                           stage4Ref.text = text
    }

    StyledTextField {
        id: valgear1

        text: valgear1Ref ? valgear1Ref.text : "120"
        visible: false

        onTextChanged: if (valgear1Ref && valgear1Ref.text !== text)
                           valgear1Ref.text = text
    }

    StyledTextField {
        id: valgear2

        text: valgear2Ref ? valgear2Ref.text : "74"
        visible: false

        onTextChanged: if (valgear2Ref && valgear2Ref.text !== text)
                           valgear2Ref.text = text
    }

    StyledTextField {
        id: valgear3

        text: valgear3Ref ? valgear3Ref.text : "54"
        visible: false

        onTextChanged: if (valgear3Ref && valgear3Ref.text !== text)
                           valgear3Ref.text = text
    }

    StyledTextField {
        id: valgear4

        text: valgear4Ref ? valgear4Ref.text : "37"
        visible: false

        onTextChanged: if (valgear4Ref && valgear4Ref.text !== text)
                           valgear4Ref.text = text
    }

    StyledTextField {
        id: valgear5

        text: valgear5Ref ? valgear5Ref.text : "28"
        visible: false

        onTextChanged: if (valgear5Ref && valgear5Ref.text !== text)
                           valgear5Ref.text = text
    }

    StyledTextField {
        id: valgear6

        text: valgear6Ref ? valgear6Ref.text : ""
        visible: false

        onTextChanged: if (valgear6Ref && valgear6Ref.text !== text)
                           valgear6Ref.text = text
    }

    Connections {
        function onTextChanged() {
            if (stage1.text !== stage1Ref.text)
                stage1.text = stage1Ref.text;
        }

        target: stage1Ref
    }

    Connections {
        function onTextChanged() {
            if (stage2.text !== stage2Ref.text)
                stage2.text = stage2Ref.text;
        }

        target: stage2Ref
    }

    Connections {
        function onTextChanged() {
            if (stage3.text !== stage3Ref.text)
                stage3.text = stage3Ref.text;
        }

        target: stage3Ref
    }

    Connections {
        function onTextChanged() {
            if (stage4.text !== stage4Ref.text)
                stage4.text = stage4Ref.text;
        }

        target: stage4Ref
    }

    Connections {
        function onTextChanged() {
            if (valgear1.text !== valgear1Ref.text)
                valgear1.text = valgear1Ref.text;
        }

        target: valgear1Ref
    }

    Connections {
        function onTextChanged() {
            if (valgear2.text !== valgear2Ref.text)
                valgear2.text = valgear2Ref.text;
        }

        target: valgear2Ref
    }

    Connections {
        function onTextChanged() {
            if (valgear3.text !== valgear3Ref.text)
                valgear3.text = valgear3Ref.text;
        }

        target: valgear3Ref
    }

    Connections {
        function onTextChanged() {
            if (valgear4.text !== valgear4Ref.text)
                valgear4.text = valgear4Ref.text;
        }

        target: valgear4Ref
    }

    Connections {
        function onTextChanged() {
            if (valgear5.text !== valgear5Ref.text)
                valgear5.text = valgear5Ref.text;
        }

        target: valgear5Ref
    }

    Connections {
        function onTextChanged() {
            if (valgear6.text !== valgear6Ref.text)
                valgear6.text = valgear6Ref.text;
        }

        target: valgear6Ref
    }

    Item {
        id: applyWarnGear

        function start() {
            if (!settingsLoaded || suppressWrites)
                return;
            AppSettings.writeWarnGearSettings(watertempwarn.text, boostwarn.text, rpmwarn.text, knockwarn.text,
                                              gercalactive, lambdamultiply.text, valgear1.text, valgear2.text,
                                              valgear3.text, valgear4.text, valgear5.text, valgear6.text);
        }

        visible: false
    }

    Item {
        id: applyRPM

        function start() {
            if (!settingsLoaded || suppressWrites)
                return;
            AppSettings.writeRPMSettings(maxRPM.text, stage1.text, stage2.text, stage3.text, stage4.text);
        }

        visible: false
    }
}
