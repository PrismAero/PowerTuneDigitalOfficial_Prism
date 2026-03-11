import QtQuick 2.15

Item {
    id: root

    property var config: ({})
    property string sensorKey: config.sensorKey !== undefined ? config.sensorKey : "rpm"
    property real rpmMax: config.maxValue !== undefined ? Number(config.maxValue) : 10000
    property real shiftPoint: config.shiftPoint !== undefined ? Number(config.shiftPoint) : 0.75
    property int shiftCount: config.shiftCount !== undefined ? Number(config.shiftCount) : 11
    property string shiftPattern: config.shiftPattern !== undefined ? config.shiftPattern : "center-out"

    property real liveValue: 0

    function readValue() {
        if (!PropertyRouter || !PropertyRouter.hasProperty(sensorKey))
            return 0
        var value = Number(PropertyRouter.getValue(sensorKey))
        return isNaN(value) ? 0 : value
    }

    readonly property var pillColors: ShiftHelper ? ShiftHelper.pillColors(shiftCount) : []
    readonly property var activationOrder: ShiftHelper ? ShiftHelper.activationOrder(shiftCount, shiftPattern) : []
    readonly property int activeCount: ShiftHelper ? ShiftHelper.activeLightCount(liveValue, rpmMax, shiftPoint, shiftCount) : 0

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

    Row {
        anchors.fill: parent
        spacing: 10

        Repeater {
            model: root.shiftCount

            Rectangle {
                width: (root.width - (root.shiftCount - 1) * parent.spacing) / root.shiftCount
                height: root.height
                radius: 40
                color: root.pillColors.length > index ? root.pillColors[index] : "#1ED033"
                opacity: ShiftHelper && ShiftHelper.isPillLit(index, root.activeCount, root.activationOrder) ? 1.0 : 0.16

                Behavior on opacity {
                    NumberAnimation { duration: 90 }
                }
            }
        }
    }
}
