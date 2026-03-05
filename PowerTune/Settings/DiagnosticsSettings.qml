// Copyright (c) 2026 Kai Wyborny. All rights reserved.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0

Item {
    id: root
    anchors.fill: parent

    readonly property color panelBg: "#1e1e3a"
    readonly property color panelBorder: "#2a2a4a"
    readonly property color pageBg: "#1a1a2e"
    readonly property color accentColor: "#009688"
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#B0B0B0"
    readonly property color errorColor: "#ff1744"
    readonly property color connectedColor: "#00c853"
    readonly property color disconnectedColor: "#ff1744"
    readonly property color consoleBg: "#0d0d1a"
    readonly property color consoleText: "#00ff88"

    property bool showAllSensors: true

    ListModel {
        id: liveDataModel
    }

    Timer {
        id: liveDataTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: refreshLiveData()
    }

    function refreshLiveData() {
        liveDataModel.clear()
        var entries = [
            { name: "RPM",            source: "Engine",   value: Engine ? Engine.rpm : 0,                     unit: "rpm" },
            { name: "Speed",          source: "Vehicle",  value: Vehicle ? Vehicle.speed : 0,                 unit: "km/h" },
            { name: "Water Temp",     source: "Engine",   value: Engine ? Engine.Watertemp : 0,               unit: "C" },
            { name: "Intake Temp",    source: "Engine",   value: Engine ? Engine.Intaketemp : 0,              unit: "C" },
            { name: "Boost",          source: "Engine",   value: Engine ? Engine.BoostPres : 0,               unit: "kPa" },
            { name: "MAP",            source: "Engine",   value: Engine ? Engine.MAP : 0,                     unit: "kPa" },
            { name: "TPS",            source: "Engine",   value: Engine ? Engine.TPS : 0,                     unit: "%" },
            { name: "Inj Duty",       source: "Engine",   value: Engine ? Engine.InjDuty : 0,                 unit: "%" },
            { name: "Ignition",       source: "Engine",   value: Engine ? Engine.Ign : 0,                     unit: "deg" },
            { name: "AFR",            source: "Engine",   value: Engine ? Engine.AFR : 0,                     unit: "" },
            { name: "Knock",          source: "Engine",   value: Engine ? Engine.Knock : 0,                   unit: "" },
            { name: "Battery",        source: "Engine",   value: Engine ? Engine.BatteryV : 0,                unit: "V" },
            { name: "Oil Pressure",   source: "Engine",   value: Engine ? Engine.oilpres : 0,                 unit: "kPa" },
            { name: "Oil Temp",       source: "Engine",   value: Engine ? Engine.oiltemp : 0,                 unit: "C" },
            { name: "Fuel Pressure",  source: "Engine",   value: Engine ? Engine.FuelPress : 0,               unit: "kPa" },
            { name: "Gear",           source: "Vehicle",  value: Vehicle ? Vehicle.Gear : 0,                  unit: "" },
            { name: "Odometer",       source: "Vehicle",  value: Vehicle ? Vehicle.Odo : 0,                   unit: "km" },
            { name: "EX AN 0",        source: "Expander", value: Expander ? Expander.EXAnalogInput0 : 0,      unit: "V" },
            { name: "EX AN 1",        source: "Expander", value: Expander ? Expander.EXAnalogInput1 : 0,      unit: "V" },
            { name: "EX AN 2",        source: "Expander", value: Expander ? Expander.EXAnalogInput2 : 0,      unit: "V" },
            { name: "EX AN 3",        source: "Expander", value: Expander ? Expander.EXAnalogInput3 : 0,      unit: "V" },
            { name: "EX AN 4",        source: "Expander", value: Expander ? Expander.EXAnalogInput4 : 0,      unit: "V" },
            { name: "EX AN 5",        source: "Expander", value: Expander ? Expander.EXAnalogInput5 : 0,      unit: "V" },
            { name: "EX AN 6",        source: "Expander", value: Expander ? Expander.EXAnalogInput6 : 0,      unit: "V" },
            { name: "EX AN 7",        source: "Expander", value: Expander ? Expander.EXAnalogInput7 : 0,      unit: "V" },
            { name: "Analog 0",       source: "ECU",      value: Analog ? Analog.Analog0 : 0,                 unit: "V" },
            { name: "Analog 1",       source: "ECU",      value: Analog ? Analog.Analog1 : 0,                 unit: "V" },
            { name: "Analog 2",       source: "ECU",      value: Analog ? Analog.Analog2 : 0,                 unit: "V" },
            { name: "Analog 3",       source: "ECU",      value: Analog ? Analog.Analog3 : 0,                 unit: "V" },
            { name: "Analog 4",       source: "ECU",      value: Analog ? Analog.Analog4 : 0,                 unit: "V" },
            { name: "EX Digi 1",      source: "Expander", value: Expander ? Expander.EXDigitalInput1 : 0,     unit: "" },
            { name: "EX Digi 2",      source: "Expander", value: Expander ? Expander.EXDigitalInput2 : 0,     unit: "" },
            { name: "EX Digi 3",      source: "Expander", value: Expander ? Expander.EXDigitalInput3 : 0,     unit: "" },
            { name: "EX Digi 4",      source: "Expander", value: Expander ? Expander.EXDigitalInput4 : 0,     unit: "" },
            { name: "EX Digi 5",      source: "Expander", value: Expander ? Expander.EXDigitalInput5 : 0,     unit: "" },
            { name: "EX Digi 6",      source: "Expander", value: Expander ? Expander.EXDigitalInput6 : 0,     unit: "" },
            { name: "EX Digi 7",      source: "Expander", value: Expander ? Expander.EXDigitalInput7 : 0,     unit: "" },
            { name: "EX Digi 8",      source: "Expander", value: Expander ? Expander.EXDigitalInput8 : 0,     unit: "" }
        ]
        for (var i = 0; i < entries.length; i++) {
            if (showAllSensors || Math.abs(entries[i].value) > 0.001) {
                liveDataModel.append(entries[i])
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: pageBg
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // * TOP ROW: System + Connection
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 230
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: panelBg
                radius: 6
                border.color: panelBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    Text {
                        text: "System"
                        font.pixelSize: 18; font.weight: Font.Bold; font.family: "Lato"
                        color: accentColor
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#3D3D3D" }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "CPU Temp"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Text { text: Diagnostics.cpuTemperature.toFixed(1) + " C"; font.pixelSize: 15; font.family: "Lato"; color: textPrimary }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "CPU Load"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Text { text: Diagnostics.cpuLoadAverage.toFixed(2); font.pixelSize: 15; font.family: "Lato"; color: textPrimary }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "RAM"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Text { text: Diagnostics.memoryUsedMB.toFixed(0) + " / " + Diagnostics.memoryTotalMB.toFixed(0) + " MB (" + Diagnostics.memoryUsagePercent.toFixed(1) + "%)"; font.pixelSize: 15; font.family: "Lato"; color: textPrimary }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Disk"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Text { text: Diagnostics.diskUsagePercent.toFixed(1) + "% used"; font.pixelSize: 15; font.family: "Lato"; color: textPrimary }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Uptime"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Text { text: Diagnostics.uptime; font.pixelSize: 15; font.family: "Lato"; color: textPrimary }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Platform"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Text { text: Connection ? Connection.Platform : "Unknown"; font.pixelSize: 15; font.family: "Lato"; color: textPrimary }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Sensors"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Text { text: Diagnostics.activeSensorCount + " / " + Diagnostics.totalSensorCount; font.pixelSize: 15; font.family: "Lato"; color: textPrimary }
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: panelBg
                radius: 6
                border.color: panelBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    Text {
                        text: "Connection"
                        font.pixelSize: 18; font.weight: Font.Bold; font.family: "Lato"
                        color: accentColor
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#3D3D3D" }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "CAN Status"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Rectangle {
                            width: 10; height: 10; radius: 5
                            color: {
                                if (Diagnostics.canStatusText === "Active") return connectedColor
                                if (Diagnostics.canStatusText === "Waiting") return "#FF9800"
                                return disconnectedColor
                            }
                        }
                        Text {
                            text: Diagnostics.canStatusText
                            font.pixelSize: 15; font.family: "Lato"
                            color: {
                                if (Diagnostics.canStatusText === "Active") return connectedColor
                                if (Diagnostics.canStatusText === "Waiting") return "#FF9800"
                                return disconnectedColor
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Daemon"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Text { text: Diagnostics.daemonName; font.pixelSize: 15; font.family: "Lato"; color: textPrimary }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "CAN Rate"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Text { text: Diagnostics.canMessageRate + " msg/s"; font.pixelSize: 15; font.family: "Lato"; color: textPrimary }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "CAN Total"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Text { text: Diagnostics.canTotalMessages + " msgs | " + Diagnostics.canErrorCount + " errors"; font.pixelSize: 15; font.family: "Lato"; color: Diagnostics.canErrorCount > 0 ? errorColor : textPrimary }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Serial"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Rectangle { width: 10; height: 10; radius: 5; color: Diagnostics.serialConnected ? connectedColor : disconnectedColor }
                        Text { text: Diagnostics.serialPort + " @ " + Diagnostics.serialBaudRate; font.pixelSize: 15; font.family: "Lato"; color: textPrimary }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Type"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Text { text: Diagnostics.connectionType; font.pixelSize: 15; font.family: "Lato"; color: textPrimary }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Time"; font.pixelSize: 15; font.family: "Lato"; color: textSecondary; Layout.preferredWidth: 140 }
                        Text { text: Diagnostics.systemTime; font.pixelSize: 15; font.family: "Lato"; color: textPrimary }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }

        // * BOTTOM ROW: Live Data Table + System Log
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 300
            spacing: 8

            // * Live Sensor Data Table (60%)
            Rectangle {
                Layout.preferredWidth: 900
                Layout.fillHeight: true
                color: panelBg
                radius: 6
                border.color: panelBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Live Sensor Data"
                            font.pixelSize: 18; font.weight: Font.Bold; font.family: "Lato"
                            color: accentColor
                            Layout.fillWidth: true
                        }
                        Text {
                            text: liveDataModel.count + " sensors"
                            font.pixelSize: 14; font.family: "Lato"
                            color: textSecondary
                        }
                        Rectangle {
                            width: 100; height: 28; radius: 4
                            color: toggleArea.pressed ? "#3D3D3D" : "#2a2a4a"
                            border.color: "#3D3D3D"; border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: showAllSensors ? "Show Active" : "Show All"
                                font.pixelSize: 13; font.family: "Lato"; color: textPrimary
                            }
                            MouseArea {
                                id: toggleArea
                                anchors.fill: parent
                                onClicked: { showAllSensors = !showAllSensors; refreshLiveData() }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#3D3D3D" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text { text: "Name"; font.pixelSize: 14; font.weight: Font.DemiBold; font.family: "Lato"; color: accentColor; Layout.preferredWidth: 160 }
                        Text { text: "Source"; font.pixelSize: 14; font.weight: Font.DemiBold; font.family: "Lato"; color: accentColor; Layout.preferredWidth: 100 }
                        Text { text: "Live Value"; font.pixelSize: 14; font.weight: Font.DemiBold; font.family: "Lato"; color: accentColor; Layout.fillWidth: true }
                        Text { text: "Unit"; font.pixelSize: 14; font.weight: Font.DemiBold; font.family: "Lato"; color: accentColor; Layout.preferredWidth: 60 }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: panelBorder }

                    ListView {
                        id: sensorListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: liveDataModel
                        spacing: 1

                        delegate: Rectangle {
                            width: sensorListView.width
                            height: 28
                            color: index % 2 === 0 ? "#1e1e3a" : "#1a1a2e"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                spacing: 4

                                Text {
                                    text: model.name
                                    font.pixelSize: 14; font.family: "Lato"
                                    color: textPrimary
                                    Layout.preferredWidth: 160
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: model.source
                                    font.pixelSize: 14; font.family: "Lato"
                                    color: textSecondary
                                    Layout.preferredWidth: 100
                                }
                                Text {
                                    text: typeof model.value === "number" ? model.value.toFixed(model.unit === "" ? 0 : 3) : String(model.value)
                                    font.pixelSize: 14; font.family: "Lato"
                                    font.weight: Font.DemiBold
                                    color: Math.abs(model.value) > 0.001 ? "#4CAF50" : "#606060"
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: model.unit
                                    font.pixelSize: 14; font.family: "Lato"
                                    color: textSecondary
                                    Layout.preferredWidth: 60
                                }
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: sensorListView.contentHeight > sensorListView.height
                                    ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                        }
                    }
                }
            }

            // * System Log (40%)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: panelBg
                radius: 6
                border.color: panelBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "System Log"
                            font.pixelSize: 18; font.weight: Font.Bold; font.family: "Lato"
                            color: accentColor
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 60; height: 28; radius: 4
                            color: clearArea.pressed ? "#3D3D3D" : "#2a2a4a"
                            border.color: "#3D3D3D"; border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "Clear"
                                font.pixelSize: 14; font.family: "Lato"; color: textPrimary
                            }
                            MouseArea {
                                id: clearArea
                                anchors.fill: parent
                                onClicked: Diagnostics.clearLog()
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#3D3D3D" }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: consoleBg
                        radius: 4

                        ListView {
                            id: logListView
                            anchors.fill: parent
                            anchors.margins: 6
                            clip: true
                            model: Diagnostics.logMessages
                            spacing: 1

                            delegate: Text {
                                width: logListView.width
                                text: modelData
                                font.pixelSize: 14; font.family: "Courier New"
                                color: consoleText
                                wrapMode: Text.WrapAnywhere
                            }

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                            }

                            onCountChanged: {
                                Qt.callLater(function() {
                                    logListView.positionViewAtEnd()
                                })
                            }
                        }
                    }
                }
            }
        }
    }
}
