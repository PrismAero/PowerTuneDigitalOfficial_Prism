import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property var config: ({})
    property string centerText: config.text !== undefined ? config.text : "Cardinal Racing"
    property bool timeEnabled: config.timeEnabled !== undefined ? (config.timeEnabled === true || config.timeEnabled === "true") : true

    property string currentTimeText: ""

    function statusColor() {
        if (!Diagnostics)
            return "#FF0909"
        if (Diagnostics.canStatusText === "Active")
            return "#1ED033"
        if (Diagnostics.canStatusText === "Waiting")
            return "#F1E83C"
        return "#FF0909"
    }

    function updateTime() {
        var now = new Date()
        currentTimeText = Qt.formatTime(now, "h:mm AP")
    }

    Component.onCompleted: updateTime()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateTime()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        spacing: 0

        Item {
            Layout.preferredWidth: 180
            Layout.fillHeight: true

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    color: "#FFFFFF"
                    font.family: "Hyperspace Race"
                    font.pixelSize: 24
                    font.italic: true
                    text: "System"
                }

                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: root.statusColor()
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                anchors.centerIn: parent
                color: "#FFFFFF"
                font.family: "Hyperspace Race"
                font.pixelSize: 24
                font.italic: true
                text: root.centerText
            }
        }

        Item {
            Layout.preferredWidth: 120
            Layout.fillHeight: true

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.timeEnabled
                color: "#FFFFFF"
                font.family: "Hyperspace Race"
                font.pixelSize: 24
                font.italic: true
                text: root.currentTimeText
            }
        }
    }
}
