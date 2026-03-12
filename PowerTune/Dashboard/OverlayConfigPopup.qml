import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

Popup {
    id: popup

    // -- Public interface --
    property string overlayId: ""
    property string configType: ""
    property string dashboardId: "racedash"
    property var currentConfig: ({})

    signal configChanged(string overlayId)

    // -- Editable config fields --
    // Datasource
    property string sensorKey: ""

    // Labels
    property string labelText: ""
    property string unitText: ""
    property string staticText: ""

    // Value range
    property real minValue: 0
    property real maxValue: 100
    property int decimals: 0

    // Race dash arc settings
    property real overlaySize: 0
    property real startAngle: 225
    property real endAngle: 56
    property real arcWidth: 0.285
    property real arcScale: 0.945
    property real arcOffsetX: 5
    property real arcOffsetY: 0
    property real minimumVisibleFraction: 0.08
    property real startTaper: 0.18
    property real endTaper: 0.18
    property bool testLoopEnabled: false
    property int testLoopDuration: 1800
    property string arcColorStart: "#8F4D17"
    property string arcColorMid: "#FF8A00"
    property real arcColorMidPos: 0.65
    property string arcColorEnd: "#B00000"
    property real valueOffsetY: 0
    property real readoutOffsetX: 0
    property real readoutOffsetY: 0
    property real readoutStep: 1
    property real readoutValueScale: 0.213
    property real readoutUnitScale: 0.076
    property real unitOffsetX: 0
    property real unitOffsetY: 0
    property real readoutSpacing: 0
    property string readoutTextColor: "#FFFFFF"

    // Warning
    property bool warningEnabled: false
    property real warningThreshold: 0
    property string warningColor: "#FF0000"
    property bool warningFlash: true
    property int warningFlashRate: 200
    property string warningDirection: "above"
    property string normalColor: "#FFFFFF"

    // Status
    property real threshold: 0.5
    property string onColor: "#1ED033"
    property string offColor: "#FF0909"
    property bool invertLogic: false

    // Gear
    property string gearSensorKey: "Gear"
    property string gearTextColor: "#FFFFFF"
    property int gearFontSize: 140
    property real suffixFontSize: 52.505
    property real gearOffsetX: 0
    property real gearOffsetY: 0
    property real gearWidth: 168
    property real gearHeight: 117

    // Shift
    property real shiftPoint: 0.75
    property int shiftCount: 11
    property string shiftPattern: "center-out"

    // Brake bias labels
    property string leftLabel: "RWD"
    property string rightLabel: "FWD"

    // Bottom bar
    property bool timeEnabled: true

    // -- Config type classification --
    readonly property bool isArc: configType === "tachCluster"
                                  || configType === "speedCluster"
    readonly property bool isGear: configType === "gear"
    readonly property bool isSensor: configType === "sensorCard"
    readonly property bool isStatus: configType === "statusRow"
    readonly property bool isBrakeBias: configType === "brakebias"
    readonly property bool isShift: configType === "shift"
    readonly property bool isBottomBar: configType === "bottombar"
    readonly property bool isCluster: configType === "tachCluster"
                                      || configType === "speedCluster"
    readonly property bool isTachCluster: configType === "tachCluster"
    // Section visibility flags
    readonly property bool hasDatasource: isArc || isGear || isSensor
                                          || isStatus || isBrakeBias
    readonly property bool hasLabel: isSensor || isStatus
    readonly property bool hasUnitDecimals: isArc || isSensor
    readonly property bool hasValueRange: isArc || isBrakeBias
    readonly property bool hasArcGeometry: isArc
    readonly property bool hasArcOverlaySize: configType === "tachCluster"
                                         || configType === "speedCluster"
    readonly property bool hasArcColors: isArc
    readonly property bool hasArcAlignment: isArc
    readonly property bool hasWarning: isArc || isSensor || isShift
    readonly property bool hasStatusConfig: isStatus
    readonly property bool hasGearConfig: isGear || isTachCluster
    readonly property bool hasShiftConfig: isShift
    readonly property bool hasBiasLabels: isBrakeBias
    readonly property bool hasStaticText: isBottomBar
    readonly property bool hasReadoutConfig: isCluster

    // -- Popup layout --
    width: 500
    height: Math.min(contentCol.implicitHeight + 40, parent ? parent.height - 40 : 680)
    x: (parent ? (parent.width - width) / 2 : 0)
    y: (parent ? (parent.height - height) / 2 : 0)
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    background: Rectangle {
        color: SettingsTheme.surfaceElevated
        border.color: SettingsTheme.border
        border.width: 2
        radius: SettingsTheme.radiusLarge
    }

    Overlay.modal: Rectangle {
        color: "#80000000"
    }

    // -- Public API --
    function openFor(id, type) {
        overlayId = id
        configType = type
        currentConfig = AppSettings.loadOverlayConfig(dashboardId, id)
        if (!configHasKeys(currentConfig) && type === "tachCluster") {
            currentConfig = AppSettings.loadOverlayConfig(dashboardId, "tachGroup")
            var legacyGear = AppSettings.loadOverlayConfig(dashboardId, "gearIndicator")
            for (var gearKey in legacyGear)
                currentConfig[gearKey] = legacyGear[gearKey]
        } else if (!configHasKeys(currentConfig) && type === "speedCluster") {
            currentConfig = AppSettings.loadOverlayConfig(dashboardId, "speedGroup")
        }
        populateFromConfig()
        open()
    }

    function configHasKeys(obj) {
        for (var key in obj)
            return true
        return false
    }

    function defaultOverlaySizeFor(type) {
        if (type === "tachCluster")
            return 575.051
        if (type === "speedCluster")
            return 503.17
        return 0
    }

    function defaultArcConfigFor(type) {
        if (type === "speedCluster") {
            return {
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
                readoutTextColor: "#FFFFFF",
                readoutStep: 1,
                readoutOffsetX: 0,
                readoutOffsetY: 62,
                readoutValueScale: 0.213,
                readoutUnitScale: 0.076,
                unitOffsetX: 14,
                unitOffsetY: -2,
                readoutSpacing: -1,
                valueOffsetY: 62
            }
        }

        return {
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
            readoutTextColor: "#FFFFFF",
            readoutStep: 1,
            readoutOffsetX: 0,
            readoutOffsetY: 94,
            readoutValueScale: 0.213,
            readoutUnitScale: 0.076,
            unitOffsetX: 34,
            unitOffsetY: -2,
            readoutSpacing: -2,
            gearOffsetX: 21.5,
            gearOffsetY: -76,
            gearWidth: 168,
            gearHeight: 117,
            suffixFontSize: 52.505,
            valueOffsetY: 94
        }
    }

    function num(val, def) { return val !== undefined ? Number(val) : def; }
    function toBool(val, def) { return val !== undefined ? (val === true || val === "true") : def; }

    function populateFromConfig() {
        var cfg = currentConfig
        var arcDefaults = defaultArcConfigFor(configType)

        // Datasource
        sensorKey = cfg.sensorKey || ""

        // Labels
        labelText = cfg.label || ""
        unitText = cfg.unit || ""
        staticText = cfg.text || ""

        // Value range
        minValue = num(cfg.minValue, 0)
        maxValue = num(cfg.maxValue, 100)
        decimals = num(cfg.decimals, 0)

        var rawOverlaySize = num(cfg.overlaySize, 0)
        if (configType === "tachCluster" || configType === "speedCluster") {
            overlaySize = rawOverlaySize > 0 ? rawOverlaySize : defaultOverlaySizeFor(configType)
        } else {
            overlaySize = rawOverlaySize > 0 ? rawOverlaySize : 0
        }

        startAngle = num(cfg.startAngle, arcDefaults.startAngle)
        endAngle = num(cfg.endAngle, arcDefaults.endAngle)
        arcWidth = num(cfg.arcWidth, arcDefaults.arcWidth)
        arcScale = num(cfg.arcScale, arcDefaults.arcScale)
        arcOffsetX = num(cfg.arcOffsetX, arcDefaults.arcOffsetX)
        arcOffsetY = num(cfg.arcOffsetY, arcDefaults.arcOffsetY)
        minimumVisibleFraction = num(cfg.minimumVisibleFraction, arcDefaults.minimumVisibleFraction)
        startTaper = num(cfg.startTaper, arcDefaults.startTaper)
        endTaper = num(cfg.endTaper, arcDefaults.endTaper)
        
        if (cfg.testLoopEnabled !== undefined)
            testLoopEnabled = toBool(cfg.testLoopEnabled, false)
        else
            testLoopEnabled = toBool(cfg.alignmentOverrideEnabled, false)
            
        testLoopDuration = num(cfg.testLoopDuration, arcDefaults.testLoopDuration)
        arcColorStart = cfg.arcColorStart || arcDefaults.arcColorStart
        arcColorMid = cfg.arcColorMid || arcDefaults.arcColorMid
        arcColorMidPos = num(cfg.arcColorMidPos, arcDefaults.arcColorMidPos)
        arcColorEnd = cfg.arcColorEnd || arcDefaults.arcColorEnd
        valueOffsetY = num(cfg.valueOffsetY, arcDefaults.valueOffsetY)
        readoutOffsetX = num(cfg.readoutOffsetX, arcDefaults.readoutOffsetX)
        readoutOffsetY = num(cfg.readoutOffsetY, cfg.valueOffsetY !== undefined ? num(cfg.valueOffsetY, 0) : arcDefaults.readoutOffsetY)
        readoutStep = num(cfg.readoutStep, arcDefaults.readoutStep)
        readoutValueScale = num(cfg.readoutValueScale, arcDefaults.readoutValueScale)
        readoutUnitScale = num(cfg.readoutUnitScale, arcDefaults.readoutUnitScale)
        unitOffsetX = num(cfg.unitOffsetX, arcDefaults.unitOffsetX)
        unitOffsetY = num(cfg.unitOffsetY, arcDefaults.unitOffsetY)
        readoutSpacing = num(cfg.readoutSpacing, arcDefaults.readoutSpacing)
        readoutTextColor = cfg.readoutTextColor || arcDefaults.readoutTextColor

        // Warning
        warningEnabled = toBool(cfg.warningEnabled, false)
        warningThreshold = num(cfg.warningThreshold, 0)
        warningColor = cfg.warningColor || "#FF0000"
        warningFlash = toBool(cfg.warningFlash, true)
        warningFlashRate = num(cfg.warningFlashRate, 200)
        warningDirection = cfg.warningDirection || "above"
        normalColor = cfg.normalColor || "#FFFFFF"

        // Status
        threshold = num(cfg.threshold, 0.5)
        onColor = cfg.onColor || "#1ED033"
        offColor = cfg.offColor || "#FF0909"
        invertLogic = toBool(cfg.invertLogic, false)

        // Gear
        gearSensorKey = cfg.gearKey || "Gear"
        gearTextColor = cfg.gearTextColor || "#FFFFFF"
        gearFontSize = num(cfg.gearFontSize, 140)
        suffixFontSize = num(cfg.suffixFontSize, arcDefaults.suffixFontSize !== undefined ? arcDefaults.suffixFontSize : 52.505)
        gearOffsetX = num(cfg.gearOffsetX, arcDefaults.gearOffsetX !== undefined ? arcDefaults.gearOffsetX : 0)
        gearOffsetY = num(cfg.gearOffsetY, arcDefaults.gearOffsetY !== undefined ? arcDefaults.gearOffsetY : 0)
        gearWidth = num(cfg.gearWidth, arcDefaults.gearWidth !== undefined ? arcDefaults.gearWidth : 168)
        gearHeight = num(cfg.gearHeight, arcDefaults.gearHeight !== undefined ? arcDefaults.gearHeight : 117)

        // Shift
        shiftPoint = num(cfg.shiftPoint, 0.75)
        shiftCount = num(cfg.shiftCount, 11)
        shiftPattern = cfg.shiftPattern || "center-out"

        // Brake bias labels
        leftLabel = cfg.leftLabel || "RWD"
        rightLabel = cfg.rightLabel || "FWD"

        // Bottom bar
        timeEnabled = toBool(cfg.timeEnabled, true)

        // Set datasource combo index
        updateDatasourceIndex()
        updateGearDatasourceIndex()
    }

    function updateDatasourceIndex() {
        if (!datasourceCombo) return
        var props = PropertyRouter.availableProperties()
        var idx = -1
        for (var i = 0; i < props.length; i++) {
            if (props[i] === popup.sensorKey) {
                idx = i
                break
            }
        }
        datasourceCombo.currentIndex = idx
    }

    function updateGearDatasourceIndex() {
        if (!gearDatasourceCombo) return
        var props = PropertyRouter.availableProperties()
        var idx = -1
        for (var i = 0; i < props.length; i++) {
            if (props[i] === popup.gearSensorKey) {
                idx = i
                break
            }
        }
        gearDatasourceCombo.currentIndex = idx
    }

    function collectConfig() {
        var config = {}

        if (hasDatasource)
            config.sensorKey = sensorKey

        if (hasLabel)
            config.label = labelText

        if (hasUnitDecimals) {
            config.unit = unitText
            config.decimals = decimals
        }

        if (hasValueRange) {
            config.minValue = minValue
            config.maxValue = maxValue
        }

        if (hasArcGeometry) {
            config.startAngle = startAngle
            config.endAngle = endAngle
            config.arcWidth = arcWidth
            config.arcScale = arcScale
            config.arcOffsetX = arcOffsetX
            config.arcOffsetY = arcOffsetY
            config.minimumVisibleFraction = minimumVisibleFraction
            config.startTaper = startTaper
            config.endTaper = endTaper
            config.testLoopEnabled = testLoopEnabled
            config.testLoopDuration = testLoopDuration
            config.valueOffsetY = valueOffsetY
            config.readoutOffsetX = readoutOffsetX
            config.readoutOffsetY = readoutOffsetY
            config.readoutStep = readoutStep
            config.readoutValueScale = readoutValueScale
            config.readoutUnitScale = readoutUnitScale
            config.unitOffsetX = unitOffsetX
            config.unitOffsetY = unitOffsetY
            config.readoutSpacing = readoutSpacing
            config.readoutTextColor = readoutTextColor
        }

        if (hasArcOverlaySize)
            config.overlaySize = overlaySize

        if (hasArcColors) {
            config.arcColorStart = arcColorStart
            config.arcColorMid = arcColorMid
            config.arcColorMidPos = arcColorMidPos
            config.arcColorEnd = arcColorEnd
        }

        if (hasWarning) {
            config.warningEnabled = warningEnabled
            config.warningThreshold = warningThreshold
            config.warningFlash = warningFlash
            config.warningFlashRate = warningFlashRate
            if (isArc)
                config.warningColor = warningColor
            if (isSensor) {
                config.warningColor = warningColor
                config.warningDirection = warningDirection
                config.normalColor = normalColor
            }
        }

        if (hasStatusConfig) {
            config.threshold = threshold
            config.onColor = onColor
            config.offColor = offColor
            config.invertLogic = invertLogic
        }

        if (hasGearConfig) {
            config.gearKey = gearSensorKey
            config.gearTextColor = gearTextColor
            config.gearFontSize = gearFontSize
            config.suffixFontSize = suffixFontSize
            config.gearOffsetX = gearOffsetX
            config.gearOffsetY = gearOffsetY
            config.gearWidth = gearWidth
            config.gearHeight = gearHeight
        }

        if (hasShiftConfig) {
            config.shiftPoint = shiftPoint
            config.shiftCount = shiftCount
            config.shiftPattern = shiftPattern
        }

        if (hasBiasLabels) {
            config.leftLabel = leftLabel
            config.rightLabel = rightLabel
        }

        if (hasStaticText) {
            config.text = staticText
            config.timeEnabled = timeEnabled
        }

        return config
    }

    function doSave() {
        var config = collectConfig()
        AppSettings.saveOverlayConfig(dashboardId, overlayId, config)
        configChanged(overlayId)
        close()
    }

    function doReset() {
        AppSettings.removeOverlayConfig(dashboardId, overlayId)
        configChanged(overlayId)
        close()
    }

    // -- UI Layout --
    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 16
        spacing: 0

        // -- Fixed Header --
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 10

            Text {
                text: "Configure: " + popup.overlayId
                font.pixelSize: SettingsTheme.fontLabel
                font.weight: Font.DemiBold
                font.family: SettingsTheme.fontFamily
                color: SettingsTheme.textPrimary
                Layout.fillWidth: true
            }

            Rectangle {
                width: 32; height: 32
                radius: 16
                color: SettingsTheme.surfacePressed

                Text {
                    text: "X"
                    color: SettingsTheme.textPrimary
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.Bold
                    font.family: SettingsTheme.fontFamily
                    anchors.centerIn: parent
                }

                TapHandler {
                    onTapped: popup.close()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: SettingsTheme.border
        }

        // -- Scrollable Content --
        ScrollView {
            id: scrollArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: scrollArea.availableWidth
                spacing: 10

                // ============================================================
                // DATA SOURCE SECTION
                // ============================================================
                SettingsSection {
                    title: "Data Source"
                    visible: popup.hasDatasource
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Parameter"
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
                        }

                        StyledComboBox {
                            id: datasourceCombo
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            model: PropertyRouter.availableProperties()
                            onActivated: function(idx) {
                                var props = PropertyRouter.availableProperties()
                                if (idx >= 0 && idx < props.length)
                                    popup.sensorKey = props[idx]
                            }
                        }
                    }
                }

                // ============================================================
                // LABEL SECTION
                // ============================================================
                SettingsSection {
                    title: "Label"
                    visible: popup.hasLabel
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Display Label"
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
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
                    title: "Unit + Decimals"
                    visible: popup.hasUnitDecimals
                    Layout.fillWidth: true

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Unit"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
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
                                text: "Decimal Places"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                            }

                            StyledSpinBox {
                                from: 0
                                to: 4
                                value: popup.decimals
                                onValueChanged: popup.decimals = value
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: SettingsTheme.controlHeight
                            }
                        }
                    }
                }

                // ============================================================
                // VALUE RANGE SECTION
                // ============================================================
                SettingsSection {
                    title: "Value Range"
                    visible: popup.hasValueRange
                    Layout.fillWidth: true

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Min Value"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                text: popup.minValue.toString()
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onTextEdited: {
                                    var v = parseFloat(text)
                                    if (!isNaN(v))
                                        popup.minValue = v
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Max Value"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                text: popup.maxValue.toString()
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onTextEdited: {
                                    var v = parseFloat(text)
                                    if (!isNaN(v))
                                        popup.maxValue = v
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // ARC GEOMETRY SECTION
                // ============================================================
                SettingsSection {
                    title: "Arc Geometry"
                    visible: popup.hasArcGeometry
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: "Angles use clock-style degrees: 0 at top, 90 at right, 180 at bottom, 270 at left."
                            wrapMode: Text.WordWrap
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "Start Angle"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.startAngle.toFixed(1)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v))
                                            popup.startAngle = v
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "End Angle"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.endAngle.toFixed(1)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v))
                                            popup.endAngle = v
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
                                    text: "Arc Width"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.arcWidth.toFixed(3)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v) && v >= 0.01 && v <= 0.95)
                                            popup.arcWidth = v
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "Arc Scale"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.arcScale.toFixed(3)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v) && v >= 0.1 && v <= 2.0)
                                            popup.arcScale = v
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
                                    text: "Arc Offset X"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.arcOffsetX.toFixed(1)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v))
                                            popup.arcOffsetX = v
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "Arc Offset Y"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.arcOffsetY.toFixed(1)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v))
                                            popup.arcOffsetY = v
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
                                    text: "Start Seed"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.minimumVisibleFraction.toFixed(3)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v) && v >= 0 && v <= 0.5)
                                            popup.minimumVisibleFraction = v
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "Value Offset Y"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.valueOffsetY.toFixed(1)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v))
                                            popup.valueOffsetY = v
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
                                    text: "Start Taper"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.startTaper.toFixed(3)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v) && v >= 0 && v <= 0.49)
                                            popup.startTaper = v
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "End Taper"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.endTaper.toFixed(3)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v) && v >= 0 && v <= 0.49)
                                            popup.endTaper = v
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
                    title: "Arc Colors"
                    visible: popup.hasArcColors
                    Layout.fillWidth: true

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
                                    text: "Start Color"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.arcColorStart
                                    onColorEdited: function(c) { popup.arcColorStart = c }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "Mid Color"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.arcColorMid
                                    onColorEdited: function(c) { popup.arcColorMid = c }
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
                                    text: "End Color"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.arcColorEnd
                                    onColorEdited: function(c) { popup.arcColorEnd = c }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "Mid Stop"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.arcColorMidPos.toFixed(2)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v) && v >= 0 && v <= 1)
                                            popup.arcColorMidPos = v
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
                    title: "Arc Size"
                    visible: popup.hasArcOverlaySize
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "Overlay Size (square)"
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
                        }

                        StyledTextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            text: popup.overlaySize.toFixed(3)
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            onTextEdited: {
                                var v = parseFloat(text)
                                if (!isNaN(v) && v >= 150 && v <= 900)
                                    popup.overlaySize = v
                            }
                        }

                        Text {
                            text: "Keeps width and height locked together so the arc stays circular."
                            wrapMode: Text.WordWrap
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
                            Layout.fillWidth: true
                        }
                    }
                }

                // ============================================================
                // READOUT SECTION
                // ============================================================
                SettingsSection {
                    title: "Readout"
                    visible: popup.hasReadoutConfig
                    Layout.fillWidth: true

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
                                    text: "Readout Step"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.readoutStep.toString()
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v) && v > 0)
                                            popup.readoutStep = v
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "Readout Color"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.readoutTextColor
                                    onColorEdited: function(c) { popup.readoutTextColor = c }
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
                                    text: "Offset X"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.readoutOffsetX.toFixed(1)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v))
                                            popup.readoutOffsetX = v
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "Offset Y"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.readoutOffsetY.toFixed(1)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v))
                                            popup.readoutOffsetY = v
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
                                    text: "Value Scale"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.readoutValueScale.toFixed(3)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v) && v > 0)
                                            popup.readoutValueScale = v
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "Unit Scale"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.readoutUnitScale.toFixed(3)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v) && v > 0)
                                            popup.readoutUnitScale = v
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
                    title: "Loop Test"
                    visible: popup.hasArcAlignment
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        StyledSwitch {
                            text: "Enable Arc Loop Test"
                            checked: popup.testLoopEnabled
                            onToggled: popup.testLoopEnabled = checked
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            visible: popup.testLoopEnabled

                            Text {
                                text: "Loop Duration (ms)"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                text: popup.testLoopDuration.toString()
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onTextEdited: {
                                    var v = parseInt(text)
                                    if (!isNaN(v) && v >= 100)
                                        popup.testLoopDuration = v
                                }
                            }

                            Text {
                                text: "Runs the arc from zero to full range and back in place of live sensor input while enabled."
                                wrapMode: Text.WordWrap
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // ============================================================
                // WARNING SECTION
                // ============================================================
                SettingsSection {
                    title: "Warning"
                    visible: popup.hasWarning
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        StyledSwitch {
                            id: warningSwitch
                            text: "Enable Warning"
                            checked: popup.warningEnabled
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
                                        text: "Threshold"
                                        font.pixelSize: SettingsTheme.fontCaption
                                        font.family: SettingsTheme.fontFamily
                                        color: SettingsTheme.textSecondary
                                    }

                                    StyledTextField {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: SettingsTheme.controlHeight
                                        text: popup.warningThreshold.toString()
                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                        onTextEdited: {
                                            var v = parseFloat(text)
                                            if (!isNaN(v))
                                                popup.warningThreshold = v
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    visible: popup.isSensor

                                    Text {
                                        text: "Warning Color"
                                        font.pixelSize: SettingsTheme.fontCaption
                                        font.family: SettingsTheme.fontFamily
                                        color: SettingsTheme.textSecondary
                                    }

                                    StyledColorPicker {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: SettingsTheme.controlHeight
                                        colorValue: popup.warningColor
                                        onColorEdited: function(c) { popup.warningColor = c }
                                    }
                                }
                            }

                            // Direction (sensor cards only)
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                visible: popup.isSensor

                                Text {
                                    text: "Warning Direction"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledComboBox {
                                    id: directionCombo
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    model: ["above", "below"]
                                    currentIndex: popup.warningDirection === "below" ? 1 : 0
                                    onActivated: function(idx) {
                                        popup.warningDirection = idx === 1 ? "below" : "above"
                                    }
                                }
                            }

                            // Normal color (sensor cards only)
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                visible: popup.isSensor

                                Text {
                                    text: "Normal Color"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.normalColor
                                    onColorEdited: function(c) { popup.normalColor = c }
                                }
                            }

                            // Flash settings (arc gauges only)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                visible: popup.isArc

                                StyledSwitch {
                                    text: "Flash"
                                    checked: popup.warningFlash
                                    onToggled: popup.warningFlash = checked
                                }

                                ColumnLayout {
                                    Layout.preferredWidth: 140
                                    spacing: 4
                                    visible: popup.warningFlash

                                    Text {
                                        text: "Flash Rate (ms)"
                                        font.pixelSize: SettingsTheme.fontCaption
                                        font.family: SettingsTheme.fontFamily
                                        color: SettingsTheme.textSecondary
                                    }

                                    StyledSpinBox {
                                        from: 50
                                        to: 1000
                                        stepSize: 50
                                        value: popup.warningFlashRate
                                        onValueChanged: popup.warningFlashRate = value
                                        Layout.preferredWidth: 140
                                        Layout.preferredHeight: SettingsTheme.controlHeight
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
                    title: "Status Configuration"
                    visible: popup.hasStatusConfig
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "ON/OFF Threshold (trip point)"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                text: popup.threshold.toString()
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onTextEdited: {
                                    var v = parseFloat(text)
                                    if (!isNaN(v))
                                        popup.threshold = v
                                }
                            }
                        }

                        StyledSwitch {
                            text: "Invert Logic"
                            checked: popup.invertLogic
                            onToggled: popup.invertLogic = checked
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "ON Color"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.onColor
                                    onColorEdited: function(c) { popup.onColor = c }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "OFF Color"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.offColor
                                    onColorEdited: function(c) { popup.offColor = c }
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // GEAR BINDING SECTION (tachGroup)
                // ============================================================
                SettingsSection {
                    title: "Gear Indicator"
                    visible: popup.hasGearConfig
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Gear Parameter"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                            }

                            StyledComboBox {
                                id: gearDatasourceCombo
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                model: PropertyRouter.availableProperties()
                                onActivated: function(idx) {
                                    var props = PropertyRouter.availableProperties()
                                    if (idx >= 0 && idx < props.length)
                                        popup.gearSensorKey = props[idx]
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
                                    text: "Text Color"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledColorPicker {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    colorValue: popup.gearTextColor
                                    onColorEdited: function(c) { popup.gearTextColor = c }
                                }
                            }

                            ColumnLayout {
                                Layout.preferredWidth: 140
                                spacing: 4

                                Text {
                                    text: "Font Size"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledSpinBox {
                                    from: 20
                                    to: 300
                                    stepSize: 10
                                    value: popup.gearFontSize
                                    onValueChanged: popup.gearFontSize = value
                                    Layout.preferredWidth: 140
                                    Layout.preferredHeight: SettingsTheme.controlHeight
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
                                    text: "Suffix Size"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.suffixFontSize.toFixed(1)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v) && v > 0)
                                            popup.suffixFontSize = v
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "Offset X"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.gearOffsetX.toFixed(1)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v))
                                            popup.gearOffsetX = v
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
                                    text: "Offset Y"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.gearOffsetY.toFixed(1)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v))
                                            popup.gearOffsetY = v
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "Width"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.gearWidth.toFixed(1)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v) && v > 0)
                                            popup.gearWidth = v
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Height"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                text: popup.gearHeight.toFixed(1)
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onTextEdited: {
                                    var v = parseFloat(text)
                                    if (!isNaN(v) && v > 0)
                                        popup.gearHeight = v
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // SHIFT LIGHTS SECTION (tachGroup)
                // ============================================================
                SettingsSection {
                    title: "Shift Lights"
                    visible: popup.hasShiftConfig
                    Layout.fillWidth: true

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
                                    text: "Shift Point (0 - 1)"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                    text: popup.shiftPoint.toFixed(3)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextEdited: {
                                        var v = parseFloat(text)
                                        if (!isNaN(v))
                                            popup.shiftPoint = v
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.preferredWidth: 140
                                spacing: 4

                                Text {
                                    text: "Light Count"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledSpinBox {
                                    from: 1
                                    to: 15
                                    value: popup.shiftCount
                                    onValueChanged: popup.shiftCount = value
                                    Layout.preferredWidth: 140
                                    Layout.preferredHeight: SettingsTheme.controlHeight
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Light Pattern"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                            }

                            StyledComboBox {
                                id: patternCombo
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                model: ["center-out", "left-to-right", "right-to-left", "alternating"]
                                currentIndex: {
                                    var items = ["center-out", "left-to-right", "right-to-left", "alternating"]
                                    var idx = items.indexOf(popup.shiftPattern)
                                    return idx >= 0 ? idx : 0
                                }
                                onActivated: function(idx) {
                                    var items = ["center-out", "left-to-right", "right-to-left", "alternating"]
                                    if (idx >= 0 && idx < items.length)
                                        popup.shiftPattern = items[idx]
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // BRAKE BIAS LABELS SECTION
                // ============================================================
                SettingsSection {
                    title: "Bias Labels"
                    visible: popup.hasBiasLabels
                    Layout.fillWidth: true

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Left Label"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
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
                                text: "Right Label"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
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
                    title: "Display Text"
                    visible: popup.hasStaticText
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Text"
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
                        }

                        StyledTextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            text: popup.staticText
                            onTextEdited: popup.staticText = text
                        }

                        StyledSwitch {
                            text: "Show Time"
                            checked: popup.timeEnabled
                            onToggled: popup.timeEnabled = checked
                        }
                    }
                }
            }
        }

        // -- Fixed Footer --
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: SettingsTheme.border
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 10
            spacing: 10

            StyledButton {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight
                text: "Save"
                primary: true
                onClicked: popup.doSave()
            }

            StyledButton {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight
                text: "Reset"
                danger: true
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
