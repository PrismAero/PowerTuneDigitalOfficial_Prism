// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

SettingsPage {
    id: root

    property int connected: 0
    property int currentLanguage: (Settings && Settings.language !== undefined) ? Settings.language : 0
    readonly property var ecuBackendMap: [5, 0, 4]
    readonly property int genericCanDaemonIndex: 40
    property int hexstring: 0
    property int hexstring2: 0
    readonly property bool isExtenderOnly: ecuBackendMap[ecuSelect.currentIndex] === 5
    property bool loggerActive: false
    property bool settingsLoaded: false

    function applyLanguage() {
        AppSettings.writeLanguage(languageselect.currentIndex);
    }

    function autoConnect() {
        if (connectButton.enabled === false) {
            connectEcu();
            ecuSelect.enabled = false;
            disconnectButton.enabled = true;
        }
    }

    function connectEcu() {
        Connect.setOdometer(odometer.text);
        Connect.setWeight(weight.text);
        var backendIdx = ecuBackendMap[ecuSelect.currentIndex];
        Connect.openConnection("", backendIdx, baseadresstext.text, shiftlightbaseadresstext.text);
        connected = 1;
    }

    function disconnectEcu() {
        Connect.closeConnection();
        connected = 0;
    }

    function ecuDropdownFromBackend(backendIdx) {
        for (var i = 0; i < ecuBackendMap.length; i++) {
            if (ecuBackendMap[i] === backendIdx)
                return i;
        }
        return 0;
    }

    function toggleDataLogger() {
        if (loggerswitch.checked) {
            loggerActive = true;
            Logger.startLog(logfilenameSelect.text);
        } else {
            loggerActive = false;
            Logger.stopLog();
        }
    }

    function triggerWarning() {
    }

    function updateWeightLabel() {
        if (unitSelect.currentIndex === 0)
            weightRow.label = Translator.translate("Weight", Settings.language) + " kg";
        if (unitSelect.currentIndex === 1)
            weightRow.label = Translator.translate("Weight", Settings.language) + " lbs";
    }

    Component.onCompleted: {
        connectButton.enabled = AppSettings.getValue("ui/connectAtStartup", false);
        weight.text = AppSettings.getValue("ui/vehicleWeight", "0");
        unitSelect1.currentIndex = AppSettings.getValue("ui/unitSelector1", 0);
        unitSelect.currentIndex = AppSettings.getValue("ui/unitSelector", 0);
        unitSelect2.currentIndex = AppSettings.getValue("ui/unitSelector2", 0);
        odometer.text = AppSettings.getValue("ui/odometer", "0");
        tripmeter.text = AppSettings.getValue("ui/tripmeter", "0");
        baseadresstext.text = AppSettings.getValue("ui/extenderCanBase", "");
        shiftlightbaseadresstext.text = AppSettings.getValue("ui/shiftLightCanBase", "");
        languageselect.currentIndex = AppSettings.getValue("Language", 0);
        mainspeedsource.currentIndex = AppSettings.getValue("ui/mainSpeedSource", 0);
        canbitrateselect.currentIndex = AppSettings.getValue("ui/bitrateSelect", 0);
        Vehicle.setTrip(tripmeter.text);
        AppSettings.setSpeedUnitIndex(unitSelect1.currentIndex);
        AppSettings.setTempUnitIndex(unitSelect.currentIndex);
        AppSettings.setPressureUnitIndex(unitSelect2.currentIndex);
        AppSettings.setMainSpeedSourceIndex(mainspeedsource.currentIndex);
        settingsLoaded = true;
        autoConnect();
    }

    Connections {
        function onOdoChanged() {
            odometer.text = Vehicle.Odo.toFixed(3);
        }

        function onTripChanged() {
            tripmeter.text = Vehicle.Trip.toFixed(3);
        }

        target: Vehicle
    }

    Connections {
        function onKnockChanged() {
            if (Engine.Knock > Settings.knockwarn)
                triggerWarning();
        }

        function onRpmChanged() {
            if (Engine.rpm > Settings.rpmwarn)
                triggerWarning();
        }

        function onWatertempChanged() {
            if (Engine.Watertemp > Settings.waterwarn)
                triggerWarning();
        }

        target: Engine
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.sectionSpacing

        // * LEFT COLUMN - Connection, Units, Language, Data Logging
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Connection", Settings.language)

                RowLayout {
                    spacing: SettingsTheme.sectionPadding

                    StyledButton {
                        id: connectButton

                        text: Translator.translate("Connect", Settings.language)

                        onClicked: {
                            connectEcu();
                            connectButton.enabled = false;
                            ecuSelect.enabled = false;
                            disconnectButton.enabled = true;
                        }
                        onEnabledChanged: if (settingsLoaded)
                                              AppSettings.setValue("ui/connectAtStartup", enabled)
                    }

                    StyledButton {
                        id: disconnectButton

                        enabled: false
                        primary: false
                        text: Translator.translate("Disconnect", Settings.language)

                        onClicked: {
                            connectButton.enabled = true;
                            disconnectButton.enabled = false;
                            ecuSelect.enabled = true;
                            disconnectEcu();
                        }
                    }
                }

                SettingsRow {
                    label: "CAN Status"

                    ConnectionStatusIndicator {
                        height: parent.height
                        status: {
                            if (Diagnostics.canStatusText === "Active")
                                return "connected";
                            if (Diagnostics.canStatusText === "Waiting")
                                return "pending";
                            return "disconnected";
                        }
                        statusText: Diagnostics.canStatusText
                        width: parent.width
                    }
                }

                SettingsRow {
                    label: Translator.translate("ECU Selection", Settings.language)

                    StyledComboBox {
                        id: ecuSelect

                        property bool initialized: false

                        height: parent.height
                        model: ["Extender Only", "CAN", "Generic CAN"]
                        width: parent.width

                        Component.onCompleted: {
                            var stored = AppSettings.getECU();
                            currentIndex = ecuDropdownFromBackend(stored);
                            AppSettings.setEcuIndex(currentIndex);
                            initialized = true;
                            autoConnect();
                        }
                        onCurrentIndexChanged: {
                            if (initialized) {
                                AppSettings.setEcuIndex(currentIndex);
                            }
                        }
                    }
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Units", Settings.language)

                SettingsRow {
                    label: Translator.translate("Speed units", Settings.language)

                    StyledComboBox {
                        id: unitSelect1

                        height: parent.height
                        model: [Translator.translate("Metric", Settings.language), Translator.translate("Imperial",
                                                                                                        Settings.language)]
                        width: parent.width

                        onCurrentIndexChanged: {
                            updateWeightLabel();
                            if (settingsLoaded)
                                AppSettings.setSpeedUnitIndex(currentIndex);
                        }
                    }
                }

                SettingsRow {
                    label: Translator.translate("Temp units", Settings.language)

                    StyledComboBox {
                        id: unitSelect

                        height: parent.height
                        model: [Translator.translate("C", Settings.language), Translator.translate("F",
                                                                                                   Settings.language)]
                        width: parent.width

                        onCurrentIndexChanged: {
                            updateWeightLabel();
                            if (settingsLoaded)
                                AppSettings.setTempUnitIndex(currentIndex);
                        }
                    }
                }

                SettingsRow {
                    label: Translator.translate("Pressure units", Settings.language)

                    StyledComboBox {
                        id: unitSelect2

                        height: parent.height
                        model: ["kPa", "PSI"]
                        width: parent.width

                        onCurrentIndexChanged: {
                            if (settingsLoaded)
                                AppSettings.setPressureUnitIndex(currentIndex);
                        }
                    }
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Language", Settings.language)

                StyledComboBox {
                    id: languageselect

                    Layout.fillWidth: true
                    model: ["English", "Deutsch", "\u65E5\u672C\u8A9E", "Espanol"]

                    onCurrentIndexChanged: {
                        applyLanguage();
                        updateWeightLabel();
                        if (settingsLoaded)
                            AppSettings.setValue("Language", currentIndex);
                    }
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Data Logging", Settings.language)

                SettingsRow {
                    label: Translator.translate("Logfile name", Settings.language)

                    StyledTextField {
                        id: logfilenameSelect

                        height: parent.height
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhSensitiveData
                                          | Qt.ImhNoPredictiveText
                        text: "DataLog"
                        width: parent.width
                    }
                }

                StyledSwitch {
                    id: loggerswitch

                    label: Translator.translate("Data Logger", Settings.language)

                    Component.onCompleted: toggleDataLogger()
                    onClicked: toggleDataLogger()
                }
            }
        }

        // * MIDDLE COLUMN - Vehicle, CAN Bus, Daemon, Display
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Vehicle", Settings.language)

                SettingsRow {
                    id: weightRow

                    label: Translator.translate("Weight", Settings.language) + " kg"

                    StyledTextField {
                        id: weight

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        width: parent.width

                        onEditingFinished: AppSettings.setValue("ui/vehicleWeight", text)
                    }
                }

                SettingsRow {
                    label: Translator.translate("Odo", Settings.language)

                    StyledTextField {
                        id: odometer

                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "0"
                        width: parent.width

                        onTextChanged: if (settingsLoaded)
                                           AppSettings.setValue("ui/odometer", text)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: SettingsTheme.sectionPadding

                    Text {
                        Layout.preferredWidth: SettingsTheme.labelWidth
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontLabel
                        text: Translator.translate("Trip", Settings.language)
                    }

                    StyledTextField {
                        id: tripmeter

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        readOnly: true
                        text: "0"

                        onTextChanged: if (settingsLoaded)
                                           AppSettings.setValue("ui/tripmeter", text)
                    }

                    StyledButton {
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        primary: false
                        text: Translator.translate("Trip Reset", Settings.language)

                        onClicked: Calculations.resettrip()
                    }
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("CAN Bus", Settings.language)

                SettingsRow {
                    label: Translator.translate("Can Bitrate", Settings.language)

                    StyledComboBox {
                        id: canbitrateselect

                        height: parent.height
                        model: ["250 kbit/s", "500 kbit/s", "1 Mbit/s"]
                        width: parent.width

                        onCurrentIndexChanged: if (settingsLoaded)
                                                   AppSettings.setValue("ui/bitrateSelect", currentIndex)
                    }
                }

                StyledButton {
                    text: Translator.translate("Apply Bitrate", Settings.language)

                    onClicked: Connect.canbitratesetup(canbitrateselect.currentIndex)
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Daemon / Startup", Settings.language)
                visible: !isExtenderOnly

                SettingsRow {
                    label: Translator.translate("Daemon", Settings.language)

                    StyledComboBox {
                        enabled: false
                        height: parent.height
                        model: ["Generic CAN"]
                        width: parent.width
                    }
                }

                SettingsRow {
                    label: Translator.translate("Speed Source", Settings.language)

                    StyledComboBox {
                        id: mainspeedsource

                        height: parent.height
                        model: ["ECU Speed", "LF Wheel", "RF Wheel", "LR Wheel", "RR Wheel", "GPS", "VR Sensor"]
                        width: parent.width

                        onCurrentIndexChanged: {
                            if (settingsLoaded) {
                                AppSettings.setMainSpeedSourceIndex(currentIndex);
                            }
                        }
                    }
                }

                StyledButton {
                    text: Translator.translate("Apply Startup", Settings.language)

                    onClicked: {
                        Connect.daemonstartup(genericCanDaemonIndex);
                        Connect.canbitratesetup(canbitrateselect.currentIndex);
                    }
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Display", Settings.language)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: SettingsTheme.controlGap

                    Text {
                        Layout.preferredWidth: SettingsTheme.labelWidth
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontLabel
                        text: Translator.translate("Brightness", Settings.language)
                    }

                    StyledButton {
                        implicitHeight: 36
                        implicitWidth: 36
                        primary: false
                        text: "-"

                        onClicked: window.adjustBrightness(-1)
                    }

                    Slider {
                        id: brightnessSlider

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        from: window.isDdc ? 0 : 20
                        stepSize: 5
                        to: window.isDdc ? 100 : 255
                        value: UI.Brightness

                        onMoved: window.applyBrightness(value)

                        Connections {
                            function onBrightnessChanged() {
                                brightnessSlider.value = UI.Brightness;
                            }

                            target: UI
                        }
                    }

                    StyledButton {
                        implicitHeight: 36
                        implicitWidth: 36
                        primary: false
                        text: "+"

                        onClicked: window.adjustBrightness(1)
                    }
                }

                StyledSwitch {
                    checked: AppSettings.getValue("ui/brightnessPopupEnabled", true)
                    label: Translator.translate("Brightness Pop Up at Boot", Settings.language)

                    onCheckedChanged: {
                        AppSettings.setValue("ui/brightnessPopupEnabled", checked);
                    }
                }
            }
        }

        // * RIGHT COLUMN - CAN Configuration, System
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                Layout.fillWidth: true
                title: "CAN Configuration"

                Text {
                    color: SettingsTheme.accent
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    font.weight: Font.DemiBold
                    text: "CAN Extender"
                }

                Text {
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: Translator.translate("base adress", Settings.language) + " " + Translator.translate(
                              "(decimal)", Settings.language)
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: SettingsTheme.controlGap

                    StyledTextField {
                        id: baseadresstext

                        Layout.preferredWidth: SettingsTheme.textFieldMinWidth
                        enabled: connectButton.enabled
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        placeholderText: "1024"

                        validator: IntValidator {
                            bottom: 0
                            top: 4000
                        }

                        onEditingFinished: AppSettings.setValue("ui/extenderCanBase", text)
                        onTextChanged: hexstring = parseInt(baseadresstext.text) || 0
                    }

                    Text {
                        color: SettingsTheme.accent
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontLabel
                        font.weight: Font.DemiBold
                        text: "HEX: 0x" + (hexstring + 0x1000).toString(16).substr(-3).toUpperCase()
                    }
                }

                Item {
                    Layout.fillWidth: true
                    height: SettingsTheme.contentSpacing / 2
                }

                Text {
                    color: SettingsTheme.accent
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontLabel
                    font.weight: Font.DemiBold
                    text: "Shiftlight CAN"
                }

                Text {
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: Translator.translate("base adress", Settings.language) + " " + Translator.translate(
                              "(decimal)", Settings.language)
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: SettingsTheme.controlGap

                    StyledTextField {
                        id: shiftlightbaseadresstext

                        Layout.preferredWidth: SettingsTheme.textFieldMinWidth
                        enabled: connectButton.enabled
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        placeholderText: "1024"

                        validator: IntValidator {
                            bottom: 0
                            top: 4000
                        }

                        onEditingFinished: AppSettings.setValue("ui/shiftLightCanBase", text)
                        onTextChanged: hexstring2 = parseInt(shiftlightbaseadresstext.text) || 0
                    }

                    Text {
                        color: SettingsTheme.accent
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontLabel
                        font.weight: Font.DemiBold
                        text: "HEX: 0x" + (hexstring2 + 0x1000).toString(16).substr(-3).toUpperCase()
                    }
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("System", Settings.language)

                Text {
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: "V 1.99F " + Connection.Platform
                }

                RowLayout {
                    spacing: SettingsTheme.sectionPadding

                    StyledButton {
                        primary: false
                        text: Translator.translate("Quit", Settings.language)

                        onClicked: Qt.quit()
                    }

                    StyledButton {
                        primary: false
                        text: Translator.translate("Reboot", Settings.language)

                        onClicked: Connect.reboot()
                    }

                    StyledButton {
                        danger: true
                        text: Translator.translate("Shutdown", Settings.language)

                        onClicked: Connect.shutdown()
                    }
                }
            }
        }
    }
}
