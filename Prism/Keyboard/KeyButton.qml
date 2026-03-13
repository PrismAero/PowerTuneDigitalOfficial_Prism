// Copyright (c) 2026 Kai Wyborny. All rights reserved.
import QtQuick 2.15

Rectangle {
    id: root

    property int fontSize: KeyboardTheme.fontKey

    // Icon support: when iconName is set, a Material icon is shown instead of text
    property string iconName: ""
    property int iconSize: 20
    property bool isAccent: false
    property bool isDestructive: false
    property int keyHeight: KeyboardTheme.controlHeight
    property string keyValue: text
    property real keyWidth: 1.0
    property bool repeatEnabled: false
    property string text: ""

    signal keyPressed(string value)

    border.color: KeyboardTheme.border
    border.width: KeyboardTheme.borderWidth
    color: {
        if (pressArea.pressed) {
            if (isAccent)
                return KeyboardTheme.accentPressed;
            if (isDestructive)
                return KeyboardTheme.errorPressed;
            return KeyboardTheme.surfacePressed;
        }
        if (isAccent)
            return KeyboardTheme.accent;
        if (isDestructive)
            return KeyboardTheme.error;
        return KeyboardTheme.controlBg;
    }
    height: keyHeight
    radius: KeyboardTheme.radiusSmall
    scale: pressArea.pressed ? KeyboardTheme.pressScale : 1.0
    width: keyWidth * 64  // base key width

    Behavior on color {
        ColorAnimation {
            duration: KeyboardTheme.colorAnimationDuration
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: KeyboardTheme.scaleAnimationDuration
        }
    }

    // Text label (visible when no icon is set)
    Text {
        anchors.centerIn: parent
        color: pressArea.pressed || root.isAccent || root.isDestructive ? KeyboardTheme.textOnAccent :
                                                                          KeyboardTheme.textPrimary

        font.family: KeyboardTheme.fontFamily
        font.pixelSize: root.fontSize
        text: root.text
        visible: root.iconName === ""
    }

    // Material icon (visible when iconName is set)
    KeyIcon {
        anchors.centerIn: parent
        icon: root.iconName
        iconColor: pressArea.pressed || root.isAccent || root.isDestructive ? KeyboardTheme.textOnAccent :
                                                                              KeyboardTheme.textPrimary
        iconSize: root.iconSize
        visible: root.iconName !== ""
    }

    MouseArea {
        id: pressArea

        anchors.fill: parent
        anchors.margins: -1  // 3px effective spacing (1px extra margin on each side)

        onCanceled: repeatTimer.stop()
        onClicked: root.keyPressed(root.keyValue)
        // Long-press repeat for backspace
        onPressAndHold: {
            if (root.repeatEnabled) {
                repeatTimer.start();
            }
        }
        onReleased: repeatTimer.stop()
    }

    Timer {
        id: repeatTimer

        interval: 100
        repeat: true

        onTriggered: root.keyPressed(root.keyValue)
    }
}
