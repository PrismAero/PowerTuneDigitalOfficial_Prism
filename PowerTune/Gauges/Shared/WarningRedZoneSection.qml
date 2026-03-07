import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target

    Text {
        text: "Red Zone"
        font.bold: true
        color: "white"
    }

    Repeater {
        model: [
            { label: "Inset", prop: "redareainset", step: 1 },
            { label: "Start", prop: "redareastart", step: 1 },
            { label: "Width", prop: "redareawidth", step: 1 }
        ]
        delegate: RowLayout {
            Layout.fillWidth: true
            property var entry: modelData
            visible: root.target && entry && root.target[entry.prop] !== undefined

            Label { text: entry.label; color: "white" }
            NumericStepper {
                Layout.fillWidth: true
                value: root.target && entry ? root.target[entry.prop] : 0
                stepSize: entry.step
                onValueChanged: function(v) { if (root.target && entry) root.target[entry.prop] = v; }
            }
        }
    }
}
