import QtQuick

Item {
    id: root

    property string teamName: "Cardinal Racing"
    property bool systemOk: true
    property string fontFamily: ""

    width: 1600
    height: 40

    Rectangle {
        id: barBackground
        anchors.fill: parent
        color: "transparent"
        visible: false
    }

    Row {
        id: leftGroup
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Text {
            text: "System"
            font.family: root.fontFamily
            font.pixelSize: 24
            font.weight: Font.Normal
            font.italic: true
            font.letterSpacing: -0.96
            color: "#FFFFFF"
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 16
            height: 16
            radius: 8
            color: root.systemOk ? "#1ED033" : "#FF0909"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Text {
        id: centerText
        text: root.teamName
        font.family: root.fontFamily
        font.pixelSize: 24
        font.weight: Font.Normal
        font.italic: true
        font.letterSpacing: -0.96
        color: "#FFFFFF"
        anchors.centerIn: parent
    }

    Text {
        id: clockText
        text: Diagnostics.displayTime
        font.family: root.fontFamily
        font.pixelSize: 24
        font.weight: Font.Normal
        font.italic: true
        font.letterSpacing: -0.96
        color: "#FFFFFF"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        width: 90
    }
}
