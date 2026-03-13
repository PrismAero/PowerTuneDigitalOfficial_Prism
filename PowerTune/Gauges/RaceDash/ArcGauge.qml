import QtQuick 2.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Gauges.RaceDash 1.0

Item {
    id: root

    property string arcColorEnd: config.arcColorEnd !== undefined ? config.arcColorEnd : (shapeMode === "speedSvg" ? "#B00000" :
                                                                                                                     "#B00000")
    property string arcColorMid: {
        var raw = config.arcColorMid !== undefined ? config.arcColorMid : (shapeMode === "speedSvg" ? "#E11B1B" :
                                                                                                      "#FF8A00");


        if (raw === "" || raw === "0" || raw === "none" || raw === "transparent")
            return "";
        return raw;
    }
    property real arcColorMidPos: config.arcColorMidPos !== undefined ? Number(config.arcColorMidPos) : 0.65
    property string arcColorStart: config.arcColorStart !== undefined ? config.arcColorStart : (shapeMode
                                                                                                === "speedSvg"
                                                                                                ? "#7A0D0D" : "#8F4D17")
    property real arcOffsetX: config.arcOffsetX !== undefined ? Number(config.arcOffsetX) : 5
    property real arcOffsetY: config.arcOffsetY !== undefined ? Number(config.arcOffsetY) : 0
    property real arcScale: config.arcScale !== undefined ? Number(config.arcScale) : 0.945
    property real arcWidth: config.arcWidth !== undefined ? Number(config.arcWidth) : 0.285
    property var config: ({})
    property int decimals: config.decimals !== undefined ? Number(config.decimals) : 0
    readonly property real displayValue: minValue + ((maxValue - minValue) * effectiveProgress)
    readonly property real effectiveProgress: testLoopEnabled ? testProgress : normalizedValue
    property real endAngle: config.endAngle !== undefined ? Number(config.endAngle) : (shapeMode === "speedSvg" ? 315 :
                                                                                                                  56)
    property real endTaper: config.endTaper !== undefined ? Number(config.endTaper) : (shapeMode === "speedSvg" ? 0.24 :
                                                                                                                  0.18)
    property real liveValue: 0
    property real maxValue: config.maxValue !== undefined ? Number(config.maxValue) : 100
    property real minValue: config.minValue !== undefined ? Number(config.minValue) : 0
    property real minimumVisibleFraction: config.minimumVisibleFraction !== undefined ? Number(
                                                                                            config.minimumVisibleFraction) :
                                                                                        0.08
    readonly property real normalizedValue: {
        if (maxValue <= minValue)
            return 0;
        return Math.max(0, Math.min(1, (liveValue - minValue) / (maxValue - minValue)));
    }
    property string sensorKey: config.sensorKey !== undefined ? config.sensorKey : ""
    property string shapeMode: config.shapeMode === "speedSvg" ? "speedSvg" : "tachSvg"
    property real startAngle: config.startAngle !== undefined ? Number(config.startAngle) : 225
    property real startTaper: config.startTaper !== undefined ? Number(config.startTaper) : (shapeMode === "speedSvg" ? 0.28 :
                                                                                                                        0.18)
    property int testLoopDuration: config.testLoopDuration !== undefined ? Number(config.testLoopDuration) : 1800
    property bool testLoopEnabled: config.testLoopEnabled === true || config.testLoopEnabled === "true"
    property real testProgress: 0
    property real valueOffsetY: config.valueOffsetY !== undefined ? Number(config.valueOffsetY) : (shapeMode
                                                                                                   === "speedSvg" ? 62 :
                                                                                                                    94)
    readonly property bool warningActive: warningEnabled && displayValue >= warningThreshold
    property bool warningEnabled: config.warningEnabled === true || config.warningEnabled === "true"
    property bool warningFlash: config.warningFlash !== undefined ? (config.warningFlash === true
                                                                     || config.warningFlash === "true") : true
    property int warningFlashRate: config.warningFlashRate !== undefined ? Number(config.warningFlashRate) : 200
    property real warningThreshold: config.warningThreshold !== undefined ? Number(config.warningThreshold) : maxValue

    function readValue() {
        if (!sensorKey || !PropertyRouter || !PropertyRouter.hasProperty(sensorKey))
            return 0;
        var value = Number(PropertyRouter.getValue(sensorKey));
        return isNaN(value) ? 0 : value;
    }

    SequentialAnimation on testProgress {
        loops: Animation.Infinite
        running: root.testLoopEnabled

        NumberAnimation {
            duration: Math.max(100, root.testLoopDuration)
            easing.type: Easing.InOutSine
            from: 0
            to: 1
        }

        NumberAnimation {
            duration: Math.max(100, root.testLoopDuration)
            easing.type: Easing.InOutSine
            from: 1
            to: 0
        }
    }

    Component.onCompleted: liveValue = readValue()

    Connections {
        function onValueChanged(propertyName, value) {
            if (!root.testLoopEnabled && propertyName === root.sensorKey) {
                var numericValue = Number(value);
                root.liveValue = isNaN(numericValue) ? 0 : numericValue;
            }
        }

        target: PropertyRouter
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
            arcScale: root.arcScale
            arcWidth: root.arcWidth
            centerOffsetX: root.arcOffsetX
            centerOffsetY: root.arcOffsetY
            endAngle: root.endAngle
            endColor: root.arcColorEnd
            endTaper: root.endTaper
            midColor: root.arcColorMid
            midColorStop: root.arcColorMidPos
            minimumVisibleFraction: root.minimumVisibleFraction
            progress: root.effectiveProgress
            shapeMode: root.shapeMode
            startAngle: root.startAngle
            startColor: root.arcColorStart
            startTaper: root.startTaper
            warningMix: warningTimer.phase ? 0.85 : 0.0
        }
    }
}
