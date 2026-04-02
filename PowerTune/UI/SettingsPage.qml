import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// * SettingsPage - Base container for all settings pages
// Provides dark background, scrollable content area, and consistent structure

Rectangle {
    id: root

    default property alias content: contentColumn.data

    Layout.fillHeight: true
    Layout.fillWidth: true
    color: SettingsTheme.background

    ScrollView {
        id: scrollView

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        anchors.fill: parent
        anchors.topMargin: SettingsTheme.pageMargin
        anchors.bottomMargin: SettingsTheme.pageMargin
        anchors.leftMargin: 40
        anchors.rightMargin: 40
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            id: contentColumn

            spacing: SettingsTheme.sectionSpacing
            width: scrollView.contentWidth
        }
    }
}
