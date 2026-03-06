import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    width: 120
    height: 120
    color: GaugeTheme.bgPanel
    border.width: GaugeTheme.borderWidth
    border.color: GaugeTheme.borderColor
    radius: 8

    property string information: "Gear indicator"
    property string mainvaluename
    property int gearValue: 0
    property double warnvaluehigh: 20000
    property double warnvaluelow: -20000
    property color textColor: GaugeTheme.textPrimary
    property color labelColor: GaugeTheme.textSecondary
    property string increasedecreaseident

    Drag.active: true

    readonly property string _gearText: {
        if (gearValue === 0) return "N";
        if (gearValue < 0) return "R";
        return gearValue.toString();
    }

    Connections {
        target: UI
        function onDraggableChanged() { mouseHandler.enabled = (UI.draggable === 1); }
    }

    Component.onCompleted: {
        if (mainvaluename)
            gearValue = Qt.binding(function() { return PropertyRouter.getValue(mainvaluename); });
    }

    GaugeMouseHandler {
        id: mouseHandler
        dragTarget: root
        onConfigRequested: function(mx, my) { configMenu.show(mx, my); }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 4
        text: "GEAR"
        font.pixelSize: root.height * 0.12 * GaugeTheme.fontSizeMultiplier
        font.family: GaugeTheme.fontFamily
        font.weight: Font.Medium
        font.capitalization: Font.AllUppercase
        color: root.labelColor
    }

    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 6
        text: root._gearText
        font.pixelSize: root.height * 0.55 * GaugeTheme.fontSizeMultiplier
        font.family: GaugeTheme.fontFamilyMono
        font.weight: Font.Bold
        color: root.textColor
    }

    Accessible.role: Accessible.Indicator
    Accessible.name: "Gear"
    Accessible.value: root._gearText

    GaugeConfigMenu {
        id: configMenu
        target: root
        onDeleteRequested: root.destroy()
    }
}
