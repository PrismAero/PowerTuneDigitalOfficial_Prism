import QtQuick 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsSection {
    title: "Indicators"

    ColumnLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.controlGap

        Text { color: SettingsTheme.textPrimary; text: "System Indicator Meta: " + PTExtenderCan.systemIndicatorMeta }
        Text { color: SettingsTheme.textPrimary; text: "System Channels: " + PTExtenderCan.systemIndicatorCh1 + ", " + PTExtenderCan.systemIndicatorCh2 + ", " + PTExtenderCan.systemIndicatorCh3 }
        Text { color: SettingsTheme.textPrimary; text: "Start/Stop Indicator Meta: " + PTExtenderCan.startStopIndicatorMeta }
        Text { color: SettingsTheme.textPrimary; text: "Start/Stop Channels: " + PTExtenderCan.startStopIndicatorCh1 + ", " + PTExtenderCan.startStopIndicatorCh2 + ", " + PTExtenderCan.startStopIndicatorCh3 }
    }
}
