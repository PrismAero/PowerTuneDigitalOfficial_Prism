import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.UI 1.0

Rectangle {
    id: root

    color: "#121212"
    height: parent.height
    visible: true
    width: parent.width

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#1E1E1E"
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Text {
                    color: "#FFFFFF"
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                    text: "CAN Bus Monitor"
                }

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 8

                    Text {
                        color: CanMonitorModel.showAllFrames ? "#707070" : "#009688"
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: 16
                        text: "Extender Only"
                    }

                    Switch {
                        id: frameFilterSwitch

                        checked: CanMonitorModel.showAllFrames

                        onCheckedChanged: CanMonitorModel.showAllFrames = checked
                    }

                    Text {
                        color: CanMonitorModel.showAllFrames ? "#009688" : "#707070"
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: 16
                        text: "All Frames"
                    }
                }

                Item {
                    width: 16
                }

                Rectangle {
                    color: CanMonitorModel.messageCount > 0 ? "#4CAF50" : "#707070"
                    height: 12
                    radius: 6
                    width: 12

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: CanMonitorModel.messageCount > 0

                        NumberAnimation {
                            duration: 500
                            to: 0.5
                        }

                        NumberAnimation {
                            duration: 500
                            to: 1.0
                        }
                    }
                }

                Text {
                    color: "#B0B0B0"
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: 18
                    text: CanMonitorModel.messageCount + " messages"
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#2D2D2D"
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 20

                Text {
                    Layout.preferredWidth: 150
                    color: "#009688"
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    text: "CAN ID"
                }

                Text {
                    Layout.fillWidth: true
                    color: "#009688"
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    text: "Payload (Hex)"
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            border.color: "#3D3D3D"
            border.width: 1
            color: "#1E1E1E"
            radius: 8

            ListView {
                id: listView

                anchors.fill: parent
                anchors.margins: 8
                clip: true
                model: CanMonitorModel
                spacing: 2

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
                delegate: Rectangle {
                    color: index % 2 === 0 ? "#252525" : "#2D2D2D"
                    height: 36
                    radius: 4
                    width: listView.width

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 20

                        Rectangle {
                            color: "#009688"
                            height: 24
                            radius: 4
                            width: 120

                            Text {
                                anchors.centerIn: parent
                                color: "#FFFFFF"
                                font.family: SettingsTheme.fontFamilyMono
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                text: model.canId
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            color: "#FFFFFF"
                            font.family: SettingsTheme.fontFamilyMono
                            font.pixelSize: 14
                            text: model.payload
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                color: "#707070"
                font.family: SettingsTheme.fontFamily
                font.pixelSize: 18
                text: "No CAN messages received"
                visible: CanMonitorModel.messageCount === 0
            }
        }
    }
}
