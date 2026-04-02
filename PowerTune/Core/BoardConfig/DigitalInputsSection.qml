// Copyright (c) PowerTune Digital, Kai Wyborny. All rights reserved.
// DigitalInputsSection.qml - Extracted expansion board digital input configuration

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsSection {
    id: root

    readonly property int _channelColW: 120
    readonly property int _enableColW: 65
    readonly property int _nameColW: 200
    readonly property int _stateColW: 80
    property var digitalConfigs: []
    property var digitalInputs: null

    signal configChanged(var configs)

    function buildConfigs() {
        var configs = [];
        for (var i = 0; i < digitalNameRepeater.count; i++) {
            var item = digitalNameRepeater.itemAt(i);
            configs.push({
                enabled: item.enableSwitch.checked,
                name: item.nameField.text
            });
        }
        return configs;
    }

    function loadConfigs(configs) {
        if (!configs || configs.length === 0)
            return;
        var count = Math.min(configs.length, digitalNameRepeater.count);
        for (var i = 0; i < count; i++) {
            var item = digitalNameRepeater.itemAt(i);
            if (item && configs[i]) {
                item.enableSwitch.checked = configs[i].enabled !== undefined ? configs[i].enabled : true;
                item.nameField.text = configs[i].name !== undefined ? configs[i].name : "";
            }
        }
    }

    Layout.fillWidth: true
    title: "Digital Inputs"

    ColumnLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.contentSpacing

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: SettingsTheme.sectionPadding
            Layout.preferredHeight: 28
            Layout.rightMargin: SettingsTheme.sectionPadding
            spacing: 8

            Text {
                Layout.preferredWidth: root._enableColW
                text: ""
            }

            Text {
                Layout.preferredWidth: root._nameColW
                color: SettingsTheme.textSecondary
                font.bold: true
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontStatus
                text: "Name"
            }

            Text {
                Layout.preferredWidth: root._channelColW
                color: SettingsTheme.textSecondary
                font.bold: true
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontStatus
                text: "Channel"
            }

            Text {
                Layout.preferredWidth: root._stateColW
                color: SettingsTheme.textSecondary
                font.bold: true
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontStatus
                text: "State"
            }
        }

        Repeater {
            id: digitalNameRepeater

            model: 8

            RowLayout {
                required property int index

                property alias enableSwitch: diEnableSwitch
                property alias nameField: digiNameField

                Layout.fillWidth: true
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: diEnableSwitch.checked ? 1.0 : 0.4
                spacing: 8

                StyledSwitch {
                    id: diEnableSwitch

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: root._enableColW
                    checked: true

                    onCheckedChanged: root.configChanged(root.buildConfigs())
                }

                StyledTextField {
                    id: digiNameField

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: root._nameColW
                    enabled: diEnableSwitch.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "DI " + (index + 1)

                    onEditingFinished: root.configChanged(root.buildConfigs())
                }

                Text {
                    Layout.preferredWidth: root._channelColW
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "EX Digi " + (index + 1)
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    readonly property string propName: "EXDigitalInput" + (index + 1)
                    readonly property real rawValue: root.digitalInputs ? root.digitalInputs[propName] : 0

                    Layout.preferredWidth: root._stateColW
                    color: rawValue > 0 ? SettingsTheme.success : SettingsTheme.textSecondary
                    font.bold: rawValue > 0
                    font.family: SettingsTheme.fontFamilyMono
                    font.pixelSize: SettingsTheme.fontStatus
                    text: rawValue > 0 ? "HIGH" : "LOW"
                    verticalAlignment: Text.AlignVCenter
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
