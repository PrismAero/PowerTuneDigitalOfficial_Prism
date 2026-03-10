import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// * SettingsPage - Base container for all settings pages
// Provides dark background, scrollable content area, and consistent structure

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: SettingsTheme.background

    default property alias content: contentColumn.data

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.margins: SettingsTheme.pageMargin
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            id: contentColumn
            width: scrollView.width - 20
            spacing: SettingsTheme.sectionSpacing
        }
    }
}
