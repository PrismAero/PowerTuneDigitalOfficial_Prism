import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target
    property var colorBindings: []

    Text {
        text: "Colors"
        font.bold: true
        color: "white"
    }

    Repeater {
        model: root.colorBindings
        delegate: RowLayout {
            Layout.fillWidth: true
            property var entry: modelData
            visible: root.target && entry && entry.prop && root.target[entry.prop] !== undefined

            Label {
                text: entry && entry.label ? entry.label : ""
                color: "white"
            }

            ColorComboBox {
                id: colorBox
                Layout.fillWidth: true
                Component.onCompleted: {
                    if (root.target && entry && entry.prop)
                        selectByName(root.target[entry.prop]);
                }
                onCurrentIndexChanged: {
                    if (!root.target || !entry || !entry.prop)
                        return;
                    var c = selectedColor();
                    if (c !== "")
                        root.target[entry.prop] = c;
                }
            }
        }
    }
}
