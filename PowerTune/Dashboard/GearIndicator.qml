import QtQuick

Item {
    id: root

    property int gear: 0
    property string fontFamily: ""

    readonly property string _gearText: {
        if (gear === 0) return "N"
        if (gear < 0) return "R"
        return gear.toString()
    }

    readonly property string _suffix: {
        if (gear <= 0) return ""
        if (gear === 1) return "st"
        if (gear === 2) return "nd"
        if (gear === 3) return "rd"
        return "th"
    }

    width: 180
    height: gearRow.height + dividerLine.height + 4

    Item {
        id: gearRow
        width: parent.width
        height: gearNumber.paintedHeight
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            id: gearNumber
            text: root._gearText
            font.family: root.fontFamily
            font.pixelSize: 140
            font.weight: Font.Bold
            color: "#FFFFFF"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: suffixText
            text: root._suffix
            font.family: root.fontFamily
            font.pixelSize: 52
            font.weight: Font.Bold
            color: "#FFFFFF"
            anchors.left: gearNumber.right
            anchors.leftMargin: 2
            anchors.bottom: gearNumber.bottom
            anchors.bottomMargin: gearNumber.paintedHeight * 0.25
            visible: root._suffix.length > 0
        }
    }

    Rectangle {
        id: dividerLine
        width: 301
        height: 2
        visible: false
        anchors.top: gearRow.bottom
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
