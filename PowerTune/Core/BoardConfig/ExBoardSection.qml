import QtQuick
import QtQuick.Layouts

Item {
    id: root

    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth

    ExBoardAnalog {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
    }
}
