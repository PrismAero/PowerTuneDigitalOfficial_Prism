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
    property bool startupSweepEnabled: true

    property real startAngle: -135
    property real endAngle: 135
    property real arcWidthFactor: 0.16
    property real majorTickStep: 10
    property real labelStepSize: 10
    property int minorTicksPerMajor: 3
    property real labelDivisor: 1
    property int labelPrecision: 0
    property bool omitMinimumLabel: false

    property bool showCenterReadout: true
    property bool showUnit: true
    property bool showTickMarks: false
    property bool showArcLabels: false
    property bool showOuterRing: true

    property color arcFillColor: GaugeTheme.aimArcOrange
    property bool useZoneColors: false
    property color lowArcColor: GaugeTheme.aimArcGreen
    property color midArcColor: GaugeTheme.aimArcYellow
    property color highArcColor: GaugeTheme.aimArcRed
    property real warningStartFraction: 0.55
    property real dangerStartFraction: 0.82

    property color arcBgLightColor: GaugeTheme.aimArcBgLight
    property color arcBgDarkColor: GaugeTheme.aimArcBgDark
    property color outerStrokeColor: GaugeTheme.aimOuterStroke
    property color innerStrokeColor: GaugeTheme.aimInnerStroke
    property color innerDiscColor: GaugeTheme.aimInnerDisc
    property color valueColor: "#FFFFFF"
    property color unitColor: GaugeTheme.aimUnitGrey
    property color tickActiveColor: "#E0E0E0"
    property color tickInactiveColor: "#444444"
    property color labelActiveColor: "#D0D0D0"
    property color labelInactiveColor: "#444444"

    readonly property real _cx: width / 2
    readonly property real _cy: height / 2
    readonly property real _outerR: Math.min(width, height) / 2
    readonly property real _arcW: _outerR * arcWidthFactor
    readonly property real _arcR: _outerR * 0.88
    readonly property real _bgArcW: _outerR * 0.30
    readonly property real _bgArcR: _outerR * 0.84
    readonly property real _innerDiscR: _bgArcR - _bgArcW / 2 - _outerR * 0.005
    readonly property real _sweepAngle: endAngle - startAngle

    property real _sweepFraction: 0
    readonly property real _dataFraction: {
        var range = maximumValue - minimumValue;
        if (range <= 0) return 0;
        return Math.max(0, Math.min(1, (value - minimumValue) / range));
    }
    readonly property real _activeFraction: _startupActive ? _sweepFraction : _dataFraction
    property bool _startupActive: false

    readonly property int _majorTickCount: {
        if (majorTickStep <= 0) return 0;
        return Math.floor((maximumValue - minimumValue) / majorTickStep) + 1;
    }
    readonly property int _labelCount: {
        if (labelStepSize <= 0) return 0;
        return Math.floor((maximumValue - minimumValue) / labelStepSize) + 1;
    }
    readonly property string _displayValueText: {
        if (_startupActive) return "--";
        if (customValueText !== "") return customValueText;
        if (!isFinite(value)) return "--";
        return Number(value).toFixed(decimalpoints);
    }

    FontLoader { id: valueFont; source: "qrc:/Resources/fonts/hyperspacerace-regular.otf" }
    FontLoader { id: unitFont; source: "qrc:/Resources/fonts/hyperspacerace-regular.otf" }
    FontLoader { id: labelFont; source: "qrc:/Resources/fonts/hyperspacerace-condensedbold.otf" }

    signal gaugeTapped(real value)
    signal menuRequested(real x, real y)

    function _bindValue() {
        if (mainvaluename)
            value = Qt.binding(function() { return PropertyRouter.getValue(mainvaluename); });
    }

    function _degToRad(d) { return d * (Math.PI / 180); }

    function _valueToAngle(v) {
        var range = maximumValue - minimumValue;
        if (range <= 0) return startAngle;
        var f = Math.max(0, Math.min(1, (v - minimumValue) / range));
        return startAngle + f * _sweepAngle;
    }

    function _polarX(angle, radius, itemWidth) {
        return _cx + radius * Math.sin(_degToRad(angle)) - itemWidth / 2;
    }

    function _polarY(angle, radius, itemHeight) {
        return _cy - radius * Math.cos(_degToRad(angle)) - itemHeight / 2;
    }

    function _colorForFraction(frac) {
        if (frac < warningStartFraction) return lowArcColor;
        if (frac < dangerStartFraction) return midArcColor;
        return highArcColor;
    }

    function _toNumber(text, fallback) {
        var parsed = Number(text);
        return isFinite(parsed) ? parsed : fallback;
    }

    SequentialAnimation {
        id: startupAnim
        running: false

        NumberAnimation {
            target: root
            property: "_sweepFraction"
            from: 0; to: 1
            duration: 800
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            property: "_sweepFraction"
            from: 1; to: 0
            duration: 600
            easing.type: Easing.InOutQuad
        }

        onFinished: root._startupActive = false
    }

    Component.onCompleted: {
        _bindValue();
        if (startupSweepEnabled) {
            _startupActive = true;
            startupAnim.start();
        }
    }
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

    Canvas {
        id: arcBgCanvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = root._cx;
            var cy = root._cy;
            var r = root._bgArcR;
            var w = root._bgArcW;
            var sa = root._degToRad(root.startAngle - 90);
            var ea = root._degToRad(root.endAngle - 90);

            ctx.lineCap = "round";
            ctx.lineWidth = w;

            var grad = ctx.createLinearGradient(cx, cy - r, cx, cy + r * 0.5);
            grad.addColorStop(0.0, root.arcBgLightColor.toString());
            grad.addColorStop(0.5, Qt.rgba(
                root.arcBgDarkColor.r * 1.2,
                root.arcBgDarkColor.g * 1.2,
                root.arcBgDarkColor.b * 1.2, 1.0).toString());
            grad.addColorStop(1.0, root.arcBgDarkColor.toString());

            ctx.strokeStyle = grad;
            ctx.beginPath();
            ctx.arc(cx, cy, r, sa, ea, false);
            ctx.stroke();
        }

        Connections {
            target: root
            function onWidthChanged() { arcBgCanvas.requestPaint(); }
            function onHeightChanged() { arcBgCanvas.requestPaint(); }
            function onStartAngleChanged() { arcBgCanvas.requestPaint(); }
            function onEndAngleChanged() { arcBgCanvas.requestPaint(); }
        }
    }

    Shape {
        id: outerRing
        anchors.fill: parent
        antialiasing: true
        visible: root.showOuterRing

        ShapePath {
            strokeWidth: Math.max(1.5, root._outerR * 0.008)
            strokeColor: root.outerStrokeColor
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: root._cx
                centerY: root._cy
                radiusX: root._outerR * 0.945
                radiusY: root._outerR * 0.945
                startAngle: root.startAngle - 90
                sweepAngle: root._sweepAngle
            }
        }
    }

    Shape {
        id: innerBoundary
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeWidth: Math.max(1, root._outerR * 0.006)
            strokeColor: root.innerStrokeColor
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: root._cx
                centerY: root._cy
                radiusX: root._bgArcR - root._bgArcW / 2
                radiusY: root._bgArcR - root._bgArcW / 2
                startAngle: root.startAngle - 90
                sweepAngle: root._sweepAngle
            }
        }
    }

    Canvas {
        id: fillArcCanvas
        anchors.fill: parent
        antialiasing: true
        visible: root._activeFraction > 0.001

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = root._cx;
            var cy = root._cy;
            var r = root._arcR;
            var w = root._arcW;
            var frac = root._activeFraction;
            if (frac <= 0) return;

            var sa = root._degToRad(root.startAngle - 90);
            var sweepRad = root._degToRad(root._sweepAngle * frac);
            var ea = sa + sweepRad;

            var fillCol = root.useZoneColors ? root._colorForFraction(frac) : root.arcFillColor;

            ctx.lineCap = "butt";
            ctx.lineWidth = w;

            ctx.save();
            ctx.globalAlpha = 0.25;
            ctx.lineWidth = w + root._outerR * 0.06;
            ctx.strokeStyle = fillCol.toString();
            ctx.beginPath();
            ctx.arc(cx, cy, r, sa, ea, false);
            ctx.stroke();
            ctx.restore();

            ctx.globalAlpha = 1.0;
            ctx.lineWidth = w;
            ctx.strokeStyle = fillCol.toString();
            ctx.beginPath();
            ctx.arc(cx, cy, r, sa, ea, false);
            ctx.stroke();
        }

        property real _watchFrac: root._activeFraction
        on_WatchFracChanged: requestPaint()

        Connections {
            target: root
            function onWidthChanged() { fillArcCanvas.requestPaint(); }
            function onHeightChanged() { fillArcCanvas.requestPaint(); }
            function onArcFillColorChanged() { fillArcCanvas.requestPaint(); }
        }
    }

    Rectangle {
        id: innerDisc
        width: root._innerDiscR * 2
        height: width
        anchors.centerIn: parent
        radius: width / 2
        color: root.innerDiscColor

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.03) }
                GradientStop { position: 0.4; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.20) }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.04)
        }
    }

    Repeater {
        model: root.showTickMarks ? root._majorTickCount : 0

        Rectangle {
            readonly property real tickValue: root.minimumValue + index * root.majorTickStep
            readonly property real tickAngle: root._valueToAngle(tickValue)
            width: Math.max(2, root._outerR * 0.014)
            height: Math.max(8, root._bgArcW * 0.45)
            radius: width / 2
            antialiasing: true
            color: tickValue <= root.value ? root.tickActiveColor : root.tickInactiveColor
            x: root._polarX(tickAngle, root._arcR, width)
            y: root._polarY(tickAngle, root._arcR, height)

            transform: Rotation {
                origin.x: width / 2
                origin.y: height / 2
                angle: tickAngle
            }
        }
    }

    Repeater {
        model: root.showTickMarks ? Math.max(0, (root._majorTickCount - 1) * root.minorTicksPerMajor) : 0

        Rectangle {
            readonly property int majorIndex: Math.floor(index / root.minorTicksPerMajor)
            readonly property int minorIndex: index % root.minorTicksPerMajor
            readonly property real minorStep: root.majorTickStep / (root.minorTicksPerMajor + 1)
            readonly property real tickValue: root.minimumValue + majorIndex * root.majorTickStep + (minorIndex + 1) * minorStep
            readonly property real tickAngle: root._valueToAngle(tickValue)
            width: Math.max(1, root._outerR * 0.008)
            height: Math.max(4, root._bgArcW * 0.22)
            radius: width / 2
            antialiasing: true
            color: tickValue <= root.value ? Qt.rgba(1, 1, 1, 0.65) : root.tickInactiveColor
            x: root._polarX(tickAngle, root._arcR, width)
            y: root._polarY(tickAngle, root._arcR, height)

            transform: Rotation {
                origin.x: width / 2
                origin.y: height / 2
                angle: tickAngle
            }
        }
    }

    Repeater {
        model: root.showArcLabels ? root._labelCount : 0

        Text {
            readonly property real labelValue: root.minimumValue + index * root.labelStepSize
            readonly property real labelAngle: root._valueToAngle(labelValue)
            readonly property real displayValue: labelValue / root.labelDivisor
            width: root._outerR * 0.18
            height: root._outerR * 0.10
            visible: !(root.omitMinimumLabel && labelValue === root.minimumValue)
            x: root._polarX(labelAngle, root._bgArcR - root._bgArcW * 0.55, width)
            y: root._polarY(labelAngle, root._bgArcR - root._bgArcW * 0.55, height)
            text: root.labelPrecision === 0 ? Math.round(displayValue).toString() : Number(displayValue).toFixed(root.labelPrecision)
            font.family: labelFont.name
            font.pixelSize: Math.max(8, root._outerR * 0.065)
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: labelValue <= root.value ? root.labelActiveColor : root.labelInactiveColor
        }
    }

    Column {
        id: centerReadout
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root._outerR * 0.06
        spacing: root._outerR * 0.02
        visible: root.showCenterReadout

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root._displayValueText
            font.family: valueFont.name
            font.pixelSize: root._displayValueText.length >= 5 ? root._outerR * 0.36 : root._outerR * 0.46
            color: root.valueColor
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.unittext
            font.family: unitFont.name
            font.pixelSize: root._outerR * 0.16
            font.italic: true
            color: root.unitColor
            horizontalAlignment: Text.AlignHCenter
            visible: root.showUnit && root.unittext !== ""
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
                                            currentIndex = i; break;
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
                            Text { text: "Label:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            TextField { width: 140; text: root.labeltext; font.pixelSize: 12; onTextChanged: root.labeltext = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Unit:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            TextField { width: 140; text: root.unittext; font.pixelSize: 12; onTextChanged: root.unittext = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Decimals:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            SpinBox { from: 0; to: 6; value: root.decimalpoints; onValueChanged: root.decimalpoints = value }
                        }
                        Switch { text: "Visible"; checked: root.visible; onCheckedChanged: root.visible = checked }
                        Switch { text: "Show value"; checked: root.showCenterReadout; onCheckedChanged: root.showCenterReadout = checked }
                        Switch { text: "Show unit"; checked: root.showUnit; onCheckedChanged: root.showUnit = checked }
                        Switch { text: "Show ticks"; checked: root.showTickMarks; onCheckedChanged: root.showTickMarks = checked }
                        Switch { text: "Show labels"; checked: root.showArcLabels; onCheckedChanged: root.showArcLabels = checked }
                        Switch { text: "Show outer ring"; checked: root.showOuterRing; onCheckedChanged: root.showOuterRing = checked }
                        Switch { text: "Zone colors"; checked: root.useZoneColors; onCheckedChanged: root.useZoneColors = checked }
                        Switch { text: "Startup sweep"; checked: root.startupSweepEnabled; onCheckedChanged: root.startupSweepEnabled = checked }
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
                            Text { text: "Min:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            SpinBox { from: -99999; to: 99999; editable: true; value: root.minimumValue; onValueChanged: root.minimumValue = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Max:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            SpinBox { from: -99999; to: 99999; editable: true; value: root.maximumValue; onValueChanged: root.maximumValue = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Start Angle:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            SpinBox { from: -360; to: 360; editable: true; value: root.startAngle; onValueChanged: root.startAngle = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "End Angle:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            SpinBox { from: -360; to: 360; editable: true; value: root.endAngle; onValueChanged: root.endAngle = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Major Tick:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            SpinBox { from: 1; to: 10000; editable: true; value: root.majorTickStep; onValueChanged: root.majorTickStep = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Label Step:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            SpinBox { from: 1; to: 10000; editable: true; value: root.labelStepSize; onValueChanged: root.labelStepSize = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Arc Width:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            TextField { width: 140; text: root.arcWidthFactor; font.pixelSize: 12; onEditingFinished: root.arcWidthFactor = root._toNumber(text, root.arcWidthFactor) }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Fill Color:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            TextField { width: 140; text: root.arcFillColor; font.pixelSize: 12; onEditingFinished: root.arcFillColor = text }
                        }
                    }
                }
            }
        ]
    }
}
