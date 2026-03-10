// Copyright (c) 2026 Kai Wyborny. All rights reserved.
import QtQuick 2.15

Rectangle {
    id: root

    property string text: ""
    property string keyValue: text
    property bool isAccent: false
    property bool isDestructive: false
    property real keyWidth: 1.0
    property int keyHeight: KeyboardTheme.controlHeight
    property int fontSize: KeyboardTheme.fontKey
    property bool repeatEnabled: false

    // Icon support: when iconName is set, a Material icon is shown instead of text
    property string iconName: ""
    property int iconSize: 20

    signal keyPressed(string value)

    width: keyWidth * 64  // base key width
    height: keyHeight
    radius: KeyboardTheme.radiusSmall
    color: {
        if (pressArea.pressed) {
            if (isAccent) return KeyboardTheme.accentPressed
            if (isDestructive) return KeyboardTheme.errorPressed
            return KeyboardTheme.surfacePressed
        }
        if (isAccent) return KeyboardTheme.accent
        if (isDestructive) return KeyboardTheme.error
        return KeyboardTheme.controlBg
    }
    border.width: KeyboardTheme.borderWidth
    border.color: KeyboardTheme.border

    Behavior on color { ColorAnimation { duration: KeyboardTheme.colorAnimationDuration } }

    scale: pressArea.pressed ? KeyboardTheme.pressScale : 1.0
    Behavior on scale { NumberAnimation { duration: KeyboardTheme.scaleAnimationDuration } }

    // Text label (visible when no icon is set)
    Text {
        anchors.centerIn: parent
        visible: root.iconName === ""
        text: root.text
        color: pressArea.pressed || root.isAccent || root.isDestructive
               ? KeyboardTheme.textOnAccent : KeyboardTheme.textPrimary
        font.pixelSize: root.fontSize
        font.family: KeyboardTheme.fontFamily
    }

    // Material icon (visible when iconName is set)
    KeyIcon {
        anchors.centerIn: parent
        visible: root.iconName !== ""
        icon: root.iconName
        iconSize: root.iconSize
        iconColor: pressArea.pressed || root.isAccent || root.isDestructive
                   ? KeyboardTheme.textOnAccent : KeyboardTheme.textPrimary
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        anchors.margins: -1  // 3px effective spacing (1px extra margin on each side)
        onClicked: root.keyPressed(root.keyValue)
        // Long-press repeat for backspace
        onPressAndHold: {
            if (root.repeatEnabled) {
                repeatTimer.start()
            }
        }
        onReleased: repeatTimer.stop()
        onCanceled: repeatTimer.stop()
    }

    Timer {
        id: repeatTimer
        interval: 100
        repeat: true
        onTriggered: root.keyPressed(root.keyValue)
    }
}
