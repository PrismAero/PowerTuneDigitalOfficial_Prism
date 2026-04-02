import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

Item {
    id: root

    implicitHeight: content.implicitHeight

    function codeRows() {
        if (!PTExtenderCan)
            return [];
        return PTExtenderCan.filteredActiveCodeDetails();
    }

    ColumnLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: SettingsTheme.sectionSpacing

        SettingsSection {
            Layout.fillWidth: true
            title: "PT Extender Live Status"

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                Text {
                    color: SettingsTheme.textPrimary
                    text: "Gear: " + (PTExtenderCan.gear < 0 ? "N/?" : PTExtenderCan.gear)
                }

                Text {
                    color: SettingsTheme.textPrimary
                    text: "Active Codes: " + PTExtenderCan.filteredActiveCodeCount
                }

                Text {
                    color: SettingsTheme.textSecondary
                    text: "DFI Checksum Errors: " + PTExtenderCan.dfiChecksumErrors
                }
            }

            Repeater {
                model: root.codeRows()
                delegate: Text {
                    color: SettingsTheme.accent
                    text: "DFI " + modelData.code + ": " + modelData.description
                }
            }
        }

        SettingsSection {
            Layout.fillWidth: true
            title: "Config Sync"

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                StyledButton {
                    text: "Sync To Device"
                    onClicked: PTExtenderConfig.syncToDevice()
                }
                StyledButton {
                    text: "Sync From Device"
                    onClicked: PTExtenderConfig.syncFromDevice()
                }
                StyledButton {
                    text: "Save To EEPROM"
                    onClicked: PTExtenderConfig.saveToDeviceEeprom()
                }
            }
        }

        PTExtenderSystemSection { Layout.fillWidth: true }
        PTExtenderGpiSection { Layout.fillWidth: true }
        PTExtenderRelaySection { Layout.fillWidth: true }
        PTExtenderTimingSection { Layout.fillWidth: true }
        PTExtenderLedSection { Layout.fillWidth: true }
        PTExtenderIndicatorSection { Layout.fillWidth: true }
        PTExtenderDfiSection { Layout.fillWidth: true }
    }
}
