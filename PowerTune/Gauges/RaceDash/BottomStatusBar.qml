import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property string centerText: config.text !== undefined ? config.text : "Cardinal Racing"
    property var config: ({})
    property string currentTimeText: ""
    property bool timeEnabled: config.timeEnabled !== undefined ? (config.timeEnabled === true || config.timeEnabled
                                                                   === "true") : true

    function statusColor() {
        if (!Diagnostics)
            return "#FF0909";
        if (Diagnostics.canStatusText === "Active")
            return "#1ED033";
        if (Diagnostics.canStatusText === "Waiting")
            return "#F1E83C";
        return "#FF0909";
    }

    function updateTime() {
        var now = new Date();
        currentTimeText = Qt.formatTime(now, "h:mm AP");
    }

    Component.onCompleted: updateTime()

    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: root.updateTime()
    }

    RowLayout {
        anchors.bottomMargin: 5
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 5
        spacing: 0

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 180

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    color: "#FFFFFF"
                    font.family: "Hyperspace Race"
                    font.italic: true
                    font.pixelSize: 24
                    text: "System"
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.statusColor()
                    height: 16
                    radius: 8
                    width: 16
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                anchors.centerIn: parent
                color: "#FFFFFF"
                font.family: "Hyperspace Race"
                font.italic: true
                font.pixelSize: 24
                text: root.centerText
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 120

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: "#FFFFFF"
                font.family: "Hyperspace Race"
                font.italic: true
                font.pixelSize: 24
                text: root.currentTimeText
                visible: root.timeEnabled
            }
        }
    }
}
