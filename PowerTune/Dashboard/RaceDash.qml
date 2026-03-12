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

    function defaultClusterConfig(id) {
        if (id === "tachCluster") {
            return {
                shapeMode: "tachSvg",
                sensorKey: "rpm",
                minValue: 0,
                maxValue: AppSettings.getValue("Max RPM", 10000),
                unit: "RPM",
                decimals: 0,
                overlaySize: DashboardTheme.defaultTachSize,
                startAngle: 225,
                endAngle: 56,
                arcWidth: 0.285,
                arcScale: 0.945,
                arcOffsetX: 5,
                arcOffsetY: 0,
                minimumVisibleFraction: 0.08,
                startTaper: 0.18,
                endTaper: 0.18,
                testLoopEnabled: false,
                testLoopDuration: 1800,
                arcColorStart: "#8F4D17",
                arcColorMid: "#FF8A00",
                arcColorMidPos: 0.65,
                arcColorEnd: "#B00000",
                warningEnabled: false,
                warningThreshold: AppSettings.getValue("Shift Light1", 3000),
                warningColor: "#FF3300",
                warningFlash: true,
                warningFlashRate: 200,
                readoutTextColor: "#FFFFFF",
                readoutStep: 1,
                readoutOffsetX: 0,
                readoutOffsetY: 94,
                readoutValueScale: 0.213,
                readoutUnitScale: 0.076,
                unitOffsetX: 34,
                unitOffsetY: -2,
                readoutSpacing: -2,
                gearKey: "Gear",
                gearTextColor: "#FFFFFF",
                gearFontSize: 140.013,
                suffixFontSize: 52.505,
                gearOffsetX: 21.5,
                gearOffsetY: -76,
                gearWidth: 168,
                gearHeight: 117
            }
        }

        if (id === "speedCluster") {
            return {
                shapeMode: "speedSvg",
                sensorKey: "speed",
                minValue: 0,
                maxValue: 200,
                unit: "MPH",
                decimals: 0,
                overlaySize: DashboardTheme.defaultSpeedSize,
                startAngle: 225,
                endAngle: 315,
                arcWidth: 0.285,
                arcScale: 0.945,
                arcOffsetX: 5,
                arcOffsetY: 0,
                minimumVisibleFraction: 0.08,
                startTaper: 0.28,
                endTaper: 0.24,
                testLoopEnabled: false,
                testLoopDuration: 1800,
                arcColorStart: "#7A0D0D",
                arcColorMid: "#E11B1B",
                arcColorMidPos: 0.62,
                arcColorEnd: "#B00000",
                warningEnabled: false,
                warningThreshold: 180,
                warningColor: "#FF0000",
                warningFlash: true,
                warningFlashRate: 200,
                readoutTextColor: "#FFFFFF",
                readoutStep: 1,
                readoutOffsetX: 0,
                readoutOffsetY: 62,
                readoutValueScale: 0.213,
                readoutUnitScale: 0.076,
                unitOffsetX: 14,
                unitOffsetY: -2,
                readoutSpacing: -1
            }
        }

        return {}
    }

    function normalizeClusterConfig(id, merged) {
        if (id === "tachCluster") {
            merged.shapeMode = "tachSvg"
        } else if (id === "speedCluster") {
            merged.shapeMode = "speedSvg"
        }
        return merged
    }

    function objectHasKeys(obj) {
        for (var key in obj)
            return true
        return false
    }

    function mergeConfig(target, source) {
        for (var key in source)
            target[key] = source[key]
    }

    function loadOverlayConfig(id, defaults, legacyIds) {
        var loaded = AppSettings.loadOverlayConfig(dashboardId, id)
        var merged = {}
        for (var key in defaults)
            merged[key] = defaults[key]
        if (objectHasKeys(loaded)) {
            mergeConfig(merged, loaded)
        } else if (legacyIds !== undefined) {
            for (var i = 0; i < legacyIds.length; ++i) {
                var legacyLoaded = AppSettings.loadOverlayConfig(dashboardId, legacyIds[i])
                mergeConfig(merged, legacyLoaded)
            }
        }
        return normalizeClusterConfig(id, merged)
    }

    function refreshConfigs() {
        overlayConfigs = {
            tachCluster: loadOverlayConfig("tachCluster", defaultClusterConfig("tachCluster"), ["tachGroup", "gearIndicator"]),
            speedCluster: loadOverlayConfig("speedCluster", defaultClusterConfig("speedCluster"), ["speedGroup"]),
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
                sensorKey: "brakeBias",
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
        onConfigChanged: function(overlayId) { root.refreshConfigs() }
    }

    DraggableOverlay {
        overlayId: "shiftIndicator"
        configType: "shift"
        x: DashboardTheme.defaultShiftX
        y: DashboardTheme.defaultShiftY
        width: 925
        height: 30
        onConfigRequested: overlayPopup.openFor(overlayId, configType)

        ShiftIndicator {
            anchors.fill: parent
            config: root.overlayConfigs.shiftIndicator || ({})
        }
    }

    DraggableOverlay {
        overlayId: "tachCluster"
        configType: "tachCluster"
        x: DashboardTheme.defaultTachX
        y: DashboardTheme.defaultTachY
        width: root.overlayConfigs.tachCluster && root.overlayConfigs.tachCluster.overlaySize !== undefined
            ? Number(root.overlayConfigs.tachCluster.overlaySize)
            : DashboardTheme.defaultTachSize
        height: width
        onConfigRequested: overlayPopup.openFor(overlayId, configType)

        TachCluster {
            anchors.fill: parent
            config: root.overlayConfigs.tachCluster || ({})
        }
    }

    DraggableOverlay {
        overlayId: "speedCluster"
        configType: "speedCluster"
        x: DashboardTheme.defaultSpeedX
        y: DashboardTheme.defaultSpeedY
        width: root.overlayConfigs.speedCluster && root.overlayConfigs.speedCluster.overlaySize !== undefined
            ? Number(root.overlayConfigs.speedCluster.overlaySize)
            : DashboardTheme.defaultSpeedSize
        height: width
        onConfigRequested: overlayPopup.openFor(overlayId, configType)

        SpeedCluster {
            anchors.fill: parent
            config: root.overlayConfigs.speedCluster || ({})
        }
    }

    DraggableOverlay {
        overlayId: "waterTemp"
        configType: "sensorCard"
        x: DashboardTheme.defaultWaterTempX
        y: DashboardTheme.defaultWaterTempY
        width: 250
        height: 113
        onConfigRequested: overlayPopup.openFor(overlayId, configType)

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
        onConfigRequested: overlayPopup.openFor(overlayId, configType)

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
        onConfigRequested: overlayPopup.openFor(overlayId, configType)

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
        onConfigRequested: overlayPopup.openFor(overlayId, configType)

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
        onConfigRequested: overlayPopup.openFor(overlayId, configType)

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
        onConfigRequested: overlayPopup.openFor(overlayId, configType)

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
