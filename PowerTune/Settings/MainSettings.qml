// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    anchors.fill: parent
    color: "#1a1a2e"

    property int connected: 0
    property int hexstring: 0
    property int hexstring2: 0
    property int currentLanguage: (Settings && Settings.language !== undefined) ? Settings.language : 0

    readonly property var ecuBackendMap: [0, 4]
    readonly property int genericCanDaemonIndex: 40

    function ecuDropdownFromBackend(backendIdx) {
        for (var i = 0; i < ecuBackendMap.length; i++) {
            if (ecuBackendMap[i] === backendIdx) return i
        }
        return 0
    }

    Item {
        id: powerTuneSettings
        Settings {
            property alias connectECUAtStartup: connectButton.enabled
            property alias ecuType: ecuSelect.currentText
            property alias vehicleweight: weight.text
            property alias unitSelector1: unitSelect1.currentIndex
            property alias unitSelector: unitSelect.currentIndex
            property alias unitSelector2: unitSelect2.currentIndex
            property alias odometervalue: odometer.text
            property alias tripmetervalue: tripmeter.text
            property alias extendercanbase: baseadresstext.text
            property alias shiftlightcanbase: shiftlightbaseadresstext.text
            property alias languagecombobox: languageselect.currentIndex
            property alias mainspeedsource: mainspeedsource.currentIndex
            property alias bitrateselect: canbitrateselect.currentIndex
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
        // Boost warning is evaluated by the shared warning loader.
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // * LEFT COLUMN
        ColumnLayout {
            Layout.preferredWidth: (root.width - 64) / 3
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: 12

            SettingsSection {
                title: Translator.translate("Connection", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    StyledButton {
                        id: connectButton
                        text: Translator.translate("Connect", Settings.language)
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

                Item { height: 8; Layout.fillWidth: true }

                RowLayout {
                    spacing: 12
                    Text {
                        text: "CAN Status"
                        font.pixelSize: 18
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    ConnectionStatusIndicator {
                        statusText: Diagnostics.canStatusText
                        status: {
                            if (Diagnostics.canStatusText === "Active") return "connected"
                            if (Diagnostics.canStatusText === "Waiting") return "pending"
                            return "disconnected"
                        }
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("ECU Selection", Settings.language)
                        font.pixelSize: 18
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledComboBox {
                        id: ecuSelect
                        Layout.fillWidth: true
                        model: ["CAN", "Generic CAN"]
                        property bool initialized: false
                        onCurrentIndexChanged: {
                            if (initialized) {
                                var backendIdx = ecuBackendMap[currentIndex]
                                AppSettings.setECU(backendIdx)
                                Connection.setecu(backendIdx)
                            }
                        }
                        Component.onCompleted: {
                            var stored = AppSettings.getECU()
                            currentIndex = ecuDropdownFromBackend(stored)
                            Connection.setecu(ecuBackendMap[currentIndex])
                            initialized = true
                            autoconnect.auto()
                        }
                    }
                }
            }

            SettingsSection {
                title: Translator.translate("Units", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Speed units", Settings.language)
                        font.pixelSize: 18
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledComboBox {
                        id: unitSelect1
                        Layout.fillWidth: true
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
                        font.pixelSize: 18
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledComboBox {
                        id: unitSelect
                        Layout.fillWidth: true
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
                        font.pixelSize: 18
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledComboBox {
                        id: unitSelect2
                        Layout.fillWidth: true
                        model: ["kPa", "PSI"]
                        Component.onCompleted: Connect.setPressUnits(currentIndex)
                        onCurrentIndexChanged: Connect.setPressUnits(currentIndex)
                    }
                }
            }
        }

        // * MIDDLE COLUMN
        ColumnLayout {
            Layout.preferredWidth: (root.width - 64) / 3
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: 12

            SettingsSection {
                title: Translator.translate("Vehicle", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    Text {
                        id: weighttext
                        text: Translator.translate("Weight", Settings.language) + " kg"
                        font.pixelSize: 18
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: weight
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Odo", Settings.language)
                        font.pixelSize: 18
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: odometer
                        Layout.fillWidth: true
                        text: "0"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Trip", Settings.language)
                        font.pixelSize: 18
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: tripmeter
                        Layout.fillWidth: true
                        text: "0"
                        readOnly: true
                        Component.onCompleted: Vehicle.setTrip(tripmeter.text)
                    }
                    StyledButton {
                        text: Translator.translate("Trip Reset", Settings.language)
                        primary: false
                        onClicked: Calculations.resettrip()
                    }
                }
            }

            SettingsSection {
                title: Translator.translate("Startup / CAN", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Daemon", Settings.language)
                        font.pixelSize: 18
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledComboBox {
                        Layout.fillWidth: true
                        model: ["Generic CAN"]
                        enabled: false
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Can Bitrate", Settings.language)
                        font.pixelSize: 18
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledComboBox {
                        id: canbitrateselect
                        Layout.fillWidth: true
                        model: ["250 kbit/s", "500 kbit/s", "1 Mbit/s"]
                    }
                }

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Speed Source", Settings.language)
                        font.pixelSize: 18
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledComboBox {
                        id: mainspeedsource
                        Layout.fillWidth: true
                        model: ["ECU Speed", "LF Wheel", "RF Wheel", "LR Wheel", "RR Wheel", "GPS", "VR Sensor"]
                        onCurrentIndexChanged: AppSettings.writeStartupSettings(mainspeedsource.currentIndex)
                    }
                }

                StyledButton {
                    text: Translator.translate("Apply Startup", Settings.language)
                    onClicked: {
                        Connect.daemonstartup(genericCanDaemonIndex)
                        Connect.canbitratesetup(canbitrateselect.currentIndex)
                    }
                }
            }

            SettingsSection {
                title: Translator.translate("Data Logging", Settings.language)
                Layout.fillWidth: true

                RowLayout {
                    spacing: 12
                    Text {
                        text: Translator.translate("Logfile name", Settings.language)
                        font.pixelSize: 18
                        font.family: "Lato"
                        color: "#FFFFFF"
                        Layout.preferredWidth: 160
                    }
                    StyledTextField {
                        id: logfilenameSelect
                        Layout.fillWidth: true
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
            }
        }

        // * RIGHT COLUMN
        ColumnLayout {
            Layout.preferredWidth: (root.width - 64) / 3
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: 12

            SettingsSection {
                title: "CAN Configuration"
                Layout.fillWidth: true

                Text {
                    text: "CAN Extender"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    font.family: "Lato"
                    color: "#009688"
                }

                Text {
                    text: Translator.translate("base adress", Settings.language) + " " + Translator.translate("(decimal)", Settings.language)
                    font.pixelSize: 16
                    font.family: "Lato"
                    color: "#B0B0B0"
                }

                RowLayout {
                    spacing: 16
                    Layout.fillWidth: true
                    StyledTextField {
                        id: baseadresstext
                        width: 120
                        enabled: connectButton.enabled
                        placeholderText: "1024"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        validator: IntValidator { bottom: 0; top: 4000 }
                        onTextChanged: hexstring = parseInt(baseadresstext.text) || 0
                    }
                    Text {
                        text: "HEX: 0x" + (hexstring + 0x1000).toString(16).substr(-3).toUpperCase()
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#009688"
                    }
                }

                Item { height: 4; Layout.fillWidth: true }

                Text {
                    text: "Shiftlight CAN"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    font.family: "Lato"
                    color: "#009688"
                }

                Text {
                    text: Translator.translate("base adress", Settings.language) + " " + Translator.translate("(decimal)", Settings.language)
                    font.pixelSize: 16
                    font.family: "Lato"
                    color: "#B0B0B0"
                }

                RowLayout {
                    spacing: 16
                    Layout.fillWidth: true
                    StyledTextField {
                        id: shiftlightbaseadresstext
                        width: 120
                        enabled: connectButton.enabled
                        placeholderText: "1024"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        validator: IntValidator { bottom: 0; top: 4000 }
                        onTextChanged: hexstring2 = parseInt(shiftlightbaseadresstext.text) || 0
                    }
                    Text {
                        text: "HEX: 0x" + (hexstring2 + 0x1000).toString(16).substr(-3).toUpperCase()
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: "#009688"
                    }
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
                        functLanguageselect.languageselectfunct()
                        changeweighttext.changetext()
                    }
                }
            }

            SettingsSection {
                title: Translator.translate("System", Settings.language)
                Layout.fillWidth: true

                Text {
                    text: "V 1.99F " + Connection.Platform
                    font.pixelSize: 16
                    font.family: "Lato"
                    color: "#B0B0B0"
                }

                RowLayout {
                    spacing: 12

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
        id: changeweighttext
        function changetext() {
            if (unitSelect.currentIndex === 0)
                weighttext.text = Translator.translate("Weight", Settings.language) + " kg"
            if (unitSelect.currentIndex === 1)
                weighttext.text = Translator.translate("Weight", Settings.language) + " lbs"
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
        id: functconnect
        function connectfunc() {
            Connect.setOdometer(odometer.text)
            Connect.setWeight(weight.text)
            var backendIdx = ecuBackendMap[ecuSelect.currentIndex]
            Connect.openConnection("", backendIdx, baseadresstext.text, shiftlightbaseadresstext.text)
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
        }
    }

    Item {
        id: functLanguageselect
        function languageselectfunct() {
            AppSettings.writeLanguage(languageselect.currentIndex)
        }
    }
}
