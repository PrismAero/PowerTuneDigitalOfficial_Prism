import QtQuick
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsSection {
    id: root
    title: "DFI Code Filters"

    readonly property var knownCodes: [
        11, 12, 13, 14, 15, 21, 23, 24, 25, 31, 32, 33, 34, 35,
        36, 39, 46, 51, 52, 53, 54, 56, 62, 63, 64, 67, 83
    ]

    ColumnLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.controlGap

        RowLayout {
            Layout.fillWidth: true
            StyledButton {
                text: "Suppress All"
                onClicked: PTExtenderConfig.suppressAllKnownCodes()
            }
            StyledButton {
                text: "Enable All"
                onClicked: PTExtenderConfig.enableAllCodes()
            }
        }

        Repeater {
            model: root.knownCodes
            delegate: RowLayout {
                Layout.fillWidth: true

                Text {
                    color: SettingsTheme.textPrimary
                    text: "DFI " + modelData + ": " + PTExtenderCan.dfiCodeDescription(modelData)
                }

                Item { Layout.fillWidth: true }

                StyledSwitch {
                    checked: !PTExtenderConfig.isCodeSuppressed(modelData)
                    text: checked ? "Enabled" : "Suppressed"
                    onCheckedChanged: {
                        if (checked)
                            PTExtenderConfig.unsuppressCode(modelData);
                        else
                            PTExtenderConfig.suppressCode(modelData);
                    }
                }
            }
        }
    }
}
