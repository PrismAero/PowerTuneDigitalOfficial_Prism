import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

Popup {
    id: popup

    property string overlayId: ""
    property string configType: ""

    property string selectedSensorKey: ""
    property string labelText: ""
    property string unitText: ""
    property real thresholdValue: 0.5
    property real minValue: 0
    property real maxValue: 100
    property string staticText: ""
    property int decimals: 0
    property string arcColorStart: ""
    property string arcColorEnd: ""
    property string gearSensorKey: "Gear"
    property real shiftPoint: 0.75
    property int shiftCount: 11
    property string shiftPattern: "center-out"

    property int selectedCategoryIndex: 0

    signal configSaved(string overlayId)

    width: 460
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

    function openFor(id, type) {
        overlayId = id
        configType = type

        var cfg = OverlayConfig.getConfigForPopup(id, type)
        selectedSensorKey = cfg.sensorKey || ""
        labelText = cfg.label || ""
        unitText = cfg.unit || ""
        thresholdValue = Number(cfg.threshold)
        minValue = Number(cfg.minValue)
        maxValue = Number(cfg.maxValue)
        staticText = cfg.text || ""
        decimals = Number(cfg.decimals)
        arcColorStart = cfg.arcColorStart || ""
        arcColorEnd = cfg.arcColorEnd || ""
        gearSensorKey = cfg.gearKey || "Gear"
        shiftPoint = Number(cfg.shiftPoint)
        shiftCount = Number(cfg.shiftCount)
        shiftPattern = cfg.shiftPattern || "center-out"

        selectedCategoryIndex = 0
        open()
    }

    function doSave() {
        OverlayConfig.saveConfigFromPopup(overlayId, configType, {
            "sensorKey": selectedSensorKey,
            "label": labelText,
            "unit": unitText,
            "threshold": thresholdValue,
            "minValue": minValue,
            "maxValue": maxValue,
            "text": staticText,
            "decimals": decimals,
            "arcColorStart": arcColorStart,
            "arcColorEnd": arcColorEnd,
            "gearKey": gearSensorKey,
            "shiftPoint": shiftPoint,
            "shiftCount": shiftCount,
            "shiftPattern": shiftPattern
        })
        configSaved(overlayId)
        close()
    }

    function doReset() {
        OverlayConfig.resetConfig(overlayId)
        configSaved(overlayId)
        close()
    }

    readonly property bool isSensorType: configType !== "staticText"
    readonly property bool isGaugeGroup: configType === "tachGroup" || configType === "speedGroup"
    readonly property bool isTachGroup: configType === "tachGroup"
    readonly property bool hasSensorPicker: isSensorType
    readonly property bool hasLabel: configType === "sensorCard" || configType === "statusRow"
    readonly property bool hasUnit: configType === "sensorCard" || isGaugeGroup
    readonly property bool hasMinMax: isGaugeGroup
    readonly property bool hasThreshold: configType === "statusRow"
    readonly property bool hasDecimals: configType === "sensorCard" || isGaugeGroup
    readonly property bool hasArcColors: isGaugeGroup
    readonly property bool hasStaticText: configType === "staticText"

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

                // -- Sensor Picker --
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: hasSensorPicker

                    Text {
                        text: "Category"
                        font.pixelSize: SettingsTheme.fontCaption
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                    }

                    StyledComboBox {
                        id: categoryCombo
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        model: SensorRegistry.availableCategories
                        currentIndex: popup.selectedCategoryIndex
                        onCurrentIndexChanged: popup.selectedCategoryIndex = currentIndex
                    }

                    Text {
                        text: "Sensor"
                        font.pixelSize: SettingsTheme.fontCaption
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                    }

                    StyledComboBox {
                        id: sensorCombo
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight

                        readonly property string activeCat: {
                            var cats = SensorRegistry.availableCategories
                            return popup.selectedCategoryIndex < cats.length ? cats[popup.selectedCategoryIndex] : ""
                        }

                        model: SensorRegistry.sensorDisplayNames(activeCat)
                        currentIndex: SensorRegistry.indexOfSensorKey(popup.selectedSensorKey, activeCat)
                        onActivated: function (idx) {
                            var sensors = SensorRegistry.getSensorsByCategory(activeCat)
                            if (idx >= 0 && idx < sensors.length) {
                                var s = sensors[idx]
                                popup.selectedSensorKey = s.key
                                if (hasLabel)
                                    popup.labelText = s.displayName
                                if (hasUnit)
                                    popup.unitText = s.unit
                            }
                        }
                    }
                }

                // -- Label --
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: hasLabel

                    Text {
                        text: "Label"
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

                // -- Unit --
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: hasUnit

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

                // -- Threshold (statusRow) --
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: hasThreshold

                    Text {
                        text: "ON/OFF Threshold (trip point)"
                        font.pixelSize: SettingsTheme.fontCaption
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                    }
                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        text: popup.thresholdValue.toString()
                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v))
                                popup.thresholdValue = v;
                        }
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }
                }

                // -- Min/Max (gauge groups) --
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: hasMinMax

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: "Min"
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
                        }
                        StyledTextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            text: popup.minValue.toString()
                            onTextEdited: {
                                var v = parseFloat(text);
                                if (!isNaN(v))
                                    popup.minValue = v;
                            }
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: "Max"
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
                        }
                        StyledTextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            text: popup.maxValue.toString()
                            onTextEdited: {
                                var v = parseFloat(text);
                                if (!isNaN(v))
                                    popup.maxValue = v;
                            }
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                    }
                }

                // -- Arc Colors (gauge groups) --
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: hasArcColors

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: "Arc Color Start"
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
                        }
                        StyledColorPicker {
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            colorValue: popup.arcColorStart
                            onColorEdited: function(newColor) { popup.arcColorStart = newColor }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: "Arc Color End"
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
                        }
                        StyledColorPicker {
                            Layout.fillWidth: true
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            colorValue: popup.arcColorEnd
                            onColorEdited: function(newColor) { popup.arcColorEnd = newColor }
                        }
                    }
                }

                // -- Decimals --
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: hasDecimals

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

                // -- Tach Group: Gear, Shift --
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: isTachGroup

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: SettingsTheme.border
                    }

                    Text {
                        text: "Gear Sensor"
                        font.pixelSize: SettingsTheme.fontCaption
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                    }
                    StyledTextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        text: popup.gearSensorKey
                        onTextEdited: popup.gearSensorKey = text
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: "Shift Point (0-1)"
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                            }
                            StyledTextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                text: popup.shiftPoint.toFixed(3)
                                onTextEdited: {
                                    var v = parseFloat(text);
                                    if (!isNaN(v))
                                        popup.shiftPoint = v;
                                }
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
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
                            var items = ["center-out", "left-to-right", "right-to-left", "alternating"];
                            var idx = items.indexOf(popup.shiftPattern);
                            return idx >= 0 ? idx : 0;
                        }
                        onActivated: function (idx) {
                            var items = ["center-out", "left-to-right", "right-to-left", "alternating"];
                            if (idx >= 0 && idx < items.length)
                                popup.shiftPattern = items[idx];
                        }
                    }
                }

                // -- Static Text (bottom bar) --
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: hasStaticText

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
