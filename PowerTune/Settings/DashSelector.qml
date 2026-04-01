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

    function adremove() {
        UI.Visibledashes = numberofdashes.currentIndex + 1;
    }

    Component.onCompleted: {
        var savedCount = AppSettings.getValue("ui/dashCount", 0);
        var savedDash1 = AppSettings.getValue("ui/dashSelect1", 0);
        var savedDash2 = AppSettings.getValue("ui/dashSelect2", 0);
        var savedDash3 = AppSettings.getValue("ui/dashSelect3", 0);
        var savedDash4 = AppSettings.getValue("ui/dashSelect4", 0);
        numberofdashes.currentIndex = savedCount;
        dash1.currentIndex = savedDash1;
        dash2.currentIndex = savedDash2;
        dash3.currentIndex = savedDash3;
        dash4.currentIndex = savedDash4;
        settingsLoaded = true;
    }

    Item {
        Layout.fillHeight: true
    }

    // * Active Dashboards Section
    SettingsSection {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: 800
        title: Translator.translate("ActiveDashboards", Settings.language)

        SettingsRow {
            label: Translator.translate("ActiveDashboards", Settings.language)

            StyledComboBox {
                id: numberofdashes

                currentIndex: -1
                model: ["1", "2", "3", "4"]

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
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: 800
        title: "Dashboard Selection"

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.controlGap

            DashSelectorWidget {
                id: dash1

                index: 1

                onCurrentIndexChanged: if (settingsLoaded)
                                           AppSettings.setValue("ui/dashSelect1", currentIndex)
            }

            DashSelectorWidget {
                id: dash2

                index: 2

                onCurrentIndexChanged: if (settingsLoaded)
                                           AppSettings.setValue("ui/dashSelect2", currentIndex)
            }

            DashSelectorWidget {
                id: dash3

                index: 3

                onCurrentIndexChanged: if (settingsLoaded)
                                           AppSettings.setValue("ui/dashSelect3", currentIndex)
            }

            DashSelectorWidget {
                id: dash4

                index: 4

                onCurrentIndexChanged: if (settingsLoaded)
                                           AppSettings.setValue("ui/dashSelect4", currentIndex)
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
