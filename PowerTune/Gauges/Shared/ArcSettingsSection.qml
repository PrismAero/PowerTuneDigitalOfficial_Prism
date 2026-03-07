import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target

    function _has(name) {
        return root.target && root.target[name] !== undefined;
    }

    Text {
        text: "Arc"
        font.bold: true
        color: "white"
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root._has("arcStartAngle") || root._has("startangle")
        Label { text: "Start"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root._has("arcStartAngle") ? root.target.arcStartAngle : (root._has("startangle") ? root.target.startangle : 0)
            stepSize: 1
            minValue: -360
            maxValue: 360
            onValueChanged: function(v) {
                if (!root.target) return;
                if (root._has("arcStartAngle")) root.target.arcStartAngle = v;
                else if (root._has("startangle")) root.target.startangle = v;
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root._has("arcEndAngle") || root._has("endangle")
        Label { text: "End"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root._has("arcEndAngle") ? root.target.arcEndAngle : (root._has("endangle") ? root.target.endangle : 0)
            stepSize: 1
            minValue: -360
            maxValue: 360
            onValueChanged: function(v) {
                if (!root.target) return;
                if (root._has("arcEndAngle")) root.target.arcEndAngle = v;
                else if (root._has("endangle")) root.target.endangle = v;
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root._has("arcStrokeWidth")
        Label { text: "Stroke"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root._has("arcStrokeWidth") ? root.target.arcStrokeWidth : 0
            stepSize: 1
            minValue: 1
            maxValue: 200
            onValueChanged: function(v) { if (root.target) root.target.arcStrokeWidth = v; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root._has("dangerThreshold") || root._has("dangerStart")
        Label { text: "Danger"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root._has("dangerThreshold") ? root.target.dangerThreshold : (root._has("dangerStart") ? root.target.dangerStart : 0.85)
            stepSize: 0.05
            minValue: 0
            maxValue: 1
            onValueChanged: function(v) {
                if (!root.target) return;
                if (root._has("dangerThreshold")) root.target.dangerThreshold = v;
                else if (root._has("dangerStart")) root.target.dangerStart = v;
            }
        }
    }
}
