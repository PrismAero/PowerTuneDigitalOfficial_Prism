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

    Item {
        id: startupsettings
        Settings {
            property alias mainspeedsource: mainspeedsource.currentIndex
            property alias daemonselect: daemonselect.currentIndex
            property alias bitrateselect: canbitrateselect.currentIndex
            property alias holleyproductid: holleyproductid.currentIndex
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

            // * Daemon Selection Section
            SettingsSection {
                title: Translator.translate("Startup daemon", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 20
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("Startup daemon", Settings.language)
                        font.pixelSize: 20
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 200
                    }

                    StyledComboBox {
                        id: daemonselect
                        width: 350
                        model: ["None", "HaltechV2", "Link Generic Dash", "Microtech", "Consult", "M800 Set1", "OBD2", "Hondata 20Hz", "Adaptronic CAN", "Motec M1", "AEM V2", "AUDI B7", "BRZ FRS 86", "ECU Masters", "Audi B8", "Emtron", "Holley (Racepak)", "MaxxECU", "Ford FG MK1", "Ford FG MK1 + OBD Polling", "Ford BA+BF ", "Ford BA+BF + OBD Polling", "Ford FG2x", "Ford FG2x + OBD Polling", "EVO X", "Blackbox M3", "NISSAN 370Z", "GM: LS2-LS7 CAN", "NISSAN 350Z", "Megasquirt CAN Simplified", "EMTECH EMS CAN", "WRX 2008-2015", "Motec Set3 ADL", "Testdaemon", "Ecoboost", "Emerald ECU", "Wolf", "GM OBD-CAN", "Unused", "Hondata 100Hz", "11-Bit CAN", "Motorsport Electronics", "Fueltech", "Delta", "Bigstuff AFR", "Bigstuff Lamda", "R35", "Prado", "WRX 2016", "LifeRacing beta", "DTAFast", "ProEFI", "TeslaSDU", "NeuroBasic", "GR Yaris (Beta)", "Syvecs S7", "RSport", "Generic CAN", "Edelbrock", "Boostec", "Holley (Standard)"]
                        onCurrentIndexChanged: autochangecanspeed.start()
                    }
                }

                StyledButton {
                    text: Translator.translate("Apply", Settings.language)
                    width: 200
                    onClicked: {
                        Connect.daemonstartup(daemonselect.currentIndex)
                        Connect.canbitratesetup(canbitrateselect.currentIndex)
                    }
                }
            }

            // * CAN Configuration Section
            SettingsSection {
                title: Translator.translate("Can Bitrate", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 20
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("Can Bitrate", Settings.language)
                        font.pixelSize: 20
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 200
                    }

                    StyledComboBox {
                        id: canbitrateselect
                        width: 280
                        model: ["250 kbit/s", "500 kbit/s", "1 Mbit/s"]
                    }
                }
            }

            // * Speed Source Section
            SettingsSection {
                title: Translator.translate("Main Speed Source", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 20
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("Main Speed Source", Settings.language)
                        font.pixelSize: 20
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 200
                    }

                    StyledComboBox {
                        id: mainspeedsource
                        width: 280
                        model: ["ECU Speed", "LF Wheelspeed", "RF Wheelspeed", "LR Wheelspeed", "RR Wheelspeed", "GPS", "VR Sensor"]
                        onCurrentIndexChanged: AppSettings.writeStartupSettings(mainspeedsource.currentIndex)
                    }
                }
            }

            // * Holley ECU Section (conditional)
            SettingsSection {
                title: Translator.translate("Holley ECU", Settings.language)
                visible: daemonselect.textAt(daemonselect.currentIndex) === "Holley (Standard)"
                Layout.fillWidth: true

                RowLayout {
                    spacing: 20
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("Holley ECU", Settings.language)
                        font.pixelSize: 20
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 200
                    }

                    StyledComboBox {
                        id: holleyproductid
                        width: 280
                        model: ListModel {
                            ListElement { text: "Terminator X"; value: 11 }
                            ListElement { text: "Dominator"; value: 1 }
                            ListElement { text: "Sniper"; value: 2 }
                            ListElement { text: "Sniper Gen2"; value: 23 }
                            ListElement { text: "HP"; value: 0 }
                        }
                        textRole: "text"
                        onCurrentIndexChanged: {
                            var selectedValue = holleyproductid.model.get(holleyproductid.currentIndex).value
                            AppSettings.writeHolleyProductID(selectedValue)
                        }
                    }
                }
            }

            // * Warning Text
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: warningtext.implicitHeight + 32
                color: "#2D1A1A"
                radius: 8
                border.color: "#F44336"
                border.width: 1

                Text {
                    id: warningtext
                    text: Translator.translate("Warningtext", Settings.language)
                    font.pixelSize: 20
                    font.bold: true
                    font.family: "Lato"
                    width: parent.width - 32
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    color: "#F44336"
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // * Auto-change CAN speed based on daemon selection
    Item {
        id: autochangecanspeed
        function start() {
            switch (daemonselect.textAt(daemonselect.currentIndex)) {
                case "OBD2":
                case "AUDI B7":
                case "BRZ FRS 86":
                case "Audi B8":
                case "Ford FG MK1":
                case "Ford FG MK1 + OBD Polling":
                case "Ford BX ":
                case "Ford BX + OBD Polling":
                case "Ford FG2x":
                case "Ford FG2x + OBD Polling":
                case "EVO X Test":
                case "NISSAN 370Z Test":
                case "GM: LS2-LS7 CAN":
                case "NISSAN 350Z Test":
                case "Subaru Test":
                case "11-Bit CAN":
                    canbitrateselect.currentIndex = 1 // 500 Kbs
                    break
                case "Motorsport Electronics":
                case "Fueltech":
                    canbitrateselect.currentIndex = 2 // 1Mbit
                    break
                default:
                    canbitrateselect.currentIndex = 2 // 1Mbit
                    break
            }
        }
    }
}
