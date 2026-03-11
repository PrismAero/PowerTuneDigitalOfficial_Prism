import QtQuick 2.15

Item {
    id: root

    property var config: ({})
    property string sensorKey: config.sensorKey !== undefined ? config.sensorKey : ""
    property string label: config.label !== undefined ? config.label : ""
    property real threshold: config.threshold !== undefined ? Number(config.threshold) : 0.5
    property color onColor: config.onColor !== undefined ? config.onColor : "#1ED033"
    property color offColor: config.offColor !== undefined ? config.offColor : "#FF0909"
    property bool invertLogic: config.invertLogic === true || config.invertLogic === "true"

    property real liveValue: 0

    function readValue() {
        if (!sensorKey || !PropertyRouter || !PropertyRouter.hasProperty(sensorKey))
            return 0
        var value = Number(PropertyRouter.getValue(sensorKey))
        return isNaN(value) ? 0 : value
    }

    readonly property bool stateOn: invertLogic ? liveValue < threshold : liveValue >= threshold

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

    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 190
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.pixelSize: 32
        font.italic: true
        text: root.label
    }

    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 60
        horizontalAlignment: Text.AlignRight
        color: root.stateOn ? root.onColor : root.offColor
        font.family: "Hyperspace Race"
        font.pixelSize: 32
        font.italic: true
        text: root.stateOn ? "ON" : "OFF"
    }
}
