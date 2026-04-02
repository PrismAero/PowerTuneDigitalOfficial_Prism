import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import DLM 1.0
import PowerTune.Core 1.0
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: tabView

    property int currentIndex: tabBar.currentIndex
    property int lastdashamount

    anchors.fill: parent
    color: SettingsTheme.background

    DLM {
        id: downloadManager

    }

    ListModel {
        id: tabModel

        ListElement {
            title: "Main"
        }

        ListElement {
            title: "Display"
        }

        ListElement {
            title: "Dash Sel."
        }

        ListElement {
            title: "Vehicle / RPM"
        }

        ListElement {
            title: "Extender Board"
        }

        ListElement {
            title: "Network"
        }

        ListElement {
            title: "Diagnostics"
        }
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

                background: Rectangle {
                    color: "transparent"
                }

                Repeater {
                    model: tabModel

                    TabButton {
                        height: SettingsTheme.tabBarHeight
                        text: Translator.translate(model.title, Settings.language)
                        width: tabView.width / tabModel.count

                        background: Rectangle {
                            border.color: parent.checked ? SettingsTheme.accent : SettingsTheme.border
                            border.width: SettingsTheme.borderWidth
                            color: parent.checked ? SettingsTheme.accent : parent.pressed
                                                    ? SettingsTheme.surfacePressed : SettingsTheme.surface
                            radius: SettingsTheme.radiusSmall
                        }
                        contentItem: Text {
                            color: parent.checked ? SettingsTheme.textPrimary : SettingsTheme.textSecondary
                            elide: Text.ElideRight
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontTab
                            font.weight: parent.checked ? Font.DemiBold : Font.Normal
                            horizontalAlignment: Text.AlignHCenter
                            text: parent.text
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }

        StackLayout {
            id: stackLayout

            Layout.fillHeight: true
            Layout.fillWidth: true
            currentIndex: tabBar.currentIndex

            Component { id: mainSettingsComponent; MainSettings { } }
            Component { id: displaySettingsComponent; DisplaySettings { } }
            Component { id: dashSelectorComponent; DashSelector { } }
            Component { id: vehicleRpmComponent; VehicleRPMSettings { } }
            Component { id: exBoardComponent; ExtenderBoardTab { } }
            Component { id: networkComponent; NetworkSettings { } }
            Component { id: diagnosticsComponent; DiagnosticsSettings { } }

            Loader {
                id: mainSettingsLoader
                active: stackLayout.currentIndex === 0
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: mainSettingsComponent
            }

            Loader {
                id: displaySettingsLoader
                active: stackLayout.currentIndex === 1
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: displaySettingsComponent
            }

            Loader {
                id: dashSelectorLoader
                active: stackLayout.currentIndex === 2
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: dashSelectorComponent
            }

            Loader {
                id: vehicleRpmLoader
                active: stackLayout.currentIndex === 3
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: vehicleRpmComponent
            }

            Loader {
                id: exBoardLoader
                active: stackLayout.currentIndex === 4
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: exBoardComponent
            }

            Loader {
                id: networkLoader
                active: stackLayout.currentIndex === 5
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: networkComponent
            }

            Loader {
                id: diagnosticsLoader
                active: stackLayout.currentIndex === 6
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: diagnosticsComponent
            }
        }
    }
}
