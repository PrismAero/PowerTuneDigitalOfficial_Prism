import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target

    Text {
        text: "Range"
        font.bold: true
        color: "white"
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.minvalue !== undefined
        Label { text: "Min"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root.target && root.target.minvalue !== undefined ? root.target.minvalue : 0
            stepSize: 1
            onValueChanged: { if (root.target) root.target.minvalue = value; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.maxvalue !== undefined
        Label { text: "Max"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root.target && root.target.maxvalue !== undefined ? root.target.maxvalue : 0
            stepSize: 10
            onValueChanged: { if (root.target) root.target.maxvalue = value; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.decimalpoints !== undefined
        Label { text: "Decimals"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root.target && root.target.decimalpoints !== undefined ? root.target.decimalpoints : 0
            stepSize: 1
            minValue: 0
            maxValue: 6
            onValueChanged: { if (root.target) root.target.decimalpoints = Math.round(value); }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.warnvaluehigh !== undefined
        Label { text: "Warn High"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root.target && root.target.warnvaluehigh !== undefined ? root.target.warnvaluehigh : 0
            stepSize: 100
            onValueChanged: { if (root.target) root.target.warnvaluehigh = value; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.warnvaluelow !== undefined
        Label { text: "Warn Low"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root.target && root.target.warnvaluelow !== undefined ? root.target.warnvaluelow : 0
            stepSize: 100
            onValueChanged: { if (root.target) root.target.warnvaluelow = value; }
        }
    }
}
