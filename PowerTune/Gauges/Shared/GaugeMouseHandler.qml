import QtQuick 2.15

Item {
    id: handler
    anchors.fill: parent
    z: 100

    property Item dragTarget: parent
    signal configRequested(real mouseX, real mouseY)

    property int _touchCounter: 0
    property real _lastTouchTime: 0

    Connections {
        target: UI
        function onDraggableChanged() { _syncEnabled(); }
    }

    Component.onCompleted: _syncEnabled()

    function _syncEnabled() {
        mouseArea.enabled = (UI.draggable === 1);
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        drag.target: handler.dragTarget
        enabled: false
        onPressed: function(mouse) {
            handler._touchCounter++;
            if (handler._touchCounter === 1) {
                handler._lastTouchTime = Date.now();
                doubleTapTimer.restart();
            } else if (handler._touchCounter === 2) {
                var elapsed = Date.now() - handler._lastTouchTime;
                handler._touchCounter = 0;
                doubleTapTimer.stop();
                if (elapsed <= 500)
                    handler.configRequested(mouse.x, mouse.y);
            }
        }
    }

    Timer {
        id: doubleTapTimer
        interval: 500
        repeat: false
        onTriggered: handler._touchCounter = 0
    }
}
