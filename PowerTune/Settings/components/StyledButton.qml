import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: root

    property bool primary: true
    property bool danger: false

    implicitWidth: Math.max(SettingsTheme.buttonMinWidth, contentItem.implicitWidth + 24)
    implicitHeight: SettingsTheme.controlHeight
    font.pixelSize: SettingsTheme.fontControl
    font.family: SettingsTheme.fontFamily
    font.weight: Font.DemiBold
    topPadding: 0
    bottomPadding: 0
    padding: 0

    contentItem: Text {
        text: root.text
        font: root.font
        opacity: root.enabled ? 1.0 : 0.5
        color: {
            if (root.danger) return SettingsTheme.textPrimary
            if (root.primary) return SettingsTheme.textPrimary
            return root.pressed ? SettingsTheme.textPrimary : SettingsTheme.accent
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: SettingsTheme.radiusSmall
        opacity: root.enabled ? 1.0 : 0.5

        color: {
            if (root.danger) {
                return root.pressed ? SettingsTheme.errorPressed : SettingsTheme.error
            }
            if (root.primary) {
                return root.pressed ? SettingsTheme.accentPressed : SettingsTheme.accent
            }
            return root.pressed ? SettingsTheme.surfacePressed : "transparent"
        }

        border.color: {
            if (root.danger) return "transparent"
            if (root.primary) return "transparent"
            return SettingsTheme.accent
        }
        border.width: root.primary ? 0 : SettingsTheme.borderWidth

        Behavior on color { ColorAnimation { duration: 100 } }
    }
}
