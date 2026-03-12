// Copyright (c) 2026 Kai Wyborny. All rights reserved.
import QtQuick 2.15

Item {
    id: keyboard

    property string currentLayout: "numeric"

    // Docked/popout mode
    property bool docked: true
    property string fieldLabel: ""
    property int numericHeight: Math.min(parent ? parent.height * 0.40 : 280, 280)
    property real popoutX: parent ? parent.width / 2 - width / 2 : 0
    property real popoutY: parent ? parent.height / 2 - height / 2 : 0
    property int qwertyHeight: Math.min(parent ? parent.height * 0.48 : 340, 340)
    property Item target: null

    // Exposed visible height for content push (only when docked and visible)
    property real visibleHeight: visible && docked ? height : 0

    function ensureFieldVisible(field) {
        if (!field || !docked)
            return;
        var scrollable = findParentFlickable(field);
        if (!scrollable)
            return;
        var fieldRect = field.mapToItem(scrollable.contentItem, 0, 0);
        var fieldBottom = fieldRect.y + field.height;
        var visibleTop = scrollable.contentY;
        var visibleBottom = visibleTop + scrollable.height - height;

        if (fieldBottom > visibleBottom) {
            scrollable.contentY = fieldBottom - scrollable.height + height + 20;
        } else if (fieldRect.y < visibleTop) {
            scrollable.contentY = fieldRect.y - 20;
        }
    }

    function findParentFlickable(item) {
        var p = item.parent;
        while (p) {
            if (p.hasOwnProperty("contentY") && p.hasOwnProperty("contentHeight"))
                return p;
            p = p.parent;
        }
        return null;
    }

    // Hides the keyboard and clears the target reference.
    function hide() {
        visible = false;
        if (target) {
            target.focus = false;
        }
        target = null;
        fieldLabel = "";
    }

    function isEditableTarget(item) {
        if (!item)
            return false;
        if (!item.hasOwnProperty("text"))
            return false;
        if (!item.hasOwnProperty("cursorPosition"))
            return false;
        if (item.hasOwnProperty("readOnly") && item.readOnly)
            return false;
        if (item.hasOwnProperty("enabled") && !item.enabled)
            return false;
        return true;
    }

    // Removes the character before the cursor position in the target field.
    function sendBackspace() {
        if (!target)
            return;
        var pos = target.cursorPosition;
        if (pos > 0) {
            if (target.remove) {
                target.remove(pos - 1, pos);
            } else {
                var txt = target.text;
                target.text = txt.substring(0, pos - 1) + txt.substring(pos);
            }
            target.cursorPosition = pos - 1;
        }
    }

    // Clears all text in the target field and resets cursor to position 0.
    function sendClear() {
        if (!target)
            return;
        if (target.clear)
            target.clear();
        else
            target.text = "";
        target.cursorPosition = 0;
    }

    // Inserts a character value at the current cursor position in the target field.
    function sendKey(value) {
        if (!target)
            return;
        var pos = target.cursorPosition;
        if (target.insert) {
            target.insert(pos, value);
        } else {
            var txt = target.text;
            target.text = txt.substring(0, pos) + value + txt.substring(pos);
        }
        target.cursorPosition = pos + value.length;
    }

    // Shows the keyboard for the given text field, auto-detecting the appropriate layout.
    // Attempts to find the field label from placeholderText or sibling Text elements.
    function show(textField) {
        if (!isEditableTarget(textField))
            return;
        target = textField;

        // Try to get field context label
        fieldLabel = "";
        if (textField.placeholderText && textField.placeholderText !== "") {
            fieldLabel = textField.placeholderText;
        } else if (textField.parent) {
            // Look for a Text/Label sibling in the parent
            for (var i = 0; i < textField.parent.children.length; i++) {
                var sibling = textField.parent.children[i];
                if (sibling !== textField && sibling.text !== undefined && sibling.text !== "" && sibling.text
                        !== textField.text) {
                    fieldLabel = sibling.text;
                    break;
                }
            }
        }

        // Auto-detect layout from inputMethodHints
        if (textField.inputMethodHints & Qt.ImhDigitsOnly || textField.inputMethodHints & Qt.ImhFormattedNumbersOnly
                || textField.inputMethodHints & Qt.ImhPreferNumbers) {
            currentLayout = "numeric";
        } else {
            currentLayout = "qwerty";
        }
        visible = true;
        ensureFieldVisible(textField);
    }

    anchors.horizontalCenter: docked ? parent.horizontalCenter : undefined

    // Clip to prevent child elements from rendering outside keyboard bounds
    clip: true

    // Height depends on layout
    height: currentLayout === "numeric" ? numericHeight : qwertyHeight
    visible: false

    // Width depends on layout and dock mode
    width: {
        if (currentLayout === "numeric") {
            return Math.min(parent ? parent.width : 520, 520);
        }
        return parent ? parent.width : 520;
    }
    y: parent ? parent.height : 0  // start off-screen
    z: 9999

    // Show/hide animations
    states: [
        State {
            name: "visible"
            when: keyboard.visible

            PropertyChanges {
                target: keyboard
                y: keyboard.docked ? keyboard.parent.height - keyboard.height : keyboard.popoutY
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
            from: "hidden"
            to: "visible"

            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
                property: "y"
            }
        },
        Transition {
            from: "visible"
            to: "hidden"

            NumberAnimation {
                duration: 150
                easing.type: Easing.InCubic
                property: "y"
            }
        }
    ]

    // Handle dock mode changes while visible
    onDockedChanged: {
        if (!visible)
            return;
        if (docked) {
            // Re-anchor to bottom
            anchors.horizontalCenter = parent.horizontalCenter;
            y = parent.height - height;
        } else {
            // Float to center
            anchors.horizontalCenter = undefined;
            x = popoutX;
            y = popoutY;
        }
    }

    // Background
    Rectangle {
        id: backgroundRect

        anchors.fill: parent
        border.color: KeyboardTheme.borderStrong
        border.width: keyboard.docked ? KeyboardTheme.borderWidth : 2
        color: KeyboardTheme.surfaceElevated
        radius: keyboard.docked ? 0 : KeyboardTheme.radiusLarge

        // Top accent border line (teal separator)
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: keyboard.docked ? 0 : 2
            anchors.right: parent.right
            anchors.rightMargin: keyboard.docked ? 0 : 2
            anchors.top: parent.top
            anchors.topMargin: keyboard.docked ? 0 : KeyboardTheme.radiusLarge
            color: KeyboardTheme.accent
            height: 2
            z: 1
        }

        // Top edge gradient glow below accent line
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: keyboard.docked ? 0 : 2
            anchors.right: parent.right
            anchors.rightMargin: keyboard.docked ? 0 : 2
            anchors.top: parent.top
            anchors.topMargin: keyboard.docked ? 2 : KeyboardTheme.radiusLarge + 2
            height: 6
            z: 1

            gradient: Gradient {
                GradientStop {
                    color: "#30009688"
                    position: 0.0
                }

                GradientStop {
                    color: "#00009688"
                    position: 1.0
                }
            }
        }

        // Input preview bar at top
        Rectangle {
            id: previewBar

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: keyboard.docked ? 1 : KeyboardTheme.radiusLarge + 1
            color: KeyboardTheme.previewBg
            height: KeyboardTheme.previewBarHeight

            // Drag handle indicator (only in popout mode)
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 3
                color: KeyboardTheme.border
                height: 4
                radius: 2
                visible: !keyboard.docked
                width: 40
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: popoutButton.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                color: KeyboardTheme.accent
                elide: Text.ElideLeft
                font.family: KeyboardTheme.fontFamily
                font.pixelSize: KeyboardTheme.fontPreview
                horizontalAlignment: Text.AlignHCenter
                text: {
                    var label = keyboard.fieldLabel;
                    var value = keyboard.target ? keyboard.target.text : "";
                    if (label !== "")
                        return label + ": " + value;
                    return value;
                }
            }

            // Close/hide keyboard button
            Rectangle {
                id: closeButton

                anchors.right: parent.right
                anchors.rightMargin: KeyboardTheme.keySpacing
                anchors.verticalCenter: parent.verticalCenter
                border.color: KeyboardTheme.accentPressed
                border.width: KeyboardTheme.borderWidth
                color: closeArea.pressed ? KeyboardTheme.accentPressed : KeyboardTheme.accent
                height: Math.max(parent.height - 4, 28)
                radius: KeyboardTheme.radiusSmall - 2
                width: KeyboardTheme.controlHeight

                KeyIcon {
                    anchors.centerIn: parent
                    icon: "keyboard_hide"
                    iconColor: KeyboardTheme.textOnAccent
                    iconSize: 18
                }

                MouseArea {
                    id: closeArea

                    anchors.fill: parent

                    onClicked: keyboard.hide()
                }
            }

            // Popout/dock toggle button
            Rectangle {
                id: popoutButton

                anchors.right: closeButton.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                border.color: KeyboardTheme.border
                border.width: KeyboardTheme.borderWidth
                color: popoutArea.pressed ? KeyboardTheme.surfacePressed : KeyboardTheme.surfaceElevated
                height: 22
                radius: KeyboardTheme.radiusSmall - 2
                width: 28

                KeyIcon {
                    anchors.centerIn: parent
                    icon: keyboard.docked ? "open_in_full" : "close_fullscreen"
                    iconColor: KeyboardTheme.textSecondary
                    iconSize: 14
                }

                MouseArea {
                    id: popoutArea

                    anchors.fill: parent

                    onClicked: {
                        if (keyboard.docked) {
                            // Switch to popout mode
                            keyboard.docked = false;
                        } else {
                            // Switch back to docked mode
                            keyboard.docked = true;
                        }
                    }
                }
            }

            // Drag area for popout mode (covers preview bar except popout button)
            MouseArea {
                id: dragArea

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: popoutButton.left
                anchors.top: parent.top
                cursorShape: Qt.BlankCursor
                drag.axis: Drag.XAndYAxis
                drag.maximumX: keyboard.parent ? keyboard.parent.width - keyboard.width : 0
                drag.maximumY: keyboard.parent ? keyboard.parent.height - keyboard.height : 0
                drag.minimumX: 0
                drag.minimumY: 0
                drag.target: keyboard
                enabled: !keyboard.docked
            }
        }

        // Layout container
        Item {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: previewBar.bottom
            anchors.topMargin: 6

            NumericPad {
                id: numPad

                visible: keyboard.currentLayout === "numeric"

                onBackspacePressed: keyboard.sendBackspace()
                onClearPressed: keyboard.sendClear()
                onEnterPressed: keyboard.hide()
                onKeyPressed: function (value) {
                    keyboard.sendKey(value);
                }
                onSwitchLayout: keyboard.currentLayout = "qwerty"
            }

            QwertyLayout {
                id: qwertyPad

                anchors.fill: parent
                visible: keyboard.currentLayout === "qwerty"

                onBackspacePressed: keyboard.sendBackspace()
                onEnterPressed: keyboard.hide()
                onKeyPressed: function (value) {
                    keyboard.sendKey(value);
                }
                onSwitchLayout: keyboard.currentLayout = "numeric"
            }
        }
    }
}
