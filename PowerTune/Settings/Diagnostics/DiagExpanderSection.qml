import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 0

    SettingsSection {
        id: extenderSection

        Layout.fillWidth: true
        collapsed: true
        collapsible: true
        title: "Extender Board"

        Timer {
            interval: 1000
            repeat: true
            running: !extenderSection.collapsed
            triggeredOnStart: true

            onTriggered: extenderDiagModel.refresh()
        }

        ListModel {
            id: extenderDiagModel

            function refresh() {
                clear();
                var data = Diagnostics.getExpanderBoardDiagnostics();
                for (var i = 0; i < data.length; i++)
                    append(data[i]);
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            Text {
                Layout.preferredWidth: 80
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
                text: "Raw (V)"
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Calibrated"
            }

            Text {
                Layout.preferredWidth: 60
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Unit"
            }

            Text {
                Layout.preferredWidth: 40
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "NTC"
            }
        }

        Repeater {
            model: extenderDiagModel

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.contentSpacing

                Text {
                    Layout.preferredWidth: 80
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.channel !== undefined ? model.channel : ""
                }

                Text {
                    Layout.preferredWidth: 80
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.rawVoltage !== undefined ? Number(model.rawVoltage).toFixed(3) : ""
                }

                Text {
                    Layout.fillWidth: true
                    color: SettingsTheme.success
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.DemiBold
                    text: model.calibratedValue !== undefined ? Number(model.calibratedValue).toFixed(3) : ""
                }

                Text {
                    Layout.preferredWidth: 60
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.unit !== undefined ? model.unit : ""
                }

                Text {
                    Layout.preferredWidth: 40
                    color: model.ntcEnabled ? SettingsTheme.accent : SettingsTheme.textDisabled
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.ntcEnabled ? "Yes" : "No"
                }
            }
        }
    }

    SettingsSection {
        id: ptExtenderSection

        Layout.fillWidth: true
        collapsed: true
        collapsible: true
        title: "PT Extender"

        Timer {
            interval: 1000
            repeat: true
            running: !ptExtenderSection.collapsed
            triggeredOnStart: true
            onTriggered: ptDiagModel.refresh()
        }

        ListModel {
            id: ptDiagModel
            function refresh() {
                clear();
                var data = Diagnostics.getPTExtenderDiagnostics();
                for (var i = 0; i < data.length; i++)
                    append(data[i]);
            }
        }

        Repeater {
            model: ptDiagModel

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.contentSpacing

                Text {
                    Layout.preferredWidth: 180
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
                    text: model.value !== undefined ? model.value : ""
                }
            }
        }
    }
}
