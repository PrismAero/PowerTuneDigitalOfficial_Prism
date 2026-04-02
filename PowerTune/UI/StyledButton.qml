import QtQuick
import QtQuick.Controls

Button {
    id: root

    property bool danger: false
    property bool primary: true

    bottomPadding: 0
    font.family: SettingsTheme.fontFamily
    font.pixelSize: SettingsTheme.fontControl
    font.weight: Font.DemiBold
    implicitHeight: SettingsTheme.controlHeight
    implicitWidth: Math.max(SettingsTheme.buttonMinWidth, contentItem.implicitWidth + 24)
    padding: 0
    topPadding: 0

    background: Rectangle {
        border.color: {
            if (root.danger)
                return "transparent";
            if (root.primary)
                return "transparent";
            return SettingsTheme.accent;
        }
        border.width: root.primary ? 0 : SettingsTheme.borderWidth
        color: {
            if (root.danger) {
                return root.pressed ? SettingsTheme.errorPressed : SettingsTheme.error;
            }
            if (root.primary) {
                return root.pressed ? SettingsTheme.accentPressed : SettingsTheme.accent;
            }
            return root.pressed ? SettingsTheme.surfacePressed : "transparent";
        }
        opacity: root.enabled ? 1.0 : 0.5
        radius: SettingsTheme.radiusSmall

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }
    contentItem: Text {
        color: {
            if (root.danger)
                return SettingsTheme.textPrimary;
            if (root.primary)
                return SettingsTheme.textPrimary;
            return root.pressed ? SettingsTheme.textPrimary : SettingsTheme.accent;
        }
        elide: Text.ElideRight
        font: root.font
        horizontalAlignment: Text.AlignHCenter
        opacity: root.enabled ? 1.0 : 0.5
        text: root.text
        verticalAlignment: Text.AlignVCenter
    }
}
