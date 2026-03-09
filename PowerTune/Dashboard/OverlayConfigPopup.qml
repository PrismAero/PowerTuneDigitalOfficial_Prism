import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
    property var sensorListModel: []

    signal configSaved(string overlayId)

    width: 460
    height: contentCol.implicitHeight + 40
    x: (parent ? (parent.width - width) / 2 : 0)
    y: (parent ? (parent.height - height) / 2 : 0)
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    background: Rectangle {
        color: "#1a1a36"
        border.color: "#3a3a60"
        border.width: 2
        radius: 10
    }

    function openFor(id, type) {
        overlayId = id;
        configType = type;

        var cfg = OverlayConfig.getConfig(id);
        selectedSensorKey = cfg.sensorKey || "";
        labelText = cfg.label || "";
        unitText = cfg.unit || "";
        thresholdValue = cfg.threshold !== undefined ? Number(cfg.threshold) : 0.5;
        minValue = cfg.minValue !== undefined ? Number(cfg.minValue) : 0;
        maxValue = cfg.maxValue !== undefined ? Number(cfg.maxValue) : 100;
        staticText = cfg.text || "";
        decimals = cfg.decimals !== undefined ? Number(cfg.decimals) : 0;
        arcColorStart = cfg.arcColorStart || "";
        arcColorEnd = cfg.arcColorEnd || "";
        gearSensorKey = cfg.gearKey || "Gear";
        shiftPoint = cfg.shiftPoint !== undefined ? Number(cfg.shiftPoint) : 0.75;
        shiftCount = cfg.shiftCount !== undefined ? Number(cfg.shiftCount) : 11;
        shiftPattern = cfg.shiftPattern || "center-out";

        if (type === "tachGroup" && maxValue <= 0) {
            var m = AppSettings.getValue("Max RPM", 10000);
            maxValue = m > 0 ? m : 10000;
        }
        if (type === "tachGroup" && shiftPoint <= 0) {
            var s1 = Number(AppSettings.getValue("Shift Light1", 3000));
            shiftPoint = maxValue > 0 ? s1 / maxValue : 0.75;
        }

        refreshSensorList();
        open();
    }

    function refreshSensorList() {
        var cats = SensorRegistry.availableCategories;
        if (cats.length === 0)
            cats = [""];
        var catName = selectedCategoryIndex < cats.length ? cats[selectedCategoryIndex] : "";
        var sensors = SensorRegistry.getSensorsByCategory(catName);
        sensorListModel = sensors;
    }

    function doSave() {
        var cfg = {};
        if (configType === "sensorCard") {
            cfg.sensorKey = selectedSensorKey;
            cfg.label = labelText;
            cfg.unit = unitText;
            cfg.decimals = decimals;
        } else if (configType === "statusRow") {
            cfg.sensorKey = selectedSensorKey;
            cfg.label = labelText;
            cfg.threshold = thresholdValue;
        } else if (configType === "tachGroup") {
            cfg.sensorKey = selectedSensorKey;
            cfg.minValue = minValue;
            cfg.maxValue = maxValue;
            cfg.unit = unitText;
            cfg.arcColorStart = arcColorStart;
            cfg.arcColorEnd = arcColorEnd;
            cfg.gearKey = gearSensorKey;
            cfg.shiftPoint = shiftPoint;
            cfg.shiftCount = shiftCount;
            cfg.shiftPattern = shiftPattern;
            cfg.decimals = decimals;
        } else if (configType === "speedGroup") {
            cfg.sensorKey = selectedSensorKey;
            cfg.minValue = minValue;
            cfg.maxValue = maxValue;
            cfg.unit = unitText;
            cfg.arcColorStart = arcColorStart;
            cfg.arcColorEnd = arcColorEnd;
            cfg.decimals = decimals;
        } else if (configType === "staticText") {
            cfg.text = staticText;
        }
        OverlayConfig.saveConfig(overlayId, cfg);
        configSaved(overlayId);
        close();
    }

    function doReset() {
        OverlayConfig.resetConfig(overlayId);
        configSaved(overlayId);
        close();
    }

    readonly property color accent: "#009688"
    readonly property color txtP: "#FFFFFF"
    readonly property color txtS: "#8888AA"
    readonly property color fieldBg: "#111122"
    readonly property color fieldBorder: "#2a2a50"

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
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Configure: " + popup.overlayId
                font.pixelSize: 18
                font.weight: Font.DemiBold
                color: txtP
                Layout.fillWidth: true
            }
            Button {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                onClicked: popup.close()
                background: Rectangle {
                    radius: 16
                    color: "#333"
                }
                contentItem: Text {
                    text: "X"
                    color: txtP
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: fieldBorder
        }

        // -- Sensor Picker --
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: hasSensorPicker

            Text {
                text: "Category"
                font.pixelSize: 13
                color: txtS
            }

            ComboBox {
                id: categoryCombo
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                model: SensorRegistry.availableCategories
                currentIndex: popup.selectedCategoryIndex
                onCurrentIndexChanged: {
                    popup.selectedCategoryIndex = currentIndex;
                    popup.refreshSensorList();
                }
                background: Rectangle {
                    radius: 6
                    color: fieldBg
                    border.color: fieldBorder
                    border.width: 1
                }
                contentItem: Text {
                    text: categoryCombo.displayText
                    color: txtP
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }
            }

            Text {
                text: "Sensor"
                font.pixelSize: 13
                color: txtS
            }

            ComboBox {
                id: sensorCombo
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                model: {
                    var names = [];
                    for (var i = 0; i < popup.sensorListModel.length; i++)
                        names.push(popup.sensorListModel[i].displayName + " (" + popup.sensorListModel[i].key + ")");
                    return names;
                }
                currentIndex: {
                    for (var i = 0; i < popup.sensorListModel.length; i++) {
                        if (popup.sensorListModel[i].key === popup.selectedSensorKey)
                            return i;
                    }
                    return -1;
                }
                onActivated: function (idx) {
                    if (idx >= 0 && idx < popup.sensorListModel.length) {
                        var s = popup.sensorListModel[idx];
                        popup.selectedSensorKey = s.key;
                        if (hasLabel)
                            popup.labelText = s.displayName;
                        if (hasUnit)
                            popup.unitText = s.unit;
                    }
                }
                background: Rectangle {
                    radius: 6
                    color: fieldBg
                    border.color: accent
                    border.width: 1
                }
                contentItem: Text {
                    text: sensorCombo.displayText
                    color: txtP
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
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
                font.pixelSize: 13
                color: txtS
            }
            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                text: popup.labelText
                onTextEdited: popup.labelText = text
                color: txtP
                font.pixelSize: 14
                background: Rectangle {
                    radius: 6
                    color: fieldBg
                    border.color: fieldBorder
                    border.width: 1
                }
            }
        }

        // -- Unit --
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            visible: hasUnit

            Text {
                text: "Unit"
                font.pixelSize: 13
                color: txtS
            }
            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                text: popup.unitText
                onTextEdited: popup.unitText = text
                color: txtP
                font.pixelSize: 14
                background: Rectangle {
                    radius: 6
                    color: fieldBg
                    border.color: fieldBorder
                    border.width: 1
                }
            }
        }

        // -- Threshold (statusRow) --
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            visible: hasThreshold

            Text {
                text: "ON/OFF Threshold (trip point)"
                font.pixelSize: 13
                color: txtS
            }
            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                text: popup.thresholdValue.toString()
                onTextEdited: {
                    var v = parseFloat(text);
                    if (!isNaN(v))
                        popup.thresholdValue = v;
                }
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                color: txtP
                font.pixelSize: 14
                background: Rectangle {
                    radius: 6
                    color: fieldBg
                    border.color: fieldBorder
                    border.width: 1
                }
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
                    font.pixelSize: 13
                    color: txtS
                }
                TextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    text: popup.minValue.toString()
                    onTextEdited: {
                        var v = parseFloat(text);
                        if (!isNaN(v))
                            popup.minValue = v;
                    }
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    color: txtP
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 6
                        color: fieldBg
                        border.color: fieldBorder
                        border.width: 1
                    }
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text {
                    text: "Max"
                    font.pixelSize: 13
                    color: txtS
                }
                TextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    text: popup.maxValue.toString()
                    onTextEdited: {
                        var v = parseFloat(text);
                        if (!isNaN(v))
                            popup.maxValue = v;
                    }
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    color: txtP
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 6
                        color: fieldBg
                        border.color: fieldBorder
                        border.width: 1
                    }
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
                    font.pixelSize: 13
                    color: txtS
                }
                TextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    text: popup.arcColorStart
                    placeholderText: "#RRGGBB"
                    onTextEdited: popup.arcColorStart = text
                    color: txtP
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 6
                        color: fieldBg
                        border.color: fieldBorder
                        border.width: 1
                    }
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text {
                    text: "Arc Color End"
                    font.pixelSize: 13
                    color: txtS
                }
                TextField {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    text: popup.arcColorEnd
                    placeholderText: "#RRGGBB"
                    onTextEdited: popup.arcColorEnd = text
                    color: txtP
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 6
                        color: fieldBg
                        border.color: fieldBorder
                        border.width: 1
                    }
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
                font.pixelSize: 13
                color: txtS
            }
            SpinBox {
                id: decimalsSpin
                from: 0
                to: 4
                value: popup.decimals
                onValueChanged: popup.decimals = value
                Layout.preferredWidth: 100
                Layout.preferredHeight: 38
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
                color: fieldBorder
            }

            Text {
                text: "Gear Sensor"
                font.pixelSize: 13
                color: txtS
            }
            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                text: popup.gearSensorKey
                onTextEdited: popup.gearSensorKey = text
                color: txtP
                font.pixelSize: 14
                background: Rectangle {
                    radius: 6
                    color: fieldBg
                    border.color: fieldBorder
                    border.width: 1
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: "Shift Point (0-1)"
                        font.pixelSize: 13
                        color: txtS
                    }
                    TextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        text: popup.shiftPoint.toFixed(3)
                        onTextEdited: {
                            var v = parseFloat(text);
                            if (!isNaN(v))
                                popup.shiftPoint = v;
                        }
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        color: txtP
                        font.pixelSize: 14
                        background: Rectangle {
                            radius: 6
                            color: fieldBg
                            border.color: fieldBorder
                            border.width: 1
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: "Light Count"
                        font.pixelSize: 13
                        color: txtS
                    }
                    SpinBox {
                        from: 1
                        to: 15
                        value: popup.shiftCount
                        onValueChanged: popup.shiftCount = value
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 38
                    }
                }
            }

            Text {
                text: "Light Pattern"
                font.pixelSize: 13
                color: txtS
            }
            ComboBox {
                id: patternCombo
                Layout.fillWidth: true
                Layout.preferredHeight: 40
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
                background: Rectangle {
                    radius: 6
                    color: fieldBg
                    border.color: fieldBorder
                    border.width: 1
                }
                contentItem: Text {
                    text: patternCombo.displayText
                    color: txtP
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
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
                font.pixelSize: 13
                color: txtS
            }
            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                text: popup.staticText
                onTextEdited: popup.staticText = text
                color: txtP
                font.pixelSize: 14
                background: Rectangle {
                    radius: 6
                    color: fieldBg
                    border.color: fieldBorder
                    border.width: 1
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: fieldBorder
        }

        // -- Action Buttons --
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                onClicked: popup.doSave()
                background: Rectangle {
                    radius: 6
                    color: accent
                }
                contentItem: Text {
                    text: "Save"
                    color: txtP
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                onClicked: popup.doReset()
                background: Rectangle {
                    radius: 6
                    color: "#663333"
                }
                contentItem: Text {
                    text: "Reset"
                    color: txtP
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                onClicked: popup.close()
                background: Rectangle {
                    radius: 6
                    color: "#333355"
                }
                contentItem: Text {
                    text: "Cancel"
                    color: txtS
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
