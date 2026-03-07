import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import PowerTune.Gauges.Core 1.0
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: roundGauge
    height: parent.height * (300 / parent.height)
    width: height
    color: "transparent"

    property string information: "Round gauge"
    property string mainvaluename
    property double mainvalue: 10
    property double maxvalue: 100
    property double minvalue: 0
    property double warnvaluehigh: 100
    property double warnvaluelow: 0
    property double redareastart: 0
    property double divider: 1
    property int needleTipWidth: 2
    property int needleLength: 100
    property int needleBaseWidth: 30
    property int needleinset: 0
    property int startangle: -140
    property int endangle: 140
    property int tickmarksteps: 10
    property int minortickmarksteps: 4
    property int setlabelsteps: 10
    property int setlabelinset: 55
    property int setminortickmarkinset: 55
    property int setmajortickmarkinset: 45
    property int redareainset: 30
    property int redareawidth: 10
    property string tickmarkcolor: GaugeTheme.textDim
    property string needlecolor: GaugeTheme.needlePrimary
    property string needlecolor2: GaugeTheme.needleSecondary
    property int decimalpoints: 0
    property string outerneedlecolortrail: "transparent"
    property string middleneedlecortrail: "transparent"
    property string outerneedlecolortrailsave: "transparent"
    property string middleneedlecortrailsave: "transparent"
    property string lowerneedlecolortrailsave: "transparent"
    property string innerneedlecolortrailsave: "transparent"
    property string lowerneedlecolortrail: "transparent"
    property string innerneedlecolortrail: "transparent"
    property string warningcolor: GaugeTheme.warningColor
    property int labelfontsize: 10
    property string labelcoloractive: GaugeTheme.textPrimary
    property string labelcolorinactive: GaugeTheme.textSecondary
    property string minortickmarkcoloractive: GaugeTheme.textPrimary
    property string minortickmarkcolorinactive: GaugeTheme.textSecondary
    property string majortickmarkcoloractive: GaugeTheme.textPrimary
    property string majortickmarkcolorinactive: GaugeTheme.textSecondary
    property int warningactive: 0
    property int minortickmarkheight: 10
    property int minortickmarkwidth: 2
    property int tickmarkheight: 10
    property int tickmarkwidth: 2
    property string increasedecreaseident
    property string backroundcolor: "transparent"
    property bool needlevisible: true
    property bool needlecentervisisble: true
    property bool ringvisible: true
    property double trailhighboarder: 0.5
    property double trailmidboarder: 0.45
    property double traillowboarder: 0.33
    property double trailbottomboarder: 0.20

    property string labelfont: "Eurostyle"
    property int desctextx: 50
    property int desctexty: 58
    property int desctextfontsize: 16
    property bool desctextfontbold: true
    property string desctextfonttype: "Eurostyle"
    property string desctextdisplaytext: ""
    property string desctextdisplaytextcolor: "white"

    property string peakneedlecolor
    property string peakneedlecolor2
    property string peakneedlelenght
    property string peakneedlebasewidth
    property string peakneedletipwidth
    property string peakneedleoffset
    property string peakneedlevisible

    Drag.active: true

    readonly property real outerRadius: gauge.width / 2

    function toPixels(percentage) {
        return percentage * outerRadius;
    }

    function valueToAngle(value) {
        var range = maxvalue - minvalue;
        if (range === 0)
            return startangle;
        var normalized = (value - minvalue) / range;
        return startangle + normalized * (endangle - startangle);
    }

    SequentialAnimation {
        id: intro
        running: true
        NumberAnimation {
            target: gauge
            property: "value"
            easing.type: Easing.InOutSine
            from: minvalue
            to: maxvalue
            duration: 1000
        }
        NumberAnimation {
            target: gauge
            property: "value"
            easing.type: Easing.InBack
            from: maxvalue
            to: minvalue
            duration: 1000
        }
    }

    GaugeMouseHandler {
        id: mouseHandler
        dragTarget: roundGauge
        onConfigRequested: function(mx, my) { configMenu.show(mx, my); }
    }

    CircularGauge {
        id: gauge
        height: parent.height * 0.9
        width: height
        value: roundGauge.mainvalue
        anchors.centerIn: parent
        maximumValue: maxvalue
        minimumValue: minvalue
        onValueChanged: warn()

        style: CircularGaugeStyle {
            labelStepSize: setlabelsteps
            labelInset: roundGauge.toPixels(setlabelinset * 0.01)
            tickmarkStepSize: tickmarksteps
            minorTickmarkCount: minortickmarksteps
            tickmarkInset: setmajortickmarkinset
            minorTickmarkInset: setminortickmarkinset
            minimumValueAngle: startangle
            maximumValueAngle: endangle

            needle: Item {
                visible: needlevisible
                y: roundGauge.outerRadius * (needleinset * 0.01)
                implicitWidth: roundGauge.outerRadius * (needleBaseWidth * 0.01)
                implicitHeight: roundGauge.outerRadius * (needleLength * 0.01)
                antialiasing: true

                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    anchors.right: parent.horizontalCenter
                    color: needlecolor2
                    antialiasing: true
                }
                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    anchors.left: parent.horizontalCenter
                    color: needlecolor
                    antialiasing: true
                }
            }

            foreground: Item {
                visible: needlecentervisisble
                Rectangle {
                    width: roundGauge.outerRadius * 0.2
                    height: width
                    radius: width / 2
                    color: "black"
                    border.color: "grey"
                    anchors.centerIn: parent
                }
            }

            background: Rectangle {
                implicitHeight: gauge.height
                implicitWidth: gauge.width
                color: backroundcolor
                anchors.centerIn: parent
                radius: 360

                Text {
                    x: ((roundGauge.height / 100) * desctextx).toFixed(0)
                    y: ((roundGauge.height / 100) * desctexty).toFixed(0)
                    text: desctextdisplaytext
                    color: desctextdisplaytextcolor
                    font.pixelSize: ((roundGauge.height / 200) * (desctextfontsize)).toFixed(0)
                    font.family: desctextfonttype
                    font.bold: desctextfontbold
                }

                Shape {
                    id: redZoneShape
                    anchors.fill: parent
                    visible: redareastart > 0

                    ShapePath {
                        strokeWidth: roundGauge.toPixels(redareawidth * 0.01)
                        strokeColor: "red"
                        fillColor: "transparent"
                        capStyle: ShapePath.FlatCap

                        PathAngleArc {
                            centerX: redZoneShape.width / 2
                            centerY: redZoneShape.height / 2
                            radiusX: roundGauge.outerRadius - roundGauge.toPixels(redareainset * 0.01) - roundGauge.toPixels(redareawidth * 0.01) / 2
                            radiusY: radiusX
                            startAngle: roundGauge.valueToAngle(redareastart) - 90
                            sweepAngle: roundGauge.valueToAngle(maxvalue) - roundGauge.valueToAngle(redareastart)
                        }
                    }
                }

                Shape {
                    id: outerTrail
                    anchors.fill: parent
                    visible: outerneedlecolortrail !== "transparent"
                    property real trailSweep: roundGauge.valueToAngle(gauge.value) - startangle

                    ShapePath {
                        strokeWidth: roundGauge.outerRadius * (trailhighboarder - trailbottomboarder)
                        strokeColor: outerneedlecolortrail
                        fillColor: "transparent"
                        capStyle: ShapePath.FlatCap

                        PathAngleArc {
                            centerX: outerTrail.width / 2
                            centerY: outerTrail.height / 2
                            radiusX: roundGauge.outerRadius * ((trailhighboarder + trailbottomboarder) / 2)
                            radiusY: radiusX
                            startAngle: startangle - 90
                            sweepAngle: outerTrail.trailSweep
                        }
                    }
                }
            }

            tickmarkLabel: Text {
                font.pixelSize: roundGauge.toPixels(labelfontsize * 0.01)
                text: divider !== 0 ? (styleData.value / divider) : styleData.value
                font.bold: true
                font.family: labelfont
                color: styleData.value <= gauge.value ? labelcoloractive : labelcolorinactive
                antialiasing: true
            }

            minorTickmark: Rectangle {
                implicitWidth: roundGauge.toPixels(minortickmarkwidth * 0.01)
                implicitHeight: roundGauge.toPixels(minortickmarkheight * 0.01)
                antialiasing: true
                smooth: true
                color: styleData.value <= gauge.value ? minortickmarkcoloractive : minortickmarkcolorinactive
            }

            tickmark: Rectangle {
                implicitWidth: roundGauge.toPixels(tickmarkwidth * 0.01)
                implicitHeight: roundGauge.toPixels(tickmarkheight * 0.01)
                antialiasing: true
                smooth: true
                color: styleData.value <= gauge.value ? majortickmarkcoloractive : majortickmarkcolorinactive
            }
        }
    }

    Image {
        id: ring
        anchors.fill: parent
        visible: ringvisible
        source: "qrc:/Resources/graphics/RoungGaugeRing.png"
    }

    GaugeConfigMenu {
        id: configMenu
        target: roundGauge
        onDeleteRequested: roundGauge.destroy()

        DatasourceSection { target: roundGauge }
        RangeSection { target: roundGauge }
        SizeSection { target: roundGauge }
        ArcSettingsSection { target: roundGauge }
        NeedleSection { target: roundGauge }
        NeedleTrailSection { target: roundGauge }
        TicksSection { target: roundGauge }
        LabelSection { target: roundGauge }
        WarningRedZoneSection { target: roundGauge }
        DescriptionSection { target: roundGauge }
        VisibilityTogglesSection {
            target: roundGauge
            toggleBindings: [
                { label: "Needle", prop: "needlevisible" },
                { label: "Needle Center", prop: "needlecentervisisble" },
                { label: "Ring", prop: "ringvisible" }
            ]
        }
        ColorsSection {
            target: roundGauge
            colorBindings: [
                { label: "Background", prop: "backroundcolor" }
            ]
        }
    }

    function warn() {
        if (gauge.value > roundGauge.warnvaluehigh || gauge.value < roundGauge.warnvaluelow) {
            roundGauge.warningcolor = "red";
            roundGauge.outerneedlecolortrail = "darkred";
            roundGauge.middleneedlecortrail = "red";
            roundGauge.lowerneedlecolortrail = "orange";
            roundGauge.innerneedlecolortrail = "transparent";
            warningactive = 1;
        } else {
            roundGauge.warningcolor = "transparent";
            roundGauge.outerneedlecolortrail = outerneedlecolortrailsave;
            roundGauge.middleneedlecortrail = middleneedlecortrailsave;
            roundGauge.lowerneedlecolortrail = lowerneedlecolortrailsave;
            roundGauge.innerneedlecolortrail = innerneedlecolortrailsave;
            warningactive = 0;
        }
    }

    function toggledecimal() {
    }

    function toggledecimal2() {
    }
}
