// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
        var savedCount = AppSettings.readDashboardCount();
        var savedDash1 = AppSettings.readSelectedDash(1);
        var savedDash2 = AppSettings.readSelectedDash(2);
        var savedDash3 = AppSettings.readSelectedDash(3);
        var savedDash4 = AppSettings.readSelectedDash(4);
        numberofdashes.currentIndex = savedCount - 1;
        dash1.currentIndex = savedDash1;
        dash2.currentIndex = savedDash2;
        dash3.currentIndex = savedDash3;
        dash4.currentIndex = savedDash4;
        adremove();
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
                    if (settingsLoaded)
                        AppSettings.writeDashboardCount(numberofdashes.currentIndex + 1);
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
                                           AppSettings.writeSelectedDash(1, currentIndex)
            }

            DashSelectorWidget {
                id: dash2

                index: 2

                onCurrentIndexChanged: if (settingsLoaded)
                                           AppSettings.writeSelectedDash(2, currentIndex)
            }

            DashSelectorWidget {
                id: dash3

                index: 3

                onCurrentIndexChanged: if (settingsLoaded)
                                           AppSettings.writeSelectedDash(3, currentIndex)
            }

            DashSelectorWidget {
                id: dash4

                index: 4

                onCurrentIndexChanged: if (settingsLoaded)
                                           AppSettings.writeSelectedDash(4, currentIndex)
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
