import QtQuick
import QtQuick.Controls

Slider {
    id: root

    implicitHeight: SettingsTheme.controlHeight
    implicitWidth: 200

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: 6
        radius: 3
        color: SettingsTheme.controlBg
        border.color: SettingsTheme.border
        border.width: SettingsTheme.borderWidth

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: 3
            color: root.enabled ? SettingsTheme.accent : SettingsTheme.textDisabled
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: 20
        height: 20
        radius: 10
        color: root.pressed ? SettingsTheme.accentPressed : SettingsTheme.accent
        border.color: SettingsTheme.border
        border.width: SettingsTheme.borderWidth
        opacity: root.enabled ? 1.0 : 0.5

        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }
}
