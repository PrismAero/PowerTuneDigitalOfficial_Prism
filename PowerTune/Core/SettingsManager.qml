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
            title: "EX Board"
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

            MainSettings {
                visible: stackLayout.currentIndex === 0
            }

            DisplaySettings {
                visible: stackLayout.currentIndex === 1
            }

            DashSelector {
                visible: stackLayout.currentIndex === 2
            }

            VehicleRPMSettings {
                visible: stackLayout.currentIndex === 3
            }

            ExBoardAnalog {
                visible: stackLayout.currentIndex === 4
            }

            NetworkSettings {
                visible: stackLayout.currentIndex === 5
            }

            DiagnosticsSettings {
                visible: stackLayout.currentIndex === 6
            }
        }
    }
}
