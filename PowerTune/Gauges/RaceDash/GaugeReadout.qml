import QtQuick 2.15

Item {
    id: root

    property real value: 0
    property int decimals: 0
    property string unit: ""
    property real stepSize: 1
    property color textColor: "#FFFFFF"
    property real valueScale: 0.213
    property real unitScale: 0.076
    property real offsetX: 0
    property real offsetY: 0
    property real unitOffsetX: 0
    property real unitOffsetY: 0
    property real spacing: 8

    readonly property real quantizedValue: {
        var numericStep = Number(stepSize)
        if (isNaN(numericStep) || numericStep <= 0)
            return value
        return Math.round(value / numericStep) * numericStep
    }

    function formattedValue() {
        return Number(quantizedValue).toFixed(Math.max(0, decimals))
    }

    Item {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.offsetX
        anchors.verticalCenterOffset: root.offsetY
        width: parent.width
        height: parent.height

        Column {
            spacing: root.spacing
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.textColor
                font.family: "Hyperspace Race"
                font.pixelSize: root.width * root.valueScale
                font.italic: false
                text: root.formattedValue()
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: root.unitOffsetX
                anchors.verticalCenterOffset: root.unitOffsetY
                visible: text.length > 0
                color: root.textColor
                font.family: "Hyperspace Race"
                font.pixelSize: root.width * root.unitScale
                font.italic: true
                text: root.unit
            }
        }
    }
}
