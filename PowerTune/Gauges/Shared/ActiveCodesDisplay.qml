import QtQuick 2.15

Item {
    id: root

    property var config: ({})
    property string sourceKey: config.sourceKey !== undefined ? config.sourceKey : "PTActiveCodes"
    property string textColor: config.textColor !== undefined ? config.textColor : "#F1E83C"
    property string noFaultsText: config.noFaultsText !== undefined ? config.noFaultsText : "No Faults"
    property string valueText: noFaultsText

    function refresh() {
        if (!PropertyRouter || !PropertyRouter.hasProperty(sourceKey)) {
            valueText = noFaultsText;
            return;
        }
        var value = String(PropertyRouter.getValue(sourceKey));
        valueText = value.length > 0 ? ("DFI " + value) : noFaultsText;
    }

    Component.onCompleted: refresh()
    onSourceKeyChanged: refresh()

    Connections {
        target: PropertyRouter
        function onValueChanged(propertyName, value) {
            if (propertyName === root.sourceKey)
                root.valueText = String(value).length > 0 ? ("DFI " + String(value)) : root.noFaultsText;
        }
    }

    Text {
        anchors.centerIn: parent
        color: root.textColor
        font.bold: true
        font.family: "Hyperspace Race"
        font.pixelSize: 24
        text: root.valueText
    }
}
