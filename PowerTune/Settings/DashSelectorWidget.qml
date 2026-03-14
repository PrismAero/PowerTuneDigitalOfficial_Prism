import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.UI 1.0

Rectangle {
    id: widget

    property alias currentIndex: cbox.currentIndex
    property int index
    property var linkedLoader

    border.color: visible && UI.Visibledashes >= index ? SettingsTheme.border : "transparent"
    border.width: SettingsTheme.borderWidth
    color: visible && UI.Visibledashes >= index ? SettingsTheme.surface : "transparent"
    height: 120
    opacity: visible ? 1 : 0
    radius: SettingsTheme.radiusLarge
    visible: UI.Visibledashes >= index
    width: 250

    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }

    Connections {
        function onLoaded() {
            if (linkedLoader.item && linkedLoader.item.dashIndex !== undefined)
                linkedLoader.item.dashIndex = cbox.currentIndex;
        }

        target: linkedLoader
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SettingsTheme.sectionPadding
        spacing: SettingsTheme.contentSpacing
        visible: UI.Visibledashes >= index

        Text {
            color: SettingsTheme.accent
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontSectionTitle
            font.weight: Font.DemiBold
            text: "Dash " + index
        }

        StyledComboBox {
            id: cbox

            Layout.fillWidth: true
            Layout.preferredHeight: SettingsTheme.controlHeight
            font.pixelSize: SettingsTheme.fontControl
            model: ["Racedash"]

            onCurrentIndexChanged: {
                linkedLoader.source = dashselector.getDashByIndex(currentIndex);
                if (linkedLoader.item && linkedLoader.item.dashIndex !== undefined)
                    linkedLoader.item.dashIndex = currentIndex;
            }
            onVisibleChanged: {
                if (visible) {
                    linkedLoader.source = dashselector.getDashByIndex(currentIndex);
                    if (linkedLoader.item && linkedLoader.item.dashIndex !== undefined)
                        linkedLoader.item.dashIndex = currentIndex;
                }
            }
        }
    }
}
