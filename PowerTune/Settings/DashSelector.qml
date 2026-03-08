// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
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

    function getDashByIndex(index) {
        switch (index) {
        case 0:
            return "qrc:/qt/qml/PrismPT/Dashboard/PowerTune/Dashboard/UserDashboard.qml";
        case 1:
            return "qrc:/qt/qml/PrismPT/Dashboard/PowerTune/Dashboard/UserDashboard.qml";
        case 2:
            return "qrc:/qt/qml/PrismPT/Dashboard/PowerTune/Dashboard/UserDashboard.qml";
        case 3:
            return Qt.resolvedUrl("CanMonitor.qml");
        }
        return "";
    }

    function getDashIndex(comboIndex) {
        return comboIndex;
    }

    function adremove() {
        UI.Visibledashes = numberofdashes.currentIndex + 1;

        while (dashView.count > numberofdashes.currentIndex + 2) {
            dashView.takeItem(dashView.count - 2);
        }

        while (dashView.count < numberofdashes.currentIndex + 2) {
            switch (dashView.count) {
            case 2:
                dashView.insertItem(1, secondPageLoader);
                break;
            case 3:
                dashView.insertItem(2, thirdPageLoader);
                break;
            case 4:
                dashView.insertItem(3, fourthPageLoader);
                break;
            }
        }
    }

    Component.onCompleted: {
        if (numberofdashes.currentIndex >= 0) {
            adremove();
            firstPageLoader.source = getDashByIndex(dash1.currentIndex);
            if (dash2.currentIndex >= 0)
                secondPageLoader.source = getDashByIndex(dash2.currentIndex);
            if (dash3.currentIndex >= 0)
                thirdPageLoader.source = getDashByIndex(dash3.currentIndex);
            if (dash4.currentIndex >= 0)
                fourthPageLoader.source = getDashByIndex(dash4.currentIndex);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Item {
            Layout.fillHeight: true
        }

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
                    font.pixelSize: 18
                    font.family: "Lato"
                    color: "#FFFFFF"
                    Layout.preferredWidth: 200
                }

                StyledComboBox {
                    id: numberofdashes
                    model: ["1", "2", "3", "4"]
                    currentIndex: -1
                    onCurrentIndexChanged: {
                        adremove();
                        AppSettings.writeSelectedDashSettings(numberofdashes.currentIndex + 1);
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

        Item {
            Layout.fillHeight: true
        }
    }
}
