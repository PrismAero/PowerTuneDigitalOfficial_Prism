import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// * SettingsSection - Card-style container for grouping related settings

Rectangle {
    id: root

    property string title: ""
    property bool collapsible: false
    property bool collapsed: false
    default property alias content: contentColumn.data

    Layout.fillWidth: true
    implicitHeight: collapsed ? headerRow.height + 24 : headerRow.height + contentColumn.height + 36
    color: "#1E1E2E"
    radius: 8
    border.color: "#2D2D4E"
    border.width: 1

    Behavior on implicitHeight {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            id: headerRow
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: root.title
                font.pixelSize: 18
                font.weight: Font.Bold
                font.family: "Lato"
                color: "#009688"
                Layout.fillWidth: true
            }

            // * Collapse button (optional)
            Rectangle {
                visible: root.collapsible
                width: 32
                height: 32
                radius: 16
                color: collapseArea.pressed ? "#3D3D3D" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: root.collapsed ? "▼" : "▲"
                    font.pixelSize: 14
                    color: "#B0B0B0"
                }

                MouseArea {
                    id: collapseArea
                    anchors.fill: parent
                    onClicked: root.collapsed = !root.collapsed
                }
            }
        }

        // * Divider line
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#3D3D3D"
            visible: !root.collapsed
        }

        ColumnLayout {
            id: contentColumn
            Layout.fillWidth: true
            spacing: 8
            visible: !root.collapsed
            opacity: root.collapsed ? 0 : 1

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }
    }
}
