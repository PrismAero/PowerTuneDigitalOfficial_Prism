import QtQuick
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsSection {
    id: root
    title: "GPI Functions"

    ColumnLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.controlGap

        Repeater {
            model: 4
            delegate: RowLayout {
                Layout.fillWidth: true
                Text { text: "GPI " + (index + 1); color: SettingsTheme.textPrimary }
                StyledSpinBox {
                    Layout.preferredWidth: 160
                    from: 0
                    to: 255
                    value: AppSettings.getValue("ui/ptextender/gpi/" + index + "/function", 0)
                    onValueChanged: AppSettings.setValue("ui/ptextender/gpi/" + index + "/function", value)
                }
                StyledButton {
                    text: "Write"
                    onClicked: PTExtenderCan.setGpiFunction(index, AppSettings.getValue("ui/ptextender/gpi/" + index + "/function", 0))
                }
            }
        }
    }
}
