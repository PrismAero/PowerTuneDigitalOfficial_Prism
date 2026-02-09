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

    Connections {
        target: Dashboard
        onSerialStatChanged: {
            consoleText.append(Dashboard.SerialStat)
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
        spacing: 24

        // * Console Output Section
        Rectangle {
            Layout.preferredWidth: 500
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
                    font.weight: Font.DemiBold
                    font.family: "Lato"
                    color: "#B0B0B0"
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
                        font.pixelSize: 14
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
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: parent.width - 20
                spacing: 20

                // * WiFi Configuration Section
                SettingsSection {
                    title: Translator.translate("WIFI Configuration", Dashboard.language)
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: 20
                        Layout.fillWidth: true

                        Text {
                            text: Translator.translate("WIFI Country", Dashboard.language)
                            font.pixelSize: 20
                            font.family: "Lato"
                            color: "#FFFFFF"
                            Layout.preferredWidth: 180
                        }

                        StyledComboBox {
                            id: wificountrycbx
                            width: 280
                            model: wificountrynames
                            textRole: "name"
                        }
                    }

                    RowLayout {
                        spacing: 20
                        Layout.fillWidth: true

                        Text {
                            text: Translator.translate("WIFI 1", Dashboard.language)
                            font.pixelSize: 20
                            font.family: "Lato"
                            color: "#FFFFFF"
                            Layout.preferredWidth: 180
                        }

                        StyledComboBox {
                            id: wifilistbox
                            width: 280
                            model: Dashboard.wifi
                            onCountChanged: btnScanNetwork.enabled = true
                        }
                    }

                    RowLayout {
                        spacing: 20
                        Layout.fillWidth: true

                        Text {
                            text: Translator.translate("Password 1", Dashboard.language)
                            font.pixelSize: 20
                            font.family: "Lato"
                            color: "#FFFFFF"
                            Layout.preferredWidth: 180
                        }

                        StyledTextField {
                            id: pw1
                            width: 280
                            placeholderText: qsTr("Passphrase")
                            echoMode: TextInput.Password
                        }
                    }

                    RowLayout {
                        spacing: 12

                        StyledButton {
                            id: btnScanNetwork
                            text: Translator.translate("Scan WIFI", Dashboard.language)
                            width: 180
                            onClicked: {
                                consoleText.clear()
                                Wifiscanner.initializeWifiscanner()
                            }
                        }

                        StyledButton {
                            id: applyWifiSettings
                            text: Translator.translate("Connect WIFI", Dashboard.language)
                            width: 180
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
                    title: Translator.translate("Network Status", Dashboard.language)
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: 20
                        Layout.fillWidth: true

                        Text {
                            text: Translator.translate("Ethernet IP adress", Dashboard.language)
                            font.pixelSize: 20
                            font.family: "Lato"
                            color: "#FFFFFF"
                            Layout.preferredWidth: 180
                        }

                        ConnectionStatusIndicator {
                            id: ethernetstatus
                            statusText: Dashboard.EthernetStat
                            status: Dashboard.EthernetStat === "NOT CONNECTED" ? "disconnected" : "connected"
                            width: 280
                        }
                    }

                    RowLayout {
                        spacing: 20
                        Layout.fillWidth: true

                        Text {
                            text: Translator.translate("WLAN IP adress", Dashboard.language)
                            font.pixelSize: 20
                            font.family: "Lato"
                            color: "#FFFFFF"
                            Layout.preferredWidth: 180
                        }

                        ConnectionStatusIndicator {
                            id: wifistatus
                            statusText: Dashboard.WifiStat
                            status: Dashboard.WifiStat === "NOT CONNECTED" ? "disconnected" : "connected"
                            width: 280
                        }
                    }
                }

                // * System Actions Section
                SettingsSection {
                    title: Translator.translate("System Actions", Dashboard.language)
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: 12

                        StyledButton {
                            id: updateBtn
                            text: Translator.translate("Update", Dashboard.language)
                            width: 180
                            onClicked: {
                                Connect.update()
                                updateBtn.enabled = false
                            }
                        }

                        StyledButton {
                            id: develtest
                            text: Translator.translate("Restart daemon", Dashboard.language)
                            width: 180
                            primary: false
                            onClicked: Connect.restartDaemon()
                        }
                    }
                }

                // * Track Downloads Section
                SettingsSection {
                    title: Translator.translate("Track Downloads", Dashboard.language)
                    Layout.fillWidth: true

                    StyledButton {
                        id: trackUpdate
                        text: Translator.translate("Update Tracks", Dashboard.language)
                        width: 280
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
                            Layout.preferredWidth: 300
                            height: 8

                            background: Rectangle {
                                implicitWidth: 300
                                implicitHeight: 8
                                color: "#2D2D2D"
                                radius: 4
                            }

                            contentItem: Item {
                                implicitWidth: 300
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
                            font.pixelSize: 16
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
        }
    }
}
