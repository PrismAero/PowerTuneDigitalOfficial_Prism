import QtQuick 2.15

Item {
    id: root

    property var config: ({})
    property int decimals: config.decimals !== undefined ? Number(config.decimals) : 2
    property string label: config.label !== undefined ? config.label : ""
    property real liveValue: 0
    property color normalColor: config.normalColor !== undefined ? config.normalColor : "#FFFFFF"
    property string sensorKey: config.sensorKey !== undefined ? config.sensorKey : ""
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
    property real warningThreshold: config.warningThreshold !== undefined ? Number(config.warningThreshold) : 0

    function readValue() {
        if (!sensorKey || !PropertyRouter || !PropertyRouter.hasProperty(sensorKey))
            return 0;
        var value = Number(PropertyRouter.getValue(sensorKey));
        return isNaN(value) ? 0 : value;
    }

    Component.onCompleted: liveValue = readValue()

    Connections {
        function onValueChanged(propertyName, value) {
            if (propertyName === root.sensorKey) {
                var numericValue = Number(value);
                root.liveValue = isNaN(numericValue) ? 0 : numericValue;
            }
        }

        target: PropertyRouter
    }

    Text {
        id: labelText

        anchors.right: parent.right
        anchors.top: parent.top
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 40
        horizontalAlignment: Text.AlignRight
        text: root.label
    }

    Text {
        anchors.left: valueText.left
        anchors.leftMargin: 0
        anchors.top: valueText.top
        anchors.topMargin: 4
        color: "#40000000"
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 68
        text: root.liveValue.toFixed(root.decimals)
        z: 0
    }

    Text {
        id: valueText

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 41
        color: root.valueColor
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 68
        text: root.liveValue.toFixed(root.decimals)
        z: 1
    }

    Text {
        anchors.right: parent.right
        anchors.top: unitText.top
        anchors.topMargin: 4
        color: "#40000000"
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 32
        horizontalAlignment: Text.AlignRight
        text: root.unit
        z: 0
    }

    Text {
        id: unitText

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 64
        color: root.valueColor
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 32
        horizontalAlignment: Text.AlignRight
        text: root.unit
        z: 1
    }
}
