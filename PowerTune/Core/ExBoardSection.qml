import QtQuick 2.15
import QtQuick.Layouts 1.15

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
