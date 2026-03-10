import QtQuick

Item {
    id: root

    property string label1: "Fuel Pump:"
    property string label2: "Cooling Fan:"
    property bool value1: false
    property bool value2: false
    property string fontFamily: ""

    // -- Configurable properties for overlay config system --
    property string datasource: ""
    property real currentValue: 0.0
    property real threshold: 0.5
    property bool invertLogic: false
    property color onColor: "#1ED033"
    property color offColor: "#FF0909"

    // -- Computed active state --
    readonly property bool isActive: invertLogic ? currentValue < threshold : currentValue >= threshold

    width: 405
    height: 183

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
        if (config.label) label1 = config.label
        if (config.threshold !== undefined) threshold = Number(config.threshold)
        if (config.invertLogic !== undefined) invertLogic = config.invertLogic === true || config.invertLogic === "true"
        if (config.onColor) onColor = config.onColor
        if (config.offColor) offColor = config.offColor
    }

    Canvas {
        id: borderChrome
        width: 304
        height: 79
        anchors.left: parent.left
        anchors.top: parent.top
        transform: Rotation {
            angle: 180
            origin.x: borderChrome.width / 2
            origin.y: borderChrome.height / 2
        }

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

    Row {
        id: row1
        x: 78
        y: 40
        spacing: 0

        Text {
            text: root.label1
            font.family: root.fontFamily
            font.pixelSize: 32
            font.weight: Font.Normal
            font.italic: true
            color: "#FFFFFF"
            width: 190
        }
        Text {
            text: root.value1 ? "ON" : "OFF"
            font.family: root.fontFamily
            font.pixelSize: 32
            font.weight: Font.Normal
            font.italic: true
            color: root.value1 ? root.onColor : root.offColor
            width: 60
            horizontalAlignment: Text.AlignRight
        }
    }

    Canvas {
        id: frameDivider
        x: 32
        y: 79
        width: 341
        height: 22
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var grad = ctx.createLinearGradient(0, height / 2, width, height / 2)
            grad.addColorStop(0.0, "transparent")
            grad.addColorStop(0.06, "#3A3A3A")
            grad.addColorStop(0.5, "#4A4A4A")
            grad.addColorStop(0.94, "#3A3A3A")
            grad.addColorStop(1.0, "transparent")

            ctx.strokeStyle = grad
            ctx.lineWidth = 1.0
            ctx.beginPath()
            ctx.moveTo(0, height / 2)
            ctx.lineTo(width, height / 2)
            ctx.stroke()
        }
    }

    Row {
        id: row2
        x: 78
        y: 115
        spacing: 0

        Text {
            text: root.label2
            font.family: root.fontFamily
            font.pixelSize: 32
            font.weight: Font.Normal
            font.italic: true
            color: "#FFFFFF"
            width: 190
        }
        Text {
            text: root.value2 ? "ON" : "OFF"
            font.family: root.fontFamily
            font.pixelSize: 32
            font.weight: Font.Normal
            font.italic: true
            color: root.value2 ? root.onColor : root.offColor
            width: 60
            horizontalAlignment: Text.AlignRight
        }
    }
}
