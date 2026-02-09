import QtQuick 2.15
import QtQuick.Controls 2.15

// * StyledSwitch - Dark themed toggle with accent color when on

Switch {
    id: root

    property string label: ""

    height: 44
    font.pixelSize: 20
    font.family: "Lato"

    indicator: Rectangle {
        implicitWidth: 56
        implicitHeight: 28
        x: root.leftPadding
        y: parent.height / 2 - height / 2
        radius: 14
        color: root.checked ? "#009688" : "#3D3D3D"
        border.color: root.checked ? "#00796B" : "#505050"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }

        Rectangle {
            x: root.checked ? parent.width - width - 4 : 4
            y: 4
            width: 20
            height: 20
            radius: 10
            color: "#FFFFFF"

            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        }
    }

    contentItem: Text {
        text: root.label !== "" ? root.label : root.text
        font: root.font
        opacity: root.enabled ? 1.0 : 0.5
        color: "#FFFFFF"
        verticalAlignment: Text.AlignVCenter
        leftPadding: root.indicator.width + 12
    }
}
