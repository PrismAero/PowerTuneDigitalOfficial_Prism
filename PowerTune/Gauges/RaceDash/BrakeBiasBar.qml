import QtQuick 2.15

Item {
    id: root

    property var config: ({})
    property string sensorKey: config.sensorKey !== undefined ? config.sensorKey : ""
    property string leftLabel: config.leftLabel !== undefined ? config.leftLabel : "RWD"
    property string rightLabel: config.rightLabel !== undefined ? config.rightLabel : "FWD"
    property real minValue: config.minValue !== undefined ? Number(config.minValue) : 0
    property real maxValue: config.maxValue !== undefined ? Number(config.maxValue) : 100

    property real liveValue: 50

    function readValue() {
        if (!sensorKey || !PropertyRouter || !PropertyRouter.hasProperty(sensorKey))
            return (minValue + maxValue) / 2
        var value = Number(PropertyRouter.getValue(sensorKey))
        return isNaN(value) ? (minValue + maxValue) / 2 : value
    }

    readonly property real progress: {
        if (maxValue <= minValue)
            return 0.5
        return Math.max(0, Math.min(1, (liveValue - minValue) / (maxValue - minValue)))
    }

    Component.onCompleted: liveValue = readValue()

    Connections {
        target: PropertyRouter

        function onValueChanged(propertyName, value) {
            if (propertyName === root.sensorKey) {
                var numericValue = Number(value)
                root.liveValue = isNaN(numericValue) ? root.liveValue : numericValue
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.pixelSize: 40
        font.italic: true
        text: "BRAKE BIAS"
    }

    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.pixelSize: 32
        text: root.leftLabel
    }

    Text {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        color: "#FFFFFF"
        font.family: "Hyperspace Race"
        font.pixelSize: 32
        text: root.rightLabel
    }

    Rectangle {
        id: biasTrack
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        width: 223
        height: 19
        radius: 9
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#FF0909" }
            GradientStop { position: 0.5; color: "#1ED033" }
            GradientStop { position: 1.0; color: "#FF0909" }
        }
    }

    Rectangle {
        id: biasPointer
        width: 3
        height: 30
        color: '#ff0000'
        anchors.bottom: biasTrack.bottom
        x: biasTrack.x + progress * biasTrack.width - width / 2
    }

    Rectangle {
        width: 8
        height: 8
        radius: 4
        color: '#ff0000'
        anchors.horizontalCenter: biasPointer.horizontalCenter
        anchors.bottom: parent.bottom
    }
}
