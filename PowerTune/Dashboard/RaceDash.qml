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

    // -- Status row colors (configurable via overlay config) --
    property string sr0OnColor: "#1ED033"
    property string sr0OffColor: "#FF0909"
    property string sr1OnColor: "#1ED033"
    property string sr1OffColor: "#FF0909"

    // -- Reactive sensor values (driven by Connections, not getValue()) --
    property real _rpmValue: 0
    property real _gearValue: 0
    property real _speedValue: 0
    property real _wtValue: 0
    property real _opValue: 0
    property real _sr0Value: 0
    property real _sr1Value: 0

    // -- Bottom bar --
    property string bbTeamName: "Cardinal Racing"

    // ================================================================
    // Config system: apply persisted overlay config to components
    // ================================================================
    function applyOverlayConfig(overlayId, config) {
        // Map overlay IDs to their component references and apply config
        switch (overlayId) {
        case "rpmArc":
            tachArcGauge.applyConfig(config)
            // Also update tach group properties for text/gear/shift overlays
            if (config.sensorKey) tachSensorKey = config.sensorKey
            if (config.minValue !== undefined) tachMin = Number(config.minValue)
            if (config.maxValue !== undefined) tachMax = Number(config.maxValue)
            if (config.unit) tachUnit = config.unit
            if (config.decimals !== undefined) tachDecimals = Number(config.decimals)
            if (config.arcColorStart) tachArcColorStart = config.arcColorStart
            if (config.arcColorEnd) tachArcColorEnd = config.arcColorEnd
            break

        case "speedArc":
            speedArcGauge.applyConfig(config)
            // Also update speed group properties for text overlay
            if (config.sensorKey) speedSensorKey = config.sensorKey
            if (config.minValue !== undefined) speedMin = Number(config.minValue)
            if (config.maxValue !== undefined) speedMax = Number(config.maxValue)
            if (config.unit) speedUnit = config.unit
            if (config.decimals !== undefined) speedDecimals = Number(config.decimals)
            if (config.arcColorStart) speedArcColorStart = config.arcColorStart
            if (config.arcColorEnd) speedArcColorEnd = config.arcColorEnd
            break

        case "gearIndicator":
            if (config.gearKey) tachGearKey = config.gearKey
            if (config.gearTextColor) gearDisplay.textColor = config.gearTextColor
            if (config.gearFontSize) gearDisplay.fontSize = Number(config.gearFontSize)
            break

        case "shiftLights":
            if (config.sensorKey) tachSensorKey = config.sensorKey
            if (config.shiftPoint !== undefined) tachShiftPoint = Number(config.shiftPoint)
            if (config.shiftCount !== undefined) tachShiftCount = Number(config.shiftCount)
            if (config.shiftPattern) tachShiftPattern = config.shiftPattern
            break

        case "waterTempCard":
            waterTempCard.applyConfig(config)
            if (config.sensorKey) wtSensorKey = config.sensorKey
            if (config.label) wtLabel = config.label
            if (config.unit) wtUnit = config.unit
            if (config.decimals !== undefined) wtDecimals = Number(config.decimals)
            break

        case "oilPressCard":
            oilPressCard.applyConfig(config)
            if (config.sensorKey) opSensorKey = config.sensorKey
            if (config.label) opLabel = config.label
            if (config.unit) opUnit = config.unit
            if (config.decimals !== undefined) opDecimals = Number(config.decimals)
            break

        case "statusRow0":
            if (config.sensorKey) sr0SensorKey = config.sensorKey
            if (config.label) sr0Label = config.label
            if (config.threshold !== undefined) sr0Threshold = Number(config.threshold)
            if (config.onColor) sr0OnColor = config.onColor
            if (config.offColor) sr0OffColor = config.offColor
            break

        case "statusRow1":
            if (config.sensorKey) sr1SensorKey = config.sensorKey
            if (config.label) sr1Label = config.label
            if (config.threshold !== undefined) sr1Threshold = Number(config.threshold)
            if (config.onColor) sr1OnColor = config.onColor
            if (config.offColor) sr1OffColor = config.offColor
            break

        case "brakeBias":
            brakeBiasBar.applyConfig(config)
            break

        case "bottomBar":
            if (config.text) bbTeamName = config.text
            break
        }
    }

    // -- Load all persisted overlay configs at startup --
    Component.onCompleted: {
        var overlayIds = [
            "rpmArc", "speedArc", "gearIndicator", "shiftLights",
            "waterTempCard", "oilPressCard",
            "statusRow0", "statusRow1",
            "brakeBias", "bottomBar"
        ]
        for (var i = 0; i < overlayIds.length; i++) {
            var config = AppSettings.loadOverlayConfig("racedash", overlayIds[i])
            if (config && Object.keys(config).length > 0) {
                applyOverlayConfig(overlayIds[i], config)
            }
        }
    }

    // -- Listen to config popup save events --
    Connections {
        target: configPopup
        function onConfigChanged(overlayId) {
            var config = AppSettings.loadOverlayConfig("racedash", overlayId)
            if (config && Object.keys(config).length > 0) {
                applyOverlayConfig(overlayId, config)
            }
        }
    }

    OverlayConfigPopup {
        id: configPopup
    }

    // -- Reactive PropertyRouter bindings for all inline overlay values --
    // Replaces expression-based PropertyRouter.getValue() calls with event-driven
    // updates to avoid re-evaluation polling and ensure consistent reactivity.
    Connections {
        target: typeof PropertyRouter !== "undefined" ? PropertyRouter : null
        function onValueChanged(propertyName, value) {
            if (propertyName === raceDash.tachSensorKey)
                raceDash._rpmValue = Number(value)
            else if (propertyName === raceDash.tachGearKey)
                raceDash._gearValue = Number(value)
            else if (propertyName === raceDash.speedSensorKey)
                raceDash._speedValue = Number(value)
            else if (propertyName === raceDash.wtSensorKey)
                raceDash._wtValue = Number(value)
            else if (propertyName === raceDash.opSensorKey)
                raceDash._opValue = Number(value)
            else if (propertyName === raceDash.sr0SensorKey)
                raceDash._sr0Value = Number(value)
            else if (propertyName === raceDash.sr1SensorKey)
                raceDash._sr1Value = Number(value)
        }
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
        overlayId: "shiftLights"
        configType: "shift"
        x: 337
        y: 30
        width: shiftLights.width
        height: shiftLights.height
        onConfigRequested: function(overlayId, configType) {
            configPopup.openFor(overlayId, configType)
        }

        ShiftIndicator {
            id: shiftLights
            rpmValue: raceDash._rpmValue
            rpmMax: raceDash.tachMax
            shiftPoint: raceDash.tachShiftPoint
            pillCount: raceDash.tachShiftCount
            activationPattern: raceDash.tachShiftPattern
        }
    }

    // ==================== Water Temp Card ====================
    DraggableOverlay {
        id: waterTempOverlay
        overlayId: "waterTempCard"
        configType: "sensor"
        x: 58
        y: 60
        width: 250
        height: 113
        onConfigRequested: function(overlayId, configType) {
            configPopup.openFor(overlayId, configType)
        }

        SensorCard {
            id: waterTempCard
            anchors.fill: parent
            label: raceDash.wtLabel
            unit: raceDash.wtUnit
            decimals: raceDash.wtDecimals
            fontFamily: hyperspaceFont.name
            datasource: raceDash.wtSensorKey
            value: raceDash._wtValue
        }
    }

    // ==================== Oil Pressure Card ====================
    DraggableOverlay {
        id: oilPressOverlay
        overlayId: "oilPressCard"
        configType: "sensor"
        x: 58
        y: 201
        width: 250
        height: 113
        onConfigRequested: function(overlayId, configType) {
            configPopup.openFor(overlayId, configType)
        }

        SensorCard {
            id: oilPressCard
            anchors.fill: parent
            label: raceDash.opLabel
            unit: raceDash.opUnit
            decimals: raceDash.opDecimals
            fontFamily: hyperspaceFont.name
            datasource: raceDash.opSensorKey
            value: raceDash._opValue
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
                configType: "status"
                width: 250
                height: 32
                onConfigRequested: function(overlayId, configType) {
                    configPopup.openFor(overlayId, configType)
                }

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
                        text: raceDash._sr0Value > raceDash.sr0Threshold ? "ON" : "OFF"
                        font.family: hyperspaceFont.name
                        font.pixelSize: 32
                        font.weight: Font.Normal
                        font.italic: true
                        color: raceDash._sr0Value > raceDash.sr0Threshold ? raceDash.sr0OnColor : raceDash.sr0OffColor
                        width: 60
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }

            DraggableOverlay {
                id: statusRow1Overlay
                overlayId: "statusRow1"
                configType: "status"
                width: 250
                height: 32
                onConfigRequested: function(overlayId, configType) {
                    configPopup.openFor(overlayId, configType)
                }

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
                        text: raceDash._sr1Value > raceDash.sr1Threshold ? "ON" : "OFF"
                        font.family: hyperspaceFont.name
                        font.pixelSize: 32
                        font.weight: Font.Normal
                        font.italic: true
                        color: raceDash._sr1Value > raceDash.sr1Threshold ? raceDash.sr1OnColor : raceDash.sr1OffColor
                        width: 60
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }

    // ==================== Brake Bias ====================
    DraggableOverlay {
        id: brakeBiasOverlay
        overlayId: "brakeBias"
        configType: "brakebias"
        x: 274
        y: 590
        width: 457
        height: 82
        onConfigRequested: function(overlayId, configType) {
            configPopup.openFor(overlayId, configType)
        }

        BrakeBiasBar {
            id: brakeBiasBar
            anchors.fill: parent
            fontFamily: hyperspaceFont.name
        }
    }

    // ==================== Tach Arc ====================
    DraggableOverlay {
        id: tachArcOverlay
        overlayId: "rpmArc"
        configType: "arc"
        x: 498
        y: 80
        width: 595
        height: 595
        onConfigRequested: function(overlayId, configType) {
            configPopup.openFor(overlayId, configType)
        }

        ArcGauge {
            id: tachArcGauge
            anchors.fill: parent
            datasource: raceDash.tachSensorKey
            minValue: raceDash.tachMin
            maxValue: raceDash.tachMax
            startAngleDeg: 135
            endAngleDeg: 405
            arcWidthFraction: 0.209
            colorStart: raceDash.tachArcColorStart
            colorEnd: raceDash.tachArcColorEnd
            bgColor: "#151518"
            startupAnimation: true
        }
    }

    // ==================== Tach Text + Gear ====================
    DraggableOverlay {
        id: tachTextOverlay
        overlayId: "gearIndicator"
        configType: "gear"
        x: 660
        y: 238
        width: tachContent.width
        height: tachContent.height
        onConfigRequested: function(overlayId, configType) {
            configPopup.openFor(overlayId, configType)
        }

        Column {
            id: tachContent
            spacing: 0

            GearIndicator {
                id: gearDisplay
                gear: raceDash._gearValue
                fontFamily: hyperspaceFont.name
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: raceDash._rpmValue.toFixed(raceDash.tachDecimals)
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
        overlayId: "speedArc"
        configType: "arc"
        x: 1058
        y: 154
        width: 521
        height: 521
        onConfigRequested: function(overlayId, configType) {
            configPopup.openFor(overlayId, configType)
        }

        ArcGauge {
            id: speedArcGauge
            anchors.fill: parent
            datasource: raceDash.speedSensorKey
            minValue: raceDash.speedMin
            maxValue: raceDash.speedMax
            startAngleDeg: 135
            endAngleDeg: 405
            arcWidthFraction: 0.209
            colorStart: raceDash.speedArcColorStart
            colorEnd: raceDash.speedArcColorEnd
            bgColor: "#151518"
            startupAnimation: true
        }
    }

    // ==================== Speed Text ====================
    DraggableOverlay {
        id: speedTextOverlay
        overlayId: "speedArc"
        configType: "arc"
        x: 1229
        y: 374
        width: speedContent.width
        height: speedContent.height
        onConfigRequested: function(overlayId, configType) {
            configPopup.openFor(overlayId, configType)
        }

        Column {
            id: speedContent
            spacing: 2

            Text {
                text: raceDash._speedValue.toFixed(raceDash.speedDecimals)
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
        configType: "bottombar"
        x: 0
        y: 680
        width: 1600
        height: 40
        onConfigRequested: function(overlayId, configType) {
            configPopup.openFor(overlayId, configType)
        }

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
                 brakeBiasOverlay.editMode || tachArcOverlay.editMode ||
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
                        brakeBiasOverlay.editMode = false;
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
