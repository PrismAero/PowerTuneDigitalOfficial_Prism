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

    // Arc geometry
    property real startAngle: 135
    property real sweepAngle: 270
    property real arcWidth: 0.209
    property bool alignmentOverrideEnabled: false
    property real alignmentOverrideProgress: 1.0

    // Arc colors
    property string arcColorStart: "#E88A1A"
    property string arcColorEnd: "#C45A00"
    property string arcColorMid: ""
    property real arcColorMidPos: 0.5
    property string arcBgColor: "#151518"

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
    // Support both old (tachGroup, speedGroup, sensorCard, statusRow, staticText)
    // and new (arc, gear, sensor, status, brakebias, shift, bottombar) config types
    readonly property bool isArc: configType === "arc"
                                  || configType === "tachGroup"
                                  || configType === "speedGroup"
    readonly property bool isGear: configType === "gear"
                                   || configType === "tachGroup"
    readonly property bool isSensor: configType === "sensor"
                                     || configType === "sensorCard"
    readonly property bool isStatus: configType === "status"
                                     || configType === "statusRow"
    readonly property bool isBrakeBias: configType === "brakebias"
                                        || configType === "brakeBias"
    readonly property bool isShift: configType === "shift"
                                    || configType === "tachGroup"
    readonly property bool isBottomBar: configType === "bottombar"
                                        || configType === "staticText"

    // Section visibility flags
    readonly property bool hasDatasource: isArc || isGear || isSensor
                                          || isStatus || isBrakeBias
    readonly property bool hasLabel: isSensor || isStatus
    readonly property bool hasUnitDecimals: isArc || isSensor
    readonly property bool hasValueRange: isArc || isBrakeBias
    readonly property bool hasArcGeometry: isArc
    readonly property bool hasArcAlignment: isArc
    readonly property bool hasArcColors: isArc
    readonly property bool hasWarning: isArc || isSensor || isShift
    readonly property bool hasStatusConfig: isStatus
    readonly property bool hasGearConfig: isGear
    readonly property bool hasShiftConfig: isShift
    readonly property bool hasBiasLabels: isBrakeBias
    readonly property bool hasStaticText: isBottomBar

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
        populateFromConfig()
        open()
    }

    function populateFromConfig() {
        var cfg = currentConfig

        // Datasource
        sensorKey = cfg.sensorKey || ""

        // Labels
        labelText = cfg.label || ""
        unitText = cfg.unit || ""
        staticText = cfg.text || ""

        // Value range
        minValue = cfg.minValue !== undefined ? Number(cfg.minValue) : 0
        maxValue = cfg.maxValue !== undefined ? Number(cfg.maxValue) : 100
        decimals = cfg.decimals !== undefined ? Number(cfg.decimals) : 0

        // Arc geometry
        startAngle = cfg.startAngle !== undefined ? Number(cfg.startAngle) : 135
        sweepAngle = cfg.sweepAngle !== undefined ? Number(cfg.sweepAngle) : 270
        arcWidth = cfg.arcWidth !== undefined ? Number(cfg.arcWidth) : 0.209
        alignmentOverrideEnabled = cfg.alignmentOverrideEnabled === true || cfg.alignmentOverrideEnabled === "true"
        alignmentOverrideProgress = cfg.alignmentOverrideProgress !== undefined ? Number(cfg.alignmentOverrideProgress) : 1.0

        // Arc colors
        arcColorStart = cfg.arcColorStart || "#E88A1A"
        arcColorEnd = cfg.arcColorEnd || "#C45A00"
        arcColorMid = cfg.arcColorMid || ""
        arcColorMidPos = cfg.arcColorMidPos !== undefined ? Number(cfg.arcColorMidPos) : 0.5
        arcBgColor = cfg.arcBgColor || "#151518"

        // Warning
        warningEnabled = cfg.warningEnabled === true || cfg.warningEnabled === "true"
        warningThreshold = cfg.warningThreshold !== undefined ? Number(cfg.warningThreshold) : 0
        warningColor = cfg.warningColor || "#FF0000"
        warningFlash = cfg.warningFlash !== undefined ? (cfg.warningFlash === true || cfg.warningFlash === "true") : true
        warningFlashRate = cfg.warningFlashRate !== undefined ? Number(cfg.warningFlashRate) : 200
        warningDirection = cfg.warningDirection || "above"
        normalColor = cfg.normalColor || "#FFFFFF"

        // Status
        threshold = cfg.threshold !== undefined ? Number(cfg.threshold) : 0.5
        onColor = cfg.onColor || "#1ED033"
        offColor = cfg.offColor || "#FF0909"
        invertLogic = cfg.invertLogic === true || cfg.invertLogic === "true"

        // Gear
        gearSensorKey = cfg.gearKey || "Gear"
        gearTextColor = cfg.gearTextColor || "#FFFFFF"
        gearFontSize = cfg.gearFontSize !== undefined ? Number(cfg.gearFontSize) : 140

        // Shift
        shiftPoint = cfg.shiftPoint !== undefined ? Number(cfg.shiftPoint) : 0.75
        shiftCount = cfg.shiftCount !== undefined ? Number(cfg.shiftCount) : 11
        shiftPattern = cfg.shiftPattern || "center-out"

        // Brake bias labels
        leftLabel = cfg.leftLabel || "RWD"
        rightLabel = cfg.rightLabel || "FWD"

        // Bottom bar
        timeEnabled = cfg.timeEnabled !== undefined ? (cfg.timeEnabled === true || cfg.timeEnabled === "true") : true

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
            config.sweepAngle = sweepAngle
            config.arcWidth = arcWidth
            config.alignmentOverrideEnabled = alignmentOverrideEnabled
            config.alignmentOverrideProgress = alignmentOverrideProgress
        }

        if (hasArcColors) {
            config.arcColorStart = arcColorStart
            config.arcColorEnd = arcColorEnd
            config.arcColorMid = arcColorMid
            config.arcColorMidPos = arcColorMidPos
            config.arcBgColor = arcBgColor
        }

        if (hasWarning) {
            config.warningEnabled = warningEnabled
            config.warningThreshold = warningThreshold
            config.warningColor = warningColor
            config.warningFlash = warningFlash
            config.warningFlashRate = warningFlashRate
            if (isSensor) {
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

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Start Angle (deg)"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                text: popup.startAngle.toString()
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
                                text: "Sweep Angle (deg)"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                text: popup.sweepAngle.toString()
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onTextEdited: {
                                    var v = parseFloat(text)
                                    if (!isNaN(v))
                                        popup.sweepAngle = v
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Arc Width (0.01 - 0.5)"
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
                                if (!isNaN(v) && v >= 0.01 && v <= 0.5)
                                    popup.arcWidth = v
                            }
                        }
                    }
                }

                // ============================================================
                // ARC ALIGNMENT SECTION
                // ============================================================
                SettingsSection {
                    title: "Arc Alignment"
                    visible: popup.hasArcAlignment
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        StyledSwitch {
                            text: "Lock To Alignment Progress"
                            checked: popup.alignmentOverrideEnabled
                            onToggled: popup.alignmentOverrideEnabled = checked
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            visible: popup.alignmentOverrideEnabled

                            Text {
                                text: "Progress (0.00 - 1.00)"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                            }

                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                text: popup.alignmentOverrideProgress.toFixed(2)
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onTextEdited: {
                                    var v = parseFloat(text)
                                    if (!isNaN(v) && v >= 0 && v <= 1)
                                        popup.alignmentOverrideProgress = v
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // ARC COLORS SECTION
                // ============================================================
                SettingsSection {
                    title: "Colors + Gradient"
                    visible: popup.hasArcColors
                    Layout.fillWidth: true

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
                    }

                    // Mid color toggle + picker
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        StyledSwitch {
                            id: midColorSwitch
                            text: "Use Mid Color"
                            checked: popup.arcColorMid !== ""
                            onToggled: {
                                if (!checked)
                                    popup.arcColorMid = ""
                                else if (popup.arcColorMid === "")
                                    popup.arcColorMid = "#FFFF00"
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            visible: midColorSwitch.checked

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

                            ColumnLayout {
                                Layout.preferredWidth: 140
                                spacing: 4

                                Text {
                                    text: "Mid Position"
                                    font.pixelSize: SettingsTheme.fontCaption
                                    font.family: SettingsTheme.fontFamily
                                    color: SettingsTheme.textSecondary
                                }

                                StyledTextField {
                                    Layout.preferredWidth: 140
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

                    // Background color
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Background Color"
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
                        }

                        StyledColorPicker {
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            colorValue: popup.arcBgColor
                            onColorEdited: function(c) { popup.arcBgColor = c }
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
