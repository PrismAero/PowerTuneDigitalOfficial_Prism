import QtQuick 2.15

Item {
    id: root

    property var config: ({})
    property string leftLabel: config.leftLabel !== undefined ? config.leftLabel : "RWD"
    property real liveValue: 50
    property real maxValue: config.maxValue !== undefined ? Number(config.maxValue) : 100
    property real minValue: config.minValue !== undefined ? Number(config.minValue) : 0
    readonly property real progress: {
        if (maxValue <= minValue)
            return 0.5;
        return Math.max(0, Math.min(1, (liveValue - minValue) / (maxValue - minValue)));
    }
    property string rightLabel: config.rightLabel !== undefined ? config.rightLabel : "FWD"
    property string sensorKey: config.sensorKey !== undefined ? config.sensorKey : ""

    function readValue() {
        if (!sensorKey || !PropertyRouter || !PropertyRouter.hasProperty(sensorKey))
            return (minValue + maxValue) / 2;
        var value = Number(PropertyRouter.getValue(sensorKey));
        return isNaN(value) ? (minValue + maxValue) / 2 : value;
    }

    Component.onCompleted: liveValue = readValue()

    Connections {
        function onValueChanged(propertyName, value) {
            if (propertyName === root.sensorKey) {
                var numericValue = Number(value);
                root.liveValue = isNaN(numericValue) ? root.liveValue : numericValue;
            }
        }

        target: PropertyRouter
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.italic: true
        font.pixelSize: 40
        text: "BRAKE BIAS"
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.pixelSize: 32
        text: root.leftLabel
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.pixelSize: 32
        text: root.rightLabel
    }

    Rectangle {
        id: biasTrack

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        height: 19
        radius: 9
        width: 223

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                color: "#FF0909"
                position: 0.0
            }

            GradientStop {
                color: "#1ED033"
                position: 0.5
            }

            GradientStop {
                color: "#FF0909"
                position: 1.0
            }
        }
    }

    Rectangle {
        id: biasPointer

        anchors.bottom: biasTrack.bottom
        color: '#ff0000'
        height: 30
        width: 3
        x: biasTrack.x + progress * biasTrack.width - width / 2
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: biasPointer.horizontalCenter
        color: '#ff0000'
        height: 8
        radius: 4
        width: 8
    }
}
