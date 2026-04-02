import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

Popup {
    id: root

    property int channelIndex: 0

    function lk(suffix) {
        return PTExtenderConfig.ledStorageKey(channelIndex, suffix);
    }

    readonly property var patternNames: PTExtenderConfig.metadataLoaded ? PTExtenderConfig.ledPatternNames() : ["Off", "Solid", "Blink", "Pulse", "Chase", "Bi-Blink", "Bi-Pulse", "Tri-Cycle", "Strobe", "Breathe"]
    readonly property var overridePatternNames: {
        const names = root.patternNames.slice();
        if (names.length > 0)
            names[0] = "Use Base";
        return names;
    }

    anchors.centerIn: Overlay.overlay
    modal: true
    padding: SettingsTheme.sectionPadding
    width: Math.min(Overlay.overlay ? Overlay.overlay.width * 0.65 : 800, 900)

    background: Rectangle {
        border.color: SettingsTheme.accent
        border.width: 2
        color: SettingsTheme.surface
        radius: SettingsTheme.radiusLarge
    }

    contentItem: ScrollView {
        clip: true
        contentWidth: availableWidth
        implicitHeight: Math.min(contentCol.implicitHeight + 20, Overlay.overlay ? Overlay.overlay.height * 0.85 : 600)

        ColumnLayout {
            id: contentCol
            width: parent.width
            spacing: SettingsTheme.contentSpacing

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    color: SettingsTheme.accent
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontSectionTitle
                    font.weight: Font.Bold
                    text: "LED Channel " + root.channelIndex
                }
                StyledButton {
                    primary: false
                    text: "Close"
                    onClicked: root.close()
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: SettingsTheme.border }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                Text { color: SettingsTheme.textSecondary; text: "Name" }
                StyledTextField {
                    Layout.fillWidth: true
                    text: AppSettings.getValue(root.lk("name"), "LED " + root.channelIndex)
                    onTextEdited: AppSettings.setValue(root.lk("name"), text)
                }
                StyledSwitch {
                    text: "Enabled"
                    checked: AppSettings.getValue(root.lk("enabled"), root.channelIndex < 14)
                    onToggled: AppSettings.setValue(root.lk("enabled"), checked)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                Text { color: SettingsTheme.textSecondary; text: "RGB Group" }
                StyledSpinBox {
                    from: 0; to: 5
                    value: AppSettings.getValue(root.lk("rgbGroup"), 0)
                    onValueChanged: AppSettings.setValue(root.lk("rgbGroup"), value)
                }
                Text { color: SettingsTheme.textSecondary; text: "RGB Role" }
                StyledComboBox {
                    model: ["R", "G", "B"]
                    currentIndex: AppSettings.getValue(root.lk("rgbChannel"), 0)
                    onActivated: AppSettings.setValue(root.lk("rgbChannel"), currentIndex)
                }
                Text { color: SettingsTheme.textSecondary; text: "Quick Bind" }
                StyledComboBox {
                    model: ["None", "GPI1", "GPI2", "GPI3", "GPI4", "Ext 0", "Ext 1", "Ext 2", "Ext 3", "Ext 4", "Ext 5", "Ext 6", "Ext 7"]
                    currentIndex: AppSettings.getValue(root.lk("quickBindInput"), -1) + 1
                    onActivated: AppSettings.setValue(root.lk("quickBindInput"), currentIndex - 1)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                Text { color: SettingsTheme.textSecondary; text: "Base Brightness" }
                StyledSlider {
                    Layout.fillWidth: true
                    from: 0; to: 255; stepSize: 1
                    value: AppSettings.getValue(root.lk("onBrightness"), 255)
                    onMoved: AppSettings.setValue(root.lk("onBrightness"), Math.round(value))
                }
                Text {
                    Layout.preferredWidth: 40
                    color: SettingsTheme.textPrimary
                    text: Math.round(AppSettings.getValue(root.lk("onBrightness"), 255)).toString()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                Text { color: SettingsTheme.textSecondary; text: "Base Pattern" }
                StyledComboBox {
                    model: root.patternNames
                    currentIndex: AppSettings.getValue(root.lk("pattern"), 0)
                    onActivated: AppSettings.setValue(root.lk("pattern"), currentIndex)
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: SettingsTheme.border }

            Text {
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontLabel
                font.weight: Font.DemiBold
                text: "Active Override"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                Text { color: SettingsTheme.textSecondary; text: "Color" }
                StyledColorPicker {
                    Layout.preferredWidth: 160
                    colorValue: PTExtenderConfig.rgbToHex(
                                    AppSettings.getValue(root.lk("overrideR"), 255),
                                    AppSettings.getValue(root.lk("overrideG"), 0),
                                    AppSettings.getValue(root.lk("overrideB"), 0))
                    onColorEdited: function(newColor) {
                        const rgb = PTExtenderConfig.hexToRgb(newColor, 255, 0, 0);
                        AppSettings.setValue(root.lk("overrideR"), rgb.r);
                        AppSettings.setValue(root.lk("overrideG"), rgb.g);
                        AppSettings.setValue(root.lk("overrideB"), rgb.b);
                    }
                }
                Text { color: SettingsTheme.textSecondary; text: "Pattern" }
                StyledComboBox {
                    model: root.overridePatternNames
                    currentIndex: AppSettings.getValue(root.lk("overridePattern"), 2)
                    onActivated: AppSettings.setValue(root.lk("overridePattern"), currentIndex)
                }
                Text { color: SettingsTheme.textSecondary; text: "Scope" }
                StyledComboBox {
                    model: ["Channel", "Group"]
                    currentIndex: AppSettings.getValue(root.lk("overrideScope"), 1)
                    onActivated: AppSettings.setValue(root.lk("overrideScope"), currentIndex)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: AppSettings.getValue(root.lk("overridePattern"), 2) === 7
                spacing: SettingsTheme.controlGap

                Text { color: SettingsTheme.textSecondary; text: "Tri-Color C" }
                StyledColorPicker {
                    Layout.preferredWidth: 160
                    colorValue: PTExtenderConfig.rgbToHex(
                                    AppSettings.getValue(root.lk("overrideR2"), 0),
                                    AppSettings.getValue(root.lk("overrideG2"), 0),
                                    AppSettings.getValue(root.lk("overrideB2"), 255))
                    onColorEdited: function(newColor) {
                        const rgb = PTExtenderConfig.hexToRgb(newColor, 0, 0, 255);
                        AppSettings.setValue(root.lk("overrideR2"), rgb.r);
                        AppSettings.setValue(root.lk("overrideG2"), rgb.g);
                        AppSettings.setValue(root.lk("overrideB2"), rgb.b);
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                Text { color: SettingsTheme.textSecondary; text: "Idle Preview" }
                LedAnimationPreview {
                    colorA: PTExtenderConfig.rgbToHex(0, 180, 0)
                    pattern: AppSettings.getValue(root.lk("pattern"), 0)
                }
                Text { color: SettingsTheme.textSecondary; text: "Active Preview" }
                LedAnimationPreview {
                    colorA: PTExtenderConfig.rgbToHex(
                                AppSettings.getValue(root.lk("overrideR"), 255),
                                AppSettings.getValue(root.lk("overrideG"), 0),
                                AppSettings.getValue(root.lk("overrideB"), 0))
                    colorB: PTExtenderConfig.rgbToHex(0, 180, 0)
                    colorC: PTExtenderConfig.rgbToHex(
                                AppSettings.getValue(root.lk("overrideR2"), 0),
                                AppSettings.getValue(root.lk("overrideG2"), 0),
                                AppSettings.getValue(root.lk("overrideB2"), 255))
                    pattern: AppSettings.getValue(root.lk("overridePattern"), 2)
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: SettingsTheme.border }

            Text {
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontLabel
                font.weight: Font.DemiBold
                text: "Advanced Logic Rule (optional)"
            }

            LogicRuleEditor {
                Layout.fillWidth: true
                channelIndex: root.channelIndex
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: SettingsTheme.border }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }
                StyledButton {
                    enabled: PTExtenderConfig.configModeActive
                    text: "Write CH " + root.channelIndex
                    onClicked: PTExtenderConfig.writeLedChannel(root.channelIndex)
                }
                StyledButton {
                    primary: false
                    text: "Close"
                    onClicked: root.close()
                }
            }
        }
    }
}
