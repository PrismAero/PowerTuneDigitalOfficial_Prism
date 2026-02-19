// Copyright (c) 2026 Kai Wyborny. All rights reserved.
import QtQuick 2.15

Rectangle {
    id: root

    property string text: ""
    property string keyValue: text
    property bool isAccent: false
    property bool isDestructive: false
    property real keyWidth: 1.0
    property int keyHeight: 48
    property int fontSize: 18
    property bool repeatEnabled: false

    signal keyPressed(string value)

    width: keyWidth * 64  // base key width
    height: keyHeight
    radius: 6
    color: pressArea.pressed
           ? (isAccent ? "#00796b" : isDestructive ? "#4a1a1a" : "#1e3a5f")
           : (isAccent ? "#009688" : isDestructive ? "#5c2a2a" : "#16213e")
    border.width: 1
    border.color: "#0a0f1e"

    Behavior on color { ColorAnimation { duration: 80 } }

    scale: pressArea.pressed ? 0.95 : 1.0
    Behavior on scale { NumberAnimation { duration: 60 } }

    Text {
        anchors.centerIn: parent
        text: root.text
        color: pressArea.pressed || root.isAccent ? "#ffffff" : "#e0e0e0"
        font.pixelSize: root.fontSize
        font.family: "Lato"
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
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
