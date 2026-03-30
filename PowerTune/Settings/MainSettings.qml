// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

SettingsPage {
    id: root

    component MainSettingsRow: RowLayout {
        id: formRow

        default property alias control: controlContainer.data
        property string description: ""
        property string label: ""

        Layout.fillWidth: true
        spacing: SettingsTheme.controlGap

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.minimumWidth: 150
            Layout.preferredWidth: 150
            spacing: 4

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontLabel
                text: formRow.label
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontStatus
                text: formRow.description
                visible: formRow.description !== ""
                wrapMode: Text.WordWrap
            }
        }

        RowLayout {
            id: controlContainer

            Layout.fillWidth: true
            Layout.minimumHeight: SettingsTheme.controlHeight
            Layout.preferredHeight: childrenRect.height > 0 ? childrenRect.height : SettingsTheme.controlHeight
            spacing: SettingsTheme.controlGap
        }
    }

    property int connected: 0
    property int currentLanguage: (Settings && Settings.language !== undefined) ? Settings.language : 0
    readonly property var ecuBackendMap: [5]
    property bool autoConnectAttempted: false
    property bool autoConnectEnabled: false
    property int hexstring: 0
    property int hexstring2: 0
    readonly property bool isExtenderOnly: ecuBackendMap[ecuSelect.currentIndex] === 5
    property bool loggerActive: false
    property bool settingsLoaded: false

    function applyLanguage() {
        AppSettings.writeLanguage(languageselect.currentIndex);
    }

    function autoConnect() {
        if (!autoConnectEnabled || autoConnectAttempted || !connectButton.enabled)
            return;
        autoConnectAttempted = true;
        connectEcu();
    }

    function connectEcu() {
        Connect.setOdometer(odometer.text);
        Connect.setWeight(weight.text);
        var backendIdx = ecuBackendMap[ecuSelect.currentIndex];
        Connect.openConnection("", backendIdx, baseadresstext.text, shiftlightbaseadresstext.text);
    }

    function disconnectEcu() {
        Connect.closeConnection();
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
        if (settingsLoaded)
            return;
        connectButton.enabled = true;
        disconnectButton.enabled = false;
        ecuSelect.enabled = true;
        autoConnectEnabled = AppSettings.getValue("ui/canAutoConnect", AppSettings.getValue("ui/connectAtStartup", false));
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
        function onConnectionStateChanged(isConnected, statusMessage) {
            connectButton.enabled = !isConnected;
            disconnectButton.enabled = isConnected;
            ecuSelect.enabled = !isConnected;
            connected = isConnected ? 1 : 0;
        }

        target: Connect
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
        function onRpmChanged() {
            if (Engine.rpm > Settings.rpmwarn)
                triggerWarning();
        }

        target: Engine
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.sectionSpacing

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                Layout.fillWidth: true
                title: "CAN / Connection"

                RowLayout {
                    Layout.fillWidth: true
                    spacing: SettingsTheme.sectionPadding

                    StyledButton {
                        id: connectButton

                        text: Translator.translate("Connect", Settings.language)

                        onClicked: {
                            connectEcu();
                        }
                    }

                    StyledButton {
                        id: disconnectButton

                        enabled: false
                        primary: false
                        text: Translator.translate("Disconnect", Settings.language)

                        onClicked: {
                            disconnectEcu();
                        }
                    }
                }

                MainSettingsRow {
                    label: "Auto Connect"
                    description: "Connect CAN automatically on startup"

                    StyledSwitch {
                        checked: autoConnectEnabled
                        text: checked ? "On" : "Off"

                        onCheckedChanged: {
                            autoConnectEnabled = checked;
                            if (settingsLoaded)
                                AppSettings.setValue("ui/canAutoConnect", checked);
                        }
                    }
                }

                MainSettingsRow {
                    label: "CAN Status"

                    ConnectionStatusIndicator {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        status: {
                            if (Diagnostics.canStatusText === "Active")
                                return "connected";
                            if (Diagnostics.canStatusText === "Waiting")
                                return "pending";
                            return "disconnected";
                        }
                        statusText: Diagnostics.canStatusText
                    }
                }

                MainSettingsRow {
                    label: Translator.translate("ECU Selection", Settings.language)

                    StyledComboBox {
                        id: ecuSelect

                        property bool initialized: false

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        model: ["Extender Only"]

                        Component.onCompleted: {
                            var stored = AppSettings.getECU();
                            currentIndex = ecuDropdownFromBackend(stored);
                            AppSettings.setEcuIndex(currentIndex);
                            initialized = true;
                            autoConnect();
                        }
                        onCurrentIndexChanged: {
                            if (initialized)
                                AppSettings.setEcuIndex(currentIndex);
                        }
                    }
                }

                MainSettingsRow {
                    label: Translator.translate("CAN Bitrate", Settings.language)

                    StyledComboBox {
                        id: canbitrateselect

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        model: ["250 kbit/s", "500 kbit/s", "1 Mbit/s"]

                        onCurrentIndexChanged: if (settingsLoaded)
                                                   AppSettings.setValue("ui/bitrateSelect", currentIndex)
                    }
                }

                MainSettingsRow {
                    label: Translator.translate("Speed Source", Settings.language)

                    StyledComboBox {
                        id: mainspeedsource

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        model: ["ECU Speed", "LF Wheel", "RF Wheel", "LR Wheel", "RR Wheel", "GPS", "VR Sensor"]

                        onCurrentIndexChanged: {
                            if (settingsLoaded)
                                AppSettings.setMainSpeedSourceIndex(currentIndex);
                        }
                    }
                }

                MainSettingsRow {
                    label: "Extender Base"
                    description: "CAN address (decimal)"

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: SettingsTheme.controlGap

                        StyledTextField {
                            id: baseadresstext

                            Layout.preferredWidth: SettingsTheme.textFieldMinWidth
                            Layout.preferredHeight: SettingsTheme.controlHeight
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
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamilyMono
                            font.pixelSize: SettingsTheme.fontStatus
                            text: "0x" + (hexstring + 0x1000).toString(16).substr(-3).toUpperCase()
                        }
                    }
                }

                MainSettingsRow {
                    label: "Shiftlight Base"
                    description: "CAN address (decimal)"

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: SettingsTheme.controlGap

                        StyledTextField {
                            id: shiftlightbaseadresstext

                            Layout.preferredWidth: SettingsTheme.textFieldMinWidth
                            Layout.preferredHeight: SettingsTheme.controlHeight
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
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamilyMono
                            font.pixelSize: SettingsTheme.fontStatus
                            text: "0x" + (hexstring2 + 0x1000).toString(16).substr(-3).toUpperCase()
                        }
                    }
                }

                StyledButton {
                    text: Translator.translate("Apply CAN Settings", Settings.language)

                    onClicked: Connect.canbitratesetup(canbitrateselect.currentIndex)
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("System", Settings.language)

                MainSettingsRow {
                    label: "Version"

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "V 1.99F " + Connection.Platform
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
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

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: SettingsTheme.sectionPadding

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Vehicle", Settings.language)

                MainSettingsRow {
                    id: weightRow

                    label: Translator.translate("Weight", Settings.language) + " kg"

                    StyledTextField {
                        id: weight

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly

                        onEditingFinished: AppSettings.setValue("ui/vehicleWeight", text)
                    }
                }

                MainSettingsRow {
                    label: Translator.translate("Odo", Settings.language)

                    StyledTextField {
                        id: odometer

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: "0"

                        onTextChanged: if (settingsLoaded)
                                           AppSettings.setValue("ui/odometer", text)
                    }
                }

                MainSettingsRow {
                    label: Translator.translate("Trip", Settings.language)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: SettingsTheme.controlGap

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
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Units", Settings.language)

                MainSettingsRow {
                    label: Translator.translate("Speed units", Settings.language)

                    StyledComboBox {
                        id: unitSelect1

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        model: [Translator.translate("Metric", Settings.language), Translator.translate("Imperial", Settings.language)]

                        onCurrentIndexChanged: {
                            updateWeightLabel();
                            if (settingsLoaded)
                                AppSettings.setSpeedUnitIndex(currentIndex);
                        }
                    }
                }

                MainSettingsRow {
                    label: Translator.translate("Temp units", Settings.language)

                    StyledComboBox {
                        id: unitSelect

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        model: [Translator.translate("C", Settings.language), Translator.translate("F", Settings.language)]

                        onCurrentIndexChanged: {
                            updateWeightLabel();
                            if (settingsLoaded)
                                AppSettings.setTempUnitIndex(currentIndex);
                        }
                    }
                }

                MainSettingsRow {
                    label: Translator.translate("Pressure units", Settings.language)

                    StyledComboBox {
                        id: unitSelect2

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        model: ["kPa", "PSI"]

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

                MainSettingsRow {
                    label: Translator.translate("Language", Settings.language)

                    StyledComboBox {
                        id: languageselect

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        model: ["English", "Deutsch", "\u65E5\u672C\u8A9E", "Espanol"]

                        onCurrentIndexChanged: {
                            applyLanguage();
                            updateWeightLabel();
                            if (settingsLoaded)
                                AppSettings.setValue("Language", currentIndex);
                        }
                    }
                }
            }

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Data Logging", Settings.language)

                MainSettingsRow {
                    label: Translator.translate("Logfile name", Settings.language)

                    StyledTextField {
                        id: logfilenameSelect

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhSensitiveData
                                          | Qt.ImhNoPredictiveText
                        text: "DataLog"
                    }
                }

                MainSettingsRow {
                    label: Translator.translate("Data Logger", Settings.language)

                    StyledSwitch {
                        id: loggerswitch

                        Component.onCompleted: toggleDataLogger()
                        onClicked: toggleDataLogger()
                    }
                }
            }
        }
    }
}
