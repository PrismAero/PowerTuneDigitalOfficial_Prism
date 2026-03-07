import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: root
    width: 800
    height: 420

    property string information: "AiM speed tach"

    property string speedSource: "speed"
    property string rpmSource: "rpm"
    property string gearSource: "Gear"
    property double speedValue: 0
    property double rpmValue: 0
    property int gearValue: 0
    property double maxSpeed: 320
    property double maxRPM: 10000
    property string speedUnit: "KM/H"
    property int speedDecimals: 0
    property int rpmDecimals: 0
    property double dangerStart: 0.82
    property double warnvaluehigh: 20000
    property double warnvaluelow: -20000
    property bool configMenuEnabled: true
    property bool showBackgroundDecorations: true
    property bool showSpeedGauge: true
    property bool showTachGauge: true
    property bool showGearBlock: true
    property bool showRpmReadout: true
    property bool showOverlapPanel: true
    property real speedStartAngle: -132
    property real speedEndAngle: 132
    property real tachStartAngle: -132
    property real tachEndAngle: 132
    property real speedArcWidthFactor: 0.18
    property real tachArcWidthFactor: 0.18
    property string neutralGearText: "N"
    property string reverseGearText: "R"
    property string rpmReadoutLabel: "RPM"

    property color arcTrackColor: GaugeTheme.aimArcTrack
    property color arcFillGreen: GaugeTheme.aimArcGreen
    property color arcFillYellow: GaugeTheme.aimArcYellowGreen
    property color arcFillRed: GaugeTheme.aimArcRed
    property color needleColor: GaugeTheme.aimNeedle
    property color speedBaseArcColor: Qt.rgba(0.83, 0.90, 0.18, 0.24)
    property color tachBaseArcColor: Qt.rgba(0.83, 0.90, 0.18, 0.24)
    property color speedCenterGlowColor: "transparent"
    property color tachCenterGlowColor: "transparent"
    property color valueColor: "#FFFFFF"
    property color unitColor: GaugeTheme.aimUnitGrey
    property color labelColor: "#FFFFFF"
    property color gearColor: GaugeTheme.aimGearColor
    property string increasedecreaseident

    FontLoader { id: compressedBoldFont; source: "qrc:/Resources/fonts/hyperspacerace-compressedbold.otf" }
    FontLoader { id: regularFont; source: "qrc:/Resources/fonts/hyperspacerace-regular.otf" }
    FontLoader { id: condensedHeavyFont; source: "qrc:/Resources/fonts/hyperspacerace-condensedheavy.otf" }
    FontLoader { id: condensedBoldFont; source: "qrc:/Resources/fonts/hyperspacerace-condensedbold.otf" }

    readonly property real _gaugeSize: Math.min(height * 0.92, width * 0.42)
    readonly property var _gradientStops: [
        { position: 0.00, color: root.arcFillGreen },
        { position: 0.50, color: root.arcFillYellow },
        { position: 0.80, color: "#FFF100" },
        { position: 1.00, color: root.arcFillRed }
    ]

    readonly property string _gearText: {
        if (gearValue === 0) return neutralGearText;
        if (gearValue < 0) return reverseGearText;
        return gearValue.toString();
    }

    readonly property real _tachLabelDivisor: root.maxRPM > 200 ? 1000 : 1

    Component.onCompleted: {
        if (speedSource)
            speedValue = Qt.binding(function() { return PropertyRouter.getValue(speedSource); });
        if (rpmSource)
            rpmValue = Qt.binding(function() { return PropertyRouter.getValue(rpmSource); });
        if (gearSource)
            gearValue = Qt.binding(function() { return PropertyRouter.getValue(gearSource); });
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        visible: root.showBackgroundDecorations
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.05) }
            GradientStop { position: 0.18; color: "transparent" }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.16) }
        }
    }

    Rectangle {
        width: root.width * 0.44
        height: root.height * 0.11
        anchors.left: parent.left
        anchors.top: parent.top
        visible: root.showBackgroundDecorations
        color: Qt.rgba(1, 1, 1, 0.03)
        rotation: -9
        transformOrigin: Item.TopLeft
    }

    Rectangle {
        width: root.width * 0.46
        height: root.height * 0.10
        anchors.right: parent.right
        anchors.top: parent.top
        visible: root.showBackgroundDecorations
        color: Qt.rgba(1, 1, 1, 0.025)
        rotation: 9
        transformOrigin: Item.TopRight
    }

    Rectangle {
        width: root.width * 0.52
        height: root.height * 0.34
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        radius: width / 2
        visible: root.showBackgroundDecorations
        color: Qt.rgba(0, 0, 0, 0.45)
    }

    AiMArcGauge {
        id: speedGauge
        width: root._gaugeSize
        height: root._gaugeSize
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: -root._gaugeSize * 0.06
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -root.height * 0.03
        value: root.speedValue
        minimumValue: 0
        maximumValue: root.maxSpeed
        visible: root.showSpeedGauge
        configMenuEnabled: false
        decimalpoints: root.speedDecimals
        unittext: root.speedUnit
        customValueText: root.speedValue.toFixed(root.speedDecimals)
        startAngle: root.speedStartAngle
        endAngle: root.speedEndAngle
        arcWidthFactor: root.speedArcWidthFactor
        majorTickStep: root.maxSpeed <= 200 ? 20 : 40
        labelStepSize: root.maxSpeed <= 200 ? 20 : 40
        minorTicksPerMajor: 3
        labelDivisor: 1
        labelPrecision: 0
        omitMinimumLabel: false
        showCenterReadout: true
        showUnit: true
        showLabels: true
        showMajorTicks: true
        showMinorTicks: true
        showDecorations: true
        showOuterRing: false
        faceOuterColor: "#080808"
        faceInnerColor: "#020202"
        centerDiscColor: Qt.rgba(0.03, 0.03, 0.03, 0.98)
        centerDiscGlowColor: root.speedCenterGlowColor
        trackColor: root.arcTrackColor
        baseArcColor: root.speedBaseArcColor
        lowArcColor: GaugeTheme.aimArcYellowGreen
        midArcColor: root.arcFillYellow
        highArcColor: root.arcFillYellow
        warningStartFraction: 0.42
        dangerStartFraction: 0.86
        tickActiveColor: root.labelColor
        tickInactiveColor: GaugeTheme.aimDimTick
        labelActiveColor: root.labelColor
        labelInactiveColor: GaugeTheme.aimDimTick
        valueColor: root.valueColor
        unitColor: root.unitColor

        Behavior on value { NumberAnimation { duration: 80; easing.type: Easing.OutQuad } }
    }

    AiMArcGauge {
        id: tachGauge
        width: root._gaugeSize
        height: root._gaugeSize
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: -root._gaugeSize * 0.06
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -root.height * 0.03
        value: root.rpmValue
        minimumValue: 0
        maximumValue: root.maxRPM
        visible: root.showTachGauge
        configMenuEnabled: false
        decimalpoints: root.rpmDecimals
        startAngle: root.tachStartAngle
        endAngle: root.tachEndAngle
        arcWidthFactor: root.tachArcWidthFactor
        majorTickStep: {
            if (root.maxRPM <= 10000) return 1000;
            if (root.maxRPM <= 16000) return 2000;
            return 2500;
        }
        labelStepSize: {
            if (root.maxRPM <= 10000) return 1000;
            if (root.maxRPM <= 16000) return 2000;
            return 2500;
        }
        minorTicksPerMajor: 3
        labelDivisor: root._tachLabelDivisor
        labelPrecision: 0
        omitMinimumLabel: true
        showCenterReadout: false
        showUnit: false
        showLabels: true
        showMajorTicks: true
        showMinorTicks: true
        showDecorations: true
        showOuterRing: false
        faceOuterColor: "#080808"
        faceInnerColor: "#020202"
        centerDiscColor: Qt.rgba(0.03, 0.03, 0.03, 0.98)
        centerDiscGlowColor: root.tachCenterGlowColor
        trackColor: root.arcTrackColor
        baseArcColor: root.tachBaseArcColor
        lowArcColor: GaugeTheme.aimArcYellowGreen
        midArcColor: root.arcFillYellow
        highArcColor: root.arcFillYellow
        warningStartFraction: 0.42
        dangerStartFraction: 0.86
        tickActiveColor: root.labelColor
        tickInactiveColor: GaugeTheme.aimDimTick
        labelActiveColor: root.labelColor
        labelInactiveColor: GaugeTheme.aimDimTick
        valueColor: root.valueColor
        unitColor: root.unitColor

        Behavior on value { NumberAnimation { duration: 80; easing.type: Easing.OutQuad } }
    }

    Shape {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -root.height * 0.03
        width: root._gaugeSize * 0.55
        height: root._gaugeSize * 0.72
        antialiasing: true
        opacity: 0.60
        z: 9
        visible: root.showOverlapPanel

        ShapePath {
            strokeWidth: 1.5
            strokeColor: Qt.rgba(1, 1, 1, 0.08)
            fillColor: Qt.rgba(0, 0, 0, 0.35)
            startX: width * 0.12
            startY: height * 0.22
            PathQuad { x: width * 0.50; y: height * 0.02; controlX: width * 0.30; controlY: height * 0.04 }
            PathQuad { x: width * 0.88; y: height * 0.22; controlX: width * 0.70; controlY: height * 0.04 }
            PathLine { x: width * 0.82; y: height * 0.80 }
            PathQuad { x: width * 0.18; y: height * 0.80; controlX: width * 0.50; controlY: height * 0.98 }
            PathLine { x: width * 0.12; y: height * 0.22 }
        }
    }

    Item {
        id: gearContainer
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -root.height * 0.03
        width: root._gaugeSize * 0.44
        height: root._gaugeSize * 0.50
        z: 10
        visible: root.showGearBlock

        MouseArea {
            anchors.fill: parent
            property real _lastTapTime: 0
            onPressed: function(mouse) {
                var now = Date.now();
                if (root.configMenuEnabled && now - _lastTapTime < 360) {
                    _lastTapTime = 0;
                    configMenu.show(mouse.x, mouse.y);
                } else {
                    _lastTapTime = now;
                }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.80
            height: parent.height * 0.74
            radius: width * 0.22
            color: Qt.rgba(0, 0, 0, 0.72)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.08)
        }

        Rectangle {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -parent.height * 0.03
            width: parent.width * 0.74
            height: parent.height * 0.20
            radius: width / 2
            color: Qt.rgba(1, 1, 1, 0.04)
            rotation: -8
        }

        Text {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 5
            anchors.verticalCenterOffset: 6
            text: root._gearText
            font.family: condensedHeavyFont.name
            font.pixelSize: parent.height * 0.78
            font.weight: Font.Black
            color: Qt.rgba(0, 0, 0, 0.72)
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, 0.55)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            anchors.centerIn: parent
            text: root._gearText
            font.family: condensedHeavyFont.name
            font.pixelSize: parent.height * 0.78
            font.weight: Font.Black
            color: root.gearColor
            style: Text.Outline
            styleColor: Qt.rgba(1, 1, 1, 0.06)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -parent.height * 0.10
            text: root._gearText
            font.family: condensedHeavyFont.name
            font.pixelSize: parent.height * 0.30
            font.weight: Font.Black
            color: Qt.rgba(1, 1, 1, 0.06)
            scale: 1.0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            transformOrigin: Item.Center
        }
    }

    Column {
        id: rpmReadout
        anchors.horizontalCenter: tachGauge.horizontalCenter
        anchors.horizontalCenterOffset: root._gaugeSize * 0.04
        anchors.top: tachGauge.verticalCenter
        anchors.topMargin: root._gaugeSize * 0.08
        spacing: -2
        visible: root.showRpmReadout

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.rpmValue.toFixed(0)
            font.family: compressedBoldFont.name
            font.pixelSize: root._gaugeSize * 0.17
            font.weight: Font.Bold
            color: root.valueColor
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.rpmReadoutLabel
            font.family: regularFont.name
            font.pixelSize: root._gaugeSize * 0.065
            font.letterSpacing: 1.4
            color: root.unitColor
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Accessible.role: Accessible.Indicator
    Accessible.name: "AiM Speed Tach"
    Accessible.description: root.speedValue.toFixed(root.speedDecimals) + " " + root.speedUnit

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

                        Text { text: "Datasources"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Row {
                            spacing: 4
                            Text { text: "Speed:"; font.pixelSize: 12; color: "#CCC"; width: 50; verticalAlignment: Text.AlignVCenter }
                            ComboBox {
                                width: 190
                                model: DatasourceService.allSources
                                textRole: "titlename"
                                font.pixelSize: 12
                                Component.onCompleted: {
                                    for (var i = 0; i < model.count; ++i)
                                        if (DatasourceService.allSources.get(i).sourcename === root.speedSource)
                                            currentIndex = i;
                                }
                                onCurrentIndexChanged: {
                                    if (currentIndex >= 0) {
                                        root.speedSource = DatasourceService.allSources.get(currentIndex).sourcename;
                                        root.speedValue = Qt.binding(function() { return PropertyRouter.getValue(root.speedSource); });
                                    }
                                }
                            }
                        }
                        Row {
                            spacing: 4
                            Text { text: "RPM:"; font.pixelSize: 12; color: "#CCC"; width: 50; verticalAlignment: Text.AlignVCenter }
                            ComboBox {
                                width: 190
                                model: DatasourceService.allSources
                                textRole: "titlename"
                                font.pixelSize: 12
                                Component.onCompleted: {
                                    for (var i = 0; i < model.count; ++i)
                                        if (DatasourceService.allSources.get(i).sourcename === root.rpmSource)
                                            currentIndex = i;
                                }
                                onCurrentIndexChanged: {
                                    if (currentIndex >= 0) {
                                        root.rpmSource = DatasourceService.allSources.get(currentIndex).sourcename;
                                        root.rpmValue = Qt.binding(function() { return PropertyRouter.getValue(root.rpmSource); });
                                    }
                                }
                            }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Gear:"; font.pixelSize: 12; color: "#CCC"; width: 50; verticalAlignment: Text.AlignVCenter }
                            ComboBox {
                                width: 190
                                model: DatasourceService.allSources
                                textRole: "titlename"
                                font.pixelSize: 12
                                Component.onCompleted: {
                                    for (var i = 0; i < model.count; ++i)
                                        if (DatasourceService.allSources.get(i).sourcename === root.gearSource)
                                            currentIndex = i;
                                }
                                onCurrentIndexChanged: {
                                    if (currentIndex >= 0) {
                                        root.gearSource = DatasourceService.allSources.get(currentIndex).sourcename;
                                        root.gearValue = Qt.binding(function() { return PropertyRouter.getValue(root.gearSource); });
                                    }
                                }
                            }
                        }

                        Text { text: "Ranges"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF"; topPadding: 8 }
                        Row {
                            spacing: 4
                            Text { text: "Max Speed:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: 10; to: 999; value: root.maxSpeed; editable: true; onValueChanged: root.maxSpeed = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Max RPM:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: 1000; to: 30000; stepSize: 500; value: root.maxRPM; editable: true; onValueChanged: root.maxRPM = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Speed Start:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: -360; to: 360; value: root.speedStartAngle; editable: true; onValueChanged: root.speedStartAngle = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Speed End:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: -360; to: 360; value: root.speedEndAngle; editable: true; onValueChanged: root.speedEndAngle = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Tach Start:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: -360; to: 360; value: root.tachStartAngle; editable: true; onValueChanged: root.tachStartAngle = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Tach End:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: -360; to: 360; value: root.tachEndAngle; editable: true; onValueChanged: root.tachEndAngle = value }
                        }

                        Text { text: "Colors"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF"; topPadding: 8 }
                        Row {
                            spacing: 4
                            Text { text: "Low Arc:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.arcFillGreen; font.pixelSize: 12; onEditingFinished: root.arcFillGreen = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Base Arc:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.speedBaseArcColor; font.pixelSize: 12; onEditingFinished: { root.speedBaseArcColor = text; root.tachBaseArcColor = text; } }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Mid Arc:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.arcFillYellow; font.pixelSize: 12; onEditingFinished: root.arcFillYellow = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "High Arc:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.arcFillRed; font.pixelSize: 12; onEditingFinished: root.arcFillRed = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Value:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.valueColor; font.pixelSize: 12; onEditingFinished: root.valueColor = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Gear:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.gearColor; font.pixelSize: 12; onEditingFinished: root.gearColor = text }
                        }

                        Text { text: "Display"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF"; topPadding: 8 }
                        Row {
                            spacing: 4
                            Text { text: "Speed Unit:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.speedUnit; font.pixelSize: 12; onTextChanged: root.speedUnit = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Neutral:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.neutralGearText; font.pixelSize: 12; onTextChanged: root.neutralGearText = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Reverse:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.reverseGearText; font.pixelSize: 12; onTextChanged: root.reverseGearText = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "RPM Label:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.rpmReadoutLabel; font.pixelSize: 12; onTextChanged: root.rpmReadoutLabel = text }
                        }
                        Switch { text: "Show speed gauge"; checked: root.showSpeedGauge; onCheckedChanged: root.showSpeedGauge = checked }
                        Switch { text: "Show tach gauge"; checked: root.showTachGauge; onCheckedChanged: root.showTachGauge = checked }
                        Switch { text: "Show overlap panel"; checked: root.showOverlapPanel; onCheckedChanged: root.showOverlapPanel = checked }
                        Switch { text: "Show gear block"; checked: root.showGearBlock; onCheckedChanged: root.showGearBlock = checked }
                        Switch { text: "Show RPM readout"; checked: root.showRpmReadout; onCheckedChanged: root.showRpmReadout = checked }
                        Switch { text: "Show background decor"; checked: root.showBackgroundDecorations; onCheckedChanged: root.showBackgroundDecorations = checked }
                    }
                }
            }
        ]
    }
}
