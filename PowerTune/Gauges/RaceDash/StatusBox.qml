import QtQuick 2.15

Item {
    id: root

    property var config: ({})
    property bool invertLogic: config.invertLogic === true || config.invertLogic === "true"
    property string label: config.label !== undefined ? config.label : "Status:"
    property real liveValue: 0
    property color offColor: config.offColor !== undefined ? config.offColor : "#FF0909"
    property color onColor: config.onColor !== undefined ? config.onColor : "#1ED033"
    property string sensorKey: config.sensorKey !== undefined ? config.sensorKey : "EXDigitalInput1"
    readonly property bool stateOn: invertLogic ? liveValue < threshold : liveValue >= threshold
    property real threshold: config.threshold !== undefined ? Number(config.threshold) : 0.5

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
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 32
        text: root.label
        width: 190
    }

    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: root.stateOn ? root.onColor : root.offColor
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 32
        horizontalAlignment: Text.AlignRight
        text: root.stateOn ? "ON" : "OFF"
        width: 60
    }
}
