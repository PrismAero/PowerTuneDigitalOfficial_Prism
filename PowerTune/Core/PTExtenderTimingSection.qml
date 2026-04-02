import QtQuick 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsSection {
    id: root
    title: "Timing"

    readonly property var timingKeys: [
        { key: "crankDuration", label: "Crank Duration (ms)" },
        { key: "runningProofTime", label: "Running Proof Time (ms)" },
        { key: "maxCrankTime", label: "Max Crank Time (ms)" },
        { key: "maxStartTime", label: "Max Start Time (ms)" }
    ]

    ColumnLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.controlGap

        Repeater {
            model: root.timingKeys
            delegate: RowLayout {
                Layout.fillWidth: true

                Text {
                    text: modelData.label
                    color: SettingsTheme.textPrimary
                }

                StyledSpinBox {
                    Layout.preferredWidth: 180
                    from: 0
                    to: 65535
                    value: AppSettings.getValue("ui/ptextender/timing/" + modelData.key, 1000)
                    onValueChanged: AppSettings.setValue("ui/ptextender/timing/" + modelData.key, value)
                }
            }
        }
    }
}
