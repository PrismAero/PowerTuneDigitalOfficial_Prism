import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: root
    width: 959
    height: 544

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
    property bool configMenuEnabled: true
    property bool showSpeedGauge: true
    property bool showTachGauge: true
    property bool showGearBlock: true
    property bool showTachTicks: false
    property bool showTachLabels: false
    property bool showSpeedTicks: false
    property bool showSpeedLabels: false
    property color tachFillColor: GaugeTheme.aimArcOrange
    property color speedFillColor: GaugeTheme.aimArcSpeedRed
    property bool tachUseZoneColors: false
    property bool speedUseZoneColors: false
    property string neutralGearText: "N"
    property string reverseGearText: "R"
    property string gearLabelText: "GEAR"
    property string increasedecreaseident

    FontLoader { id: boldFont; source: "qrc:/Resources/fonts/hyperspacerace-bold.otf" }
    FontLoader { id: regularFont; source: "qrc:/Resources/fonts/hyperspacerace-regular.otf" }

    readonly property real _tachSize: Math.min(root.width * (544.0 / 959.0), root.height)
    readonly property real _speedSizeFactor: 476.0 / 544.0
    readonly property real _speedSize: root._tachSize * _speedSizeFactor
    readonly property real _speedLeftOffset: 483.0 / 959.0
    readonly property real _speedTopOffset: 68.0 / 544.0
    readonly property real _tachLabelDivisor: root.maxRPM > 200 ? 1000 : 1

    readonly property string _gearText: {
        if (gearValue === 0) return neutralGearText;
        if (gearValue < 0) return reverseGearText;
        return gearValue.toString();
    }

    Component.onCompleted: {
        if (speedSource)
            speedValue = Qt.binding(function() { return PropertyRouter.getValue(speedSource); });
        if (rpmSource)
            rpmValue = Qt.binding(function() { return PropertyRouter.getValue(rpmSource); });
        if (gearSource)
            gearValue = Qt.binding(function() { return PropertyRouter.getValue(gearSource); });
    }

    AiMArcGauge {
        id: tachGauge
        x: 0
        y: 0
        width: root._tachSize
        height: root._tachSize
        visible: root.showTachGauge
        configMenuEnabled: false
        value: root.rpmValue
        minimumValue: 0
        maximumValue: root.maxRPM
        decimalpoints: root.rpmDecimals
        unittext: "RPM"
        customValueText: root.rpmValue.toFixed(root.rpmDecimals)
        startAngle: -135
        endAngle: 135
        arcFillColor: root.tachFillColor
        useZoneColors: root.tachUseZoneColors
        showCenterReadout: true
        showUnit: true
        showTickMarks: root.showTachTicks
        showArcLabels: root.showTachLabels
        majorTickStep: {
            if (root.maxRPM <= 10000) return 1000;
            if (root.maxRPM <= 16000) return 2000;
            return 2500;
        }
        labelStepSize: {
            if (root.maxRPM <= 12000) return 1000;
            return 2000;
        }
        minorTicksPerMajor: 3
        labelDivisor: root._tachLabelDivisor
        omitMinimumLabel: true

        Behavior on value { NumberAnimation { duration: 80; easing.type: Easing.OutQuad } }
    }

    AiMArcGauge {
        id: speedGauge
        x: root._speedLeftOffset * root.width
        y: root._speedTopOffset * root._tachSize
        width: root._speedSize
        height: root._speedSize
        visible: root.showSpeedGauge
        configMenuEnabled: false
        value: root.speedValue
        minimumValue: 0
        maximumValue: root.maxSpeed
        decimalpoints: root.speedDecimals
        unittext: root.speedUnit
        customValueText: root.speedValue.toFixed(root.speedDecimals)
        startAngle: -135
        endAngle: 135
        arcFillColor: root.speedFillColor
        useZoneColors: root.speedUseZoneColors
        showCenterReadout: true
        showUnit: true
        showTickMarks: root.showSpeedTicks
        showArcLabels: root.showSpeedLabels
        majorTickStep: root.maxSpeed <= 200 ? 20 : 40
        labelStepSize: root.maxSpeed <= 200 ? 20 : 40
        minorTicksPerMajor: 3
        omitMinimumLabel: false

        Behavior on value { NumberAnimation { duration: 80; easing.type: Easing.OutQuad } }
    }

    Item {
        id: gearBlock
        x: tachGauge.x + tachGauge.width * 0.512 - width / 2
        y: tachGauge.y + tachGauge.height * 0.66 - height * 0.35
        width: tachGauge.width * 0.25
        height: tachGauge.height * 0.38
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

        Text {
            id: gearNumber
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            text: root._gearText
            font.family: boldFont.name
            font.pixelSize: tachGauge.height * 0.37
            font.weight: Font.Bold
            font.italic: true
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignHCenter

            Text {
                anchors.fill: parent
                text: parent.text
                font: parent.font
                color: Qt.rgba(0, 0, 0, 0.5)
                horizontalAlignment: Text.AlignHCenter
                z: -1
                anchors.leftMargin: 2
                anchors.topMargin: 3
            }
        }

        Text {
            id: gearLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: gearNumber.bottom
            anchors.topMargin: -tachGauge.height * 0.02
            text: root.gearLabelText
            font.family: regularFont.name
            font.pixelSize: tachGauge.height * 0.118
            font.italic: true
            color: "#FFFFFF"
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
                        width: parent ? parent.width : 280

                        Text { text: "Datasources"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Row {
                            spacing: 4
                            Text { text: "Speed:"; font.pixelSize: 12; color: "#CCC"; width: 60 }
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
                            Text { text: "RPM:"; font.pixelSize: 12; color: "#CCC"; width: 60 }
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
                            Text { text: "Gear:"; font.pixelSize: 12; color: "#CCC"; width: 60 }
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
                            Text { text: "Max Speed:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            SpinBox { from: 10; to: 999; value: root.maxSpeed; editable: true; onValueChanged: root.maxSpeed = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Max RPM:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            SpinBox { from: 1000; to: 30000; stepSize: 500; value: root.maxRPM; editable: true; onValueChanged: root.maxRPM = value }
                        }

                        Text { text: "Appearance"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF"; topPadding: 8 }
                        Row {
                            spacing: 4
                            Text { text: "Tach Color:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            TextField { width: 140; text: root.tachFillColor; font.pixelSize: 12; onEditingFinished: root.tachFillColor = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Speed Color:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            TextField { width: 140; text: root.speedFillColor; font.pixelSize: 12; onEditingFinished: root.speedFillColor = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Speed Unit:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            TextField { width: 140; text: root.speedUnit; font.pixelSize: 12; onTextChanged: root.speedUnit = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Neutral:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            TextField { width: 140; text: root.neutralGearText; font.pixelSize: 12; onTextChanged: root.neutralGearText = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Gear Label:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            TextField { width: 140; text: root.gearLabelText; font.pixelSize: 12; onTextChanged: root.gearLabelText = text }
                        }
                        Switch { text: "Show speed gauge"; checked: root.showSpeedGauge; onCheckedChanged: root.showSpeedGauge = checked }
                        Switch { text: "Show tach gauge"; checked: root.showTachGauge; onCheckedChanged: root.showTachGauge = checked }
                        Switch { text: "Show gear block"; checked: root.showGearBlock; onCheckedChanged: root.showGearBlock = checked }
                        Switch { text: "Tach ticks"; checked: root.showTachTicks; onCheckedChanged: root.showTachTicks = checked }
                        Switch { text: "Tach labels"; checked: root.showTachLabels; onCheckedChanged: root.showTachLabels = checked }
                        Switch { text: "Speed ticks"; checked: root.showSpeedTicks; onCheckedChanged: root.showSpeedTicks = checked }
                        Switch { text: "Speed labels"; checked: root.showSpeedLabels; onCheckedChanged: root.showSpeedLabels = checked }
                        Switch { text: "Tach zone colors"; checked: root.tachUseZoneColors; onCheckedChanged: root.tachUseZoneColors = checked }
                        Switch { text: "Speed zone colors"; checked: root.speedUseZoneColors; onCheckedChanged: root.speedUseZoneColors = checked }
                    }
                }
            }
        ]
    }
}
