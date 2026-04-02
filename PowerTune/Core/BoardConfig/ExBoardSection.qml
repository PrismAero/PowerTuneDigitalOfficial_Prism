import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property int activeTab: 0

    implicitHeight: content.implicitHeight

    ExBoardAnalog {
        id: content

        activeTab: root.activeTab
        width: root.width
    }
}
