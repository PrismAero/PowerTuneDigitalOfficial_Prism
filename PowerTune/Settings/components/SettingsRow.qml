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
    spacing: SettingsTheme.controlGap
    opacity: root.visible ? 1 : 0
    height: root.visible ? implicitHeight : 0

    Behavior on opacity { NumberAnimation { duration: 150 } }
    Behavior on height { NumberAnimation { duration: 150 } }

    ColumnLayout {
        Layout.preferredWidth: SettingsTheme.labelWidth
        Layout.minimumWidth: SettingsTheme.labelWidth
        spacing: 4

        Text {
            text: root.label
            font.pixelSize: SettingsTheme.fontLabel
            font.family: SettingsTheme.fontFamily
            color: SettingsTheme.textPrimary
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Text {
            visible: root.description !== ""
            text: root.description
            font.pixelSize: SettingsTheme.fontStatus
            font.family: SettingsTheme.fontFamily
            color: SettingsTheme.textSecondary
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
    }

    Item {
        id: controlContainer
        Layout.preferredWidth: 280
        Layout.preferredHeight: SettingsTheme.controlHeight
    }
}
