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
        id: warnettings
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

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // * LEFT COLUMN - Warning Thresholds
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
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: watertempwarn
                        width: 160
                        text: "110"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Boost", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: boostwarn
                        width: 160
                        text: "0.9"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Revs", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: rpmwarn
                        width: 160
                        text: "10000"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Knock", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: knockwarn
                        width: 160
                        text: "80"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Lamdamultiply", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: lambdamultiply
                        width: 160
                        text: "14.7"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                }
            }
        }

        // * RIGHT COLUMN - Gear Ratios
        ColumnLayout {
            Layout.preferredWidth: (root.width - 48) / 2
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: 12

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
                        applysettings.start()
                    }

                    onCheckedChanged: {
                        gercalactive = gearcalcselect.checked ? 1 : 0
                        applysettings.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Gear", Settings.language) + " 1"
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: valgear1
                        width: 160
                        text: "120"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Gear", Settings.language) + " 2"
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: valgear2
                        width: 160
                        text: "74"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Gear", Settings.language) + " 3"
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: valgear3
                        width: 160
                        text: "54"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Gear", Settings.language) + " 4"
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: valgear4
                        width: 160
                        text: "37"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Gear", Settings.language) + " 5"
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: valgear5
                        width: 160
                        text: "28"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Gear", Settings.language) + " 6"
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: valgear6
                        width: 160
                        text: ""
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                        Component.onCompleted: applysettings.start()
                    }
                }

                Text {
                    text: "Enter RPM/Speed ratio values for each gear"
                    font.pixelSize: 14
                    font.family: "Lato"
                    color: "#707070"
                    font.italic: true
                }
            }
        }
    }

    Item {
        id: applysettings
        function start() {
            AppSettings.writeWarnGearSettings(
                watertempwarn.text, boostwarn.text, rpmwarn.text, knockwarn.text,
                gercalactive, lambdamultiply.text,
                valgear1.text, valgear2.text, valgear3.text,
                valgear4.text, valgear5.text, valgear6.text
            )
        }
    }
}
