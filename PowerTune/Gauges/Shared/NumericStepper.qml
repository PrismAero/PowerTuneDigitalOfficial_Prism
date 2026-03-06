import QtQuick 2.15
import QtQuick.Controls 2.15

Row {
    id: root
    spacing: 2

    property real value: 0
    property real stepSize: 1
    property real minValue: -99999
    property real maxValue: 99999
    property bool editable: false
    property int buttonWidth: 40
    property int displayWidth: 60
    property int displayFontSize: 15

    signal valueChanged(real newValue)

    RoundButton {
        text: "-"
        width: root.buttonWidth
        height: width
        onClicked: _decrement()
        onPressAndHold: holdTimer.direction = -1
        onReleased: holdTimer.direction = 0
    }

    Loader {
        id: displayLoader
        width: root.displayWidth
        height: parent.height
        sourceComponent: root.editable ? editableDisplay : readonlyDisplay
    }

    Component {
        id: readonlyDisplay
        Text {
            text: root.value
            font.pixelSize: root.displayFontSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "black"
        }
    }

    Component {
        id: editableDisplay
        TextField {
            text: root.value
            font.pixelSize: root.displayFontSize
            horizontalAlignment: Text.AlignHCenter
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onTextChanged: {
                var v = parseFloat(text);
                if (!isNaN(v) && v !== root.value)
                    root._apply(v);
            }
        }
    }

    RoundButton {
        text: "+"
        width: root.buttonWidth
        height: width
        onClicked: _increment()
        onPressAndHold: holdTimer.direction = 1
        onReleased: holdTimer.direction = 0
    }

    Timer {
        id: holdTimer
        property int direction: 0
        interval: 80
        repeat: true
        running: direction !== 0
        onTriggered: {
            if (direction > 0) _increment();
            else _decrement();
        }
    }

    function _increment() {
        _apply(Math.min(value + stepSize, maxValue));
    }

    function _decrement() {
        _apply(Math.max(value - stepSize, minValue));
    }

    function _apply(v) {
        value = v;
        valueChanged(v);
    }
}
