import QtQuick

Item {
    id: root

    property real rpmValue: 0
    property real rpmMax: 10000
    property real shiftPoint: 0.75
    property int pillCount: 11
    property string activationPattern: "center-out"

    width: 925
    height: 30

    readonly property real _pillWidth: 75
    readonly property real _pillGap: 10
    readonly property real _pillRadius: 40

    readonly property var _pillColors: ShiftHelper.pillColors(pillCount)
    readonly property var _activationOrder: ShiftHelper.activationOrder(pillCount, activationPattern)
    readonly property int _activeLights: ShiftHelper.activeLightCount(rpmValue, rpmMax, shiftPoint, pillCount)

    Row {
        anchors.centerIn: parent
        spacing: root._pillGap

        Repeater {
            model: root.pillCount

            Rectangle {
                width: root._pillWidth
                height: 30
                radius: root._pillRadius
                color: ShiftHelper.isPillLit(index, root._activeLights, root._activationOrder)
                       ? root._pillColors[index] : "#222222"

                Behavior on color {
                    ColorAnimation {
                        duration: 60
                    }
                }
            }
        }
    }
}
