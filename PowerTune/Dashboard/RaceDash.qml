import QtQuick
import QtQuick.Controls
import PowerTune.Gauges.Shared 1.0

Item {
    id: raceDash
    width: 1600
    height: 720

    property int dashIndex: 0

    FontLoader {
        id: hyperspaceFont
        source: "qrc:/Resources/fonts/HyperspaceRaceVariable.otf"
    }

    // -- Tach group (drives arc, text, gear, shift lights) --
    property string tachSensorKey: "rpm"
    property real tachMin: 0
    property real tachMax: 10000
    property string tachUnit: "RPM"
    property string tachArcColorStart: "#E88A1A"
    property string tachArcColorEnd: "#C45A00"
    property string tachGearKey: "Gear"
    property real tachShiftPoint: 0.75
    property int tachShiftCount: 11
    property string tachShiftPattern: "center-out"
    property int tachDecimals: 0

    // -- Speed group (drives arc, text) --
    property string speedSensorKey: "speed"
    property real speedMin: 0
    property real speedMax: 200
    property string speedUnit: "MPH"
    property string speedArcColorStart: "#AA1111"
    property string speedArcColorEnd: "#880000"
    property int speedDecimals: 0

    // -- Sensor cards --
    property string wtSensorKey: "Watertemp"
    property string wtLabel: "Water Temp"
    property string wtUnit: "F\u00B0"
    property int wtDecimals: 2

    property string opSensorKey: "oilpres"
    property string opLabel: "Oil Pressure"
    property string opUnit: "PSI"
    property int opDecimals: 2

    // -- Status rows --
    property string sr0SensorKey: "DigitalInput1"
    property string sr0Label: "Digital 1:"
    property real sr0Threshold: 0.5

    property string sr1SensorKey: "DigitalInput2"
    property string sr1Label: "Digital 2:"
    property real sr1Threshold: 0.5

    // -- Bottom bar --
    property string bbTeamName: "Cardinal Racing"

    function applyOverlayProps(overlayId) {
        var p = OverlayConfig.getOverlayProperties(overlayId)
        if (overlayId === "waterTemp") {
            wtSensorKey = p.sensorKey; wtLabel = p.label; wtUnit = p.unit; wtDecimals = p.decimals
        } else if (overlayId === "oilPressure") {
            opSensorKey = p.sensorKey; opLabel = p.label; opUnit = p.unit; opDecimals = p.decimals
        } else if (overlayId === "statusRow0") {
            sr0SensorKey = p.sensorKey; sr0Label = p.label; sr0Threshold = p.threshold
        } else if (overlayId === "statusRow1") {
            sr1SensorKey = p.sensorKey; sr1Label = p.label; sr1Threshold = p.threshold
        } else if (overlayId === "tachGroup") {
            tachSensorKey = p.sensorKey; tachMin = p.minValue; tachMax = p.maxValue
            tachUnit = p.unit; tachArcColorStart = p.arcColorStart; tachArcColorEnd = p.arcColorEnd
            tachGearKey = p.gearKey; tachShiftPoint = p.shiftPoint
            tachShiftCount = p.shiftCount; tachShiftPattern = p.shiftPattern; tachDecimals = p.decimals
        } else if (overlayId === "speedGroup") {
            speedSensorKey = p.sensorKey; speedMin = p.minValue; speedMax = p.maxValue
            speedUnit = p.unit; speedArcColorStart = p.arcColorStart; speedArcColorEnd = p.arcColorEnd
            speedDecimals = p.decimals
        } else if (overlayId === "bottomBar") {
            bbTeamName = p.text
        }
    }

    Component.onCompleted: {
        applyOverlayProps("waterTemp"); applyOverlayProps("oilPressure")
        applyOverlayProps("statusRow0"); applyOverlayProps("statusRow1")
        applyOverlayProps("tachGroup"); applyOverlayProps("speedGroup")
        applyOverlayProps("bottomBar")
    }

    Connections {
        target: OverlayConfig
        function onConfigChanged(overlayId) { raceDash.applyOverlayProps(overlayId) }
    }

    OverlayConfigPopup {
        id: configPopup
    }

    Image {
        id: staticBackground
        anchors.fill: parent
        source: "qrc:/Resources/graphics/Racedash_AiM.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    // ==================== Shift Lights ====================
    DraggableOverlay {
        id: shiftOverlay
        overlayId: "tachGroup"
        configType: "tachGroup"
        x: 337
        y: 30
        width: shiftLights.width
        height: shiftLights.height
        onConfigRequested: configPopup.openFor(overlayId, configType)

        ShiftIndicator {
            id: shiftLights
            rpmValue: {
                var v = PropertyRouter.getValue(raceDash.tachSensorKey);
                return v !== undefined ? Number(v) : 0;
            }
            rpmMax: raceDash.tachMax
            shiftPoint: raceDash.tachShiftPoint
            pillCount: raceDash.tachShiftCount
            activationPattern: raceDash.tachShiftPattern
        }
    }

    // ==================== Water Temp Card ====================
    DraggableOverlay {
        id: waterTempOverlay
        overlayId: "waterTemp"
        configType: "sensorCard"
        x: 58
        y: 60
        width: 250
        height: 113
        onConfigRequested: configPopup.openFor(overlayId, configType)

        Item {
            anchors.fill: parent

            Text {
                id: wtLabelText
                text: raceDash.wtLabel
                font.family: hyperspaceFont.name
                font.pixelSize: 40
                font.weight: Font.Light
                font.italic: true
                color: "#FFFFFF"
                anchors.top: parent.top
                anchors.right: parent.right
            }

            Text {
                id: wtValueText
                text: {
                    var v = PropertyRouter.getValue(raceDash.wtSensorKey);
                    return v !== undefined ? Number(v).toFixed(raceDash.wtDecimals) : "0";
                }
                font.family: hyperspaceFont.name
                font.pixelSize: 68
                font.weight: Font.Normal
                font.italic: true
                font.letterSpacing: -2.72
                color: "#FFFFFF"
                anchors.left: parent.left
                anchors.top: wtLabelText.bottom
                anchors.topMargin: 2
            }

            Text {
                text: raceDash.wtUnit
                font.family: hyperspaceFont.name
                font.pixelSize: 32
                font.weight: Font.Normal
                font.italic: true
                color: "#FFFFFF"
                anchors.right: parent.right
                anchors.bottom: wtValueText.bottom
                anchors.bottomMargin: 4
            }
        }
    }

    // ==================== Oil Pressure Card ====================
    DraggableOverlay {
        id: oilPressOverlay
        overlayId: "oilPressure"
        configType: "sensorCard"
        x: 58
        y: 201
        width: 250
        height: 113
        onConfigRequested: configPopup.openFor(overlayId, configType)

        Item {
            anchors.fill: parent

            Text {
                id: opLabelText
                text: raceDash.opLabel
                font.family: hyperspaceFont.name
                font.pixelSize: 40
                font.weight: Font.Light
                font.italic: true
                color: "#FFFFFF"
                anchors.top: parent.top
                anchors.right: parent.right
            }

            Text {
                id: opValueText
                text: {
                    var v = PropertyRouter.getValue(raceDash.opSensorKey);
                    return v !== undefined ? Number(v).toFixed(raceDash.opDecimals) : "0";
                }
                font.family: hyperspaceFont.name
                font.pixelSize: 68
                font.weight: Font.Normal
                font.italic: true
                font.letterSpacing: -2.72
                color: "#FFFFFF"
                anchors.left: parent.left
                anchors.top: opLabelText.bottom
                anchors.topMargin: 2
            }

            Text {
                text: raceDash.opUnit
                font.family: hyperspaceFont.name
                font.pixelSize: 32
                font.weight: Font.Normal
                font.italic: true
                color: "#FFFFFF"
                anchors.right: parent.right
                anchors.bottom: opValueText.bottom
                anchors.bottomMargin: 4
            }
        }
    }

    // ==================== Status Rows ====================
    DraggableOverlay {
        id: statusOverlay
        overlayId: "statusBox"
        x: 58
        y: 379
        width: statusContent.width
        height: statusContent.height

        Column {
            id: statusContent
            width: 250
            spacing: 50

            DraggableOverlay {
                id: statusRow0Overlay
                overlayId: "statusRow0"
                configType: "statusRow"
                width: 250
                height: 32
                onConfigRequested: configPopup.openFor(overlayId, configType)

                Row {
                    spacing: 0
                    Text {
                        text: raceDash.sr0Label
                        font.family: hyperspaceFont.name
                        font.pixelSize: 32
                        font.weight: Font.Normal
                        font.italic: true
                        color: "#FFFFFF"
                        width: 190
                    }
                    Text {
                        text: {
                            var v = PropertyRouter.getValue(raceDash.sr0SensorKey);
                            return (v !== undefined && Number(v) > raceDash.sr0Threshold) ? "ON" : "OFF";
                        }
                        font.family: hyperspaceFont.name
                        font.pixelSize: 32
                        font.weight: Font.Normal
                        font.italic: true
                        color: {
                            var v = PropertyRouter.getValue(raceDash.sr0SensorKey);
                            return (v !== undefined && Number(v) > raceDash.sr0Threshold) ? "#1ED033" : "#FF0909";
                        }
                        width: 60
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }

            DraggableOverlay {
                id: statusRow1Overlay
                overlayId: "statusRow1"
                configType: "statusRow"
                width: 250
                height: 32
                onConfigRequested: configPopup.openFor(overlayId, configType)

                Row {
                    spacing: 0
                    Text {
                        text: raceDash.sr1Label
                        font.family: hyperspaceFont.name
                        font.pixelSize: 32
                        font.weight: Font.Normal
                        font.italic: true
                        color: "#FFFFFF"
                        width: 190
                    }
                    Text {
                        text: {
                            var v = PropertyRouter.getValue(raceDash.sr1SensorKey);
                            return (v !== undefined && Number(v) > raceDash.sr1Threshold) ? "ON" : "OFF";
                        }
                        font.family: hyperspaceFont.name
                        font.pixelSize: 32
                        font.weight: Font.Normal
                        font.italic: true
                        color: {
                            var v = PropertyRouter.getValue(raceDash.sr1SensorKey);
                            return (v !== undefined && Number(v) > raceDash.sr1Threshold) ? "#1ED033" : "#FF0909";
                        }
                        width: 60
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }

    // ==================== Brake Bias Needle ====================
    DraggableOverlay {
        id: biasNeedleOverlay
        overlayId: "biasNeedle"
        x: 274
        y: 603
        width: 12
        height: 28

        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = "#FFFFFF";
                var cx = width / 2;
                ctx.beginPath();
                ctx.moveTo(cx - 1.5, 0);
                ctx.lineTo(cx + 1.5, 0);
                ctx.lineTo(cx + 1.5, height - 10);
                ctx.lineTo(cx + 6, height - 10);
                ctx.lineTo(cx, height);
                ctx.lineTo(cx - 6, height - 10);
                ctx.lineTo(cx - 1.5, height - 10);
                ctx.closePath();
                ctx.fill();
            }
        }
    }

    // ==================== Tach Arc ====================
    DraggableOverlay {
        id: tachArcOverlay
        overlayId: "tachGroup"
        configType: "tachGroup"
        x: 498
        y: 80
        width: 595
        height: 595
        onConfigRequested: configPopup.openFor(overlayId, configType)

        ArcFillOverlay {
            anchors.fill: parent
            value: {
                var v = PropertyRouter.getValue(raceDash.tachSensorKey);
                return v !== undefined ? Number(v) : 0;
            }
            minValue: raceDash.tachMin
            maxValue: raceDash.tachMax
            startAngleDeg: 135
            sweepAngleDeg: 270
            arcOuterRadius: 0.434
            arcInnerRadius: 0.225
            arcColorStart: raceDash.tachArcColorStart
            arcColorEnd: raceDash.tachArcColorEnd
            startupAnimation: true
        }
    }

    // ==================== Tach Text + Gear ====================
    DraggableOverlay {
        id: tachTextOverlay
        overlayId: "tachGroup"
        configType: "tachGroup"
        x: 660
        y: 238
        width: tachContent.width
        height: tachContent.height
        onConfigRequested: configPopup.openFor(overlayId, configType)

        Column {
            id: tachContent
            spacing: 0

            GearIndicator {
                id: gearDisplay
                gear: {
                    var v = PropertyRouter.getValue(raceDash.tachGearKey);
                    return v !== undefined ? Number(v) : 0;
                }
                fontFamily: hyperspaceFont.name
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: {
                    var v = PropertyRouter.getValue(raceDash.tachSensorKey);
                    return v !== undefined ? Number(v).toFixed(raceDash.tachDecimals) : "0";
                }
                font.family: hyperspaceFont.name
                font.pixelSize: 122
                font.weight: Font.Normal
                color: "#FFFFFF"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: raceDash.tachUnit
                font.family: hyperspaceFont.name
                font.pixelSize: 44
                font.weight: Font.Normal
                font.italic: true
                color: "#FFFFFF"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ==================== Speed Arc ====================
    DraggableOverlay {
        id: speedArcOverlay
        overlayId: "speedGroup"
        configType: "speedGroup"
        x: 1058
        y: 154
        width: 521
        height: 521
        onConfigRequested: configPopup.openFor(overlayId, configType)

        ArcFillOverlay {
            anchors.fill: parent
            value: {
                var v = PropertyRouter.getValue(raceDash.speedSensorKey);
                return v !== undefined ? Number(v) : 0;
            }
            minValue: raceDash.speedMin
            maxValue: raceDash.speedMax
            startAngleDeg: 135
            sweepAngleDeg: 270
            arcOuterRadius: 0.434
            arcInnerRadius: 0.225
            arcColorStart: raceDash.speedArcColorStart
            arcColorEnd: raceDash.speedArcColorEnd
            startupAnimation: true
        }
    }

    // ==================== Speed Text ====================
    DraggableOverlay {
        id: speedTextOverlay
        overlayId: "speedGroup"
        configType: "speedGroup"
        x: 1229
        y: 374
        width: speedContent.width
        height: speedContent.height
        onConfigRequested: configPopup.openFor(overlayId, configType)

        Column {
            id: speedContent
            spacing: 2

            Text {
                text: {
                    var v = PropertyRouter.getValue(raceDash.speedSensorKey);
                    return v !== undefined ? Number(v).toFixed(raceDash.speedDecimals) : "0";
                }
                font.family: hyperspaceFont.name
                font.pixelSize: 122
                font.weight: Font.Normal
                color: "#FFFFFF"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: raceDash.speedUnit
                font.family: hyperspaceFont.name
                font.pixelSize: 44
                font.weight: Font.Normal
                font.italic: true
                color: "#FFFFFF"
                anchors.right: parent.right
            }
        }
    }

    // ==================== Bottom Bar ====================
    DraggableOverlay {
        id: bottomBarOverlay
        overlayId: "bottomBar"
        configType: "staticText"
        x: 0
        y: 680
        width: 1600
        height: 40
        onConfigRequested: configPopup.openFor(overlayId, configType)

        BottomStatusBar {
            anchors.fill: parent
            teamName: raceDash.bbTeamName
            systemOk: true
            fontFamily: hyperspaceFont.name
        }
    }

    // ==================== Edit Mode Toolbar ====================
    Rectangle {
        id: editToolbar
        z: 250
        width: toolbarRow.width + 24
        height: 44
        radius: 22
        color: "#DD1a1a36"
        border.color: "#3a3a60"
        border.width: 1
        anchors.horizontalCenter: parent.horizontalCenter
        y: 8
        visible: shiftOverlay.editMode || waterTempOverlay.editMode ||
                 oilPressOverlay.editMode || statusOverlay.editMode ||
                 biasNeedleOverlay.editMode || tachArcOverlay.editMode ||
                 tachTextOverlay.editMode || speedArcOverlay.editMode ||
                 speedTextOverlay.editMode || bottomBarOverlay.editMode

        Row {
            id: toolbarRow
            anchors.centerIn: parent
            spacing: 8

            Rectangle {
                width: lockLabel.width + 20; height: 32; radius: 16
                color: OverlayConfig.positionsLocked ? "#663333" : "#336633"
                Text {
                    id: lockLabel
                    anchors.centerIn: parent
                    text: OverlayConfig.positionsLocked ? "Unlock" : "Lock"
                    font.pixelSize: 13; font.weight: Font.Bold; color: "#FFFFFF"
                }
                TapHandler {
                    onTapped: OverlayConfig.positionsLocked = !OverlayConfig.positionsLocked
                }
            }

            Rectangle {
                width: resetLabel.width + 20; height: 32; radius: 16
                color: "#553333"
                Text {
                    id: resetLabel
                    anchors.centerIn: parent
                    text: "Reset Positions"
                    font.pixelSize: 13; font.weight: Font.Bold; color: "#FFFFFF"
                }
                TapHandler {
                    onTapped: OverlayConfig.resetAllPositions()
                }
            }

            Rectangle {
                width: closeAllLabel.width + 20; height: 32; radius: 16
                color: "#333355"
                Text {
                    id: closeAllLabel
                    anchors.centerIn: parent
                    text: "Close Edit"
                    font.pixelSize: 13; font.weight: Font.Bold; color: "#8888AA"
                }
                TapHandler {
                    onTapped: {
                        shiftOverlay.editMode = false;
                        waterTempOverlay.editMode = false;
                        oilPressOverlay.editMode = false;
                        statusOverlay.editMode = false;
                        biasNeedleOverlay.editMode = false;
                        tachArcOverlay.editMode = false;
                        tachTextOverlay.editMode = false;
                        speedArcOverlay.editMode = false;
                        speedTextOverlay.editMode = false;
                        bottomBarOverlay.editMode = false;
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        z: 300
        color: "transparent"
        WarningLoader {}
    }
}
