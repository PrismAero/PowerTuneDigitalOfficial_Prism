import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// * SettingsSection - Card-style container for grouping related settings

Rectangle {
    id: root

    readonly property int _inset: SettingsTheme.sectionPadding + SettingsTheme.borderWidth
    property bool collapsed: false
    property bool collapsible: false
    default property alias content: contentColumn.data
    property string title: ""

    Layout.fillWidth: true
    border.color: SettingsTheme.border
    border.width: SettingsTheme.borderWidth
    color: SettingsTheme.surface
    implicitHeight: collapsed ? headerRow.height + (_inset * 2) : headerRow.height + contentColumn.height + (_inset
                                                                                                             * 2) + (SettingsTheme.contentSpacing
                                                                                                                     * 2)
    radius: SettingsTheme.radiusLarge

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root._inset
        spacing: SettingsTheme.contentSpacing

        RowLayout {
            id: headerRow

            Layout.fillWidth: true
            spacing: 8

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontSectionTitle
                font.weight: Font.Bold
                text: root.title
            }

            // * Collapse button (optional)
            Rectangle {
                color: collapseArea.pressed ? SettingsTheme.surfacePressed : "transparent"
                height: 32
                radius: 16
                visible: root.collapsible
                width: 32

                Text {
                    anchors.centerIn: parent
                    color: SettingsTheme.textSecondary
                    font.pixelSize: 14
                    text: root.collapsed ? "v" : "^"
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
            color: SettingsTheme.border
            height: SettingsTheme.borderWidth
            visible: !root.collapsed
        }

        ColumnLayout {
            id: contentColumn

            Layout.fillWidth: true
            opacity: root.collapsed ? 0 : 1
            spacing: SettingsTheme.contentSpacing
            visible: !root.collapsed

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }
    }
}
