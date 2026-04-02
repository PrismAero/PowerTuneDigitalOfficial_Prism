import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

Rectangle {
    id: widget

    property alias currentIndex: cbox.currentIndex
    property int index

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
        }
    }
}
