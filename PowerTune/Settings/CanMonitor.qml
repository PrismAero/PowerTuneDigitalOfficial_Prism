import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    visible: true
    width: parent.width
    height: parent.height
    color: "#121212"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // * Header
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
                    text: "CAN Bus Monitor"
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                    font.family: "Lato"
                    color: "#FFFFFF"
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: listView.model.count > 0 ? "#4CAF50" : "#707070"

                    SequentialAnimation on opacity {
                        running: listView.model.count > 0
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.5; duration: 500 }
                        NumberAnimation { to: 1.0; duration: 500 }
                    }
                }

                Text {
                    text: listView.model.count + " messages"
                    font.pixelSize: 16
                    font.family: "Lato"
                    color: "#B0B0B0"
                }
            }
        }

        // * CAN Message List Header
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
                    text: "CAN ID"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    font.family: "Lato"
                    color: "#009688"
                    Layout.preferredWidth: 150
                }

                Text {
                    text: "Payload (Hex)"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    font.family: "Lato"
                    color: "#009688"
                    Layout.fillWidth: true
                }
            }
        }

        // * CAN Message ListView
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#1E1E1E"
            radius: 8
            border.color: "#3D3D3D"
            border.width: 1

            ListView {
                id: listView
                anchors.fill: parent
                anchors.margins: 8
                clip: true
                spacing: 2

                model: ListModel {}

                delegate: Rectangle {
                    width: listView.width
                    height: 36
                    color: index % 2 === 0 ? "#252525" : "#2D2D2D"
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 20

                        // * CAN ID with badge style
                        Rectangle {
                            width: 120
                            height: 24
                            color: "#009688"
                            radius: 4

                            Text {
                                anchors.centerIn: parent
                                text: model.canId
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                font.family: "Courier New"
                                color: "#FFFFFF"
                            }
                        }

                        // * Payload
                        Text {
                            text: model.payload
                            font.pixelSize: 14
                            font.family: "Courier New"
                            color: "#FFFFFF"
                            Layout.fillWidth: true
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
            }

            // * Empty state
            Text {
                anchors.centerIn: parent
                text: "No CAN messages received"
                font.pixelSize: 18
                font.family: "Lato"
                color: "#707070"
                visible: listView.model.count === 0
            }
        }
    }

    Connections {
        target: Connection
        function onCanChanged() {
            var canId = Connection.can[0]
            var payload = Connection.can[1]
            var itemFound = false

            for (var i = 0; i < listView.model.count; ++i) {
                if (listView.model.get(i).canId === canId) {
                    listView.model.setProperty(i, "payload", payload)
                    itemFound = true
                    break
                }
            }

            if (!itemFound) {
                listView.model.append({ "canId": canId, "payload": payload })
            }
        }
    }
}
