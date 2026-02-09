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
        Settings {
            property alias maxrpm: maxRPM.text
            property alias shift1: stage1.text
            property alias shift2: stage2.text
            property alias shift3: stage3.text
            property alias shift4: stage4.text
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

            // * RPM Configuration Section
            SettingsSection {
                title: "RPM Configuration"
                Layout.fillWidth: true

                RowLayout {
                    spacing: 20

                    Text {
                        text: "MAX RPM"
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 180
                    }

                    StyledTextField {
                        id: maxRPM
                        width: 200
                        text: "10000"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: applysettings.start()
                    }
                }
            }

            // * Shift Light Section
            SettingsSection {
                title: Translator.translate("Shift Light", Dashboard.language)
                Layout.fillWidth: true

                Text {
                    text: "Configure RPM thresholds for each shift light stage"
                    font.pixelSize: 16
                    font.family: "Lato"
                    color: "#707070"
                    font.italic: true
                }

                RowLayout {
                    spacing: 20
                    Layout.fillWidth: true

                    // * Stage 1
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 120
                        color: "#2D2D2D"
                        radius: 8
                        border.color: "#4CAF50"
                        border.width: 2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: Translator.translate("Stage", Dashboard.language) + " 1"
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                                font.family: "Lato"
                                color: "#4CAF50"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            StyledTextField {
                                id: stage1
                                width: 160
                                text: "3000"
                                Layout.alignment: Qt.AlignHCenter
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onEditingFinished: applysettings.start()
                            }

                            Text {
                                text: "RPM"
                                font.pixelSize: 14
                                font.family: "Lato"
                                color: "#B0B0B0"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // * Stage 2
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 120
                        color: "#2D2D2D"
                        radius: 8
                        border.color: "#FFEB3B"
                        border.width: 2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: Translator.translate("Stage", Dashboard.language) + " 2"
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                                font.family: "Lato"
                                color: "#FFEB3B"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            StyledTextField {
                                id: stage2
                                width: 160
                                text: "5500"
                                Layout.alignment: Qt.AlignHCenter
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onEditingFinished: applysettings.start()
                            }

                            Text {
                                text: "RPM"
                                font.pixelSize: 14
                                font.family: "Lato"
                                color: "#B0B0B0"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // * Stage 3
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 120
                        color: "#2D2D2D"
                        radius: 8
                        border.color: "#FF9800"
                        border.width: 2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: Translator.translate("Stage", Dashboard.language) + " 3"
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                                font.family: "Lato"
                                color: "#FF9800"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            StyledTextField {
                                id: stage3
                                width: 160
                                text: "5500"
                                Layout.alignment: Qt.AlignHCenter
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onEditingFinished: applysettings.start()
                            }

                            Text {
                                text: "RPM"
                                font.pixelSize: 14
                                font.family: "Lato"
                                color: "#B0B0B0"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // * Stage 4
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 120
                        color: "#2D2D2D"
                        radius: 8
                        border.color: "#F44336"
                        border.width: 2

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: Translator.translate("Stage", Dashboard.language) + " 4"
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                                font.family: "Lato"
                                color: "#F44336"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            StyledTextField {
                                id: stage4
                                width: 160
                                text: "7500"
                                Layout.alignment: Qt.AlignHCenter
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onEditingFinished: applysettings.start()
                            }

                            Text {
                                text: "RPM"
                                font.pixelSize: 14
                                font.family: "Lato"
                                color: "#B0B0B0"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        id: applysettings
        function start() {
            AppSettings.writeRPMSettings(maxRPM.text, stage1.text, stage2.text, stage3.text, stage4.text)
        }
    }
}
