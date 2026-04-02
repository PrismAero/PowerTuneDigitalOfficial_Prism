import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

Item {
    id: root

    property int channelIndex: 0
    property int localConditionCount: loadValue("conditionCount", 1)

    signal ruleChanged()

    readonly property var conditionNames: PTExtenderConfig.metadataLoaded ? PTExtenderConfig.logicConditionNames() : [
        "None", "GPI High", "GPI Low", "GPI Rising", "GPI Falling",
        "Relay On", "Relay Off", "Tach Greater", "Tach Less",
        "Timer Elapsed", "State Match", "Ext Input High", "Ext Input Low"
    ]

    function baseKey() {
        return "ui/ptextender/led/" + channelIndex + "/rule/"
    }

    function saveValue(key, value) {
        AppSettings.setValue(baseKey() + key, value)
        ruleChanged()
    }

    function loadValue(key, fallback) {
        return AppSettings.getValue(baseKey() + key, fallback)
    }

    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.controlGap

            StyledSwitch {
                id: enabledSwitch
                checked: root.loadValue("enabled", false)
                text: "Rule enabled"
                onToggled: root.saveValue("enabled", checked)
            }

            StyledSpinBox {
                from: 1; to: 4
                value: root.localConditionCount
                onValueChanged: {
                    if (value !== root.localConditionCount) {
                        root.localConditionCount = value;
                        root.saveValue("conditionCount", value);
                    }
                }
            }

            Text {
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontControl
                text: "conditions"
            }
        }

        Repeater {
            model: 4
            delegate: RowLayout {
                required property int index
                Layout.fillWidth: true
                enabled: index < root.localConditionCount
                opacity: enabled ? 1.0 : 0.35
                spacing: SettingsTheme.controlGap

                StyledComboBox {
                    Layout.preferredWidth: 180
                    model: root.conditionNames
                    currentIndex: root.loadValue("cond" + index + "/type", 0)
                    onActivated: root.saveValue("cond" + index + "/type", currentIndex)
                }

                StyledSpinBox {
                    from: 0; to: 255
                    value: root.loadValue("cond" + index + "/channel", 0)
                    onValueChanged: root.saveValue("cond" + index + "/channel", value)
                }

                StyledSpinBox {
                    from: 0; to: 65535
                    value: root.loadValue("cond" + index + "/threshold", 0)
                    onValueChanged: root.saveValue("cond" + index + "/threshold", value)
                }

                StyledSwitch {
                    checked: root.loadValue("cond" + index + "/enabled", index === 0)
                    text: "enabled"
                    onToggled: root.saveValue("cond" + index + "/enabled", checked)
                }

                StyledComboBox {
                    Layout.preferredWidth: 110
                    model: ["AND", "OR", "AND NOT"]
                    currentIndex: Math.max(0, Math.min(2, root.loadValue("op" + index, 1) - 1))
                    onActivated: root.saveValue("op" + index, currentIndex + 1)
                    visible: index < 3
                }
            }
        }
    }

    onChannelIndexChanged: localConditionCount = loadValue("conditionCount", 1)
}
