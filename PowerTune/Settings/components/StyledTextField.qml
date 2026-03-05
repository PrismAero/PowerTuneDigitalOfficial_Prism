import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    id: root

    implicitWidth: Math.max(120, contentWidth + leftPadding + rightPadding + 20)
    implicitHeight: Math.max(48, font.pixelSize + topPadding + bottomPadding)
    font.pixelSize: 22
    font.family: "Lato"
    color: "#FFFFFF"
    placeholderTextColor: "#707070"
    verticalAlignment: Text.AlignVCenter
    leftPadding: 16
    rightPadding: 16
    topPadding: 12
    bottomPadding: 12

    background: Rectangle {
        color: "#2D2D2D"
        radius: 8
        border.color: root.activeFocus ? "#009688" : (root.hovered ? "#505050" : "#3D3D3D")
        border.width: root.activeFocus ? 2 : 1

        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    selectionColor: "#009688"
    selectedTextColor: "#FFFFFF"

    cursorDelegate: Rectangle {
        visible: root.cursorVisible
        color: "#009688"
        width: 2
    }
}
