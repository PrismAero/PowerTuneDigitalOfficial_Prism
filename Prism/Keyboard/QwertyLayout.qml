// Copyright (c) 2026 Kai Wyborny. All rights reserved.
import QtQuick 2.15

Item {
    id: qwertyLayout

    property bool shiftActive: false

    signal keyPressed(string value)
    signal backspacePressed()
    signal enterPressed()
    signal switchLayout()

    // Calculate key dimensions based on available width
    property real keySpacing: 4
    property real standardKeyWidth: (width - keySpacing * 9) / 10
    property real rowHeight: (height - keySpacing * 3) / 4

    Column {
        anchors.fill: parent
        spacing: keySpacing

        // Row 1: q w e r t y u i o p (10 keys)
        Row {
            spacing: qwertyLayout.keySpacing
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
                KeyButton {
                    text: qwertyLayout.shiftActive ? modelData.toUpperCase() : modelData
                    keyValue: qwertyLayout.shiftActive ? modelData.toUpperCase() : modelData
                    width: qwertyLayout.standardKeyWidth
                    height: qwertyLayout.rowHeight
                    onKeyPressed: function(value) { qwertyLayout.keyPressed(value) }
                }
            }
        }

        // Row 2: a s d f g h j k l (9 keys, centered)
        Row {
            spacing: qwertyLayout.keySpacing
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
                KeyButton {
                    text: qwertyLayout.shiftActive ? modelData.toUpperCase() : modelData
                    keyValue: qwertyLayout.shiftActive ? modelData.toUpperCase() : modelData
                    width: qwertyLayout.standardKeyWidth
                    height: qwertyLayout.rowHeight
                    onKeyPressed: function(value) { qwertyLayout.keyPressed(value) }
                }
            }
        }

        // Row 3: Shift z x c v b n m Backspace (9 keys)
        Row {
            spacing: qwertyLayout.keySpacing
            anchors.horizontalCenter: parent.horizontalCenter

            KeyButton {
                text: "Shift"
                keyValue: "shift"
                fontSize: 12
                width: qwertyLayout.standardKeyWidth
                height: qwertyLayout.rowHeight
                isAccent: qwertyLayout.shiftActive
                onKeyPressed: qwertyLayout.shiftActive = !qwertyLayout.shiftActive
            }

            Repeater {
                model: ["z", "x", "c", "v", "b", "n", "m"]
                KeyButton {
                    text: qwertyLayout.shiftActive ? modelData.toUpperCase() : modelData
                    keyValue: qwertyLayout.shiftActive ? modelData.toUpperCase() : modelData
                    width: qwertyLayout.standardKeyWidth
                    height: qwertyLayout.rowHeight
                    onKeyPressed: function(value) { qwertyLayout.keyPressed(value) }
                }
            }

            KeyButton {
                text: "<--"
                keyValue: "backspace"
                isDestructive: true
                repeatEnabled: true
                fontSize: 12
                width: qwertyLayout.standardKeyWidth
                height: qwertyLayout.rowHeight
                onKeyPressed: qwertyLayout.backspacePressed()
            }
        }

        // Row 4: 123 Space . Done
        Row {
            spacing: qwertyLayout.keySpacing
            anchors.horizontalCenter: parent.horizontalCenter

            KeyButton {
                text: "123"
                keyValue: "switchLayout"
                fontSize: 14
                width: qwertyLayout.standardKeyWidth * 1.5
                height: qwertyLayout.rowHeight
                onKeyPressed: qwertyLayout.switchLayout()
            }

            KeyButton {
                text: " "
                keyValue: " "
                // Space bar takes remaining width: total - (123 key + . key + Done key + 3 spacings)
                width: qwertyLayout.width - (qwertyLayout.standardKeyWidth * 1.5) - (qwertyLayout.standardKeyWidth) - (qwertyLayout.standardKeyWidth * 1.5) - (qwertyLayout.keySpacing * 3)
                height: qwertyLayout.rowHeight
                onKeyPressed: function(value) { qwertyLayout.keyPressed(value) }
            }

            KeyButton {
                text: "."
                width: qwertyLayout.standardKeyWidth
                height: qwertyLayout.rowHeight
                onKeyPressed: function(value) { qwertyLayout.keyPressed(value) }
            }

            KeyButton {
                text: "Done"
                keyValue: "enter"
                isAccent: true
                fontSize: 14
                width: qwertyLayout.standardKeyWidth * 1.5
                height: qwertyLayout.rowHeight
                onKeyPressed: qwertyLayout.enterPressed()
            }
        }
    }
}
