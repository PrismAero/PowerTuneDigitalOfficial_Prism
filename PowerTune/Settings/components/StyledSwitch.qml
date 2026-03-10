import QtQuick 2.15
import QtQuick.Controls 2.15

// * StyledSwitch - Dark themed toggle with accent color when on

Switch {
    id: root

    property string label: ""

    height: SettingsTheme.controlHeight
    font.pixelSize: SettingsTheme.fontControl
    font.family: SettingsTheme.fontFamily

    indicator: Rectangle {
        implicitWidth: SettingsTheme.switchTrackWidth
        implicitHeight: SettingsTheme.switchTrackHeight
        x: root.leftPadding
        y: parent.height / 2 - height / 2
        radius: SettingsTheme.switchTrackHeight / 2
        color: root.checked ? SettingsTheme.accent : SettingsTheme.controlBg
        border.color: root.checked ? SettingsTheme.accentPressed : SettingsTheme.border
        border.width: SettingsTheme.borderWidth

        Behavior on color { ColorAnimation { duration: 150 } }

        Rectangle {
            x: root.checked ? parent.width - width - 3 : 3
            y: (parent.height - height) / 2
            width: SettingsTheme.switchKnobSize
            height: SettingsTheme.switchKnobSize
            radius: SettingsTheme.switchKnobSize / 2
            color: SettingsTheme.textPrimary

            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        }
    }

    contentItem: Text {
        text: root.label !== "" ? root.label : root.text
        font: root.font
        opacity: root.enabled ? 1.0 : 0.5
        color: SettingsTheme.textPrimary
        verticalAlignment: Text.AlignVCenter
        leftPadding: root.indicator.width + 12
    }
}
