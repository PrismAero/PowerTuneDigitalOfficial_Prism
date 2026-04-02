import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

SettingsSection {
    id: analogSection

    Layout.fillWidth: true
    collapsed: true
    collapsible: true
    title: "Analog Inputs"

    Timer {
        interval: 1000
        repeat: true
        running: !analogSection.collapsed
        triggeredOnStart: true

        onTriggered: analogDiagModel.refresh()
    }

    ListModel {
        id: analogDiagModel

        function refresh() {
            clear();
            var data = Diagnostics.getAnalogInputDiagnostics();
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
    }

    Repeater {
        model: analogDiagModel

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
        }
    }
}
