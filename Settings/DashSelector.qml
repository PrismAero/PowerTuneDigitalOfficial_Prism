import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import QtMultimedia 5.8
import "qrc:/Translator.js" as Translator
import "components"

Rectangle {
    id: dashselector
    anchors.fill: parent
    color: "#121212"

    Settings {
        property alias dashselect1: dash1.currentIndex
        property alias dashselect2: dash2.currentIndex
        property alias dashselect3: dash3.currentIndex
        property alias dashselect4: dash4.currentIndex
        property alias numberofdash: numberofdashes.currentIndex
    }

    function getDashByIndex(index) {
        switch (index) {
            case 0: return "qrc:/Gauges/Cluster.qml"
            case 1: return "qrc:/Gauges/GPS.qml"
            case 2: return "qrc:/GPSTracks/Laptimer.qml"
            case 3: return "qrc:/Gauges/PFCSensors.qml"
            case 4: return "qrc:/Gauges/Userdash1.qml"
            case 5: return "qrc:/Gauges/Userdash2.qml"
            case 6: return "qrc:/Gauges/Userdash3.qml"
            case 7: return "qrc:/Gauges/ForceMeter.qml"
            case 8: return "qrc:/Gauges/Mediaplayer.qml"
            case 9: return "qrc:/Gauges/Screentoggle.qml"
            case 10: return "qrc:/Gauges/SpeedMeasurements.qml"
            case 11: return "qrc:/Settings/CanMonitor.qml"
        }
    }

    function adremove() {
        Dashboard.Visibledashes = numberofdashes.currentIndex + 1

        while (dashView.count > numberofdashes.currentIndex + 2) {
            dashView.takeItem(dashView.count - 2)
        }

        while (dashView.count < numberofdashes.currentIndex + 2) {
            switch (dashView.count) {
                case 2: dashView.insertItem(1, secondPageLoader); break
                case 3: dashView.insertItem(2, thirdPageLoader); break
                case 4: dashView.insertItem(3, fourthPageLoader); break
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 16
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: dashselector.width - 32
            spacing: 20

            // * Active Dashboards Section
            SettingsSection {
                title: Translator.translate("ActiveDashboards", Dashboard.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 20

                    Text {
                        text: Translator.translate("ActiveDashboards", Dashboard.language)
                        font.pixelSize: 20
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 200
                    }

                    StyledComboBox {
                        id: numberofdashes
                        width: 150
                        model: ["1", "2", "3", "4"]
                        currentIndex: -1
                        onCurrentIndexChanged: {
                            adremove()
                            AppSettings.writeSelectedDashSettings(numberofdashes.currentIndex + 1)
                        }
                    }
                }
            }

            // * Dashboard Selection Section
            SettingsSection {
                title: "Dashboard Selection"
                Layout.fillWidth: true

                RowLayout {
                    spacing: 16
                    Layout.fillWidth: true

                    DashSelectorWidget {
                        id: dash1
                        index: 1
                        linkedLoader: firstPageLoader
                    }

                    DashSelectorWidget {
                        id: dash2
                        index: 2
                        linkedLoader: secondPageLoader
                    }

                    DashSelectorWidget {
                        id: dash3
                        index: 3
                        linkedLoader: thirdPageLoader
                    }

                    DashSelectorWidget {
                        id: dash4
                        index: 4
                        linkedLoader: fourthPageLoader
                        Component.onCompleted: tabView.currentIndex = 0
                    }
                }
            }
        }
    }
}
