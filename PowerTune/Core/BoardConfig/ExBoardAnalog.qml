import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

Item {
    id: root

    implicitHeight: mainColumn.implicitHeight
    implicitWidth: mainColumn.implicitWidth

    property bool loadingConfig: false
    property var boardConfigData: ({})
    property var speedSensorConfig: ({})
    property var gearSensorConfig: ({})
    property var brightnessConfig: ({})
    property var diffConfig: ({})
    property int rpmSource: 0
    property bool speedSensorEnabled: false
    property bool gearSensorEnabled: false
    property string speedSensorUnit: "MPH"
    property var reservedAnalogPorts: []
    property var reservedDigitalPorts: []
    property var linearPresetNames: ExBoardConfig.linearPresetNames()
    property var ntcPresetNames: ExBoardConfig.ntcPresetNames()
    property int activeTab: 0

    function openPopup(popup) {
        popup.parent = Overlay.overlay;
        popup.open();
    }

    function openLoaderPopup(loader, configureCallback) {
        if (!loader.active)
            loader.active = true;

        var popup = loader.item;
        if (!popup)
            return;

        if (configureCallback)
            configureCallback(popup);

        root.openPopup(popup);
    }

    function boolValue(value) {
        return value === true || value === "true";
    }

    function syncBoardConfigState() {
        speedSensorConfig = boardConfigData.speedSensor || ({});
        gearSensorConfig = boardConfigData.gearSensor || ({});
        brightnessConfig = boardConfigData.brightness || ({});
        rpmSource = boardConfigData.rpmSource !== undefined ? Number(boardConfigData.rpmSource) : 0;
        speedSensorEnabled = boolValue(speedSensorConfig.enabled);
        gearSensorEnabled = boolValue(gearSensorConfig.enabled);
        speedSensorUnit = speedSensorConfig.unit ? speedSensorConfig.unit : "MPH";
    }

    function speedSourceSummary() {
        const cfg = speedSensorConfig || ({});
        const source = cfg.sourceType ? String(cfg.sourceType).toLowerCase() : "analog";
        if (source === "analogsquare" || source === "analogfrequency") {
            const aPort = (cfg.analogPort !== undefined) ? Number(cfg.analogPort) : 0;
            const th = (cfg.frequencyThreshold !== undefined) ? Number(cfg.frequencyThreshold) : 1.2;
            const hy = (cfg.frequencyHysteresis !== undefined) ? Number(cfg.frequencyHysteresis) : 0.2;
            return "SpeedSrc: AN" + aPort + " sq, th " + th.toFixed(2) + "V, hys " + hy.toFixed(2) + "V";
        }
        if (source === "digital") {
            const dPort = (cfg.digitalPort !== undefined) ? Number(cfg.digitalPort) : 0;
            return "SpeedSrc: DI" + (dPort + 1) + " sq";
        }
        const port = (cfg.analogPort !== undefined) ? Number(cfg.analogPort) : 0;
        return "SpeedSrc: AN" + port + " linear";
    }

    function liveRawVoltage(channel) {
        switch (channel) {
        case 0: return Expander.EXAnalogInput0;
        case 1: return Expander.EXAnalogInput1;
        case 2: return Expander.EXAnalogInput2;
        case 3: return Expander.EXAnalogInput3;
        case 4: return Expander.EXAnalogInput4;
        case 5: return Expander.EXAnalogInput5;
        case 6: return Expander.EXAnalogInput6;
        case 7: return Expander.EXAnalogInput7;
        }
        return 0.0;
    }

    function liveCalibratedValue(channel) {
        switch (channel) {
        case 0: return Expander.EXAnalogCalc0;
        case 1: return Expander.EXAnalogCalc1;
        case 2: return Expander.EXAnalogCalc2;
        case 3: return Expander.EXAnalogCalc3;
        case 4: return Expander.EXAnalogCalc4;
        case 5: return Expander.EXAnalogCalc5;
        case 6: return Expander.EXAnalogCalc6;
        case 7: return Expander.EXAnalogCalc7;
        }
        return 0.0;
    }

    function loadAllSettingsFromManager() {
        loadingConfig = true;
        var config = ExBoardConfig.loadAllSettings();
        boardConfigData = config.board || ({});
        diffConfig = ExBoardConfig.getDifferentialSensorConfig() || ({});
        syncBoardConfigState();
        ExBoardChannelModel.refresh();
        ExBoardDigitalModel.refresh();
        refreshPortReservations();
        loadingConfig = false;
    }

    function saveBoardConfig(config) {
        if (loadingConfig)
            return;

        boardConfigData = config || ({});
        syncBoardConfigState();
        ExBoardConfig.saveBoardConfig(boardConfigData);
        refreshPortReservations();
    }

    function refreshPortReservations() {
        reservedAnalogPorts = ExBoardConfig.reservedAnalogPorts();
        reservedDigitalPorts = ExBoardConfig.reservedDigitalPorts();
    }

    Component.onCompleted: loadAllSettingsFromManager()

    ColumnLayout {
        id: mainColumn

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: SettingsTheme.sectionSpacing

        SettingsSection {
            title: "Board Status"
            Layout.fillWidth: true
            visible: root.activeTab === 2

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                Rectangle {
                    width: SettingsTheme.statusDotSize
                    height: SettingsTheme.statusDotSize
                    radius: SettingsTheme.statusDotSize / 2
                    color: Diagnostics.canConnected ? SettingsTheme.success : SettingsTheme.error
                }
                Text {
                    text: Diagnostics.canStatusText
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                }
                Text {
                    text: Diagnostics.canMessageRate + " msg/s"
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                }

                Item { Layout.fillWidth: true }

                Text {
                    visible: rpmSource > 0
                    text: {
                        var src = rpmSource === 1 ? "CAN RPM" : "DI1 Tach";
                        return src + ": " + Engine.rpm + " rpm";
                    }
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                }

                Text {
                    visible: speedSensorEnabled
                    text: {
                        var spd = (Expander.EXSpeed !== undefined) ? Expander.EXSpeed.toFixed(1) : "0.0";
                        return spd + " " + speedSensorUnit;
                    }
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                }

                Text {
                    visible: speedSensorEnabled
                    text: speedSourceSummary()
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                }

                Text {
                    visible: gearSensorEnabled
                    text: {
                        var g = Expander.EXGear;
                        if (g === 0) return "Gear: N";
                        if (g === -1) return "Gear: R";
                        return "Gear: " + g;
                    }
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                }

                Text {
                    visible: boolValue(diffConfig.enabled)
                    text: "Diff: " + Expander.differentialSensor.toFixed(2)
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                }
            }
        }

        SettingsSection {
            title: "Configuration"
            Layout.fillWidth: true
            visible: root.activeTab === 2

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.controlGap

                StyledButton {
                    primary: false
                    text: "Board Config"
                    onClicked: root.openLoaderPopup(boardConfigLoader)
                }

                StyledButton {
                    primary: false
                    text: "Digital Inputs"
                    onClicked: root.openLoaderPopup(digitalInputsLoader)
                }

                StyledButton {
                    primary: false
                    text: "Gear Sensor"
                    onClicked: root.openLoaderPopup(gearSensorLoader)
                }

                StyledButton {
                    primary: false
                    text: "Speed Sensor"
                    onClicked: root.openLoaderPopup(speedSensorLoader)
                }

                StyledButton {
                    primary: false
                    text: "Diff Sensor"
                    onClicked: root.openLoaderPopup(diffSensorLoader)
                }

                Item { Layout.fillWidth: true }
            }
        }

        SettingsSection {
            title: "Analog Channels"
            Layout.fillWidth: true
            visible: root.activeTab === 0

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Item { Layout.preferredWidth: 20 }
                Text { Layout.preferredWidth: 50; text: "CH"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true }
                Text { Layout.fillWidth: true; Layout.minimumWidth: 120; text: "Name"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true }
                Text { Layout.preferredWidth: 80; text: "Mode"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true }
                Text { Layout.fillWidth: true; Layout.minimumWidth: 100; text: "Preset"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true }
                Text { Layout.preferredWidth: 100; text: "Raw V"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; horizontalAlignment: Text.AlignRight }
                Text { Layout.preferredWidth: 110; text: "Calibrated"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; horizontalAlignment: Text.AlignRight }
                Text { Layout.preferredWidth: 100; text: "V Range"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; horizontalAlignment: Text.AlignRight }
                Item { Layout.preferredWidth: 110 }
            }

            Rectangle { Layout.fillWidth: true; height: SettingsTheme.borderWidth; color: SettingsTheme.border }

            Repeater {
                model: ExBoardChannelModel

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    spacing: 12
                    required property int channelIndex
                    required property string name
                    required property bool channelEnabled
                    required property bool ntcEnabled
                    required property string presetName
                    required property string rawVoltageText
                    required property string calibratedValueText
                    required property string voltageRangeText
                    required property bool hasSignal
                    opacity: channelEnabled ? 1.0 : 0.4

                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: parent.height

                        Rectangle {
                            anchors.centerIn: parent
                            width: SettingsTheme.statusDotSize
                            height: SettingsTheme.statusDotSize
                            radius: SettingsTheme.statusDotSize / 2
                            color: hasSignal ? SettingsTheme.success : SettingsTheme.textDisabled
                        }
                    }

                    Text {
                        Layout.preferredWidth: 50
                        text: "AN " + channelIndex
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontLabel
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 120
                        text: name
                        color: name !== "---" ? SettingsTheme.textPrimary : SettingsTheme.textPlaceholder
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontLabel
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 28
                        Layout.alignment: Qt.AlignVCenter
                        radius: SettingsTheme.radiusSmall
                        color: ntcEnabled ? "#2196F3" : SettingsTheme.accent

                        Text {
                            anchors.centerIn: parent
                            text: ntcEnabled ? "NTC" : "Linear"
                            color: "#FFFFFF"
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            font.bold: true
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 100
                        text: presetName
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        Layout.preferredWidth: 100
                        text: rawVoltageText
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontLabel
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        Layout.preferredWidth: 110
                        text: calibratedValueText
                        color: SettingsTheme.warning
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontLabel
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        Layout.preferredWidth: 100
                        text: voltageRangeText
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontStatus
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    StyledButton {
                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        primary: false
                        text: "Configure"

                        onClicked: {
                            root.openLoaderPopup(channelConfigLoader, function(popup) {
                                popup.channelIndex = channelIndex;
                                popup.channelConfig = ExBoardChannelModel.configAt(channelIndex);
                                popup.liveRawVoltage = Qt.binding(function() {
                                    return root.liveRawVoltage(channelIndex);
                                });
                                popup.liveCalibratedValue = Qt.binding(function() {
                                    return root.liveCalibratedValue(channelIndex);
                                });
                            });
                        }
                    }
                }
            }
        }

        SettingsSection {
            title: "Digital Inputs"
            Layout.fillWidth: true
            visible: root.activeTab === 1

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Item { Layout.preferredWidth: 20 }
                Text { Layout.preferredWidth: 80; text: "Channel"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true }
                Text { Layout.fillWidth: true; Layout.minimumWidth: 150; text: "Name"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true }
                Text { Layout.preferredWidth: 80; text: "State"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true }
                Text { Layout.preferredWidth: 140; text: "Tach RPM"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; visible: rpmSource === 2 }
                Item { Layout.fillWidth: true }
            }

            Rectangle { Layout.fillWidth: true; height: SettingsTheme.borderWidth; color: SettingsTheme.border }

            Repeater {
                model: ExBoardDigitalModel

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    spacing: 12
                    required property int channelIndex
                    required property string name
                    required property bool stateHigh
                    required property string stateText

                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: parent.height

                        Rectangle {
                            anchors.centerIn: parent
                            width: SettingsTheme.statusDotSize
                            height: SettingsTheme.statusDotSize
                            radius: SettingsTheme.statusDotSize / 2
                            color: stateHigh ? SettingsTheme.success : SettingsTheme.textDisabled
                        }
                    }

                    Text {
                        Layout.preferredWidth: 80
                        text: "DI " + (channelIndex + 1)
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontLabel
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 150
                        text: name
                        color: name !== "---" ? SettingsTheme.textPrimary : SettingsTheme.textPlaceholder
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontLabel
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        Layout.preferredWidth: 80
                        text: stateText
                        color: stateHigh ? SettingsTheme.success : SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontLabel
                        font.bold: stateHigh
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        Layout.preferredWidth: 140
                        visible: channelIndex === 0 && rpmSource === 2
                        text: ExBoardDigitalModel.tachRpmText
                        color: SettingsTheme.warning
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontLabel
                        verticalAlignment: Text.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }
    }

    Component {
        id: channelConfigPopupComponent

        AnalogChannelConfigPopup {
            linearPresetNames: root.linearPresetNames
            ntcPresetNames: root.ntcPresetNames

            onSaved: function(channel, config) {
                ExBoardConfig.saveChannelConfig(channel, config);
                ExBoardChannelModel.refresh();
            }

            onPresetApplied: function(channel, presetName, presetType) {
                if (presetType === "linear")
                    ExBoardConfig.applyLinearPreset(channel, presetName);
                else
                    ExBoardConfig.applyNtcPreset(channel, presetName);

                ExBoardChannelModel.refresh();
                channelConfig = ExBoardChannelModel.configAt(channel);
            }
        }
    }

    Component {
        id: boardConfigPopupComponent

        Popup {
            id: boardConfigPopup
            width: parent ? Math.min(parent.width - 40, 700) : 700
            height: parent ? Math.min(parent.height - 40, 550) : 550
            x: parent ? (parent.width - width) / 2 : 0
            y: parent ? (parent.height - height) / 2 : 0
            modal: true
            padding: 0
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            Overlay.modal: Rectangle { color: "#80000000" }

            background: Rectangle {
                color: SettingsTheme.surfaceElevated
                radius: SettingsTheme.radiusLarge
                border.color: SettingsTheme.border
                border.width: 2
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: SettingsTheme.sectionPadding
                spacing: SettingsTheme.contentSpacing

                Text {
                    text: "Board Configuration"
                    color: SettingsTheme.accent
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontSectionTitle
                    font.weight: Font.Bold
                }

                Rectangle { Layout.fillWidth: true; height: SettingsTheme.borderWidth; color: SettingsTheme.border }

                ScrollView {
                    id: boardConfigScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: availableWidth

                    BoardConfigSection {
                        width: boardConfigScroll.contentWidth
                        boardConfig: root.boardConfigData
                        reservedAnalogPorts: root.reservedAnalogPorts
                        reservedDigitalPorts: root.reservedDigitalPorts

                        onConfigChanged: function(config) {
                            root.saveBoardConfig(config);
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }
                    StyledButton {
                        primary: false
                        text: "Close"
                        onClicked: boardConfigPopup.close()
                    }
                }
            }
        }
    }

    Component {
        id: digitalInputsPopupComponent

        Popup {
            id: digitalInputsPopup
            width: parent ? Math.min(parent.width - 40, 700) : 700
            height: parent ? Math.min(parent.height - 40, 650) : 650
            x: parent ? (parent.width - width) / 2 : 0
            y: parent ? (parent.height - height) / 2 : 0
            modal: true
            padding: 0
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            Overlay.modal: Rectangle { color: "#80000000" }

            background: Rectangle {
                color: SettingsTheme.surfaceElevated
                radius: SettingsTheme.radiusLarge
                border.color: SettingsTheme.border
                border.width: 2
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: SettingsTheme.sectionPadding
                spacing: SettingsTheme.contentSpacing

                Text {
                    text: "Digital Inputs Configuration"
                    color: SettingsTheme.accent
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontSectionTitle
                    font.weight: Font.Bold
                }

                Rectangle { Layout.fillWidth: true; height: SettingsTheme.borderWidth; color: SettingsTheme.border }

                ScrollView {
                    id: digitalInputsScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: availableWidth

                    DigitalInputsSection {
                        width: digitalInputsScroll.contentWidth
                        digitalInputs: Digital
                        digitalConfigs: ExBoardConfig.loadAllSettings().digitalChannels

                        onConfigChanged: function(configs) {
                            var current = ExBoardConfig.loadAllSettings();
                            current.digitalChannels = configs;
                            ExBoardConfig.saveAllSettings(current);
                            ExBoardDigitalModel.refresh();
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }
                    StyledButton {
                        primary: false
                        text: "Close"
                        onClicked: digitalInputsPopup.close()
                    }
                }
            }
        }
    }

    Component {
        id: gearSensorPopupComponent

        GearSensorConfigPopup {
            gearConfig: root.gearSensorConfig
            unavailableAnalogPorts: root.reservedAnalogPorts
            expanderData: Expander

            onSaved: function(config) {
                var updated = JSON.parse(JSON.stringify(root.boardConfigData));
                updated.gearSensor = config;
                root.saveBoardConfig(updated);
            }
        }
    }

    Component {
        id: speedSensorPopupComponent

        SpeedSensorConfigPopup {
            speedConfig: root.speedSensorConfig
            expanderData: Expander

            onSaved: function(config) {
                var updated = JSON.parse(JSON.stringify(root.boardConfigData));
                updated.speedSensor = config;
                root.saveBoardConfig(updated);
            }
        }
    }

    Component {
        id: diffSensorPopupComponent

        DiffSensorConfigPopup {
            diffConfig: root.diffConfig
            unavailableAnalogPorts: root.reservedAnalogPorts

            onSaved: function(config) {
                ExBoardConfig.saveDifferentialSensorConfig(config);
                root.diffConfig = config;
                root.refreshPortReservations();
            }
        }
    }

    Loader { id: channelConfigLoader; active: false; sourceComponent: channelConfigPopupComponent }
    Loader { id: boardConfigLoader; active: false; sourceComponent: boardConfigPopupComponent }
    Loader { id: digitalInputsLoader; active: false; sourceComponent: digitalInputsPopupComponent }
    Loader { id: gearSensorLoader; active: false; sourceComponent: gearSensorPopupComponent }
    Loader { id: speedSensorLoader; active: false; sourceComponent: speedSensorPopupComponent }
    Loader { id: diffSensorLoader; active: false; sourceComponent: diffSensorPopupComponent }
}
