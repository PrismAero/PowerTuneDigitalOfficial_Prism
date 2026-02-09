import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// * ConnectionStatusIndicator - Compact status display with color-coded states

Rectangle {
    id: root

    property string label: "Status"
    property string statusText: "Unknown"
    property string status: "unknown" // "connected", "disconnected", "pending", "unknown"

    width: 280
    height: 44
    radius: 8
    color: "#2D2D2D"
    border.color: {
        switch (root.status) {
            case "connected": return "#4CAF50"
            case "disconnected": return "#F44336"
            case "pending": return "#FF9800"
            default: return "#3D3D3D"
        }
    }
    border.width: 2

    Behavior on border.color { ColorAnimation { duration: 200 } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // * Status indicator dot
        Rectangle {
            width: 12
            height: 12
            radius: 6
            color: {
                switch (root.status) {
                    case "connected": return "#4CAF50"
                    case "disconnected": return "#F44336"
                    case "pending": return "#FF9800"
                    default: return "#707070"
                }
            }

            Behavior on color { ColorAnimation { duration: 200 } }

            // * Pulse animation for pending state
            SequentialAnimation on opacity {
                running: root.status === "pending"
                loops: Animation.Infinite
                NumberAnimation { to: 0.4; duration: 500 }
                NumberAnimation { to: 1.0; duration: 500 }
            }
        }

        Text {
            text: root.statusText
            font.pixelSize: 18
            font.family: "Lato"
            color: "#FFFFFF"
            Layout.fillWidth: true
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }
}
