// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

SettingsPage {
    id: root
    property bool settingsLoaded: false

    Connections {
        target: Connection
        function onSerialStatChanged() {
            consoleText.append(Connection.SerialStat)
            consoleFlickable.contentY = consoleFlickable.contentHeight - consoleFlickable.height
        }
    }

    WifiCountryList {
        id: wificountrynames
    }

    Component.onCompleted: {
        wificountrycbx.currentIndex = AppSettings.getValue("ui/wifiCountryIndex", 0)
        settingsLoaded = true
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.minimumHeight: root.height - 2 * SettingsTheme.pageMargin
        spacing: SettingsTheme.sectionSpacing

        // * Settings Column (constrained width)
        ColumnLayout {
            Layout.preferredWidth: 480
            Layout.maximumWidth: 520
            Layout.fillHeight: true
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                title: Translator.translate("WIFI Configuration", Settings.language)
                Layout.fillWidth: true

                SettingsRow {
                    label: Translator.translate("WIFI Country", Settings.language)
                    StyledComboBox {
                        id: wificountrycbx
                        width: parent.width
                        height: parent.height
                        model: wificountrynames
                        textRole: "name"
                        onCurrentIndexChanged: if (settingsLoaded) AppSettings.setValue("ui/wifiCountryIndex", currentIndex)
                    }
                }

                SettingsRow {
                    label: Translator.translate("WIFI 1", Settings.language)
                    StyledComboBox {
                        id: wifilistbox
                        width: parent.width
                        height: parent.height
                        model: Connection.wifi
                        onCountChanged: btnScanNetwork.enabled = true
                    }
                }

                SettingsRow {
                    label: Translator.translate("Password 1", Settings.language)
                    StyledTextField {
                        id: pw1
                        width: parent.width
                        height: parent.height
                        placeholderText: qsTr("Passphrase")
                        echoMode: TextInput.Password
                    }
                }

                RowLayout {
                    spacing: SettingsTheme.sectionPadding

                    StyledButton {
                        id: btnScanNetwork
                        text: Translator.translate("Scan WIFI", Settings.language)
                        onClicked: {
                            consoleText.clear()
                            Wifiscanner.initializeWifiscanner()
                        }
                    }

                    StyledButton {
                        id: applyWifiSettings
                        text: Translator.translate("Connect WIFI", Settings.language)
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

            SettingsSection {
                title: Translator.translate("Network Status", Settings.language)
                Layout.fillWidth: true

                SettingsRow {
                    label: Translator.translate("Ethernet IP Address", Settings.language)
                    ConnectionStatusIndicator {
                        id: ethernetstatus
                        width: parent.width
                        height: parent.height
                        statusText: Connection.EthernetStat
                        status: Connection.EthernetStat === "NOT CONNECTED" ? "disconnected" : "connected"
                    }
                }

                SettingsRow {
                    label: Translator.translate("WLAN IP Address", Settings.language)
                    ConnectionStatusIndicator {
                        id: wifistatus
                        width: parent.width
                        height: parent.height
                        statusText: Connection.WifiStat
                        status: Connection.WifiStat === "NOT CONNECTED" ? "disconnected" : "connected"
                    }
                }
            }

            SettingsSection {
                title: Translator.translate("System Actions", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: SettingsTheme.sectionPadding

                    StyledButton {
                        id: updateBtn
                        text: Translator.translate("Update", Settings.language)
                        onClicked: {
                            Diagnostics.addLogMessage("INFO", "System update initiated")
                            consoleText.append("[System] Update initiated...")
                            Connect.update()
                            updateBtn.enabled = false
                        }
                    }

                    StyledButton {
                        id: develtest
                        text: Translator.translate("Restart daemon", Settings.language)
                        primary: false
                        onClicked: {
                            Diagnostics.addLogMessage("INFO", "Daemon restart initiated")
                            consoleText.append("[System] Restarting daemon...")
                            Connect.restartDaemon()
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }

        // * Console Output (fills remaining width)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: SettingsTheme.consoleBg
            radius: SettingsTheme.radiusLarge
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: SettingsTheme.sectionPadding
                spacing: SettingsTheme.contentSpacing

                Text {
                    text: "Console Output"
                    font.pixelSize: SettingsTheme.fontSectionTitle
                    font.weight: Font.Bold
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.accent
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: SettingsTheme.borderWidth
                    color: SettingsTheme.border
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
                        color: SettingsTheme.consoleText
                        font.pixelSize: SettingsTheme.fontCaption
                        font.family: SettingsTheme.fontFamilyMono
                        background: Rectangle { color: "transparent" }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
        }
    }
}
