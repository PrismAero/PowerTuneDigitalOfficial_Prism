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
    property int digiValue
    property string digiStringValue
    property int maxBrightnessOnBoot
    property bool loadingConfig: false
    property int rpmCheckboxSaveValue: 0

    // Unified analog table column widths
    readonly property int enableColW: 65
    readonly property int nameColW: 120
    readonly property int modeColW: 120
    readonly property int presetColW: 210
    readonly property int fieldColW: 65
    readonly property int divCheckColW: 45
    readonly property int liveVColW: 75
    readonly property int calibColW: 90
    readonly property int statusColW: 28

    // True when any NTC-capable channel is in NTC mode; shows extra calibration columns
    readonly property bool anyNtcActive: checkan0ntc.checked || checkan1ntc.checked || checkan2ntc.checked || checkan3ntc.checked || checkan4ntc.checked || checkan5ntc.checked

    property var linearPresetNames: {
        var presets = Calibration.linearPresets();
        var names = ["Custom"];
        for (var i = 0; i < presets.length; i++) {
            names.push(presets[i].name);
        }
        return names;
    }

    property var ntcPresetNames: {
        var presets = Calibration.ntcPresets();
        var names = ["Custom"];
        for (var i = 0; i < presets.length; i++) {
            names.push(presets[i].name);
        }
        return names;
    }

    function analogChannelRefs() {
        return [
            { enabled: chEnable0, name: chName0, modeCombo: modeCombo0, linearPreset: linPreset0, ntcPreset: ntcPreset0,
              val0Field: ex00, val5Field: ex05, ntcToggle: checkan0ntc, divider100: checkan0100, divider1k: checkan01k,
              steinhartT: [t10, t20, t30], steinhartR: [r10, r20, r30] },
            { enabled: chEnable1, name: chName1, modeCombo: modeCombo1, linearPreset: linPreset1, ntcPreset: ntcPreset1,
              val0Field: ex10, val5Field: ex15, ntcToggle: checkan1ntc, divider100: checkan1100, divider1k: checkan11k,
              steinhartT: [t11, t21, t31], steinhartR: [r11, r21, r31] },
            { enabled: chEnable2, name: chName2, modeCombo: modeCombo2, linearPreset: linPreset2, ntcPreset: ntcPreset2,
              val0Field: ex20, val5Field: ex25, ntcToggle: checkan2ntc, divider100: checkan2100, divider1k: checkan21k,
              steinhartT: [t12, t22, t32], steinhartR: [r12, r22, r32] },
            { enabled: chEnable3, name: chName3, modeCombo: modeCombo3, linearPreset: linPreset3, ntcPreset: ntcPreset3,
              val0Field: ex30, val5Field: ex35, ntcToggle: checkan3ntc, divider100: checkan3100, divider1k: checkan31k,
              steinhartT: [t13, t23, t33], steinhartR: [r13, r23, r33] },
            { enabled: chEnable4, name: chName4, modeCombo: modeCombo4, linearPreset: linPreset4, ntcPreset: ntcPreset4,
              val0Field: ex40, val5Field: ex45, ntcToggle: checkan4ntc, divider100: checkan4100, divider1k: checkan41k,
              steinhartT: [t14, t24, t34], steinhartR: [r14, r24, r34] },
            { enabled: chEnable5, name: chName5, modeCombo: modeCombo5, linearPreset: linPreset5, ntcPreset: ntcPreset5,
              val0Field: ex50, val5Field: ex55, ntcToggle: checkan5ntc, divider100: checkan5100, divider1k: checkan51k,
              steinhartT: [t15, t25, t35], steinhartR: [r15, r25, r35] },
            { enabled: chEnable6, name: chName6, linearPreset: linPreset6, val0Field: ex60, val5Field: ex65 },
            { enabled: chEnable7, name: chName7, linearPreset: linPreset7, val0Field: ex70, val5Field: ex75 }
        ];
    }

    function digitalChannelItem(index) {
        return digitalNameRepeater.itemAt(index);
    }

    function comboIndexForValue(options, value) {
        for (var i = 0; i < options.length; ++i) {
            if (String(options[i]) === String(value))
                return i;
        }
        return -1;
    }

    function setComboSelection(combo, options, value) {
        var idx = comboIndexForValue(options, value);
        combo.currentIndex = idx >= 0 ? idx : 0;
    }

    function stringValue(value, fallback) {
        return value === undefined || value === null ? fallback : String(value);
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

    function buildBoardConfig() {
        return {
            selectedValue: digitalExtender.currentIndex,
            switchValue: maxBrightnessBoot.checked,
            rpmSource: rpmsourceselector.currentIndex,
            rpmCanVersion: rpmcanversionselector.currentIndex,
            cylinderCombobox: cylindercombobox.currentIndex,
            cylinderComboboxValue: parseFloat(cylindercombobox.currentText),
            cylinderComboboxV2: cylindercomboboxv2.currentIndex,
            cylinderComboboxV2Value: parseFloat(cylindercomboboxv2.currentText),
            cylinderComboboxDi1: cylindercomboboxDi1.currentIndex,
            rpmcheckbox: rpmCheckboxSaveValue,
            an7Damping: an7dampingfactor.text,
            gearSensor: buildGearSensorConfig(),
            speedSensor: buildSpeedSensorConfig()
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
            config.steinhartT = [
                ref.steinhartT[0].text,
                ref.steinhartT[1].text,
                ref.steinhartT[2].text
            ];
            config.steinhartR = [
                ref.steinhartR[0].text,
                ref.steinhartR[1].text,
                ref.steinhartR[2].text
            ];
        }

        return config;
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

    function applyBoardConfig(config) {
        var board = config || {};
        digitalExtender.currentIndex = board.selectedValue !== undefined ? board.selectedValue : 0;
        maxBrightnessBoot.checked = board.switchValue !== undefined ? !!board.switchValue : false;
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

    function loadAllSettingsFromManager() {
        var config = ExBoardConfig.loadAllSettings();

        loadingConfig = true;
        for (var channel = 0; channel < 8; ++channel)
            applyChannelConfig(channel, config.channels && config.channels[channel] ? config.channels[channel] : {});
        for (var i = 0; i < 8; ++i)
            applyDigitalChannelConfig(i, config.digitalChannels && config.digitalChannels[i] ? config.digitalChannels[i] : {});
        applyBoardConfig(config.board || {});
        loadingConfig = false;

        inputs.setInputs();
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
        visible: false
        function setInputs() {
            if (loadingConfig)
                return;
            ExBoardConfig.saveAllSettings(buildAllSettings());
        }
    }

    Item {
        id: cylindercalcrpmdi1
        visible: false
        function cylindercalcrpmdi1() {
            inputs.setInputs();
        }
    }

    // =============================================================
    // SECTION 1: Unified Analog Channels
    // =============================================================
    SettingsSection {
        title: "Analog Channels"
        Layout.fillWidth: true

        ColumnLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            // Table header row
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.rightMargin: SettingsTheme.sectionPadding
                spacing: 8
                Text {
                    text: ""
                    Layout.preferredWidth: enableColW
                }
                Text {
                    text: "Name"
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: nameColW
                }
                Text {
                    text: "Mode"
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: modeColW
                }
                Text {
                    text: "Preset"
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: presetColW
                }
                Text {
                    text: anyNtcActive ? "T1 / V0" : "V0"
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: fieldColW
                }
                Text {
                    text: anyNtcActive ? "R1 / V5" : "V5"
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: fieldColW
                }
                Text {
                    text: "T2"
                    visible: anyNtcActive
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: fieldColW
                }
                Text {
                    text: "R2"
                    visible: anyNtcActive
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: fieldColW
                }
                Text {
                    text: "T3"
                    visible: anyNtcActive
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: fieldColW
                }
                Text {
                    text: "R3"
                    visible: anyNtcActive
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: fieldColW
                }
                Text {
                    text: "100Ω"
                    visible: anyNtcActive
                    font.pixelSize: SettingsTheme.fontCaption
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: divCheckColW
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "1KΩ"
                    visible: anyNtcActive
                    font.pixelSize: SettingsTheme.fontCaption
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: divCheckColW
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Live V"
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: liveVColW
                }
                Text {
                    text: "Calibrated"
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: calibColW
                }
                Text {
                    text: ""
                    Layout.preferredWidth: statusColW
                }
            }

            // ---- CH 0 (NTC capable) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                spacing: 8
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable0.checked ? 1.0 : 0.4
                StyledSwitch {
                    id: chEnable0
                    Layout.preferredWidth: enableColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    onCheckedChanged: inputs.setInputs()
                }
                StyledTextField {
                    id: chName0
                    Layout.preferredWidth: nameColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 0"
                    enabled: chEnable0.checked
                    onEditingFinished: inputs.setInputs()
                }
                StyledComboBox {
                    id: modeCombo0
                    model: ["Linear", "NTC"]
                    Layout.preferredWidth: modeColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    enabled: chEnable0.checked
                    onActivated: {
                        checkan0ntc.checked = (currentIndex === 1);
                    }
                }
                Item {
                    Layout.preferredWidth: presetColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledComboBox {
                        id: linPreset0
                        model: linearPresetNames
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        visible: !checkan0ntc.checked
                        enabled: chEnable0.checked
                        onActivated: applyLinearPreset(0, currentText)
                    }
                    StyledComboBox {
                        id: ntcPreset0
                        model: ntcPresetNames
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        visible: checkan0ntc.checked
                        enabled: chEnable0.checked
                        onActivated: applyNtcPreset(0, currentText)
                    }
                }
                Item {
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: ex00
                        text: "0"
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: !checkan0ntc.checked
                        enabled: chEnable0.checked
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t10
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan0ntc.checked
                        enabled: chEnable0.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: ex05
                        text: "5"
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: !checkan0ntc.checked
                        enabled: chEnable0.checked
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r10
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan0ntc.checked
                        enabled: chEnable0.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: t20
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan0ntc.checked
                        enabled: chEnable0.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: r20
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan0ntc.checked
                        enabled: chEnable0.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: t30
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan0ntc.checked
                        enabled: chEnable0.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: r30
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan0ntc.checked
                        enabled: chEnable0.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledCheckBox {
                        id: checkan0100
                        anchors.centerIn: parent
                        visible: checkan0ntc.checked
                        enabled: chEnable0.checked
                        onCheckStateChanged: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledCheckBox {
                        id: checkan01k
                        anchors.centerIn: parent
                        visible: checkan0ntc.checked
                        enabled: chEnable0.checked
                        onCheckStateChanged: inputs.setInputs()
                    }
                }
                Text {
                    text: (Expander ? Expander.EXAnalogInput0 : 0).toFixed(3)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: (Expander ? Expander.EXAnalogInput0 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    Layout.preferredWidth: liveVColW
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: checkan0ntc.checked ? "NTC" : (parseFloat(ex00.text) + ((Expander ? Expander.EXAnalogInput0 : 0) / 5.0) * (parseFloat(ex05.text) - parseFloat(ex00.text))).toFixed(2)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPrimary
                    Layout.preferredWidth: calibColW
                    verticalAlignment: Text.AlignVCenter
                }
                Item {
                    Layout.preferredWidth: statusColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Rectangle {
                        anchors.centerIn: parent
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        color: (Expander ? Expander.EXAnalogInput0 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    }
                }
            }

            // ---- CH 1 (NTC capable) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                spacing: 8
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable1.checked ? 1.0 : 0.4
                StyledSwitch {
                    id: chEnable1
                    Layout.preferredWidth: enableColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    onCheckedChanged: inputs.setInputs()
                }
                StyledTextField {
                    id: chName1
                    Layout.preferredWidth: nameColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 1"
                    enabled: chEnable1.checked
                    onEditingFinished: inputs.setInputs()
                }
                StyledComboBox {
                    id: modeCombo1
                    model: ["Linear", "NTC"]
                    Layout.preferredWidth: modeColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    enabled: chEnable1.checked
                    onActivated: {
                        checkan1ntc.checked = (currentIndex === 1);
                    }
                }
                Item {
                    Layout.preferredWidth: presetColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledComboBox {
                        id: linPreset1
                        model: linearPresetNames
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        visible: !checkan1ntc.checked
                        enabled: chEnable1.checked
                        onActivated: applyLinearPreset(1, currentText)
                    }
                    StyledComboBox {
                        id: ntcPreset1
                        model: ntcPresetNames
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        visible: checkan1ntc.checked
                        enabled: chEnable1.checked
                        onActivated: applyNtcPreset(1, currentText)
                    }
                }
                Item {
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: ex10
                        text: "0"
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: !checkan1ntc.checked
                        enabled: chEnable1.checked
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t11
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan1ntc.checked
                        enabled: chEnable1.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: ex15
                        text: "5"
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: !checkan1ntc.checked
                        enabled: chEnable1.checked
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r11
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan1ntc.checked
                        enabled: chEnable1.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: t21
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan1ntc.checked
                        enabled: chEnable1.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: r21
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan1ntc.checked
                        enabled: chEnable1.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: t31
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan1ntc.checked
                        enabled: chEnable1.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: r31
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan1ntc.checked
                        enabled: chEnable1.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledCheckBox {
                        id: checkan1100
                        anchors.centerIn: parent
                        visible: checkan1ntc.checked
                        enabled: chEnable1.checked
                        onCheckStateChanged: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledCheckBox {
                        id: checkan11k
                        anchors.centerIn: parent
                        visible: checkan1ntc.checked
                        enabled: chEnable1.checked
                        onCheckStateChanged: inputs.setInputs()
                    }
                }
                Text {
                    text: (Expander ? Expander.EXAnalogInput1 : 0).toFixed(3)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: (Expander ? Expander.EXAnalogInput1 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    Layout.preferredWidth: liveVColW
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: checkan1ntc.checked ? "NTC" : (parseFloat(ex10.text) + ((Expander ? Expander.EXAnalogInput1 : 0) / 5.0) * (parseFloat(ex15.text) - parseFloat(ex10.text))).toFixed(2)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPrimary
                    Layout.preferredWidth: calibColW
                    verticalAlignment: Text.AlignVCenter
                }
                Item {
                    Layout.preferredWidth: statusColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Rectangle {
                        anchors.centerIn: parent
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        color: (Expander ? Expander.EXAnalogInput1 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    }
                }
            }

            // ---- CH 2 (NTC capable) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                spacing: 8
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable2.checked ? 1.0 : 0.4
                StyledSwitch {
                    id: chEnable2
                    Layout.preferredWidth: enableColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    onCheckedChanged: inputs.setInputs()
                }
                StyledTextField {
                    id: chName2
                    Layout.preferredWidth: nameColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 2"
                    enabled: chEnable2.checked
                    onEditingFinished: inputs.setInputs()
                }
                StyledComboBox {
                    id: modeCombo2
                    model: ["Linear", "NTC"]
                    Layout.preferredWidth: modeColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    enabled: chEnable2.checked
                    onActivated: {
                        checkan2ntc.checked = (currentIndex === 1);
                    }
                }
                Item {
                    Layout.preferredWidth: presetColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledComboBox {
                        id: linPreset2
                        model: linearPresetNames
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        visible: !checkan2ntc.checked
                        enabled: chEnable2.checked
                        onActivated: applyLinearPreset(2, currentText)
                    }
                    StyledComboBox {
                        id: ntcPreset2
                        model: ntcPresetNames
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        visible: checkan2ntc.checked
                        enabled: chEnable2.checked
                        onActivated: applyNtcPreset(2, currentText)
                    }
                }
                Item {
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: ex20
                        text: "0"
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: !checkan2ntc.checked
                        enabled: chEnable2.checked
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t12
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan2ntc.checked
                        enabled: chEnable2.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: ex25
                        text: "5"
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: !checkan2ntc.checked
                        enabled: chEnable2.checked
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r12
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan2ntc.checked
                        enabled: chEnable2.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: t22
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan2ntc.checked
                        enabled: chEnable2.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: r22
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan2ntc.checked
                        enabled: chEnable2.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: t32
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan2ntc.checked
                        enabled: chEnable2.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: r32
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan2ntc.checked
                        enabled: chEnable2.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledCheckBox {
                        id: checkan2100
                        anchors.centerIn: parent
                        visible: checkan2ntc.checked
                        enabled: chEnable2.checked
                        onCheckStateChanged: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledCheckBox {
                        id: checkan21k
                        anchors.centerIn: parent
                        visible: checkan2ntc.checked
                        enabled: chEnable2.checked
                        onCheckStateChanged: inputs.setInputs()
                    }
                }
                Text {
                    text: (Expander ? Expander.EXAnalogInput2 : 0).toFixed(3)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: (Expander ? Expander.EXAnalogInput2 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    Layout.preferredWidth: liveVColW
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: checkan2ntc.checked ? "NTC" : (parseFloat(ex20.text) + ((Expander ? Expander.EXAnalogInput2 : 0) / 5.0) * (parseFloat(ex25.text) - parseFloat(ex20.text))).toFixed(2)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPrimary
                    Layout.preferredWidth: calibColW
                    verticalAlignment: Text.AlignVCenter
                }
                Item {
                    Layout.preferredWidth: statusColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Rectangle {
                        anchors.centerIn: parent
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        color: (Expander ? Expander.EXAnalogInput2 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    }
                }
            }

            // ---- CH 3 (NTC capable) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                spacing: 8
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable3.checked ? 1.0 : 0.4
                StyledSwitch {
                    id: chEnable3
                    Layout.preferredWidth: enableColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    onCheckedChanged: inputs.setInputs()
                }
                StyledTextField {
                    id: chName3
                    Layout.preferredWidth: nameColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 3"
                    enabled: chEnable3.checked
                    onEditingFinished: inputs.setInputs()
                }
                StyledComboBox {
                    id: modeCombo3
                    model: ["Linear", "NTC"]
                    Layout.preferredWidth: modeColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    enabled: chEnable3.checked
                    onActivated: {
                        checkan3ntc.checked = (currentIndex === 1);
                    }
                }
                Item {
                    Layout.preferredWidth: presetColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledComboBox {
                        id: linPreset3
                        model: linearPresetNames
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        visible: !checkan3ntc.checked
                        enabled: chEnable3.checked
                        onActivated: applyLinearPreset(3, currentText)
                    }
                    StyledComboBox {
                        id: ntcPreset3
                        model: ntcPresetNames
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        visible: checkan3ntc.checked
                        enabled: chEnable3.checked
                        onActivated: applyNtcPreset(3, currentText)
                    }
                }
                Item {
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: ex30
                        text: "0"
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: !checkan3ntc.checked
                        enabled: chEnable3.checked
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t13
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan3ntc.checked
                        enabled: chEnable3.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: ex35
                        text: "5"
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: !checkan3ntc.checked
                        enabled: chEnable3.checked
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r13
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan3ntc.checked
                        enabled: chEnable3.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: t23
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan3ntc.checked
                        enabled: chEnable3.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: r23
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan3ntc.checked
                        enabled: chEnable3.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: t33
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan3ntc.checked
                        enabled: chEnable3.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: r33
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan3ntc.checked
                        enabled: chEnable3.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledCheckBox {
                        id: checkan3100
                        anchors.centerIn: parent
                        visible: checkan3ntc.checked
                        enabled: chEnable3.checked
                        onCheckStateChanged: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledCheckBox {
                        id: checkan31k
                        anchors.centerIn: parent
                        visible: checkan3ntc.checked
                        enabled: chEnable3.checked
                        onCheckStateChanged: inputs.setInputs()
                    }
                }
                Text {
                    text: (Expander ? Expander.EXAnalogInput3 : 0).toFixed(3)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: (Expander ? Expander.EXAnalogInput3 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    Layout.preferredWidth: liveVColW
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: checkan3ntc.checked ? "NTC" : (parseFloat(ex30.text) + ((Expander ? Expander.EXAnalogInput3 : 0) / 5.0) * (parseFloat(ex35.text) - parseFloat(ex30.text))).toFixed(2)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPrimary
                    Layout.preferredWidth: calibColW
                    verticalAlignment: Text.AlignVCenter
                }
                Item {
                    Layout.preferredWidth: statusColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Rectangle {
                        anchors.centerIn: parent
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        color: (Expander ? Expander.EXAnalogInput3 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    }
                }
            }

            // ---- CH 4 (NTC capable) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                spacing: 8
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable4.checked ? 1.0 : 0.4
                StyledSwitch {
                    id: chEnable4
                    Layout.preferredWidth: enableColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    onCheckedChanged: inputs.setInputs()
                }
                StyledTextField {
                    id: chName4
                    Layout.preferredWidth: nameColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 4"
                    enabled: chEnable4.checked
                    onEditingFinished: inputs.setInputs()
                }
                StyledComboBox {
                    id: modeCombo4
                    model: ["Linear", "NTC"]
                    Layout.preferredWidth: modeColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    enabled: chEnable4.checked
                    onActivated: {
                        checkan4ntc.checked = (currentIndex === 1);
                    }
                }
                Item {
                    Layout.preferredWidth: presetColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledComboBox {
                        id: linPreset4
                        model: linearPresetNames
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        visible: !checkan4ntc.checked
                        enabled: chEnable4.checked
                        onActivated: applyLinearPreset(4, currentText)
                    }
                    StyledComboBox {
                        id: ntcPreset4
                        model: ntcPresetNames
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        visible: checkan4ntc.checked
                        enabled: chEnable4.checked
                        onActivated: applyNtcPreset(4, currentText)
                    }
                }
                Item {
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: ex40
                        text: "0"
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: !checkan4ntc.checked
                        enabled: chEnable4.checked
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t14
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan4ntc.checked
                        enabled: chEnable4.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: ex45
                        text: "5"
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: !checkan4ntc.checked
                        enabled: chEnable4.checked
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r14
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan4ntc.checked
                        enabled: chEnable4.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: t24
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan4ntc.checked
                        enabled: chEnable4.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: r24
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan4ntc.checked
                        enabled: chEnable4.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: t34
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan4ntc.checked
                        enabled: chEnable4.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: r34
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan4ntc.checked
                        enabled: chEnable4.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledCheckBox {
                        id: checkan4100
                        anchors.centerIn: parent
                        visible: checkan4ntc.checked
                        enabled: chEnable4.checked
                        onCheckStateChanged: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledCheckBox {
                        id: checkan41k
                        anchors.centerIn: parent
                        visible: checkan4ntc.checked
                        enabled: chEnable4.checked
                        onCheckStateChanged: inputs.setInputs()
                    }
                }
                Text {
                    text: (Expander ? Expander.EXAnalogInput4 : 0).toFixed(3)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: (Expander ? Expander.EXAnalogInput4 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    Layout.preferredWidth: liveVColW
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: checkan4ntc.checked ? "NTC" : (parseFloat(ex40.text) + ((Expander ? Expander.EXAnalogInput4 : 0) / 5.0) * (parseFloat(ex45.text) - parseFloat(ex40.text))).toFixed(2)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPrimary
                    Layout.preferredWidth: calibColW
                    verticalAlignment: Text.AlignVCenter
                }
                Item {
                    Layout.preferredWidth: statusColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Rectangle {
                        anchors.centerIn: parent
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        color: (Expander ? Expander.EXAnalogInput4 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    }
                }
            }

            // ---- CH 5 (NTC capable) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                spacing: 8
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable5.checked ? 1.0 : 0.4
                StyledSwitch {
                    id: chEnable5
                    Layout.preferredWidth: enableColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    onCheckedChanged: inputs.setInputs()
                }
                StyledTextField {
                    id: chName5
                    Layout.preferredWidth: nameColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 5"
                    enabled: chEnable5.checked
                    onEditingFinished: inputs.setInputs()
                }
                StyledComboBox {
                    id: modeCombo5
                    model: ["Linear", "NTC"]
                    Layout.preferredWidth: modeColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    enabled: chEnable5.checked
                    onActivated: {
                        checkan5ntc.checked = (currentIndex === 1);
                    }
                }
                Item {
                    Layout.preferredWidth: presetColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledComboBox {
                        id: linPreset5
                        model: linearPresetNames
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        visible: !checkan5ntc.checked
                        enabled: chEnable5.checked
                        onActivated: applyLinearPreset(5, currentText)
                    }
                    StyledComboBox {
                        id: ntcPreset5
                        model: ntcPresetNames
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        visible: checkan5ntc.checked
                        enabled: chEnable5.checked
                        onActivated: applyNtcPreset(5, currentText)
                    }
                }
                Item {
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: ex50
                        text: "0"
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: !checkan5ntc.checked
                        enabled: chEnable5.checked
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: t15
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan5ntc.checked
                        enabled: chEnable5.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: ex55
                        text: "5"
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: !checkan5ntc.checked
                        enabled: chEnable5.checked
                        onEditingFinished: inputs.setInputs()
                    }
                    StyledTextField {
                        id: r15
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan5ntc.checked
                        enabled: chEnable5.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: t25
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan5ntc.checked
                        enabled: chEnable5.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: r25
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan5ntc.checked
                        enabled: chEnable5.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: t35
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan5ntc.checked
                        enabled: chEnable5.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledTextField {
                        id: r35
                        anchors.fill: parent
                        font.pixelSize: SettingsTheme.fontStatus
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        visible: checkan5ntc.checked
                        enabled: chEnable5.checked
                        onEditingFinished: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledCheckBox {
                        id: checkan5100
                        anchors.centerIn: parent
                        visible: checkan5ntc.checked
                        enabled: chEnable5.checked
                        onCheckStateChanged: inputs.setInputs()
                    }
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    StyledCheckBox {
                        id: checkan51k
                        anchors.centerIn: parent
                        visible: checkan5ntc.checked
                        enabled: chEnable5.checked
                        onCheckStateChanged: inputs.setInputs()
                    }
                }
                Text {
                    text: (Expander ? Expander.EXAnalogInput5 : 0).toFixed(3)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: (Expander ? Expander.EXAnalogInput5 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    Layout.preferredWidth: liveVColW
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: checkan5ntc.checked ? "NTC" : (parseFloat(ex50.text) + ((Expander ? Expander.EXAnalogInput5 : 0) / 5.0) * (parseFloat(ex55.text) - parseFloat(ex50.text))).toFixed(2)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPrimary
                    Layout.preferredWidth: calibColW
                    verticalAlignment: Text.AlignVCenter
                }
                Item {
                    Layout.preferredWidth: statusColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Rectangle {
                        anchors.centerIn: parent
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        color: (Expander ? Expander.EXAnalogInput5 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    }
                }
            }

            // ---- CH 6 (Linear only, no NTC) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                spacing: 8
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable6.checked ? 1.0 : 0.4
                StyledSwitch {
                    id: chEnable6
                    Layout.preferredWidth: enableColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    onCheckedChanged: inputs.setInputs()
                }
                StyledTextField {
                    id: chName6
                    Layout.preferredWidth: nameColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 6"
                    enabled: chEnable6.checked
                    onEditingFinished: inputs.setInputs()
                }
                Text {
                    text: "Linear"
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPlaceholder
                    Layout.preferredWidth: modeColW
                    verticalAlignment: Text.AlignVCenter
                }
                StyledComboBox {
                    id: linPreset6
                    model: linearPresetNames
                    Layout.preferredWidth: presetColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    enabled: chEnable6.checked
                    onActivated: applyLinearPreset(6, currentText)
                }
                StyledTextField {
                    id: ex60
                    text: "0"
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    enabled: chEnable6.checked
                    onEditingFinished: inputs.setInputs()
                }
                StyledTextField {
                    id: ex65
                    text: "5"
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    enabled: chEnable6.checked
                    onEditingFinished: inputs.setInputs()
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                }
                Text {
                    text: (Expander ? Expander.EXAnalogInput6 : 0).toFixed(3)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: (Expander ? Expander.EXAnalogInput6 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    Layout.preferredWidth: liveVColW
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: (parseFloat(ex60.text) + ((Expander ? Expander.EXAnalogInput6 : 0) / 5.0) * (parseFloat(ex65.text) - parseFloat(ex60.text))).toFixed(2)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPrimary
                    Layout.preferredWidth: calibColW
                    verticalAlignment: Text.AlignVCenter
                }
                Item {
                    Layout.preferredWidth: statusColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Rectangle {
                        anchors.centerIn: parent
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        color: (Expander ? Expander.EXAnalogInput6 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    }
                }
            }

            // ---- CH 7 (Linear only, no NTC) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.controlHeight + 2
                spacing: 8
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.rightMargin: SettingsTheme.sectionPadding
                opacity: chEnable7.checked ? 1.0 : 0.4
                StyledSwitch {
                    id: chEnable7
                    Layout.preferredWidth: enableColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    onCheckedChanged: inputs.setInputs()
                }
                StyledTextField {
                    id: chName7
                    Layout.preferredWidth: nameColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    placeholderText: "AN 7"
                    enabled: chEnable7.checked
                    onEditingFinished: inputs.setInputs()
                }
                Text {
                    text: "Linear"
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPlaceholder
                    Layout.preferredWidth: modeColW
                    verticalAlignment: Text.AlignVCenter
                }
                StyledComboBox {
                    id: linPreset7
                    model: linearPresetNames
                    Layout.preferredWidth: presetColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    enabled: chEnable7.checked
                    onActivated: applyLinearPreset(7, currentText)
                }
                StyledTextField {
                    id: ex70
                    text: "0"
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    enabled: chEnable7.checked
                    onEditingFinished: inputs.setInputs()
                }
                StyledTextField {
                    id: ex75
                    text: "5"
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    enabled: chEnable7.checked
                    onEditingFinished: inputs.setInputs()
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: fieldColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                }
                Item {
                    visible: anyNtcActive
                    Layout.preferredWidth: divCheckColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                }
                Text {
                    text: (Expander ? Expander.EXAnalogInput7 : 0).toFixed(3)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: (Expander ? Expander.EXAnalogInput7 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    Layout.preferredWidth: liveVColW
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: (parseFloat(ex70.text) + ((Expander ? Expander.EXAnalogInput7 : 0) / 5.0) * (parseFloat(ex75.text) - parseFloat(ex70.text))).toFixed(2)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPrimary
                    Layout.preferredWidth: calibColW
                    verticalAlignment: Text.AlignVCenter
                }
                Item {
                    Layout.preferredWidth: statusColW
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Rectangle {
                        anchors.centerIn: parent
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        color: (Expander ? Expander.EXAnalogInput7 : 0) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                    }
                }
            }
        }
    }

    // =============================================================
    // SECTION 2: Board Configuration
    // =============================================================
    SettingsSection {
        title: "Board Configuration"
        Layout.fillWidth: true

        ColumnLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.sectionPadding

            // Compact label width for this section (override default 180px)
            readonly property int boardConfigLabelW: 140

            SettingsRow {
                label: "AN7 Damping"
                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledTextField {
                    id: an7dampingfactor
                    text: "0"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
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
                    text: Translator.translate("Version", Settings.language) + ":"
                    font.pixelSize: SettingsTheme.fontLabel
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPrimary
                    verticalAlignment: Text.AlignVCenter
                }
                StyledComboBox {
                    id: rpmcanversionselector
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["V1", "V2"]
                    onActivated: inputs.setInputs()
                }
                Text {
                    text: Translator.translate("Cylinders", Settings.language) + ":"
                    font.pixelSize: SettingsTheme.fontLabel
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPrimary
                    verticalAlignment: Text.AlignVCenter
                }
                StyledComboBox {
                    id: cylindercombobox
                    visible: rpmcanversionselector.currentIndex == 0
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["0.5", "0.6", "0.7", "0.8", "0.9", "1", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "2.9", "3", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9", "4", "4.1", "4.2", "4.3", "4.4", "4.5", "4.6", "4.7", "4.8", "4.9", "5", "5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "5.8", "5.9", "6", "6.1", "6.2", "6.3", "6.4", "6.5", "6.6", "6.7", "6.8", "6.9", "7", "7.1", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7", "7.8", "7.9", "8", "8.1", "8.2", "8.3", "8.4", "8.5", "8.6", "8.7", "8.8", "8.9", "9", "9.1", "9.2", "9.3", "9.4", "9.5", "9.6", "9.7", "9.8", "9.9", "10", "10.1", "10.2", "10.3", "10.4", "10.5", "10.6", "10.7", "10.8", "10.9", "11", "11.1", "11.2", "11.3", "11.4", "11.5", "11.6", "11.7", "11.8", "11.9", "12", "12.1", "12.2", "12.3", "12.4", "12.5", "12.6", "12.7", "12.8", "12.9"]
                    onActivated: inputs.setInputs()
                }
                StyledComboBox {
                    id: cylindercomboboxv2
                    visible: rpmcanversionselector.currentIndex == 1
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["1", "2", "3", "4", "5", "6", "8", "12"]
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
                    text: Translator.translate("Cylinders", Settings.language) + ":"
                    font.pixelSize: SettingsTheme.fontLabel
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textPrimary
                    verticalAlignment: Text.AlignVCenter
                }
                StyledComboBox {
                    id: cylindercomboboxDi1
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    font.pixelSize: SettingsTheme.fontStatus
                    model: ["1", "2", "3", "4", "5", "6", "8", "12"]
                    onActivated: cylindercalcrpmdi1.cylindercalcrpmdi1()
                }
                Item {
                    Layout.fillWidth: true
                }
            }

            SettingsRow {
                label: "Headlight Channel"
                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledComboBox {
                    id: digitalExtender
                    model: comboBoxModel
                    textRole: "text"
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    onCurrentIndexChanged: {
                        digiValue = currentIndex;
                        digiStringValue = "Ex Digital Input " + (currentIndex + 1);
                    }
                }
            }

            SettingsRow {
                label: "CAN/IO Brightness"
                Component.onCompleted: children[0].Layout.preferredWidth = parent.boardConfigLabelW

                StyledSwitch {
                    id: maxBrightnessBoot
                    text: checked ? "On" : "Off"
                    Layout.preferredWidth: 100
                    onCheckedChanged: inputs.setInputs()
                }
            }
        }
    }

    // =============================================================
    // SECTION 3: Digital Inputs
    // =============================================================
    SettingsSection {
        title: "Digital Inputs"
        Layout.fillWidth: true

        ColumnLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            // Digital header row
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                Layout.leftMargin: SettingsTheme.sectionPadding
                Layout.rightMargin: SettingsTheme.sectionPadding
                spacing: 8
                Text {
                    text: ""
                    Layout.preferredWidth: enableColW
                }
                Text {
                    text: "Name"
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: 200
                }
                Text {
                    text: "Channel"
                    font.pixelSize: SettingsTheme.fontStatus
                    font.bold: true
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.preferredWidth: 120
                }
            }

            Repeater {
                id: digitalNameRepeater
                model: 8
                RowLayout {
                    property alias enableSwitch: diEnableSwitch
                    property alias nameField: digiNameField
                    Layout.fillWidth: true
                    Layout.preferredHeight: SettingsTheme.controlHeight + 2
                    spacing: 8
                    Layout.leftMargin: SettingsTheme.sectionPadding
                    Layout.rightMargin: SettingsTheme.sectionPadding
                    opacity: diEnableSwitch.checked ? 1.0 : 0.4

                    StyledSwitch {
                        id: diEnableSwitch
                        Layout.preferredWidth: enableColW
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        checked: true
                        onCheckedChanged: inputs.setInputs()
                    }

                    StyledTextField {
                        id: digiNameField
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        font.pixelSize: SettingsTheme.fontStatus
                        placeholderText: "DI " + (index + 1)
                        enabled: diEnableSwitch.checked
                        onEditingFinished: inputs.setInputs()
                    }

                    Text {
                        text: "EX Digi " + (index + 1)
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.preferredWidth: 120
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
        title: "Gear Position Sensor"
        Layout.fillWidth: true

        SettingsRow {
            label: "Enable"
            StyledSwitch {
                id: gearSensorEnabled
                checked: false
            }
        }

        SettingsRow {
            visible: gearSensorEnabled.checked
            label: "Analog Port"
            StyledComboBox {
                id: gearSensorPort
                model: ["EX Analog 0", "EX Analog 1", "EX Analog 2", "EX Analog 3",
                        "EX Analog 4", "EX Analog 5", "EX Analog 6", "EX Analog 7"]
            }
        }

        SettingsRow {
            visible: gearSensorEnabled.checked
            label: "Tolerance (V)"
            StyledTextField {
                id: gearTolerance
                text: "0.2"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: gearSensorEnabled.checked
            label: "Neutral"
            StyledTextField {
                id: gearVoltageN
                text: "0.0"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: gearSensorEnabled.checked
            label: "Reverse"
            StyledTextField {
                id: gearVoltageR
                text: "0.5"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: gearSensorEnabled.checked
            label: "1st Gear"
            StyledTextField {
                id: gearVoltage1
                text: "1.0"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: gearSensorEnabled.checked
            label: "2nd Gear"
            StyledTextField {
                id: gearVoltage2
                text: "1.5"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: gearSensorEnabled.checked
            label: "3rd Gear"
            StyledTextField {
                id: gearVoltage3
                text: "2.0"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: gearSensorEnabled.checked
            label: "4th Gear"
            StyledTextField {
                id: gearVoltage4
                text: "2.5"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: gearSensorEnabled.checked
            label: "5th Gear"
            StyledTextField {
                id: gearVoltage5
                text: "3.0"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: gearSensorEnabled.checked
            label: "6th Gear"
            StyledTextField {
                id: gearVoltage6
                text: "3.5"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: gearSensorEnabled.checked
            label: "Current"
            Text {
                text: {
                    var idx = gearSensorPort.currentIndex;
                    var raw = 0;
                    if (Expander) {
                        if (idx === 0) raw = Expander.EXAnalogInput0;
                        else if (idx === 1) raw = Expander.EXAnalogInput1;
                        else if (idx === 2) raw = Expander.EXAnalogInput2;
                        else if (idx === 3) raw = Expander.EXAnalogInput3;
                        else if (idx === 4) raw = Expander.EXAnalogInput4;
                        else if (idx === 5) raw = Expander.EXAnalogInput5;
                        else if (idx === 6) raw = Expander.EXAnalogInput6;
                        else if (idx === 7) raw = Expander.EXAnalogInput7;
                    }
                    var gear = Expander ? Expander.EXGear : -2;
                    var gearStr = gear === -2 ? "?" : gear === -1 ? "R" : gear === 0 ? "N" : String(gear);
                    return raw.toFixed(3) + " V -> Gear " + gearStr;
                }
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamilyMono
                font.pixelSize: SettingsTheme.fontControl
            }
        }

        StyledButton {
            visible: gearSensorEnabled.checked
            text: "Save Gear Config"
            Layout.alignment: Qt.AlignRight
            onClicked: ExBoardConfig.saveAllSettings(buildAllSettings())
        }
    }

    // =============================================================
    // SECTION 5: Speed Sensor
    // =============================================================
    SettingsSection {
        title: "Speed Sensor"
        Layout.fillWidth: true

        SettingsRow {
            label: "Enable"
            StyledSwitch {
                id: speedSensorEnabled
                checked: false
            }
        }

        SettingsRow {
            visible: speedSensorEnabled.checked
            label: "Source Type"
            StyledComboBox {
                id: speedSourceType
                model: ["Analog", "Digital"]
            }
        }

        SettingsRow {
            visible: speedSensorEnabled.checked && speedSourceType.currentIndex === 0
            label: "Analog Port"
            StyledComboBox {
                id: speedAnalogPort
                model: ["EX Analog 0", "EX Analog 1", "EX Analog 2", "EX Analog 3",
                        "EX Analog 4", "EX Analog 5", "EX Analog 6", "EX Analog 7"]
            }
        }

        SettingsRow {
            visible: speedSensorEnabled.checked && speedSourceType.currentIndex === 1
            label: "Digital Port"
            StyledComboBox {
                id: speedDigitalPort
                model: ["EX Digital 1", "EX Digital 2", "EX Digital 3", "EX Digital 4",
                        "EX Digital 5", "EX Digital 6", "EX Digital 7", "EX Digital 8"]
            }
        }

        SettingsRow {
            visible: speedSensorEnabled.checked && speedSourceType.currentIndex === 1
            label: "Pulses/Rev"
            StyledTextField {
                id: speedPulsesPerRev
                text: "4.0"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: speedSensorEnabled.checked && speedSourceType.currentIndex === 0
            label: "Voltage Multiplier"
            StyledTextField {
                id: speedVoltageMultiplier
                text: "1.0"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: speedSensorEnabled.checked
            label: "Tire Circumference (m)"
            StyledTextField {
                id: speedTireCircumference
                text: "2.06"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: speedSensorEnabled.checked
            label: "Final Drive Ratio"
            StyledTextField {
                id: speedFinalDriveRatio
                text: "1.0"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.preferredWidth: 100
            }
        }

        SettingsRow {
            visible: speedSensorEnabled.checked
            label: "Unit"
            StyledComboBox {
                id: speedUnit
                model: ["MPH", "KPH"]
            }
        }

        SettingsRow {
            visible: speedSensorEnabled.checked
            label: "Current Speed"
            Text {
                text: (Expander ? Expander.EXSpeed : 0).toFixed(1) + " " + (speedUnit.currentIndex === 0 ? "MPH" : "KPH")
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamilyMono
                font.pixelSize: SettingsTheme.fontControl
            }
        }

        StyledButton {
            visible: speedSensorEnabled.checked
            text: "Save Speed Config"
            Layout.alignment: Qt.AlignRight
            onClicked: ExBoardConfig.saveAllSettings(buildAllSettings())
        }
    }

    Component.onCompleted: {
        loadAllSettingsFromManager();
    }

    function executeOnBootAction() {
        if (maxBrightnessBoot.checked) {
            maxBrightnessOnBoot = 1;
        }
    }
}
