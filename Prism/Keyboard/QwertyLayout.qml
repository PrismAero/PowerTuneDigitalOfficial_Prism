// Copyright (c) 2026 Kai Wyborny. All rights reserved.
import QtQuick 2.15

Item {
    id: qwertyLayout

    // Calculate key dimensions based on available width
    property real keySpacing: KeyboardTheme.keySpacing
    property real rowHeight: Math.max((height - keySpacing * 3) / 4, KeyboardTheme.controlHeight)
    property bool shiftActive: false
    property real standardKeyWidth: (width - keySpacing * 9) / 10

    signal backspacePressed
    signal enterPressed
    signal keyPressed(string value)
    signal switchLayout

    Column {
        anchors.fill: parent
        spacing: keySpacing

        // Row 1: q w e r t y u i o p (10 keys)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: qwertyLayout.keySpacing

            Repeater {
                model: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]

                KeyButton {
                    height: qwertyLayout.rowHeight
                    keyValue: qwertyLayout.shiftActive ? modelData.toUpperCase() : modelData
                    text: qwertyLayout.shiftActive ? modelData.toUpperCase() : modelData
                    width: qwertyLayout.standardKeyWidth

                    onKeyPressed: function (value) {
                        qwertyLayout.keyPressed(value);
                    }
                }
            }
        }

        // Row 2: a s d f g h j k l (9 keys, centered)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: qwertyLayout.keySpacing

            Repeater {
                model: ["a", "s", "d", "f", "g", "h", "j", "k", "l"]

                KeyButton {
                    height: qwertyLayout.rowHeight
                    keyValue: qwertyLayout.shiftActive ? modelData.toUpperCase() : modelData
                    text: qwertyLayout.shiftActive ? modelData.toUpperCase() : modelData
                    width: qwertyLayout.standardKeyWidth

                    onKeyPressed: function (value) {
                        qwertyLayout.keyPressed(value);
                    }
                }
            }
        }

        // Row 3: Shift z x c v b n m Backspace (9 keys)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: qwertyLayout.keySpacing

            KeyButton {
                height: qwertyLayout.rowHeight
                iconName: qwertyLayout.shiftActive ? "keyboard_capslock" : "shift"
                iconSize: 18
                isAccent: qwertyLayout.shiftActive
                keyValue: "shift"
                width: qwertyLayout.standardKeyWidth

                onKeyPressed: qwertyLayout.shiftActive = !qwertyLayout.shiftActive
            }

            Repeater {
                model: ["z", "x", "c", "v", "b", "n", "m"]

                KeyButton {
                    height: qwertyLayout.rowHeight
                    keyValue: qwertyLayout.shiftActive ? modelData.toUpperCase() : modelData
                    text: qwertyLayout.shiftActive ? modelData.toUpperCase() : modelData
                    width: qwertyLayout.standardKeyWidth

                    onKeyPressed: function (value) {
                        qwertyLayout.keyPressed(value);
                    }
                }
            }

            KeyButton {
                height: qwertyLayout.rowHeight
                iconName: "backspace"
                iconSize: 18
                isDestructive: true
                keyValue: "backspace"
                repeatEnabled: true
                width: qwertyLayout.standardKeyWidth

                onKeyPressed: qwertyLayout.backspacePressed()
            }
        }

        // Row 4: 123 Space . Done
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: qwertyLayout.keySpacing

            KeyButton {
                height: qwertyLayout.rowHeight
                iconName: "pin"
                iconSize: 18
                keyValue: "switchLayout"
                width: qwertyLayout.standardKeyWidth * 1.5

                onKeyPressed: qwertyLayout.switchLayout()
            }

            KeyButton {
                height: qwertyLayout.rowHeight
                keyValue: " "
                text: " "
                // Space bar takes remaining width: total - (123 key + . key + Done key + 3 spacings)
                width: qwertyLayout.width - (qwertyLayout.standardKeyWidth * 1.5) - (qwertyLayout.standardKeyWidth) - (
                           qwertyLayout.standardKeyWidth * 1.5) - (qwertyLayout.keySpacing * 3)

                onKeyPressed: function (value) {
                    qwertyLayout.keyPressed(value);
                }
            }

            KeyButton {
                height: qwertyLayout.rowHeight
                text: "."
                width: qwertyLayout.standardKeyWidth

                onKeyPressed: function (value) {
                    qwertyLayout.keyPressed(value);
                }
            }

            KeyButton {
                height: qwertyLayout.rowHeight
                iconName: "check"
                iconSize: 20
                isAccent: true
                keyValue: "enter"
                width: qwertyLayout.standardKeyWidth * 1.5

                onKeyPressed: qwertyLayout.enterPressed()
            }
        }
    }
}
