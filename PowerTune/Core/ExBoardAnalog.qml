// Copyright (c) PowerTune Digital, Kai Wyborny. All rights reserved.
// ExBoardAnalog.qml - EX Board analog input calibration with NTC + linear presets
// Layout: SettingsPage with unified channel table, board config, digital inputs

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Utils 1.0
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsPage {
    id: mainWindow

    // True when any NTC-capable channel is in NTC mode; shows extra calibration columns
    readonly property bool anyNtcActive: checkan0ntc.checked || checkan1ntc.checked || checkan2ntc.checked
                                         || checkan3ntc.checked || checkan4ntc.checked || checkan5ntc.checked
    property var analogChannelModel: ["Ex Analog Input 1", "Ex Analog Input 2", "Ex Analog Input 3",
        "Ex Analog Input 4", "Ex Analog Input 5", "Ex Analog Input 6", "Ex Analog Input 7", "Ex Analog Input 8"]
    readonly property int calibColW: 90
    readonly property int divCheckColW: 45

    // Unified analog table column widths
    readonly property int enableColW: 65
    readonly property int fieldColW: 65
    property var linearPresetNames: {
        var presets = Calibration.linearPresets();
        var names = ["Custom"];
        for (var i = 0; i < presets.length; i++) {
            names.push(presets[i].name);
        }
        return names;
    }
    readonly property int liveVColW: 75
    property bool loadingConfig: false
    readonly property int modeColW: 120
    readonly property int nameColW: 120
    property var ntcPresetNames: {
        var presets = Calibration.ntcPresets();
        var names = ["Custom"];
        for (var i = 0; i < presets.length; i++) {
            names.push(presets[i].name);
        }
        return names;
    }
    readonly property int presetColW: 210
    property int rpmCheckboxSaveValue: 0
    readonly property int statusColW: 28

    function analogChannelRefs() {
        return [
                    {
                        enabled: chEnable0,
                        name: chName0,
                        modeCombo: modeCombo0,
                        linearPreset: linPreset0,
                        ntcPreset: ntcPreset0,
                        val0Field: ex00,
                        val5Field: ex05,
                        ntcToggle: checkan0ntc,
                        divider100: checkan0100,
                        divider1k: checkan01k,
                        steinhartT: [t10, t20, t30],
                        steinhartR: [r10, r20, r30]
                    },
                    {
                        enabled: chEnable1,
                        name: chName1,
                        modeCombo: modeCombo1,
                        linearPreset: linPreset1,
                        ntcPreset: ntcPreset1,
                        val0Field: ex10,
                        val5Field: ex15,
                        ntcToggle: checkan1ntc,
                        divider100: checkan1100,
                        divider1k: checkan11k,
                        steinhartT: [t11, t21, t31],
                        steinhartR: [r11, r21, r31]
                    },
                    {
                        enabled: chEnable2,
                        name: chName2,
                        modeCombo: modeCombo2,
                        linearPreset: linPreset2,
                        ntcPreset: ntcPreset2,
                        val0Field: ex20,
                        val5Field: ex25,
                        ntcToggle: checkan2ntc,
                        divider100: checkan2100,
                        divider1k: checkan21k,
                        steinhartT: [t12, t22, t32],
                        steinhartR: [r12, r22, r32]
                    },
                    {
                        enabled: chEnable3,
                        name: chName3,
                        modeCombo: modeCombo3,
                        linearPreset: linPreset3,
                        ntcPreset: ntcPreset3,
                        val0Field: ex30,
                        val5Field: ex35,
                        ntcToggle: checkan3ntc,
                        divider100: checkan3100,
                        divider1k: checkan31k,
                        steinhartT: [t13, t23, t33],
                        steinhartR: [r13, r23, r33]
                    },
                    {
                        enabled: chEnable4,
                        name: chName4,
                        modeCombo: modeCombo4,
                        linearPreset: linPreset4,
                        ntcPreset: ntcPreset4,
                        val0Field: ex40,
                        val5Field: ex45,
                        ntcToggle: checkan4ntc,
                        divider100: checkan4100,
                        divider1k: checkan41k,
                        steinhartT: [t14, t24, t34],
                        steinhartR: [r14, r24, r34]
                    },
                    {
                        enabled: chEnable5,
                        name: chName5,
                        modeCombo: modeCombo5,
                        linearPreset: linPreset5,
                        ntcPreset: ntcPreset5,
                        val0Field: ex50,
                        val5Field: ex55,
                        ntcToggle: checkan5ntc,
                        divider100: checkan5100,
                        divider1k: checkan51k,
                        steinhartT: [t15, t25, t35],
                        steinhartR: [r15, r25, r35]
                    },
                    {
                        enabled: chEnable6,
                        name: chName6,
                        linearPreset: linPreset6,
                        val0Field: ex60,
                        val5Field: ex65
                    },
                    {
                        enabled: chEnable7,
                        name: chName7,
                        linearPreset: linPreset7,
                        val0Field: ex70,
                        val5Field: ex75
                    }
                ];
    }

    function applyBoardConfig(config) {
        var board = config || {};
        var brightnessConfig = board.brightness || {};
        digitalExtender.currentIndex = brightnessConfig.headlightChannel !== undefined ? brightnessConfig.headlightChannel
                                                                                       : (board.selectedValue !== undefined ? board.selectedValue : 0);
        brightnessManualEnabled.checked = brightnessConfig.manualEnabled !== undefined ? !!brightnessConfig.manualEnabled : true;
        discreteBrightnessEnabled.checked =
                brightnessConfig.discreteEnabled !== undefined ? !!brightnessConfig.discreteEnabled
                                                               : (board.switchValue !== undefined ? !!board.switchValue : false);
        canIoBrightnessEnabled.checked = brightnessConfig.canIoEnabled !== undefined ? !!brightnessConfig.canIoEnabled : false;
        analogBrightnessEnabled.checked = brightnessConfig.analogEnabled !== undefined ? !!brightnessConfig.analogEnabled : false;
        analogBrightnessChannel.currentIndex = brightnessConfig.analogChannel !== undefined ? brightnessConfig.analogChannel : 0;
        rpmsourceselector.currentIndex = board.rpmSource !== undefined ? board.rpmSource : 0;
        rpmcanversionselector.currentIndex = board.rpmCanVersion !== undefined ? board.rpmCanVersion : 0;
        cylindercombobox.currentIndex = board.cylinderCombobox !== undefined ? board.cylinderCombobox : 0;
        cylindercomboboxv2.currentIndex = board.cylinderComboboxV2 !== undefined ? board.cylinderComboboxV2 : 0;
        cylindercomboboxDi1.currentIndex = board.cylinderComboboxDi1 !== undefined ? board.cylinderComboboxDi1 : 0;
        rpmCheckboxSaveValue = board.rpmcheckbox !== undefined ? board.rpmcheckbox : 0;
        an7dampingfactor.text = stringValue(board.an7Damping, "0");

        var gearConfig = board.gearSensor || {};
        gearSensorEnabled.checked = gearConfig.enabled === true || gearConfig.enabled === "true";
        gearSensorPort.currentIndex = Number(gearConfig.port) || 0;
        gearTolerance.text = stringValue(gearConfig.tolerance, "0.2");
        gearVoltageN.text = stringValue(gearConfig.voltageN, "0.0");
        gearVoltageR.text = stringValue(gearConfig.voltageR, "0.5");
        gearVoltage1.text = stringValue(gearConfig.voltage1, "1.0");
        gearVoltage2.text = stringValue(gearConfig.voltage2, "1.5");
        gearVoltage3.text = stringValue(gearConfig.voltage3, "2.0");
        gearVoltage4.text = stringValue(gearConfig.voltage4, "2.5");
        gearVoltage5.text = stringValue(gearConfig.voltage5, "3.0");
        gearVoltage6.text = stringValue(gearConfig.voltage6, "3.5");

        var speedConfig = board.speedSensor || {};
        speedSensorEnabled.checked = speedConfig.enabled === true || speedConfig.enabled === "true";
        speedSourceType.currentIndex = speedConfig.sourceType === "digital" ? 1 : 0;
        speedAnalogPort.currentIndex = Number(speedConfig.analogPort) || 0;
        speedDigitalPort.currentIndex = Number(speedConfig.digitalPort) || 0;
        speedPulsesPerRev.text = stringValue(speedConfig.pulsesPerRev, "4.0");
        speedVoltageMultiplier.text = stringValue(speedConfig.voltageMultiplier, "1.0");
        speedTireCircumference.text = stringValue(speedConfig.tireCircumference, "2.06");
        speedFinalDriveRatio.text = stringValue(speedConfig.finalDriveRatio, "1.0");
        speedUnit.currentIndex = speedConfig.unit === "KPH" ? 1 : 0;
    }

    function applyChannelConfig(channel, config) {
        var ref = analogChannelRefs()[channel];
        if (!ref || !config)
            return;

        ref.enabled.checked = config.enabled !== undefined ? !!config.enabled : true;
        ref.name.text = stringValue(config.name, "");
        ref.val0Field.text = stringValue(config.val0v, "0");
        ref.val5Field.text = stringValue(config.val5v, "5");
        setComboSelection(ref.linearPreset, linearPresetNames, config.linearPreset || "Custom");

        if (channel < 6) {
            var ntcEnabled = !!config.ntcEnabled;
            ref.ntcToggle.checked = ntcEnabled;
            ref.modeCombo.currentIndex = ntcEnabled ? 1 : 0;
            ref.divider100.checked = !!config.divider100;
            ref.divider1k.checked = !!config.divider1k;
            setComboSelection(ref.ntcPreset, ntcPresetNames, config.ntcPreset || "Custom");

            var steinhartT = config.steinhartT || [];
            var steinhartR = config.steinhartR || [];
            for (var i = 0; i < 3; ++i) {
                ref.steinhartT[i].text = stringValue(steinhartT[i], "0");
                ref.steinhartR[i].text = stringValue(steinhartR[i], "0");
            }
        }
    }

    function applyDigitalChannelConfig(index, config) {
        var item = digitalChannelItem(index);
        if (!item || !config)
            return;

        item.enableSwitch.checked = config.enabled !== undefined ? !!config.enabled : true;
        item.nameField.text = stringValue(config.name, "");
    }

    function applyLinearPreset(channel, presetName) {
        ExBoardConfig.applyLinearPreset(channel, presetName);
        applyChannelConfig(channel, ExBoardConfig.getChannelConfig(channel));
        inputs.setInputs();
    }

    function applyNtcPreset(channel, presetName) {
        ExBoardConfig.applyNtcPreset(channel, presetName);
        applyChannelConfig(channel, ExBoardConfig.getChannelConfig(channel));
        inputs.setInputs();
    }

    function buildAllSettings() {
        var channels = [];
        for (var ch = 0; ch < 8; ++ch)
            channels.push(buildChannelConfig(ch));

        var digitalChannels = [];
        for (var i = 0; i < 8; ++i) {
            var item = digitalChannelItem(i);
            if (!item)
                continue;
            digitalChannels.push({
                                     enabled: item.enableSwitch.checked,
                                     name: item.nameField.text
                                 });
        }

        return {
            channels: channels,
            digitalChannels: digitalChannels,
            board: buildBoardConfig()
        };
    }

    function buildBoardConfig() {
        return {
            selectedValue: digitalExtender.currentIndex,
            switchValue: discreteBrightnessEnabled.checked || canIoBrightnessEnabled.checked,
            rpmSource: rpmsourceselector.currentIndex,
            rpmCanVersion: rpmcanversionselector.currentIndex,
            cylinderCombobox: cylindercombobox.currentIndex,
            cylinderComboboxValue: parseFloat(cylindercombobox.currentText),
            cylinderComboboxV2: cylindercomboboxv2.currentIndex,
            cylinderComboboxV2Value: parseFloat(cylindercomboboxv2.currentText),
            cylinderComboboxDi1: cylindercomboboxDi1.currentIndex,
            rpmcheckbox: rpmCheckboxSaveValue,
            an7Damping: an7dampingfactor.text,
            brightness: buildBrightnessConfig(),
            gearSensor: buildGearSensorConfig(),
            speedSensor: buildSpeedSensorConfig()
        };
    }

    function buildBrightnessConfig() {
        return {
            manualEnabled: brightnessManualEnabled.checked,
            discreteEnabled: discreteBrightnessEnabled.checked,
            canIoEnabled: canIoBrightnessEnabled.checked,
            analogEnabled: analogBrightnessEnabled.checked,
            headlightChannel: digitalExtender.currentIndex,
            analogChannel: analogBrightnessChannel.currentIndex,
            globalMaxPercent: AppSettings.readGlobalBrightnessPercent()
        };
    }

    function buildChannelConfig(channel) {
        var ref = analogChannelRefs()[channel];
        if (!ref)
            return {};

        var config = {
            enabled: ref.enabled.checked,
            name: ref.name.text,
            linearPreset: ref.linearPreset.currentText,
            val0v: ref.val0Field.text,
            val5v: ref.val5Field.text
        };

        if (channel < 6) {
            config.ntcEnabled = ref.ntcToggle.checked;
            config.ntcPreset = ref.ntcPreset.currentText;
            config.divider100 = ref.divider100.checked;
            config.divider1k = ref.divider1k.checked;
            config.steinhartT = [ref.steinhartT[0].text, ref.steinhartT[1].text, ref.steinhartT[2].text];
            config.steinhartR = [ref.steinhartR[0].text, ref.steinhartR[1].text, ref.steinhartR[2].text];
        }

        return config;
    }

    function buildGearSensorConfig() {
        return {
            enabled: gearSensorEnabled.checked,
            port: gearSensorPort.currentIndex,
            tolerance: parseFloat(gearTolerance.text),
            voltageN: parseFloat(gearVoltageN.text),
            voltageR: parseFloat(gearVoltageR.text),
            voltage1: parseFloat(gearVoltage1.text),
            voltage2: parseFloat(gearVoltage2.text),
            voltage3: parseFloat(gearVoltage3.text),
            voltage4: parseFloat(gearVoltage4.text),
            voltage5: parseFloat(gearVoltage5.text),
            voltage6: parseFloat(gearVoltage6.text)
        };
    }

    function buildSpeedSensorConfig() {
        return {
            enabled: speedSensorEnabled.checked,
            sourceType: speedSourceType.currentIndex === 0 ? "analog" : "digital",
            analogPort: speedAnalogPort.currentIndex,
            digitalPort: speedDigitalPort.currentIndex,
            pulsesPerRev: parseFloat(speedPulsesPerRev.text),
            voltageMultiplier: parseFloat(speedVoltageMultiplier.text),
            tireCircumference: parseFloat(speedTireCircumference.text),
            finalDriveRatio: parseFloat(speedFinalDriveRatio.text),
            unit: speedUnit.currentIndex === 0 ? "MPH" : "KPH"
        };
    }

    function comboIndexForValue(options, value) {
        for (var i = 0; i < options.length; ++i) {
            if (String(options[i]) === String(value))
                return i;
        }
        return -1;
    }

    function digitalChannelItem(index) {
        return digitalNameRepeater.itemAt(index);
    }

    function loadAllSettingsFromManager() {
        var config = ExBoardConfig.loadAllSettings();

        loadingConfig = true;
        for (var channel = 0; channel < 8; ++channel)
            applyChannelConfig(channel, config.channels && config.channels[channel] ? config.channels[channel] : {});
        for (var i = 0; i < 8; ++i)
            applyDigitalChannelConfig(i, config.digitalChannels && config.digitalChannels[i] ? config.digitalChannels[i] :
                                                                                               {});
        applyBoardConfig(config.board || {});
        loadingConfig = false;

        inputs.setInputs();
    }

    function setComboSelection(combo, options, value) {
        var idx = comboIndexForValue(options, value);
        combo.currentIndex = idx >= 0 ? idx : 0;
    }

    function stringValue(value, fallback) {
        return value === undefined || value === null ? fallback : String(value);
    }

    Component.onCompleted: {
        loadAllSettingsFromManager();
    }

    ListModel {
        id: comboBoxModel

        ListElement {
            text: "Ex Digital Input 1"
        }

        ListElement {
            text: "Ex Digital Input 2"
        }

        ListElement {
            text: "Ex Digital Input 3"
        }

        ListElement {
            text: "Ex Digital Input 4"
        }

        ListElement {
            text: "Ex Digital Input 5"
        }

        ListElement {
            text: "Ex Digital Input 6"
        }

        ListElement {
            text: "Ex Digital Input 7"
        }

        ListElement {
            text: "Ex Digital Input 8"
        }
    }

    // Hidden NTC state checkboxes (driven by mode combos, consumed by writeEXBoardSettings)
    StyledCheckBox {
        id: checkan0ntc

        visible: false

        onCheckStateChanged: inputs.setInputs()
    }

    StyledCheckBox {
        id: checkan1ntc

        visible: false

        onCheckStateChanged: inputs.setInputs()
    }

    StyledCheckBox {
        id: checkan2ntc

        visible: false

        onCheckStateChanged: inputs.setInputs()
    }

    StyledCheckBox {
        id: checkan3ntc

        visible: false

        onCheckStateChanged: inputs.setInputs()
    }

    StyledCheckBox {
        id: checkan4ntc

        visible: false

        onCheckStateChanged: inputs.setInputs()
    }

    StyledCheckBox {
        id: checkan5ntc

        visible: false

        onCheckStateChanged: inputs.setInputs()
    }

    Item {
        id: inputs

        function setInputs() {
            if (loadingConfig)
                return;
            ExBoardConfig.saveAllSettings(buildAllSettings());
        }

        visible: false
    }

    Item {
        id: cylindercalcrpmdi1

        function cylindercalcrpmdi1() {
            inputs.setInputs();
        }

        visible: false
    }

    // =============================================================
    // SECTION 1: Unified Analog Channels
    // =============================================================
    SettingsSection {
        Layout.fillWidth: true
        title: "Analog Channels"

        ColumnLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            // Table header row
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.preferredHeight: 28
                Layout.rightMargin: SettingsTheme.sectionPadding
                spacing: 8

                Text {
                    Layout.preferredWidth: enableColW
                    text: ""
                }

                Text {
                    Layout.preferredWidth: nameColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "Name"
                }

                Text {
                    Layout.preferredWidth: modeColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "Mode"
                }

                Text {
                    Layout.preferredWidth: presetColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "Preset"
                }

                Text {
                    Layout.preferredWidth: fieldColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: anyNtcActive ? "T1 / V0" : "V0"
                }

                Text {
                    Layout.preferredWidth: fieldColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: anyNtcActive ? "R1 / V5" : "V5"
                }

                Text {
                    Layout.preferredWidth: fieldColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "T2"
                    visible: anyNtcActive
                }

                Text {
                    Layout.preferredWidth: fieldColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "R2"
                    visible: anyNtcActive
                }

                Text {
                    Layout.preferredWidth: fieldColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "T3"
                    visible: anyNtcActive
                }

                Text {
                    Layout.preferredWidth: fieldColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "R3"
                    visible: anyNtcActive
                }

                Text {
                    Layout.preferredWidth: divCheckColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    horizontalAlignment: Text.AlignHCenter
                    text: "100Ω"
                    visible: anyNtcActive
                }

                Text {
                    Layout.preferredWidth: divCheckColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    horizontalAlignment: Text.AlignHCenter
                    text: "1KΩ"
                    visible: anyNtcActive
                }

                Text {
                    Layout.preferredWidth: liveVColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "Live V"
                }

                Text {
                    Layout.preferredWidth: calibColW
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "Calibrated"
                }

                Text {
                    Layout.preferredWidth: statusColW
                    text: ""
                }
            }

            // ---- CH 0 (NTC capable) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable0.checked ? 1.0 : 0.4
                spacing: 8

                StyledSwitch {
                    id: chEnable0

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: enableColW

                    onCheckedChanged: inputs.setInputs()
                }

                StyledTextField {
                    id: chName0

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: nameColW
                    enabled: chEnable0.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 0"

                    onEditingFinished: inputs.setInputs()
                }

                StyledComboBox {
                    id: modeCombo0

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: modeColW
                    enabled: chEnable0.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["Linear", "NTC"]

                    onActivated: {
                        checkan0ntc.checked = (currentIndex === 1);
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: presetColW

                    StyledComboBox {
                        id: linPreset0

                        anchors.fill: parent
                        enabled: chEnable0.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        model: linearPresetNames
                        visible: !checkan0ntc.checked

                        onActivated: applyLinearPreset(0, currentText)
                    }

                    StyledComboBox {
                        id: ntcPreset0

                        anchors.fill: parent
                        enabled: chEnable0.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        model: ntcPresetNames
                        visible: checkan0ntc.checked

                        onActivated: applyNtcPreset(0, currentText)
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW

                    StyledTextField {
                        id: ex00

                        anchors.fill: parent
                        enabled: chEnable0.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "0"
                        visible: !checkan0ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }

                    StyledTextField {
                        id: t10

                        anchors.fill: parent
                        enabled: chEnable0.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan0ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW

                    StyledTextField {
                        id: ex05

                        anchors.fill: parent
                        enabled: chEnable0.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "5"
                        visible: !checkan0ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }

                    StyledTextField {
                        id: r10

                        anchors.fill: parent
                        enabled: chEnable0.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan0ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: t20

                        anchors.fill: parent
                        enabled: chEnable0.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan0ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: r20

                        anchors.fill: parent
                        enabled: chEnable0.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan0ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: t30

                        anchors.fill: parent
                        enabled: chEnable0.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan0ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: r30

                        anchors.fill: parent
                        enabled: chEnable0.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan0ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive

                    StyledCheckBox {
                        id: checkan0100

                        anchors.centerIn: parent
                        enabled: chEnable0.checked
                        visible: checkan0ntc.checked

                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive

                    StyledCheckBox {
                        id: checkan01k

                        anchors.centerIn: parent
                        enabled: chEnable0.checked
                        visible: checkan0ntc.checked

                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                Text {
                    Layout.preferredWidth: liveVColW
                    color: (Expander ? Expander.EXAnalogInput0 : 0) > 0.001 ? SettingsTheme.success :
                                                                              SettingsTheme.textDisabled
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: (Expander ? Expander.EXAnalogInput0 : 0).toFixed(3)
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: calibColW
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: checkan0ntc.checked ? "NTC" : (parseFloat(ex00.text) + ((Expander ? Expander.EXAnalogInput0 :
                                                                                              0) / 5.0) * (parseFloat(
                                                                                                               ex05.text)
                                                                                                           - parseFloat(
                                                                                                               ex00.text))).toFixed(
                                                    2)
                    verticalAlignment: Text.AlignVCenter
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: statusColW

                    Rectangle {
                        anchors.centerIn: parent
                        color: (Expander ? Expander.EXAnalogInput0 : 0) > 0.001 ? SettingsTheme.success :
                                                                                  SettingsTheme.textDisabled
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        width: SettingsTheme.statusDotSize
                    }
                }
            }

            // ---- CH 1 (NTC capable) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable1.checked ? 1.0 : 0.4
                spacing: 8

                StyledSwitch {
                    id: chEnable1

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: enableColW

                    onCheckedChanged: inputs.setInputs()
                }

                StyledTextField {
                    id: chName1

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: nameColW
                    enabled: chEnable1.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 1"

                    onEditingFinished: inputs.setInputs()
                }

                StyledComboBox {
                    id: modeCombo1

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: modeColW
                    enabled: chEnable1.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["Linear", "NTC"]

                    onActivated: {
                        checkan1ntc.checked = (currentIndex === 1);
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: presetColW

                    StyledComboBox {
                        id: linPreset1

                        anchors.fill: parent
                        enabled: chEnable1.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        model: linearPresetNames
                        visible: !checkan1ntc.checked

                        onActivated: applyLinearPreset(1, currentText)
                    }

                    StyledComboBox {
                        id: ntcPreset1

                        anchors.fill: parent
                        enabled: chEnable1.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        model: ntcPresetNames
                        visible: checkan1ntc.checked

                        onActivated: applyNtcPreset(1, currentText)
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW

                    StyledTextField {
                        id: ex10

                        anchors.fill: parent
                        enabled: chEnable1.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "0"
                        visible: !checkan1ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }

                    StyledTextField {
                        id: t11

                        anchors.fill: parent
                        enabled: chEnable1.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan1ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW

                    StyledTextField {
                        id: ex15

                        anchors.fill: parent
                        enabled: chEnable1.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "5"
                        visible: !checkan1ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }

                    StyledTextField {
                        id: r11

                        anchors.fill: parent
                        enabled: chEnable1.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan1ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: t21

                        anchors.fill: parent
                        enabled: chEnable1.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan1ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: r21

                        anchors.fill: parent
                        enabled: chEnable1.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan1ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: t31

                        anchors.fill: parent
                        enabled: chEnable1.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan1ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: r31

                        anchors.fill: parent
                        enabled: chEnable1.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan1ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive

                    StyledCheckBox {
                        id: checkan1100

                        anchors.centerIn: parent
                        enabled: chEnable1.checked
                        visible: checkan1ntc.checked

                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive

                    StyledCheckBox {
                        id: checkan11k

                        anchors.centerIn: parent
                        enabled: chEnable1.checked
                        visible: checkan1ntc.checked

                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                Text {
                    Layout.preferredWidth: liveVColW
                    color: (Expander ? Expander.EXAnalogInput1 : 0) > 0.001 ? SettingsTheme.success :
                                                                              SettingsTheme.textDisabled
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: (Expander ? Expander.EXAnalogInput1 : 0).toFixed(3)
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: calibColW
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: checkan1ntc.checked ? "NTC" : (parseFloat(ex10.text) + ((Expander ? Expander.EXAnalogInput1 :
                                                                                              0) / 5.0) * (parseFloat(
                                                                                                               ex15.text)
                                                                                                           - parseFloat(
                                                                                                               ex10.text))).toFixed(
                                                    2)
                    verticalAlignment: Text.AlignVCenter
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: statusColW

                    Rectangle {
                        anchors.centerIn: parent
                        color: (Expander ? Expander.EXAnalogInput1 : 0) > 0.001 ? SettingsTheme.success :
                                                                                  SettingsTheme.textDisabled
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        width: SettingsTheme.statusDotSize
                    }
                }
            }

            // ---- CH 2 (NTC capable) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable2.checked ? 1.0 : 0.4
                spacing: 8

                StyledSwitch {
                    id: chEnable2

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: enableColW

                    onCheckedChanged: inputs.setInputs()
                }

                StyledTextField {
                    id: chName2

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: nameColW
                    enabled: chEnable2.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 2"

                    onEditingFinished: inputs.setInputs()
                }

                StyledComboBox {
                    id: modeCombo2

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: modeColW
                    enabled: chEnable2.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["Linear", "NTC"]

                    onActivated: {
                        checkan2ntc.checked = (currentIndex === 1);
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: presetColW

                    StyledComboBox {
                        id: linPreset2

                        anchors.fill: parent
                        enabled: chEnable2.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        model: linearPresetNames
                        visible: !checkan2ntc.checked

                        onActivated: applyLinearPreset(2, currentText)
                    }

                    StyledComboBox {
                        id: ntcPreset2

                        anchors.fill: parent
                        enabled: chEnable2.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        model: ntcPresetNames
                        visible: checkan2ntc.checked

                        onActivated: applyNtcPreset(2, currentText)
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW

                    StyledTextField {
                        id: ex20

                        anchors.fill: parent
                        enabled: chEnable2.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "0"
                        visible: !checkan2ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }

                    StyledTextField {
                        id: t12

                        anchors.fill: parent
                        enabled: chEnable2.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan2ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW

                    StyledTextField {
                        id: ex25

                        anchors.fill: parent
                        enabled: chEnable2.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "5"
                        visible: !checkan2ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }

                    StyledTextField {
                        id: r12

                        anchors.fill: parent
                        enabled: chEnable2.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan2ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: t22

                        anchors.fill: parent
                        enabled: chEnable2.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan2ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: r22

                        anchors.fill: parent
                        enabled: chEnable2.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan2ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: t32

                        anchors.fill: parent
                        enabled: chEnable2.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan2ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: r32

                        anchors.fill: parent
                        enabled: chEnable2.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan2ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive

                    StyledCheckBox {
                        id: checkan2100

                        anchors.centerIn: parent
                        enabled: chEnable2.checked
                        visible: checkan2ntc.checked

                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive

                    StyledCheckBox {
                        id: checkan21k

                        anchors.centerIn: parent
                        enabled: chEnable2.checked
                        visible: checkan2ntc.checked

                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                Text {
                    Layout.preferredWidth: liveVColW
                    color: (Expander ? Expander.EXAnalogInput2 : 0) > 0.001 ? SettingsTheme.success :
                                                                              SettingsTheme.textDisabled
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: (Expander ? Expander.EXAnalogInput2 : 0).toFixed(3)
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: calibColW
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: checkan2ntc.checked ? "NTC" : (parseFloat(ex20.text) + ((Expander ? Expander.EXAnalogInput2 :
                                                                                              0) / 5.0) * (parseFloat(
                                                                                                               ex25.text)
                                                                                                           - parseFloat(
                                                                                                               ex20.text))).toFixed(
                                                    2)
                    verticalAlignment: Text.AlignVCenter
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: statusColW

                    Rectangle {
                        anchors.centerIn: parent
                        color: (Expander ? Expander.EXAnalogInput2 : 0) > 0.001 ? SettingsTheme.success :
                                                                                  SettingsTheme.textDisabled
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        width: SettingsTheme.statusDotSize
                    }
                }
            }

            // ---- CH 3 (NTC capable) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable3.checked ? 1.0 : 0.4
                spacing: 8

                StyledSwitch {
                    id: chEnable3

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: enableColW

                    onCheckedChanged: inputs.setInputs()
                }

                StyledTextField {
                    id: chName3

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: nameColW
                    enabled: chEnable3.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 3"

                    onEditingFinished: inputs.setInputs()
                }

                StyledComboBox {
                    id: modeCombo3

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: modeColW
                    enabled: chEnable3.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["Linear", "NTC"]

                    onActivated: {
                        checkan3ntc.checked = (currentIndex === 1);
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: presetColW

                    StyledComboBox {
                        id: linPreset3

                        anchors.fill: parent
                        enabled: chEnable3.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        model: linearPresetNames
                        visible: !checkan3ntc.checked

                        onActivated: applyLinearPreset(3, currentText)
                    }

                    StyledComboBox {
                        id: ntcPreset3

                        anchors.fill: parent
                        enabled: chEnable3.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        model: ntcPresetNames
                        visible: checkan3ntc.checked

                        onActivated: applyNtcPreset(3, currentText)
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW

                    StyledTextField {
                        id: ex30

                        anchors.fill: parent
                        enabled: chEnable3.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "0"
                        visible: !checkan3ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }

                    StyledTextField {
                        id: t13

                        anchors.fill: parent
                        enabled: chEnable3.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan3ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW

                    StyledTextField {
                        id: ex35

                        anchors.fill: parent
                        enabled: chEnable3.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "5"
                        visible: !checkan3ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }

                    StyledTextField {
                        id: r13

                        anchors.fill: parent
                        enabled: chEnable3.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan3ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: t23

                        anchors.fill: parent
                        enabled: chEnable3.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan3ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: r23

                        anchors.fill: parent
                        enabled: chEnable3.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan3ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: t33

                        anchors.fill: parent
                        enabled: chEnable3.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan3ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: r33

                        anchors.fill: parent
                        enabled: chEnable3.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan3ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive

                    StyledCheckBox {
                        id: checkan3100

                        anchors.centerIn: parent
                        enabled: chEnable3.checked
                        visible: checkan3ntc.checked

                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive

                    StyledCheckBox {
                        id: checkan31k

                        anchors.centerIn: parent
                        enabled: chEnable3.checked
                        visible: checkan3ntc.checked

                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                Text {
                    Layout.preferredWidth: liveVColW
                    color: (Expander ? Expander.EXAnalogInput3 : 0) > 0.001 ? SettingsTheme.success :
                                                                              SettingsTheme.textDisabled
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: (Expander ? Expander.EXAnalogInput3 : 0).toFixed(3)
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: calibColW
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: checkan3ntc.checked ? "NTC" : (parseFloat(ex30.text) + ((Expander ? Expander.EXAnalogInput3 :
                                                                                              0) / 5.0) * (parseFloat(
                                                                                                               ex35.text)
                                                                                                           - parseFloat(
                                                                                                               ex30.text))).toFixed(
                                                    2)
                    verticalAlignment: Text.AlignVCenter
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: statusColW

                    Rectangle {
                        anchors.centerIn: parent
                        color: (Expander ? Expander.EXAnalogInput3 : 0) > 0.001 ? SettingsTheme.success :
                                                                                  SettingsTheme.textDisabled
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        width: SettingsTheme.statusDotSize
                    }
                }
            }

            // ---- CH 4 (NTC capable) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable4.checked ? 1.0 : 0.4
                spacing: 8

                StyledSwitch {
                    id: chEnable4

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: enableColW

                    onCheckedChanged: inputs.setInputs()
                }

                StyledTextField {
                    id: chName4

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: nameColW
                    enabled: chEnable4.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 4"

                    onEditingFinished: inputs.setInputs()
                }

                StyledComboBox {
                    id: modeCombo4

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: modeColW
                    enabled: chEnable4.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["Linear", "NTC"]

                    onActivated: {
                        checkan4ntc.checked = (currentIndex === 1);
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: presetColW

                    StyledComboBox {
                        id: linPreset4

                        anchors.fill: parent
                        enabled: chEnable4.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        model: linearPresetNames
                        visible: !checkan4ntc.checked

                        onActivated: applyLinearPreset(4, currentText)
                    }

                    StyledComboBox {
                        id: ntcPreset4

                        anchors.fill: parent
                        enabled: chEnable4.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        model: ntcPresetNames
                        visible: checkan4ntc.checked

                        onActivated: applyNtcPreset(4, currentText)
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW

                    StyledTextField {
                        id: ex40

                        anchors.fill: parent
                        enabled: chEnable4.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "0"
                        visible: !checkan4ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }

                    StyledTextField {
                        id: t14

                        anchors.fill: parent
                        enabled: chEnable4.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan4ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW

                    StyledTextField {
                        id: ex45

                        anchors.fill: parent
                        enabled: chEnable4.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "5"
                        visible: !checkan4ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }

                    StyledTextField {
                        id: r14

                        anchors.fill: parent
                        enabled: chEnable4.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan4ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: t24

                        anchors.fill: parent
                        enabled: chEnable4.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan4ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: r24

                        anchors.fill: parent
                        enabled: chEnable4.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan4ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: t34

                        anchors.fill: parent
                        enabled: chEnable4.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan4ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: r34

                        anchors.fill: parent
                        enabled: chEnable4.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan4ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive

                    StyledCheckBox {
                        id: checkan4100

                        anchors.centerIn: parent
                        enabled: chEnable4.checked
                        visible: checkan4ntc.checked

                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive

                    StyledCheckBox {
                        id: checkan41k

                        anchors.centerIn: parent
                        enabled: chEnable4.checked
                        visible: checkan4ntc.checked

                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                Text {
                    Layout.preferredWidth: liveVColW
                    color: (Expander ? Expander.EXAnalogInput4 : 0) > 0.001 ? SettingsTheme.success :
                                                                              SettingsTheme.textDisabled
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: (Expander ? Expander.EXAnalogInput4 : 0).toFixed(3)
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: calibColW
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: checkan4ntc.checked ? "NTC" : (parseFloat(ex40.text) + ((Expander ? Expander.EXAnalogInput4 :
                                                                                              0) / 5.0) * (parseFloat(
                                                                                                               ex45.text)
                                                                                                           - parseFloat(
                                                                                                               ex40.text))).toFixed(
                                                    2)
                    verticalAlignment: Text.AlignVCenter
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: statusColW

                    Rectangle {
                        anchors.centerIn: parent
                        color: (Expander ? Expander.EXAnalogInput4 : 0) > 0.001 ? SettingsTheme.success :
                                                                                  SettingsTheme.textDisabled
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        width: SettingsTheme.statusDotSize
                    }
                }
            }

            // ---- CH 5 (NTC capable) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable5.checked ? 1.0 : 0.4
                spacing: 8

                StyledSwitch {
                    id: chEnable5

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: enableColW

                    onCheckedChanged: inputs.setInputs()
                }

                StyledTextField {
                    id: chName5

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: nameColW
                    enabled: chEnable5.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 5"

                    onEditingFinished: inputs.setInputs()
                }

                StyledComboBox {
                    id: modeCombo5

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: modeColW
                    enabled: chEnable5.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["Linear", "NTC"]

                    onActivated: {
                        checkan5ntc.checked = (currentIndex === 1);
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: presetColW

                    StyledComboBox {
                        id: linPreset5

                        anchors.fill: parent
                        enabled: chEnable5.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        model: linearPresetNames
                        visible: !checkan5ntc.checked

                        onActivated: applyLinearPreset(5, currentText)
                    }

                    StyledComboBox {
                        id: ntcPreset5

                        anchors.fill: parent
                        enabled: chEnable5.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        model: ntcPresetNames
                        visible: checkan5ntc.checked

                        onActivated: applyNtcPreset(5, currentText)
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW

                    StyledTextField {
                        id: ex50

                        anchors.fill: parent
                        enabled: chEnable5.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "0"
                        visible: !checkan5ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }

                    StyledTextField {
                        id: t15

                        anchors.fill: parent
                        enabled: chEnable5.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan5ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW

                    StyledTextField {
                        id: ex55

                        anchors.fill: parent
                        enabled: chEnable5.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "5"
                        visible: !checkan5ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }

                    StyledTextField {
                        id: r15

                        anchors.fill: parent
                        enabled: chEnable5.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan5ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: t25

                        anchors.fill: parent
                        enabled: chEnable5.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan5ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: r25

                        anchors.fill: parent
                        enabled: chEnable5.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan5ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: t35

                        anchors.fill: parent
                        enabled: chEnable5.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan5ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive

                    StyledTextField {
                        id: r35

                        anchors.fill: parent
                        enabled: chEnable5.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan5ntc.checked

                        onEditingFinished: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive

                    StyledCheckBox {
                        id: checkan5100

                        anchors.centerIn: parent
                        enabled: chEnable5.checked
                        visible: checkan5ntc.checked

                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive

                    StyledCheckBox {
                        id: checkan51k

                        anchors.centerIn: parent
                        enabled: chEnable5.checked
                        visible: checkan5ntc.checked

                        onCheckStateChanged: inputs.setInputs()
                    }
                }

                Text {
                    Layout.preferredWidth: liveVColW
                    color: (Expander ? Expander.EXAnalogInput5 : 0) > 0.001 ? SettingsTheme.success :
                                                                              SettingsTheme.textDisabled
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: (Expander ? Expander.EXAnalogInput5 : 0).toFixed(3)
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: calibColW
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: checkan5ntc.checked ? "NTC" : (parseFloat(ex50.text) + ((Expander ? Expander.EXAnalogInput5 :
                                                                                              0) / 5.0) * (parseFloat(
                                                                                                               ex55.text)
                                                                                                           - parseFloat(
                                                                                                               ex50.text))).toFixed(
                                                    2)
                    verticalAlignment: Text.AlignVCenter
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: statusColW

                    Rectangle {
                        anchors.centerIn: parent
                        color: (Expander ? Expander.EXAnalogInput5 : 0) > 0.001 ? SettingsTheme.success :
                                                                                  SettingsTheme.textDisabled
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        width: SettingsTheme.statusDotSize
                    }
                }
            }

            // ---- CH 6 (Linear only, no NTC) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable6.checked ? 1.0 : 0.4
                spacing: 8

                StyledSwitch {
                    id: chEnable6

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: enableColW

                    onCheckedChanged: inputs.setInputs()
                }

                StyledTextField {
                    id: chName6

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: nameColW
                    enabled: chEnable6.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 6"

                    onEditingFinished: inputs.setInputs()
                }

                Text {
                    Layout.preferredWidth: modeColW
                    color: SettingsTheme.textPlaceholder
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "Linear"
                    verticalAlignment: Text.AlignVCenter
                }

                StyledComboBox {
                    id: linPreset6

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: presetColW
                    enabled: chEnable6.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    model: linearPresetNames

                    onActivated: applyLinearPreset(6, currentText)
                }

                StyledTextField {
                    id: ex60

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    enabled: chEnable6.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "0"

                    onEditingFinished: inputs.setInputs()
                }

                StyledTextField {
                    id: ex65

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    enabled: chEnable6.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "5"

                    onEditingFinished: inputs.setInputs()
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive
                }

                Text {
                    Layout.preferredWidth: liveVColW
                    color: (Expander ? Expander.EXAnalogInput6 : 0) > 0.001 ? SettingsTheme.success :
                                                                              SettingsTheme.textDisabled
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: (Expander ? Expander.EXAnalogInput6 : 0).toFixed(3)
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: calibColW
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: (parseFloat(ex60.text) + ((Expander ? Expander.EXAnalogInput6 : 0) / 5.0) * (parseFloat(
                                                                                                           ex65.text)
                                                                                                       - parseFloat(
                                                                                                           ex60.text))).toFixed(
                              2)
                    verticalAlignment: Text.AlignVCenter
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: statusColW

                    Rectangle {
                        anchors.centerIn: parent
                        color: (Expander ? Expander.EXAnalogInput6 : 0) > 0.001 ? SettingsTheme.success :
                                                                                  SettingsTheme.textDisabled
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        width: SettingsTheme.statusDotSize
                    }
                }
            }

            // ---- CH 7 (Linear only, no NTC) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable7.checked ? 1.0 : 0.4
                spacing: 8

                StyledSwitch {
                    id: chEnable7

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: enableColW

                    onCheckedChanged: inputs.setInputs()
                }

                StyledTextField {
                    id: chName7

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: nameColW
                    enabled: chEnable7.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 7"

                    onEditingFinished: inputs.setInputs()
                }

                Text {
                    Layout.preferredWidth: modeColW
                    color: SettingsTheme.textPlaceholder
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "Linear"
                    verticalAlignment: Text.AlignVCenter
                }

                StyledComboBox {
                    id: linPreset7

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: presetColW
                    enabled: chEnable7.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    model: linearPresetNames

                    onActivated: applyLinearPreset(7, currentText)
                }

                StyledTextField {
                    id: ex70

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    enabled: chEnable7.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "0"

                    onEditingFinished: inputs.setInputs()
                }

                StyledTextField {
                    id: ex75

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    enabled: chEnable7.checked
                    font.pixelSize: SettingsTheme.fontStatus
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "5"

                    onEditingFinished: inputs.setInputs()
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: fieldColW
                    visible: anyNtcActive
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: divCheckColW
                    visible: anyNtcActive
                }

                Text {
                    Layout.preferredWidth: liveVColW
                    color: (Expander ? Expander.EXAnalogInput7 : 0) > 0.001 ? SettingsTheme.success :
                                                                              SettingsTheme.textDisabled
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: (Expander ? Expander.EXAnalogInput7 : 0).toFixed(3)
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: calibColW
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: (parseFloat(ex70.text) + ((Expander ? Expander.EXAnalogInput7 : 0) / 5.0) * (parseFloat(
                                                                                                           ex75.text)
                                                                                                       - parseFloat(
                                                                                                           ex70.text))).toFixed(
                              2)
                    verticalAlignment: Text.AlignVCenter
                }

                Item {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: statusColW

                    Rectangle {
                        anchors.centerIn: parent
                        color: (Expander ? Expander.EXAnalogInput7 : 0) > 0.001 ? SettingsTheme.success :
                                                                                  SettingsTheme.textDisabled
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        width: SettingsTheme.statusDotSize
                    }
                }
            }
        }
    }

    // =============================================================
    // SECTION 2: Board Configuration
    // =============================================================
    SettingsSection {
        Layout.fillWidth: true
        title: "Board Configuration"

        ColumnLayout {

            // Compact label width for this section (override default 180px)
            readonly property int boardConfigLabelW: 140

            Layout.fillWidth: true
            spacing: SettingsTheme.sectionPadding

            SettingsRow {
                label: "AN7 Damping"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledTextField {
                    id: an7dampingfactor

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 80
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "0"

                    validator: RegularExpressionValidator {
                        regularExpression: /^(?:[1-9]\d{0,2}|1000)$/
                    }

                    onEditingFinished: inputs.setInputs()
                }
            }

            SettingsRow {
                label: "RPM Source"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledComboBox {
                    id: rpmsourceselector

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    model: ["None", "CAN RPM", "EX Digital 1 Tach"]

                    onActivated: inputs.setInputs()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.sectionPadding
                visible: rpmsourceselector.currentIndex === 1

                Text {
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    text: Translator.translate("Version", Settings.language) + ":"
                    verticalAlignment: Text.AlignVCenter
                }

                StyledComboBox {
                    id: rpmcanversionselector

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 80
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["V1", "V2"]

                    onActivated: inputs.setInputs()
                }

                Text {
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    text: Translator.translate("Cylinders", Settings.language) + ":"
                    verticalAlignment: Text.AlignVCenter
                }

                StyledComboBox {
                    id: cylindercombobox

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 90
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["0.5", "0.6", "0.7", "0.8", "0.9", "1", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7",
                        "1.8", "1.9", "2", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "2.9", "3", "3.1",
                        "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9", "4", "4.1", "4.2", "4.3", "4.4", "4.5",
                        "4.6", "4.7", "4.8", "4.9", "5", "5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "5.8", "5.9", "6",
                        "6.1", "6.2", "6.3", "6.4", "6.5", "6.6", "6.7", "6.8", "6.9", "7", "7.1", "7.2", "7.3", "7.4",
                        "7.5", "7.6", "7.7", "7.8", "7.9", "8", "8.1", "8.2", "8.3", "8.4", "8.5", "8.6", "8.7", "8.8",
                        "8.9", "9", "9.1", "9.2", "9.3", "9.4", "9.5", "9.6", "9.7", "9.8", "9.9", "10", "10.1", "10.2",
                        "10.3", "10.4", "10.5", "10.6", "10.7", "10.8", "10.9", "11", "11.1", "11.2", "11.3", "11.4",
                        "11.5", "11.6", "11.7", "11.8", "11.9", "12", "12.1", "12.2", "12.3", "12.4", "12.5", "12.6",
                        "12.7", "12.8", "12.9"]
                    visible: rpmcanversionselector.currentIndex == 0

                    onActivated: inputs.setInputs()
                }

                StyledComboBox {
                    id: cylindercomboboxv2

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 90
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["1", "2", "3", "4", "5", "6", "8", "12"]
                    visible: rpmcanversionselector.currentIndex == 1

                    onActivated: inputs.setInputs()
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.sectionPadding
                visible: rpmsourceselector.currentIndex === 2

                Text {
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    text: Translator.translate("Cylinders", Settings.language) + ":"
                    verticalAlignment: Text.AlignVCenter
                }

                StyledComboBox {
                    id: cylindercomboboxDi1

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 90
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["1", "2", "3", "4", "5", "6", "8", "12"]

                    onActivated: cylindercalcrpmdi1.cylindercalcrpmdi1()
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            SettingsRow {
                description: "Future runtime source toggle"
                label: "On-Screen Brightness"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledSwitch {
                    id: brightnessManualEnabled

                    Layout.preferredWidth: 100
                    text: checked ? "On" : "Off"

                    onCheckedChanged: inputs.setInputs()
                }
            }

            SettingsRow {
                description: "Future runtime source toggle"
                label: "Discrete Brightness Source"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledSwitch {
                    id: discreteBrightnessEnabled

                    Layout.preferredWidth: 100
                    text: checked ? "On" : "Off"

                    onCheckedChanged: inputs.setInputs()
                }
            }

            SettingsRow {
                description: "Future runtime source toggle"
                label: "CAN/IO Brightness Source"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledSwitch {
                    id: canIoBrightnessEnabled

                    Layout.preferredWidth: 100
                    text: checked ? "On" : "Off"

                    onCheckedChanged: inputs.setInputs()
                }
            }

            SettingsRow {
                description: "Future runtime source toggle"
                label: "Analog Brightness Source"

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledSwitch {
                    id: analogBrightnessEnabled

                    Layout.preferredWidth: 100
                    text: checked ? "On" : "Off"

                    onCheckedChanged: inputs.setInputs()
                }
            }

            SettingsRow {
                label: "Headlight Channel"
                visible: discreteBrightnessEnabled.checked || canIoBrightnessEnabled.checked

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledComboBox {
                    id: digitalExtender

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 200
                    model: comboBoxModel
                    textRole: "text"
                }
            }

            SettingsRow {
                label: "Analog Brightness Channel"
                visible: analogBrightnessEnabled.checked

                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledComboBox {
                    id: analogBrightnessChannel

                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 200
                    model: analogChannelModel
                }
            }
        }
    }

    // =============================================================
    // SECTION 3: Digital Inputs
    // =============================================================
    SettingsSection {
        Layout.fillWidth: true
        title: "Digital Inputs"

        ColumnLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            // Digital header row
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.preferredHeight: 28
                Layout.rightMargin: SettingsTheme.sectionPadding
                spacing: 8

                Text {
                    Layout.preferredWidth: enableColW
                    text: ""
                }

                Text {
                    Layout.preferredWidth: 200
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "Name"
                }

                Text {
                    Layout.preferredWidth: 120
                    color: SettingsTheme.textSecondary
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "Channel"
                }
            }

            Repeater {
                id: digitalNameRepeater

                model: 8

                RowLayout {
                    property alias enableSwitch: diEnableSwitch
                    property alias nameField: digiNameField

                    Layout.fillWidth: true
                    Layout.leftMargin: SettingsTheme.sectionPadding
                    Layout.preferredHeight: SettingsTheme.controlHeight + 2
                    Layout.rightMargin: SettingsTheme.sectionPadding
                    opacity: diEnableSwitch.checked ? 1.0 : 0.4
                    spacing: 8

                    StyledSwitch {
                        id: diEnableSwitch

                        Layout.preferredHeight: SettingsTheme.controlHeight
                        Layout.preferredWidth: enableColW
                        checked: true

                        onCheckedChanged: inputs.setInputs()
                    }

                    StyledTextField {
                        id: digiNameField

                        Layout.preferredHeight: SettingsTheme.controlHeight
                        Layout.preferredWidth: 200
                        enabled: diEnableSwitch.checked
                        font.pixelSize: SettingsTheme.fontStatus
                        placeholderText: "DI " + (index + 1)

                        onEditingFinished: inputs.setInputs()
                    }

                    Text {
                        Layout.preferredWidth: 120
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "EX Digi " + (index + 1)
                        verticalAlignment: Text.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    // =============================================================
    // SECTION 4: Gear Position Sensor
    // =============================================================
    SettingsSection {
        Layout.fillWidth: true
        title: "Gear Position Sensor"

        SettingsRow {
            label: "Enable"

            StyledSwitch {
                id: gearSensorEnabled

                checked: false
            }
        }

        SettingsRow {
            label: "Analog Port"
            visible: gearSensorEnabled.checked

            StyledComboBox {
                id: gearSensorPort

                model: ["EX Analog 0", "EX Analog 1", "EX Analog 2", "EX Analog 3", "EX Analog 4", "EX Analog 5",
                    "EX Analog 6", "EX Analog 7"]
            }
        }

        SettingsRow {
            label: "Tolerance (V)"
            visible: gearSensorEnabled.checked

            StyledTextField {
                id: gearTolerance

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "0.2"
            }
        }

        SettingsRow {
            label: "Neutral"
            visible: gearSensorEnabled.checked

            StyledTextField {
                id: gearVoltageN

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "0.0"
            }
        }

        SettingsRow {
            label: "Reverse"
            visible: gearSensorEnabled.checked

            StyledTextField {
                id: gearVoltageR

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "0.5"
            }
        }

        SettingsRow {
            label: "1st Gear"
            visible: gearSensorEnabled.checked

            StyledTextField {
                id: gearVoltage1

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "1.0"
            }
        }

        SettingsRow {
            label: "2nd Gear"
            visible: gearSensorEnabled.checked

            StyledTextField {
                id: gearVoltage2

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "1.5"
            }
        }

        SettingsRow {
            label: "3rd Gear"
            visible: gearSensorEnabled.checked

            StyledTextField {
                id: gearVoltage3

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "2.0"
            }
        }

        SettingsRow {
            label: "4th Gear"
            visible: gearSensorEnabled.checked

            StyledTextField {
                id: gearVoltage4

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "2.5"
            }
        }

        SettingsRow {
            label: "5th Gear"
            visible: gearSensorEnabled.checked

            StyledTextField {
                id: gearVoltage5

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "3.0"
            }
        }

        SettingsRow {
            label: "6th Gear"
            visible: gearSensorEnabled.checked

            StyledTextField {
                id: gearVoltage6

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "3.5"
            }
        }

        SettingsRow {
            label: "Current"
            visible: gearSensorEnabled.checked

            Text {
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamilyMono
                font.pixelSize: SettingsTheme.fontControl
                text: {
                    var idx = gearSensorPort.currentIndex;
                    var raw = 0;
                    if (Expander) {
                        if (idx === 0)
                            raw = Expander.EXAnalogInput0;
                        else if (idx === 1)
                            raw = Expander.EXAnalogInput1;
                        else if (idx === 2)
                            raw = Expander.EXAnalogInput2;
                        else if (idx === 3)
                            raw = Expander.EXAnalogInput3;
                        else if (idx === 4)
                            raw = Expander.EXAnalogInput4;
                        else if (idx === 5)
                            raw = Expander.EXAnalogInput5;
                        else if (idx === 6)
                            raw = Expander.EXAnalogInput6;
                        else if (idx === 7)
                            raw = Expander.EXAnalogInput7;
                    }
                    var gear = Expander ? Expander.EXGear : -2;
                    var gearStr = gear === -2 ? "?" : gear === -1 ? "R" : gear === 0 ? "N" : String(gear);
                    return raw.toFixed(3) + " V -> Gear " + gearStr;
                }
            }
        }

        StyledButton {
            Layout.alignment: Qt.AlignRight
            text: "Save Gear Config"
            visible: gearSensorEnabled.checked

            onClicked: ExBoardConfig.saveAllSettings(buildAllSettings())
        }
    }

    // =============================================================
    // SECTION 5: Speed Sensor
    // =============================================================
    SettingsSection {
        Layout.fillWidth: true
        title: "Speed Sensor"

        SettingsRow {
            label: "Enable"

            StyledSwitch {
                id: speedSensorEnabled

                checked: false
            }
        }

        SettingsRow {
            label: "Source Type"
            visible: speedSensorEnabled.checked

            StyledComboBox {
                id: speedSourceType

                model: ["Analog", "Digital"]
            }
        }

        SettingsRow {
            label: "Analog Port"
            visible: speedSensorEnabled.checked && speedSourceType.currentIndex === 0

            StyledComboBox {
                id: speedAnalogPort

                model: ["EX Analog 0", "EX Analog 1", "EX Analog 2", "EX Analog 3", "EX Analog 4", "EX Analog 5",
                    "EX Analog 6", "EX Analog 7"]
            }
        }

        SettingsRow {
            label: "Digital Port"
            visible: speedSensorEnabled.checked && speedSourceType.currentIndex === 1

            StyledComboBox {
                id: speedDigitalPort

                model: ["EX Digital 1", "EX Digital 2", "EX Digital 3", "EX Digital 4", "EX Digital 5", "EX Digital 6",
                    "EX Digital 7", "EX Digital 8"]
            }
        }

        SettingsRow {
            label: "Pulses/Rev"
            visible: speedSensorEnabled.checked && speedSourceType.currentIndex === 1

            StyledTextField {
                id: speedPulsesPerRev

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "4.0"
            }
        }

        SettingsRow {
            label: "Voltage Multiplier"
            visible: speedSensorEnabled.checked && speedSourceType.currentIndex === 0

            StyledTextField {
                id: speedVoltageMultiplier

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "1.0"
            }
        }

        SettingsRow {
            label: "Tire Circumference (m)"
            visible: speedSensorEnabled.checked

            StyledTextField {
                id: speedTireCircumference

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "2.06"
            }
        }

        SettingsRow {
            label: "Final Drive Ratio"
            visible: speedSensorEnabled.checked

            StyledTextField {
                id: speedFinalDriveRatio

                Layout.preferredWidth: 100
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: "1.0"
            }
        }

        SettingsRow {
            label: "Unit"
            visible: speedSensorEnabled.checked

            StyledComboBox {
                id: speedUnit

                model: ["MPH", "KPH"]
            }
        }

        SettingsRow {
            label: "Current Speed"
            visible: speedSensorEnabled.checked

            Text {
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamilyMono
                font.pixelSize: SettingsTheme.fontControl
                text: (Expander ? Expander.EXSpeed : 0).toFixed(1) + " " + (speedUnit.currentIndex === 0 ? "MPH" :
                                                                                                           "KPH")
            }
        }

        StyledButton {
            Layout.alignment: Qt.AlignRight
            text: "Save Speed Config"
            visible: speedSensorEnabled.checked

            onClicked: ExBoardConfig.saveAllSettings(buildAllSettings())
        }
    }
}
