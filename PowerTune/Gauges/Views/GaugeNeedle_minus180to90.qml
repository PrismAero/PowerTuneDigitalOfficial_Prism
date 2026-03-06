/*
Gauge Needle that moves from -180 degrees to 90 degrees which pulls a red Tail
modified code from
https://github.com/alex-adam/Tesla
*/

import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root

    property real value: 0

    onValueChanged: {
        zeiger.rotation = Math.min(Math.max(-250, root.value * 3.5 - 180), 90);
        root.currentValue = zeiger.rotation - 180;
    }
    width: parent.width
    height: parent.height

    Rectangle {
        id: zeiger
        rotation: -180
        width: parent.width / 85
        height: parent.width / 2.2
        transformOrigin: Item.Bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter

        smooth: true
        antialiasing: true
        color: "white"
        onRotationChanged: root.currentValue = zeiger.rotation - 180

        Behavior on rotation {
            NumberAnimation {
                duration: 5
                easing.type: Easing.OutCirc
            }
        }
    }

    property color secondaryColor: zeiger.color

    property real centerWidth: width / 2
    property real centerHeight: height / 2
    property real radius: Math.min(root.width, root.height) / 2.08

    property real minimumValue: -360
    property real maximumValue: 0
    property real currentValue: -360

    property real angle: (currentValue - minimumValue) / (maximumValue - minimumValue) * 2 * Math.PI
    property real angleOffset: Math.PI / 2

    property real _sweepDeg: root.angle * 180 / Math.PI
    property real _startDeg: root.angleOffset * 180 / Math.PI - 90

    Shape {
        id: trailEffect
        anchors.fill: parent
        visible: root._sweepDeg > 0

        ShapePath {
            strokeWidth: root.radius * 0.14
            strokeColor: "#f22900"
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: trailEffect.width / 2
                centerY: trailEffect.height / 2
                radiusX: root.radius * 0.92
                radiusY: root.radius * 0.92
                startAngle: root._startDeg
                sweepAngle: root._sweepDeg
            }
        }

        ShapePath {
            strokeWidth: root.radius * 0.06
            strokeColor: "#e96448"
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: trailEffect.width / 2
                centerY: trailEffect.height / 2
                radiusX: root.radius * 0.83
                radiusY: root.radius * 0.83
                startAngle: root._startDeg
                sweepAngle: root._sweepDeg
            }
        }
    }
}
