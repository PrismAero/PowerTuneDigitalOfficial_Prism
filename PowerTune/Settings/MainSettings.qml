// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtMultimedia
import Qt.labs.settings 1.0
import PowerTune.Settings 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    anchors.fill: parent
    color: "#1a1a2e"

    property int connected: 0
    property int hexstring: 0
    property int hexstring2: 0
    property int currentLanguage: Settings.language

    // * Settings persistence
    Item {
        id: powerTuneSettings
        Settings {
            property alias connectECUAtStartup: connectButton.enabled
            property alias connectGPSAtStartup: connectButtonGPS.enabled
            property alias serialPortName: serialName.currentText
            property alias gpsPortName: serialNameGPS.currentText
            property alias gpsPortNameindex: serialNameGPS.currentIndex
            property alias ecuType: ecuSelect.currentText
            property alias auxunit1: unitaux1.text
            property alias aux1: an1V0.text
            property alias aux2: an2V5.text
            property alias auxunit2: unitaux2.text
            property alias aux3: an3V0.text
            property alias aux4: an4V5.text
            property alias goProVariant: goProSelect.currentIndex
            property alias password: goPropass.text
            property alias vehicleweight: weight.text
            property alias unitSelector1: unitSelect1.currentIndex
            property alias unitSelector: unitSelect.currentIndex
            property alias unitSelector2: unitSelect2.currentIndex
            property alias odometervalue: odometer.text
            property alias tripmetervalue: tripmeter.text
            property alias smoothingrpm: smoothrpm.currentIndex
            property alias smoothingspeed: smoothspeed.currentIndex
            property alias extendercanbase: baseadresstext.text
            property alias shiftlightcanbase: shiftlightbaseadresstext.text
            property alias languagecombobox: languageselect.currentIndex
        }

        SoundEffect {
            id: warnsound
            source: "qrc:/Resources/Sounds/alarm.wav"
        }

        Connections {
            target: Vehicle
            onOdoChanged: odometer.text = Vehicle.Odo.toFixed(3)
        }
        Connections {
            target: Vehicle
            onTripChanged: tripmeter.text = Vehicle.Trip.toFixed(3)
        }
        Connections {
            target: Engine
            onWatertempChanged: { if (Engine.Watertemp > Settings.waterwarn) playwarning.start() }
        }
        Connections {
            target: Engine
            onRpmChanged: { if (Engine.rpm > Settings.rpmwarn) playwarning.start() }
        }
        Connections {
            target: Engine
            onKnockChanged: { if (Engine.Knock > Settings.knockwarn) playwarning.start() }
        }
        Connections {
            target: Engine
            onBoostPresChanged: { if (Engine.BoostPres > Settings.boostwarn) playwarning.start() }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // * LEFT COLUMN
        ColumnLayout {
            Layout.preferredWidth: (root.width - 56) / 3
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: 10

            // * Connection Section
            SettingsSection {
                title: Translator.translate("Connection", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 8
                    StyledButton {
                        id: connectButton
                        text: Translator.translate("Connect", Settings.language)
                        width: 150
                        onClicked: {
                            functconnect.connectfunc()
                            connectButton.enabled = false
                            ecuSelect.enabled = false
                            disconnectButton.enabled = true
                        }
                    }
                    StyledButton {
                        id: disconnectButton
                        text: Translator.translate("Disconnect", Settings.language)
                        width: 150
                        primary: false
                        enabled: false
                        onClicked: {
                            connectButton.enabled = true
                            disconnectButton.enabled = false
                            ecuSelect.enabled = true
                            functdisconnect.disconnectfunc()
                        }
                    }
                }

                RowLayout {
                    spacing: 8
                    StyledButton {
                        id: connectButtonGPS
                        text: Translator.translate("GPS Connect", Settings.language)
                        width: 150
                        Component.onCompleted: autoconnectGPS.auto()
                        onClicked: {
                            connectButtonGPS.enabled = false
                            disconnectButtonGPS.enabled = true
                            autoconnectGPS.auto()
                        }
                    }
                    StyledButton {
                        id: disconnectButtonGPS
                        text: Translator.translate("GPS Disconnect", Settings.language)
                        width: 150
                        primary: false
                        enabled: false
                        onClicked: {
                            connectButtonGPS.enabled = true
                            disconnectButtonGPS.enabled = false
                            Gps.closeConnection()
                        }
                    }
                }

                // * ECU Serial Port (visible for PowerFC)
                RowLayout {
                    visible: ecuSelect.currentIndex === 1
                    spacing: 12
                    Text {
                        text: Translator.translate("ECU Serial Port", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledComboBox {
                        id: serialName
                        width: 200
                        model: Connect.portsNames
                        property bool initialized: false
                        onCurrentIndexChanged: {
                            if (initialized) AppSettings.setBaudRate(currentIndex)
                        }
                        Component.onCompleted: {
                            currentIndex = AppSettings.getBaudRate()
                            initialized = true
                            autoconnect.auto()
                        }
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("GPS Port", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledComboBox {
                        id: serialNameGPS
                        width: 200
                        model: Connect.portsNames
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Serial Status", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    ConnectionStatusIndicator {
                        statusText: Connection.SerialStat
                        status: Connection.SerialStat === "Connected" ? "connected" : "disconnected"
                        width: 200
                    }
                }
            }

            // * ECU Configuration Section
            SettingsSection {
                title: Translator.translate("ECU Configuration", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("ECU Selection", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledComboBox {
                        id: ecuSelect
                        width: 200
                        model: ["CAN", "PowerFC", "Consult", "OBD2", "Generic CAN"]
                        property bool initialized: false
                        onCurrentIndexChanged: {
                            if (initialized) {
                                AppSettings.setECU(currentIndex)
                                Connection.setecu(ecuSelect.currentIndex)
                            }
                        }
                        Component.onCompleted: {
                            currentIndex = AppSettings.getECU()
                            Connection.setecu(ecuSelect.currentIndex)
                            initialized = true
                        }
                    }
                }

                // * Smoothing options (visible for Consult)
                RowLayout {
                    visible: Connection.ecu === 2
                    spacing: 12
                    Text {
                        text: Translator.translate("RPM Smoothing", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledComboBox {
                        id: smoothrpm
                        width: 200
                        model: [Translator.translate("OFF", Settings.language), "2", "3", "4", "5", "6", "7", "8", "9", "10"]
                        onCurrentIndexChanged: Settings.setsmoothrpm(smoothrpm.currentIndex)
                        Component.onCompleted: Settings.setsmoothrpm(smoothrpm.currentIndex)
                    }
                }

                RowLayout {
                    visible: Connection.ecu === 2
                    spacing: 12
                    Text {
                        text: Translator.translate("Speed Smoothing", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledComboBox {
                        id: smoothspeed
                        width: 200
                        model: [Translator.translate("OFF", Settings.language), "2", "3", "4", "5", "6", "7", "8", "9", "10"]
                        onCurrentIndexChanged: Settings.setsmoothspeed(smoothspeed.currentIndex)
                        Component.onCompleted: Settings.setsmoothspeed(smoothspeed.currentIndex)
                    }
                }
            }

            // * Units Section
            SettingsSection {
                title: Translator.translate("Units", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Speed units", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledComboBox {
                        id: unitSelect1
                        width: 200
                        model: [Translator.translate("Metric", Settings.language), Translator.translate("Imperial", Settings.language)]
                        Component.onCompleted: {
                            Connect.setSpeedUnits(currentIndex)
                            changeweighttext.changetext()
                        }
                        onCurrentIndexChanged: {
                            Connect.setSpeedUnits(currentIndex)
                            changeweighttext.changetext()
                        }
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Temp units", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledComboBox {
                        id: unitSelect
                        width: 200
                        model: [Translator.translate("C", Settings.language), Translator.translate("F", Settings.language)]
                        Component.onCompleted: {
                            Connect.setUnits(currentIndex)
                            changeweighttext.changetext()
                        }
                        onCurrentIndexChanged: {
                            Connect.setUnits(currentIndex)
                            changeweighttext.changetext()
                        }
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Pressure units", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledComboBox {
                        id: unitSelect2
                        width: 200
                        model: ["kPa", "PSI"]
                        Component.onCompleted: Connect.setPressUnits(currentIndex)
                        onCurrentIndexChanged: Connect.setPressUnits(currentIndex)
                    }
                }
            }
        }

        // * MIDDLE COLUMN
        ColumnLayout {
            Layout.preferredWidth: (root.width - 56) / 3
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: 10

            // * Vehicle Section
            SettingsSection {
                title: Translator.translate("Vehicle", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    Text {
                        id: weighttext
                        text: Translator.translate("Weight", Settings.language) + " kg"
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledTextField {
                        id: weight
                        width: 200
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Odo", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledTextField {
                        id: odometer
                        width: 200
                        text: "0"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Trip", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledTextField {
                        id: tripmeter
                        width: 140
                        text: "0"
                        readOnly: true
                        Component.onCompleted: Vehicle.setTrip(tripmeter.text)
                    }
                    StyledButton {
                        text: Translator.translate("Trip Reset", Settings.language)
                        width: 100
                        primary: false
                        onClicked: Calculations.resettrip()
                    }
                }
            }

            // * Data Logging Section
            SettingsSection {
                title: Translator.translate("Data Logging", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Logfile name", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledTextField {
                        id: logfilenameSelect
                        width: 200
                        text: "DataLog"
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                    }
                }

                StyledSwitch {
                    id: loggerswitch
                    label: Translator.translate("Data Logger", Settings.language)
                    Component.onCompleted: logger.datalogger()
                    onClicked: logger.datalogger()
                }

                StyledSwitch {
                    id: nmeaLog
                    label: Translator.translate("NMEA Logger", Settings.language)
                    onClicked: GPS.setNMEAlog(nmeaLog.checked ? 1 : 0)
                    Component.onCompleted: tabView.currentIndex = 1
                }
            }

            // * GoPro Section
            SettingsSection {
                title: "GoPro"
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("GoPro Variant", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledComboBox {
                        id: goProSelect
                        width: 200
                        model: ["Hero", "Hero2", "Hero3"]
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("GoPro Pasword", Settings.language)
                        font.pixelSize: 16
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 140
                    }
                    StyledTextField {
                        id: goPropass
                        width: 200
                        placeholderText: Translator.translate("GoPro Pasword", Settings.language)
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                        Component.onCompleted: transferSettings.sendSettings()
                    }
                }

                StyledSwitch {
                    id: record
                    label: Translator.translate("GoPro rec", Settings.language)
                    onClicked: { transferSettings.sendSettings(); goproRec.rec() }
                }
            }

            // * Analog Inputs Section (PowerFC only)
            SettingsSection {
                title: "Analog Inputs"
                visible: ecuSelect.currentIndex === 1
                Layout.fillWidth: true

                GridLayout {
                    columns: 4
                    rowSpacing: 4
                    columnSpacing: 8

                    Text { text: ""; font.pixelSize: 14; color: "#B0B0B0" }
                    Text { text: "0V"; font.pixelSize: 14; color: "#B0B0B0" }
                    Text { text: "5V"; font.pixelSize: 14; color: "#B0B0B0" }
                    Text { text: "Name"; font.pixelSize: 14; color: "#B0B0B0" }

                    Text { text: "AN1-2"; font.pixelSize: 14; color: "#FFFFFF" }
                    StyledTextField { id: an1V0; width: 80; placeholderText: "9"; inputMethodHints: Qt.ImhFormattedNumbersOnly }
                    StyledTextField { id: an2V5; width: 80; placeholderText: "16"; inputMethodHints: Qt.ImhFormattedNumbersOnly }
                    StyledTextField { id: unitaux1; width: 80; placeholderText: "AFR" }

                    Text { text: "AN3-4"; font.pixelSize: 14; color: "#FFFFFF" }
                    StyledTextField { id: an3V0; width: 80; placeholderText: "0"; inputMethodHints: Qt.ImhFormattedNumbersOnly }
                    StyledTextField { id: an4V5; width: 80; placeholderText: "5"; inputMethodHints: Qt.ImhFormattedNumbersOnly }
                    StyledTextField { id: unitaux2; width: 80; placeholderText: "AFR" }
                }
            }
        }

        // * RIGHT COLUMN
        ColumnLayout {
            Layout.preferredWidth: (root.width - 56) / 3
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: 10

            // * CAN Configuration Section
            SettingsSection {
                title: "CAN Configuration"
                Layout.fillWidth: true

                // CAN Extender
                Text {
                    text: "CAN Extender"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    font.family: "Lato"
                    color: "#009688"
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("base adress", Settings.language) + " " + Translator.translate("(decimal)", Settings.language)
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: baseadresstext
                        width: 100
                        enabled: connectButton.enabled
                        placeholderText: "1024"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        validator: IntValidator { bottom: 0; top: 4000 }
                        onTextChanged: hexstring = parseInt(baseadresstext.text) || 0
                    }
                    Text {
                        text: "HEX: 0x" + (hexstring + 0x1000).toString(16).substr(-3).toUpperCase()
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: "#009688"
                    }
                }

                // Shiftlight CAN
                Text {
                    text: "Shiftlight CAN"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    font.family: "Lato"
                    color: "#009688"
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("base adress", Settings.language) + " " + Translator.translate("(decimal)", Settings.language)
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: shiftlightbaseadresstext
                        width: 100
                        enabled: connectButton.enabled
                        placeholderText: "1024"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        validator: IntValidator { bottom: 0; top: 4000 }
                        onTextChanged: hexstring2 = parseInt(shiftlightbaseadresstext.text) || 0
                    }
                    Text {
                        text: "HEX: 0x" + (hexstring2 + 0x1000).toString(16).substr(-3).toUpperCase()
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: "#009688"
                    }
                }
            }

            // * Language Section
            SettingsSection {
                title: Translator.translate("Language", Settings.language)
                Layout.fillWidth: true

                StyledComboBox {
                    id: languageselect
                    width: 280

                    model: ["English", "Deutsch", "\u65E5\u672C\u8A9E", "Espanol"]

                    onCurrentIndexChanged: {
                        functLanguageselect.languageselectfunct()
                        changeweighttext.changetext()
                    }
                }
            }

            // * System Section
            SettingsSection {
                title: Translator.translate("System", Settings.language)
                Layout.fillWidth: true

                Text {
                    text: "V 1.99F " + Connection.Platform
                    font.pixelSize: 14
                    font.family: "Lato"
                    color: "#B0B0B0"
                }

                RowLayout {
                    spacing: 8

                    StyledButton {
                        text: Translator.translate("Quit", Settings.language)
                        width: 120
                        primary: false
                        onClicked: Qt.quit()
                    }

                    StyledButton {
                        text: Translator.translate("Reboot", Settings.language)
                        width: 120
                        primary: false
                        onClicked: Connect.reboot()
                    }

                    StyledButton {
                        text: Translator.translate("Shutdown", Settings.language)
                        width: 120
                        danger: true
                        onClicked: Connect.shutdown()
                    }
                }
            }
        }
    }

    // * Helper Functions
    Item {
        id: autoconnect
        function auto() {
            if (connectButton.enabled === false) {
                functconnect.connectfunc()
                ecuSelect.enabled = false
                disconnectButton.enabled = true
            }
        }
    }

    Item {
        id: autoconnectGPS
        function auto() {
            if (connectButtonGPS.enabled === false) {
                Gps.openConnection(serialNameGPS.currentText, "9600")
                disconnectButtonGPS.enabled = true
            }
        }
    }

    Item {
        id: changeweighttext
        function changetext() {
            if (unitSelect.currentIndex === 0)
                weighttext.text = Translator.translate("Weight", Settings.language) + " kg"
            if (unitSelect.currentIndex === 1)
                weighttext.text = Translator.translate("Weight", Settings.language) + " lbs"
        }
    }

    Item {
        id: goproRec
        property int recording: 0
        function rec() {
            if (record.checked) {
                goproRec.recording = 1
                GoPro.goprorec(recording)
            } else {
                goproRec.recording = 0
                GoPro.goprorec(recording)
            }
        }
    }

    Item {
        id: logger
        property int loggeron: 0
        function datalogger() {
            if (loggerswitch.checked) {
                logger.loggeron = 1
                Logger.startLog(logfilenameSelect.text)
            } else {
                logger.loggeron = 0
                Logger.stopLog()
            }
        }
    }

    Item {
        id: transferSettings
        function sendSettings() {
            GoPro.goProSettings(goProSelect.currentIndex, goPropass.text)
        }
    }

    Item {
        id: functconnect
        function connectfunc() {
            Connect.setOdometer(odometer.text)
            Connect.setWeight(weight.text)
            Connect.openConnection(serialName.currentText, ecuSelect.currentIndex, baseadresstext.text, shiftlightbaseadresstext.text)
            Apexi.calculatorAux(an1V0.text, an2V5.text, an3V0.text, an4V5.text, unitaux1.text, unitaux2.text)
            connected = 1
        }
    }

    Item {
        id: functdisconnect
        function disconnectfunc() {
            Connect.closeConnection()
            connected = 0
        }
    }

    Item {
        id: playwarning
        function start() {
            if (!warnsound.playing) warnsound.play()
        }
    }

    Item {
        id: functLanguageselect
        function languageselectfunct() {
            AppSettings.writeLanguage(languageselect.currentIndex)
        }
    }

    Item {
        id: autoconnectArd
        Component.onCompleted: autoconnectArd.auto()
        function auto() {
            if (Connection.externalspeedconnectionrequest === 1) {
                Arduino.openConnection(Connection.externalspeedport, "9600")
            }
        }
    }
}
