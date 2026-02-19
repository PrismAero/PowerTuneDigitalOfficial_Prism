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

    Connections {
        target: Connection
        onSerialStatChanged: {
            consoleText.append(Connection.SerialStat)
            consoleFlickable.contentY = consoleFlickable.contentHeight - consoleFlickable.height
        }
    }

    WifiCountryList {
        id: wificountrynames
    }

    Settings {
        property alias wificountryindex: wificountrycbx.currentIndex
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // * Console Output Section
        Rectangle {
            Layout.preferredWidth: 250
            Layout.maximumWidth: 300
            Layout.fillHeight: true
            color: "#0A0A0A"
            radius: 8
            border.color: "#3D3D3D"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: "Console Output"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.family: "Lato"
                    color: "#009688"
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3D3D3D"
                }

                Flickable {
                    id: consoleFlickable
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentHeight: consoleText.contentHeight

                    TextArea {
                        id: consoleText
                        width: parent.width
                        wrapMode: TextArea.Wrap
                        readOnly: true
                        color: "#4CAF50"
                        font.pixelSize: 13
                        font.family: "Courier New"
                        background: Rectangle { color: "transparent" }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
        }

        // * Settings Column
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            // * WiFi Configuration Section
            SettingsSection {
                title: Translator.translate("WIFI Configuration", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 16
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("WIFI Country", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }

                    StyledComboBox {
                        id: wificountrycbx
                        Layout.fillWidth: true
                        model: wificountrynames
                        textRole: "name"
                    }
                }

                RowLayout {
                    spacing: 16
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("WIFI 1", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }

                    StyledComboBox {
                        id: wifilistbox
                        Layout.fillWidth: true
                        model: Connection.wifi
                        onCountChanged: btnScanNetwork.enabled = true
                    }
                }

                RowLayout {
                    spacing: 16
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("Password 1", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }

                    StyledTextField {
                        id: pw1
                        Layout.fillWidth: true
                        placeholderText: qsTr("Passphrase")
                        echoMode: TextInput.Password
                    }
                }

                RowLayout {
                    spacing: 12

                    StyledButton {
                        id: btnScanNetwork
                        text: Translator.translate("Scan WIFI", Settings.language)
                        Layout.preferredWidth: 160
                        onClicked: {
                            consoleText.clear()
                            Wifiscanner.initializeWifiscanner()
                        }
                    }

                    StyledButton {
                        id: applyWifiSettings
                        text: Translator.translate("Connect WIFI", Settings.language)
                        Layout.preferredWidth: 160
                        onClicked: {
                            Wifiscanner.setwifi(
                                wificountrynames.get(wificountrycbx.currentIndex).countryname,
                                wifilistbox.textAt(wifilistbox.currentIndex),
                                pw1.text, "placeholder", "placeholder")
                            Connect.reboot()
                        }
                    }
                }

                Component.onCompleted: Wifiscanner.initializeWifiscanner()
            }

            // * Network Status Section
            SettingsSection {
                title: Translator.translate("Network Status", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 16
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("Ethernet IP Address", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }

                    ConnectionStatusIndicator {
                        id: ethernetstatus
                        statusText: Connection.EthernetStat
                        status: Connection.EthernetStat === "NOT CONNECTED" ? "disconnected" : "connected"
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 16
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("WLAN IP Address", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }

                    ConnectionStatusIndicator {
                        id: wifistatus
                        statusText: Connection.WifiStat
                        status: Connection.WifiStat === "NOT CONNECTED" ? "disconnected" : "connected"
                        Layout.fillWidth: true
                    }
                }
            }

            // * System Actions and Track Downloads in a row to save vertical space
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                SettingsSection {
                    title: Translator.translate("System Actions", Settings.language)
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    RowLayout {
                        spacing: 12

                        StyledButton {
                            id: updateBtn
                            text: Translator.translate("Update", Settings.language)
                            Layout.preferredWidth: 140
                            onClicked: {
                                Connect.update()
                                updateBtn.enabled = false
                            }
                        }

                        StyledButton {
                            id: develtest
                            text: Translator.translate("Restart daemon", Settings.language)
                            Layout.preferredWidth: 160
                            primary: false
                            onClicked: Connect.restartDaemon()
                        }
                    }
                }

                SettingsSection {
                    title: Translator.translate("Track Downloads", Settings.language)
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    StyledButton {
                        id: trackUpdate
                        text: Translator.translate("Update Tracks", Settings.language)
                        Layout.preferredWidth: 200
                        onClicked: {
                            downloadManager.append("")
                            downloadManager.append("https://gitlab.com/PowerTuneDigital/PowertuneTracks/-/raw/main/repo.txt")
                            downloadManager.append("")
                            consoleText.append("Downloading Tracks for Laptimer:")
                            trackUpdate.enabled = false
                            downloadprogress.indeterminate = true
                        }
                    }

                    RowLayout {
                        spacing: 12
                        Layout.fillWidth: true

                        ProgressBar {
                            id: downloadprogress
                            Layout.preferredWidth: 200
                            height: 8

                            background: Rectangle {
                                implicitWidth: 200
                                implicitHeight: 8
                                color: "#2D2D2D"
                                radius: 4
                            }

                            contentItem: Item {
                                implicitWidth: 200
                                implicitHeight: 8

                                Rectangle {
                                    width: downloadprogress.visualPosition * parent.width
                                    height: parent.height
                                    radius: 4
                                    color: "#009688"
                                    visible: !downloadprogress.indeterminate
                                }

                                Rectangle {
                                    id: indeterminateBar
                                    width: parent.width * 0.3
                                    height: parent.height
                                    radius: 4
                                    color: "#009688"
                                    visible: downloadprogress.indeterminate

                                    SequentialAnimation on x {
                                        running: downloadprogress.indeterminate
                                        loops: Animation.Infinite
                                        NumberAnimation { from: -indeterminateBar.width; to: downloadprogress.width; duration: 1500; easing.type: Easing.InOutQuad }
                                    }
                                }
                            }
                        }

                        Text {
                            id: downloadspeedtext
                            text: downloadManager.downloadStatus
                            font.pixelSize: 14
                            font.family: "Lato"
                            color: "#B0B0B0"
                            onTextChanged: {
                                if (downloadspeedtext.text === "Finished") {
                                    downloadprogress.indeterminate = false
                                    downloadspeedtext.text = " "
                                    Connect.changefolderpermission()
                                }
                            }
                        }
                    }

                    Text {
                        id: downloadfilenametext
                        text: downloadManager.downloadFilename
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: "#B0B0B0"
                        visible: false
                        onTextChanged: consoleText.append(downloadManager.downloadFilename)
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
