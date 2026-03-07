import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target
    property var fontBindings: []

    Text {
        text: "Fonts"
        font.bold: true
        color: "white"
    }

    Repeater {
        model: root.fontBindings
        delegate: ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            property var entry: modelData
            visible: root.target && entry && entry.fontProp && root.target[entry.fontProp] !== undefined

            Label {
                text: entry && entry.label ? entry.label : ""
                color: "white"
            }

            FontComboBox {
                Layout.fillWidth: true
                Component.onCompleted: {
                    if (root.target && entry && entry.fontProp)
                        selectByName(root.target[entry.fontProp]);
                }
                onCurrentTextChanged: {
                    if (root.target && entry && entry.fontProp)
                        root.target[entry.fontProp] = currentText;
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.target && entry && entry.sizeProp && root.target[entry.sizeProp] !== undefined
                Label { text: "Size"; color: "white" }
                NumericStepper {
                    Layout.fillWidth: true
                    value: root.target && entry && entry.sizeProp ? root.target[entry.sizeProp] : 0
                    stepSize: 1
                    minValue: 1
                    maxValue: 200
                    onValueChanged: function(v) {
                        if (root.target && entry && entry.sizeProp)
                            root.target[entry.sizeProp] = v;
                    }
                }
            }
        }
    }
}
