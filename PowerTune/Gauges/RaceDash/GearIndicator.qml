import QtQuick 2.15

Item {
    id: root

    property var config: ({})
    property string gearKey: config.gearKey !== undefined ? config.gearKey : "Gear"
    property color gearTextColor: config.gearTextColor !== undefined ? config.gearTextColor : "#FFFFFF"
    property real gearFontSize: config.gearFontSize !== undefined ? Number(config.gearFontSize) : 140.013
    property real suffixFontSize: config.suffixFontSize !== undefined ? Number(config.suffixFontSize) : 52.505

    property real liveGear: 0

    function readValue() {
        if (!PropertyRouter || !PropertyRouter.hasProperty(gearKey))
            return 0
        var value = Number(PropertyRouter.getValue(gearKey))
        return isNaN(value) ? 0 : value
    }

    function mainText() {
        if (liveGear < 0)
            return "R"
        if (liveGear === 0)
            return "N"
        return Math.round(liveGear).toString()
    }

    function suffixText() {
        var rounded = Math.round(liveGear)
        if (rounded <= 0)
            return ""
        if (rounded % 10 === 1 && rounded % 100 !== 11)
            return "st"
        if (rounded % 10 === 2 && rounded % 100 !== 12)
            return "nd"
        if (rounded % 10 === 3 && rounded % 100 !== 13)
            return "rd"
        return "th"
    }

    Component.onCompleted: liveGear = readValue()

    Connections {
        target: PropertyRouter

        function onValueChanged(propertyName, value) {
            if (propertyName === root.gearKey) {
                var numericValue = Number(value)
                root.liveGear = isNaN(numericValue) ? 0 : numericValue
            }
        }
    }

    Item {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        Text {
            id: mainGear
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: suffixText() === "" ? 0 : -18
            color: root.gearTextColor
            font.family: "Hyperspace Race"
            font.pixelSize: root.gearFontSize
            font.bold: true
            text: root.mainText()
        }

        Text {
            visible: text.length > 0
            anchors.left: mainGear.right
            anchors.bottom: mainGear.bottom
            anchors.leftMargin: 4
            color: root.gearTextColor
            font.family: "Hyperspace Race"
            font.pixelSize: root.suffixFontSize
            font.bold: true
            text: root.suffixText()
        }
    }
}
