import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import "qrc:/Translator.js" as Translator
import "components"

Rectangle {
    id: root
    anchors.fill: parent
    color: "#121212"

    Item {
        id: speedcorretionsettings
        Settings {
            property alias speedpercentsetting: speedpercent.text
            property alias pulsespermilesetting: pulsespermile.text
            property alias usbvrsensorcheckstate: usbvrcheckbox.checked
            property alias connectbuttonenabled: connectButtonArd.enabled
            property alias disconnectbuttonenabled: disconnectButtonArd.enabled
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

            // * Speed Correction Section
            SettingsSection {
                title: Translator.translate("SpeedCorrection", Dashboard.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 20
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("SpeedCorrection", Dashboard.language) + " %"
                        font.pixelSize: 20
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 250
                    }

                    StyledTextField {
                        id: speedpercent
                        width: 200
                        text: "100"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        Component.onCompleted: {
                            AppSettings.writeSpeedSettings(speedpercent.text / 100, pulsespermile.text)
                        }
                        onEditingFinished: AppSettings.writeSpeedSettings(speedpercent.text / 100, pulsespermile.text)
                    }

                    Text {
                        text: "(100 = no correction)"
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#707070"
                        font.italic: true
                    }
                }
            }

            // * External Speed Sensor Section
            SettingsSection {
                title: Translator.translate("USB VR Speed Sensor", Dashboard.language)
                Layout.fillWidth: true

                StyledSwitch {
                    id: usbvrcheckbox
                    label: Translator.translate("USB VR Speed Sensor", Dashboard.language)
                    onCheckedChanged: {
                        if (!checked) {
                            if (Dashboard.externalspeedconnectionrequest === 1) {
                                Arduino.closeConnection()
                            }
                            AppSettings.externalspeedconnectionstatus(0)
                            connectButtonArd.enabled = true
                            disconnectButtonArd.enabled = false
                        }
                    }
                }

                // * Conditional settings (visible when checkbox is checked)
                ColumnLayout {
                    visible: usbvrcheckbox.checked
                    spacing: 16
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: 20
                        Layout.fillWidth: true

                        Text {
                            text: Translator.translate("Pulses per mile", Dashboard.language)
                            font.pixelSize: 20
                            font.family: "Lato"
                            color: "#FFFFFF"
                            Layout.preferredWidth: 250
                        }

                        StyledTextField {
                            id: pulsespermile
                            width: 200
                            text: "100000"
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            Component.onCompleted: {
                                AppSettings.writeSpeedSettings(speedpercent.text / 100, pulsespermile.text)
                            }
                            onEditingFinished: AppSettings.writeSpeedSettings(speedpercent.text / 100, pulsespermile.text)
                        }
                    }

                    RowLayout {
                        spacing: 20
                        Layout.fillWidth: true

                        Text {
                            text: Translator.translate("External Speed port", Dashboard.language)
                            font.pixelSize: 20
                            font.family: "Lato"
                            color: "#FFFFFF"
                            Layout.preferredWidth: 250
                        }

                        StyledComboBox {
                            id: serialNameArd
                            width: 280
                            model: Connect.portsNames
                        }
                    }

                    RowLayout {
                        spacing: 12
                        Layout.fillWidth: true

                        StyledButton {
                            id: connectButtonArd
                            text: Translator.translate("Connect", Dashboard.language)
                            width: 180
                            onClicked: {
                                AppSettings.externalspeedconnectionstatus(1)
                                AppSettings.externalspeedport(serialNameArd.textAt(serialNameArd.currentIndex))
                                Arduino.openConnection(Dashboard.externalspeedport, "9600")
                                connectButtonArd.enabled = false
                                disconnectButtonArd.enabled = true
                            }
                        }

                        StyledButton {
                            id: disconnectButtonArd
                            text: Translator.translate("Disconnect", Dashboard.language)
                            width: 180
                            primary: false
                            enabled: false
                            onClicked: {
                                AppSettings.externalspeedconnectionstatus(0)
                                Arduino.closeConnection()
                                connectButtonArd.enabled = true
                                disconnectButtonArd.enabled = false
                            }
                        }
                    }
                }
            }
        }
    }
}
