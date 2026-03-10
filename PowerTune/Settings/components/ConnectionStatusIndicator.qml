import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// * ConnectionStatusIndicator - Compact status display with color-coded states

Rectangle {
    id: root

    property string label: "Status"
    property string statusText: "Unknown"
    property string status: "unknown" // "connected", "disconnected", "pending", "unknown"

    implicitWidth: 200
    implicitHeight: SettingsTheme.controlHeight
    radius: SettingsTheme.radiusSmall
    color: SettingsTheme.controlBg
    border.color: {
        switch (root.status) {
            case "connected": return SettingsTheme.success
            case "disconnected": return SettingsTheme.error
            case "pending": return SettingsTheme.warning
            default: return SettingsTheme.border
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
            width: SettingsTheme.statusDotSize
            height: SettingsTheme.statusDotSize
            radius: SettingsTheme.statusDotSize / 2
            color: {
                switch (root.status) {
                    case "connected": return SettingsTheme.success
                    case "disconnected": return SettingsTheme.error
                    case "pending": return SettingsTheme.warning
                    default: return SettingsTheme.textPlaceholder
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
            font.pixelSize: SettingsTheme.fontControl
            font.family: SettingsTheme.fontFamily
            color: SettingsTheme.textPrimary
            Layout.fillWidth: true
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }
}
