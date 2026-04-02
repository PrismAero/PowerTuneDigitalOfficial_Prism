import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

Item {
    id: root

    property int channelIndex: 0
    property int localConditionCount: loadValue("conditionCount", 1)

    signal ruleChanged()

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
            spacing: 8

            StyledSwitch {
                id: enabledSwitch
                checked: root.loadValue("enabled", false)
                text: "Rule enabled"
                onToggled: root.saveValue("enabled", checked)
            }

            SpinBox {
                from: 1
                to: 4
                value: root.localConditionCount
                onValueModified: {
                    root.localConditionCount = value
                    root.saveValue("conditionCount", value)
                }
            }

            Text {
                color: SettingsTheme.textSecondary
                text: "conditions"
            }
        }

        Repeater {
            model: 4
            delegate: RowLayout {
                required property int index
                Layout.fillWidth: true
                enabled: index < root.localConditionCount
                spacing: 8

                ComboBox {
                    Layout.preferredWidth: 180
                    model: [
                        "None",
                        "GPI High",
                        "GPI Low",
                        "GPI Rising",
                        "GPI Falling",
                        "Relay On",
                        "Relay Off",
                        "Tach Greater",
                        "Tach Less",
                        "Timer Elapsed",
                        "State Match",
                        "Ext Input High",
                        "Ext Input Low"
                    ]
                    currentIndex: root.loadValue("cond" + index + "/type", 0)
                    onActivated: root.saveValue("cond" + index + "/type", currentIndex)
                }

                SpinBox {
                    from: 0
                    to: 255
                    value: root.loadValue("cond" + index + "/channel", 0)
                    onValueModified: root.saveValue("cond" + index + "/channel", value)
                }

                SpinBox {
                    from: 0
                    to: 65535
                    value: root.loadValue("cond" + index + "/threshold", 0)
                    onValueModified: root.saveValue("cond" + index + "/threshold", value)
                }

                StyledSwitch {
                    checked: root.loadValue("cond" + index + "/enabled", index === 0)
                    text: "enabled"
                    onToggled: root.saveValue("cond" + index + "/enabled", checked)
                }

                ComboBox {
                    visible: index < 3
                    Layout.preferredWidth: 110
                    model: ["AND", "OR", "AND NOT"]
                    currentIndex: Math.max(0, Math.min(2, root.loadValue("op" + index, 1) - 1))
                    onActivated: root.saveValue("op" + index, currentIndex + 1)
                }
            }
        }
    }

    onChannelIndexChanged: localConditionCount = loadValue("conditionCount", 1)
}
