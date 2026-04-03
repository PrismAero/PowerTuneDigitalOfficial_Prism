import QtQuick

Item {
    id: root

    property var config: ({})
    property real gearFontSize: config.gearFontSize !== undefined ? Number(config.gearFontSize) : 160.0
    property string gearKey: config.gearKey !== undefined ? config.gearKey : "Gear"
    property color gearTextColor: config.gearTextColor !== undefined ? config.gearTextColor : "#FFFFFF"
    property real liveGear: 0
    property real suffixFontSize: config.suffixFontSize !== undefined ? Number(config.suffixFontSize) : 52.505

    function readValue() {
        if (!PropertyRouter || !PropertyRouter.hasProperty(gearKey))
            return 0;
        const value = Number(PropertyRouter.getValue(gearKey));
        return isNaN(value) ? 0 : value;
    }

    Component.onCompleted: liveGear = readValue()
    onGearKeyChanged: liveGear = readValue()

    Connections {
        function onValueChanged(propertyName, value) {
            if (propertyName === root.gearKey) {
                const numericValue = Number(value);
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
            anchors.horizontalCenterOffset: ShiftHelper.gearSuffixText(root.liveGear) === "" ? 0 : -18
            color: root.gearTextColor
            font.bold: true
            font.family: "Hyperspace Race"
            font.pixelSize: root.gearFontSize
            text: ShiftHelper.gearMainText(root.liveGear)
        }

        Text {
            anchors.bottom: mainGear.bottom
            anchors.left: mainGear.right
            anchors.leftMargin: 4
            color: root.gearTextColor
            font.bold: true
            font.family: "Hyperspace Race"
            font.pixelSize: root.suffixFontSize
            text: ShiftHelper.gearSuffixText(root.liveGear)
            visible: text.length > 0
        }
    }
}
