import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

Popup {
    id: popup

    property string configType: ""
    property var currentConfig: ({})
    property string dashboardId: "racedash"
    property string overlayId: ""

    readonly property bool isArc: configType === "tachCluster" || configType === "speedCluster"
    readonly property bool isBottomBar: configType === "bottombar"
    readonly property bool isBrakeBias: configType === "brakebias"
    readonly property bool isCluster: configType === "tachCluster" || configType === "speedCluster"
    readonly property bool isGear: configType === "gear"
    readonly property bool isSensor: configType === "sensorCard"
    readonly property bool isShift: configType === "shift"
    readonly property bool isStatus: configType === "statusRow"
    readonly property bool isTachCluster: configType === "tachCluster"

    readonly property bool hasArcAlignment: isArc
    readonly property bool hasArcColors: isArc
    readonly property bool hasArcGeometry: isArc
    readonly property bool hasArcOverlaySize: configType === "tachCluster" || configType === "speedCluster"
    readonly property bool hasBiasLabels: isBrakeBias
    readonly property bool hasDatasource: isArc || isGear || isSensor || isStatus || isBrakeBias
    readonly property bool hasGearConfig: isGear || isTachCluster
    readonly property bool hasLabel: isSensor || isStatus
    readonly property bool hasReadoutConfig: isCluster
    readonly property bool hasShiftConfig: isShift
    readonly property bool hasStaticText: isBottomBar
    readonly property bool hasStatusConfig: isStatus
    readonly property bool hasUnitDecimals: isArc || isSensor
    readonly property bool hasValueRange: isArc || isBrakeBias
    readonly property bool hasWarning: isArc || isSensor || isShift

    property string sensorKey: ""
    property string labelText: ""
    property string unitText: ""
    property string staticText: ""
    property real minValue: 0
    property real maxValue: 0
    property int decimals: 0
    property real overlaySize: 0
    property real startAngle: 0
    property real endAngle: 0
    property real arcWidth: 0
    property real arcScale: 0
    property real arcOffsetX: 0
    property real arcOffsetY: 0
    property real minimumVisibleFraction: 0
    property real startTaper: 0
    property real endTaper: 0
    property bool testLoopEnabled: false
    property int testLoopDuration: 0
    property string arcColorStart: ""
    property string arcColorMid: ""
    property real arcColorMidPos: 0
    property string arcColorEnd: ""
    property real valueOffsetY: 0
    property real readoutOffsetX: 0
    property real readoutOffsetY: 0
    property real readoutStep: 0
    property real readoutValueScale: 0
    property real readoutUnitScale: 0
    property real unitOffsetX: 0
    property real unitOffsetY: 0
    property real readoutSpacing: 0
    property string readoutTextColor: ""
    property bool warningEnabled: false
    property real warningThreshold: 0
    property string warningColor: ""
    property bool warningFlash: false
    property int warningFlashRate: 0
    property string warningDirection: ""
    property string normalColor: ""
    property real threshold: 0
    property string onColor: ""
    property string offColor: ""
    property bool invertLogic: false
    property string gearSensorKey: ""
    property string gearTextColor: ""
    property int gearFontSize: 0
    property real suffixFontSize: 0
    property real gearOffsetX: 0
    property real gearOffsetY: 0
    property real gearWidth: 0
    property real gearHeight: 0
    property real shiftPoint: 0
    property int shiftCount: 0
    property string shiftPattern: ""
    property string leftLabel: ""
    property string rightLabel: ""
    property bool biasShowSideValues: false
    property bool biasShowCenterValue: true
    property string biasValueUnit: ""
    property int biasValueDecimals: 1
    property real biasDampingMultiplier: 1.0
    property bool biasMarkerEnabled: true
    property string biasMarkerColor: "#00C8FF"
    property real biasMarkerWidth: 2.0
    property bool timeEnabled: false

    signal configChanged(string overlayId)

    function editorState() {
        return {
            sensorKey: sensorKey,
            labelText: labelText,
            unitText: unitText,
            staticText: staticText,
            minValue: minValue,
            maxValue: maxValue,
            decimals: decimals,
            overlaySize: overlaySize,
            startAngle: startAngle,
            endAngle: endAngle,
            arcWidth: arcWidth,
            arcScale: arcScale,
            arcOffsetX: arcOffsetX,
            arcOffsetY: arcOffsetY,
            minimumVisibleFraction: minimumVisibleFraction,
            startTaper: startTaper,
            endTaper: endTaper,
            testLoopEnabled: testLoopEnabled,
            testLoopDuration: testLoopDuration,
            arcColorStart: arcColorStart,
            arcColorMid: arcColorMid,
            arcColorMidPos: arcColorMidPos,
            arcColorEnd: arcColorEnd,
            valueOffsetY: valueOffsetY,
            readoutOffsetX: readoutOffsetX,
            readoutOffsetY: readoutOffsetY,
            readoutStep: readoutStep,
            readoutValueScale: readoutValueScale,
            readoutUnitScale: readoutUnitScale,
            unitOffsetX: unitOffsetX,
            unitOffsetY: unitOffsetY,
            readoutSpacing: readoutSpacing,
            readoutTextColor: readoutTextColor,
            warningEnabled: warningEnabled,
            warningThreshold: warningThreshold,
            warningColor: warningColor,
            warningFlash: warningFlash,
            warningFlashRate: warningFlashRate,
            warningDirection: warningDirection,
            normalColor: normalColor,
            threshold: threshold,
            onColor: onColor,
            offColor: offColor,
            invertLogic: invertLogic,
            gearSensorKey: gearSensorKey,
            gearTextColor: gearTextColor,
            gearFontSize: gearFontSize,
            suffixFontSize: suffixFontSize,
            gearOffsetX: gearOffsetX,
            gearOffsetY: gearOffsetY,
            gearWidth: gearWidth,
            gearHeight: gearHeight,
            shiftPoint: shiftPoint,
            shiftCount: shiftCount,
            shiftPattern: shiftPattern,
            leftLabel: leftLabel,
            rightLabel: rightLabel,
            biasShowSideValues: biasShowSideValues,
            biasShowCenterValue: biasShowCenterValue,
            biasValueUnit: biasValueUnit,
            biasValueDecimals: biasValueDecimals,
            biasDampingMultiplier: biasDampingMultiplier,
            biasMarkerEnabled: biasMarkerEnabled,
            biasMarkerColor: biasMarkerColor,
            biasMarkerWidth: biasMarkerWidth,
            timeEnabled: timeEnabled
        };
    }

    function getDefaults() {
        return OverlayDefaults.defaultsFor(overlayId);
    }

    function doReset() {
        AppSettings.removeOverlayConfig(dashboardId, overlayId);
        configChanged(overlayId);
        close();
    }

    function doSave() {
        var config = OverlayConfigService.buildOverlayConfig(configType, editorState());
        AppSettings.saveOverlayConfig(dashboardId, overlayId, config);
        configChanged(overlayId);
        close();
    }

    function num(val, def) {
        return val !== undefined ? Number(val) : def;
    }

    function openFor(id, type) {
        overlayId = id;
        configType = type;
        currentConfig = OverlayConfigService.prepareOverlayEditorConfig(dashboardId, id, type);
        populateFromConfig();
        open();
    }

    function populateFromConfig() {
        var cfg = currentConfig;
        var defs = getDefaults();

        sensorKey = OverlayConfigService.normalizeAnalogSensorKey(cfg.sensorKey || defs.sensorKey || "");

        labelText = cfg.label || defs.label || "";
        unitText = cfg.unit || defs.unit || "";
        staticText = cfg.text || defs.text || "";

        minValue = num(cfg.minValue, num(defs.minValue, 0));
        maxValue = num(cfg.maxValue, num(defs.maxValue, 100));
        decimals = num(cfg.decimals, num(defs.decimals, 0));

        var defSize = num(defs.overlaySize, 0);
        var rawOverlaySize = num(cfg.overlaySize, 0);
        overlaySize = rawOverlaySize > 0 ? rawOverlaySize : defSize;

        startAngle = num(cfg.startAngle, num(defs.startAngle, 225));
        endAngle = num(cfg.endAngle, num(defs.endAngle, 400));
        arcWidth = num(cfg.arcWidth, num(defs.arcWidth, 0.32));
        arcScale = num(cfg.arcScale, num(defs.arcScale, 1));
        arcOffsetX = num(cfg.arcOffsetX, num(defs.arcOffsetX, 0));
        arcOffsetY = num(cfg.arcOffsetY, num(defs.arcOffsetY, 0));
        minimumVisibleFraction = num(cfg.minimumVisibleFraction, num(defs.minimumVisibleFraction, 0));
        startTaper = num(cfg.startTaper, num(defs.startTaper, 0.18));
        endTaper = num(cfg.endTaper, num(defs.endTaper, 0.18));

        if (cfg.testLoopEnabled !== undefined)
            testLoopEnabled = toBool(cfg.testLoopEnabled, false);
        else
            testLoopEnabled = toBool(cfg.alignmentOverrideEnabled, toBool(defs.testLoopEnabled, false));

        testLoopDuration = num(cfg.testLoopDuration, num(defs.testLoopDuration, 1800));
        arcColorStart = cfg.arcColorStart || defs.arcColorStart || "#8F4D17";
        arcColorMid = cfg.arcColorMid || defs.arcColorMid || "";
        arcColorMidPos = num(cfg.arcColorMidPos, num(defs.arcColorMidPos, 0.65));
        arcColorEnd = cfg.arcColorEnd || defs.arcColorEnd || "#B00000";
        valueOffsetY = num(cfg.valueOffsetY, num(defs.valueOffsetY, 0));
        readoutOffsetX = num(cfg.readoutOffsetX, num(defs.readoutOffsetX, 0));
        readoutOffsetY = num(cfg.readoutOffsetY, cfg.valueOffsetY !== undefined ? num(cfg.valueOffsetY, 0) :
                                                                                  num(defs.readoutOffsetY, 0));
        readoutStep = num(cfg.readoutStep, num(defs.readoutStep, 1));
        readoutValueScale = num(cfg.readoutValueScale, num(defs.readoutValueScale, 0.213));
        readoutUnitScale = num(cfg.readoutUnitScale, num(defs.readoutUnitScale, 0.076));
        unitOffsetX = num(cfg.unitOffsetX, num(defs.unitOffsetX, 0));
        unitOffsetY = num(cfg.unitOffsetY, num(defs.unitOffsetY, 0));
        readoutSpacing = num(cfg.readoutSpacing, num(defs.readoutSpacing, 0));
        readoutTextColor = cfg.readoutTextColor || defs.readoutTextColor || "#FFFFFF";

        warningEnabled = toBool(cfg.warningEnabled, toBool(defs.warningEnabled, false));
        warningThreshold = num(cfg.warningThreshold, num(defs.warningThreshold, 0));
        warningColor = cfg.warningColor || defs.warningColor || "#FF0000";
        warningFlash = toBool(cfg.warningFlash, toBool(defs.warningFlash, true));
        warningFlashRate = num(cfg.warningFlashRate, num(defs.warningFlashRate, 200));
        warningDirection = cfg.warningDirection || defs.warningDirection || "above";
        normalColor = cfg.normalColor || defs.normalColor || "#FFFFFF";

        threshold = num(cfg.threshold, num(defs.threshold, 0.5));
        onColor = cfg.onColor || defs.onColor || "#1ED033";
        offColor = cfg.offColor || defs.offColor || "#FF0909";
        invertLogic = toBool(cfg.invertLogic, toBool(defs.invertLogic, false));

        gearSensorKey = OverlayConfigService.normalizeAnalogSensorKey(cfg.gearKey || defs.gearKey || "Gear");
        gearTextColor = cfg.gearTextColor || defs.gearTextColor || "#FFFFFF";
        gearFontSize = num(cfg.gearFontSize, num(defs.gearFontSize, 160));
        suffixFontSize = num(cfg.suffixFontSize, num(defs.suffixFontSize, 52.505));
        gearOffsetX = num(cfg.gearOffsetX, num(defs.gearOffsetX, 0));
        gearOffsetY = num(cfg.gearOffsetY, num(defs.gearOffsetY, 0));
        gearWidth = num(cfg.gearWidth, num(defs.gearWidth, 168));
        gearHeight = num(cfg.gearHeight, num(defs.gearHeight, 117));

        shiftPoint = num(cfg.shiftPoint, num(defs.shiftPoint, 0.3));
        shiftCount = num(cfg.shiftCount, num(defs.shiftCount, 11));
        shiftPattern = cfg.shiftPattern || defs.shiftPattern || "center-out";

        leftLabel = cfg.leftLabel || defs.leftLabel || "RWD";
        rightLabel = cfg.rightLabel || defs.rightLabel || "FWD";
        biasShowSideValues = toBool(cfg.showSideValues, toBool(defs.showSideValues, false));
        biasShowCenterValue = toBool(cfg.showCenterValue, toBool(defs.showCenterValue, true));
        biasValueUnit = cfg.valueUnit || defs.valueUnit || "";
        biasValueDecimals = num(cfg.valueDecimals, num(defs.valueDecimals, 1));
        biasDampingMultiplier = num(cfg.dampingMultiplier, num(defs.dampingMultiplier, 1.0));
        biasMarkerEnabled = toBool(cfg.markerEnabled, toBool(defs.markerEnabled, true));
        biasMarkerColor = cfg.markerColor || defs.markerColor || "#00C8FF";
        biasMarkerWidth = num(cfg.markerWidth, num(defs.markerWidth, 2.0));

        timeEnabled = toBool(cfg.timeEnabled, toBool(defs.timeEnabled, true));
    }

    function toBool(val, def) {
        return val !== undefined ? (val === true || val === "true") : def;
    }

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    height: Math.min(contentCol.implicitHeight + 40, parent ? parent.height - 40 : 680)
    modal: true
    padding: 0

    width: 500
    x: (parent ? (parent.width - width) / 2 : 0)
    y: (parent ? (parent.height - height) / 2 : 0)

    Overlay.modal: Rectangle {
        color: "#80000000"
    }
    background: Rectangle {
        border.color: SettingsTheme.border
        border.width: 2
        color: SettingsTheme.surfaceElevated
        radius: SettingsTheme.radiusLarge
    }

    ColumnLayout {
        id: contentCol

        anchors.fill: parent
        anchors.margins: 16
        spacing: 0

        RowLayout {
            Layout.bottomMargin: 10
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontLabel
                font.weight: Font.DemiBold
                text: "Configure: " + popup.overlayId
            }

            Rectangle {
                color: SettingsTheme.surfacePressed
                height: 32
                radius: 16
                width: 32

                Text {
                    anchors.centerIn: parent
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.Bold
                    text: "X"
                }

                TapHandler {
                    onTapped: popup.close()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            color: SettingsTheme.border
            height: 1
        }

        ScrollView {
            id: scrollArea

            Layout.bottomMargin: 10
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.topMargin: 10
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            clip: true
            contentWidth: availableWidth

            ColumnLayout {
                spacing: 10
                width: scrollArea.contentWidth

                OverlayDataSection { config: popup }
                OverlayArcSection { config: popup }
                OverlayAlertSection { config: popup }
                OverlayGearShiftSection { config: popup }
                OverlayBiasTextSection { config: popup }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            color: SettingsTheme.border
            height: 1
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 10
            spacing: 10

            StyledButton {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight
                primary: true
                text: "Save"

                onClicked: popup.doSave()
            }

            StyledButton {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight
                danger: true
                text: "Reset"

                onClicked: popup.doReset()
            }

            StyledButton {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight
                text: "Cancel"

                onClicked: popup.close()
            }
        }
    }
}
