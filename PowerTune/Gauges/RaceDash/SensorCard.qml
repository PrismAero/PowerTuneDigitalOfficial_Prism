import QtQuick
import PowerTune.Gauges.Shared 1.0

Item {
    id: root

    property var config: ({})
    property int decimals: config.decimals !== undefined ? Number(config.decimals) : 0
    property string label: config.label !== undefined ? config.label : "Sensor"
    property real liveValue: 0
    property color normalColor: config.normalColor !== undefined ? config.normalColor : "#FFFFFF"
    property string sensorKey: config.sensorKey !== undefined ? config.sensorKey : "rpm"
    property string unit: config.unit !== undefined ? config.unit : ""
    readonly property color valueColor: warningActive ? warningColor : normalColor
    readonly property bool warningActive: {
        if (!warningEnabled)
            return false;
        if (warningDirection === "below")
            return liveValue <= warningThreshold;
        return liveValue >= warningThreshold;
    }
    property color warningColor: config.warningColor !== undefined ? config.warningColor : "#FF0000"
    property string warningDirection: config.warningDirection !== undefined ? config.warningDirection : "above"
    property bool warningEnabled: config.warningEnabled === true || config.warningEnabled === "true"
    property bool warningFlash: config.warningFlash !== undefined ? (config.warningFlash === true
                                                                     || config.warningFlash === "true") : true
    property int warningFlashRate: config.warningFlashRate !== undefined ? Number(config.warningFlashRate) : 200
    property real warningThreshold: config.warningThreshold !== undefined ? Number(config.warningThreshold) : 0

    readonly property bool flashHidden: warningFlashTimer.phase
    readonly property real flashOpacity: flashHidden ? 0.0 : 1.0

    function readValue() {
        if (!sensorKey || !PropertyRouter || !PropertyRouter.hasProperty(sensorKey))
            return 0;
        var value = Number(PropertyRouter.getValue(sensorKey));
        return isNaN(value) ? 0 : value;
    }

    Component.onCompleted: liveValue = readValue()
    onSensorKeyChanged: liveValue = readValue()

    Connections {
        function onValueChanged(propertyName, value) {
            if (propertyName === root.sensorKey) {
                var numericValue = Number(value);
                root.liveValue = isNaN(numericValue) ? 0 : numericValue;
            }
        }

        target: PropertyRouter
    }

    WarningFlashTimer {
        id: warningFlashTimer

        active: root.warningActive
        flashEnabled: root.warningFlash
        flashRate: root.warningFlashRate
    }

    Text {
        id: labelText

        anchors.right: parent.right
        anchors.top: parent.top
        color: root.warningActive ? root.warningColor : "#FFFFFF"
        font.bold: root.warningActive
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 40
        horizontalAlignment: Text.AlignRight
        opacity: root.warningActive ? root.flashOpacity : 1.0
        text: root.label
    }

    Text {
        anchors.left: valueText.left
        anchors.leftMargin: 0
        anchors.top: valueText.top
        anchors.topMargin: 4
        color: "#40000000"
        font.bold: root.warningActive
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 68
        opacity: root.warningActive ? root.flashOpacity : 1.0
        text: root.liveValue.toFixed(root.decimals)
        z: 0
    }

    Text {
        id: valueText

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 41
        color: root.valueColor
        font.bold: root.warningActive
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 68
        opacity: root.warningActive ? root.flashOpacity : 1.0
        text: root.liveValue.toFixed(root.decimals)
        z: 1
    }

    Text {
        anchors.right: parent.right
        anchors.top: unitText.top
        anchors.topMargin: 4
        color: "#40000000"
        font.bold: root.warningActive
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 32
        horizontalAlignment: Text.AlignRight
        opacity: root.warningActive ? root.flashOpacity : 1.0
        text: root.unit
        z: 0
    }

    Text {
        id: unitText

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 64
        color: root.valueColor
        font.bold: root.warningActive
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 32
        horizontalAlignment: Text.AlignRight
        opacity: root.warningActive ? root.flashOpacity : 1.0
        text: root.unit
        z: 1
    }
}
