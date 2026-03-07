import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target
    property var options: ["None", "deg", "degC", "%", "degF", "kPa", "PSI", "ms", "V", "mV", "lambda", "kph", "mph"]

    Text {
        text: "Unit Symbol"
        font.bold: true
        color: "white"
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 4
        columnSpacing: 4
        rowSpacing: 4

        Repeater {
            model: root.options
            delegate: Button {
                text: modelData
                checkable: true
                checked: {
                    if (!root.target || root.target.mainunit === undefined)
                        return false;
                    return root.target.mainunit === (modelData === "None" ? "" : modelData);
                }
                onClicked: {
                    if (!root.target || root.target.mainunit === undefined)
                        return;
                    root.target.mainunit = (modelData === "None" ? "" : modelData);
                }
            }
        }
    }
}
