import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: root
    width: 300
    height: 300

    property string information: "Modern round gauge"
    property string mainvaluename
    property double mainvalue: 0
    property double maxvalue: 100
    property double minvalue: 0
    property double warnvaluehigh: 20000
    property double warnvaluelow: -20000
    property int decimalpoints: 0
    property string unittext: ""
    property string labeltext: ""
    property real startangle: -225
    property real endangle: 45
    property int tickcount: 10
    property int minortickcount: 4
    property real dangerStart: 0.85
    property color arcTrackColor: GaugeTheme.arcTrack
    property color arcFillColor: GaugeTheme.arcFill
    property color arcDangerColor: GaugeTheme.arcDanger
    property color needleColor: GaugeTheme.needlePrimary
    property color needleGlowColor: GaugeTheme.needleGlow
    property color textColor: GaugeTheme.textPrimary
    property color labelColor: GaugeTheme.textSecondary
    property color unitColor: GaugeTheme.textAccent
    property color tickColor: GaugeTheme.textDim
    property string increasedecreaseident

    Drag.active: true

    readonly property real _range: maxvalue - minvalue
    readonly property real _fraction: _range > 0 ? Math.max(0, Math.min(1, (mainvalue - minvalue) / _range)) : 0
    readonly property real _sweepTotal: endangle - startangle
    readonly property real _valueSweep: _fraction * _sweepTotal
    readonly property real _needleAngle: startangle + _valueSweep
    readonly property real _gaugeRadius: Math.min(width, height) / 2
    readonly property real _arcInset: _gaugeRadius * 0.12
    readonly property real _arcRadius: _gaugeRadius - _arcInset
    readonly property real _arcWidth: _gaugeRadius * 0.06

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
        id: trackArc
        anchors.fill: parent

        ShapePath {
            strokeWidth: root._arcWidth
            strokeColor: root.arcTrackColor
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root._arcRadius
                radiusY: root._arcRadius
                startAngle: root.startangle
                sweepAngle: root._sweepTotal
            }
        }
    }

    Shape {
        id: dangerArc
        anchors.fill: parent
        visible: root.dangerStart < 1.0

        ShapePath {
            strokeWidth: root._arcWidth
            strokeColor: root.arcDangerColor
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root._arcRadius
                radiusY: root._arcRadius
                startAngle: root.startangle + root.dangerStart * root._sweepTotal
                sweepAngle: (1.0 - root.dangerStart) * root._sweepTotal
            }
        }
    }

    Shape {
        id: fillArc
        anchors.fill: parent

        ShapePath {
            strokeWidth: root._arcWidth + 2
            strokeColor: root._fraction >= root.dangerStart ? root.arcDangerColor : root.arcFillColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root._arcRadius
                radiusY: root._arcRadius
                startAngle: root.startangle
                sweepAngle: root._valueSweep
            }
        }
    }

    Repeater {
        model: root.tickcount + 1
        delegate: Item {
            property real tickAngle: root.startangle + (index / root.tickcount) * root._sweepTotal
            property real tickAngleRad: tickAngle * Math.PI / 180
            property real outerR: root._arcRadius + root._arcWidth
            property real innerR: root._arcRadius + root._arcWidth + root._gaugeRadius * 0.06
            property real labelR: root._arcRadius + root._arcWidth + root._gaugeRadius * 0.14

            Rectangle {
                width: 2
                height: root._gaugeRadius * 0.06
                color: root.tickColor
                x: root.width / 2 + outerR * Math.cos(tickAngleRad) - width / 2
                y: root.height / 2 + outerR * Math.sin(tickAngleRad) - height / 2
                rotation: tickAngle + 90
                antialiasing: true
            }

            Text {
                property real tickValue: root.minvalue + (index / root.tickcount) * root._range
                text: tickValue.toFixed(0)
                font.pixelSize: root._gaugeRadius * 0.09 * GaugeTheme.fontSizeMultiplier
                font.family: GaugeTheme.fontFamily
                color: root.tickColor
                x: root.width / 2 + labelR * Math.cos(tickAngleRad) - implicitWidth / 2
                y: root.height / 2 + labelR * Math.sin(tickAngleRad) - implicitHeight / 2
            }
        }
    }

    Item {
        id: needleContainer
        x: root.width / 2
        y: root.height / 2
        rotation: root._needleAngle + 90

        Rectangle {
            id: needleGlow
            width: 6
            height: root._arcRadius * 0.85
            radius: 3
            color: root.needleGlowColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            antialiasing: true
        }

        Rectangle {
            id: needle
            width: 3
            height: root._arcRadius * 0.85
            radius: 1.5
            color: root.needleColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            antialiasing: true
        }

        Behavior on rotation { NumberAnimation { duration: 80; easing.type: Easing.OutQuad } }
    }

    Rectangle {
        id: hub
        width: root._gaugeRadius * 0.12
        height: width
        radius: width / 2
        color: root.needleColor
        anchors.centerIn: parent
        antialiasing: true
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root._gaugeRadius * 0.28
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.mainvalue.toFixed(root.decimalpoints)
            font.pixelSize: root._gaugeRadius * GaugeTheme.valueFontFactor * GaugeTheme.fontSizeMultiplier
            font.family: GaugeTheme.fontFamilyMono
            font.weight: Font.Bold
            color: root.textColor
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.unittext
            font.pixelSize: root._gaugeRadius * GaugeTheme.unitFontFactor * GaugeTheme.fontSizeMultiplier
            font.family: GaugeTheme.fontFamily
            color: root.unitColor
            visible: text.length > 0
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.labeltext
            font.pixelSize: root._gaugeRadius * GaugeTheme.labelFontFactor * GaugeTheme.fontSizeMultiplier
            font.family: GaugeTheme.fontFamily
            font.weight: Font.Medium
            color: root.labelColor
            visible: text.length > 0
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
