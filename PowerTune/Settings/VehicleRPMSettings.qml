// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Core 1.0
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

SettingsPage {
    id: root

    Component.onCompleted: {
        VehicleRpmSettingsModel.load();
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
                        text: VehicleRpmSettingsModel.waterTempWarn
                        width: parent.width

                        onEditingFinished: {
                            VehicleRpmSettingsModel.waterTempWarn = text;
                            VehicleRpmSettingsModel.applyWarnGear();
                        }
                    }
                }

                SettingsRow {
                    label: Translator.translate("Boost", Settings.language)

                    StyledTextField {
                        id: boostwarn

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: VehicleRpmSettingsModel.boostWarn
                        width: parent.width

                        onEditingFinished: {
                            VehicleRpmSettingsModel.boostWarn = text;
                            VehicleRpmSettingsModel.applyWarnGear();
                        }
                    }
                }

                SettingsRow {
                    label: Translator.translate("Revs", Settings.language)

                    StyledTextField {
                        id: rpmwarn

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: VehicleRpmSettingsModel.rpmWarn
                        width: parent.width

                        onEditingFinished: {
                            VehicleRpmSettingsModel.rpmWarn = text;
                            VehicleRpmSettingsModel.applyWarnGear();
                        }
                    }
                }

                SettingsRow {
                    label: Translator.translate("Knock", Settings.language)

                    StyledTextField {
                        id: knockwarn

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: VehicleRpmSettingsModel.knockWarn
                        width: parent.width

                        onEditingFinished: {
                            VehicleRpmSettingsModel.knockWarn = text;
                            VehicleRpmSettingsModel.applyWarnGear();
                        }
                    }
                }

                SettingsRow {
                    label: Translator.translate("Lamdamultiply", Settings.language)

                    StyledTextField {
                        id: lambdamultiply

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: VehicleRpmSettingsModel.lambdaMultiply
                        width: parent.width

                        onEditingFinished: {
                            VehicleRpmSettingsModel.lambdaMultiply = text;
                            VehicleRpmSettingsModel.applyWarnGear();
                        }
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
                        text: VehicleRpmSettingsModel.speedPercent
                        width: parent.width

                        onEditingFinished: {
                            VehicleRpmSettingsModel.speedPercent = text;
                            VehicleRpmSettingsModel.applySpeed();
                        }
                    }
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: "DFI Serial"

                SettingsRow {
                    label: "Enabled"
                    description: "Read Kawasaki DFI codes via UART"

                    StyledSwitch {
                        checked: DfiSerial ? DfiSerial.enabled : false
                        label: checked ? "On" : "Off"
                        onCheckedChanged: {
                            if (DfiSerial)
                                DfiSerial.enabled = checked;
                        }
                    }
                }

                SettingsRow {
                    label: "Port"

                    StyledTextField {
                        Layout.fillWidth: true
                        height: parent.height
                        text: DfiSerial ? DfiSerial.portPath : "/dev/ttyAMA0"
                        onEditingFinished: {
                            if (DfiSerial)
                                DfiSerial.portPath = text;
                        }
                    }
                }

                SettingsRow {
                    label: "Status"

                    ConnectionStatusIndicator {
                        Layout.fillWidth: true
                        height: parent.height
                        status: {
                            if (!DfiSerial)
                                return "disconnected";
                            if (DfiSerial.hasSignal)
                                return "connected";
                            if (DfiSerial.connected)
                                return "pending";
                            return "disconnected";
                        }
                        statusText: {
                            if (!DfiSerial)
                                return "Unavailable";
                            if (DfiSerial.hasSignal)
                                return "Receiving";
                            if (DfiSerial.connected)
                                return "Connected (no signal)";
                            return "Disconnected";
                        }
                    }
                }

                SettingsRow {
                    label: "Gear / Codes"

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontStatus
                        text: DfiSerial ? ("Gear: " + DfiSerial.gearString + "  Codes: " + (DfiSerial.activeCodes || "none")) : "-"
                    }
                }

                StyledButton {
                    text: "DFI Code Filters"
                    onClicked: dfiCodeFilterPopup.open()
                }

                DfiCodeFilterPopup {
                    id: dfiCodeFilterPopup
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
                        text: VehicleRpmSettingsModel.maxRpm
                        width: parent.width

                        onEditingFinished: {
                            VehicleRpmSettingsModel.maxRpm = text;
                            VehicleRpmSettingsModel.applyRpm();
                        }
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
                                    text: VehicleRpmSettingsModel.shiftStageText(index)
                                    onEditingFinished: {
                                        VehicleRpmSettingsModel.setShiftStageText(index, text);
                                        VehicleRpmSettingsModel.applyRpm();
                                    }
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

                    checked: VehicleRpmSettingsModel.gearCalcEnabled
                    label: checked ? Translator.translate("GearCalculation", Settings.language) + " "
                                                    + Translator.translate("ON", Settings.language) :
                                                    Translator.translate("GearCalculation", Settings.language) + " "
                                                    + Translator.translate("OFF", Settings.language)

                    onCheckedChanged: {
                        VehicleRpmSettingsModel.gearCalcEnabled = checked;
                        VehicleRpmSettingsModel.applyWarnGear();
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
                                    text: VehicleRpmSettingsModel.gearValueText(index)
                                    onEditingFinished: {
                                        VehicleRpmSettingsModel.setGearValueText(index, text);
                                        VehicleRpmSettingsModel.applyWarnGear();
                                    }
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
}
