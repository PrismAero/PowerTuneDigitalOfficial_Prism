import QtQuick 2.15

Item {
    id: genwarning

    property string warningtext: ""

    anchors.fill: parent

    Rectangle {
        id: genwarningsquare

        anchors.centerIn: parent
        color: "red"
        height: parent.height / 1.5
        width: parent.width / 1.5

        SequentialAnimation on color {
            loops: Animation.Infinite

            ColorAnimation {
                duration: 300
                from: "red"
                to: "orange"
            }

            ColorAnimation {
                duration: 300
                from: "orange"
                to: "red"
            }
        }

        Text {
            id: warntxt

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height / 5
            color: "black"
            font.bold: true
            font.family: "Lato"
            font.pixelSize: parent.width / 13
            text: "Warning!!!"
        }

        Text {
            id: warningtxt

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: warntxt.bottom
            anchors.topMargin: parent.height / 5
            color: "black"
            font.bold: true
            font.family: "Lato"
            font.pixelSize: parent.width / 20
            text: warningtext
        }
    }
}
