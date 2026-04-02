import QtQuick 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsSection {
    id: root
    title: "Relay Functions"

    ColumnLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.controlGap

        Repeater {
            model: 4
            delegate: RowLayout {
                Layout.fillWidth: true
                Text { text: "Relay " + (index + 1); color: SettingsTheme.textPrimary }
                StyledSpinBox {
                    Layout.preferredWidth: 160
                    from: 0
                    to: 255
                    value: AppSettings.getValue("ui/ptextender/relay/" + index + "/function", 0)
                    onValueChanged: AppSettings.setValue("ui/ptextender/relay/" + index + "/function", value)
                }
                StyledButton {
                    text: "Write"
                    onClicked: PTExtenderCan.setRelayFunction(index, AppSettings.getValue("ui/ptextender/relay/" + index + "/function", 0))
                }
            }
        }
    }
}
