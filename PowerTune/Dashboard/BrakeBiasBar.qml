import QtQuick

Item {
    id: root

    // -- Configurable properties --
    property string datasource: ""
    property real currentValue: 50.0
    property real minValue: 0
    property real maxValue: 100
    property string leftLabel: "FRONT"
    property string rightLabel: "REAR"
    property color fillColor: "#009688"
    property color bgColor: "#333333"
    property string fontFamily: ""

    width: 457
    height: 82

    // -- PropertyRouter reactive binding --
    Connections {
        target: typeof PropertyRouter !== "undefined" ? PropertyRouter : null
        function onValueChanged(propertyName, value) {
            if (propertyName === root.datasource && root.datasource !== "") {
                root.currentValue = Number(value)
            }
        }
    }

    // -- Config application from OverlayConfigPopup --
    function applyConfig(config) {
        if (config.sensorKey) datasource = config.sensorKey
        if (config.minValue !== undefined) minValue = Number(config.minValue)
        if (config.maxValue !== undefined) maxValue = Number(config.maxValue)
        if (config.leftLabel) leftLabel = config.leftLabel
        if (config.rightLabel) rightLabel = config.rightLabel
    }

    // -- Computed bias fraction (0.0 = full left, 1.0 = full right) --
    readonly property real _biasFraction: {
        var range = maxValue - minValue
        if (range <= 0) return 0.5
        return Math.max(0, Math.min(1, (currentValue - minValue) / range))
    }

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
        id: leftLabelText
        text: root.leftLabel
        font.family: root.fontFamily
        font.pixelSize: 32
        font.weight: Font.Normal
        font.italic: false
        color: "#FFFFFF"
        anchors.left: parent.left
        anchors.verticalCenter: barTrack.verticalCenter
    }

    Text {
        id: rightLabelText
        text: root.rightLabel
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
        anchors.left: leftLabelText.right
        anchors.leftMargin: 12
        anchors.right: rightLabelText.left
        anchors.rightMargin: 12
        anchors.top: titleText.bottom
        anchors.topMargin: 4
        height: 18

        // Background track
        Rectangle {
            id: barTrack
            anchors.fill: parent
            radius: 8
            color: root.bgColor
        }

        // Left (front) fill portion
        Rectangle {
            id: leftFill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * root._biasFraction
            radius: 8
            color: root.fillColor

            Behavior on width {
                NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
            }
        }

        // Needle indicator at the split point
        Canvas {
            id: needleCanvas
            x: root._biasFraction * parent.width - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            height: parent.height + 14

            Behavior on x {
                NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
            }

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

        // Percentage label centered on the bar
        Text {
            anchors.centerIn: parent
            text: Math.round(root._biasFraction * 100) + " / " + Math.round((1.0 - root._biasFraction) * 100)
            font.family: root.fontFamily
            font.pixelSize: 12
            font.weight: Font.Bold
            color: "#FFFFFF"
        }
    }
}
