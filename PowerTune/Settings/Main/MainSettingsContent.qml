// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Core 1.0
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
    property bool autoConnectAttempted: false
    property bool autoConnectEnabled: false
    property int hexstring: 0
    property int hexstring2: 0
    property int ptHexstring: 0
    property bool loggerActive: false
    property bool settingsLoaded: false
    readonly property string appVersionText: (Updater && Updater.currentVersion !== "") ? Updater.currentVersion : (Qt.application.version !== "" ? Qt.application.version : "0.0.0")
    readonly property string buildVersionText: (typeof BuildVersion !== "undefined" && BuildVersion !== "") ? BuildVersion : appVersionText
    readonly property string buildProfileText: (typeof BuildProfile !== "undefined" && BuildProfile !== "") ? BuildProfile : "release"
    readonly property string buildDateText: (typeof BuildDateUtc !== "undefined" && BuildDateUtc !== "") ? BuildDateUtc : "unknown"
    readonly property string buildCommitText: (typeof BuildCommit !== "undefined" && BuildCommit !== "") ? BuildCommit : "unknown"
    readonly property string buildDependenciesText: (typeof BuildDependencies !== "undefined" && BuildDependencies !== "") ? BuildDependencies : "Qt 6.8.3, Yocto Scarthgap, meta-qt6"
    readonly property string buildNotesText: (typeof BuildNotes !== "undefined" && BuildNotes !== "") ? BuildNotes : "No build notes provided."

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
        Connect.openConnection();
    }

    function disconnectEcu() {
        Connect.closeConnection();
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
        autoConnectEnabled = AppSettings.getValue("ui/canAutoConnect", AppSettings.getValue("ui/connectAtStartup", false));
        AppSettings.setValue("ui/canAutoConnect", autoConnectEnabled);
        weight.text = AppSettings.getValue("ui/vehicleWeight", "0");
        unitSelect1.currentIndex = AppSettings.getValue("ui/unitSelector1", 0);
        unitSelect.currentIndex = AppSettings.getValue("ui/unitSelector", 0);
        unitSelect2.currentIndex = AppSettings.getValue("ui/unitSelector2", 0);
        odometer.text = AppSettings.getValue("ui/odometer", "0");
        tripmeter.text = AppSettings.getValue("ui/tripmeter", "0");
        exboardEnabledSwitch.checked = AppSettings.getValue("ui/exboard/enabled", true);
        ptEnabledSwitch.checked = AppSettings.getValue("ui/ptextender/enabled", true);
        baseadresstext.text = AppSettings.getValue("ui/extenderCanBase", "");
        shiftlightbaseadresstext.text = AppSettings.getValue("ui/shiftLightCanBase", "");
        ptextenderbaseadresstext.text = AppSettings.getValue("ui/ptextender/canBase", "");
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
            exboardEnabledSwitch.enabled = !isConnected;
            ptEnabledSwitch.enabled = !isConnected;
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

    Popup {
        id: buildInfoPopup

        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        modal: true
        padding: SettingsTheme.sectionPadding
        width: Math.min(root.width * 0.75, 780)

        background: Rectangle {
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth
            color: SettingsTheme.cardBg
            radius: SettingsTheme.radiusLarge
        }

        contentItem: ColumnLayout {
            spacing: SettingsTheme.contentSpacing

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontSectionTitle
                font.weight: Font.Bold
                text: Translator.translate("Build Information", Settings.language)
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontStatus
                text: "Software: " + root.buildVersionText + " | Platform: " + (Connection.Platform || "Unknown")
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamilyMono
                font.pixelSize: SettingsTheme.fontStatus
                text: "Build Profile: " + root.buildProfileText + "\nBuild Date UTC: " + root.buildDateText + "\nCommit: " + root.buildCommitText + "\nQt Runtime: " + Qt.version
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontLabel
                text: Translator.translate("Dependencies", Settings.language)
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontStatus
                text: root.buildDependenciesText
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontLabel
                text: Translator.translate("Notes", Settings.language)
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: 150

                TextArea {
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    readOnly: true
                    text: root.buildNotesText
                    wrapMode: TextEdit.WordWrap
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight

                StyledButton {
                    primary: false
                    text: Translator.translate("Close", Settings.language)
                    onClicked: buildInfoPopup.close()
                }
            }
        }
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
                    label: "EX Board Extender"

                    StyledSwitch {
                        id: exboardEnabledSwitch

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        onCheckedChanged: if (settingsLoaded)
                                              AppSettings.setValue("ui/exboard/enabled", checked)
                    }
                }

                MainSettingsRow {
                    label: "PT Extender"

                    StyledSwitch {
                        id: ptEnabledSwitch

                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        onCheckedChanged: if (settingsLoaded)
                                              AppSettings.setValue("ui/ptextender/enabled", checked)
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
                        model: ["ECU Speed", "LF Wheel", "RF Wheel", "LR Wheel", "RR Wheel", "GPS", "VR Sensor", "DFI Serial"]

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
                            placeholderText: "1536"

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
                            placeholderText: "1536"

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

                MainSettingsRow {
                    label: "PT Extender Base"
                    description: "CAN address (decimal)"

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: SettingsTheme.controlGap

                        StyledTextField {
                            id: ptextenderbaseadresstext

                            Layout.preferredWidth: SettingsTheme.textFieldMinWidth
                            Layout.preferredHeight: SettingsTheme.controlHeight
                            enabled: connectButton.enabled
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            placeholderText: "1536"

                            validator: IntValidator {
                                bottom: 0
                                top: 4000
                            }

                            onEditingFinished: AppSettings.setValue("ui/ptextender/canBase", text)
                            onTextChanged: ptHexstring = parseInt(ptextenderbaseadresstext.text) || 0
                        }

                        Text {
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamilyMono
                            font.pixelSize: SettingsTheme.fontStatus
                            text: "0x" + (ptHexstring + 0x1000).toString(16).substr(-3).toUpperCase()
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

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: SettingsTheme.controlGap

                        Text {
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamilyMono
                            font.pixelSize: SettingsTheme.fontStatus
                            text: root.appVersionText + " (" + (Connection.Platform || "Unknown") + ")"
                        }

                        StyledButton {
                            primary: false
                            text: Translator.translate("Info", Settings.language)
                            onClicked: buildInfoPopup.open()
                        }
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

            SettingsSection {
                Layout.fillWidth: true
                title: Translator.translate("Updates", Settings.language)

                MainSettingsRow {
                    label: Translator.translate("Current Version", Settings.language)

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Updater.currentVersion
                    }
                }

                MainSettingsRow {
                    label: Translator.translate("Latest Version", Settings.language)

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Updater.latestVersion === "" ? "-" : Updater.latestVersion
                    }
                }

                MainSettingsRow {
                    label: Translator.translate("Auth", Settings.language)

                    Text {
                        color: Updater.hasAuthToken ? SettingsTheme.success : SettingsTheme.warning
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Updater.hasAuthToken
                              ? Translator.translate("Token available", Settings.language)
                              : Translator.translate("Token missing", Settings.language)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: SettingsTheme.sectionPadding

                    StyledButton {
                        text: Translator.translate("Check for Updates", Settings.language)
                        onClicked: Updater.checkForUpdates()
                    }

                    StyledButton {
                        enabled: Updater.updateAvailable
                        primary: false
                        text: Translator.translate("Download Update", Settings.language)
                        onClicked: Updater.downloadUpdate()
                    }

                    StyledButton {
                        enabled: Updater.downloadReady
                        danger: true
                        text: Translator.translate("Install Update", Settings.language)
                        onClicked: Updater.installUpdate()
                    }
                }

                ProgressBar {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: Updater.downloadProgressPercent
                    visible: Updater.status === "downloading" || Updater.status === "verifying"
                }

                Text {
                    Layout.fillWidth: true
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontStatus
                    text: Updater.statusMessage
                    wrapMode: Text.WordWrap
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

            SettingsSection {
                Layout.fillWidth: true
                title: "DFI Serial"

                MainSettingsRow {
                    label: "Enabled"
                    description: "Read Kawasaki DFI codes via UART"

                    StyledSwitch {
                        id: dfiSerialEnabledSwitch
                        checked: DfiSerial ? DfiSerial.enabled : false
                        text: checked ? "On" : "Off"
                        onCheckedChanged: {
                            if (settingsLoaded && DfiSerial)
                                DfiSerial.enabled = checked;
                        }
                    }
                }

                MainSettingsRow {
                    label: "Port"

                    StyledTextField {
                        id: dfiSerialPort
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        text: DfiSerial ? DfiSerial.portPath : "/dev/ttyAMA0"
                        onEditingFinished: {
                            if (DfiSerial)
                                DfiSerial.portPath = text;
                        }
                    }
                }

                MainSettingsRow {
                    label: "Status"

                    ConnectionStatusIndicator {
                        Layout.fillWidth: true
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        status: {
                            if (!DfiSerial) return "disconnected";
                            if (DfiSerial.hasSignal) return "connected";
                            if (DfiSerial.connected) return "pending";
                            return "disconnected";
                        }
                        statusText: {
                            if (!DfiSerial) return "Unavailable";
                            if (DfiSerial.hasSignal) return "Receiving";
                            if (DfiSerial.connected) return "Connected (no signal)";
                            return "Disconnected";
                        }
                    }
                }

                MainSettingsRow {
                    label: "Gear / Codes"

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontStatus
                        text: DfiSerial ? ("Gear: " + DfiSerial.gearString + "  Codes: " + (DfiSerial.activeCodes || "none")) : "-"
                    }
                }

                StyledButton {
                    text: "DFI Code Filters"
                    onClicked: dfiCodeFilterPopup.open()
                }

                DfiCodeFilterPopup {
                    id: dfiCodeFilterPopup
                }
            }
        }
    }
}
