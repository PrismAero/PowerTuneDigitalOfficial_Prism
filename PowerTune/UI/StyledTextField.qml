import QtQuick
import QtQuick.Controls

TextField {
    id: root

    bottomPadding: 4
    color: SettingsTheme.textPrimary
    font.family: SettingsTheme.fontFamily
    font.pixelSize: SettingsTheme.fontControl
    implicitHeight: SettingsTheme.controlHeight
    implicitWidth: Math.max(SettingsTheme.textFieldMinWidth, contentWidth + leftPadding + rightPadding + 20)
    leftPadding: 12
    placeholderTextColor: SettingsTheme.textPlaceholder
    rightPadding: 12
    selectedTextColor: SettingsTheme.textPrimary
    selectionColor: SettingsTheme.accent
    topPadding: 4
    verticalAlignment: TextInput.AlignVCenter

    background: Rectangle {
        border.color: root.activeFocus ? SettingsTheme.accent : SettingsTheme.border
        border.width: root.activeFocus ? 2 : SettingsTheme.borderWidth
        color: SettingsTheme.controlBg
        radius: SettingsTheme.radiusSmall

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
    }
    cursorDelegate: Rectangle {
        color: SettingsTheme.accent
        visible: root.cursorVisible
        width: 2
    }
}
