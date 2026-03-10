import QtQuick 2.15
import QtQuick.Controls 2.15

// * StyledCheckBox - Dark themed checkbox with accent color when checked

CheckBox {
    id: root

    property string label: ""

    height: SettingsTheme.controlHeight
    font.pixelSize: SettingsTheme.fontControl
    font.family: SettingsTheme.fontFamily

    indicator: Rectangle {
        implicitWidth: SettingsTheme.checkBoxSize
        implicitHeight: SettingsTheme.checkBoxSize
        x: root.leftPadding
        y: parent.height / 2 - height / 2
        radius: SettingsTheme.radiusSmall
        color: root.checked ? SettingsTheme.accent : SettingsTheme.controlBg
        border.color: root.checked ? SettingsTheme.accentPressed : SettingsTheme.border
        border.width: root.checked ? 2 : SettingsTheme.borderWidth

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        // * Checkmark icon drawn with two rotated rectangles
        Item {
            anchors.centerIn: parent
            width: 16
            height: 16
            opacity: root.checked ? 1.0 : 0.0

            Behavior on opacity { NumberAnimation { duration: 150 } }

            // * Short leg of checkmark
            Rectangle {
                x: 1
                y: 8
                width: 7
                height: 2.5
                radius: 1
                color: SettingsTheme.textPrimary
                rotation: 45
                transformOrigin: Item.Left
            }

            // * Long leg of checkmark
            Rectangle {
                x: 5
                y: 11
                width: 12
                height: 2.5
                radius: 1
                color: SettingsTheme.textPrimary
                rotation: -45
                transformOrigin: Item.Left
            }
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
