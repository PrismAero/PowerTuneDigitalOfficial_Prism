import QtQuick 2.15
import QtQuick.Controls 2.15
import PrismPT.Dashboard 1.0
import PowerTune.UI 1.0
import PowerTune.Gauges.Shared 1.0
import PowerTune.Gauges.RaceDash 1.0

Item {
    id: root

    property string dashboardId: "racedash"
    property var overlayConfigs: ({})
    property var overlayDefinitions: [
        {id: "tachCluster", legacyIds: ["tachGroup", "gearIndicator"]},
        {id: "speedCluster", legacyIds: ["speedGroup"]},
        {id: "shiftIndicator", legacyIds: []},
        {id: "waterTemp", legacyIds: []},
        {id: "oilPressure", legacyIds: []},
        {id: "statusRow0", legacyIds: []},
        {id: "statusRow1", legacyIds: []},
        {id: "brakeBias", legacyIds: []},
        {id: "bottomBar", legacyIds: []}
    ]

    function migrateLegacyOverlayConfigs() {
        for (var i = 0; i < overlayDefinitions.length; ++i) {
            var definition = overlayDefinitions[i];
            if (!definition.legacyIds || definition.legacyIds.length === 0)
                continue;

            var current = AppSettings.loadOverlayConfig(dashboardId, definition.id);
            if (objectHasKeys(current))
                continue;

            var mergedLegacy = {};
            var foundLegacy = false;
            for (var j = 0; j < definition.legacyIds.length; ++j) {
                var legacyId = definition.legacyIds[j];
                var legacyLoaded = AppSettings.loadOverlayConfig(dashboardId, legacyId);
                if (objectHasKeys(legacyLoaded)) {
                    mergeConfig(mergedLegacy, legacyLoaded);
                    AppSettings.removeOverlayConfig(dashboardId, legacyId);
                    foundLegacy = true;
                }
            }

            if (foundLegacy)
                AppSettings.saveOverlayConfig(dashboardId, definition.id, mergedLegacy);
        }
    }

    function mergeConfig(target, source) {
        for (var key in source)
            target[key] = source[key];
    }

    function normalizeAnalogSensorKey(key) {
        if (key === undefined || key === null)
            return "";

        var trimmed = String(key).trim();
        var match = trimmed.match(/^EXAnalogInput([0-7])$/);
        if (match && match.length === 2)
            return "EXAnalogCalc" + match[1];

        return trimmed;
    }

    function normalizePersistedOverlaySensorBindings() {
        for (var i = 0; i < overlayDefinitions.length; ++i) {
            var id = overlayDefinitions[i].id;
            var loaded = AppSettings.loadOverlayConfig(dashboardId, id);
            if (!objectHasKeys(loaded))
                continue;

            var changed = false;
            if (loaded.sensorKey !== undefined) {
                var normalizedSensorKey = normalizeAnalogSensorKey(loaded.sensorKey);
                if (normalizedSensorKey !== loaded.sensorKey) {
                    loaded.sensorKey = normalizedSensorKey;
                    changed = true;
                }
            }

            if (loaded.gearKey !== undefined) {
                var normalizedGearKey = normalizeAnalogSensorKey(loaded.gearKey);
                if (normalizedGearKey !== loaded.gearKey) {
                    loaded.gearKey = normalizedGearKey;
                    changed = true;
                }
            }

            if (changed)
                AppSettings.saveOverlayConfig(dashboardId, id, loaded);
        }
    }

    function objectHasKeys(obj) {
        for (var key in obj)
            return true;
        return false;
    }

    function refreshConfigs() {
        var ids = [];
        for (var i = 0; i < overlayDefinitions.length; ++i)
            ids.push(overlayDefinitions[i].id);

        var loadedById = AppSettings.loadOverlayConfigs(dashboardId, ids);
        var nextConfigs = {};
        for (var j = 0; j < overlayDefinitions.length; ++j) {
            var id = overlayDefinitions[j].id;
            var defaults = OverlayDefaults.defaultsFor(id);
            var merged = {};
            for (var key in defaults)
                merged[key] = defaults[key];
            var loaded = loadedById[id] || ({});
            if (objectHasKeys(loaded)) {
                if (loaded.sensorKey !== undefined)
                    loaded.sensorKey = normalizeAnalogSensorKey(loaded.sensorKey);
                if (loaded.gearKey !== undefined)
                    loaded.gearKey = normalizeAnalogSensorKey(loaded.gearKey);
                mergeConfig(merged, loaded);
            }
            nextConfigs[id] = merged;
        }
        overlayConfigs = nextConfigs;
    }

    anchors.fill: parent

    Component.onCompleted: {
        migrateLegacyOverlayConfigs();
        normalizePersistedOverlaySensorBindings();
        refreshConfigs();
    }

    Popup {
        id: layoutPopup

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        focus: true
        modal: false
        padding: 12
        width: 240
        x: root.width - width - 16
        y: 16

        background: Rectangle {
            border.color: Qt.rgba(1, 1, 1, 0.16)
            color: Qt.rgba(0.05, 0.05, 0.05, 0.92)
            radius: 10
        }

        Column {
            anchors.fill: parent
            spacing: 10

            Text {
                color: "#FFFFFF"
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontLabel
                font.weight: Font.DemiBold
                text: "Layout Tools"
            }

            StyledSwitch {
                checked: OverlayConfig.positionsLocked
                text: OverlayConfig.positionsLocked ? "Positions Locked" : "Positions Unlocked"
                width: parent.width

                onToggled: OverlayConfig.positionsLocked = checked
            }

            StyledButton {
                danger: true
                text: "Reset Positions"
                width: parent.width

                onClicked: {
                    OverlayConfig.resetAllPositions();
                    layoutPopup.close();
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
        fillMode: Image.Stretch
        smooth: true
        source: DashboardTheme.backgroundAsset
    }

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 10
        border.color: Qt.rgba(1, 1, 1, 0.18)
        color: Qt.rgba(0, 0, 0, 0.35)
        height: 34
        radius: 17
        width: 34
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
                    layoutPopup.close();
                else
                    layoutPopup.open();
            }
        }
    }

    OverlayConfigPopup {
        id: overlayPopup

        dashboardId: root.dashboardId

        onConfigChanged: function (overlayId) {
            root.refreshConfigs();
        }
    }

    DraggableOverlay {
        configType: "shift"
        height: 30
        overlayId: "shiftIndicator"
        width: 925
        x: DashboardTheme.defaultShiftX
        y: DashboardTheme.defaultShiftY

        onConfigRequested: function(overlayId, configType) { overlayPopup.openFor(overlayId, configType); }

        ShiftIndicator {
            anchors.fill: parent
            config: root.overlayConfigs.shiftIndicator || ({})
        }
    }

    DraggableOverlay {
        configType: "tachCluster"
        height: width
        overlayId: "tachCluster"
        width: root.overlayConfigs.tachCluster && root.overlayConfigs.tachCluster.overlaySize !== undefined ? Number(
                                                                                                                  root.overlayConfigs.tachCluster.overlaySize) :
                                                                                                              DashboardTheme.defaultTachSize
        x: DashboardTheme.defaultTachX
        y: DashboardTheme.defaultTachY

        onConfigRequested: function(overlayId, configType) { overlayPopup.openFor(overlayId, configType); }

        TachCluster {
            anchors.fill: parent
            config: root.overlayConfigs.tachCluster || ({})
        }
    }

    DraggableOverlay {
        configType: "speedCluster"
        height: width
        overlayId: "speedCluster"
        width: root.overlayConfigs.speedCluster && root.overlayConfigs.speedCluster.overlaySize !== undefined ? Number(
                                                                                                                    root.overlayConfigs.speedCluster.overlaySize) :
                                                                                                                DashboardTheme.defaultSpeedSize
        x: DashboardTheme.defaultSpeedX
        y: DashboardTheme.defaultSpeedY

        onConfigRequested: function(overlayId, configType) { overlayPopup.openFor(overlayId, configType); }

        SpeedCluster {
            anchors.fill: parent
            config: root.overlayConfigs.speedCluster || ({})
        }
    }

    DraggableOverlay {
        configType: "sensorCard"
        height: 113
        overlayId: "waterTemp"
        width: 250
        x: DashboardTheme.defaultWaterTempX
        y: DashboardTheme.defaultWaterTempY

        onConfigRequested: function(overlayId, configType) { overlayPopup.openFor(overlayId, configType); }

        SensorCard {
            anchors.fill: parent
            config: root.overlayConfigs.waterTemp || ({})
        }
    }

    DraggableOverlay {
        configType: "sensorCard"
        height: 113
        overlayId: "oilPressure"
        width: 250
        x: DashboardTheme.defaultOilPressureX
        y: DashboardTheme.defaultOilPressureY

        onConfigRequested: function(overlayId, configType) { overlayPopup.openFor(overlayId, configType); }

        SensorCard {
            anchors.fill: parent
            config: root.overlayConfigs.oilPressure || ({})
        }
    }

    DraggableOverlay {
        configType: "statusRow"
        height: 25
        overlayId: "statusRow0"
        width: 250
        x: DashboardTheme.defaultStatusRow0X
        y: DashboardTheme.defaultStatusRow0Y

        onConfigRequested: function(overlayId, configType) { overlayPopup.openFor(overlayId, configType); }

        StatusBox {
            anchors.fill: parent
            config: root.overlayConfigs.statusRow0 || ({})
        }
    }

    DraggableOverlay {
        configType: "statusRow"
        height: 25
        overlayId: "statusRow1"
        width: 250
        x: DashboardTheme.defaultStatusRow1X
        y: DashboardTheme.defaultStatusRow1Y

        onConfigRequested: function(overlayId, configType) { overlayPopup.openFor(overlayId, configType); }

        StatusBox {
            anchors.fill: parent
            config: root.overlayConfigs.statusRow1 || ({})
        }
    }

    DraggableOverlay {
        configType: "brakebias"
        height: 82
        overlayId: "brakeBias"
        width: 365
        x: DashboardTheme.defaultBrakeBiasX
        y: DashboardTheme.defaultBrakeBiasY

        onConfigRequested: function(overlayId, configType) { overlayPopup.openFor(overlayId, configType); }

        BrakeBiasBar {
            anchors.fill: parent
            config: root.overlayConfigs.brakeBias || ({})
        }
    }

    DraggableOverlay {
        configType: "bottombar"
        height: 40
        overlayId: "bottomBar"
        width: 1600
        x: DashboardTheme.defaultBottomBarX
        y: DashboardTheme.defaultBottomBarY

        onConfigRequested: function(overlayId, configType) { overlayPopup.openFor(overlayId, configType); }

        BottomStatusBar {
            anchors.fill: parent
            config: root.overlayConfigs.bottomBar || ({})
        }
    }

    Item {
        anchors.fill: parent
        z: 300

        WarningLoader {
        }
    }
}
