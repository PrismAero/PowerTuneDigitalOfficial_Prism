import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges.Widgets 1.0
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: raceDash
    anchors.fill: parent

    property int dashIndex: 0
    property bool configMenuEnabled: true

    property real maxSpeedValue: 320
    property real maxRpmValue: 10000

    property bool snsrCard1Visible: true
    property bool snsrCard2Visible: true
    property bool brakeBiasVisible: true
    property bool mainClusterVisible: true
    property bool logoVisible: true
    property bool statusBarVisible: true

    property color tachFillColor: GaugeTheme.aimArcOrange
    property color speedFillColor: GaugeTheme.aimArcSpeedRed
    property bool showTachTicks: false
    property bool showTachLabels: false
    property bool showSpeedTicks: false
    property bool showSpeedLabels: false

    property string teamLogoSource: ""

    QtObject {
        id: snsrSlot1
        property string sectionTitle: "Sensor 1"
        property string source: "Watertemp"
        property string label: "Water Temp"
        property string unit: "F\u00B0"
        property int decimals: 2
        property bool visible: true
    }

    QtObject {
        id: snsrSlot2
        property string sectionTitle: "Sensor 2"
        property string source: "EXAnalogCalc0"
        property string label: "OIL PRESSURE"
        property string unit: "F\u00B0"
        property int decimals: 2
        property bool visible: true
    }

    QtObject {
        id: biasSlot
        property string source: "BrakeBias"
        property string title: "BRAKE BIAS"
        property string leftLabel: "RWD"
        property string rightLabel: "FWD"
    }

    Rectangle {
        anchors.fill: parent
        color: "#0C0C0C"
    }

    MouseArea {
        anchors.fill: parent
        z: 1
        propagateComposedEvents: true
        onPressed: function(mouse) { mouse.accepted = false; }
        onDoubleClicked: function(mouse) {
            if (!raceDash.configMenuEnabled) return;
            mouse.accepted = true;
            configMenu.show(mouse.x, mouse.y);
        }
    }

    AiMSensorLabel {
        id: sensorCard1
        x: raceDash.width * 0.083
        y: raceDash.height * 0.181
        width: raceDash.width * 0.156
        height: raceDash.height * 0.178
        visible: raceDash.snsrCard1Visible && snsrSlot1.visible
        configMenuEnabled: false
        mainvaluename: snsrSlot1.source
        labeltext: snsrSlot1.label
        unittext: snsrSlot1.unit
        decimalpoints: snsrSlot1.decimals
    }

    AiMSensorLabel {
        id: sensorCard2
        x: raceDash.width * 0.083
        y: raceDash.height * 0.392
        width: raceDash.width * 0.156
        height: raceDash.height * 0.178
        visible: raceDash.snsrCard2Visible && snsrSlot2.visible
        configMenuEnabled: false
        mainvaluename: snsrSlot2.source
        labeltext: snsrSlot2.label
        unittext: snsrSlot2.unit
        decimalpoints: snsrSlot2.decimals
    }

    AiMBrakeBias {
        id: brakeBias
        x: raceDash.width * 0.019
        y: raceDash.height * 0.683
        width: raceDash.width * 0.277
        height: raceDash.height * 0.229
        visible: raceDash.brakeBiasVisible
        configMenuEnabled: false
        brakeBiasSource: biasSlot.source
        titleText: biasSlot.title
        leftLabel: biasSlot.leftLabel
        rightLabel: biasSlot.rightLabel
    }

    AiMSpeedTach {
        id: mainCluster
        x: raceDash.width * 0.332
        y: raceDash.height * 0.122
        width: raceDash.width * 0.599
        height: raceDash.height * 0.756
        visible: raceDash.mainClusterVisible
        configMenuEnabled: false
        maxSpeed: raceDash.maxSpeedValue
        maxRPM: raceDash.maxRpmValue
        speedUnit: Settings.speedunits === "imperial" ? "MPH" : "KM/H"
        tachFillColor: raceDash.tachFillColor
        speedFillColor: raceDash.speedFillColor
        showTachTicks: raceDash.showTachTicks
        showTachLabels: raceDash.showTachLabels
        showSpeedTicks: raceDash.showSpeedTicks
        showSpeedLabels: raceDash.showSpeedLabels
    }

    Image {
        id: teamLogo
        x: raceDash.width * 0.842
        y: raceDash.height * 0.049
        width: raceDash.width * 0.138
        height: raceDash.height * 0.147
        visible: raceDash.logoVisible && source !== ""
        source: raceDash.teamLogoSource
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    AiMStatusBar {
        id: statusBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: raceDash.height * 0.056
        visible: raceDash.statusBarVisible
        configMenuEnabled: false
    }

    GaugeConfigMenu {
        id: configMenu
        target: raceDash
        allowDelete: false
        panelWidth: 380
        sections: [
            QtObject {
                property Component component: Component {
                    Column {
                        spacing: 6
                        width: parent ? parent.width : 340

                        Text { text: "Layout"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Switch { text: "Sensor card 1"; checked: raceDash.snsrCard1Visible; onCheckedChanged: raceDash.snsrCard1Visible = checked }
                        Switch { text: "Sensor card 2"; checked: raceDash.snsrCard2Visible; onCheckedChanged: raceDash.snsrCard2Visible = checked }
                        Switch { text: "Brake bias"; checked: raceDash.brakeBiasVisible; onCheckedChanged: raceDash.brakeBiasVisible = checked }
                        Switch { text: "Main cluster"; checked: raceDash.mainClusterVisible; onCheckedChanged: raceDash.mainClusterVisible = checked }
                        Switch { text: "Team logo"; checked: raceDash.logoVisible; onCheckedChanged: raceDash.logoVisible = checked }
                        Switch { text: "Status bar"; checked: raceDash.statusBarVisible; onCheckedChanged: raceDash.statusBarVisible = checked }

                        Text { text: "Gauge Ranges"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF"; topPadding: 8 }
                        Row {
                            spacing: 4
                            Text { text: "Max Speed:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            SpinBox { from: 10; to: 999; value: raceDash.maxSpeedValue; editable: true; onValueChanged: raceDash.maxSpeedValue = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Max RPM:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            SpinBox { from: 1000; to: 30000; stepSize: 500; value: raceDash.maxRpmValue; editable: true; onValueChanged: raceDash.maxRpmValue = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Tach Color:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            TextField { width: 220; text: raceDash.tachFillColor; font.pixelSize: 12; onEditingFinished: raceDash.tachFillColor = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Speed Color:"; font.pixelSize: 12; color: "#CCC"; width: 80 }
                            TextField { width: 220; text: raceDash.speedFillColor; font.pixelSize: 12; onEditingFinished: raceDash.speedFillColor = text }
                        }
                        Switch { text: "Tach ticks"; checked: raceDash.showTachTicks; onCheckedChanged: raceDash.showTachTicks = checked }
                        Switch { text: "Tach labels"; checked: raceDash.showTachLabels; onCheckedChanged: raceDash.showTachLabels = checked }
                        Switch { text: "Speed ticks"; checked: raceDash.showSpeedTicks; onCheckedChanged: raceDash.showSpeedTicks = checked }
                        Switch { text: "Speed labels"; checked: raceDash.showSpeedLabels; onCheckedChanged: raceDash.showSpeedLabels = checked }
                    }
                }
            },
            QtObject {
                property Component component: Component {
                    Column {
                        spacing: 6
                        width: parent ? parent.width : 340

                        Text { text: "Sensor Slots"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }

                        Repeater {
                            model: [snsrSlot1, snsrSlot2]
                            delegate: Column {
                                property var slot: modelData
                                spacing: 4
                                width: parent.width

                                Rectangle { width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.08) }
                                Text { text: slot.sectionTitle; font.bold: true; font.pixelSize: 12; color: "#F0F0F0" }
                                Switch { text: "Visible"; checked: slot.visible; onCheckedChanged: slot.visible = checked }
                                Row {
                                    spacing: 4
                                    Text { text: "Source:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    ComboBox {
                                        width: 230
                                        model: DatasourceService.allSources
                                        textRole: "titlename"
                                        font.pixelSize: 12
                                        Component.onCompleted: {
                                            for (var i = 0; i < model.count; ++i)
                                                if (DatasourceService.allSources.get(i).sourcename === slot.source) { currentIndex = i; break; }
                                        }
                                        onActivated: slot.source = DatasourceService.allSources.get(currentIndex).sourcename
                                    }
                                }
                                Row {
                                    spacing: 4
                                    Text { text: "Label:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    TextField { width: 230; text: slot.label; font.pixelSize: 12; onTextChanged: slot.label = text }
                                }
                                Row {
                                    spacing: 4
                                    Text { text: "Unit:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    TextField { width: 230; text: slot.unit; font.pixelSize: 12; onTextChanged: slot.unit = text }
                                }
                                Row {
                                    spacing: 4
                                    Text { text: "Decimals:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    SpinBox { from: 0; to: 6; value: slot.decimals; onValueChanged: slot.decimals = value }
                                }
                            }
                        }
                    }
                }
            },
            QtObject {
                property Component component: Component {
                    Column {
                        spacing: 6
                        width: parent ? parent.width : 340

                        Text { text: "Brake Bias"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Row {
                            spacing: 4
                            Text { text: "Source:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                            ComboBox {
                                width: 230
                                model: DatasourceService.allSources
                                textRole: "titlename"
                                font.pixelSize: 12
                                Component.onCompleted: {
                                    for (var i = 0; i < model.count; ++i)
                                        if (DatasourceService.allSources.get(i).sourcename === biasSlot.source) { currentIndex = i; break; }
                                }
                                onActivated: biasSlot.source = DatasourceService.allSources.get(currentIndex).sourcename
                            }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Title:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                            TextField { width: 230; text: biasSlot.title; font.pixelSize: 12; onTextChanged: biasSlot.title = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Left:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                            TextField { width: 230; text: biasSlot.leftLabel; font.pixelSize: 12; onTextChanged: biasSlot.leftLabel = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Right:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                            TextField { width: 230; text: biasSlot.rightLabel; font.pixelSize: 12; onTextChanged: biasSlot.rightLabel = text }
                        }

                        Text { text: "Status Bar"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF"; topPadding: 8 }
                        Row {
                            spacing: 4
                            Text { text: "Team:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                            TextField { width: 230; text: statusBar.teamName; font.pixelSize: 12; onTextChanged: statusBar.teamName = text }
                        }

                        Text { text: "Logo"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF"; topPadding: 8 }
                        Row {
                            spacing: 4
                            Text { text: "Path:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                            TextField { width: 230; text: raceDash.teamLogoSource; font.pixelSize: 12; onTextChanged: raceDash.teamLogoSource = text }
                        }
                    }
                }
            }
        ]
    }
}
