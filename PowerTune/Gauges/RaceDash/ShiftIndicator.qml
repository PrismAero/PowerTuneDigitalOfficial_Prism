import QtQuick

Item {
    id: root

    readonly property var activationOrder: ShiftHelper ? ShiftHelper.activationOrder(shiftCount, shiftPattern) : []
    readonly property int activeCount: ShiftHelper ? ShiftHelper.activeLightCount(liveValue, rpmMax, shiftPoint,
                                                                                  shiftCount) : 0
    property var config: ({})
    property real liveValue: 0
    readonly property var pillColors: ShiftHelper ? ShiftHelper.pillColors(shiftCount) : []
    property real rpmMax: config.maxValue !== undefined ? Number(config.maxValue) : 10000
    property string sensorKey: config.sensorKey !== undefined ? config.sensorKey : "rpm"
    property int shiftCount: config.shiftCount !== undefined ? Number(config.shiftCount) : 11
    property string shiftPattern: config.shiftPattern !== undefined ? config.shiftPattern : "center-out"
    property real shiftPoint: config.shiftPoint !== undefined ? Number(config.shiftPoint) : 0.3

    function readValue() {
        if (!PropertyRouter || !PropertyRouter.hasProperty(sensorKey))
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

    Row {
        anchors.fill: parent
        spacing: 10

        Repeater {
            model: root.shiftCount

            Rectangle {
                color: root.pillColors.length > index ? root.pillColors[index] : "#1ED033"
                height: root.height
                opacity: ShiftHelper && ShiftHelper.isPillLit(index, root.activeCount, root.activationOrder) ? 1.0 :
                                                                                                               0.16
                radius: 40
                width: (root.width - (root.shiftCount - 1) * parent.spacing) / root.shiftCount

                Behavior on opacity {
                    NumberAnimation {
                        duration: 90
                    }
                }
            }
        }
    }
}
