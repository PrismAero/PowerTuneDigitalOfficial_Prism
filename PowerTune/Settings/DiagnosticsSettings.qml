// Copyright (c) 2026 Kai Wyborny. All rights reserved.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsPage {
    id: root

    property bool showAllSensors: Diagnostics.showAllSensors

    // Compact status row height and spacing for the read-only top sections
    readonly property int _statusRowHeight: 22
    readonly property int _statusRowSpacing: 2
    readonly property int _statusLabelWidth: 100

    ListModel {
        id: logLevelModel
        ListElement { label: "All";   level: 0 }
        ListElement { label: "Info";  level: 1 }
        ListElement { label: "Warn";  level: 2 }
        ListElement { label: "Error"; level: 3 }
    }

    // * TOP ROW: System Information + Connection Status (compact)
    RowLayout {
        id: topRow
        Layout.fillWidth: true
        spacing: SettingsTheme.sectionSpacing

        SettingsSection {
            title: "System Information"
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: root._statusRowSpacing

                // CPU Temp
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "CPU Temp"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Text {
                        text: Diagnostics.cpuTemperature.toFixed(1) + " C"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }

                // CPU Load
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "CPU Load"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Text {
                        text: Diagnostics.cpuLoadAverage.toFixed(2)
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }

                // RAM
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "RAM"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Text {
                        text: Diagnostics.memoryUsedMB.toFixed(0) + " / " + Diagnostics.memoryTotalMB.toFixed(0) + " MB (" + Diagnostics.memoryUsagePercent.toFixed(1) + "%)"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }

                // Disk
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "Disk"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Text {
                        text: Diagnostics.diskUsagePercent.toFixed(1) + "% used"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }

                // Uptime
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "Uptime"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Text {
                        text: Diagnostics.uptime
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }

                // Platform
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "Platform"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Text {
                        text: Connection ? Connection.Platform : "Unknown"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }

                // Sensors
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "Sensors"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Text {
                        text: Diagnostics.activeSensorCount + " / " + Diagnostics.totalSensorCount
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }
            }
        }

        SettingsSection {
            title: "Connection"
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: root._statusRowSpacing

                // CAN Status
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "CAN Status"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Rectangle {
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        Layout.alignment: Qt.AlignVCenter
                        color: {
                            if (Diagnostics.canStatusText === "Active") return SettingsTheme.success
                            if (Diagnostics.canStatusText === "Waiting") return SettingsTheme.warning
                            return SettingsTheme.error
                        }
                    }
                    Text {
                        text: Diagnostics.canStatusText
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        Layout.fillWidth: true
                        color: {
                            if (Diagnostics.canStatusText === "Active") return SettingsTheme.success
                            if (Diagnostics.canStatusText === "Waiting") return SettingsTheme.warning
                            return SettingsTheme.error
                        }
                    }
                }

                // Daemon
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "Daemon"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Text {
                        text: Diagnostics.daemonName
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }

                // CAN Rate
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "CAN Rate"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Text {
                        text: Diagnostics.canMessageRate + " msg/s"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }

                // CAN Total
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "CAN Total"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Text {
                        text: Diagnostics.canTotalMessages + " msgs | " + Diagnostics.canErrorCount + " errors"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: Diagnostics.canErrorCount > 0 ? SettingsTheme.error : SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }

                // Serial
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "Serial"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Rectangle {
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        Layout.alignment: Qt.AlignVCenter
                        color: Diagnostics.serialConnected ? SettingsTheme.success : SettingsTheme.error
                    }
                    Text {
                        text: Diagnostics.serialPort + " @ " + Diagnostics.serialBaudRate
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }

                // Type
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "Type"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Text {
                        text: Diagnostics.connectionType
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }

                // Time
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing
                    Text {
                        text: "Time"
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        Layout.preferredWidth: root._statusLabelWidth
                    }
                    Text {
                        text: Diagnostics.systemTime
                        font.pixelSize: SettingsTheme.fontStatus
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    // * BOTTOM ROW: Live Sensor Data + System Log
    // Height is calculated to fill remaining viewport space below the top row.
    // root.height = SettingsPage Rectangle height (fills available area).
    // Available content height = root.height - pageMargin*2 (ScrollView margins).
    // Bottom row height = available - topRow height - sectionSpacing between rows.
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: root.height - (SettingsTheme.pageMargin * 2)
                                - topRow.height - SettingsTheme.sectionSpacing
        spacing: SettingsTheme.sectionSpacing

        // * Live Sensor Data Table
        SettingsSection {
            title: "Live Sensor Data"
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.contentSpacing

                Text {
                    text: Diagnostics.liveSensorEntries.length + " sensors"
                    font.pixelSize: SettingsTheme.fontCaption
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    radius: SettingsTheme.radiusSmall
                    color: toggleArea.pressed ? SettingsTheme.surfacePressed : SettingsTheme.controlBg
                    border.color: SettingsTheme.border
                    border.width: SettingsTheme.borderWidth

                    Text {
                        anchors.centerIn: parent
                        text: showAllSensors ? "Show Active" : "Show All"
                        font.pixelSize: SettingsTheme.fontCaption
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
                    }
                    MouseArea {
                        id: toggleArea
                        anchors.fill: parent
                        onClicked: Diagnostics.showAllSensors = !Diagnostics.showAllSensors
                    }
                }
            }

            // * Table Header
            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.contentSpacing

                Text {
                    text: "Name"
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.DemiBold
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.accent
                    Layout.preferredWidth: 160
                }
                Text {
                    text: "Source"
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.DemiBold
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.accent
                    Layout.preferredWidth: 100
                }
                Text {
                    text: "Live Value"
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.DemiBold
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.accent
                    Layout.fillWidth: true
                }
                Text {
                    text: "Unit"
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.DemiBold
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.accent
                    Layout.preferredWidth: 60
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: SettingsTheme.borderWidth
                color: SettingsTheme.border
            }

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
                    height: 32
                    color: index % 2 === 0 ? SettingsTheme.surface : SettingsTheme.background

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: SettingsTheme.contentSpacing / 2
                        anchors.rightMargin: SettingsTheme.contentSpacing / 2
                        spacing: SettingsTheme.contentSpacing

                        Text {
                            text: modelData.name
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textPrimary
                            Layout.preferredWidth: 160
                            elide: Text.ElideRight
                        }
                        Text {
                            text: modelData.source
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
                            Layout.preferredWidth: 100
                        }
                        Text {
                            text: modelData.unit === "" ? Number(modelData.value).toFixed(0) : Number(modelData.value).toFixed(3)
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            font.weight: Font.DemiBold
                            color: Math.abs(modelData.value) > 0.001 ? SettingsTheme.success : SettingsTheme.textDisabled
                            Layout.fillWidth: true
                        }
                        Text {
                            text: modelData.unit
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: SettingsTheme.textSecondary
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

        // * System Log
        SettingsSection {
            title: "System Log"
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.contentSpacing

                Item { Layout.fillWidth: true }

                Repeater {
                    model: logLevelModel

                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        radius: SettingsTheme.radiusSmall
                        color: Diagnostics.logLevel === model.level ? SettingsTheme.accent : SettingsTheme.controlBg
                        border.color: Diagnostics.logLevel === model.level ? SettingsTheme.accent : SettingsTheme.border
                        border.width: SettingsTheme.borderWidth

                        Text {
                            anchors.centerIn: parent
                            text: model.label
                            font.pixelSize: SettingsTheme.fontCaption
                            font.family: SettingsTheme.fontFamily
                            color: Diagnostics.logLevel === model.level ? SettingsTheme.textPrimary : SettingsTheme.textSecondary
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Diagnostics.logLevel = model.level
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    radius: SettingsTheme.radiusSmall
                    color: clearArea.pressed ? SettingsTheme.surfacePressed : SettingsTheme.controlBg
                    border.color: SettingsTheme.border
                    border.width: SettingsTheme.borderWidth

                    Text {
                        anchors.centerIn: parent
                        text: "Clear"
                        font.pixelSize: SettingsTheme.fontCaption
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textPrimary
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
                Layout.fillHeight: true
                color: SettingsTheme.consoleBg
                radius: SettingsTheme.radiusSmall

                ListView {
                    id: logListView
                    anchors.fill: parent
                    anchors.margins: SettingsTheme.radiusSmall
                    clip: true
                    model: Diagnostics.filteredLogMessages
                    spacing: 1

                    delegate: Text {
                        width: logListView.width
                        text: modelData
                        font.pixelSize: SettingsTheme.fontCaption
                        font.family: SettingsTheme.fontFamilyMono
                        color: {
                            if (modelData.indexOf("[ERROR]") !== -1 || modelData.indexOf("[FATAL]") !== -1)
                                return SettingsTheme.error;
                            if (modelData.indexOf("[WARN]") !== -1)
                                return SettingsTheme.warning;
                            if (modelData.indexOf("[DEBUG]") !== -1)
                                return SettingsTheme.textDisabled;
                            return SettingsTheme.consoleText;
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
