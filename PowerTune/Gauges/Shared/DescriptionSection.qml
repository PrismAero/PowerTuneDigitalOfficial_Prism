import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target

    Text {
        text: "Description"
        font.bold: true
        color: "white"
    }

    Repeater {
        model: [
            { label: "X", prop: "desctextx" },
            { label: "Y", prop: "desctexty" },
            { label: "Size", prop: "desctextfontsize" }
        ]
        delegate: RowLayout {
            Layout.fillWidth: true
            property var entry: modelData
            visible: root.target && entry && root.target[entry.prop] !== undefined

            Label { text: entry.label; color: "white" }
            NumericStepper {
                Layout.fillWidth: true
                value: root.target && entry ? root.target[entry.prop] : 0
                stepSize: 1
                onValueChanged: function(v) { if (root.target && entry) root.target[entry.prop] = v; }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.desctextfonttype !== undefined
        Label { text: "Font"; color: "white" }
        FontComboBox {
            Layout.fillWidth: true
            Component.onCompleted: { if (root.target) selectByName(root.target.desctextfonttype); }
            onCurrentTextChanged: { if (root.target) root.target.desctextfonttype = currentText; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.desctextdisplaytextcolor !== undefined
        Label { text: "Color"; color: "white" }
        ColorComboBox {
            Layout.fillWidth: true
            Component.onCompleted: { if (root.target) selectByName(root.target.desctextdisplaytextcolor); }
            onCurrentIndexChanged: {
                if (!root.target) return;
                var c = selectedColor();
                if (c !== "")
                    root.target.desctextdisplaytextcolor = c;
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.desctextdisplaytext !== undefined
        Label { text: "Text"; color: "white" }
        TextField {
            Layout.fillWidth: true
            text: root.target && root.target.desctextdisplaytext !== undefined ? root.target.desctextdisplaytext : ""
            onEditingFinished: { if (root.target) root.target.desctextdisplaytext = text; }
        }
    }
}
