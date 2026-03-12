import QtQuick 2.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Gauges.RaceDash 1.0

Item {
    id: root

    property var config: ({})
    property string sensorKey: config.sensorKey !== undefined ? config.sensorKey : ""
    property string shapeMode: config.shapeMode === "speedSvg" ? "speedSvg" : "tachSvg"
    property real minValue: config.minValue !== undefined ? Number(config.minValue) : 0
    property real maxValue: config.maxValue !== undefined ? Number(config.maxValue) : 100
    property int decimals: config.decimals !== undefined ? Number(config.decimals) : 0
    property bool warningEnabled: config.warningEnabled === true || config.warningEnabled === "true"
    property real warningThreshold: config.warningThreshold !== undefined ? Number(config.warningThreshold) : maxValue
    property bool warningFlash: config.warningFlash !== undefined ? (config.warningFlash === true || config.warningFlash === "true") : true
    property int warningFlashRate: config.warningFlashRate !== undefined ? Number(config.warningFlashRate) : 200
    property real startAngle: config.startAngle !== undefined ? Number(config.startAngle) : 225
    property real endAngle: config.endAngle !== undefined ? Number(config.endAngle) : (shapeMode === "speedSvg" ? 315 : 56)
    property real arcWidth: config.arcWidth !== undefined ? Number(config.arcWidth) : 0.285
    property real arcScale: config.arcScale !== undefined ? Number(config.arcScale) : 0.945
    property real arcOffsetX: config.arcOffsetX !== undefined ? Number(config.arcOffsetX) : 5
    property real arcOffsetY: config.arcOffsetY !== undefined ? Number(config.arcOffsetY) : 0
    property real minimumVisibleFraction: config.minimumVisibleFraction !== undefined ? Number(config.minimumVisibleFraction) : 0.08
    property real startTaper: config.startTaper !== undefined ? Number(config.startTaper) : (shapeMode === "speedSvg" ? 0.28 : 0.18)
    property real endTaper: config.endTaper !== undefined ? Number(config.endTaper) : (shapeMode === "speedSvg" ? 0.24 : 0.18)
    property bool testLoopEnabled: config.testLoopEnabled === true || config.testLoopEnabled === "true"
    property int testLoopDuration: config.testLoopDuration !== undefined ? Number(config.testLoopDuration) : 1800
    property string arcColorStart: config.arcColorStart !== undefined ? config.arcColorStart : (shapeMode === "speedSvg" ? "#7A0D0D" : "#8F4D17")
    property string arcColorMid: config.arcColorMid !== undefined ? config.arcColorMid : (shapeMode === "speedSvg" ? "#E11B1B" : "#FF8A00")
    property real arcColorMidPos: config.arcColorMidPos !== undefined ? Number(config.arcColorMidPos) : 0.65
    property string arcColorEnd: config.arcColorEnd !== undefined ? config.arcColorEnd : (shapeMode === "speedSvg" ? "#B00000" : "#B00000")
    property real valueOffsetY: config.valueOffsetY !== undefined ? Number(config.valueOffsetY) : (shapeMode === "speedSvg" ? 62 : 94)

    property real liveValue: 0
    property real testProgress: 0
    readonly property real normalizedValue: {
        if (maxValue <= minValue)
            return 0
        return Math.max(0, Math.min(1, (liveValue - minValue) / (maxValue - minValue)))
    }
    readonly property real effectiveProgress: testLoopEnabled ? testProgress : normalizedValue
    readonly property real displayValue: minValue + ((maxValue - minValue) * effectiveProgress)
    readonly property bool warningActive: warningEnabled && displayValue >= warningThreshold

    function readValue() {
        if (!sensorKey || !PropertyRouter || !PropertyRouter.hasProperty(sensorKey))
            return 0
        var value = Number(PropertyRouter.getValue(sensorKey))
        return isNaN(value) ? 0 : value
    }

    Component.onCompleted: liveValue = readValue()

    SequentialAnimation on testProgress {
        running: root.testLoopEnabled
        loops: Animation.Infinite

        NumberAnimation {
            from: 0
            to: 1
            duration: Math.max(100, root.testLoopDuration)
            easing.type: Easing.InOutSine
        }

        NumberAnimation {
            from: 1
            to: 0
            duration: Math.max(100, root.testLoopDuration)
            easing.type: Easing.InOutSine
        }
    }

    Connections {
        target: PropertyRouter

        function onValueChanged(propertyName, value) {
            if (!root.testLoopEnabled && propertyName === root.sensorKey) {
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
        anchors.fill: parent

        RaceArcItem {
            anchors.fill: parent
            progress: root.effectiveProgress
            shapeMode: root.shapeMode
            warningMix: warningTimer.phase ? 0.85 : 0.0
            startAngle: root.startAngle
            endAngle: root.endAngle
            arcWidth: root.arcWidth
            arcScale: root.arcScale
            centerOffsetX: root.arcOffsetX
            centerOffsetY: root.arcOffsetY
            minimumVisibleFraction: root.minimumVisibleFraction
            startTaper: root.startTaper
            endTaper: root.endTaper
            startColor: root.arcColorStart
            midColor: root.arcColorMid
            midColorStop: root.arcColorMidPos
            endColor: root.arcColorEnd
        }
    }

}
