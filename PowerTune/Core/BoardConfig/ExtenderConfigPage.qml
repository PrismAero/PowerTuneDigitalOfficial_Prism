import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import com.powertune 1.0
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

Rectangle {
    id: root

    property bool exEnabled: AppSettings.getValue("ui/exboard/enabled", true)
    property bool ptEnabled: AppSettings.getValue("ui/ptextender/enabled", true)

    property int activeGroup: ptEnabled ? 1 : 0
    property int exTabIndex: 0
    property int ptTabIndex: 0

    anchors.fill: parent
    color: SettingsTheme.background

    readonly property var exTabs: ["Analog", "Digital", "General"]
    readonly property var ptTabs: ["Status", "System", "GPI", "Relay", "Timing", "LEDs", "Indicators", "DFI"]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: configBannerCol.implicitHeight + 16
            color: "#33FF9800"
            visible: PTExtenderConfig.configModeActive

            ColumnLayout {
                id: configBannerCol
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        color: SettingsTheme.warning
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontSectionTitle
                        font.weight: Font.Bold
                        text: "CONFIG MODE ACTIVE"
                    }
                    Item { Layout.fillWidth: true }
                    StyledButton {
                        danger: true
                        text: "Save & Reboot"
                        onClicked: PTExtenderConfig.saveAndReboot()
                    }
                    StyledButton {
                        primary: false
                        text: "Exit Config Mode"
                        onClicked: PTExtenderConfig.exitConfigMode()
                    }
                }

                Text {
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: PTExtenderConfig.metadataLoaded
                          ? "Metadata loaded -- all menus populated from device"
                          : "Loading metadata from device..."
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: moduleRow.implicitHeight + 16
            color: SettingsTheme.surface

            RowLayout {
                id: moduleRow
                anchors.fill: parent
                anchors.margins: 8
                spacing: SettingsTheme.controlGap

                StyledSwitch {
                    checked: root.exEnabled
                    text: "EX Board Enabled"
                    onCheckedChanged: {
                        root.exEnabled = checked;
                        AppSettings.setValue("ui/exboard/enabled", checked);
                        if (!checked && root.activeGroup === 0 && root.ptEnabled)
                            root.activeGroup = 1;
                    }
                }
                StyledSwitch {
                    checked: root.ptEnabled
                    text: "PT Extender Enabled"
                    onCheckedChanged: {
                        root.ptEnabled = checked;
                        AppSettings.setValue("ui/ptextender/enabled", checked);
                        if (!checked && root.activeGroup === 1 && root.exEnabled)
                            root.activeGroup = 0;
                    }
                }
                Item { Layout.fillWidth: true }
                StyledButton {
                    text: "Enter Config Mode"
                    visible: !PTExtenderConfig.configModeActive && root.ptEnabled
                    onClicked: PTExtenderConfig.enterConfigMode()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: SettingsTheme.pageMargin
            Layout.rightMargin: SettingsTheme.pageMargin
            Layout.topMargin: SettingsTheme.pageMargin
            spacing: SettingsTheme.controlGap

            StyledTabGroupHeader {
                Layout.fillWidth: true
                groupActive: root.activeGroup === 0
                groupEnabled: root.exEnabled
                groupLabel: "EX Board"
                selectedIndex: root.exTabIndex
                tabLabels: root.exTabs
                visible: root.exEnabled

                onTabClicked: function (index) {
                    root.activeGroup = 0;
                    root.exTabIndex = index;
                }
            }

            StyledTabGroupHeader {
                Layout.fillWidth: true
                groupActive: root.activeGroup === 1
                groupEnabled: root.ptEnabled
                groupLabel: "PT Extender"
                selectedIndex: root.ptTabIndex
                tabLabels: root.ptTabs
                visible: root.ptEnabled

                onTabClicked: function (index) {
                    root.activeGroup = 1;
                    root.ptTabIndex = index;
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: SettingsTheme.pageMargin
            Layout.rightMargin: SettingsTheme.pageMargin
            Layout.bottomMargin: SettingsTheme.pageMargin
            border.color: SettingsTheme.accent
            border.width: SettingsTheme.borderWidth
            color: SettingsTheme.surface
            radius: SettingsTheme.radiusSmall

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: SettingsTheme.radiusSmall
                color: SettingsTheme.surface
            }

            ScrollView {
                anchors.fill: parent
                anchors.margins: SettingsTheme.sectionPadding
                clip: true
                contentWidth: availableWidth

                ColumnLayout {
                    width: parent.width
                    spacing: SettingsTheme.sectionSpacing

                    Loader {
                        Layout.fillWidth: true
                        active: root.activeGroup === 0
                        visible: active
                        sourceComponent: Component {
                            ExBoardSection {
                                activeTab: root.exTabIndex
                                width: parent ? parent.width : 0
                            }
                        }
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: root.activeGroup === 1 && root.ptTabIndex === 0
                        visible: active
                        sourceComponent: ptStatusComponent
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: root.activeGroup === 1 && root.ptTabIndex === 1
                        visible: active
                        sourceComponent: Component { PTExtenderSystemSection { Layout.fillWidth: true } }
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: root.activeGroup === 1 && root.ptTabIndex === 2
                        visible: active
                        sourceComponent: Component { PTExtenderGpiSection { Layout.fillWidth: true } }
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: root.activeGroup === 1 && root.ptTabIndex === 3
                        visible: active
                        sourceComponent: Component { PTExtenderRelaySection { Layout.fillWidth: true } }
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: root.activeGroup === 1 && root.ptTabIndex === 4
                        visible: active
                        sourceComponent: Component { PTExtenderTimingSection { Layout.fillWidth: true } }
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: root.activeGroup === 1 && root.ptTabIndex === 5
                        visible: active
                        sourceComponent: Component { PTExtenderLedSection { Layout.fillWidth: true } }
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: root.activeGroup === 1 && root.ptTabIndex === 6
                        visible: active
                        sourceComponent: Component { PTExtenderIndicatorSection { Layout.fillWidth: true } }
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: root.activeGroup === 1 && root.ptTabIndex === 7
                        visible: active
                        sourceComponent: Component { PTExtenderDfiSection { Layout.fillWidth: true } }
                    }
                }
            }
        }
    }

    Component {
        id: ptStatusComponent

        ColumnLayout {
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
                    model: PTExtenderCan ? PTExtenderCan.filteredActiveCodeDetails() : []
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
        }
    }
}
