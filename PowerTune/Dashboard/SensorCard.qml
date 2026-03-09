import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property string label: "Water Temp"
    property string unit: "F"
    property real value: 0
    property int decimals: 2
    property string fontFamily: ""
    property bool showDivider: true

    width: 340
    height: 130

    Text {
        id: labelText
        text: root.label
        font.family: root.fontFamily
        font.pixelSize: 40
        font.weight: Font.Light
        font.italic: true
        color: "#FFFFFF"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: parent.width - 250
        width: 250
        horizontalAlignment: Text.AlignRight
    }

    Text {
        id: valueText
        text: root.value.toFixed(root.decimals)
        font.family: root.fontFamily
        font.pixelSize: 68
        font.weight: Font.Normal
        font.italic: true
        font.letterSpacing: -2.72
        color: "#FFFFFF"
        anchors.left: parent.left
        anchors.top: labelText.bottom
        anchors.topMargin: 2

        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 4
            horizontalOffset: 0
            radius: 8
            samples: 17
            color: "#40000000"
        }
    }

    Text {
        id: unitText
        text: root.unit
        font.family: root.fontFamily
        font.pixelSize: 32
        font.weight: Font.Normal
        font.italic: true
        color: "#FFFFFF"
        anchors.right: parent.right
        anchors.rightMargin: parent.width - 250
        anchors.bottom: valueText.bottom
        anchors.bottomMargin: 4

        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 4
            horizontalOffset: 0
            radius: 8
            samples: 17
            color: "#40000000"
        }
    }

    Canvas {
        id: dividerVector
        x: 35
        y: 33
        width: 304
        height: 79
        visible: root.showDivider
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = "#3A3A3A"
            ctx.lineWidth = 1.5

            ctx.beginPath()
            ctx.moveTo(0, height)
            ctx.lineTo(width * 0.28, height * 0.08)
            ctx.lineTo(width, height * 0.08)
            ctx.stroke()
        }
    }
}
