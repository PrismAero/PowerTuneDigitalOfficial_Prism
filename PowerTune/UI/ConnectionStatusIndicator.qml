import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// * ConnectionStatusIndicator - Compact status display with color-coded states

Rectangle {
    id: root

    property string label: "Status"
    property string status: "unknown" // "connected", "disconnected", "pending", "unknown"

    property string statusText: "Unknown"

    border.color: {
        switch (root.status) {
        case "connected":
            return SettingsTheme.success;
        case "disconnected":
            return SettingsTheme.error;
        case "pending":
            return SettingsTheme.warning;
        default:
            return SettingsTheme.border;
        }
    }
    border.width: 2
    color: SettingsTheme.controlBg
    implicitHeight: SettingsTheme.controlHeight
    implicitWidth: 200
    radius: SettingsTheme.radiusSmall

    Behavior on border.color {
        ColorAnimation {
            duration: 200
        }
    }

    RowLayout {
        anchors.bottomMargin: 0
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 0
        spacing: 8

        // * Status indicator dot
        Rectangle {
            color: {
                switch (root.status) {
                case "connected":
                    return SettingsTheme.success;
                case "disconnected":
                    return SettingsTheme.error;
                case "pending":
                    return SettingsTheme.warning;
                default:
                    return SettingsTheme.textPlaceholder;
                }
            }
            height: SettingsTheme.statusDotSize
            radius: SettingsTheme.statusDotSize / 2
            width: SettingsTheme.statusDotSize

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            // * Pulse animation for pending state
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: root.status === "pending"

                NumberAnimation {
                    duration: 500
                    to: 0.4
                }

                NumberAnimation {
                    duration: 500
                    to: 1.0
                }
            }
        }

        Text {
            Layout.fillWidth: true
            color: SettingsTheme.textPrimary
            elide: Text.ElideRight
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontControl
            text: root.statusText
            verticalAlignment: Text.AlignVCenter
        }
    }
}
