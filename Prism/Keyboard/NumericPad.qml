// Copyright (c) 2026 Kai Wyborny. All rights reserved.
import QtQuick 2.15

Item {
    id: numericPad

    signal keyPressed(string value)
    signal backspacePressed()
    signal clearPressed()
    signal enterPressed()
    signal switchLayout()

    // Calculate key dimensions based on available width/height
    property real keySpacing: 4
    property real cellWidth: (width - keySpacing * 3) / 4
    property real cellHeight: (height - keySpacing * 3) / 4

    Grid {
        id: grid
        anchors.fill: parent
        columns: 4
        spacing: keySpacing

        // Row 1: 7 8 9 Backspace
        KeyButton {
            text: "7"
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: function(value) { numericPad.keyPressed(value) }
        }
        KeyButton {
            text: "8"
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: function(value) { numericPad.keyPressed(value) }
        }
        KeyButton {
            text: "9"
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: function(value) { numericPad.keyPressed(value) }
        }
        KeyButton {
            text: "<--"
            keyValue: "backspace"
            isDestructive: true
            repeatEnabled: true
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: numericPad.backspacePressed()
        }

        // Row 2: 4 5 6 Clear
        KeyButton {
            text: "4"
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: function(value) { numericPad.keyPressed(value) }
        }
        KeyButton {
            text: "5"
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: function(value) { numericPad.keyPressed(value) }
        }
        KeyButton {
            text: "6"
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: function(value) { numericPad.keyPressed(value) }
        }
        KeyButton {
            text: "Clear"
            keyValue: "clear"
            isDestructive: true
            fontSize: 14
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: numericPad.clearPressed()
        }

        // Row 3: 1 2 3 ABC
        KeyButton {
            text: "1"
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: function(value) { numericPad.keyPressed(value) }
        }
        KeyButton {
            text: "2"
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: function(value) { numericPad.keyPressed(value) }
        }
        KeyButton {
            text: "3"
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: function(value) { numericPad.keyPressed(value) }
        }
        KeyButton {
            text: "ABC"
            keyValue: "switchLayout"
            fontSize: 14
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: numericPad.switchLayout()
        }

        // Row 4: - 0 . Done
        KeyButton {
            text: "-"
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: function(value) { numericPad.keyPressed(value) }
        }
        KeyButton {
            text: "0"
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: function(value) { numericPad.keyPressed(value) }
        }
        KeyButton {
            text: "."
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: function(value) { numericPad.keyPressed(value) }
        }
        KeyButton {
            text: "Done"
            keyValue: "enter"
            isAccent: true
            fontSize: 14
            keyWidth: 1.0
            width: numericPad.cellWidth
            height: numericPad.cellHeight
            onKeyPressed: numericPad.enterPressed()
        }
    }
}
