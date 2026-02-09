import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// * SettingsRow - Label + control layout with consistent spacing

RowLayout {
    id: root

    property string label: ""
    property string description: ""
    property bool visible: true
    default property alias control: controlContainer.data

    Layout.fillWidth: true
    spacing: 20
    opacity: root.visible ? 1 : 0
    height: root.visible ? implicitHeight : 0

    Behavior on opacity { NumberAnimation { duration: 150 } }
    Behavior on height { NumberAnimation { duration: 150 } }

    ColumnLayout {
        Layout.preferredWidth: 280
        Layout.minimumWidth: 200
        spacing: 4

        Text {
            text: root.label
            font.pixelSize: 22
            font.family: "Lato"
            color: "#FFFFFF"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Text {
            visible: root.description !== ""
            text: root.description
            font.pixelSize: 16
            font.family: "Lato"
            color: "#B0B0B0"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
    }

    Item {
        id: controlContainer
        Layout.preferredWidth: 280
        Layout.preferredHeight: 44
    }
}
