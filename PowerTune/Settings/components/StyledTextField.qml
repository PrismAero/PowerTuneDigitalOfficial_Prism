import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    id: root

    implicitWidth: Math.max(SettingsTheme.textFieldMinWidth, contentWidth + leftPadding + rightPadding + 20)
    implicitHeight: Math.max(SettingsTheme.controlHeight, font.pixelSize + topPadding + bottomPadding)
    font.pixelSize: SettingsTheme.fontControl
    font.family: SettingsTheme.fontFamily
    color: SettingsTheme.textPrimary
    placeholderTextColor: SettingsTheme.textPlaceholder
    verticalAlignment: Text.AlignVCenter
    leftPadding: 16
    rightPadding: 16
    topPadding: 12
    bottomPadding: 12

    background: Rectangle {
        color: SettingsTheme.controlBg
        radius: SettingsTheme.radiusSmall
        border.color: root.activeFocus ? SettingsTheme.accent : SettingsTheme.border
        border.width: root.activeFocus ? 2 : SettingsTheme.borderWidth

        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    selectionColor: SettingsTheme.accent
    selectedTextColor: SettingsTheme.textPrimary

    cursorDelegate: Rectangle {
        visible: root.cursorVisible
        color: SettingsTheme.accent
        width: 2
    }
}
