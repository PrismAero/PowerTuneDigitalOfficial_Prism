// Copyright (c) 2026 Kai Wyborny. All rights reserved.
import QtQuick 2.15

Item {
    id: numericPad

    signal keyPressed(string value)
    signal backspacePressed()
    signal clearPressed()
    signal enterPressed()
    signal switchLayout()

    // Compact width - do not stretch to full parent width (iOS-style)
    width: Math.min(parent ? parent.width : 480, 480)
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    anchors.top: parent ? parent.top : undefined
    anchors.bottom: parent ? parent.bottom : undefined

    // Calculate key dimensions based on available width/height
    // Number columns are wider, action column is slightly narrower
    property real keySpacing: 4
    property real actionColumnRatio: 0.85
    property real numColumnWidth: (width - keySpacing * 3 - actionColumnWidth) / 3
    property real actionColumnWidth: (width - keySpacing * 3) / (3 + actionColumnRatio) * actionColumnRatio
    property real cellHeight: (height - keySpacing * 3) / 4

    Row {
        anchors.fill: parent
        spacing: 0

        // Number keys grid (3 columns)
        Grid {
            id: numberGrid
            width: numericPad.numColumnWidth * 3 + numericPad.keySpacing * 2
            height: parent.height
            columns: 3
            spacing: numericPad.keySpacing

            // Row 1: 7 8 9
            KeyButton {
                text: "7"
                width: numericPad.numColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: function(value) { numericPad.keyPressed(value) }
            }
            KeyButton {
                text: "8"
                width: numericPad.numColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: function(value) { numericPad.keyPressed(value) }
            }
            KeyButton {
                text: "9"
                width: numericPad.numColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: function(value) { numericPad.keyPressed(value) }
            }

            // Row 2: 4 5 6
            KeyButton {
                text: "4"
                width: numericPad.numColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: function(value) { numericPad.keyPressed(value) }
            }
            KeyButton {
                text: "5"
                width: numericPad.numColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: function(value) { numericPad.keyPressed(value) }
            }
            KeyButton {
                text: "6"
                width: numericPad.numColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: function(value) { numericPad.keyPressed(value) }
            }

            // Row 3: 1 2 3
            KeyButton {
                text: "1"
                width: numericPad.numColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: function(value) { numericPad.keyPressed(value) }
            }
            KeyButton {
                text: "2"
                width: numericPad.numColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: function(value) { numericPad.keyPressed(value) }
            }
            KeyButton {
                text: "3"
                width: numericPad.numColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: function(value) { numericPad.keyPressed(value) }
            }

            // Row 4: - 0 .
            KeyButton {
                text: "-"
                width: numericPad.numColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: function(value) { numericPad.keyPressed(value) }
            }
            KeyButton {
                text: "0"
                width: numericPad.numColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: function(value) { numericPad.keyPressed(value) }
            }
            KeyButton {
                text: "."
                width: numericPad.numColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: function(value) { numericPad.keyPressed(value) }
            }
        }

        // Vertical divider between number keys and action column
        Rectangle {
            width: 1
            height: parent.height
            color: "#2a3a5e"
            anchors.verticalCenter: parent.verticalCenter
        }

        // Spacer for the remaining gap
        Item {
            width: numericPad.keySpacing - 1
            height: parent.height
        }

        // Action column (backspace, clear, ABC, done)
        Column {
            width: numericPad.actionColumnWidth
            height: parent.height
            spacing: numericPad.keySpacing

            KeyButton {
                text: "<--"
                keyValue: "backspace"
                isDestructive: true
                repeatEnabled: true
                width: numericPad.actionColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: numericPad.backspacePressed()
            }
            KeyButton {
                text: "Clear"
                keyValue: "clear"
                isDestructive: true
                fontSize: 14
                width: numericPad.actionColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: numericPad.clearPressed()
            }
            KeyButton {
                text: "ABC"
                keyValue: "switchLayout"
                fontSize: 14
                width: numericPad.actionColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: numericPad.switchLayout()
            }
            KeyButton {
                text: "Done"
                keyValue: "enter"
                isAccent: true
                fontSize: 14
                width: numericPad.actionColumnWidth
                height: numericPad.cellHeight
                onKeyPressed: numericPad.enterPressed()
            }
        }
    }
}
