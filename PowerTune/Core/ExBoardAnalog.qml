import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Utils 1.0
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsPage {
    id: root

    property bool loadingConfig: false
    property var channelConfigs: []
    property var digitalChannelConfigs: []
    property var boardConfig: ({})

    property var linearPresetNames: {
        var presets = Calibration.linearPresets();
        var names = ["Custom"];
        for (var i = 0; i < presets.length; i++)
            names.push(presets[i].name);
        return names;
    }
    property var ntcPresetNames: {
        var presets = Calibration.ntcPresets();
        var names = ["Custom"];
        for (var i = 0; i < presets.length; i++)
            names.push(presets[i].name);
        return names;
    }

    function openPopup(popup) {
        popup.parent = Overlay.overlay;
        popup.open();
    }

    function loadAllSettingsFromManager() {
        var config = ExBoardConfig.loadAllSettings();
        loadingConfig = true;

        var chConfigs = [];
        for (var ch = 0; ch < 8; ++ch)
            chConfigs.push(config.channels && config.channels[ch] ? config.channels[ch] : {});
        channelConfigs = chConfigs;

        var diConfigs = [];
        for (var i = 0; i < 8; ++i)
            diConfigs.push(config.digitalChannels && config.digitalChannels[i] ? config.digitalChannels[i] : {});
        digitalChannelConfigs = diConfigs;

        boardConfig = config.board || {};
        loadingConfig = false;
    }

    function saveAllSettings() {
        if (loadingConfig)
            return;
        var channels = [];
        for (var ch = 0; ch < 8; ++ch)
            channels.push(channelConfigs[ch] || {});

        ExBoardConfig.saveAllSettings({
            channels: channels,
            digitalChannels: digitalChannelConfigs,
            board: boardConfig
        });
    }

    function liveRawVoltage(ch) {
        switch (ch) {
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

    function liveCalibratedValue(ch) {
        switch (ch) {
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

    function digitalInputState(di) {
        switch (di) {
        case 1: return Digital.EXDigitalInput1;
        case 2: return Digital.EXDigitalInput2;
        case 3: return Digital.EXDigitalInput3;
        case 4: return Digital.EXDigitalInput4;
        case 5: return Digital.EXDigitalInput5;
        case 6: return Digital.EXDigitalInput6;
        case 7: return Digital.EXDigitalInput7;
        case 8: return Digital.EXDigitalInput8;
        }
        return false;
    }

    Component.onCompleted: loadAllSettingsFromManager()

    SettingsSection {
        title: "Board Status"
        Layout.fillWidth: true

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
                visible: boardConfig.rpmSource !== undefined && boardConfig.rpmSource > 0
                text: {
                    var src = boardConfig.rpmSource === 1 ? "CAN RPM" : "DI1 Tach";
                    return src + ": " + Engine.rpm + " rpm";
                }
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontStatus
            }

            Text {
                visible: boardConfig.speedSensor !== undefined && boardConfig.speedSensor !== null && boardConfig.speedSensor.enabled === true
                text: {
                    var spd = (Expander.EXSpeed !== undefined) ? Expander.EXSpeed.toFixed(1) : "0.0";
                    var unit = (boardConfig.speedSensor && boardConfig.speedSensor.unit) ? boardConfig.speedSensor.unit : "MPH";
                    return spd + " " + unit;
                }
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontStatus
            }

            Text {
                visible: boardConfig.gearSensor !== undefined && boardConfig.gearSensor !== null && boardConfig.gearSensor.enabled === true
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
                visible: diffSensorPopup.diffConfig && diffSensorPopup.diffConfig.enabled === true
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

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.controlGap

            StyledButton {
                primary: false
                text: "Board Config"
                onClicked: root.openPopup(boardConfigPopup)
            }

            StyledButton {
                primary: false
                text: "Digital Inputs"
                onClicked: root.openPopup(digitalInputsPopup)
            }

            StyledButton {
                primary: false
                text: "Gear Sensor"
                onClicked: root.openPopup(gearSensorPopup)
            }

            StyledButton {
                primary: false
                text: "Speed Sensor"
                onClicked: root.openPopup(speedSensorPopup)
            }

            StyledButton {
                primary: false
                text: "Diff Sensor"
                onClicked: root.openPopup(diffSensorPopup)
            }

            Item { Layout.fillWidth: true }
        }
    }

    SettingsSection {
        title: "Analog Channels"
        Layout.fillWidth: true

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
            model: 8

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                spacing: 12
                opacity: {
                    var cfg = root.channelConfigs[index];
                    return (cfg && cfg.enabled === false) ? 0.4 : 1.0;
                }

                Item {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: parent.height

                    Rectangle {
                        anchors.centerIn: parent
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        color: root.liveRawVoltage(index) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    }
                }

                Text {
                    Layout.preferredWidth: 50
                    text: "AN " + index
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 120
                    text: {
                        var cfg = root.channelConfigs[index];
                        return (cfg && cfg.name) ? cfg.name : "---";
                    }
                    color: {
                        var cfg = root.channelConfigs[index];
                        return (cfg && cfg.name) ? SettingsTheme.textPrimary : SettingsTheme.textPlaceholder;
                    }
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
                    color: {
                        var cfg = root.channelConfigs[index];
                        return (cfg && cfg.ntcEnabled) ? "#2196F3" : SettingsTheme.accent;
                    }

                    Text {
                        anchors.centerIn: parent
                        text: {
                            var cfg = root.channelConfigs[index];
                            return (cfg && cfg.ntcEnabled) ? "NTC" : "Linear";
                        }
                        color: "#FFFFFF"
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        font.bold: true
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 100
                    text: {
                        var cfg = root.channelConfigs[index];
                        if (!cfg) return "Custom";
                        if (cfg.ntcEnabled)
                            return cfg.ntcPreset || "Custom";
                        return cfg.linearPreset || "Custom";
                    }
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: 100
                    text: root.liveRawVoltage(index).toFixed(3)
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamilyMono
                    font.pixelSize: SettingsTheme.fontLabel
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: 110
                    text: root.liveCalibratedValue(index).toFixed(2)
                    color: SettingsTheme.warning
                    font.family: SettingsTheme.fontFamilyMono
                    font.pixelSize: SettingsTheme.fontLabel
                    font.bold: true
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: 100
                    text: {
                        var cfg = root.channelConfigs[index];
                        var minV = cfg ? (cfg.minVoltage || "0.0") : "0.0";
                        var maxV = cfg ? (cfg.maxVoltage || "5.0") : "5.0";
                        return minV + " - " + maxV + " V";
                    }
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
                        channelConfigPopup.channelIndex = index;
                        channelConfigPopup.channelConfig = root.channelConfigs[index] || {};
                        channelConfigPopup.liveRawVoltage = Qt.binding(function() { return root.liveRawVoltage(index); });
                        channelConfigPopup.liveCalibratedValue = Qt.binding(function() { return root.liveCalibratedValue(index); });
                        root.openPopup(channelConfigPopup);
                    }
                }
            }
        }
    }

    SettingsSection {
        title: "Digital Inputs"
        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Item { Layout.preferredWidth: 20 }
            Text { Layout.preferredWidth: 80; text: "Channel"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true }
            Text { Layout.fillWidth: true; Layout.minimumWidth: 150; text: "Name"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true }
            Text { Layout.preferredWidth: 80; text: "State"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true }
            Text { Layout.preferredWidth: 140; text: "Tach RPM"; color: SettingsTheme.textSecondary; font.family: SettingsTheme.fontFamily; font.pixelSize: SettingsTheme.fontStatus; font.bold: true; visible: boardConfig.rpmSource === 2 }
            Item { Layout.fillWidth: true }
        }

        Rectangle { Layout.fillWidth: true; height: SettingsTheme.borderWidth; color: SettingsTheme.border }

        Repeater {
            model: 8

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                spacing: 12

                Item {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: parent.height

                    Rectangle {
                        anchors.centerIn: parent
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        color: root.digitalInputState(index + 1) ? SettingsTheme.success : SettingsTheme.textDisabled
                    }
                }

                Text {
                    Layout.preferredWidth: 80
                    text: "DI " + (index + 1)
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 150
                    text: {
                        var cfg = root.digitalChannelConfigs[index];
                        return (cfg && cfg.name) ? cfg.name : "---";
                    }
                    color: {
                        var cfg = root.digitalChannelConfigs[index];
                        return (cfg && cfg.name) ? SettingsTheme.textPrimary : SettingsTheme.textPlaceholder;
                    }
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: 80
                    text: root.digitalInputState(index + 1) ? "HIGH" : "LOW"
                    color: root.digitalInputState(index + 1) ? SettingsTheme.success : SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    font.bold: root.digitalInputState(index + 1)
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: 140
                    visible: index === 0 && boardConfig.rpmSource === 2
                    text: Digital.frequencyDIEX1 !== undefined ? Math.round(Digital.frequencyDIEX1) + " rpm" : "---"
                    color: SettingsTheme.warning
                    font.family: SettingsTheme.fontFamilyMono
                    font.pixelSize: SettingsTheme.fontLabel
                    verticalAlignment: Text.AlignVCenter
                }

                Item { Layout.fillWidth: true }
            }
        }
    }

    AnalogChannelConfigPopup {
        id: channelConfigPopup
        linearPresetNames: root.linearPresetNames
        ntcPresetNames: root.ntcPresetNames

        onSaved: function(channel, config) {
            var configs = root.channelConfigs.slice();
            configs[channel] = config;
            root.channelConfigs = configs;
            root.saveAllSettings();
        }

        onPresetApplied: function(channel, presetName, presetType) {
            if (presetType === "linear")
                ExBoardConfig.applyLinearPreset(channel, presetName);
            else
                ExBoardConfig.applyNtcPreset(channel, presetName);

            var updated = ExBoardConfig.getChannelConfig(channel);
            var configs = root.channelConfigs.slice();
            configs[channel] = updated;
            root.channelConfigs = configs;
            channelConfigPopup.channelConfig = updated;
        }
    }

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
                    id: boardConfigSection
                    width: boardConfigScroll.contentWidth
                    boardConfig: root.boardConfig

                    onConfigChanged: function(config) {
                        root.boardConfig = config;
                        root.saveAllSettings();
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
                    id: digitalInputsSection
                    width: digitalInputsScroll.contentWidth
                    digitalConfigs: root.digitalChannelConfigs
                    digitalInputs: Digital

                    onConfigChanged: function(configs) {
                        root.digitalChannelConfigs = configs;
                        root.saveAllSettings();
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

    GearSensorConfigPopup {
        id: gearSensorPopup
        gearConfig: root.boardConfig.gearSensor || ({})
        expanderData: Expander

        onSaved: function(config) {
            var bc = JSON.parse(JSON.stringify(root.boardConfig));
            bc.gearSensor = config;
            root.boardConfig = bc;
            root.saveAllSettings();
        }
    }

    SpeedSensorConfigPopup {
        id: speedSensorPopup
        speedConfig: root.boardConfig.speedSensor || ({})
        expanderData: Expander

        onSaved: function(config) {
            var bc = JSON.parse(JSON.stringify(root.boardConfig));
            bc.speedSensor = config;
            root.boardConfig = bc;
            root.saveAllSettings();
        }
    }

    DiffSensorConfigPopup {
        id: diffSensorPopup
        diffConfig: ExBoardConfig.getDifferentialSensorConfig()

        onSaved: function(config) {
            ExBoardConfig.saveDifferentialSensorConfig(config);
            diffSensorPopup.diffConfig = config;
        }
    }
}
