import QtQuick 2.15
import QtQuick.Controls 2.15

// * StyledTextField - Dark input with accent border on focus

TextField {
    id: root

    width: 280
    height: 44
    font.pixelSize: 20
    font.family: "Lato"
    color: "#FFFFFF"
    placeholderTextColor: "#707070"
    verticalAlignment: Text.AlignVCenter
    leftPadding: 12
    rightPadding: 12

    background: Rectangle {
        color: "#2D2D2D"
        radius: 8
        border.color: root.activeFocus ? "#009688" : (root.hovered ? "#505050" : "#3D3D3D")
        border.width: root.activeFocus ? 2 : 1

        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    // * Selection colors
    selectionColor: "#009688"
    selectedTextColor: "#FFFFFF"

    // * Cursor
    cursorDelegate: Rectangle {
        visible: root.cursorVisible
        color: "#009688"
        width: 2
    }
}
