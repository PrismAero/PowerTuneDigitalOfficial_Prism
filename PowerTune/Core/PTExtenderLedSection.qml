import QtQuick 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsSection {
    title: "LED State"

    ColumnLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.controlGap

        Text {
            color: SettingsTheme.textSecondary
            text: "Live values from PT Extender"
        }

        Text { color: SettingsTheme.textPrimary; text: "System LED RGB: " + PTExtenderCan.systemLedR + ", " + PTExtenderCan.systemLedG + ", " + PTExtenderCan.systemLedB + " (pattern " + PTExtenderCan.systemLedPattern + ")" }
        Text { color: SettingsTheme.textPrimary; text: "Start/Stop LED RGB: " + PTExtenderCan.startStopLedR + ", " + PTExtenderCan.startStopLedG + ", " + PTExtenderCan.startStopLedB + " (pattern " + PTExtenderCan.startStopLedPattern + ")" }
    }
}
