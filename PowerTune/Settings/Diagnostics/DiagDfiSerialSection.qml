import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Core 1.0
import PowerTune.UI 1.0

SettingsSection {
    id: dfiSection

    Layout.fillWidth: true
    collapsed: true
    collapsible: true
    title: "DFI Serial"

    Timer {
        interval: 1000
        repeat: true
        running: !dfiSection.collapsed
        triggeredOnStart: true
        onTriggered: dfiDiagModel.refresh()
    }

    ListModel {
        id: dfiDiagModel

        function refresh() {
            clear();
            var data = Diagnostics.getDfiSerialDiagnostics();
            for (var i = 0; i < data.length; i++)
                append(data[i]);
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.contentSpacing

        Text {
            Layout.preferredWidth: 160
            color: SettingsTheme.accent
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontCaption
            font.weight: Font.DemiBold
            text: "Parameter"
        }

        Text {
            Layout.fillWidth: true
            color: SettingsTheme.accent
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontCaption
            font.weight: Font.DemiBold
            text: "Value"
        }
    }

    Repeater {
        model: dfiDiagModel

        delegate: RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            Text {
                Layout.preferredWidth: 160
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: model.key !== undefined ? model.key : ""
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamilyMono
                font.pixelSize: SettingsTheme.fontCaption
                text: model.value !== undefined ? String(model.value) : ""
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.controlGap

        StyledButton {
            primary: false
            text: "DFI Code Filters"
            onClicked: dfiFilterPopupDiag.open()
        }
    }

    DfiCodeFilterPopup {
        id: dfiFilterPopupDiag
    }
}
