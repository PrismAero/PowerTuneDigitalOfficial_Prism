import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.UI 1.0

Rectangle {
    id: widget
    width: 250
    height: 120
    color: visible && UI.Visibledashes >= index ? SettingsTheme.surface : "transparent"
    radius: SettingsTheme.radiusLarge
    border.color: visible && UI.Visibledashes >= index ? SettingsTheme.border : "transparent"
    border.width: SettingsTheme.borderWidth
    visible: UI.Visibledashes >= index
    opacity: visible ? 1 : 0

    Behavior on opacity { NumberAnimation { duration: 200 } }

    property alias currentIndex: cbox.currentIndex
    property int index
    property var linkedLoader

    Connections {
        target: linkedLoader
        function onLoaded() {
            if (linkedLoader.item && linkedLoader.item.dashIndex !== undefined)
                linkedLoader.item.dashIndex = cbox.currentIndex;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SettingsTheme.sectionPadding
        spacing: SettingsTheme.contentSpacing
        visible: UI.Visibledashes >= index

        Text {
            text: "Dash " + index
            font.pixelSize: SettingsTheme.fontSectionTitle
            font.weight: Font.DemiBold
            font.family: SettingsTheme.fontFamily
            color: SettingsTheme.accent
        }

        StyledComboBox {
            id: cbox
            Layout.fillWidth: true
            Layout.preferredHeight: SettingsTheme.controlHeight
            font.pixelSize: SettingsTheme.fontControl
            model: [
                "User Dash 1", "User Dash 2", "User Dash 3",
                "Racedash", "CAN Monitor"
            ]

            onCurrentIndexChanged: {
                linkedLoader.source = dashselector.getDashByIndex(currentIndex)
                if (linkedLoader.item && linkedLoader.item.dashIndex !== undefined)
                    linkedLoader.item.dashIndex = currentIndex;
            }
            onVisibleChanged: {
                if (visible) {
                    linkedLoader.source = dashselector.getDashByIndex(currentIndex)
                    if (linkedLoader.item && linkedLoader.item.dashIndex !== undefined)
                        linkedLoader.item.dashIndex = currentIndex;
                }
            }
        }
    }
}
