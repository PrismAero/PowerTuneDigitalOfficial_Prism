import QtQuick

Timer {
    id: root
    property bool active: false
    property bool flashEnabled: true
    property int flashRate: 200
    property bool phase: false

    interval: flashRate / 2
    running: active && flashEnabled
    repeat: true
    onTriggered: phase = !phase
    onActiveChanged: if (!active) phase = false
    onRunningChanged: if (!running) phase = false
}
