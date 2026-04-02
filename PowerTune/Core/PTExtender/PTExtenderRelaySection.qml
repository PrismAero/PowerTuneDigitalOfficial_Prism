import QtQuick
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsSection {
    id: root
    title: "Relay Functions"

    readonly property var functionNames: PTExtenderConfig.metadataLoaded ? PTExtenderConfig.relayFunctionNames() : []

    ColumnLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.controlGap

        Text {
            color: SettingsTheme.textSecondary
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontCaption
            text: root.functionNames.length === 0
                  ? "Enter config mode to load function names from device"
                  : "Function names loaded from device (" + root.functionNames.length + " options)"
        }

        Repeater {
            model: 4
            delegate: RowLayout {
                required property int index
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                Text {
                    Layout.preferredWidth: SettingsTheme.labelWidth
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    text: "Relay " + (index + 1)
                }

                StyledComboBox {
                    Layout.fillWidth: true
                    enabled: root.functionNames.length > 0
                    model: root.functionNames
                    currentIndex: AppSettings.getValue("ui/ptextender/relay/" + index + "/function", 0)
                    onActivated: AppSettings.setValue("ui/ptextender/relay/" + index + "/function", currentIndex)
                }

                StyledButton {
                    enabled: PTExtenderConfig.configModeActive
                    text: "Write"
                    onClicked: PTExtenderCan.setRelayFunction(index, AppSettings.getValue("ui/ptextender/relay/" + index + "/function", 0))
                }
            }
        }
    }
}
