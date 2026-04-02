import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsSection {
    id: root
    title: "LED Channels"

    function ledKey(ch, suffix) {
        return PTExtenderConfig.ledStorageKey(ch, suffix)
    }

    readonly property var patternNames: PTExtenderConfig.metadataLoaded ? PTExtenderConfig.ledPatternNames() : []

    function patternLabel(idx) {
        if (root.patternNames.length > idx && idx >= 0)
            return root.patternNames[idx];
        return "Pattern " + idx;
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.contentSpacing

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.controlGap

            Text {
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: "Click Edit to configure a channel. Quick-bind maps an input to LED color/pattern without logic rules."
            }
            Item { Layout.fillWidth: true }
            StyledButton {
                enabled: PTExtenderConfig.configModeActive
                text: "Write All Channels"
                onClicked: PTExtenderConfig.writeAllLedChannels()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Item { Layout.preferredWidth: 20 }
            Text { Layout.preferredWidth: 50; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; text: "CH" }
            Text { Layout.fillWidth: true; Layout.minimumWidth: 100; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; text: "Name" }
            Text { Layout.preferredWidth: 50; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; text: "Group" }
            Text { Layout.preferredWidth: 160; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; text: "Color / Pattern" }
            Item { Layout.preferredWidth: 80 }
        }

        Rectangle { Layout.fillWidth: true; height: SettingsTheme.borderWidth; color: SettingsTheme.border }

        Repeater {
            model: 16

            delegate: RowLayout {
                required property int index
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                spacing: 12
                opacity: AppSettings.getValue(root.ledKey(index, "enabled"), index < 14) ? 1.0 : 0.4

                Item {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: parent.height

                    Rectangle {
                        anchors.centerIn: parent
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        color: AppSettings.getValue(root.ledKey(index, "enabled"), index < 14)
                               ? SettingsTheme.success : SettingsTheme.textDisabled
                    }
                }

                Text {
                    Layout.preferredWidth: 50
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    text: index.toString()
                }

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 100
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    text: AppSettings.getValue(root.ledKey(index, "name"), "LED " + index)
                }

                Text {
                    Layout.preferredWidth: 50
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    verticalAlignment: Text.AlignVCenter
                    text: {
                        const g = AppSettings.getValue(root.ledKey(index, "rgbGroup"), 0);
                        return g > 0 ? ("G" + g) : "-";
                    }
                }

                RowLayout {
                    Layout.preferredWidth: 160
                    spacing: 8

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 4
                        border.color: SettingsTheme.border
                        border.width: 1
                        color: PTExtenderConfig.rgbToHex(
                                   AppSettings.getValue(root.ledKey(index, "overrideR"), 255),
                                   AppSettings.getValue(root.ledKey(index, "overrideG"), 0),
                                   AppSettings.getValue(root.ledKey(index, "overrideB"), 0))
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        text: root.patternLabel(AppSettings.getValue(root.ledKey(index, "overridePattern"), 2))
                    }
                }

                StyledButton {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignVCenter
                    primary: false
                    text: "Edit"
                    onClicked: {
                        editPopup.channelIndex = index;
                        editPopup.open();
                    }
                }
            }
        }
    }

    PTExtenderLedEditPopup {
        id: editPopup
    }
}
