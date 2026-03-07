import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0
import Qt.labs.settings 1.0

Rectangle {
    id: gauge
    width: parent.width * 0.125
    height: parent.height * 0.17
    color: "transparent"
    antialiasing: false
    Drag.active: true

    property string information: "Bar gauge"
    property string gaugename: ""
    property string mainvaluename
    property alias gaugetext: gaugetextfield.text
    property double gaugevalue: 0
    property double minvalue: 0
    property double maxvalue: 100
    property int decimalpoints: 0
    property double warnvaluehigh: 20000
    property double warnvaluelow: -20000

    property double gaugeScaleOffset
    property double scaleValue: gaugeSettings.scaleValueStored
    property double offsetValueMultiply: gaugeSettings.offsetValueMultiplyStored
    property double offsetValueDivide: gaugeSettings.offsetValueDivideStored

    Settings {
        id: gaugeSettings
        property double scaleValueStored
        property double offsetValueMultiplyStored
        property double offsetValueDivideStored
    }

    GaugeMouseHandler {
        id: mouseHandler
        dragTarget: gauge
        onConfigRequested: function(mx, my) { configMenu.show(mx, my); }
    }

    readonly property double _range: maxvalue - minvalue
    readonly property double _fraction: _range > 0 ? Math.max(0, Math.min(1, (gaugevalue - minvalue) / _range)) : 0

    Rectangle {
        id: barTrack
        anchors.fill: parent
        anchors.margins: 10
        color: "#1f1f1f"
        radius: 4

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height * gauge._fraction
            radius: 4
            color: Qt.rgba(gauge._fraction, 0, 1 - gauge._fraction, 1)
        }
    }

    Text {
        id: gaugetextfield
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 2
        font.pixelSize: Math.max(10, parent.height / 7)
        font.bold: true
        font.family: "Eurostile"
        color: "white"
        text: (decimalpoints > 0 ? gaugevalue.toFixed(decimalpoints) : gaugevalue) + " " + gaugename
    }

    function updateValueBinding() {
        if (mainvaluename === "")
            return;
        gaugevalue = Qt.binding(function() { return PropertyRouter.getValue(mainvaluename); });
    }

    Component.onCompleted: updateValueBinding()

    GaugeConfigMenu {
        id: configMenu
        target: gauge
        onDeleteRequested: gauge.destroy()

        DatasourceSection { target: gauge }
        RangeSection { target: gauge }
        SizeSection { target: gauge }
        LabelSection { target: gauge }
    }
}
