import QtQuick

Item {
    id: root

    property string teamName: "Cardinal Racing"
    property bool systemOk: true
    property string fontFamily: ""

    width: 1600
    height: 40

    property string _currentTime: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date()
            var h = d.getHours()
            var m = d.getMinutes()
            var ampm = h >= 12 ? "Pm" : "Am"
            h = h % 12
            if (h === 0) h = 12
            var mStr = m < 10 ? "0" + m : m.toString()
            root._currentTime = h + ":" + mStr + " " + ampm
        }
    }

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
        text: root._currentTime
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
