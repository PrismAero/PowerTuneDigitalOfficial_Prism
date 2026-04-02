// Copyright (c) 2026 Kai Wyborny. All rights reserved.
import QtQuick

Item {
    id: numericPad

    property real actionColumnRatio: 0.85
    property real actionColumnWidth: (width - keySpacing * 3) / (3 + actionColumnRatio) * actionColumnRatio
    property real cellHeight: Math.max((height - keySpacing * 3) / 4, KeyboardTheme.controlHeight)

    // Calculate key dimensions based on available width/height
    // Number columns are wider, action column is slightly narrower
    property real keySpacing: KeyboardTheme.keySpacing
    property real numColumnWidth: (width - keySpacing * 3 - actionColumnWidth) / 3

    signal backspacePressed
    signal clearPressed
    signal enterPressed
    signal keyPressed(string value)
    signal switchLayout

    anchors.bottom: parent ? parent.bottom : undefined
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    anchors.top: parent ? parent.top : undefined

    // Compact width - do not stretch to full parent width (iOS-style)
    width: Math.min(parent ? parent.width : 480, 480)

    Row {
        anchors.fill: parent
        spacing: 0

        // Number keys grid (3 columns)
        Grid {
            id: numberGrid

            columns: 3
            height: parent.height
            spacing: numericPad.keySpacing
            width: numericPad.numColumnWidth * 3 + numericPad.keySpacing * 2

            // Row 1: 7 8 9
            KeyButton {
                height: numericPad.cellHeight
                text: "7"
                width: numericPad.numColumnWidth

                onKeyPressed: function (value) {
                    numericPad.keyPressed(value);
                }
            }

            KeyButton {
                height: numericPad.cellHeight
                text: "8"
                width: numericPad.numColumnWidth

                onKeyPressed: function (value) {
                    numericPad.keyPressed(value);
                }
            }

            KeyButton {
                height: numericPad.cellHeight
                text: "9"
                width: numericPad.numColumnWidth

                onKeyPressed: function (value) {
                    numericPad.keyPressed(value);
                }
            }

            // Row 2: 4 5 6
            KeyButton {
                height: numericPad.cellHeight
                text: "4"
                width: numericPad.numColumnWidth

                onKeyPressed: function (value) {
                    numericPad.keyPressed(value);
                }
            }

            KeyButton {
                height: numericPad.cellHeight
                text: "5"
                width: numericPad.numColumnWidth

                onKeyPressed: function (value) {
                    numericPad.keyPressed(value);
                }
            }

            KeyButton {
                height: numericPad.cellHeight
                text: "6"
                width: numericPad.numColumnWidth

                onKeyPressed: function (value) {
                    numericPad.keyPressed(value);
                }
            }

            // Row 3: 1 2 3
            KeyButton {
                height: numericPad.cellHeight
                text: "1"
                width: numericPad.numColumnWidth

                onKeyPressed: function (value) {
                    numericPad.keyPressed(value);
                }
            }

            KeyButton {
                height: numericPad.cellHeight
                text: "2"
                width: numericPad.numColumnWidth

                onKeyPressed: function (value) {
                    numericPad.keyPressed(value);
                }
            }

            KeyButton {
                height: numericPad.cellHeight
                text: "3"
                width: numericPad.numColumnWidth

                onKeyPressed: function (value) {
                    numericPad.keyPressed(value);
                }
            }

            // Row 4: - 0 .
            KeyButton {
                height: numericPad.cellHeight
                text: "-"
                width: numericPad.numColumnWidth

                onKeyPressed: function (value) {
                    numericPad.keyPressed(value);
                }
            }

            KeyButton {
                height: numericPad.cellHeight
                text: "0"
                width: numericPad.numColumnWidth

                onKeyPressed: function (value) {
                    numericPad.keyPressed(value);
                }
            }

            KeyButton {
                height: numericPad.cellHeight
                text: "."
                width: numericPad.numColumnWidth

                onKeyPressed: function (value) {
                    numericPad.keyPressed(value);
                }
            }
        }

        // Vertical divider between number keys and action column
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            color: KeyboardTheme.borderStrong
            height: parent.height
            width: 1
        }

        // Spacer for the remaining gap
        Item {
            height: parent.height
            width: numericPad.keySpacing - 1
        }

        // Action column (backspace, clear, ABC, done)
        Column {
            height: parent.height
            spacing: numericPad.keySpacing
            width: numericPad.actionColumnWidth

            KeyButton {
                height: numericPad.cellHeight
                iconName: "backspace"
                iconSize: 20
                isDestructive: true
                keyValue: "backspace"
                repeatEnabled: true
                width: numericPad.actionColumnWidth

                onKeyPressed: numericPad.backspacePressed()
            }

            KeyButton {
                height: numericPad.cellHeight
                iconName: "clear_all"
                iconSize: 20
                isDestructive: true
                keyValue: "clear"
                width: numericPad.actionColumnWidth

                onKeyPressed: numericPad.clearPressed()
            }

            KeyButton {
                fontSize: KeyboardTheme.fontAction
                height: numericPad.cellHeight
                keyValue: "switchLayout"
                text: "ABC"
                width: numericPad.actionColumnWidth

                onKeyPressed: numericPad.switchLayout()
            }

            KeyButton {
                height: numericPad.cellHeight
                iconName: "check"
                iconSize: 22
                isAccent: true
                keyValue: "enter"
                width: numericPad.actionColumnWidth

                onKeyPressed: numericPad.enterPressed()
            }
        }
    }
}
