import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import QtSensors
import QtMultimedia
import "qrc:/Gauges/"
import DLM 1.0
import PowerTune 1.0

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
        target: Dashboard
        function onEcuChanged() { setregtabtitle() }
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
                                return Translator.translate(model.title, Dashboard.language)
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

        // * Content Area
        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            Loader {
                source: "Settings/main.qml"
                active: stackLayout.currentIndex === 0
            }
            Loader {
                source: "Settings/DashSelector.qml"
                active: stackLayout.currentIndex === 1
            }
            Loader {
                source: "Settings/sensehat.qml"
                active: stackLayout.currentIndex === 2
            }
            Loader {
                source: "Settings/warn_gear.qml"
                active: stackLayout.currentIndex === 3
            }
            Loader {
                source: "Settings/speed.qml"
                active: stackLayout.currentIndex === 4
            }
            Loader {
                source: "Settings/analog.qml"
                active: stackLayout.currentIndex === 5
            }
            Loader {
                source: "Settings/rpm.qml"
                active: stackLayout.currentIndex === 6
            }
            Loader {
                source: "qrc:/ExBoardAnalog.qml"
                active: stackLayout.currentIndex === 7
            }
            Loader {
                source: "Settings/startup.qml"
                active: stackLayout.currentIndex === 8
            }
            Loader {
                source: "Settings/network.qml"
                active: stackLayout.currentIndex === 9
            }
        }
    }

    // * Dynamic tab title for ECU-specific tab
    property string regtabTitle: Translator.translate("Analog", Dashboard.language)

    function setregtabtitle() {
        switch (Dashboard.ecu) {
            case "0":
            case "1":
                regtabTitle = Translator.translate("Analog", Dashboard.language)
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
                regtabTitle = Translator.translate("Analog", Dashboard.language)
        }
    }

    Component.onCompleted: setregtabtitle()
}
