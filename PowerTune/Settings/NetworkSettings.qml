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

    Component.onCompleted: {
        wificountrycbx.currentIndex = AppSettings.getValue("ui/wifiCountryIndex", 0);
        settingsLoaded = true;
    }

    Connections {
        function onSerialStatChanged() {
            consoleText.append(Connection.SerialStat);
            consoleFlickable.contentY = consoleFlickable.contentHeight - consoleFlickable.height;
        }

        target: Connection
    }

    WifiCountryList {
        id: wificountrynames

    }

    RowLayout {
        Layout.fillWidth: true
        Layout.minimumHeight: root.height - 2 * SettingsTheme.pageMargin
        spacing: SettingsTheme.sectionSpacing

        // * Settings Column (constrained width)
        ColumnLayout {
            Layout.fillHeight: true
            Layout.maximumWidth: 520
            Layout.preferredWidth: 480
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("WIFI Configuration", Settings.language)

                Component.onCompleted: Wifiscanner.initializeWifiscanner()

                SettingsRow {
                    label: Translator.translate("WIFI Country", Settings.language)

                    StyledComboBox {
                        id: wificountrycbx

                        height: parent.height
                        model: wificountrynames
                        textRole: "name"
                        width: parent.width

                        onCurrentIndexChanged: if (settingsLoaded)
                                                   AppSettings.setValue("ui/wifiCountryIndex", currentIndex)
                    }
                }

                SettingsRow {
                    label: Translator.translate("WIFI 1", Settings.language)

                    StyledComboBox {
                        id: wifilistbox

                        height: parent.height
                        model: Connection.wifi
                        width: parent.width

                        onCountChanged: btnScanNetwork.enabled = true
                    }
                }

                SettingsRow {
                    label: Translator.translate("Password 1", Settings.language)

                    StyledTextField {
                        id: pw1

                        echoMode: TextInput.Password
                        height: parent.height
                        placeholderText: qsTr("Passphrase")
                        width: parent.width
                    }
                }

                RowLayout {
                    spacing: SettingsTheme.sectionPadding

                    StyledButton {
                        id: btnScanNetwork

                        text: Translator.translate("Scan WIFI", Settings.language)

                        onClicked: {
                            consoleText.clear();
                            Wifiscanner.initializeWifiscanner();
                        }
                    }

                    StyledButton {
                        id: applyWifiSettings

                        text: Translator.translate("Connect WIFI", Settings.language)

                        onClicked: {
                            Wifiscanner.setwifi(wificountrynames.get(wificountrycbx.currentIndex).countryname,
                                                wifilistbox.textAt(wifilistbox.currentIndex), pw1.text, "placeholder",
                                                "placeholder");
                            Connect.reboot();
                        }
                    }
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Network Status", Settings.language)

                SettingsRow {
                    label: Translator.translate("Ethernet IP Address", Settings.language)

                    ConnectionStatusIndicator {
                        id: ethernetstatus

                        height: parent.height
                        status: Connection.EthernetStat === "NOT CONNECTED" ? "disconnected" : "connected"
                        statusText: Connection.EthernetStat
                        width: parent.width
                    }
                }

                SettingsRow {
                    label: Translator.translate("WLAN IP Address", Settings.language)

                    ConnectionStatusIndicator {
                        id: wifistatus

                        height: parent.height
                        status: Connection.WifiStat === "NOT CONNECTED" ? "disconnected" : "connected"
                        statusText: Connection.WifiStat
                        width: parent.width
                    }
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("System Actions", Settings.language)

                RowLayout {
                    spacing: SettingsTheme.sectionPadding

                    StyledButton {
                        id: updateBtn

                        text: Translator.translate("Update", Settings.language)

                        onClicked: {
                            Diagnostics.addLogMessage("INFO", "System update initiated");
                            consoleText.append("[System] Update initiated...");
                            Connect.update();
                            updateBtn.enabled = false;
                        }
                    }

                    StyledButton {
                        id: develtest

                        primary: false
                        text: Translator.translate("Restart daemon", Settings.language)

                        onClicked: {
                            Diagnostics.addLogMessage("INFO", "Daemon restart initiated");
                            consoleText.append("[System] Restarting daemon...");
                            Connect.restartDaemon();
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }

        // * Console Output (fills remaining width)
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth
            color: SettingsTheme.consoleBg
            radius: SettingsTheme.radiusLarge

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: SettingsTheme.sectionPadding
                spacing: SettingsTheme.contentSpacing

                Text {
                    color: SettingsTheme.accent
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontSectionTitle
                    font.weight: Font.Bold
                    text: "Console Output"
                }

                Rectangle {
                    Layout.fillWidth: true
                    color: SettingsTheme.border
                    height: SettingsTheme.borderWidth
                }

                Flickable {
                    id: consoleFlickable

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    contentHeight: consoleText.contentHeight

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    TextArea {
                        id: consoleText

                        color: SettingsTheme.consoleText
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontCaption
                        readOnly: true
                        width: parent.width
                        wrapMode: TextArea.Wrap

                        background: Rectangle {
                            color: "transparent"
                        }
                    }
                }
            }
        }
    }
}
