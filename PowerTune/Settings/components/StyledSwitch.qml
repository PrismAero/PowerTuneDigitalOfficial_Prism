import QtQuick 2.15
import QtQuick.Controls 2.15

// * StyledSwitch - Dark themed toggle with accent color when on

Switch {
    id: root

    property string label: ""

    font.family: SettingsTheme.fontFamily
    font.pixelSize: SettingsTheme.fontControl
    height: SettingsTheme.controlHeight

    contentItem: Text {
        color: SettingsTheme.textPrimary
        font: root.font
        leftPadding: root.indicator.width + 12
        opacity: root.enabled ? 1.0 : 0.5
        text: root.label !== "" ? root.label : root.text
        verticalAlignment: Text.AlignVCenter
    }
    indicator: Rectangle {
        border.color: root.checked ? SettingsTheme.accentPressed : SettingsTheme.border
        border.width: SettingsTheme.borderWidth
        color: root.checked ? SettingsTheme.accent : SettingsTheme.controlBg
        implicitHeight: SettingsTheme.switchTrackHeight
        implicitWidth: SettingsTheme.switchTrackWidth
        radius: SettingsTheme.switchTrackHeight / 2
        x: root.leftPadding
        y: parent.height / 2 - height / 2

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        Rectangle {
            color: SettingsTheme.textPrimary
            height: SettingsTheme.switchKnobSize
            radius: SettingsTheme.switchKnobSize / 2
            width: SettingsTheme.switchKnobSize
            x: root.checked ? parent.width - width - 3 : 3
            y: (parent.height - height) / 2

            Behavior on x {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}
