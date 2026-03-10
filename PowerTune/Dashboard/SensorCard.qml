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

    // -- Configurable properties for overlay config system --
    property string datasource: ""
    property real currentValue: 0.0
    property int decimalPlaces: 1
    property string unitLabel: ""
    property bool warningEnabled: false
    property real warningThreshold: -1
    property color warningColor: "#FF0000"
    property string warningDirection: "above"
    property color textColor: "#FFFFFF"

    width: 340
    height: 130

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
        if (config.label) label = config.label
        if (config.decimals !== undefined) decimalPlaces = Number(config.decimals)
        if (config.unit) unitLabel = config.unit
        if (config.warningEnabled !== undefined) warningEnabled = config.warningEnabled === true || config.warningEnabled === "true"
        if (config.warningThreshold !== undefined) warningThreshold = Number(config.warningThreshold)
        if (config.warningColor) warningColor = config.warningColor
        if (config.warningDirection) warningDirection = config.warningDirection
        if (config.normalColor) textColor = config.normalColor
    }

    // -- Warning state computation --
    readonly property bool _isWarning: {
        if (!warningEnabled || warningThreshold < 0) return false
        if (warningDirection === "below")
            return currentValue < warningThreshold
        return currentValue >= warningThreshold
    }

    // -- Effective display values: prefer datasource-driven values, fall back to legacy --
    readonly property string _displayValue: {
        if (datasource !== "") {
            return currentValue.toFixed(decimalPlaces)
        }
        return value.toFixed(decimals)
    }

    readonly property string _displayUnit: {
        if (datasource !== "" && unitLabel !== "") return unitLabel
        return unit
    }

    readonly property color _displayColor: {
        if (_isWarning) return warningColor
        if (datasource !== "") return textColor
        return "#FFFFFF"
    }

    Text {
        id: labelText
        text: root.label
        font.family: root.fontFamily
        font.pixelSize: 40
        font.weight: Font.Light
        font.italic: true
        color: root._displayColor
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: parent.width - 250
        width: 250
        horizontalAlignment: Text.AlignRight
    }

    Text {
        id: valueText
        text: root._displayValue
        font.family: root.fontFamily
        font.pixelSize: 68
        font.weight: Font.Normal
        font.italic: true
        font.letterSpacing: -2.72
        color: root._displayColor
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
        text: root._displayUnit
        font.family: root.fontFamily
        font.pixelSize: 32
        font.weight: Font.Normal
        font.italic: true
        color: root._displayColor
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
