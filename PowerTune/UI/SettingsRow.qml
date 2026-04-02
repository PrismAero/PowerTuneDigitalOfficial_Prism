import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// * SettingsRow - Label + control layout with consistent spacing

RowLayout {
    id: root

    default property alias control: controlContainer.data
    property string description: ""
    property string label: ""

    Layout.fillWidth: true
    height: root.visible ? implicitHeight : 0
    opacity: root.visible ? 1 : 0
    spacing: SettingsTheme.controlGap

    Behavior on height {
        NumberAnimation {
            duration: 5
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: 150
        }
    }

    ColumnLayout {
        Layout.minimumWidth: SettingsTheme.labelWidth
        Layout.preferredWidth: SettingsTheme.labelWidth
        spacing: 4

        Text {
            Layout.fillWidth: true
            color: SettingsTheme.textPrimary
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontLabel
            text: root.label
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.fillWidth: true
            color: SettingsTheme.textSecondary
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontStatus
            text: root.description
            visible: root.description !== ""
            wrapMode: Text.WordWrap
        }
    }

    Item {
        id: controlContainer

        Layout.minimumHeight: SettingsTheme.controlHeight
        Layout.preferredHeight: childrenRect.height > 0 ? childrenRect.height : SettingsTheme.controlHeight
        Layout.preferredWidth: 280
    }

    // Trailing spacer absorbs excess width so label + control stay left-aligned
    Item {
        Layout.fillWidth: true
    }
}
