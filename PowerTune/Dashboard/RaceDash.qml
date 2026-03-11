import QtQuick 2.15
import QtQuick.Controls 2.15
import PrismPT.Dashboard 1.0
import PowerTune.UI 1.0
import PowerTune.Gauges.Shared 1.0
import PowerTune.Gauges.RaceDash 1.0

Item {
    id: root
    anchors.fill: parent

    property string dashboardId: "racedash"
    property var overlayConfigs: ({})

    function normalizeArcConfig(id, merged) {
        var normalized = {}
        for (var key in merged)
            normalized[key] = merged[key]

        if (id === "tachGroup") {
            normalized.shapeMode = "tachSvg"
            delete normalized.pathStart
            delete normalized.pathEnd
            delete normalized.rotationDeg
            delete normalized.thicknessScale
            delete normalized.startAngle
            delete normalized.sweepAngle
            delete normalized.arcWidth
            delete normalized.arcColorStart
            delete normalized.arcColorMid
            delete normalized.arcColorMidPos
            delete normalized.arcColorEnd
            delete normalized.arcBgColor
            delete normalized.warningColor
            if (normalized.overlaySize === undefined)
                normalized.overlaySize = DashboardTheme.defaultTachSize
            if (normalized.referenceOverlaySize === undefined)
                normalized.referenceOverlaySize = DashboardTheme.defaultTachSize
            if (normalized.valueOffsetY === undefined)
                normalized.valueOffsetY = 94
            if (normalized.contentRightInsetRatio === undefined)
                normalized.contentRightInsetRatio = 0.0583
            if (normalized.contentBottomInsetRatio === undefined)
                normalized.contentBottomInsetRatio = 0.151
        } else if (id === "speedGroup") {
            normalized.shapeMode = "speedSvg"
            delete normalized.pathStart
            delete normalized.pathEnd
            delete normalized.rotationDeg
            delete normalized.thicknessScale
            delete normalized.startAngle
            delete normalized.sweepAngle
            delete normalized.arcWidth
            delete normalized.arcColorStart
            delete normalized.arcColorMid
            delete normalized.arcColorMidPos
            delete normalized.arcColorEnd
            delete normalized.arcBgColor
            delete normalized.warningColor
            if (normalized.overlaySize === undefined)
                normalized.overlaySize = DashboardTheme.defaultSpeedSize
            if (normalized.referenceOverlaySize === undefined)
                normalized.referenceOverlaySize = DashboardTheme.defaultSpeedSize
            if (normalized.valueOffsetY === undefined)
                normalized.valueOffsetY = 62
            if (normalized.contentRightInsetRatio === undefined)
                normalized.contentRightInsetRatio = 0.0583
            if (normalized.contentBottomInsetRatio === undefined)
                normalized.contentBottomInsetRatio = 0.151
        }

        return normalized
    }

    function loadOverlayConfig(id, defaults) {
        var loaded = AppSettings.loadOverlayConfig(dashboardId, id)
        var merged = {}
        for (var key in defaults)
            merged[key] = defaults[key]
        for (var loadedKey in loaded)
            merged[loadedKey] = loaded[loadedKey]
        return normalizeArcConfig(id, merged)
    }

    function refreshConfigs() {
        overlayConfigs = {
            tachGroup: loadOverlayConfig("tachGroup", {
                sensorKey: "rpm",
                shapeMode: "tachSvg",
                minValue: 0,
                maxValue: AppSettings.getValue("Max RPM", 10000),
                unit: "RPM",
                decimals: 0,
                overlaySize: DashboardTheme.defaultTachSize,
                referenceOverlaySize: DashboardTheme.defaultTachSize,
                shiftPoint: AppSettings.getValue("Shift Light1", 3000) / Math.max(1, AppSettings.getValue("Max RPM", 10000)),
                warningEnabled: false,
                alignmentOverrideEnabled: false,
                alignmentOverrideProgress: 1.0,
                valueOffsetY: 94,
                contentRightInsetRatio: 0.0583,
                contentBottomInsetRatio: 0.151
            }),
            speedGroup: loadOverlayConfig("speedGroup", {
                sensorKey: "speed",
                shapeMode: "speedSvg",
                minValue: 0,
                maxValue: 200,
                unit: "MPH",
                decimals: 0,
                overlaySize: DashboardTheme.defaultSpeedSize,
                referenceOverlaySize: DashboardTheme.defaultSpeedSize,
                warningEnabled: false,
                alignmentOverrideEnabled: false,
                alignmentOverrideProgress: 1.0,
                valueOffsetY: 62,
                contentRightInsetRatio: 0.0583,
                contentBottomInsetRatio: 0.151
            }),
            gearIndicator: loadOverlayConfig("gearIndicator", {
                gearKey: "Gear",
                gearTextColor: "#FFFFFF",
                gearFontSize: 140.013,
                suffixFontSize: 52.505
            }),
            shiftIndicator: loadOverlayConfig("shiftIndicator", {
                sensorKey: "rpm",
                maxValue: AppSettings.getValue("Max RPM", 10000),
                shiftPoint: AppSettings.getValue("Shift Light1", 3000) / Math.max(1, AppSettings.getValue("Max RPM", 10000)),
                shiftCount: 11,
                shiftPattern: "center-out"
            }),
            waterTemp: loadOverlayConfig("waterTemp", {
                sensorKey: "Watertemp",
                label: "Water Temp",
                unit: "F°",
                decimals: 2
            }),
            oilPressure: loadOverlayConfig("oilPressure", {
                sensorKey: "oilpres",
                label: "Oil Pressure",
                unit: "PSI",
                decimals: 2
            }),
            statusRow0: loadOverlayConfig("statusRow0", {
                sensorKey: "DigitalInput1",
                label: "Fuel Pump:",
                threshold: 0.5,
                onColor: "#1ED033",
                offColor: "#FF0909"
            }),
            statusRow1: loadOverlayConfig("statusRow1", {
                sensorKey: "DigitalInput2",
                label: "Cooling Fan:",
                threshold: 0.5,
                onColor: "#1ED033",
                offColor: "#FF0909"
            }),
            brakeBias: loadOverlayConfig("brakeBias", {
                leftLabel: "RWD",
                rightLabel: "FWD",
                minValue: 0,
                maxValue: 100
            }),
            bottomBar: loadOverlayConfig("bottomBar", {
                text: "Cardinal Racing",
                timeEnabled: true
            })
        }
    }

    Component.onCompleted: refreshConfigs()

    Popup {
        id: layoutPopup
        x: root.width - width - 16
        y: 16
        width: 240
        modal: false
        focus: true
        padding: 12
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Qt.rgba(0.05, 0.05, 0.05, 0.92)
            border.color: Qt.rgba(1, 1, 1, 0.16)
            radius: 10
        }

        Column {
            anchors.fill: parent
            spacing: 10

            Text {
                text: "Layout Tools"
                color: "#FFFFFF"
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontLabel
                font.weight: Font.DemiBold
            }

            StyledSwitch {
                width: parent.width
                text: OverlayConfig.positionsLocked ? "Positions Locked" : "Positions Unlocked"
                checked: OverlayConfig.positionsLocked
                onToggled: OverlayConfig.positionsLocked = checked
            }

            StyledButton {
                width: parent.width
                text: "Reset Positions"
                danger: true
                onClicked: {
                    OverlayConfig.resetAllPositions()
                    layoutPopup.close()
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Image {
        anchors.fill: parent
        source: DashboardTheme.backgroundAsset
        fillMode: Image.Stretch
        smooth: true
    }

    Rectangle {
        width: 34
        height: 34
        radius: 17
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.rightMargin: 10
        color: Qt.rgba(0, 0, 0, 0.35)
        border.color: Qt.rgba(1, 1, 1, 0.18)
        z: 500

        Text {
            anchors.centerIn: parent
            color: "#FFFFFF"
            font.family: SettingsTheme.fontFamily
            font.pixelSize: 18
            text: "\u2261"
        }

        TapHandler {
            onTapped: {
                if (layoutPopup.opened)
                    layoutPopup.close()
                else
                    layoutPopup.open()
            }
        }
    }

    OverlayConfigPopup {
        id: overlayPopup
        dashboardId: root.dashboardId
        onConfigChanged: root.refreshConfigs()
    }

    DraggableOverlay {
        overlayId: "shiftIndicator"
        configType: "shift"
        x: DashboardTheme.defaultShiftX
        y: DashboardTheme.defaultShiftY
        width: 925
        height: 30
        onConfigRequested: function(requestedOverlayId, requestedConfigType) {
            overlayPopup.openFor(requestedOverlayId, requestedConfigType)
        }

        ShiftIndicator {
            anchors.fill: parent
            config: root.overlayConfigs.shiftIndicator || ({})
        }
    }

    DraggableOverlay {
        overlayId: "tachGroup"
        configType: "tachGroup"
        x: DashboardTheme.defaultTachX
        y: DashboardTheme.defaultTachY
        width: root.overlayConfigs.tachGroup && root.overlayConfigs.tachGroup.overlaySize !== undefined
            ? Number(root.overlayConfigs.tachGroup.overlaySize)
            : DashboardTheme.defaultTachSize
        height: width
        onConfigRequested: function(requestedOverlayId, requestedConfigType) {
            overlayPopup.openFor(requestedOverlayId, requestedConfigType)
        }

        ArcGauge {
            anchors.fill: parent
            config: root.overlayConfigs.tachGroup || ({})
        }
    }

    DraggableOverlay {
        overlayId: "gearIndicator"
        configType: "gear"
        x: 741
        y: 243
        width: 168
        height: 117
        onConfigRequested: function(requestedOverlayId, requestedConfigType) {
            overlayPopup.openFor(requestedOverlayId, requestedConfigType)
        }

        GearIndicator {
            anchors.fill: parent
            config: root.overlayConfigs.gearIndicator || ({})
        }
    }

    DraggableOverlay {
        overlayId: "speedGroup"
        configType: "speedGroup"
        x: DashboardTheme.defaultSpeedX
        y: DashboardTheme.defaultSpeedY
        width: root.overlayConfigs.speedGroup && root.overlayConfigs.speedGroup.overlaySize !== undefined
            ? Number(root.overlayConfigs.speedGroup.overlaySize)
            : DashboardTheme.defaultSpeedSize
        height: width
        onConfigRequested: function(requestedOverlayId, requestedConfigType) {
            overlayPopup.openFor(requestedOverlayId, requestedConfigType)
        }

        ArcGauge {
            anchors.fill: parent
            config: root.overlayConfigs.speedGroup || ({})
        }
    }

    DraggableOverlay {
        overlayId: "waterTemp"
        configType: "sensorCard"
        x: DashboardTheme.defaultWaterTempX
        y: DashboardTheme.defaultWaterTempY
        width: 250
        height: 113
        onConfigRequested: function(requestedOverlayId, requestedConfigType) {
            overlayPopup.openFor(requestedOverlayId, requestedConfigType)
        }

        SensorCard {
            anchors.fill: parent
            config: root.overlayConfigs.waterTemp || ({})
        }
    }

    DraggableOverlay {
        overlayId: "oilPressure"
        configType: "sensorCard"
        x: DashboardTheme.defaultOilPressureX
        y: DashboardTheme.defaultOilPressureY
        width: 250
        height: 113
        onConfigRequested: function(requestedOverlayId, requestedConfigType) {
            overlayPopup.openFor(requestedOverlayId, requestedConfigType)
        }

        SensorCard {
            anchors.fill: parent
            config: root.overlayConfigs.oilPressure || ({})
        }
    }

    DraggableOverlay {
        overlayId: "statusRow0"
        configType: "statusRow"
        x: DashboardTheme.defaultStatusRow0X
        y: DashboardTheme.defaultStatusRow0Y
        width: 250
        height: 25
        onConfigRequested: function(requestedOverlayId, requestedConfigType) {
            overlayPopup.openFor(requestedOverlayId, requestedConfigType)
        }

        StatusBox {
            anchors.fill: parent
            config: root.overlayConfigs.statusRow0 || ({})
        }
    }

    DraggableOverlay {
        overlayId: "statusRow1"
        configType: "statusRow"
        x: DashboardTheme.defaultStatusRow1X
        y: DashboardTheme.defaultStatusRow1Y
        width: 250
        height: 25
        onConfigRequested: function(requestedOverlayId, requestedConfigType) {
            overlayPopup.openFor(requestedOverlayId, requestedConfigType)
        }

        StatusBox {
            anchors.fill: parent
            config: root.overlayConfigs.statusRow1 || ({})
        }
    }

    DraggableOverlay {
        overlayId: "brakeBias"
        configType: "brakebias"
        x: DashboardTheme.defaultBrakeBiasX
        y: DashboardTheme.defaultBrakeBiasY
        width: 365
        height: 82
        onConfigRequested: function(requestedOverlayId, requestedConfigType) {
            overlayPopup.openFor(requestedOverlayId, requestedConfigType)
        }

        BrakeBiasBar {
            anchors.fill: parent
            config: root.overlayConfigs.brakeBias || ({})
        }
    }

    DraggableOverlay {
        overlayId: "bottomBar"
        configType: "bottombar"
        x: DashboardTheme.defaultBottomBarX
        y: DashboardTheme.defaultBottomBarY
        width: 1600
        height: 40
        onConfigRequested: function(requestedOverlayId, requestedConfigType) {
            overlayPopup.openFor(requestedOverlayId, requestedConfigType)
        }

        BottomStatusBar {
            anchors.fill: parent
            config: root.overlayConfigs.bottomBar || ({})
        }
    }

    Item {
        anchors.fill: parent
        z: 300
        WarningLoader {}
    }
}
