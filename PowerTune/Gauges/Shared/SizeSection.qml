import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target

    Text {
        text: "Size"
        font.bold: true
        color: "white"
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.width !== undefined
        Label { text: "Width"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root.target && root.target.width !== undefined ? root.target.width : 0
            stepSize: 10
            minValue: 20
            maxValue: 2000
            onValueChanged: { if (root.target) root.target.width = value; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.height !== undefined
        Label { text: "Height"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root.target && root.target.height !== undefined ? root.target.height : 0
            stepSize: 10
            minValue: 20
            maxValue: 2000
            onValueChanged: { if (root.target) root.target.height = value; }
        }
    }
}
