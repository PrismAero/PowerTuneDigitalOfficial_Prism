// Copyright (c) 2026 Kai Wyborny. All rights reserved.
import QtQuick 2.15

Item {
    id: keyboard

    property Item target: null
    property string currentLayout: "numeric"

    // Anchor to bottom of parent, full width
    anchors.left: parent.left
    anchors.right: parent.right
    // Height depends on layout
    height: currentLayout === "numeric" ? numericHeight : qwertyHeight

    property int numericHeight: Math.min(parent.height * 0.35, 240)
    property int qwertyHeight: Math.min(parent.height * 0.45, 300)

    visible: false
    y: parent.height  // start off-screen
    z: 9999

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"
        border.width: 1
        border.color: "#2a2a4e"

        // Input preview bar at top
        Rectangle {
            id: previewBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 32
            color: "#0f0f23"

            Text {
                anchors.centerIn: parent
                text: keyboard.target ? keyboard.target.text : ""
                color: "#009688"
                font.pixelSize: 16
                font.family: "Lato"
                elide: Text.ElideLeft
                width: parent.width - 20
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Layout container
        Item {
            anchors.top: previewBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 4

            NumericPad {
                id: numPad
                anchors.fill: parent
                visible: keyboard.currentLayout === "numeric"
                onKeyPressed: function(value) { keyboard.sendKey(value) }
                onBackspacePressed: keyboard.sendBackspace()
                onClearPressed: keyboard.sendClear()
                onEnterPressed: keyboard.hide()
                onSwitchLayout: keyboard.currentLayout = "qwerty"
            }

            QwertyLayout {
                id: qwertyPad
                anchors.fill: parent
                visible: keyboard.currentLayout === "qwerty"
                onKeyPressed: function(value) { keyboard.sendKey(value) }
                onBackspacePressed: keyboard.sendBackspace()
                onEnterPressed: keyboard.hide()
                onSwitchLayout: keyboard.currentLayout = "numeric"
            }
        }
    }

    // Show/hide animations
    states: [
        State {
            name: "visible"
            when: keyboard.visible
            PropertyChanges {
                target: keyboard
                y: keyboard.parent.height - keyboard.height
            }
        },
        State {
            name: "hidden"
            when: !keyboard.visible
            PropertyChanges {
                target: keyboard
                y: keyboard.parent.height
            }
        }
    ]

    transitions: [
        Transition {
            from: "hidden"; to: "visible"
            NumberAnimation { property: "y"; duration: 200; easing.type: Easing.OutCubic }
        },
        Transition {
            from: "visible"; to: "hidden"
            NumberAnimation { property: "y"; duration: 150; easing.type: Easing.InCubic }
        }
    ]

    // Shows the keyboard for the given text field, auto-detecting the appropriate layout.
    function show(textField) {
        target = textField
        // Auto-detect layout from inputMethodHints
        if (textField.inputMethodHints & Qt.ImhDigitsOnly ||
            textField.inputMethodHints & Qt.ImhFormattedNumbersOnly ||
            textField.inputMethodHints & Qt.ImhPreferNumbers) {
            currentLayout = "numeric"
        } else {
            currentLayout = "qwerty"
        }
        visible = true
    }

    // Hides the keyboard and clears the target reference.
    function hide() {
        visible = false
        if (target) {
            target.focus = false
        }
        target = null
    }

    // Inserts a character value at the current cursor position in the target field.
    function sendKey(value) {
        if (!target) return
        var pos = target.cursorPosition
        var txt = target.text
        target.text = txt.substring(0, pos) + value + txt.substring(pos)
        target.cursorPosition = pos + value.length
    }

    // Removes the character before the cursor position in the target field.
    function sendBackspace() {
        if (!target) return
        var pos = target.cursorPosition
        if (pos > 0) {
            var txt = target.text
            target.text = txt.substring(0, pos - 1) + txt.substring(pos)
            target.cursorPosition = pos - 1
        }
    }

    // Clears all text in the target field and resets cursor to position 0.
    function sendClear() {
        if (!target) return
        target.text = ""
        target.cursorPosition = 0
    }
}
