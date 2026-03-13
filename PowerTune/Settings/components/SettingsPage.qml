import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
        anchors.margins: SettingsTheme.pageMargin
        clip: true

        ColumnLayout {
            id: contentColumn

            spacing: SettingsTheme.sectionSpacing
            width: scrollView.availableWidth
        }
    }
}
