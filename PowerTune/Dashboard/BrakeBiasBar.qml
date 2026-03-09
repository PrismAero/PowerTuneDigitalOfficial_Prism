import QtQuick

Item {
    id: root

    property real biasValue: 50.0
    property string fontFamily: ""

    width: 457
    height: 82

    Text {
        id: titleText
        text: "BRAKE BIAS"
        font.family: root.fontFamily
        font.pixelSize: 40
        font.weight: Font.Normal
        font.italic: true
        color: "#FFFFFF"
        anchors.top: parent.top
        anchors.horizontalCenter: barArea.horizontalCenter
    }

    Text {
        id: rwdLabel
        text: "RWD"
        font.family: root.fontFamily
        font.pixelSize: 32
        font.weight: Font.Normal
        font.italic: false
        color: "#FFFFFF"
        anchors.left: parent.left
        anchors.verticalCenter: barTrack.verticalCenter
    }

    Text {
        id: fwdLabel
        text: "FWD"
        font.family: root.fontFamily
        font.pixelSize: 32
        font.weight: Font.Normal
        font.italic: false
        color: "#FFFFFF"
        anchors.right: parent.right
        anchors.verticalCenter: barTrack.verticalCenter
    }

    Item {
        id: barArea
        anchors.left: rwdLabel.right
        anchors.leftMargin: 12
        anchors.right: fwdLabel.left
        anchors.rightMargin: 12
        anchors.top: titleText.bottom
        anchors.topMargin: 4
        height: 18

        Rectangle {
            id: barTrack
            anchors.fill: parent
            radius: 8

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#CC0000" }
                GradientStop { position: 0.5; color: "#CCCC00" }
                GradientStop { position: 1.0; color: "#00CC00" }
            }
        }

        Canvas {
            id: needleCanvas
            x: (root.biasValue / 100.0) * parent.width - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            height: parent.height + 14
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.fillStyle = "#FFFFFF"

                var cx = width / 2
                var stemW = 1.5

                ctx.beginPath()
                ctx.moveTo(cx - stemW, 0)
                ctx.lineTo(cx + stemW, 0)
                ctx.lineTo(cx + stemW, height - 10)
                ctx.lineTo(cx + 6, height - 10)
                ctx.lineTo(cx, height)
                ctx.lineTo(cx - 6, height - 10)
                ctx.lineTo(cx - stemW, height - 10)
                ctx.closePath()
                ctx.fill()
            }
        }
    }
}
