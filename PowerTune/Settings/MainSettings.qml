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
    property int hexstring: 0
    property int hexstring2: 0
    property int currentLanguage: (Settings && Settings.language !== undefined) ? Settings.language : 0
    property bool settingsLoaded: false
    property bool loggerActive: false

    readonly property var ecuBackendMap: [5, 0, 4]
    readonly property int genericCanDaemonIndex: 40
    readonly property bool isExtenderOnly: ecuBackendMap[ecuSelect.currentIndex] === 5

    function ecuDropdownFromBackend(backendIdx) {
        for (var i = 0; i < ecuBackendMap.length; i++) {
            if (ecuBackendMap[i] === backendIdx)
                return i;
        }
        return 0;
    }

    function autoConnect() {
        if (connectButton.enabled === false) {
            connectEcu();
            ecuSelect.enabled = false;
            disconnectButton.enabled = true;
        }
    }

    function updateWeightLabel() {
        if (unitSelect.currentIndex === 0)
            weightRow.label = Translator.translate("Weight", Settings.language) + " kg";
        if (unitSelect.currentIndex === 1)
            weightRow.label = Translator.translate("Weight", Settings.language) + " lbs";
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

    function triggerWarning() {
    }

    function applyLanguage() {
        AppSettings.writeLanguage(languageselect.currentIndex);
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
        settingsLoaded = true;
        autoConnect();
    }

    Connections {
        target: Vehicle
        function onOdoChanged() {
            odometer.text = Vehicle.Odo.toFixed(3);
        }
        function onTripChanged() {
            tripmeter.text = Vehicle.Trip.toFixed(3);
        }
    }
    Connections {
        target: Engine
        function onWatertempChanged() {
            if (Engine.Watertemp > Settings.waterwarn)
                triggerWarning();
        }
        function onRpmChanged() {
            if (Engine.rpm > Settings.rpmwarn)
                triggerWarning();
        }
        function onKnockChanged() {
            if (Engine.Knock > Settings.knockwarn)
                triggerWarning();
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.sectionSpacing

        // * LEFT COLUMN
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                title: Translator.translate("Connection", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: SettingsTheme.sectionPadding
                    StyledButton {
                        id: connectButton
                        text: Translator.translate("Connect", Settings.language)
                        onEnabledChanged: if (settingsLoaded)
                            AppSettings.setValue("ui/connectAtStartup", enabled)
                        onClicked: {
                            connectEcu();
                            connectButton.enabled = false;
                            ecuSelect.enabled = false;
                            disconnectButton.enabled = true;
                        }
                    }
                    StyledButton {
                        id: disconnectButton
                        text: Translator.translate("Disconnect", Settings.language)
                        primary: false
                        enabled: false
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
                        width: parent.width
                        height: parent.height
                        statusText: Diagnostics.canStatusText
                        status: {
                            if (Diagnostics.canStatusText === "Active")
                                return "connected";
                            if (Diagnostics.canStatusText === "Waiting")
                                return "pending";
                            return "disconnected";
                        }
                    }
                }

                SettingsRow {
                    label: Translator.translate("ECU Selection", Settings.language)
                    StyledComboBox {
                        id: ecuSelect
                        width: parent.width
                        height: parent.height
                        model: ["Extender Only", "CAN", "Generic CAN"]
                        property bool initialized: false
                        onCurrentIndexChanged: {
                            if (initialized) {
                                var backendIdx = ecuBackendMap[currentIndex];
                                AppSettings.setECU(backendIdx);
                                Connection.setecu(backendIdx);
                            }
                        }
                        Component.onCompleted: {
                            var stored = AppSettings.getECU();
                            currentIndex = ecuDropdownFromBackend(stored);
                            Connection.setecu(ecuBackendMap[currentIndex]);
                            initialized = true;
                            autoConnect();
                        }
                    }
                }
            }

            SettingsSection {
                title: Translator.translate("Units", Settings.language)
                Layout.fillWidth: true

                SettingsRow {
                    label: Translator.translate("Speed units", Settings.language)
                    StyledComboBox {
                        id: unitSelect1
                        width: parent.width
                        height: parent.height
                        model: [Translator.translate("Metric", Settings.language), Translator.translate("Imperial", Settings.language)]
                        Component.onCompleted: {
                            Connect.setSpeedUnits(currentIndex);
                            updateWeightLabel();
                        }
                        onCurrentIndexChanged: {
                            Connect.setSpeedUnits(currentIndex);
                            updateWeightLabel();
                            if (settingsLoaded)
                                AppSettings.setValue("ui/unitSelector1", currentIndex);
                        }
                    }
                }

                SettingsRow {
                    label: Translator.translate("Temp units", Settings.language)
                    StyledComboBox {
                        id: unitSelect
                        width: parent.width
                        height: parent.height
                        model: [Translator.translate("C", Settings.language), Translator.translate("F", Settings.language)]
                        Component.onCompleted: {
                            Connect.setUnits(currentIndex);
                            updateWeightLabel();
                        }
                        onCurrentIndexChanged: {
                            Connect.setUnits(currentIndex);
                            updateWeightLabel();
                            if (settingsLoaded)
                                AppSettings.setValue("ui/unitSelector", currentIndex);
                        }
                    }
                }

                SettingsRow {
                    label: Translator.translate("Pressure units", Settings.language)
                    StyledComboBox {
                        id: unitSelect2
                        width: parent.width
                        height: parent.height
                        model: ["kPa", "PSI"]
                        Component.onCompleted: Connect.setPressUnits(currentIndex)
                        onCurrentIndexChanged: {
                            Connect.setPressUnits(currentIndex);
                            if (settingsLoaded)
                                AppSettings.setValue("ui/unitSelector2", currentIndex);
                        }
                    }
                }
            }
        }

        // * MIDDLE COLUMN
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                title: Translator.translate("Vehicle", Settings.language)
                Layout.fillWidth: true

                SettingsRow {
                    id: weightRow
                    label: Translator.translate("Weight", Settings.language) + " kg"
                    StyledTextField {
                        id: weight
                        width: parent.width
                        height: parent.height
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onEditingFinished: AppSettings.setValue("ui/vehicleWeight", text)
                    }
                }

                SettingsRow {
                    label: Translator.translate("Odo", Settings.language)
                    StyledTextField {
                        id: odometer
                        width: parent.width
                        height: parent.height
                        text: "0"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onTextChanged: if (settingsLoaded)
                            AppSettings.setValue("ui/odometer", text)
                    }
                }

                RowLayout {
                    spacing: SettingsTheme.sectionPadding
                    Layout.fillWidth: true

                    Text {
                        text: Translator.translate("Trip", Settings.language)
                        font.pixelSize: SettingsTheme.fontLabel
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.preferredWidth: SettingsTheme.labelWidth
                    }
                    StyledTextField {
                        id: tripmeter
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        text: "0"
                        readOnly: true
                        onTextChanged: if (settingsLoaded)
                            AppSettings.setValue("ui/tripmeter", text)
                    }
                    StyledButton {
                        text: Translator.translate("Trip Reset", Settings.language)
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        primary: false
                        onClicked: Calculations.resettrip()
                    }
                }
            }

            SettingsSection {
                title: Translator.translate("CAN Bus", Settings.language)
                Layout.fillWidth: true

                SettingsRow {
                    label: Translator.translate("Can Bitrate", Settings.language)
                    StyledComboBox {
                        id: canbitrateselect
                        width: parent.width
                        height: parent.height
                        model: ["250 kbit/s", "500 kbit/s", "1 Mbit/s"]
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
                title: Translator.translate("Daemon / Startup", Settings.language)
                Layout.fillWidth: true
                visible: !isExtenderOnly

                SettingsRow {
                    label: Translator.translate("Daemon", Settings.language)
                    StyledComboBox {
                        width: parent.width
                        height: parent.height
                        model: ["Generic CAN"]
                        enabled: false
                    }
                }

                SettingsRow {
                    label: Translator.translate("Speed Source", Settings.language)
                    StyledComboBox {
                        id: mainspeedsource
                        width: parent.width
                        height: parent.height
                        model: ["ECU Speed", "LF Wheel", "RF Wheel", "LR Wheel", "RR Wheel", "GPS", "VR Sensor"]
                        onCurrentIndexChanged: {
                            if (settingsLoaded) {
                                AppSettings.writeStartupSettings(mainspeedsource.currentIndex);
                                AppSettings.setValue("ui/mainSpeedSource", currentIndex);
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
                title: Translator.translate("Data Logging", Settings.language)
                Layout.fillWidth: true

                SettingsRow {
                    label: Translator.translate("Logfile name", Settings.language)
                    StyledTextField {
                        id: logfilenameSelect
                        width: parent.width
                        height: parent.height
                        text: "DataLog"
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
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

        // * RIGHT COLUMN
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                title: "CAN Configuration"
                Layout.fillWidth: true

                Text {
                    text: "CAN Extender"
                    font.pixelSize: SettingsTheme.fontLabel
                    font.weight: Font.DemiBold
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.accent
                }

                Text {
                    text: Translator.translate("base adress", Settings.language) + " " + Translator.translate("(decimal)", Settings.language)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                }

                RowLayout {
                    spacing: SettingsTheme.controlGap
                    Layout.fillWidth: true
                    StyledTextField {
                        id: baseadresstext
                        Layout.preferredWidth: SettingsTheme.textFieldMinWidth
                        enabled: connectButton.enabled
                        placeholderText: "1024"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        validator: IntValidator {
                            bottom: 0
                            top: 4000
                        }
                        onTextChanged: hexstring = parseInt(baseadresstext.text) || 0
                        onEditingFinished: AppSettings.setValue("ui/extenderCanBase", text)
                    }
                    Text {
                        text: "HEX: 0x" + (hexstring + 0x1000).toString(16).substr(-3).toUpperCase()
                        font.pixelSize: SettingsTheme.fontLabel
                        font.weight: Font.DemiBold
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.accent
                    }
                }

                Item {
                    height: SettingsTheme.contentSpacing / 2
                    Layout.fillWidth: true
                }

                Text {
                    text: "Shiftlight CAN"
                    font.pixelSize: SettingsTheme.fontLabel
                    font.weight: Font.DemiBold
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.accent
                }

                Text {
                    text: Translator.translate("base adress", Settings.language) + " " + Translator.translate("(decimal)", Settings.language)
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                }

                RowLayout {
                    spacing: SettingsTheme.controlGap
                    Layout.fillWidth: true
                    StyledTextField {
                        id: shiftlightbaseadresstext
                        Layout.preferredWidth: SettingsTheme.textFieldMinWidth
                        enabled: connectButton.enabled
                        placeholderText: "1024"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        validator: IntValidator {
                            bottom: 0
                            top: 4000
                        }
                        onTextChanged: hexstring2 = parseInt(shiftlightbaseadresstext.text) || 0
                        onEditingFinished: AppSettings.setValue("ui/shiftLightCanBase", text)
                    }
                    Text {
                        text: "HEX: 0x" + (hexstring2 + 0x1000).toString(16).substr(-3).toUpperCase()
                        font.pixelSize: SettingsTheme.fontLabel
                        font.weight: Font.DemiBold
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.accent
                    }
                }
            }

            SettingsSection {
                title: "Display"
                Layout.fillWidth: true

                StyledButton {
                    text: "Show Brightness Popup"
                    onClicked: window.showBrightnessPopup()
                }
            }

            SettingsSection {
                title: Translator.translate("Language", Settings.language)
                Layout.fillWidth: true

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
                title: Translator.translate("System", Settings.language)
                Layout.fillWidth: true

                Text {
                    text: "V 1.99F " + Connection.Platform
                    font.pixelSize: SettingsTheme.fontStatus
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                }

                RowLayout {
                    spacing: SettingsTheme.sectionPadding

                    StyledButton {
                        text: Translator.translate("Quit", Settings.language)
                        primary: false
                        onClicked: Qt.quit()
                    }

                    StyledButton {
                        text: Translator.translate("Reboot", Settings.language)
                        primary: false
                        onClicked: Connect.reboot()
                    }

                    StyledButton {
                        text: Translator.translate("Shutdown", Settings.language)
                        danger: true
                        onClicked: Connect.shutdown()
                    }
                }
            }
        }
    }
}
