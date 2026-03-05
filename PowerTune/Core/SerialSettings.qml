import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import DLM 1.0
import PowerTune.Core 1.0
import PowerTune.Settings 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: tabView
    anchors.fill: parent
    color: colorBackground

    property int lastdashamount
    property int currentIndex: tabBar.currentIndex

    readonly property color colorBackground: "#121212"
    readonly property color colorBackgroundSecondary: "#1E1E1E"
    readonly property color colorBackgroundTertiary: "#2D2D2D"
    readonly property color colorAccent: "#009688"
    readonly property color colorTextPrimary: "#FFFFFF"
    readonly property color colorTextSecondary: "#B0B0B0"
    readonly property color colorDivider: "#3D3D3D"

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
            Layout.preferredHeight: 56
            color: colorBackground

            TabBar {
                id: tabBar
                anchors.fill: parent
                background: Rectangle { color: "transparent" }

                Repeater {
                    model: tabModel
                    TabButton {
                        text: Translator.translate(model.title, Settings.language)
                        width: tabView.width / tabModel.count
                        height: 56

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 18
                            font.family: "Lato"
                            font.weight: parent.checked ? Font.DemiBold : Font.Normal
                            color: parent.checked ? colorTextPrimary : colorTextSecondary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            color: parent.checked ? colorAccent : colorBackgroundTertiary
                            border.color: parent.checked ? colorAccent : colorDivider
                            border.width: 1
                            radius: 4
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
