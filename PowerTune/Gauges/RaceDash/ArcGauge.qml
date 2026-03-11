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
    property string unit: config.unit !== undefined ? config.unit : ""
    property bool warningEnabled: config.warningEnabled === true || config.warningEnabled === "true"
    property real warningThreshold: config.warningThreshold !== undefined ? Number(config.warningThreshold) : maxValue
    property bool warningFlash: config.warningFlash !== undefined ? (config.warningFlash === true || config.warningFlash === "true") : true
    property int warningFlashRate: config.warningFlashRate !== undefined ? Number(config.warningFlashRate) : 200
    property bool alignmentGuideEnabled: config.alignmentOverrideEnabled === true || config.alignmentOverrideEnabled === "true"
    property real alignmentGuideProgress: config.alignmentOverrideProgress !== undefined ? Number(config.alignmentOverrideProgress) : 1.0
    property real referenceOverlaySize: config.referenceOverlaySize !== undefined
        ? Number(config.referenceOverlaySize)
        : (config.overlaySize !== undefined ? Number(config.overlaySize) : Math.max(width, 1))
    property real valueOffsetY: {
        if (config.valueOffsetY === undefined)
            return height * 0.085
        var rawOffset = Number(config.valueOffsetY)
        if (isNaN(rawOffset))
            return height * 0.085
        var referenceSize = referenceOverlaySize > 0 ? referenceOverlaySize : Math.max(width, 1)
        return rawOffset * (width / referenceSize)
    }
    property real contentRightInsetRatio: config.contentRightInsetRatio !== undefined ? Number(config.contentRightInsetRatio) : 0.0583
    property real contentBottomInsetRatio: config.contentBottomInsetRatio !== undefined ? Number(config.contentBottomInsetRatio) : 0.151
    readonly property real contentScale: Math.min(1.0 - contentRightInsetRatio, 1.0 - contentBottomInsetRatio)

    property real liveValue: 0
    readonly property real normalizedValue: {
        if (maxValue <= minValue)
            return 0
        return Math.max(0, Math.min(1, (liveValue - minValue) / (maxValue - minValue)))
    }
    readonly property real displayValue: liveValue
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
        width: Math.min(parent.width, parent.height) * root.contentScale
        height: width
        anchors.left: parent.left
        anchors.top: parent.top

        RaceArcItem {
            anchors.fill: parent
            visible: root.alignmentGuideEnabled
            opacity: 0.18
            progress: 1.0
            shapeMode: root.shapeMode
            warningMix: 0.0
        }

        RaceArcItem {
            anchors.fill: parent
            visible: root.alignmentGuideEnabled
            opacity: 0.45
            progress: Math.max(0, Math.min(1, root.alignmentGuideProgress))
            shapeMode: root.shapeMode
            warningMix: 0.0
        }

        RaceArcItem {
            anchors.fill: parent
            progress: root.normalizedValue
            shapeMode: root.shapeMode
            warningMix: warningTimer.phase ? 0.85 : 0.0
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
