import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsPage {
    id: root

    property bool exEnabled: AppSettings.getValue("ui/exboard/enabled", true)
    property bool ptEnabled: AppSettings.getValue("ui/ptextender/enabled", true)

    Component.onCompleted: {
        exEnabled = AppSettings.getValue("ui/exboard/enabled", true);
        ptEnabled = AppSettings.getValue("ui/ptextender/enabled", true);
    }

    ScrollView {
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: SettingsTheme.sectionSpacing

            SettingsSection {
                Layout.fillWidth: true
                title: "Extender Modules"

                RowLayout {
                    Layout.fillWidth: true
                    spacing: SettingsTheme.controlGap

                    StyledSwitch {
                        checked: root.exEnabled
                        text: "EX Board Enabled"
                        onCheckedChanged: {
                            root.exEnabled = checked;
                            AppSettings.setValue("ui/exboard/enabled", checked);
                        }
                    }

                    StyledSwitch {
                        checked: root.ptEnabled
                        text: "PT Extender Enabled"
                        onCheckedChanged: {
                            root.ptEnabled = checked;
                            AppSettings.setValue("ui/ptextender/enabled", checked);
                        }
                    }
                }
            }

            ExBoardSection {
                Layout.fillWidth: true
                visible: root.exEnabled
            }

            PTExtenderConfigPage {
                Layout.fillWidth: true
                visible: root.ptEnabled
            }
        }
    }
}
