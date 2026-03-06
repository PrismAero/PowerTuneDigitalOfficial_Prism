import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: root
    width: 200
    height: 200

    property string information: "Arc fill gauge"
    property string mainvaluename
    property double mainvalue: 0
    property double maxvalue: 100
    property double minvalue: 0
    property double warnvaluehigh: 20000
    property double warnvaluelow: -20000
    property int decimalpoints: 0
    property string unittext: ""
    property string labeltext: ""
    property color arcTrackColor: GaugeTheme.arcTrack
    property color arcFillColor: GaugeTheme.arcFill
    property color arcDangerColor: GaugeTheme.arcDanger
    property color valueTextColor: GaugeTheme.textPrimary
    property color labelTextColor: GaugeTheme.textSecondary
    property color unitTextColor: GaugeTheme.textAccent
    property real arcStartAngle: -225
    property real arcEndAngle: 45
    property real arcStrokeWidth: 12
    property real dangerThreshold: 0.85
    property string increasedecreaseident

    Drag.active: true

    readonly property real _range: maxvalue - minvalue
    readonly property real _fraction: _range > 0 ? Math.max(0, Math.min(1, (mainvalue - minvalue) / _range)) : 0
    readonly property real _sweepTotal: arcEndAngle - arcStartAngle
    readonly property real _valueSweep: _fraction * _sweepTotal
    readonly property bool _inDanger: _fraction >= dangerThreshold

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

    Shape {
        id: trackShape
        anchors.fill: parent
        anchors.margins: arcStrokeWidth / 2

        ShapePath {
            strokeWidth: root.arcStrokeWidth
            strokeColor: root.arcTrackColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: trackShape.width / 2
                centerY: trackShape.height / 2
                radiusX: trackShape.width / 2 - root.arcStrokeWidth / 2
                radiusY: trackShape.height / 2 - root.arcStrokeWidth / 2
                startAngle: root.arcStartAngle
                sweepAngle: root._sweepTotal
            }
        }
    }

    Shape {
        id: fillShape
        anchors.fill: trackShape

        ShapePath {
            strokeWidth: root.arcStrokeWidth
            strokeColor: root._inDanger ? root.arcDangerColor : root.arcFillColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            Behavior on strokeColor { ColorAnimation { duration: 150 } }

            PathAngleArc {
                centerX: fillShape.width / 2
                centerY: fillShape.height / 2
                radiusX: fillShape.width / 2 - root.arcStrokeWidth / 2
                radiusY: fillShape.height / 2 - root.arcStrokeWidth / 2
                startAngle: root.arcStartAngle
                sweepAngle: root._valueSweep
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.labeltext
            font.pixelSize: root.height * GaugeTheme.labelFontFactor * GaugeTheme.fontSizeMultiplier
            font.family: GaugeTheme.fontFamily
            font.weight: Font.Medium
            color: root.labelTextColor
            visible: text.length > 0
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.mainvalue.toFixed(root.decimalpoints)
            font.pixelSize: root.height * GaugeTheme.valueFontFactor * GaugeTheme.fontSizeMultiplier
            font.family: GaugeTheme.fontFamilyMono
            font.weight: Font.Bold
            color: root.valueTextColor
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.unittext
            font.pixelSize: root.height * GaugeTheme.unitFontFactor * GaugeTheme.fontSizeMultiplier
            font.family: GaugeTheme.fontFamily
            font.weight: Font.Normal
            color: root.unitTextColor
            visible: text.length > 0
        }
    }

    Rectangle {
        id: dangerBorder
        anchors.fill: parent
        color: "transparent"
        border.width: 3
        border.color: root.arcDangerColor
        radius: width / 2
        opacity: _inDanger ? 1 : 0
        visible: opacity > 0

        SequentialAnimation on opacity {
            running: root._inDanger && root.mainvalue > root.warnvaluehigh
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: GaugeTheme.warningFlashDuration }
            NumberAnimation { to: 1.0; duration: GaugeTheme.warningFlashDuration }
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
