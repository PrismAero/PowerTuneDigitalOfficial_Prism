import QtQuick 2.15

Item {
    id: root

    property var config: ({})
    property string leftLabel: config.leftLabel !== undefined ? config.leftLabel : "RWD"
    property real liveValue: 50
    property real maxValue: config.maxValue !== undefined ? Number(config.maxValue) : 100
    property real minValue: config.minValue !== undefined ? Number(config.minValue) : 0
    property string valueUnit: config.valueUnit !== undefined ? String(config.valueUnit) : ""
    property int valueDecimals: config.valueDecimals !== undefined ? Number(config.valueDecimals) : 1
    property bool showSideValues: config.showSideValues !== undefined ? (config.showSideValues === true || config.showSideValues === "true") : false
    property bool showCenterValue: config.showCenterValue !== undefined ? (config.showCenterValue === true || config.showCenterValue === "true") : true
    property real dampingMultiplier: config.dampingMultiplier !== undefined ? Number(config.dampingMultiplier) : 1.0
    property bool markerEnabled: config.markerEnabled !== undefined ? (config.markerEnabled === true || config.markerEnabled === "true") : true
    property color markerColor: config.markerColor !== undefined ? String(config.markerColor) : "#00C8FF"
    property real markerWidth: config.markerWidth !== undefined ? Number(config.markerWidth) : 2.0
    property real targetValue: (minValue + maxValue) / 2
    property real minSeen: zeroValue
    property real maxSeen: zeroValue
    property real lastExtremeValue: zeroValue
    property bool hasExtremeMarker: false
    readonly property real span: Math.max(0.0001, maxValue - minValue)
    readonly property real zeroValue: clamp(0.0, minValue, maxValue)
    readonly property real progress: {
        if (maxValue <= minValue)
            return 0.5;
        return Math.max(0, Math.min(1, (liveValue - minValue) / (maxValue - minValue)));
    }
    readonly property real markerProgress: valueToProgress(lastExtremeValue)
    readonly property real leftShare: (1.0 - progress) * span
    readonly property real rightShare: progress * span
    property string rightLabel: config.rightLabel !== undefined ? config.rightLabel : "FWD"
    property string sensorKey: config.sensorKey !== undefined ? config.sensorKey : "differentialSensor"

    function clamp(value, low, high) {
        return Math.max(low, Math.min(high, value));
    }

    function valueToProgress(value) {
        if (maxValue <= minValue)
            return 0.5;
        return clamp((value - minValue) / (maxValue - minValue), 0, 1);
    }

    function formatValue(value) {
        var decimals = clamp(valueDecimals, 0, 4);
        var text = Number(value).toFixed(decimals);
        return valueUnit.length > 0 ? (text + " " + valueUnit) : text;
    }

    function readValue() {
        if (!sensorKey || !PropertyRouter || !PropertyRouter.hasProperty(sensorKey))
            return (minValue + maxValue) / 2;
        var value = Number(PropertyRouter.getValue(sensorKey));
        return isNaN(value) ? (minValue + maxValue) / 2 : value;
    }

    function resetLiveState() {
        var initial = clamp(readValue(), minValue, maxValue);
        targetValue = initial;
        liveValue = initial;
        minSeen = zeroValue;
        maxSeen = zeroValue;
        lastExtremeValue = zeroValue;
        hasExtremeMarker = false;
    }

    Component.onCompleted: resetLiveState()
    onSensorKeyChanged: resetLiveState()
    onMinValueChanged: resetLiveState()
    onMaxValueChanged: resetLiveState()

    Connections {
        function onValueChanged(propertyName, value) {
            if (propertyName === root.sensorKey) {
                var numericValue = Number(value);
                var resolvedValue = isNaN(numericValue) ? (root.minValue + root.maxValue) / 2 : numericValue;
                root.targetValue = root.clamp(resolvedValue, root.minValue, root.maxValue);
                var epsilon = 0.0001;
                var isNonZeroReading = Math.abs(root.targetValue - root.zeroValue) > epsilon;

                if (isNonZeroReading && root.targetValue < root.minSeen) {
                    root.minSeen = root.targetValue;
                    root.lastExtremeValue = root.targetValue;
                    root.hasExtremeMarker = true;
                }

                if (isNonZeroReading && root.targetValue > root.maxSeen) {
                    root.maxSeen = root.targetValue;
                    root.lastExtremeValue = root.targetValue;
                    root.hasExtremeMarker = true;
                }

                if (root.dampingMultiplier >= 0.999)
                    root.liveValue = root.targetValue;
            }
        }

        target: PropertyRouter
    }

    Timer {
        id: smoothTimer

        interval: 16
        repeat: true
        running: true

        onTriggered: {
            if (Math.abs(root.targetValue - root.liveValue) < 0.0001)
                return;
            var factor = root.clamp(root.dampingMultiplier, 0.01, 1.0);
            root.liveValue += (root.targetValue - root.liveValue) * factor;
            if (Math.abs(root.targetValue - root.liveValue) < 0.01)
                root.liveValue = root.targetValue;
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 40
        text: "BRAKE BIAS"
    }

    Text {
        anchors.bottom: leftLabelText.top
        anchors.bottomMargin: 2
        anchors.left: parent.left
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.pixelSize: 20
        text: root.formatValue(root.leftShare)
        visible: root.showSideValues
    }

    Text {
        id: leftLabelText

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.pixelSize: 32
        text: root.leftLabel
    }

    Text {
        anchors.bottom: rightLabelText.top
        anchors.bottomMargin: 2
        anchors.right: parent.right
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.pixelSize: 20
        text: root.formatValue(root.rightShare)
        visible: root.showSideValues
    }

    Text {
        id: rightLabelText

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.pixelSize: 32
        text: root.rightLabel
    }

    Rectangle {
        id: biasTrack

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        height: 19
        radius: 9
        width: 223

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                color: "#FF0909"
                position: 0.0
            }

            GradientStop {
                color: "#1ED033"
                position: 0.5
            }

            GradientStop {
                color: "#FF0909"
                position: 1.0
            }
        }
    }

    Rectangle {
        id: extremeMarker

        anchors.bottom: biasTrack.top
        anchors.bottomMargin: -4
        color: root.markerColor
        height: biasTrack.height + 16
        radius: width / 2
        visible: root.markerEnabled && root.hasExtremeMarker
        width: root.clamp(root.markerWidth, 1.0, 8.0)
        x: biasTrack.x + (root.markerProgress * biasTrack.width) - width / 2
    }

    Rectangle {
        id: biasPointer

        anchors.bottom: biasTrack.bottom
        color: '#ff0000'
        height: 30
        width: 3
        x: biasTrack.x + progress * biasTrack.width - width / 2
    }

    Text {
        anchors.horizontalCenter: biasPointer.horizontalCenter
        anchors.top: biasTrack.bottom
        anchors.topMargin: 3
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.pixelSize: 18
        text: root.formatValue(root.liveValue)
        visible: root.showCenterValue
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: biasPointer.horizontalCenter
        color: '#ff0000'
        height: 8
        radius: 4
        width: 8
    }
}
