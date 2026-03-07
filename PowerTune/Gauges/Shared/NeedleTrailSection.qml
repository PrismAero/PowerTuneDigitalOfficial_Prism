import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target

    Text {
        text: "Needle Trail"
        font.bold: true
        color: "white"
    }

    Repeater {
        model: [
            { label: "Outer Trail", saveProp: "outerneedlecolortrailsave", liveProp: "outerneedlecolortrail" },
            { label: "Middle Trail", saveProp: "middleneedlecortrailsave", liveProp: "middleneedlecortrail" },
            { label: "Lower Trail", saveProp: "lowerneedlecolortrailsave", liveProp: "lowerneedlecolortrail" }
        ]
        delegate: RowLayout {
            Layout.fillWidth: true
            property var entry: modelData
            visible: root.target && entry && root.target[entry.saveProp] !== undefined

            Label { text: entry.label; color: "white" }

            ColorComboBox {
                Layout.fillWidth: true
                Component.onCompleted: {
                    if (root.target && entry)
                        selectByName(root.target[entry.saveProp]);
                }
                onCurrentIndexChanged: {
                    if (!root.target || !entry)
                        return;
                    var c = selectedColor();
                    if (c === "")
                        return;
                    root.target[entry.saveProp] = c;
                    if (root.target[entry.liveProp] !== undefined)
                        root.target[entry.liveProp] = c;
                }
            }
        }
    }
}
