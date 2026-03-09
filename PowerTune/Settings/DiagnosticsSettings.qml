// Copyright (c) 2026 Kai Wyborny. All rights reserved.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0

Item {
    id: root

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

    property bool showAllSensors: Diagnostics.showAllSensors

    ListModel {
        id: logLevelModel
        ListElement { label: "All";   level: 0 }
        ListElement { label: "Info";  level: 1 }
        ListElement { label: "Warn";  level: 2 }
        ListElement { label: "Error"; level: 3 }
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
                            text: Diagnostics.liveSensorEntries.length + " sensors"
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
                                onClicked: Diagnostics.showAllSensors = !Diagnostics.showAllSensors
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
                        model: Diagnostics.liveSensorEntries
                        spacing: 1

                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: sensorListView.width
                            height: 28
                            color: index % 2 === 0 ? "#1e1e3a" : "#1a1a2e"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                spacing: 4

                                Text {
                                    text: modelData.name
                                    font.pixelSize: 14; font.family: "Lato"
                                    color: textPrimary
                                    Layout.preferredWidth: 160
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: modelData.source
                                    font.pixelSize: 14; font.family: "Lato"
                                    color: textSecondary
                                    Layout.preferredWidth: 100
                                }
                                Text {
                                    text: modelData.unit === "" ? Number(modelData.value).toFixed(0) : Number(modelData.value).toFixed(3)
                                    font.pixelSize: 14; font.family: "Lato"
                                    font.weight: Font.DemiBold
                                    color: Math.abs(modelData.value) > 0.001 ? "#4CAF50" : "#606060"
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: modelData.unit
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
                        }

                        Item { Layout.fillWidth: true }

                        Repeater {
                            model: logLevelModel

                            Rectangle {
                                width: 50; height: 26; radius: 4
                                color: Diagnostics.logLevel === model.level ? accentColor : "#2a2a4a"
                                border.color: Diagnostics.logLevel === model.level ? accentColor : "#3D3D3D"
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: model.label
                                    font.pixelSize: 12; font.family: "Lato"
                                    color: Diagnostics.logLevel === model.level ? "#FFFFFF" : textSecondary
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Diagnostics.logLevel = model.level
                                }
                            }
                        }

                        Rectangle {
                            width: 50; height: 26; radius: 4
                            color: clearArea.pressed ? "#3D3D3D" : "#2a2a4a"
                            border.color: "#3D3D3D"; border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "Clear"
                                font.pixelSize: 12; font.family: "Lato"; color: textPrimary
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
                            model: Diagnostics.filteredLogMessages
                            spacing: 1

                            delegate: Text {
                                width: logListView.width
                                text: modelData
                                font.pixelSize: 13; font.family: "Courier New"
                                color: {
                                    if (modelData.indexOf("[ERROR]") !== -1 || modelData.indexOf("[FATAL]") !== -1)
                                        return "#ff1744";
                                    if (modelData.indexOf("[WARN]") !== -1)
                                        return "#FF9800";
                                    if (modelData.indexOf("[DEBUG]") !== -1)
                                        return "#666680";
                                    return consoleText;
                                }
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
