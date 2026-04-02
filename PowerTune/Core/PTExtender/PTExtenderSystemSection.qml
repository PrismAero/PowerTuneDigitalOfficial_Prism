import QtQuick
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsSection {
    id: root
    title: "System"

    ColumnLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.controlGap

        RowLayout {
            Layout.fillWidth: true

            Text { text: "Device Name"; color: SettingsTheme.textPrimary }
            StyledTextField {
                Layout.fillWidth: true
                text: AppSettings.getValue("ui/ptextender/system/deviceName", "PTExtender")
                onEditingFinished: AppSettings.setValue("ui/ptextender/system/deviceName", text)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Faults Enabled"; color: SettingsTheme.textPrimary }
            StyledSwitch {
                checked: AppSettings.getValue("ui/ptextender/system/faultEnable", true)
                onCheckedChanged: AppSettings.setValue("ui/ptextender/system/faultEnable", checked)
            }
        }
    }
}
