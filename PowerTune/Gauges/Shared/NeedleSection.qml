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
        text: "Needle"
        font.bold: true
        color: "white"
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root._has("needleColor") || root._has("needlecolor")
        Label { text: "Needle"; color: "white" }
        ColorComboBox {
            Layout.fillWidth: true
            Component.onCompleted: {
                if (root._has("needleColor")) selectByName(root.target.needleColor);
                else if (root._has("needlecolor")) selectByName(root.target.needlecolor);
            }
            onCurrentIndexChanged: {
                var c = selectedColor();
                if (c === "") return;
                if (root._has("needleColor")) root.target.needleColor = c;
                else if (root._has("needlecolor")) root.target.needlecolor = c;
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root._has("needleGlowColor") || root._has("needlecolor2")
        Label { text: "Glow"; color: "white" }
        ColorComboBox {
            Layout.fillWidth: true
            Component.onCompleted: {
                if (root._has("needleGlowColor")) selectByName(root.target.needleGlowColor);
                else if (root._has("needlecolor2")) selectByName(root.target.needlecolor2);
            }
            onCurrentIndexChanged: {
                var c = selectedColor();
                if (c === "") return;
                if (root._has("needleGlowColor")) root.target.needleGlowColor = c;
                else if (root._has("needlecolor2")) root.target.needlecolor2 = c;
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root._has("needleLength")
        Label { text: "Length"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root._has("needleLength") ? root.target.needleLength : 0
            stepSize: 1
            onValueChanged: function(v) { if (root.target) root.target.needleLength = v; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root._has("needleBaseWidth")
        Label { text: "Base Width"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root._has("needleBaseWidth") ? root.target.needleBaseWidth : 0
            stepSize: 1
            onValueChanged: function(v) { if (root.target) root.target.needleBaseWidth = v; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root._has("needleTipWidth")
        Label { text: "Tip Width"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root._has("needleTipWidth") ? root.target.needleTipWidth : 0
            stepSize: 1
            onValueChanged: function(v) { if (root.target) root.target.needleTipWidth = v; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root._has("needleinset")
        Label { text: "Inset"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root._has("needleinset") ? root.target.needleinset : 0
            stepSize: 1
            onValueChanged: function(v) { if (root.target) root.target.needleinset = v; }
        }
    }
}
