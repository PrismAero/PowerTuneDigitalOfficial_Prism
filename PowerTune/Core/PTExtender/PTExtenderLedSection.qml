import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsSection {
    id: root
    title: "LED Channels"

    function ledKey(ch, suffix) {
        return "ui/ptextender/led/" + ch + "/" + suffix
    }

    function clampByte(v) {
        return Math.max(0, Math.min(255, v))
    }

    function toHex(v) {
        const h = clampByte(v).toString(16).toUpperCase()
        return h.length < 2 ? "0" + h : h
    }

    function rgbToHex(r, g, b) {
        return "#" + toHex(r) + toHex(g) + toHex(b)
    }

    function hexToRgb(hex, fallbackR, fallbackG, fallbackB) {
        if (!hex || hex.length !== 7 || hex.charAt(0) !== "#")
            return { r: fallbackR, g: fallbackG, b: fallbackB }
        return {
            r: clampByte(parseInt(hex.substring(1, 3), 16)),
            g: clampByte(parseInt(hex.substring(3, 5), 16)),
            b: clampByte(parseInt(hex.substring(5, 7), 16))
        }
    }

    function writeChannel(ch) {
        const base = "ui/ptextender/led/" + ch + "/"
        const name = (AppSettings.getValue(base + "name", "LED " + ch) + "").padEnd(16, "\0").substring(0, 16)
        const main = String.fromCharCode(
                    AppSettings.getValue(base + "rgbGroup", 0),
                    AppSettings.getValue(base + "rgbChannel", 0),
                    AppSettings.getValue(base + "onBrightness", 255),
                    AppSettings.getValue(base + "pattern", 0),
                    AppSettings.getValue(base + "enabled", ch < 14) ? 1 : 0
                    )
        const override = String.fromCharCode(
                    AppSettings.getValue(base + "overrideR", 255),
                    AppSettings.getValue(base + "overrideG", 0),
                    AppSettings.getValue(base + "overrideB", 0),
                    AppSettings.getValue(base + "overridePattern", 2),
                    AppSettings.getValue(base + "overrideScope", 1)
                    )
        const override2 = String.fromCharCode(
                    AppSettings.getValue(base + "overrideR2", 0),
                    AppSettings.getValue(base + "overrideG2", 0),
                    AppSettings.getValue(base + "overrideB2", 255)
                    )
        const quickBind = String.fromCharCode((AppSettings.getValue(base + "quickBindInput", -1) + 256) % 256)

        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupLed, ch, 0x00, main)
        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupLed, ch, 0x01, override)
        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupLed, ch, 0x02, override2)
        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupLed, ch, 0x03, quickBind)

        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupLed, ch, 0x10, name.substring(0, 5))
        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupLed, ch, 0x11, name.substring(5, 10))
        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupLed, ch, 0x12, name.substring(10, 15))
        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupLed, ch, 0x13, name.substring(15, 16))

        const ruleMeta = String.fromCharCode(
                    AppSettings.getValue(base + "rule/enabled", false) ? 1 : 0,
                    AppSettings.getValue(base + "rule/conditionCount", 1)
                    )
        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupLed, ch, 0x20, ruleMeta)

        for (let i = 0; i < 4; ++i) {
            const cond = String.fromCharCode(
                        AppSettings.getValue(base + "rule/cond" + i + "/type", i === 0 ? 0 : 0),
                        AppSettings.getValue(base + "rule/cond" + i + "/channel", 0),
                        AppSettings.getValue(base + "rule/cond" + i + "/threshold", 0) & 0xFF,
                        (AppSettings.getValue(base + "rule/cond" + i + "/threshold", 0) >> 8) & 0xFF,
                        AppSettings.getValue(base + "rule/cond" + i + "/enabled", i === 0) ? 1 : 0
                        )
            PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupLed, ch, 0x21 + i, cond)
        }
        const ops = String.fromCharCode(
                    AppSettings.getValue(base + "rule/op0", 1),
                    AppSettings.getValue(base + "rule/op1", 1),
                    AppSettings.getValue(base + "rule/op2", 1)
                    )
        PTExtenderCan.writeConfigRegister(PTExtenderCan.ConfigGroupLed, ch, 0x25, ops)
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            color: SettingsTheme.textSecondary
            text: "Quick-bind lets you map an input to LED color/pattern without writing advanced logic rules."
        }

        Button {
            text: "Write All LED Channels"
            onClicked: {
                for (let i = 0; i < 16; ++i)
                    root.writeChannel(i)
            }
        }

        Repeater {
            model: 16

            delegate: Rectangle {
                required property int index
                Layout.fillWidth: true
                color: SettingsTheme.surfaceElevated
                border.color: SettingsTheme.border
                border.width: SettingsTheme.borderWidth
                radius: SettingsTheme.radiusSmall
                implicitHeight: content.implicitHeight + 12

                ColumnLayout {
                    id: content
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            color: SettingsTheme.textPrimary
                            text: "CH" + index
                            font.bold: true
                        }

                        StyledTextField {
                            Layout.fillWidth: true
                            text: AppSettings.getValue(root.ledKey(index, "name"), "LED " + index)
                            onTextEdited: AppSettings.setValue(root.ledKey(index, "name"), text)
                        }

                        StyledSwitch {
                            text: "Enabled"
                            checked: AppSettings.getValue(root.ledKey(index, "enabled"), index < 14)
                            onToggled: AppSettings.setValue(root.ledKey(index, "enabled"), checked)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text { color: SettingsTheme.textSecondary; text: "Group" }
                        SpinBox {
                            from: 0; to: 5
                            value: AppSettings.getValue(root.ledKey(index, "rgbGroup"), 0)
                            onValueModified: AppSettings.setValue(root.ledKey(index, "rgbGroup"), value)
                        }
                        Text { color: SettingsTheme.textSecondary; text: "Role" }
                        ComboBox {
                            model: ["R", "G", "B"]
                            currentIndex: AppSettings.getValue(root.ledKey(index, "rgbChannel"), 0)
                            onActivated: AppSettings.setValue(root.ledKey(index, "rgbChannel"), currentIndex)
                        }
                        Text { color: SettingsTheme.textSecondary; text: "Bind" }
                        ComboBox {
                            Layout.preferredWidth: 180
                            model: ["None", "GPI1", "GPI2", "GPI3", "GPI4", "Ext Input 0", "Ext Input 1", "Ext Input 2", "Ext Input 3", "Ext Input 4", "Ext Input 5", "Ext Input 6", "Ext Input 7"]
                            currentIndex: AppSettings.getValue(root.ledKey(index, "quickBindInput"), -1) + 1
                            onActivated: AppSettings.setValue(root.ledKey(index, "quickBindInput"), currentIndex - 1)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text { color: SettingsTheme.textSecondary; text: "Base Brightness" }
                        Slider {
                            Layout.fillWidth: true
                            from: 0; to: 255
                            value: AppSettings.getValue(root.ledKey(index, "onBrightness"), 255)
                            onMoved: AppSettings.setValue(root.ledKey(index, "onBrightness"), Math.round(value))
                        }
                        Text { color: SettingsTheme.textSecondary; text: Math.round(AppSettings.getValue(root.ledKey(index, "onBrightness"), 255)) }
                        Text { color: SettingsTheme.textSecondary; text: "Base Pattern" }
                        ComboBox {
                            model: ["OFF", "SOLID", "BLINK", "PULSE", "CHASE", "BI BLINK", "BI PULSE", "TRI CYCLE", "STROBE", "BREATHE"]
                            currentIndex: AppSettings.getValue(root.ledKey(index, "pattern"), 0)
                            onActivated: AppSettings.setValue(root.ledKey(index, "pattern"), currentIndex)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text { color: SettingsTheme.textSecondary; text: "Active Color" }
                        StyledColorPicker {
                            Layout.preferredWidth: 160
                            colorValue: root.rgbToHex(
                                            AppSettings.getValue(root.ledKey(index, "overrideR"), 255),
                                            AppSettings.getValue(root.ledKey(index, "overrideG"), 0),
                                            AppSettings.getValue(root.ledKey(index, "overrideB"), 0))
                            onColorEdited: function(newColor) {
                                const rgb = root.hexToRgb(newColor, 255, 0, 0)
                                AppSettings.setValue(root.ledKey(index, "overrideR"), rgb.r)
                                AppSettings.setValue(root.ledKey(index, "overrideG"), rgb.g)
                                AppSettings.setValue(root.ledKey(index, "overrideB"), rgb.b)
                            }
                        }
                        Text { color: SettingsTheme.textSecondary; text: "Pattern" }
                        ComboBox {
                            model: ["BASE", "SOLID", "BLINK", "PULSE", "CHASE", "BI BLINK", "BI PULSE", "TRI CYCLE", "STROBE", "BREATHE"]
                            currentIndex: AppSettings.getValue(root.ledKey(index, "overridePattern"), 2)
                            onActivated: AppSettings.setValue(root.ledKey(index, "overridePattern"), currentIndex)
                        }
                        Text { color: SettingsTheme.textSecondary; text: "Scope" }
                        ComboBox {
                            model: ["Channel", "Group"]
                            currentIndex: AppSettings.getValue(root.ledKey(index, "overrideScope"), 1)
                            onActivated: AppSettings.setValue(root.ledKey(index, "overrideScope"), currentIndex)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        visible: AppSettings.getValue(root.ledKey(index, "overridePattern"), 2) === 7
                        spacing: 6
                        Text { color: SettingsTheme.textSecondary; text: "Tri Color C" }
                        StyledColorPicker {
                            Layout.preferredWidth: 160
                            colorValue: root.rgbToHex(
                                            AppSettings.getValue(root.ledKey(index, "overrideR2"), 0),
                                            AppSettings.getValue(root.ledKey(index, "overrideG2"), 0),
                                            AppSettings.getValue(root.ledKey(index, "overrideB2"), 255))
                            onColorEdited: function(newColor) {
                                const rgb = root.hexToRgb(newColor, 0, 0, 255)
                                AppSettings.setValue(root.ledKey(index, "overrideR2"), rgb.r)
                                AppSettings.setValue(root.ledKey(index, "overrideG2"), rgb.g)
                                AppSettings.setValue(root.ledKey(index, "overrideB2"), rgb.b)
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text { color: SettingsTheme.textSecondary; text: "Idle" }
                        LedAnimationPreview {
                            colorA: root.rgbToHex(0, 180, 0)
                            pattern: AppSettings.getValue(root.ledKey(index, "pattern"), 0)
                        }
                        Text { color: SettingsTheme.textSecondary; text: "Active" }
                        LedAnimationPreview {
                            colorA: root.rgbToHex(
                                        AppSettings.getValue(root.ledKey(index, "overrideR"), 255),
                                        AppSettings.getValue(root.ledKey(index, "overrideG"), 0),
                                        AppSettings.getValue(root.ledKey(index, "overrideB"), 0))
                            colorB: root.rgbToHex(0, 180, 0)
                            colorC: root.rgbToHex(
                                        AppSettings.getValue(root.ledKey(index, "overrideR2"), 0),
                                        AppSettings.getValue(root.ledKey(index, "overrideG2"), 0),
                                        AppSettings.getValue(root.ledKey(index, "overrideB2"), 255))
                            pattern: AppSettings.getValue(root.ledKey(index, "overridePattern"), 2)
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            text: "Write CH" + index
                            onClicked: root.writeChannel(index)
                        }
                    }

                    Text {
                        color: SettingsTheme.textSecondary
                        text: "Advanced Logic Rule (optional)"
                    }
                    LogicRuleEditor {
                        Layout.fillWidth: true
                        channelIndex: index
                    }
                }
            }
        }
    }
}
