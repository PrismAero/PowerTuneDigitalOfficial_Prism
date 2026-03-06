import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    width: 160
    height: 80
    color: GaugeTheme.bgPanel
    border.width: GaugeTheme.borderWidth
    border.color: GaugeTheme.borderColor

    property string information: "Numeric cell"
    property string mainvaluename
    property double mainvalue: 0
    property double warnvaluehigh: 20000
    property double warnvaluelow: -20000
    property int decimalpoints: 0
    property string unittext: ""
    property string labeltext: ""
    property color labelColor: GaugeTheme.textSecondary
    property color valueColor: GaugeTheme.textPrimary
    property color unitColor: GaugeTheme.textAccent
    property string increasedecreaseident

    Drag.active: true

    Connections {
        target: UI
        function onDraggableChanged() { mouseHandler.enabled = (UI.draggable === 1); }
    }

    Component.onCompleted: {
        if (mainvaluename)
            mainvalue = Qt.binding(function() { return PropertyRouter.getValue(mainvaluename); });
    }

    GaugeMouseHandler {
        id: mouseHandler
        dragTarget: root
        onConfigRequested: function(mx, my) { configMenu.show(mx, my); }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 4

        Text {
            width: parent.width
            text: root.labeltext
            font.pixelSize: root.height * 0.18 * GaugeTheme.fontSizeMultiplier
            font.family: GaugeTheme.fontFamily
            font.weight: Font.Medium
            font.capitalization: Font.AllUppercase
            color: root.labelColor
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
        }

        Item {
            width: parent.width
            height: parent.height * 0.55

            Text {
                id: valueText
                anchors.left: parent.left
                anchors.baseline: parent.bottom
                text: root.mainvalue.toFixed(root.decimalpoints)
                font.pixelSize: root.height * 0.5 * GaugeTheme.fontSizeMultiplier
                font.family: GaugeTheme.fontFamilyMono
                font.weight: Font.Bold
                color: root.valueColor
            }

            Text {
                anchors.left: valueText.right
                anchors.leftMargin: 4
                anchors.baseline: valueText.baseline
                text: root.unittext
                font.pixelSize: root.height * 0.2 * GaugeTheme.fontSizeMultiplier
                font.family: GaugeTheme.fontFamily
                font.weight: Font.Normal
                color: root.unitColor
                visible: text.length > 0
            }
        }
    }

    Rectangle {
        id: warningOverlay
        anchors.fill: parent
        color: "transparent"
        border.width: 2
        border.color: GaugeTheme.warningColor
        opacity: 0
        visible: opacity > 0

        SequentialAnimation on opacity {
            running: root.mainvalue > root.warnvaluehigh || root.mainvalue < root.warnvaluelow
            loops: Animation.Infinite
            NumberAnimation { to: 0.8; duration: GaugeTheme.warningFlashDuration }
            NumberAnimation { to: 0.0; duration: GaugeTheme.warningFlashDuration }
        }
    }

    Accessible.role: Accessible.Indicator
    Accessible.name: root.labeltext || root.information
    Accessible.description: root.mainvalue.toFixed(root.decimalpoints)

    GaugeConfigMenu {
        id: configMenu
        target: root
        onDeleteRequested: root.destroy()
    }
}
