import QtQuick 2.15
import QtQuick.Controls 2.15

// * StyledButton - Primary and secondary button variants

Button {
    id: root

    property bool primary: true
    property bool danger: false

    width: 280
    height: 48
    font.pixelSize: 20
    font.family: "Lato"
    font.weight: Font.DemiBold

    contentItem: Text {
        text: root.text
        font: root.font
        opacity: root.enabled ? 1.0 : 0.5
        color: {
            if (root.danger) return "#FFFFFF"
            if (root.primary) return "#FFFFFF"
            return root.pressed ? "#FFFFFF" : "#009688"
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: 8
        opacity: root.enabled ? 1.0 : 0.5

        color: {
            if (root.danger) {
                return root.pressed ? "#C62828" : (root.hovered ? "#E53935" : "#F44336")
            }
            if (root.primary) {
                return root.pressed ? "#00796B" : (root.hovered ? "#00897B" : "#009688")
            }
            return root.pressed ? "#009688" : "transparent"
        }

        border.color: {
            if (root.danger) return "transparent"
            if (root.primary) return "transparent"
            return root.hovered ? "#00897B" : "#009688"
        }
        border.width: root.primary ? 0 : 2

        Behavior on color { ColorAnimation { duration: 100 } }
    }
}
