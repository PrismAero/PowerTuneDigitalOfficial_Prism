import QtQuick 2.15

Item {
    id: root

    property var config: ({})
    property real gearFontSize: config.gearFontSize !== undefined ? Number(config.gearFontSize) : 160.0
    property string gearKey: config.gearKey !== undefined ? config.gearKey : "Gear"
    property color gearTextColor: config.gearTextColor !== undefined ? config.gearTextColor : "#FFFFFF"
    property real liveGear: 0
    property real suffixFontSize: config.suffixFontSize !== undefined ? Number(config.suffixFontSize) : 52.505

    function mainText() {
        if (liveGear < 0)
            return "R";
        if (liveGear === 0)
            return "N";
        return Math.round(liveGear).toString();
    }

    function readValue() {
        if (!PropertyRouter || !PropertyRouter.hasProperty(gearKey))
            return 0;
        var value = Number(PropertyRouter.getValue(gearKey));
        return isNaN(value) ? 0 : value;
    }

    function suffixText() {
        var rounded = Math.round(liveGear);
        if (rounded <= 0)
            return "";
        if (rounded % 10 === 1 && rounded % 100 !== 11)
            return "st";
        if (rounded % 10 === 2 && rounded % 100 !== 12)
            return "nd";
        if (rounded % 10 === 3 && rounded % 100 !== 13)
            return "rd";
        return "th";
    }

    Component.onCompleted: liveGear = readValue()

    Connections {
        function onValueChanged(propertyName, value) {
            if (propertyName === root.gearKey) {
                var numericValue = Number(value);
                root.liveGear = isNaN(numericValue) ? 0 : numericValue;
            }
        }

        target: PropertyRouter
    }

    Item {
        anchors.centerIn: parent
        height: parent.height
        width: parent.width

        Text {
            id: mainGear

            anchors.centerIn: parent
            anchors.horizontalCenterOffset: suffixText() === "" ? 0 : -18
            color: root.gearTextColor
            font.bold: true
            font.family: "Hyperspace Race"
            font.pixelSize: root.gearFontSize
            text: root.mainText()
        }

        Text {
            anchors.bottom: mainGear.bottom
            anchors.left: mainGear.right
            anchors.leftMargin: 4
            color: root.gearTextColor
            font.bold: true
            font.family: "Hyperspace Race"
            font.pixelSize: root.suffixFontSize
            text: root.suffixText()
            visible: text.length > 0
        }
    }
}
