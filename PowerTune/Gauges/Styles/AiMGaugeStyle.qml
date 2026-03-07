import QtQuick 2.15
import QtQuick.Shapes 1.15
import PowerTune.Gauges.Core 1.0
import PowerTune.Gauges.Shared 1.0

CircularGaugeStyle {
    id: aimStyle

    minimumValueAngle: -130
    maximumValueAngle: 130
    tickmarkStepSize: 20
    labelStepSize: 20
    minorTickmarkCount: 3
    tickmarkInset: toPixels(0.05)
    minorTickmarkInset: tickmarkInset + toPixels(0.01)
    labelInset: toPixels(0.28)

    property real arcWidthFactor: 0.15
    property color arcTrackColor: GaugeTheme.aimArcTrack
    property color dangerColor: GaugeTheme.aimArcRed
    property var arcGradientStops: [
        { position: 0.00, color: GaugeTheme.aimArcGreen },
        { position: 0.45, color: GaugeTheme.aimArcYellowGreen },
        { position: 0.75, color: GaugeTheme.aimArcYellow },
        { position: 1.00, color: GaugeTheme.aimArcRed }
    ]
    property real dangerStartFraction: 0.85
    property color needleColor: GaugeTheme.aimNeedle
    property color needleGlowColor: GaugeTheme.aimNeedleGlow
    property real needleWidthFactor: 0.024
    property real needleLengthFactor: 0.82
    property color tickActiveColor: "#F0F0F0"
    property color tickInactiveColor: GaugeTheme.aimDimTick
    property color labelActiveColor: "#E0E0E0"
    property color labelInactiveColor: GaugeTheme.aimDimTick
    property color centerValueColor: GaugeTheme.aimValueWhite
    property color centerUnitColor: GaugeTheme.aimUnitGrey
    property string centerValueText: ""
    property string centerUnitText: ""
    property bool centerReadoutVisible: true
    property real labelDivisor: 1
    property int labelPrecision: 0
    property bool omitZeroLabel: false
    property string valueFontSource: "qrc:/Resources/fonts/hyperspacerace-compressedbold.otf"
    property string unitFontSource: "qrc:/Resources/fonts/hyperspacerace-regular.otf"
    property string labelFontSource: "qrc:/Resources/fonts/hyperspacerace-condensedbold.otf"

    readonly property real _arcWidth: outerRadius * arcWidthFactor
    readonly property real _arcRadius: outerRadius - outerRadius * 0.14
    readonly property real _sweepTotal: maximumValueAngle - minimumValueAngle
    readonly property real _fraction: {
        var range = maximumValue - minimumValue;
        if (range <= 0)
            return 0;
        return Math.max(0, Math.min(1, (value - minimumValue) / range));
    }
    readonly property int _segmentCount: 30

    function _interpolateColor(fraction) {
        var stops = arcGradientStops;
        if (stops.length === 0)
            return "#FFFFFF";
        if (fraction <= stops[0].position)
            return stops[0].color;
        if (fraction >= stops[stops.length - 1].position)
            return stops[stops.length - 1].color;
        for (var i = 0; i < stops.length - 1; ++i) {
            if (fraction >= stops[i].position && fraction <= stops[i + 1].position) {
                var span = stops[i + 1].position - stops[i].position;
                var t = span <= 0 ? 0 : (fraction - stops[i].position) / span;
                var c1 = stops[i].color;
                var c2 = stops[i + 1].color;
                return Qt.rgba(
                    c1.r + (c2.r - c1.r) * t,
                    c1.g + (c2.g - c1.g) * t,
                    c1.b + (c2.b - c1.b) * t,
                    1
                );
            }
        }
        return stops[stops.length - 1].color;
    }

    function _colorWithAlpha(fraction, alpha) {
        var c = _interpolateColor(fraction);
        return Qt.rgba(c.r, c.g, c.b, alpha);
    }

    background: Item {
        implicitWidth: outerRadius * 2
        implicitHeight: outerRadius * 2

        FontLoader { id: _valueFont; source: aimStyle.valueFontSource }
        FontLoader { id: _unitFont; source: aimStyle.unitFontSource }

        Rectangle {
            x: outerRadius * 0.03
            y: outerRadius * 0.06
            width: parent.width
            height: parent.height
            radius: width / 2
            color: GaugeTheme.aimGaugeShadow
            opacity: 0.85
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: GaugeTheme.aimGaugeFaceOuter
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 3
            radius: width / 2
            color: "transparent"
            border.width: 2
            border.color: GaugeTheme.aimBezelColor
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: outerRadius * 0.04
            radius: width / 2
            color: GaugeTheme.aimGaugeFaceInner
            border.width: 1
            border.color: GaugeTheme.aimGaugeInnerRing
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            gradient: Gradient {
                GradientStop { position: 0.0; color: GaugeTheme.aimGaugeSpecular }
                GradientStop { position: 0.30; color: GaugeTheme.aimGaugeSpecularSoft }
                GradientStop { position: 0.55; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.14) }
            }
        }

        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                strokeWidth: aimStyle._arcWidth + 6
                strokeColor: Qt.rgba(0, 0, 0, 0.5)
                fillColor: "transparent"
                capStyle: ShapePath.FlatCap

                PathAngleArc {
                    centerX: outerRadius
                    centerY: outerRadius
                    radiusX: aimStyle._arcRadius
                    radiusY: aimStyle._arcRadius
                    startAngle: aimStyle.minimumValueAngle - 90
                    sweepAngle: aimStyle._sweepTotal
                }
            }
        }

        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                strokeWidth: aimStyle._arcWidth + 2
                strokeColor: aimStyle.arcTrackColor
                fillColor: "transparent"
                capStyle: ShapePath.FlatCap

                PathAngleArc {
                    centerX: outerRadius
                    centerY: outerRadius
                    radiusX: aimStyle._arcRadius
                    radiusY: aimStyle._arcRadius
                    startAngle: aimStyle.minimumValueAngle - 90
                    sweepAngle: aimStyle._sweepTotal
                }
            }
        }

        Repeater {
            model: aimStyle._segmentCount

            Shape {
                anchors.fill: parent
                antialiasing: true
                visible: aimStyle._fraction > (index / aimStyle._segmentCount)

                ShapePath {
                    strokeWidth: aimStyle._arcWidth * 1.4
                    strokeColor: {
                        var mid = Math.min((index + 0.5) / aimStyle._segmentCount, aimStyle._fraction);
                        return aimStyle._colorWithAlpha(mid, 0.14);
                    }
                    fillColor: "transparent"
                    capStyle: ShapePath.FlatCap

                    PathAngleArc {
                        centerX: outerRadius
                        centerY: outerRadius
                        radiusX: aimStyle._arcRadius
                        radiusY: aimStyle._arcRadius
                        startAngle: {
                            var segStart = index / aimStyle._segmentCount;
                            return aimStyle.minimumValueAngle + segStart * aimStyle._sweepTotal - 90;
                        }
                        sweepAngle: {
                            var segStart = index / aimStyle._segmentCount;
                            var segEnd = (index + 1) / aimStyle._segmentCount;
                            var clampedEnd = Math.min(segEnd, aimStyle._fraction);
                            if (clampedEnd <= segStart)
                                return 0;
                            return (clampedEnd - segStart) * aimStyle._sweepTotal;
                        }
                    }
                }
            }
        }

        Repeater {
            model: aimStyle._segmentCount

            Shape {
                anchors.fill: parent
                antialiasing: true
                visible: aimStyle._fraction > (index / aimStyle._segmentCount)

                ShapePath {
                    strokeWidth: aimStyle._arcWidth
                    strokeColor: {
                        var mid = Math.min((index + 0.5) / aimStyle._segmentCount, aimStyle._fraction);
                        return aimStyle._interpolateColor(mid);
                    }
                    fillColor: "transparent"
                    capStyle: index === 0 ? ShapePath.RoundCap : ShapePath.FlatCap

                    PathAngleArc {
                        centerX: outerRadius
                        centerY: outerRadius
                        radiusX: aimStyle._arcRadius
                        radiusY: aimStyle._arcRadius
                        startAngle: {
                            var segStart = index / aimStyle._segmentCount;
                            return aimStyle.minimumValueAngle + segStart * aimStyle._sweepTotal - 90;
                        }
                        sweepAngle: {
                            var segStart = index / aimStyle._segmentCount;
                            var segEnd = (index + 1) / aimStyle._segmentCount;
                            var clampedEnd = Math.min(segEnd, aimStyle._fraction);
                            if (clampedEnd <= segStart)
                                return 0;
                            return (clampedEnd - segStart) * aimStyle._sweepTotal;
                        }
                    }
                }
            }
        }

        Repeater {
            model: aimStyle._segmentCount

            Shape {
                anchors.fill: parent
                antialiasing: true
                visible: aimStyle._fraction > (index / aimStyle._segmentCount)

                ShapePath {
                    strokeWidth: 2
                    strokeColor: {
                        var mid = Math.min((index + 0.5) / aimStyle._segmentCount, aimStyle._fraction);
                        return aimStyle._colorWithAlpha(mid, 0.80);
                    }
                    fillColor: "transparent"
                    capStyle: ShapePath.FlatCap

                    PathAngleArc {
                        centerX: outerRadius
                        centerY: outerRadius
                        radiusX: aimStyle._arcRadius - aimStyle._arcWidth * 0.30
                        radiusY: aimStyle._arcRadius - aimStyle._arcWidth * 0.30
                        startAngle: {
                            var segStart = index / aimStyle._segmentCount;
                            return aimStyle.minimumValueAngle + segStart * aimStyle._sweepTotal - 90;
                        }
                        sweepAngle: {
                            var segStart = index / aimStyle._segmentCount;
                            var segEnd = (index + 1) / aimStyle._segmentCount;
                            var clampedEnd = Math.min(segEnd, aimStyle._fraction);
                            if (clampedEnd <= segStart)
                                return 0;
                            return (clampedEnd - segStart) * aimStyle._sweepTotal;
                        }
                    }
                }
            }
        }

        Rectangle {
            width: outerRadius * 1.20
            height: outerRadius * 0.48
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: outerRadius * 0.12
            radius: width / 2
            color: Qt.rgba(1, 1, 1, 0.03)
            rotation: -8
        }

        Rectangle {
            width: outerRadius * 1.10
            height: outerRadius * 0.55
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: outerRadius * 0.20
            radius: width / 2
            color: Qt.rgba(0, 0, 0, 0.25)
        }

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: outerRadius * 0.14
            spacing: 1
            visible: aimStyle.centerReadoutVisible

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: aimStyle.centerValueText
                font.family: _valueFont.name
                font.pixelSize: {
                    if (aimStyle.centerValueText.length >= 4)
                        return outerRadius * 0.30;
                    return outerRadius * 0.42;
                }
                font.weight: Font.Bold
                color: aimStyle.centerValueColor
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: aimStyle.centerUnitText
                font.family: _unitFont.name
                font.pixelSize: outerRadius * 0.10
                font.letterSpacing: 1.5
                color: aimStyle.centerUnitColor
                horizontalAlignment: Text.AlignHCenter
                visible: aimStyle.centerUnitText !== ""
            }
        }
    }

    needle: Item {
        implicitWidth: outerRadius * aimStyle.needleWidthFactor
        implicitHeight: outerRadius * aimStyle.needleLengthFactor

        Rectangle {
            width: parent.width * 3
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            radius: width / 2
            color: Qt.rgba(aimStyle.needleColor.r, aimStyle.needleColor.g, aimStyle.needleColor.b, 0.20)
            antialiasing: true
        }

        Rectangle {
            width: parent.width
            height: parent.height * 0.70
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            radius: width / 2
            color: aimStyle.needleColor
            antialiasing: true
        }

        Rectangle {
            width: parent.width * 0.7
            height: parent.height * 0.35
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            radius: width / 2
            color: Qt.rgba(0.2, 0.2, 0.2, 0.9)
            antialiasing: true
        }
    }

    foreground: Item {
        Rectangle {
            width: outerRadius * 0.10
            height: width
            radius: width / 2
            anchors.centerIn: parent
            color: "#080808"
            border.width: 1
            border.color: GaugeTheme.aimPanelStrokeBright
            antialiasing: true
        }

        Rectangle {
            width: outerRadius * 0.035
            height: width
            radius: width / 2
            anchors.centerIn: parent
            color: aimStyle.needleColor
            antialiasing: true
        }
    }

    tickmark: Rectangle {
        implicitWidth: outerRadius * 0.012
        implicitHeight: outerRadius * 0.08
        radius: width / 2
        antialiasing: true
        color: {
            if (!styleData)
                return aimStyle.tickActiveColor;
            return styleData.value <= aimStyle.value ? aimStyle.tickActiveColor : aimStyle.tickInactiveColor;
        }
    }

    minorTickmark: Rectangle {
        implicitWidth: outerRadius * 0.006
        implicitHeight: outerRadius * 0.04
        radius: width / 2
        antialiasing: true
        color: {
            if (!styleData)
                return aimStyle.tickActiveColor;
            return styleData.value <= aimStyle.value ? Qt.rgba(1, 1, 1, 0.7) : aimStyle.tickInactiveColor;
        }
    }

    tickmarkLabel: Text {
        property var _labelFont: FontLoader { source: aimStyle.labelFontSource }

        font.family: _labelFont.name
        font.pixelSize: Math.max(8, outerRadius * 0.085)
        font.weight: Font.DemiBold
        text: {
            if (!styleData)
                return "";
            if (aimStyle.omitZeroLabel && styleData.value === aimStyle.minimumValue)
                return "";
            var displayValue = styleData.value / aimStyle.labelDivisor;
            if (aimStyle.labelPrecision === 0)
                return Math.round(displayValue).toString();
            return Number(displayValue).toFixed(aimStyle.labelPrecision);
        }
        color: {
            if (!styleData)
                return aimStyle.labelActiveColor;
            return styleData.value <= aimStyle.value ? aimStyle.labelActiveColor : aimStyle.labelInactiveColor;
        }
        antialiasing: true
    }
}
