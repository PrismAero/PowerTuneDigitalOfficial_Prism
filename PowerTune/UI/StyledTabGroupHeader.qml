import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string groupLabel: ""
    property var tabLabels: []
    property int selectedIndex: 0
    property bool groupActive: false
    property bool groupEnabled: true

    signal tabClicked(int index)

    implicitHeight: labelText.implicitHeight + 6 + tabRow.height

    Text {
        id: labelText

        anchors.left: parent.left
        anchors.leftMargin: 6
        color: root.groupActive ? SettingsTheme.accent : SettingsTheme.textSecondary
        font.family: SettingsTheme.fontFamily
        font.pixelSize: SettingsTheme.fontCaption
        font.weight: Font.Bold
        opacity: root.groupEnabled ? 1.0 : 0.4
        text: root.groupLabel
    }

    Row {
        id: tabRow

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: labelText.bottom
        anchors.topMargin: 6
        height: SettingsTheme.tabBarHeight
        spacing: 2

        Repeater {
            model: root.tabLabels

            delegate: Item {
                id: tabDelegate

                required property int index
                required property string modelData

                readonly property bool isActive: root.groupActive && root.selectedIndex === index

                clip: true
                height: tabRow.height
                width: (tabRow.width - (root.tabLabels.length - 1) * tabRow.spacing) / root.tabLabels.length

                Rectangle {
                    width: parent.width
                    height: parent.height + SettingsTheme.radiusSmall
                    radius: SettingsTheme.radiusSmall
                    color: tabDelegate.isActive ? SettingsTheme.surface
                         : tabArea.pressed ? SettingsTheme.surfacePressed
                         : SettingsTheme.controlBg
                    border.color: tabDelegate.isActive ? SettingsTheme.accent : SettingsTheme.border
                    border.width: SettingsTheme.borderWidth
                    opacity: root.groupEnabled ? 1.0 : 0.4
                }

                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: 3
                    color: SettingsTheme.accent
                    visible: tabDelegate.isActive
                }

                Text {
                    anchors.centerIn: parent
                    color: tabDelegate.isActive ? SettingsTheme.textPrimary
                         : root.groupEnabled ? SettingsTheme.textSecondary
                         : SettingsTheme.textDisabled
                    elide: Text.ElideRight
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontTab
                    font.weight: tabDelegate.isActive ? Font.DemiBold : Font.Normal
                    horizontalAlignment: Text.AlignHCenter
                    text: tabDelegate.modelData
                    width: parent.width - 8
                }

                MouseArea {
                    id: tabArea

                    anchors.fill: parent
                    enabled: root.groupEnabled
                    onClicked: root.tabClicked(index)
                }
            }
        }
    }
}
