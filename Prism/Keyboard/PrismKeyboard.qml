// Copyright (c) 2026 Kai Wyborny. All rights reserved.
import QtQuick 2.15

Item {
    id: keyboard

    property Item target: null
    property string currentLayout: "numeric"
    property string fieldLabel: ""

    // Docked/popout mode
    property bool docked: true
    property real popoutX: parent ? parent.width / 2 - width / 2 : 0
    property real popoutY: parent ? parent.height / 2 - height / 2 : 0

    // Exposed visible height for content push (only when docked and visible)
    property real visibleHeight: visible && docked ? height : 0

    // Width depends on layout and dock mode
    width: {
        if (currentLayout === "numeric") {
            return Math.min(parent ? parent.width : 520, 520)
        }
        return parent ? parent.width : 520
    }
    anchors.horizontalCenter: docked ? parent.horizontalCenter : undefined

    // Height depends on layout
    height: currentLayout === "numeric" ? numericHeight : qwertyHeight

    property int numericHeight: Math.min(parent ? parent.height * 0.40 : 280, 280)
    property int qwertyHeight: Math.min(parent ? parent.height * 0.48 : 340, 340)

    visible: false
    y: parent ? parent.height : 0  // start off-screen
    z: 9999

    // Clip to prevent child elements from rendering outside keyboard bounds
    clip: true

    // Background
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: KeyboardTheme.surfaceElevated
        border.width: keyboard.docked ? KeyboardTheme.borderWidth : 2
        border.color: KeyboardTheme.borderStrong
        radius: keyboard.docked ? 0 : KeyboardTheme.radiusLarge

        // Top accent border line (teal separator)
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: keyboard.docked ? 0 : KeyboardTheme.radiusLarge
            anchors.leftMargin: keyboard.docked ? 0 : 2
            anchors.rightMargin: keyboard.docked ? 0 : 2
            height: 2
            color: KeyboardTheme.accent
            z: 1
        }

        // Top edge gradient glow below accent line
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: keyboard.docked ? 2 : KeyboardTheme.radiusLarge + 2
            anchors.leftMargin: keyboard.docked ? 0 : 2
            anchors.rightMargin: keyboard.docked ? 0 : 2
            height: 6
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#30009688" }
                GradientStop { position: 1.0; color: "#00009688" }
            }
            z: 1
        }

        // Input preview bar at top
        Rectangle {
            id: previewBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: keyboard.docked ? 1 : KeyboardTheme.radiusLarge + 1
            height: KeyboardTheme.previewBarHeight
            color: KeyboardTheme.previewBg

            // Drag handle indicator (only in popout mode)
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 3
                width: 40
                height: 4
                radius: 2
                color: KeyboardTheme.border
                visible: !keyboard.docked
            }

            Text {
                anchors.left: parent.left
                anchors.right: popoutButton.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                anchors.rightMargin: 6
                text: {
                    var label = keyboard.fieldLabel
                    var value = keyboard.target ? keyboard.target.text : ""
                    if (label !== "") return label + ": " + value
                    return value
                }
                color: KeyboardTheme.accent
                font.pixelSize: KeyboardTheme.fontPreview
                font.family: KeyboardTheme.fontFamily
                elide: Text.ElideLeft
                horizontalAlignment: Text.AlignHCenter
            }

            // Popout/dock toggle button
            Rectangle {
                id: popoutButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 6
                width: 28
                height: 22
                radius: KeyboardTheme.radiusSmall - 2
                color: popoutArea.pressed ? KeyboardTheme.surfacePressed : KeyboardTheme.surfaceElevated
                border.width: KeyboardTheme.borderWidth
                border.color: KeyboardTheme.border

                KeyIcon {
                    anchors.centerIn: parent
                    icon: keyboard.docked ? "open_in_full" : "close_fullscreen"
                    iconSize: 14
                    iconColor: KeyboardTheme.textSecondary
                }

                MouseArea {
                    id: popoutArea
                    anchors.fill: parent
                    onClicked: {
                        if (keyboard.docked) {
                            // Switch to popout mode
                            keyboard.docked = false
                        } else {
                            // Switch back to docked mode
                            keyboard.docked = true
                        }
                    }
                }
            }

            // Drag area for popout mode (covers preview bar except popout button)
            MouseArea {
                id: dragArea
                anchors.left: parent.left
                anchors.right: popoutButton.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                enabled: !keyboard.docked
                drag.target: keyboard
                drag.axis: Drag.XAndYAxis
                drag.minimumX: 0
                drag.minimumY: 0
                drag.maximumX: keyboard.parent ? keyboard.parent.width - keyboard.width : 0
                drag.maximumY: keyboard.parent ? keyboard.parent.height - keyboard.height : 0
                cursorShape: Qt.BlankCursor
            }
        }

        // Layout container
        Item {
            anchors.top: previewBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 6
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.bottomMargin: 8

            NumericPad {
                id: numPad
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
                y: keyboard.docked
                   ? keyboard.parent.height - keyboard.height
                   : keyboard.popoutY
            }
        },
        State {
            name: "hidden"
            when: !keyboard.visible
            PropertyChanges {
                target: keyboard
                y: keyboard.parent ? keyboard.parent.height : 0
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

    // Handle dock mode changes while visible
    onDockedChanged: {
        if (!visible) return
        if (docked) {
            // Re-anchor to bottom
            anchors.horizontalCenter = parent.horizontalCenter
            y = parent.height - height
        } else {
            // Float to center
            anchors.horizontalCenter = undefined
            x = popoutX
            y = popoutY
        }
    }

    // Shows the keyboard for the given text field, auto-detecting the appropriate layout.
    // Attempts to find the field label from placeholderText or sibling Text elements.
    function show(textField) {
        if (!isEditableTarget(textField))
            return
        target = textField

        // Try to get field context label
        fieldLabel = ""
        if (textField.placeholderText && textField.placeholderText !== "") {
            fieldLabel = textField.placeholderText
        } else if (textField.parent) {
            // Look for a Text/Label sibling in the parent
            for (var i = 0; i < textField.parent.children.length; i++) {
                var sibling = textField.parent.children[i]
                if (sibling !== textField && sibling.text !== undefined
                    && sibling.text !== "" && sibling.text !== textField.text) {
                    fieldLabel = sibling.text
                    break
                }
            }
        }

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
        fieldLabel = ""
    }

    // Inserts a character value at the current cursor position in the target field.
    function sendKey(value) {
        if (!target) return
        var pos = target.cursorPosition
        if (target.insert) {
            target.insert(pos, value)
        } else {
            var txt = target.text
            target.text = txt.substring(0, pos) + value + txt.substring(pos)
        }
        target.cursorPosition = pos + value.length
    }

    // Removes the character before the cursor position in the target field.
    function sendBackspace() {
        if (!target) return
        var pos = target.cursorPosition
        if (pos > 0) {
            if (target.remove) {
                target.remove(pos - 1, 1)
            } else {
                var txt = target.text
                target.text = txt.substring(0, pos - 1) + txt.substring(pos)
            }
            target.cursorPosition = pos - 1
        }
    }

    // Clears all text in the target field and resets cursor to position 0.
    function sendClear() {
        if (!target) return
        if (target.clear)
            target.clear()
        else
            target.text = ""
        target.cursorPosition = 0
    }

    function isEditableTarget(item) {
        if (!item)
            return false
        if (!item.hasOwnProperty("text"))
            return false
        if (!item.hasOwnProperty("cursorPosition"))
            return false
        if (item.hasOwnProperty("readOnly") && item.readOnly)
            return false
        if (item.hasOwnProperty("enabled") && !item.enabled)
            return false
        return true
    }
}
