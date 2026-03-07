// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    anchors.fill: parent
    color: "#1a1a2e"

    // Generic CAN daemon index in the C++ backend mapping
    readonly property int genericCanDaemonIndex: 40

    Item {
        id: startupsettings
        Settings {
            property alias mainspeedsource: mainspeedsource.currentIndex
            property alias bitrateselect: canbitrateselect.currentIndex
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        anchors.rightMargin: parent.width * 0.35
        spacing: 12

        SettingsSection {
            title: Translator.translate("Startup daemon", Settings.language)
            Layout.fillWidth: true

            RowLayout {
                spacing: 16
                Layout.fillWidth: true

                Text {
                    text: Translator.translate("Startup daemon", Settings.language)
                    font.pixelSize: 18
                    font.family: "Lato"
                    color: "#FFFFFF"
                    Layout.preferredWidth: 180
                }

                StyledComboBox {
                    id: daemonselect
                    width: 280
                    model: ["Generic CAN"]
                    enabled: false
                }

                StyledButton {
                    text: Translator.translate("Apply", Settings.language)
                    width: 120
                    onClicked: {
                        Connect.daemonstartup(genericCanDaemonIndex)
                        Connect.canbitratesetup(canbitrateselect.currentIndex)
                    }
                }
            }
        }

        SettingsSection {
            title: Translator.translate("Can Bitrate", Settings.language)
            Layout.fillWidth: true

            RowLayout {
                spacing: 16
                Layout.fillWidth: true

                Text {
                    text: Translator.translate("Can Bitrate", Settings.language)
                    font.pixelSize: 18
                    font.family: "Lato"
                    color: "#FFFFFF"
                    Layout.preferredWidth: 180
                }

                StyledComboBox {
                    id: canbitrateselect
                    width: 280
                    model: ["250 kbit/s", "500 kbit/s", "1 Mbit/s"]
                }
            }
        }

        SettingsSection {
            title: Translator.translate("Main Speed Source", Settings.language)
            Layout.fillWidth: true

            RowLayout {
                spacing: 16
                Layout.fillWidth: true

                Text {
                    text: Translator.translate("Main Speed Source", Settings.language)
                    font.pixelSize: 18
                    font.family: "Lato"
                    color: "#FFFFFF"
                    Layout.preferredWidth: 180
                }

                StyledComboBox {
                    id: mainspeedsource
                    width: 280
                    model: ["ECU Speed", "LF Wheelspeed", "RF Wheelspeed", "LR Wheelspeed", "RR Wheelspeed", "GPS", "VR Sensor"]
                    onCurrentIndexChanged: AppSettings.writeStartupSettings(mainspeedsource.currentIndex)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: warningtext.implicitHeight + 24
            color: "#2D1A1A"
            radius: 8
            border.color: "#F44336"
            border.width: 1

            Text {
                id: warningtext
                text: Translator.translate("Warningtext", Settings.language)
                font.pixelSize: 18
                font.bold: true
                font.family: "Lato"
                width: parent.width - 24
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                color: "#F44336"
                wrapMode: Text.WordWrap
            }
        }

        Item { Layout.fillHeight: true }
    }
}
