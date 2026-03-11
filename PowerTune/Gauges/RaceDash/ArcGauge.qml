import QtQuick 2.15
import PowerTune.Gauges.Shared 1.0

Item {
    id: root

    property var config: ({})
    property string sensorKey: config.sensorKey !== undefined ? config.sensorKey : ""
    property real minValue: config.minValue !== undefined ? Number(config.minValue) : 0
    property real maxValue: config.maxValue !== undefined ? Number(config.maxValue) : 100
    property int decimals: config.decimals !== undefined ? Number(config.decimals) : 0
    property string unit: config.unit !== undefined ? config.unit : ""
    property real startAngle: config.startAngle !== undefined ? Number(config.startAngle) : 135
    property real sweepAngle: config.sweepAngle !== undefined ? Number(config.sweepAngle) : 270
    property real arcWidth: config.arcWidth !== undefined ? Number(config.arcWidth) : 0.209
    property color arcColorStart: config.arcColorStart !== undefined ? config.arcColorStart : "#E88A1A"
    property color arcColorMid: config.arcColorMid !== undefined ? config.arcColorMid : "transparent"
    property real arcColorMidPos: config.arcColorMidPos !== undefined ? Number(config.arcColorMidPos) : 0.5
    property color arcColorEnd: config.arcColorEnd !== undefined ? config.arcColorEnd : "#C45A00"
    property color arcBgColor: config.arcBgColor !== undefined ? config.arcBgColor : "#151518"
    property bool warningEnabled: config.warningEnabled === true || config.warningEnabled === "true"
    property real warningThreshold: config.warningThreshold !== undefined ? Number(config.warningThreshold) : maxValue
    property bool warningFlash: config.warningFlash !== undefined ? (config.warningFlash === true || config.warningFlash === "true") : true
    property int warningFlashRate: config.warningFlashRate !== undefined ? Number(config.warningFlashRate) : 200
    property bool alignmentOverrideEnabled: config.alignmentOverrideEnabled === true || config.alignmentOverrideEnabled === "true"
    property real alignmentOverrideProgress: config.alignmentOverrideProgress !== undefined ? Number(config.alignmentOverrideProgress) : 1.0
    property real valueOffsetY: config.valueOffsetY !== undefined ? Number(config.valueOffsetY) : height * 0.085
    property real contentRightInsetRatio: config.contentRightInsetRatio !== undefined ? Number(config.contentRightInsetRatio) : 0.0583
    property real contentBottomInsetRatio: config.contentBottomInsetRatio !== undefined ? Number(config.contentBottomInsetRatio) : 0.151

    property real liveValue: 0
    readonly property real normalizedValue: {
        if (alignmentOverrideEnabled)
            return Math.max(0, Math.min(1, alignmentOverrideProgress))
        if (maxValue <= minValue)
            return 0
        return Math.max(0, Math.min(1, (liveValue - minValue) / (maxValue - minValue)))
    }
    readonly property real displayValue: alignmentOverrideEnabled
        ? (minValue + (normalizedValue * (maxValue - minValue)))
        : liveValue
    readonly property bool warningActive: warningEnabled && displayValue >= warningThreshold

    function readValue() {
        if (!sensorKey || !PropertyRouter || !PropertyRouter.hasProperty(sensorKey))
            return 0
        var value = Number(PropertyRouter.getValue(sensorKey))
        return isNaN(value) ? 0 : value
    }

    function formattedValue() {
        var digits = Math.max(0, decimals)
        return Number(displayValue).toFixed(digits)
    }

    Component.onCompleted: liveValue = readValue()

    Connections {
        target: PropertyRouter

        function onValueChanged(propertyName, value) {
            if (propertyName === root.sensorKey) {
                var numericValue = Number(value)
                root.liveValue = isNaN(numericValue) ? 0 : numericValue
            }
        }
    }

    WarningFlashTimer {
        id: warningTimer
        active: root.warningActive
        flashEnabled: root.warningFlash
        flashRate: root.warningFlashRate
    }

    Item {
        id: arcLayer
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width * (1.0 - root.contentRightInsetRatio)
        height: parent.height * (1.0 - root.contentBottomInsetRatio)

        ShaderEffect {
            id: arcShader
            anchors.fill: parent
            blending: true

            vertexShader: "qrc:/qt/qml/PrismPT/Dashboard/PowerTune/Dashboard/Shaders/arc_fill.vert.qsb"
            fragmentShader: "qrc:/qt/qml/PrismPT/Dashboard/PowerTune/Dashboard/Shaders/arc_fill.frag.qsb"

            property real uProgress: root.normalizedValue
            property real uStartAngleDeg: root.startAngle
            property real uSweepAngleDeg: root.sweepAngle
            property real uThickness: root.arcWidth
            property color uColorStart: root.arcColorStart
            property color uColorMid: root.arcColorMid
            property color uColorEnd: root.arcColorEnd
            property color uBgColor: "transparent"
            property real uUseMidColor: root.arcColorMid.a > 0 ? 1.0 : 0.0
            property real uMidPos: root.arcColorMidPos
            property real uHighlightStrength: 0.35
            property real uHighlightWidth: 0.08
            property real uInnerFade: 0.42
            property real uOuterFade: 0.24
            property real uWarningMix: warningTimer.phase ? 0.7 : 0.0
            property real uOpacity: 1.0
        }
    }

    Item {
        anchors.fill: parent

        Column {
            spacing: 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: root.valueOffsetY

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#FFFFFF"
                font.family: "Hyperspace Race"
                font.pixelSize: parent ? parent.parent.width * 0.213 : 0
                font.italic: false
                text: root.formattedValue()
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#FFFFFF"
                font.family: "Hyperspace Race"
                font.pixelSize: parent ? parent.parent.width * 0.076 : 0
                font.italic: true
                text: root.unit
            }
        }
    }
}
