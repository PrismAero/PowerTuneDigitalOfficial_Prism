// Copyright (c) 2026 Kai Wyborny. All rights reserved.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0

// * DiagnosticsSettings - 2x2 grid diagnostics dashboard page
// * Displays system info, connection status, active sensors, and log console.
// * All data sourced from DiagnosticsProvider (QML context: "Diagnostics").

Item {
    id: root
    anchors.fill: parent

    // * Theme constants
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

    // * Sensor data model refreshed periodically
    property var sensorData: []

    Timer {
        id: sensorRefreshTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.sensorData = Diagnostics.getLiveSensorData()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: pageBg
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: 8
        columns: 2
        rows: 2
        columnSpacing: 8
        rowSpacing: 8

        // * ---- Top-Left: System Info ----
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 280
            color: panelBg
            radius: 6
            border.color: panelBorder
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                Text {
                    text: "System"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.family: "Lato"
                    color: accentColor
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3D3D3D"
                }

                // * CPU Temperature
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "CPU Temperature"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textSecondary
                        Layout.preferredWidth: 160
                    }
                    Text {
                        text: Diagnostics.cpuTemperature.toFixed(1) + " C"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textPrimary
                    }
                }

                // * Memory Usage
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Memory Usage"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textSecondary
                        Layout.preferredWidth: 160
                    }
                    Text {
                        text: Diagnostics.memoryUsagePercent.toFixed(1) + "%"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textPrimary
                    }
                }

                // * Uptime
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Uptime"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textSecondary
                        Layout.preferredWidth: 160
                    }
                    Text {
                        text: Diagnostics.uptime
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textPrimary
                    }
                }

                // * System Time
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "System Time"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textSecondary
                        Layout.preferredWidth: 160
                    }
                    Text {
                        text: Diagnostics.systemTime
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textPrimary
                    }
                }

                // * Active Sensors
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Active Sensors"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textSecondary
                        Layout.preferredWidth: 160
                    }
                    Text {
                        text: Diagnostics.activeSensorCount + " / " + Diagnostics.totalSensorCount
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textPrimary
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        // * ---- Top-Right: Connection Status ----
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 280
            color: panelBg
            radius: 6
            border.color: panelBorder
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                Text {
                    text: "Connection"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.family: "Lato"
                    color: accentColor
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3D3D3D"
                }

                // * CAN Status
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "CAN Status"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textSecondary
                        Layout.preferredWidth: 160
                    }
                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: Diagnostics.canConnected ? connectedColor : disconnectedColor
                    }
                    Text {
                        text: Diagnostics.canConnected ? "Connected" : "Disconnected"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: Diagnostics.canConnected ? connectedColor : disconnectedColor
                    }
                }

                // * Daemon
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Daemon"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textSecondary
                        Layout.preferredWidth: 160
                    }
                    Text {
                        text: Diagnostics.daemonName
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textPrimary
                    }
                }

                // * Message Rate
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Message Rate"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textSecondary
                        Layout.preferredWidth: 160
                    }
                    Text {
                        text: Diagnostics.canMessageRate + " msg/s"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textPrimary
                    }
                }

                // * Total Messages
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Total Messages"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textSecondary
                        Layout.preferredWidth: 160
                    }
                    Text {
                        text: Diagnostics.canTotalMessages
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textPrimary
                    }
                }

                // * Error Count
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Error Count"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textSecondary
                        Layout.preferredWidth: 160
                    }
                    Text {
                        text: Diagnostics.canErrorCount
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: Diagnostics.canErrorCount > 0 ? errorColor : textPrimary
                    }
                }

                // * Serial
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Serial"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textSecondary
                        Layout.preferredWidth: 160
                    }
                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: Diagnostics.serialConnected ? connectedColor : disconnectedColor
                    }
                    Text {
                        text: Diagnostics.serialPort + " @ " + Diagnostics.serialBaudRate
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textPrimary
                    }
                }

                // * Connection Type
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Connection Type"
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textSecondary
                        Layout.preferredWidth: 160
                    }
                    Text {
                        text: Diagnostics.connectionType
                        font.pixelSize: 14
                        font.family: "Lato"
                        color: textPrimary
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        // * ---- Bottom-Left: Active Sensors ----
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: panelBg
            radius: 6
            border.color: panelBorder
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                Text {
                    text: "Active Sensors"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.family: "Lato"
                    color: accentColor
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3D3D3D"
                }

                // * Table header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "Name"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: accentColor
                        Layout.preferredWidth: 300
                    }
                    Text {
                        text: "Unit"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: accentColor
                        Layout.preferredWidth: 100
                    }
                    Text {
                        text: "Source"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.family: "Lato"
                        color: accentColor
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: panelBorder
                }

                // * Sensor list
                ListView {
                    id: sensorListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.sensorData
                    spacing: 2

                    delegate: RowLayout {
                        width: sensorListView.width
                        spacing: 4

                        Text {
                            text: modelData.displayName || ""
                            font.pixelSize: 12
                            font.family: "Lato"
                            color: textPrimary
                            Layout.preferredWidth: 300
                            elide: Text.ElideRight
                        }
                        Text {
                            text: modelData.unit || ""
                            font.pixelSize: 12
                            font.family: "Lato"
                            color: textSecondary
                            Layout.preferredWidth: 100
                        }
                        Text {
                            text: modelData.source || ""
                            font.pixelSize: 12
                            font.family: "Lato"
                            color: textSecondary
                            Layout.fillWidth: true
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: sensorListView.contentHeight > sensorListView.height
                                ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                    }
                }
            }
        }

        // * ---- Bottom-Right: Log Console ----
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: panelBg
            radius: 6
            border.color: panelBorder
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "System Log"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        font.family: "Lato"
                        color: accentColor
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 60
                        height: 28
                        radius: 4
                        color: clearArea.pressed ? "#3D3D3D" : "#2a2a4a"
                        border.color: "#3D3D3D"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Clear"
                            font.pixelSize: 12
                            font.family: "Lato"
                            color: textPrimary
                        }

                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            onClicked: Diagnostics.clearLog()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3D3D3D"
                }

                // * Console output area
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
                            font.pixelSize: 12
                            font.family: "Courier New"
                            color: consoleText
                            wrapMode: Text.WrapAnywhere
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        // * Auto-scroll to bottom on new messages
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
