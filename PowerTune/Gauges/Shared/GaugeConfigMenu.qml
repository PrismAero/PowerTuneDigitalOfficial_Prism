import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "darkgrey"
    z: 200
    visible: false
    width: 280
    height: Math.min(contentColumn.implicitHeight + 20, maxHeight)

    property Item target
    property int maxHeight: 600

    default property alias content: contentColumn.data

    signal deleteRequested
    signal closed

    Drag.active: true

    MouseArea {
        anchors.fill: parent
        drag.target: root
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: 10
        contentHeight: contentColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        ColumnLayout {
            id: contentColumn
            width: flickable.width
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Button {
                    text: "Delete"
                    Layout.fillWidth: true
                    onClicked: {
                        root.visible = false;
                        root.deleteRequested();
                    }
                }

                Button {
                    text: "Close"
                    Layout.fillWidth: true
                    highlighted: true
                    onClicked: {
                        root.visible = false;
                        root.closed();
                    }
                }
            }
        }
    }

    function show(mx, my) {
        if (target) {
            x = mx;
            y = my;
        }
        visible = true;
    }
}
