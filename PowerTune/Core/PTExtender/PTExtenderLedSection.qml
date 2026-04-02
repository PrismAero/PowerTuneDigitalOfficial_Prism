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
        spacing: 6

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
            spacing: 0

            Text { Layout.preferredWidth: 50; color: SettingsTheme.textSecondary; font.pixelSize: SettingsTheme.fontCaption; text: "CH" }
            Text { Layout.fillWidth: true; Layout.minimumWidth: 100; color: SettingsTheme.textSecondary; font.pixelSize: SettingsTheme.fontCaption; text: "Name" }
            Text { Layout.preferredWidth: 60; color: SettingsTheme.textSecondary; font.pixelSize: SettingsTheme.fontCaption; text: "Enabled" }
            Text { Layout.preferredWidth: 50; color: SettingsTheme.textSecondary; font.pixelSize: SettingsTheme.fontCaption; text: "Group" }
            Text { Layout.preferredWidth: 30; color: SettingsTheme.textSecondary; font.pixelSize: SettingsTheme.fontCaption; text: "Color" }
            Text { Layout.preferredWidth: 100; color: SettingsTheme.textSecondary; font.pixelSize: SettingsTheme.fontCaption; text: "Pattern" }
            Text { Layout.preferredWidth: 50; color: SettingsTheme.textSecondary; font.pixelSize: SettingsTheme.fontCaption; text: "Preview" }
            Text { Layout.preferredWidth: 80; color: SettingsTheme.textSecondary; font.pixelSize: SettingsTheme.fontCaption; text: "" }
        }

        Repeater {
            model: 16

            delegate: Rectangle {
                required property int index
                Layout.fillWidth: true
                color: index % 2 === 0 ? SettingsTheme.surfaceElevated : SettingsTheme.surface
                border.color: SettingsTheme.border
                border.width: SettingsTheme.borderWidth
                radius: 2
                implicitHeight: 40

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 0

                    Text {
                        Layout.preferredWidth: 50
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontControl
                        font.weight: Font.Bold
                        text: index.toString()
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 100
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontControl
                        elide: Text.ElideRight
                        text: AppSettings.getValue(root.ledKey(index, "name"), "LED " + index)
                    }

                    Text {
                        Layout.preferredWidth: 60
                        color: AppSettings.getValue(root.ledKey(index, "enabled"), index < 14) ? SettingsTheme.success : SettingsTheme.textDisabled
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontControl
                        text: AppSettings.getValue(root.ledKey(index, "enabled"), index < 14) ? "ON" : "OFF"
                    }

                    Text {
                        Layout.preferredWidth: 50
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontControl
                        text: {
                            const g = AppSettings.getValue(root.ledKey(index, "rgbGroup"), 0);
                            return g > 0 ? ("G" + g) : "-";
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.leftMargin: 3
                        radius: 4
                        border.color: SettingsTheme.border
                        border.width: 1
                        color: PTExtenderConfig.rgbToHex(
                                   AppSettings.getValue(root.ledKey(index, "overrideR"), 255),
                                   AppSettings.getValue(root.ledKey(index, "overrideG"), 0),
                                   AppSettings.getValue(root.ledKey(index, "overrideB"), 0))
                    }

                    Text {
                        Layout.preferredWidth: 100
                        Layout.leftMargin: 6
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontControl
                        elide: Text.ElideRight
                        text: root.patternLabel(AppSettings.getValue(root.ledKey(index, "overridePattern"), 2))
                    }

                    LedAnimationPreview {
                        Layout.preferredWidth: 50
                        colorA: PTExtenderConfig.rgbToHex(
                                    AppSettings.getValue(root.ledKey(index, "overrideR"), 255),
                                    AppSettings.getValue(root.ledKey(index, "overrideG"), 0),
                                    AppSettings.getValue(root.ledKey(index, "overrideB"), 0))
                        pattern: AppSettings.getValue(root.ledKey(index, "overridePattern"), 2)
                    }

                    StyledButton {
                        Layout.preferredWidth: 80
                        text: "Edit"
                        onClicked: {
                            editPopup.channelIndex = index;
                            editPopup.open();
                        }
                    }
                }
            }
        }
    }

    PTExtenderLedEditPopup {
        id: editPopup
    }
}
