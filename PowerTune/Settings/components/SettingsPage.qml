import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// * SettingsPage - Base container for all settings pages
// Provides dark background, scrollable content area, and consistent structure

Rectangle {
    id: root
    anchors.fill: parent
    color: theme.colorBackground

    // * Theme colors - consistent across all settings
    QtObject {
        id: theme
        readonly property color colorBackground: "#121212"
        readonly property color colorBackgroundSecondary: "#1E1E1E"
        readonly property color colorBackgroundTertiary: "#2D2D2D"
        readonly property color colorAccent: "#009688"
        readonly property color colorTextPrimary: "#FFFFFF"
        readonly property color colorTextSecondary: "#B0B0B0"
        readonly property color colorDivider: "#3D3D3D"
        readonly property color colorSuccess: "#4CAF50"
        readonly property color colorWarning: "#FF9800"
        readonly property color colorError: "#F44336"

        readonly property int fontHeader: 28
        readonly property int fontBody: 22
        readonly property int fontCaption: 16

        readonly property int buttonHeight: 48
        readonly property int controlHeight: 44
        readonly property int controlWidth: 280
        readonly property int sectionPadding: 16
        readonly property int rowSpacing: 12
        readonly property int sectionSpacing: 20
        readonly property int borderRadius: 8
    }

    default property alias content: contentColumn.data
    property alias theme: theme

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.margins: 16
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            id: contentColumn
            width: scrollView.width - 20
            spacing: theme.sectionSpacing
        }
    }
}
