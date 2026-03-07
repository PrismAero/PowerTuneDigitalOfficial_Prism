import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: root
    width: 320
    height: 320

    property string information: "AiM arc gauge"
    property string mainvaluename: ""
    property real value: 0
    property real minimumValue: 0
    property real maximumValue: 100
    property int decimalpoints: 0
    property string labeltext: ""
    property string unittext: ""
    property string customValueText: ""
    property string increasedecreaseident
    property bool configMenuEnabled: true

    property real startAngle: -135
    property real endAngle: 135
    property real arcWidthFactor: 0.14
    property int segmentCount: 42
    property real majorTickStep: 10
    property real labelStepSize: 10
    property int minorTicksPerMajor: 3
    property real labelDivisor: 1
    property int labelPrecision: 0
    property bool omitMinimumLabel: false

    property bool showCenterReadout: true
    property bool showUnit: true
    property bool showHeading: false
    property bool showLabels: true
    property bool showMajorTicks: true
    property bool showMinorTicks: true
    property bool showDecorations: true
    property bool showOuterRing: true

    property color faceOuterColor: GaugeTheme.aimGaugeFaceOuter
    property color faceInnerColor: GaugeTheme.aimGaugeFaceInner
    property color bezelColor: GaugeTheme.aimBezelColor
    property color innerRingColor: GaugeTheme.aimGaugeInnerRing
    property color shadowColor: GaugeTheme.aimGaugeShadow
    property color trackColor: GaugeTheme.aimArcTrack
    property color baseArcColor: Qt.rgba(0.79, 0.87, 0.18, 0.24)
    property color lowArcColor: GaugeTheme.aimArcGreen
    property color midArcColor: GaugeTheme.aimArcYellow
    property color highArcColor: GaugeTheme.aimArcRed
    property real warningStartFraction: 0.55
    property real dangerStartFraction: 0.82
    property color tickActiveColor: "#F0F0F0"
    property color tickInactiveColor: GaugeTheme.aimDimTick
    property color labelActiveColor: "#E4E4E4"
    property color labelInactiveColor: GaugeTheme.aimDimTick
    property color valueColor: GaugeTheme.aimValueWhite
    property color unitColor: GaugeTheme.aimUnitGrey
    property color headingColor: GaugeTheme.aimTrackName
    property color centerRingColor: Qt.rgba(1, 1, 1, 0.09)
    property color centerDiscColor: Qt.rgba(0.02, 0.02, 0.02, 0.98)
    property color centerDiscGlowColor: Qt.rgba(0.85, 0.95, 0.20, 0.22)

    readonly property real outerRadius: Math.min(width, height) / 2
    readonly property real _arcWidth: outerRadius * arcWidthFactor
    readonly property real _arcRadius: outerRadius - outerRadius * 0.16
    readonly property real _sweepAngle: endAngle - startAngle
    readonly property real _fraction: {
        var range = maximumValue - minimumValue;
        if (range <= 0)
            return 0;
        return Math.max(0, Math.min(1, (value - minimumValue) / range));
    }
    readonly property int _majorTickCount: {
        if (majorTickStep <= 0)
            return 0;
        return Math.floor((maximumValue - minimumValue) / majorTickStep) + 1;
    }
    readonly property int _labelCount: {
        if (labelStepSize <= 0)
            return 0;
        return Math.floor((maximumValue - minimumValue) / labelStepSize) + 1;
    }
    readonly property string _displayValueText: {
        if (customValueText !== "")
            return customValueText;
        if (!isFinite(value))
            return "--";
        return Number(value).toFixed(decimalpoints);
    }

    FontLoader { id: valueFont; source: "qrc:/Resources/fonts/hyperspacerace-compressedbold.otf" }
    FontLoader { id: unitFont; source: "qrc:/Resources/fonts/hyperspacerace-regular.otf" }
    FontLoader { id: labelFont; source: "qrc:/Resources/fonts/hyperspacerace-condensedbold.otf" }

    signal gaugeTapped(real value)
    signal menuRequested(real x, real y)

    function _bindValue() {
        if (mainvaluename)
            value = Qt.binding(function() { return PropertyRouter.getValue(mainvaluename); });
    }

    function _degToRad(degrees) {
        return degrees * (Math.PI / 180);
    }

    function _valueToAngle(v) {
        var range = maximumValue - minimumValue;
        if (range <= 0)
            return startAngle;
        var f = Math.max(0, Math.min(1, (v - minimumValue) / range));
        return startAngle + f * _sweepAngle;
    }

    function _polarX(angle, radius, itemWidth) {
        return width / 2 + radius * Math.sin(_degToRad(angle)) - itemWidth / 2;
    }

    function _polarY(angle, radius, itemHeight) {
        return height / 2 - radius * Math.cos(_degToRad(angle)) - itemHeight / 2;
    }

    function _colorForFraction(fraction) {
        if (fraction < warningStartFraction)
            return lowArcColor;
        if (fraction < dangerStartFraction)
            return midArcColor;
        return highArcColor;
    }

    function _colorWithAlpha(colorValue, alpha) {
        return Qt.rgba(colorValue.r, colorValue.g, colorValue.b, alpha);
    }

    function _toNumber(text, fallback) {
        var parsed = Number(text);
        return isFinite(parsed) ? parsed : fallback;
    }

    Component.onCompleted: _bindValue()
    onMainvaluenameChanged: _bindValue()

    MouseArea {
        anchors.fill: parent
        property real _lastTapTime: 0
        onPressed: function(mouse) {
            var now = Date.now();
            if (root.configMenuEnabled && now - _lastTapTime < 360) {
                _lastTapTime = 0;
                root.menuRequested(mouse.x, mouse.y);
                configMenu.show(mouse.x, mouse.y);
            } else {
                _lastTapTime = now;
                root.gaugeTapped(root.value);
            }
        }
    }

    Rectangle {
        x: outerRadius * 0.03
        y: outerRadius * 0.06
        width: parent.width
        height: parent.height
        radius: width / 2
        color: root.shadowColor
        opacity: 0.85
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.faceOuterColor
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        radius: width / 2
        color: "transparent"
        border.width: root.showOuterRing ? 2 : 0
        border.color: root.bezelColor
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: outerRadius * 0.04
        radius: width / 2
        color: root.faceInnerColor
        border.width: 1
        border.color: root.innerRingColor
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        visible: root.showDecorations
        gradient: Gradient {
            GradientStop { position: 0.0; color: GaugeTheme.aimGaugeSpecular }
            GradientStop { position: 0.30; color: GaugeTheme.aimGaugeSpecularSoft }
            GradientStop { position: 0.58; color: "transparent" }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.16) }
        }
    }

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeWidth: root._arcWidth + 6
            strokeColor: Qt.rgba(0, 0, 0, 0.5)
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: root.outerRadius
                centerY: root.outerRadius
                radiusX: root._arcRadius
                radiusY: root._arcRadius
                startAngle: root.startAngle - 90
                sweepAngle: root._sweepAngle
            }
        }
    }

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeWidth: root._arcWidth * 0.98
            strokeColor: root.baseArcColor
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: root.outerRadius
                centerY: root.outerRadius
                radiusX: root._arcRadius
                radiusY: root._arcRadius
                startAngle: root.startAngle - 90
                sweepAngle: root._sweepAngle
            }
        }
    }

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeWidth: root._arcWidth + 2
            strokeColor: root.trackColor
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: root.outerRadius
                centerY: root.outerRadius
                radiusX: root._arcRadius
                radiusY: root._arcRadius
                startAngle: root.startAngle - 90
                sweepAngle: root._sweepAngle
            }
        }
    }

    Repeater {
        model: root.segmentCount

        Shape {
            anchors.fill: parent
            antialiasing: true
            visible: root._fraction > (index / root.segmentCount)

            ShapePath {
                strokeWidth: root._arcWidth * 1.35
                strokeColor: {
                    var mid = Math.min((index + 0.5) / root.segmentCount, root._fraction);
                    return root._colorWithAlpha(root._colorForFraction(mid), 0.16);
                }
                fillColor: "transparent"
                capStyle: ShapePath.FlatCap

                PathAngleArc {
                    centerX: root.outerRadius
                    centerY: root.outerRadius
                    radiusX: root._arcRadius
                    radiusY: root._arcRadius
                    startAngle: {
                        var segStart = index / root.segmentCount;
                        return root.startAngle + segStart * root._sweepAngle - 90;
                    }
                    sweepAngle: {
                        var segStart = index / root.segmentCount;
                        var segEnd = (index + 1) / root.segmentCount;
                        var clampedEnd = Math.min(segEnd, root._fraction);
                        if (clampedEnd <= segStart)
                            return 0;
                        return (clampedEnd - segStart) * root._sweepAngle;
                    }
                }
            }
        }
    }

    Repeater {
        model: root.segmentCount

        Shape {
            anchors.fill: parent
            antialiasing: true
            visible: root._fraction > (index / root.segmentCount)

            ShapePath {
                strokeWidth: root._arcWidth
                strokeColor: {
                    var mid = Math.min((index + 0.5) / root.segmentCount, root._fraction);
                    return root._colorForFraction(mid);
                }
                fillColor: "transparent"
                capStyle: index === 0 ? ShapePath.RoundCap : ShapePath.FlatCap

                PathAngleArc {
                    centerX: root.outerRadius
                    centerY: root.outerRadius
                    radiusX: root._arcRadius
                    radiusY: root._arcRadius
                    startAngle: {
                        var segStart = index / root.segmentCount;
                        return root.startAngle + segStart * root._sweepAngle - 90;
                    }
                    sweepAngle: {
                        var segStart = index / root.segmentCount;
                        var segEnd = (index + 1) / root.segmentCount;
                        var clampedEnd = Math.min(segEnd, root._fraction);
                        if (clampedEnd <= segStart)
                            return 0;
                        return (clampedEnd - segStart) * root._sweepAngle;
                    }
                }
            }
        }
    }

    Repeater {
        model: root.segmentCount

        Shape {
            anchors.fill: parent
            antialiasing: true
            visible: root._fraction > (index / root.segmentCount)

            ShapePath {
                strokeWidth: 2
                strokeColor: {
                    var mid = Math.min((index + 0.5) / root.segmentCount, root._fraction);
                    return root._colorWithAlpha(root._colorForFraction(mid), 0.85);
                }
                fillColor: "transparent"
                capStyle: ShapePath.FlatCap

                PathAngleArc {
                    centerX: root.outerRadius
                    centerY: root.outerRadius
                    radiusX: root._arcRadius - root._arcWidth * 0.30
                    radiusY: root._arcRadius - root._arcWidth * 0.30
                    startAngle: {
                        var segStart = index / root.segmentCount;
                        return root.startAngle + segStart * root._sweepAngle - 90;
                    }
                    sweepAngle: {
                        var segStart = index / root.segmentCount;
                        var segEnd = (index + 1) / root.segmentCount;
                        var clampedEnd = Math.min(segEnd, root._fraction);
                        if (clampedEnd <= segStart)
                            return 0;
                        return (clampedEnd - segStart) * root._sweepAngle;
                    }
                }
            }
        }
    }

    Repeater {
        model: root._majorTickCount

        Rectangle {
            readonly property real tickValue: root.minimumValue + index * root.majorTickStep
            readonly property real tickAngle: root._valueToAngle(tickValue)
            width: Math.max(2, root.outerRadius * 0.012)
            height: Math.max(8, root.outerRadius * 0.08)
            radius: width / 2
            antialiasing: true
            visible: root.showMajorTicks
            color: tickValue <= root.value ? root.tickActiveColor : root.tickInactiveColor
            x: root._polarX(tickAngle, root._arcRadius + root._arcWidth * 0.53, width)
            y: root._polarY(tickAngle, root._arcRadius + root._arcWidth * 0.53, height)

            transform: Rotation {
                origin.x: width / 2
                origin.y: height / 2
                angle: tickAngle
            }
        }
    }

    Repeater {
        model: Math.max(0, (root._majorTickCount - 1) * root.minorTicksPerMajor)

        Rectangle {
            readonly property int majorIndex: Math.floor(index / root.minorTicksPerMajor)
            readonly property int minorIndex: index % root.minorTicksPerMajor
            readonly property real minorStep: root.majorTickStep / (root.minorTicksPerMajor + 1)
            readonly property real tickValue: root.minimumValue + majorIndex * root.majorTickStep + (minorIndex + 1) * minorStep
            readonly property real tickAngle: root._valueToAngle(tickValue)
            width: Math.max(1, root.outerRadius * 0.006)
            height: Math.max(5, root.outerRadius * 0.04)
            radius: width / 2
            antialiasing: true
            visible: root.showMinorTicks
            color: tickValue <= root.value ? Qt.rgba(1, 1, 1, 0.72) : root.tickInactiveColor
            x: root._polarX(tickAngle, root._arcRadius + root._arcWidth * 0.55, width)
            y: root._polarY(tickAngle, root._arcRadius + root._arcWidth * 0.55, height)

            transform: Rotation {
                origin.x: width / 2
                origin.y: height / 2
                angle: tickAngle
            }
        }
    }

    Repeater {
        model: root._labelCount

        Text {
            readonly property real labelValue: root.minimumValue + index * root.labelStepSize
            readonly property real labelAngle: root._valueToAngle(labelValue)
            readonly property real displayValue: labelValue / root.labelDivisor
            width: root.outerRadius * 0.18
            height: root.outerRadius * 0.10
            visible: root.showLabels && !(root.omitMinimumLabel && labelValue === root.minimumValue)
            x: root._polarX(labelAngle, root._arcRadius - root._arcWidth * 1.55, width)
            y: root._polarY(labelAngle, root._arcRadius - root._arcWidth * 1.55, height)
            text: root.labelPrecision === 0 ? Math.round(displayValue).toString() : Number(displayValue).toFixed(root.labelPrecision)
            font.family: labelFont.name
            font.pixelSize: Math.max(8, root.outerRadius * 0.08)
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: labelValue <= root.value ? root.labelActiveColor : root.labelInactiveColor
        }
    }

    Rectangle {
        width: outerRadius * 1.18
        height: outerRadius * 0.48
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: outerRadius * 0.12
        radius: width / 2
        color: Qt.rgba(1, 1, 1, 0.03)
        rotation: -8
        visible: root.showDecorations
    }

    Rectangle {
        width: outerRadius * 1.08
        height: outerRadius * 0.54
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: outerRadius * 0.22
        radius: width / 2
        color: Qt.rgba(0, 0, 0, 0.24)
        visible: root.showDecorations
    }

    Rectangle {
        width: outerRadius * 1.02
        height: width
        anchors.centerIn: parent
        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.035)
    }

    Rectangle {
        width: outerRadius * 0.84
        height: width
        anchors.centerIn: parent
        radius: width / 2
        color: Qt.rgba(0, 0, 0, 0.34)
        border.width: 1
        border.color: root.centerRingColor
    }

    Rectangle {
        width: outerRadius * 0.66
        height: width
        anchors.centerIn: parent
        anchors.verticalCenterOffset: outerRadius * 0.02
        radius: width / 2
        color: root.centerDiscColor
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.05)
    }

    Rectangle {
        width: outerRadius * 0.66
        height: width * 0.34
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.verticalCenter
        anchors.topMargin: -outerRadius * 0.16
        radius: width / 2
        color: Qt.rgba(1, 1, 1, 0.025)
        rotation: -8
        visible: root.showDecorations
    }

    Rectangle {
        width: outerRadius * 0.66
        height: width
        anchors.centerIn: parent
        anchors.verticalCenterOffset: outerRadius * 0.02
        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: root._colorWithAlpha(root._colorForFraction(Math.max(0.35, root._fraction)), 0.26)
    }

    Rectangle {
        width: outerRadius * 0.48
        height: width
        anchors.centerIn: parent
        anchors.verticalCenterOffset: outerRadius * 0.02
        radius: width / 2
        color: root.centerDiscGlowColor
        opacity: root.showDecorations ? 1 : 0
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: outerRadius * 0.14
        spacing: 1
        visible: root.showCenterReadout

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.showHeading ? root.labeltext : root._displayValueText
            font.family: root.showHeading ? labelFont.name : valueFont.name
            font.pixelSize: root.showHeading ? root.outerRadius * 0.08 : (root._displayValueText.length >= 4 ? root.outerRadius * 0.30 : root.outerRadius * 0.42)
            font.weight: root.showHeading ? Font.DemiBold : Font.Bold
            font.capitalization: root.showHeading ? Font.AllUppercase : Font.MixedCase
            font.letterSpacing: root.showHeading ? 1.0 : 0
            color: root.showHeading ? root.headingColor : root.valueColor
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.showHeading ? root._displayValueText : root.unittext
            font.family: root.showHeading ? valueFont.name : unitFont.name
            font.pixelSize: root.showHeading ? root.outerRadius * 0.32 : root.outerRadius * 0.10
            font.weight: root.showHeading ? Font.Bold : Font.Medium
            font.letterSpacing: root.showHeading ? 0 : 1.5
            color: root.showHeading ? root.valueColor : root.unitColor
            horizontalAlignment: Text.AlignHCenter
            visible: root.showHeading || (root.showUnit && root.unittext !== "")
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.unittext
            font.family: unitFont.name
            font.pixelSize: root.outerRadius * 0.08
            font.letterSpacing: 1.2
            color: root.unitColor
            horizontalAlignment: Text.AlignHCenter
            visible: root.showHeading && root.showUnit && root.unittext !== ""
        }
    }

    Accessible.role: Accessible.Indicator
    Accessible.name: root.labeltext || root.information
    Accessible.description: root._displayValueText

    GaugeConfigMenu {
        id: configMenu
        target: root
        allowDelete: false
        sections: [
            QtObject {
                property Component component: Component {
                    Column {
                        property Item target
                        spacing: 6
                        width: parent ? parent.width : 260

                        Text { text: "Datasource"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Row {
                            spacing: 4
                            Text { text: "Source:"; font.pixelSize: 12; color: "#CCC"; width: 50; verticalAlignment: Text.AlignVCenter }
                            ComboBox {
                                width: 190
                                model: DatasourceService.allSources
                                textRole: "titlename"
                                font.pixelSize: 12
                                Component.onCompleted: {
                                    for (var i = 0; i < model.count; ++i) {
                                        if (DatasourceService.allSources.get(i).sourcename === root.mainvaluename) {
                                            currentIndex = i;
                                            break;
                                        }
                                    }
                                }
                                onCurrentIndexChanged: {
                                    if (currentIndex >= 0)
                                        root.mainvaluename = DatasourceService.allSources.get(currentIndex).sourcename;
                                }
                            }
                        }
                    }
                }
            },
            QtObject {
                property Component component: Component {
                    Column {
                        property Item target
                        spacing: 6
                        width: parent ? parent.width : 260

                        Text { text: "Display"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Row {
                            spacing: 4
                            Text { text: "Label:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.labeltext; font.pixelSize: 12; onTextChanged: root.labeltext = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Unit:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.unittext; font.pixelSize: 12; onTextChanged: root.unittext = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Decimals:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: 0; to: 6; value: root.decimalpoints; onValueChanged: root.decimalpoints = value }
                        }
                        Switch { text: "Visible"; checked: root.visible; onCheckedChanged: root.visible = checked }
                        Switch { text: "Show center readout"; checked: root.showCenterReadout; onCheckedChanged: root.showCenterReadout = checked }
                        Switch { text: "Show unit"; checked: root.showUnit; onCheckedChanged: root.showUnit = checked }
                        Switch { text: "Show heading"; checked: root.showHeading; onCheckedChanged: root.showHeading = checked }
                        Switch { text: "Show labels"; checked: root.showLabels; onCheckedChanged: root.showLabels = checked }
                        Switch { text: "Show major ticks"; checked: root.showMajorTicks; onCheckedChanged: root.showMajorTicks = checked }
                        Switch { text: "Show minor ticks"; checked: root.showMinorTicks; onCheckedChanged: root.showMinorTicks = checked }
                        Switch { text: "Show outer ring"; checked: root.showOuterRing; onCheckedChanged: root.showOuterRing = checked }
                    }
                }
            },
            QtObject {
                property Component component: Component {
                    Column {
                        property Item target
                        spacing: 6
                        width: parent ? parent.width : 260

                        Text { text: "Arc Geometry"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Row {
                            spacing: 4
                            Text { text: "Min:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: -99999; to: 99999; editable: true; value: root.minimumValue; onValueChanged: root.minimumValue = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Max:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: -99999; to: 99999; editable: true; value: root.maximumValue; onValueChanged: root.maximumValue = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Start Angle:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: -360; to: 360; editable: true; value: root.startAngle; onValueChanged: root.startAngle = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "End Angle:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: -360; to: 360; editable: true; value: root.endAngle; onValueChanged: root.endAngle = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Major Tick:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: 1; to: 10000; editable: true; value: root.majorTickStep; onValueChanged: root.majorTickStep = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Label Step:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: 1; to: 10000; editable: true; value: root.labelStepSize; onValueChanged: root.labelStepSize = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Minor Ticks:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: 0; to: 12; value: root.minorTicksPerMajor; onValueChanged: root.minorTicksPerMajor = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Arc Width:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.arcWidthFactor; font.pixelSize: 12; onEditingFinished: root.arcWidthFactor = root._toNumber(text, root.arcWidthFactor) }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Divisor:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.labelDivisor; font.pixelSize: 12; onEditingFinished: root.labelDivisor = root._toNumber(text, root.labelDivisor) }
                        }
                    }
                }
            },
            QtObject {
                property Component component: Component {
                    Column {
                        property Item target
                        spacing: 6
                        width: parent ? parent.width : 260

                        Text { text: "Theme"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Row {
                            spacing: 4
                            Text { text: "Track:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.trackColor; font.pixelSize: 12; onEditingFinished: root.trackColor = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Base Arc:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.baseArcColor; font.pixelSize: 12; onEditingFinished: root.baseArcColor = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Low Arc:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.lowArcColor; font.pixelSize: 12; onEditingFinished: root.lowArcColor = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Mid Arc:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.midArcColor; font.pixelSize: 12; onEditingFinished: root.midArcColor = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "High Arc:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.highArcColor; font.pixelSize: 12; onEditingFinished: root.highArcColor = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Warn At:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.warningStartFraction; font.pixelSize: 12; onEditingFinished: root.warningStartFraction = root._toNumber(text, root.warningStartFraction) }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Danger At:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.dangerStartFraction; font.pixelSize: 12; onEditingFinished: root.dangerStartFraction = root._toNumber(text, root.dangerStartFraction) }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Value:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.valueColor; font.pixelSize: 12; onEditingFinished: root.valueColor = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Unit:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.unitColor; font.pixelSize: 12; onEditingFinished: root.unitColor = text }
                        }
                        Switch { text: "Show decorations"; checked: root.showDecorations; onCheckedChanged: root.showDecorations = checked }
                    }
                }
            }
        ]
    }
}
