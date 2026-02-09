import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import PowerTune.Settings 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    anchors.fill: parent
    color: "#121212"

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

    ScrollView {
        anchors.fill: parent
        anchors.margins: 16
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: root.width - 32
            spacing: 20

            // * Warning Thresholds Section
            SettingsSection {
                title: Translator.translate("Warning Thresholds", Dashboard.language)
                Layout.fillWidth: true

                GridLayout {
                    columns: 5
                    rowSpacing: 12
                    columnSpacing: 20

                    // Labels row
                    Text {
                        text: Translator.translate("WaterTemp", Dashboard.language)
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#B0B0B0"
                    }
                    Text {
                        text: Translator.translate("Boost", Dashboard.language)
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#B0B0B0"
                    }
                    Text {
                        text: Translator.translate("Revs", Dashboard.language)
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#B0B0B0"
                    }
                    Text {
                        text: Translator.translate("Knock", Dashboard.language)
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#B0B0B0"
                    }
                    Text {
                        text: Translator.translate("Lamdamultiply", Dashboard.language)
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#B0B0B0"
                    }

                    // Input fields row
                    StyledTextField {
                        id: watertempwarn
                        width: 140
                        text: "110"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                    StyledTextField {
                        id: boostwarn
                        width: 140
                        text: "0.9"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                    StyledTextField {
                        id: rpmwarn
                        width: 140
                        text: "10000"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                    StyledTextField {
                        id: knockwarn
                        width: 140
                        text: "80"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                    StyledTextField {
                        id: lambdamultiply
                        width: 140
                        text: "14.7"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                }
            }

            // * Gear Calculation Section
            SettingsSection {
                title: Translator.translate("GearCalculation", Dashboard.language)
                Layout.fillWidth: true

                StyledSwitch {
                    id: gearcalcselect
                    label: gearcalcselect.checked
                        ? Translator.translate("GearCalculation", Dashboard.language) + " " + Translator.translate("ON", Dashboard.language)
                        : Translator.translate("GearCalculation", Dashboard.language) + " " + Translator.translate("OFF", Dashboard.language)

                    Component.onCompleted: {
                        gercalactive = gearcalcselect.checked ? 1 : 0
                        applysettings.start()
                    }

                    onCheckedChanged: {
                        gercalactive = gearcalcselect.checked ? 1 : 0
                        applysettings.start()
                    }
                }

                GridLayout {
                    columns: 6
                    rowSpacing: 12
                    columnSpacing: 16

                    // Labels row
                    Text {
                        text: Translator.translate("Gear", Dashboard.language) + " 1"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#B0B0B0"
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        text: Translator.translate("Gear", Dashboard.language) + " 2"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#B0B0B0"
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        text: Translator.translate("Gear", Dashboard.language) + " 3"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#B0B0B0"
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        text: Translator.translate("Gear", Dashboard.language) + " 4"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#B0B0B0"
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        text: Translator.translate("Gear", Dashboard.language) + " 5"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#B0B0B0"
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        text: Translator.translate("Gear", Dashboard.language) + " 6"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#B0B0B0"
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Input fields row
                    StyledTextField {
                        id: valgear1
                        width: 100
                        text: "120"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                    StyledTextField {
                        id: valgear2
                        width: 100
                        text: "74"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                    StyledTextField {
                        id: valgear3
                        width: 100
                        text: "54"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                    StyledTextField {
                        id: valgear4
                        width: 100
                        text: "37"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                    StyledTextField {
                        id: valgear5
                        width: 100
                        text: "28"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                    StyledTextField {
                        id: valgear6
                        width: 100
                        text: ""
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                        Component.onCompleted: applysettings.start()
                    }
                }

                Text {
                    text: "Enter RPM/Speed ratio values for each gear"
                    font.pixelSize: 16
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
