import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target

    Text {
        text: "Labels"
        font.bold: true
        color: "white"
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && (root.target.labeltext !== undefined || root.target.desctextdisplaytext !== undefined)
        Label { text: "Label"; color: "white" }
        TextField {
            Layout.fillWidth: true
            text: root.target && root.target.labeltext !== undefined ? root.target.labeltext
                 : (root.target && root.target.desctextdisplaytext !== undefined ? root.target.desctextdisplaytext : "")
            onEditingFinished: {
                if (!root.target) return;
                if (root.target.labeltext !== undefined)
                    root.target.labeltext = text;
                else if (root.target.desctextdisplaytext !== undefined)
                    root.target.desctextdisplaytext = text;
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.unittext !== undefined
        Label { text: "Unit"; color: "white" }
        TextField {
            Layout.fillWidth: true
            text: root.target && root.target.unittext !== undefined ? root.target.unittext : ""
            onEditingFinished: { if (root.target) root.target.unittext = text; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.displaytext !== undefined
        Label { text: "Display"; color: "white" }
        TextField {
            Layout.fillWidth: true
            text: root.target && root.target.displaytext !== undefined ? root.target.displaytext : ""
            onEditingFinished: { if (root.target) root.target.displaytext = text; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.target && root.target.gaugename !== undefined
        Label { text: "Name"; color: "white" }
        TextField {
            Layout.fillWidth: true
            text: root.target && root.target.gaugename !== undefined ? root.target.gaugename : ""
            onEditingFinished: { if (root.target) root.target.gaugename = text; }
        }
    }
}
