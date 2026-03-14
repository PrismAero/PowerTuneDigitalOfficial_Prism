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

    // Config type classification
    readonly property bool isArc: configType === "tachCluster" || configType === "speedCluster"
    readonly property bool isBottomBar: configType === "bottombar"
    readonly property bool isBrakeBias: configType === "brakebias"
    readonly property bool isCluster: configType === "tachCluster" || configType === "speedCluster"
    readonly property bool isGear: configType === "gear"
    readonly property bool isSensor: configType === "sensorCard"
    readonly property bool isShift: configType === "shift"
    readonly property bool isStatus: configType === "statusRow"
    readonly property bool isTachCluster: configType === "tachCluster"

    // Section visibility flags
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

    // Editable config fields -- all populated by populateFromConfig() from OverlayDefaults
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
    property bool timeEnabled: false

    signal configChanged(string overlayId)

    function collectConfig() {
        var config = {};

        if (hasDatasource)
            config.sensorKey = sensorKey;

        if (hasLabel)
            config.label = labelText;

        if (hasUnitDecimals) {
            config.unit = unitText;
            config.decimals = decimals;
        }

        if (hasValueRange) {
            config.minValue = minValue;
            config.maxValue = maxValue;
        }

        if (hasArcGeometry) {
            config.startAngle = startAngle;
            config.endAngle = endAngle;
            config.arcWidth = arcWidth;
            config.arcScale = arcScale;
            config.arcOffsetX = arcOffsetX;
            config.arcOffsetY = arcOffsetY;
            config.minimumVisibleFraction = minimumVisibleFraction;
            config.startTaper = startTaper;
            config.endTaper = endTaper;
            config.testLoopEnabled = testLoopEnabled;
            config.testLoopDuration = testLoopDuration;
            config.valueOffsetY = valueOffsetY;
            config.readoutOffsetX = readoutOffsetX;
            config.readoutOffsetY = readoutOffsetY;
            config.readoutStep = readoutStep;
            config.readoutValueScale = readoutValueScale;
            config.readoutUnitScale = readoutUnitScale;
            config.unitOffsetX = unitOffsetX;
            config.unitOffsetY = unitOffsetY;
            config.readoutSpacing = readoutSpacing;
            config.readoutTextColor = readoutTextColor;
        }

        if (hasArcOverlaySize)
            config.overlaySize = overlaySize;

        if (hasArcColors) {
            config.arcColorStart = arcColorStart;
            config.arcColorMid = arcColorMid;
            config.arcColorMidPos = arcColorMidPos;
            config.arcColorEnd = arcColorEnd;
        }

        if (hasWarning) {
            config.warningEnabled = warningEnabled;
            config.warningThreshold = warningThreshold;
            config.warningFlash = warningFlash;
            config.warningFlashRate = warningFlashRate;
            if (isArc)
                config.warningColor = warningColor;
            if (isSensor) {
                config.warningColor = warningColor;
                config.warningDirection = warningDirection;
                config.normalColor = normalColor;
            }
        }

        if (hasStatusConfig) {
            config.threshold = threshold;
            config.onColor = onColor;
            config.offColor = offColor;
            config.invertLogic = invertLogic;
        }

        if (hasGearConfig) {
            config.gearKey = gearSensorKey;
            config.gearTextColor = gearTextColor;
            config.gearFontSize = gearFontSize;
            config.suffixFontSize = suffixFontSize;
            config.gearOffsetX = gearOffsetX;
            config.gearOffsetY = gearOffsetY;
            config.gearWidth = gearWidth;
            config.gearHeight = gearHeight;
        }

        if (hasShiftConfig) {
            config.shiftPoint = shiftPoint;
            config.shiftCount = shiftCount;
            config.shiftPattern = shiftPattern;
        }

        if (hasBiasLabels) {
            config.leftLabel = leftLabel;
            config.rightLabel = rightLabel;
        }

        if (hasStaticText) {
            config.text = staticText;
            config.timeEnabled = timeEnabled;
        }

        return config;
    }

    function configHasKeys(obj) {
        for (var key in obj)
            return true;
        return false;
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
        var config = collectConfig();
        AppSettings.saveOverlayConfig(dashboardId, overlayId, config);
        configChanged(overlayId);
        close();
    }

    function num(val, def) {
        return val !== undefined ? Number(val) : def;
    }

    // -- Public API --
    function openFor(id, type) {
        overlayId = id;
        configType = type;
        currentConfig = AppSettings.loadOverlayConfig(dashboardId, id);
        if (!configHasKeys(currentConfig) && type === "tachCluster") {
            currentConfig = AppSettings.loadOverlayConfig(dashboardId, "tachGroup");
            var legacyGear = AppSettings.loadOverlayConfig(dashboardId, "gearIndicator");
            for (var gearKey in legacyGear)
                currentConfig[gearKey] = legacyGear[gearKey];
        } else if (!configHasKeys(currentConfig) && type === "speedCluster") {
            currentConfig = AppSettings.loadOverlayConfig(dashboardId, "speedGroup");
        }
        populateFromConfig();
        open();
    }

    function populateFromConfig() {
        var cfg = currentConfig;
        var defs = getDefaults();

        sensorKey = cfg.sensorKey || defs.sensorKey || "";

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

        gearSensorKey = cfg.gearKey || defs.gearKey || "Gear";
        gearTextColor = cfg.gearTextColor || defs.gearTextColor || "#FFFFFF";
        gearFontSize = num(cfg.gearFontSize, num(defs.gearFontSize, 140));
        suffixFontSize = num(cfg.suffixFontSize, num(defs.suffixFontSize, 52.505));
        gearOffsetX = num(cfg.gearOffsetX, num(defs.gearOffsetX, 0));
        gearOffsetY = num(cfg.gearOffsetY, num(defs.gearOffsetY, 0));
        gearWidth = num(cfg.gearWidth, num(defs.gearWidth, 168));
        gearHeight = num(cfg.gearHeight, num(defs.gearHeight, 117));

        shiftPoint = num(cfg.shiftPoint, num(defs.shiftPoint, 0.75));
        shiftCount = num(cfg.shiftCount, num(defs.shiftCount, 11));
        shiftPattern = cfg.shiftPattern || defs.shiftPattern || "center-out";

        leftLabel = cfg.leftLabel || defs.leftLabel || "RWD";
        rightLabel = cfg.rightLabel || defs.rightLabel || "FWD";

        timeEnabled = toBool(cfg.timeEnabled, toBool(defs.timeEnabled, true));
    }

    function toBool(val, def) {
        return val !== undefined ? (val === true || val === "true") : def;
    }

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    height: Math.min(contentCol.implicitHeight + 40, parent ? parent.height - 40 : 680)
    modal: true
    padding: 0

    // -- Popup layout --
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

    // -- UI Layout --
    ColumnLayout {
        id: contentCol

        anchors.fill: parent
        anchors.margins: 16
        spacing: 0

        // -- Fixed Header --
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

        // -- Scrollable Content --
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

                // ============================================================
                // DATA SOURCE SECTION
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Data Source"
                    visible: popup.hasDatasource

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: "Parameter"
                        }

                        SensorPicker {
                            id: datasourcePicker

                            Layout.fillWidth: true
                            selectedKey: popup.sensorKey

                            onSensorSelected: function (key, displayName, unit) {
                                popup.sensorKey = key;
                            }
                        }
                    }
                }

                // ============================================================
                // LABEL SECTION
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Label"
                    visible: popup.hasLabel

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: "Display Label"
                        }

                        StyledTextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            text: popup.labelText

                            onTextEdited: popup.labelText = text
                        }
                    }
                }

                // ============================================================
                // UNIT + DECIMALS SECTION
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Unit + Decimals"
                    visible: popup.hasUnitDecimals

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: "Unit"
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                text: popup.unitText

                                onTextEdited: popup.unitText = text
                            }
                        }

                        ColumnLayout {
                            Layout.preferredWidth: 140
                            spacing: 4

                            Text {
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: "Decimal Places"
                            }

                            StyledSpinBox {
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                Layout.preferredWidth: 140
                                from: 0
                                to: 4
                                value: popup.decimals

                                onValueChanged: popup.decimals = value
                            }
                        }
                    }
                }

                // ============================================================
                // VALUE RANGE SECTION
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Value Range"
                    visible: popup.hasValueRange

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: "Min Value"
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                text: popup.minValue.toString()

                                onTextEdited: {
                                    var v = parseFloat(text);
                                    if (!isNaN(v))
                                        popup.minValue = v;
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: "Max Value"
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                text: popup.maxValue.toString()

                                onTextEdited: {
                                    var v = parseFloat(text);
                                    if (!isNaN(v))
                                        popup.maxValue = v;
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // ARC GEOMETRY SECTION
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Arc Geometry"
                    visible: popup.hasArcGeometry

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            Layout.fillWidth: true
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: "Angles use clock-style degrees: 0 at top, 90 at right, 180 at bottom, 270 at left."
                            wrapMode: Text.WordWrap
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Start Angle"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.startAngle.toFixed(1)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v))
                                            popup.startAngle = v;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "End Angle"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.endAngle.toFixed(1)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v))
                                            popup.endAngle = v;
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Arc Width"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.arcWidth.toFixed(3)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v) && v >= 0.01 && v <= 0.95)
                                            popup.arcWidth = v;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Arc Scale"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.arcScale.toFixed(3)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v) && v >= 0.1 && v <= 2.0)
                                            popup.arcScale = v;
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Arc Offset X"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.arcOffsetX.toFixed(1)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v))
                                            popup.arcOffsetX = v;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Arc Offset Y"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.arcOffsetY.toFixed(1)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v))
                                            popup.arcOffsetY = v;
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Start Seed"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.minimumVisibleFraction.toFixed(3)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v) && v >= 0 && v <= 0.5)
                                            popup.minimumVisibleFraction = v;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Value Offset Y"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.valueOffsetY.toFixed(1)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v))
                                            popup.valueOffsetY = v;
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Start Taper"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.startTaper.toFixed(3)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v) && v >= 0 && v <= 0.49)
                                            popup.startTaper = v;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "End Taper"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.endTaper.toFixed(3)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v) && v >= 0 && v <= 0.49)
                                            popup.endTaper = v;
                                    }
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // ARC COLORS SECTION
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Arc Colors"
                    visible: popup.hasArcColors

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Start Color"
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.arcColorStart

                                    onColorEdited: function (c) {
                                        popup.arcColorStart = c;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Mid Color"
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.arcColorMid

                                    onColorEdited: function (c) {
                                        popup.arcColorMid = c;
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "End Color"
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.arcColorEnd

                                    onColorEdited: function (c) {
                                        popup.arcColorEnd = c;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Mid Stop"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.arcColorMidPos.toFixed(2)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v) && v >= 0 && v <= 1)
                                            popup.arcColorMidPos = v;
                                    }
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // ARC SIZE SECTION
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Arc Size"
                    visible: popup.hasArcOverlaySize

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: "Overlay Size (square)"
                        }

                        StyledTextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: popup.overlaySize.toFixed(3)

                            onTextEdited: {
                                var v = parseFloat(text);
                                if (!isNaN(v) && v >= 150 && v <= 900)
                                    popup.overlaySize = v;
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: "Keeps width and height locked together so the arc stays circular."
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                // ============================================================
                // READOUT SECTION
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Readout"
                    visible: popup.hasReadoutConfig

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Readout Step"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.readoutStep.toString()

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v) && v > 0)
                                            popup.readoutStep = v;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Readout Color"
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.readoutTextColor

                                    onColorEdited: function (c) {
                                        popup.readoutTextColor = c;
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Offset X"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.readoutOffsetX.toFixed(1)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v))
                                            popup.readoutOffsetX = v;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Offset Y"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.readoutOffsetY.toFixed(1)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v))
                                            popup.readoutOffsetY = v;
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Value Scale"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.readoutValueScale.toFixed(3)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v) && v > 0)
                                            popup.readoutValueScale = v;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Unit Scale"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.readoutUnitScale.toFixed(3)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v) && v > 0)
                                            popup.readoutUnitScale = v;
                                    }
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // LOOP TEST SECTION
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Loop Test"
                    visible: popup.hasArcAlignment

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        StyledSwitch {
                            checked: popup.testLoopEnabled
                            text: "Enable Arc Loop Test"

                            onToggled: popup.testLoopEnabled = checked
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            visible: popup.testLoopEnabled

                            Text {
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: "Loop Duration (ms)"
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                text: popup.testLoopDuration.toString()

                                onTextEdited: {
                                    var v = parseInt(text);
                                    if (!isNaN(v) && v >= 100)
                                        popup.testLoopDuration = v;
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: "Runs the arc from zero to full range and back in place of live sensor input while enabled."
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                // ============================================================
                // WARNING SECTION
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Warning"
                    visible: popup.hasWarning

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        StyledSwitch {
                            id: warningSwitch

                            checked: popup.warningEnabled
                            text: "Enable Warning"

                            onToggled: popup.warningEnabled = checked
                        }

                        // Warning details (visible when enabled)
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            visible: popup.warningEnabled

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        color: SettingsTheme.textSecondary
                                        font.family: SettingsTheme.fontFamily
                                        font.pixelSize: SettingsTheme.fontCaption
                                        text: "Threshold"
                                    }

                                    StyledTextField {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: SettingsTheme.controlHeight
                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                        text: popup.warningThreshold.toString()

                                        onTextEdited: {
                                            var v = parseFloat(text);
                                            if (!isNaN(v))
                                                popup.warningThreshold = v;
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    visible: popup.isSensor

                                    Text {
                                        color: SettingsTheme.textSecondary
                                        font.family: SettingsTheme.fontFamily
                                        font.pixelSize: SettingsTheme.fontCaption
                                        text: "Warning Color"
                                    }

                                    StyledColorPicker {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: SettingsTheme.controlHeight
                                        colorValue: popup.warningColor

                                        onColorEdited: function (c) {
                                            popup.warningColor = c;
                                        }
                                    }
                                }
                            }

                            // Direction (sensor cards only)
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                visible: popup.isSensor

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Warning Direction"
                                }

                                StyledComboBox {
                                    id: directionCombo

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    currentIndex: popup.warningDirection === "below" ? 1 : 0
                                    model: ["above", "below"]

                                    onActivated: function (idx) {
                                        popup.warningDirection = idx === 1 ? "below" : "above";
                                    }
                                }
                            }

                            // Normal color (sensor cards only)
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                visible: popup.isSensor

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Normal Color"
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.normalColor

                                    onColorEdited: function (c) {
                                        popup.normalColor = c;
                                    }
                                }
                            }

                            // Flash settings (arc gauges only)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                visible: popup.isArc

                                StyledSwitch {
                                    checked: popup.warningFlash
                                    text: "Flash"

                                    onToggled: popup.warningFlash = checked
                                }

                                ColumnLayout {
                                    Layout.preferredWidth: 140
                                    spacing: 4
                                    visible: popup.warningFlash

                                    Text {
                                        color: SettingsTheme.textSecondary
                                        font.family: SettingsTheme.fontFamily
                                        font.pixelSize: SettingsTheme.fontCaption
                                        text: "Flash Rate (ms)"
                                    }

                                    StyledSpinBox {
                                        Layout.preferredHeight: SettingsTheme.controlHeight
                                        Layout.preferredWidth: 140
                                        from: 50
                                        stepSize: 50
                                        to: 1000
                                        value: popup.warningFlashRate

                                        onValueChanged: popup.warningFlashRate = value
                                    }
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // STATUS CONFIG SECTION (statusRow)
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Status Configuration"
                    visible: popup.hasStatusConfig

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: "ON/OFF Threshold (trip point)"
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                text: popup.threshold.toString()

                                onTextEdited: {
                                    var v = parseFloat(text);
                                    if (!isNaN(v))
                                        popup.threshold = v;
                                }
                            }
                        }

                        StyledSwitch {
                            checked: popup.invertLogic
                            text: "Invert Logic"

                            onToggled: popup.invertLogic = checked
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "ON Color"
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.onColor

                                    onColorEdited: function (c) {
                                        popup.onColor = c;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "OFF Color"
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.offColor

                                    onColorEdited: function (c) {
                                        popup.offColor = c;
                                    }
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // GEAR BINDING SECTION (tachGroup)
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Gear Indicator"
                    visible: popup.hasGearConfig

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: "Gear Parameter"
                            }

                            SensorPicker {
                                id: gearDatasourcePicker

                                Layout.fillWidth: true
                                selectedKey: popup.gearSensorKey

                                onSensorSelected: function (key, displayName, unit) {
                                    popup.gearSensorKey = key;
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Text Color"
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.gearTextColor

                                    onColorEdited: function (c) {
                                        popup.gearTextColor = c;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.preferredWidth: 140
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Font Size"
                                }

                                StyledSpinBox {
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    Layout.preferredWidth: 140
                                    from: 20
                                    stepSize: 10
                                    to: 300
                                    value: popup.gearFontSize

                                    onValueChanged: popup.gearFontSize = value
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Suffix Size"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.suffixFontSize.toFixed(1)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v) && v > 0)
                                            popup.suffixFontSize = v;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Offset X"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.gearOffsetX.toFixed(1)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v))
                                            popup.gearOffsetX = v;
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Offset Y"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.gearOffsetY.toFixed(1)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v))
                                            popup.gearOffsetY = v;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Width"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.gearWidth.toFixed(1)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v) && v > 0)
                                            popup.gearWidth = v;
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: "Height"
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                text: popup.gearHeight.toFixed(1)

                                onTextEdited: {
                                    var v = parseFloat(text);
                                    if (!isNaN(v) && v > 0)
                                        popup.gearHeight = v;
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // SHIFT LIGHTS SECTION (tachGroup)
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Shift Lights"
                    visible: popup.hasShiftConfig

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Shift Point (0 - 1)"
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    text: popup.shiftPoint.toFixed(3)

                                    onTextEdited: {
                                        var v = parseFloat(text);
                                        if (!isNaN(v))
                                            popup.shiftPoint = v;
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.preferredWidth: 140
                                spacing: 4

                                Text {
                                    color: SettingsTheme.textSecondary
                                    font.family: SettingsTheme.fontFamily
                                    font.pixelSize: SettingsTheme.fontCaption
                                    text: "Light Count"
                                }

                                StyledSpinBox {
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    Layout.preferredWidth: 140
                                    from: 1
                                    to: 15
                                    value: popup.shiftCount

                                    onValueChanged: popup.shiftCount = value
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: "Light Pattern"
                            }

                            StyledComboBox {
                                id: patternCombo

                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                currentIndex: {
                                    var items = ["center-out", "left-to-right", "right-to-left", "alternating"];
                                    var idx = items.indexOf(popup.shiftPattern);
                                    return idx >= 0 ? idx : 0;
                                }
                                model: ["center-out", "left-to-right", "right-to-left", "alternating"]

                                onActivated: function (idx) {
                                    var items = ["center-out", "left-to-right", "right-to-left", "alternating"];
                                    if (idx >= 0 && idx < items.length)
                                        popup.shiftPattern = items[idx];
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // BRAKE BIAS LABELS SECTION
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Bias Labels"
                    visible: popup.hasBiasLabels

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: "Left Label"
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                text: popup.leftLabel

                                onTextEdited: popup.leftLabel = text
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                color: SettingsTheme.textSecondary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: "Right Label"
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                text: popup.rightLabel

                                onTextEdited: popup.rightLabel = text
                            }
                        }
                    }
                }

                // ============================================================
                // STATIC TEXT SECTION (bottom bar)
                // ============================================================
                SettingsSection {
                    Layout.fillWidth: true
                    title: "Display Text"
                    visible: popup.hasStaticText

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: "Text"
                        }

                        StyledTextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            text: popup.staticText

                            onTextEdited: popup.staticText = text
                        }

                        StyledSwitch {
                            checked: popup.timeEnabled
                            text: "Show Time"

                            onToggled: popup.timeEnabled = checked
                        }
                    }
                }
            }
        }

        // -- Fixed Footer --
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
