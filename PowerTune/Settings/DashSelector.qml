// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import QtMultimedia
import PowerTune.Settings 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: dashselector
    anchors.fill: parent
    color: "#1a1a2e"

    Settings {
        property alias dashselect1: dash1.currentIndex
        property alias dashselect2: dash2.currentIndex
        property alias dashselect3: dash3.currentIndex
        property alias dashselect4: dash4.currentIndex
        property alias numberofdash: numberofdashes.currentIndex
    }

    // * Returns resource path for dashboard component
    // * Uses qt_add_qml_module resource paths (prefix + source path)
    function getDashByIndex(index) {
        var basePath = "qrc:/qt/qml/PowerTune/Gauges/PowerTune/Gauges/"
        switch (index) {
            case 0: return basePath + "Cluster.qml"
            case 1: return basePath + "GPS.qml"
            case 2: return "qrc:/GPSTracks/Laptimer.qml"
            case 3: return basePath + "PFCSensors.qml"
            case 4: return basePath + "Userdash1.qml"
            case 5: return basePath + "Userdash2.qml"
            case 6: return basePath + "Userdash3.qml"
            case 7: return basePath + "ForceMeter.qml"
            case 8: return basePath + "Mediaplayer.qml"
            case 9: return basePath + "Screentoggle.qml"
            case 10: return basePath + "SpeedMeasurements.qml"
            case 11: return "qrc:/qt/qml/PowerTune/Settings/PowerTune/Settings/CanMonitor.qml"
        }
    }

    function adremove() {
        UI.Visibledashes = numberofdashes.currentIndex + 1

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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Item { Layout.fillHeight: true }

        // * Active Dashboards Section
        SettingsSection {
            title: Translator.translate("ActiveDashboards", Settings.language)
            Layout.fillWidth: true
            Layout.maximumWidth: 800
            Layout.alignment: Qt.AlignHCenter

            RowLayout {
                spacing: 16

                Text {
                    text: Translator.translate("ActiveDashboards", Settings.language)
                    font.pixelSize: 16
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
            Layout.maximumWidth: 800
            Layout.alignment: Qt.AlignHCenter

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

        Item { Layout.fillHeight: true }
    }
}
