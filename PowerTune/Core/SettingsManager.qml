import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import DLM 1.0
import PowerTune.Core 1.0
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: tabView
    anchors.fill: parent
    color: SettingsTheme.background

    property int lastdashamount
    property int currentIndex: tabBar.currentIndex

    DLM {
        id: downloadManager
    }

    ListModel {
        id: tabModel
        ListElement { title: "Main" }
        ListElement { title: "Dash Sel." }
        ListElement { title: "Vehicle / RPM" }
        ListElement { title: "EX Board" }
        ListElement { title: "Network" }
        ListElement { title: "Diagnostics" }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: SettingsTheme.tabBarHeight
            color: SettingsTheme.background

            TabBar {
                id: tabBar
                anchors.fill: parent
                background: Rectangle { color: "transparent" }

                Repeater {
                    model: tabModel
                    TabButton {
                        text: Translator.translate(model.title, Settings.language)
                        width: tabView.width / tabModel.count
                        height: SettingsTheme.tabBarHeight

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: SettingsTheme.fontTab
                            font.family: SettingsTheme.fontFamily
                            font.weight: parent.checked ? Font.DemiBold : Font.Normal
                            color: parent.checked ? SettingsTheme.textPrimary : SettingsTheme.textSecondary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            color: parent.checked ? SettingsTheme.accent
                                 : parent.pressed ? SettingsTheme.surfacePressed
                                 : SettingsTheme.surface
                            border.color: parent.checked ? SettingsTheme.accent : SettingsTheme.border
                            border.width: SettingsTheme.borderWidth
                            radius: SettingsTheme.radiusSmall
                        }
                    }
                }
            }
        }

        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            MainSettings {
                visible: stackLayout.currentIndex === 0
            }
            DashSelector {
                visible: stackLayout.currentIndex === 1
            }
            VehicleRPMSettings {
                visible: stackLayout.currentIndex === 2
            }
            ExBoardAnalog {
                visible: stackLayout.currentIndex === 3
            }
            NetworkSettings {
                visible: stackLayout.currentIndex === 4
            }
            DiagnosticsSettings {
                visible: stackLayout.currentIndex === 5
            }
        }
    }
}
