import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target
    property var toggleBindings: []

    Text {
        text: "Visibility"
        font.bold: true
        color: "white"
    }

    Repeater {
        model: root.toggleBindings
        delegate: RowLayout {
            Layout.fillWidth: true
            property var entry: modelData
            visible: root.target && entry && entry.prop && root.target[entry.prop] !== undefined

            Label {
                text: entry && entry.label ? entry.label : ""
                color: "white"
            }

            Switch {
                checked: root.target && entry && entry.prop ? !!root.target[entry.prop] : false
                onToggled: {
                    if (root.target && entry && entry.prop)
                        root.target[entry.prop] = checked;
                }
            }
        }
    }
}
