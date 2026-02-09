import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import QtSensors
import QtMultimedia
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

    // * Dark theme color definitions
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

    Connections {
        target: Connection
        function onEcuChanged() { setregtabtitle() }
    }
    Connections {
        target: Settings
        function onLanguageChanged() { setregtabtitle() }
    }

    // * Tab titles model
    ListModel {
        id: tabModel
        ListElement { title: "Main" }
        ListElement { title: "Dash Sel." }
        ListElement { title: "Sensehat" }
        ListElement { title: "Warn / Gear" }
        ListElement { title: "Speed" }
        ListElement { title: "Analog" }
        ListElement { title: "RPM" }
        ListElement { title: "EX Board" }
        ListElement { title: "Startup" }
        ListElement { title: "Network" }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // * Tab Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: colorBackground

            ScrollView {
                anchors.fill: parent
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                clip: true

                TabBar {
                    id: tabBar
                    width: Math.max(implicitWidth, parent.width)
                    background: Rectangle { color: "transparent" }

                    Repeater {
                        model: tabModel
                        TabButton {
                            text: {
                                // * Translate tab titles
                                if (index === 5) return regtabTitle
                                return Translator.translate(model.title, Settings.language)
                            }
                            width: 145
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
        }

        // * Content Area - using module components directly
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
            SenseHatSettings {
                visible: stackLayout.currentIndex === 2
            }
            WarnGearSettings {
                visible: stackLayout.currentIndex === 3
            }
            SpeedSettings {
                visible: stackLayout.currentIndex === 4
            }
            AnalogSettings {
                visible: stackLayout.currentIndex === 5
            }
            RPMSettings {
                visible: stackLayout.currentIndex === 6
            }
            ExBoardAnalog {
                visible: stackLayout.currentIndex === 7
            }
            StartupSettings {
                visible: stackLayout.currentIndex === 8
            }
            NetworkSettings {
                visible: stackLayout.currentIndex === 9
            }
        }
    }

    // * Dynamic tab title for ECU-specific tab
    property string regtabTitle: Translator.translate("Analog", Settings.language)

    function setregtabtitle() {
        switch (Connection.ecu) {
            case "0":
            case "1":
                regtabTitle = Translator.translate("Analog", Settings.language)
                break
            case "2":
                regtabTitle = "Consult"
                break
            case "3":
                regtabTitle = "OBD"
                break
            case "4":
                regtabTitle = "Generic CAN"
                break
            default:
                regtabTitle = Translator.translate("Analog", Settings.language)
        }
    }

    Component.onCompleted: setregtabtitle()
}
