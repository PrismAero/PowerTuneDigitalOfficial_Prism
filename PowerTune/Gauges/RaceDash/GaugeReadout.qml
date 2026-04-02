import QtQuick

Item {
    id: root

    property int decimals: 0
    property real offsetX: 0
    property real offsetY: 0
    readonly property real quantizedValue: {
        var numericStep = Number(stepSize);
        if (isNaN(numericStep) || numericStep <= 0)
            return value;
        return Math.round(value / numericStep) * numericStep;
    }
    property real spacing: 8
    property real stepSize: 1
    property color textColor: "#FFFFFF"
    property string unit: ""
    property real unitOffsetX: 0
    property real unitOffsetY: 0
    property real unitScale: 0.076
    property real value: 0
    property real valueScale: 0.213

    function formattedValue() {
        return Number(quantizedValue).toFixed(Math.max(0, decimals));
    }

    Item {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.offsetX
        anchors.verticalCenterOffset: root.offsetY
        height: parent.height
        width: parent.width

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: root.spacing

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.textColor
                font.family: "Hyperspace Race"
                font.italic: false
                font.pixelSize: root.width * root.valueScale
                text: root.formattedValue()
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: root.unitOffsetX
                anchors.verticalCenterOffset: root.unitOffsetY
                color: root.textColor
                font.family: "Hyperspace Race"
                font.italic: true
                font.pixelSize: root.width * root.unitScale
                text: root.unit
                visible: text.length > 0
            }
        }
    }
}
