import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

SettingsSection {
    id: digitalSection

    Layout.fillWidth: true
    collapsed: true
    collapsible: true
    title: "Digital Inputs"

    Timer {
        interval: 1000
        repeat: true
        running: !digitalSection.collapsed
        triggeredOnStart: true

        onTriggered: digitalDiagModel.refresh()
    }

    ListModel {
        id: digitalDiagModel

        function refresh() {
            clear();
            var ecu = Diagnostics.getDigitalInputDiagnostics();
            for (var i = 0; i < ecu.length; i++)
                append(ecu[i]);
            var ext = Diagnostics.getExtenderDigitalDiagnostics();
            for (var j = 0; j < ext.length; j++)
                append(ext[j]);
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.contentSpacing

        Text {
            Layout.preferredWidth: 120
            color: SettingsTheme.accent
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontCaption
            font.weight: Font.DemiBold
            text: "Channel"
        }

        Text {
            Layout.preferredWidth: 80
            color: SettingsTheme.accent
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontCaption
            font.weight: Font.DemiBold
            text: "State"
        }

        Text {
            Layout.fillWidth: true
            color: SettingsTheme.accent
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontCaption
            font.weight: Font.DemiBold
            text: "Name"
        }
    }

    Repeater {
        model: digitalDiagModel

        delegate: RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            Text {
                Layout.preferredWidth: 120
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: model.channel !== undefined ? model.channel : ""
            }

            Rectangle {
                Layout.preferredHeight: 20
                Layout.preferredWidth: 80
                color: model.state ? SettingsTheme.success : SettingsTheme.textDisabled
                radius: 4

                Text {
                    anchors.centerIn: parent
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    text: model.state ? "ON" : "OFF"
                }
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: model.label !== undefined ? model.label : ""
            }
        }
    }
}
