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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // * Speed Correction Section
        SettingsSection {
            title: Translator.translate("SpeedCorrection", Settings.language)
            Layout.fillWidth: true
            Layout.maximumWidth: 800

            RowLayout {
                spacing: 12
                Layout.fillWidth: true

                Text {
                    text: Translator.translate("SpeedCorrection", Settings.language) + " %"
                    font.pixelSize: 16
                    font.family: "Lato"
                    color: "#FFFFFF"
                    Layout.preferredWidth: 220
                }

                StyledTextField {
                    id: speedpercent
                    width: 180
                    text: "100"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    Component.onCompleted: {
                        AppSettings.writeSpeedSettings(speedpercent.text / 100, pulsespermile.text)
                    }
                    onEditingFinished: AppSettings.writeSpeedSettings(speedpercent.text / 100, pulsespermile.text)
                }

                Text {
                    text: "(100 = no correction)"
                    font.pixelSize: 14
                    font.family: "Lato"
                    color: "#707070"
                    font.italic: true
                }
            }
        }

        // * External Speed Sensor Section
        SettingsSection {
            title: Translator.translate("USB VR Speed Sensor", Settings.language)
            Layout.fillWidth: true
            Layout.maximumWidth: 800

            StyledSwitch {
                id: usbvrcheckbox
                label: Translator.translate("USB VR Speed Sensor", Settings.language)
                onCheckedChanged: {
                    if (!checked) {
                        if (Connection.externalspeedconnectionrequest === 1) {
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
                spacing: 8
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("Pulses per mile", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 220
                    }

                    StyledTextField {
                        id: pulsespermile
                        width: 180
                        text: "100000"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        Component.onCompleted: {
                            AppSettings.writeSpeedSettings(speedpercent.text / 100, pulsespermile.text)
                        }
                        onEditingFinished: AppSettings.writeSpeedSettings(speedpercent.text / 100, pulsespermile.text)
                    }
                }

                RowLayout {
                    spacing: 12
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("External Speed port", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 220
                    }

                    StyledComboBox {
                        id: serialNameArd
                        width: 250
                        model: Connect.portsNames
                    }
                }

                RowLayout {
                    spacing: 8
                    Layout.fillWidth: true

                    StyledButton {
                        id: connectButtonArd
                        text: Translator.translate("Connect", Settings.language)
                        width: 160
                        onClicked: {
                            AppSettings.externalspeedconnectionstatus(1)
                            AppSettings.externalspeedport(serialNameArd.textAt(serialNameArd.currentIndex))
                            Arduino.openConnection(Connection.externalspeedport, "9600")
                            connectButtonArd.enabled = false
                            disconnectButtonArd.enabled = true
                        }
                    }

                    StyledButton {
                        id: disconnectButtonArd
                        text: Translator.translate("Disconnect", Settings.language)
                        width: 160
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

        Item { Layout.fillHeight: true }
    }
}
