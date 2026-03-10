// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

SettingsPage {
    id: dashselector
    property bool settingsLoaded: false

    function getDashByIndex(index) {
        switch (index) {
        case 0:
            return "qrc:/qt/qml/PrismPT/Dashboard/PowerTune/Dashboard/UserDashboard.qml";
        case 1:
            return "qrc:/qt/qml/PrismPT/Dashboard/PowerTune/Dashboard/UserDashboard.qml";
        case 2:
            return "qrc:/qt/qml/PrismPT/Dashboard/PowerTune/Dashboard/UserDashboard.qml";
        case 3:
            return "qrc:/qt/qml/PrismPT/Dashboard/PowerTune/Dashboard/RaceDash.qml";
        case 4:
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
        dash1.currentIndex = AppSettings.getValue("ui/dashSelect1", 0)
        dash2.currentIndex = AppSettings.getValue("ui/dashSelect2", 0)
        dash3.currentIndex = AppSettings.getValue("ui/dashSelect3", 0)
        dash4.currentIndex = AppSettings.getValue("ui/dashSelect4", 0)
        numberofdashes.currentIndex = AppSettings.getValue("ui/dashCount", 0)
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
        settingsLoaded = true
    }

    Item {
        Layout.fillHeight: true
    }

    // * Active Dashboards Section
    SettingsSection {
        title: Translator.translate("ActiveDashboards", Settings.language)
        Layout.fillWidth: true
        Layout.maximumWidth: 800
        Layout.alignment: Qt.AlignHCenter

        SettingsRow {
            label: Translator.translate("ActiveDashboards", Settings.language)

            StyledComboBox {
                id: numberofdashes
                model: ["1", "2", "3", "4"]
                currentIndex: -1
                onCurrentIndexChanged: {
                    adremove();
                    if (settingsLoaded) {
                        AppSettings.writeSelectedDashSettings(numberofdashes.currentIndex + 1);
                        AppSettings.setValue("ui/dashCount", currentIndex);
                    }
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
            spacing: SettingsTheme.controlGap
            Layout.fillWidth: true

            DashSelectorWidget {
                id: dash1
                index: 1
                linkedLoader: firstPageLoader
                onCurrentIndexChanged: if (settingsLoaded) AppSettings.setValue("ui/dashSelect1", currentIndex)
            }

            DashSelectorWidget {
                id: dash2
                index: 2
                linkedLoader: secondPageLoader
                onCurrentIndexChanged: if (settingsLoaded) AppSettings.setValue("ui/dashSelect2", currentIndex)
            }

            DashSelectorWidget {
                id: dash3
                index: 3
                linkedLoader: thirdPageLoader
                onCurrentIndexChanged: if (settingsLoaded) AppSettings.setValue("ui/dashSelect3", currentIndex)
            }

            DashSelectorWidget {
                id: dash4
                index: 4
                linkedLoader: fourthPageLoader
                Component.onCompleted: tabView.currentIndex = 0
                onCurrentIndexChanged: if (settingsLoaded) AppSettings.setValue("ui/dashSelect4", currentIndex)
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
