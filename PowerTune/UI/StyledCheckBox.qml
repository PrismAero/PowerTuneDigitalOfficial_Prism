import QtQuick 2.15
import QtQuick.Controls 2.15

// * StyledCheckBox - Dark themed checkbox with accent color when checked

CheckBox {
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
        border.width: root.checked ? 2 : SettingsTheme.borderWidth
        color: root.checked ? SettingsTheme.accent : SettingsTheme.controlBg
        implicitHeight: SettingsTheme.checkBoxSize
        implicitWidth: SettingsTheme.checkBoxSize
        radius: SettingsTheme.radiusSmall
        x: root.leftPadding
        y: parent.height / 2 - height / 2

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        // * Checkmark icon drawn with two rotated rectangles
        Item {
            anchors.centerIn: parent
            height: 20
            opacity: root.checked ? 1.0 : 0.0
            width: 20

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            // * Short leg of checkmark
            Rectangle {
                color: SettingsTheme.textPrimary
                height: 3
                radius: 1
                rotation: 45
                transformOrigin: Item.Left
                width: 9
                x: 1
                y: 10
            }

            // * Long leg of checkmark
            Rectangle {
                color: SettingsTheme.textPrimary
                height: 3
                radius: 1
                rotation: -45
                transformOrigin: Item.Left
                width: 15
                x: 6
                y: 14
            }
        }
    }
}
