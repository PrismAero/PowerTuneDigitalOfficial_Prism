// Copyright (c) 2026 Kai Wyborny. All rights reserved.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsPage {
    id: root

    readonly property int _statusLabelWidth: 100

    // Compact status row height and spacing for the read-only top sections
    readonly property int _statusRowHeight: 22
    readonly property int _statusRowSpacing: 2
    property bool showAllSensors: Diagnostics.showAllSensors

    Component.onCompleted: Diagnostics.setPageVisible(true)
    Component.onDestruction: Diagnostics.setPageVisible(false)

    ListModel {
        id: logLevelModel

        ListElement {
            label: "All"
            level: 0
        }

        ListElement {
            label: "Info"
            level: 1
        }

        ListElement {
            label: "Warn"
            level: 2
        }

        ListElement {
            label: "Error"
            level: 3
        }
    }

    // * TOP ROW: System Information + Connection Status (compact)
    RowLayout {
        id: topRow

        Layout.fillWidth: true
        spacing: SettingsTheme.sectionSpacing

        SettingsSection {
            Layout.fillWidth: true
            title: "System Information"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: root._statusRowSpacing

                // CPU Temp
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "CPU Temp"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: Diagnostics.cpuTemperatureAvailable ? SettingsTheme.textPrimary :
                                                                     SettingsTheme.textDisabled
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.cpuTemperatureAvailable ? Diagnostics.cpuTemperature.toFixed(1) + " C" : "N/A"
                    }
                }

                // CPU Load
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "CPU Load"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.cpuLoadAverage.toFixed(2)
                    }
                }

                // RAM
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "RAM"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.memoryUsedMB.toFixed(0) + " / " + Diagnostics.memoryTotalMB.toFixed(0) + " MB ("
                              + Diagnostics.memoryUsagePercent.toFixed(1) + "%)"
                    }
                }

                // Disk
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "Disk"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.diskUsagePercent.toFixed(1) + "% used"
                    }
                }

                // Uptime
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "Uptime"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.uptime
                    }
                }

                // Platform
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "Platform"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Connection ? Connection.Platform : "Unknown"
                    }
                }

                // Sensors
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "Sensors"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.activeSensorCount + " / " + Diagnostics.totalSensorCount
                    }
                }
            }
        }

        SettingsSection {
            Layout.fillWidth: true
            title: "Connection"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: root._statusRowSpacing

                // CAN Status
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "CAN Status"
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        color: {
                            if (Diagnostics.canStatusText === "Active")
                                return SettingsTheme.success;
                            if (Diagnostics.canStatusText === "Waiting")
                                return SettingsTheme.warning;
                            return SettingsTheme.error;
                        }
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        width: SettingsTheme.statusDotSize
                    }

                    Text {
                        Layout.fillWidth: true
                        color: {
                            if (Diagnostics.canStatusText === "Active")
                                return SettingsTheme.success;
                            if (Diagnostics.canStatusText === "Waiting")
                                return SettingsTheme.warning;
                            return SettingsTheme.error;
                        }
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.canStatusText
                    }
                }

                // Daemon
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "Daemon"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.daemonName
                    }
                }

                // CAN Rate
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "CAN Rate"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.canMessageRate + " msg/s"
                    }
                }

                // CAN Total
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "CAN Total"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: Diagnostics.canErrorCount > 0 ? SettingsTheme.error : SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.canTotalMessages + " msgs | " + Diagnostics.canErrorCount + " errors"
                    }
                }

                // Serial
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "Serial"
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        color: Diagnostics.serialConnected ? SettingsTheme.success : SettingsTheme.error
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        width: SettingsTheme.statusDotSize
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.serialPort + " @ " + Diagnostics.serialBaudRate
                    }
                }

                // Type
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "Type"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.connectionType
                    }
                }

                // Time
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root._statusRowHeight
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: root._statusLabelWidth
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: "Time"
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontStatus
                        text: Diagnostics.systemTime
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
        Layout.preferredHeight: root.height - (SettingsTheme.pageMargin * 2) - topRow.height
                                - SettingsTheme.sectionSpacing

        spacing: SettingsTheme.sectionSpacing

        // * Live Sensor Data Table
        SettingsSection {
            Layout.fillHeight: true
            Layout.fillWidth: true
            title: "Live Sensor Data"

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.contentSpacing

                Text {
                    Layout.fillWidth: true
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: Diagnostics.liveSensorEntries.length + " sensors"
                }

                Rectangle {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 120
                    border.color: SettingsTheme.border
                    border.width: SettingsTheme.borderWidth
                    color: toggleArea.pressed ? SettingsTheme.surfacePressed : SettingsTheme.controlBg
                    radius: SettingsTheme.radiusSmall

                    Text {
                        anchors.centerIn: parent
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: showAllSensors ? "Show Active" : "Show All"
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
                    Layout.preferredWidth: 160
                    color: SettingsTheme.accent
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.DemiBold
                    text: "Name"
                }

                Text {
                    Layout.preferredWidth: 100
                    color: SettingsTheme.accent
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.DemiBold
                    text: "Source"
                }

                Text {
                    Layout.fillWidth: true
                    color: SettingsTheme.accent
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.DemiBold
                    text: "Live Value"
                }

                Text {
                    Layout.preferredWidth: 60
                    color: SettingsTheme.accent
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.DemiBold
                    text: "Unit"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                color: SettingsTheme.border
                height: SettingsTheme.borderWidth
            }

            ListView {
                id: sensorListView

                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                model: Diagnostics.liveSensorEntries
                spacing: 1

                ScrollBar.vertical: ScrollBar {
                    policy: sensorListView.contentHeight > sensorListView.height ? ScrollBar.AsNeeded :
                                                                                   ScrollBar.AlwaysOff
                }
                delegate: Rectangle {
                    required property int index
                    required property var modelData

                    color: index % 2 === 0 ? SettingsTheme.surface : SettingsTheme.background
                    height: 32
                    width: sensorListView.width

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: SettingsTheme.contentSpacing / 2
                        anchors.rightMargin: SettingsTheme.contentSpacing / 2
                        spacing: SettingsTheme.contentSpacing

                        Rectangle {
                            color: modelData.active ? SettingsTheme.success : SettingsTheme.textDisabled
                            height: SettingsTheme.statusDotSize
                            radius: SettingsTheme.statusDotSize / 2
                            width: SettingsTheme.statusDotSize
                        }

                        Text {
                            Layout.preferredWidth: 160
                            color: SettingsTheme.textPrimary
                            elide: Text.ElideRight
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: modelData.name
                        }

                        Text {
                            Layout.preferredWidth: 100
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: modelData.source
                        }

                        Text {
                            Layout.fillWidth: true
                            color: modelData.active ? SettingsTheme.success : SettingsTheme.textDisabled
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            font.weight: Font.DemiBold
                            text: modelData.unit === "" ? Number(modelData.value).toFixed(0) : Number(
                                                              modelData.value).toFixed(3)
                        }

                        Text {
                            Layout.preferredWidth: 60
                            color: SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: modelData.unit
                        }
                    }
                }
            }
        }

        // * System Log
        SettingsSection {
            Layout.fillHeight: true
            Layout.fillWidth: true
            title: "System Log"

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.contentSpacing

                Item {
                    Layout.fillWidth: true
                }

                Repeater {
                    model: logLevelModel

                    Rectangle {
                        Layout.preferredHeight: SettingsTheme.controlHeight
                        Layout.preferredWidth: 60
                        border.color: Diagnostics.logLevel === model.level ? SettingsTheme.accent : SettingsTheme.border
                        border.width: SettingsTheme.borderWidth
                        color: Diagnostics.logLevel === model.level ? SettingsTheme.accent : SettingsTheme.controlBg
                        radius: SettingsTheme.radiusSmall

                        Text {
                            anchors.centerIn: parent
                            color: Diagnostics.logLevel === model.level ? SettingsTheme.textPrimary :
                                                                          SettingsTheme.textSecondary
                            font.family: SettingsTheme.fontFamily
                            font.pixelSize: SettingsTheme.fontCaption
                            text: model.label
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: Diagnostics.logLevel = model.level
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 60
                    border.color: SettingsTheme.border
                    border.width: SettingsTheme.borderWidth
                    color: clearArea.pressed ? SettingsTheme.surfacePressed : SettingsTheme.controlBg
                    radius: SettingsTheme.radiusSmall

                    Text {
                        anchors.centerIn: parent
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: "Clear"
                    }

                    MouseArea {
                        id: clearArea

                        anchors.fill: parent

                        onClicked: Diagnostics.clearLog()
                    }
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: SettingsTheme.consoleBg
                radius: SettingsTheme.radiusSmall

                ListView {
                    id: logListView

                    anchors.fill: parent
                    anchors.margins: SettingsTheme.radiusSmall
                    clip: true
                    model: Diagnostics.filteredLogMessages
                    spacing: 1

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                    delegate: Text {
                        color: {
                            if (modelData.indexOf("[ERROR]") !== -1 || modelData.indexOf("[FATAL]") !== -1)
                                return SettingsTheme.error;
                            if (modelData.indexOf("[WARN]") !== -1)
                                return SettingsTheme.warning;
                            if (modelData.indexOf("[DEBUG]") !== -1)
                                return SettingsTheme.textDisabled;
                            return SettingsTheme.consoleText;
                        }
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontCaption
                        text: modelData
                        width: logListView.width
                        wrapMode: Text.WrapAnywhere
                    }

                    onCountChanged: {
                        Qt.callLater(function () {
                            logListView.positionViewAtEnd();
                        });
                    }
                }
            }
        }
    }

    // * ANALOG INPUTS DIAGNOSTICS
    SettingsSection {
        id: analogSection

        Layout.fillWidth: true
        collapsed: true
        collapsible: true
        title: "Analog Inputs"

        Timer {
            interval: 1000
            repeat: true
            running: !analogSection.collapsed
            triggeredOnStart: true

            onTriggered: analogDiagModel.refresh()
        }

        ListModel {
            id: analogDiagModel

            function refresh() {
                clear();
                var data = Diagnostics.getAnalogInputDiagnostics();
                for (var i = 0; i < data.length; i++)
                    append(data[i]);
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            Text {
                Layout.preferredWidth: 80
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Channel"
            }

            Text {
                Layout.preferredWidth: 80
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Raw (V)"
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Calibrated"
            }

            Text {
                Layout.preferredWidth: 60
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Unit"
            }
        }

        Repeater {
            model: analogDiagModel

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.contentSpacing

                Text {
                    Layout.preferredWidth: 80
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.channel !== undefined ? model.channel : ""
                }

                Text {
                    Layout.preferredWidth: 80
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.rawVoltage !== undefined ? Number(model.rawVoltage).toFixed(3) : ""
                }

                Text {
                    Layout.fillWidth: true
                    color: SettingsTheme.success
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.DemiBold
                    text: model.calibratedValue !== undefined ? Number(model.calibratedValue).toFixed(3) : ""
                }

                Text {
                    Layout.preferredWidth: 60
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.unit !== undefined ? model.unit : ""
                }
            }
        }
    }

    // * DIGITAL INPUTS DIAGNOSTICS
    SettingsSection {
        id: digitalSection

        Layout.fillWidth: true
        collapsed: true
        collapsible: true
        title: "Digital Inputs"

        Timer {
            interval: 1000
            repeat: true
            running: !digitalSection.collapsed
            triggeredOnStart: true

            onTriggered: digitalDiagModel.refresh()
        }

        ListModel {
            id: digitalDiagModel

            function refresh() {
                clear();
                var ecu = Diagnostics.getDigitalInputDiagnostics();
                for (var i = 0; i < ecu.length; i++)
                    append(ecu[i]);
                var ext = Diagnostics.getExtenderDigitalDiagnostics();
                for (var j = 0; j < ext.length; j++)
                    append(ext[j]);
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            Text {
                Layout.preferredWidth: 120
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Channel"
            }

            Text {
                Layout.preferredWidth: 80
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "State"
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Name"
            }
        }

        Repeater {
            model: digitalDiagModel

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.contentSpacing

                Text {
                    Layout.preferredWidth: 120
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.channel !== undefined ? model.channel : ""
                }

                Rectangle {
                    Layout.preferredHeight: 20
                    Layout.preferredWidth: 80
                    color: model.state ? SettingsTheme.success : SettingsTheme.textDisabled
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        text: model.state ? "ON" : "OFF"
                    }
                }

                Text {
                    Layout.fillWidth: true
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.label !== undefined ? model.label : ""
                }
            }
        }
    }

    // * EXTENDER BOARD DIAGNOSTICS
    SettingsSection {
        id: extenderSection

        Layout.fillWidth: true
        collapsed: true
        collapsible: true
        title: "Extender Board"

        Timer {
            interval: 1000
            repeat: true
            running: !extenderSection.collapsed
            triggeredOnStart: true

            onTriggered: extenderDiagModel.refresh()
        }

        ListModel {
            id: extenderDiagModel

            function refresh() {
                clear();
                var data = Diagnostics.getExpanderBoardDiagnostics();
                for (var i = 0; i < data.length; i++)
                    append(data[i]);
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            Text {
                Layout.preferredWidth: 80
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Channel"
            }

            Text {
                Layout.preferredWidth: 80
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Raw (V)"
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Calibrated"
            }

            Text {
                Layout.preferredWidth: 60
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Unit"
            }

            Text {
                Layout.preferredWidth: 40
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "NTC"
            }
        }

        Repeater {
            model: extenderDiagModel

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.contentSpacing

                Text {
                    Layout.preferredWidth: 80
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.channel !== undefined ? model.channel : ""
                }

                Text {
                    Layout.preferredWidth: 80
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.rawVoltage !== undefined ? Number(model.rawVoltage).toFixed(3) : ""
                }

                Text {
                    Layout.fillWidth: true
                    color: SettingsTheme.success
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.DemiBold
                    text: model.calibratedValue !== undefined ? Number(model.calibratedValue).toFixed(3) : ""
                }

                Text {
                    Layout.preferredWidth: 60
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.unit !== undefined ? model.unit : ""
                }

                Text {
                    Layout.preferredWidth: 40
                    color: model.ntcEnabled ? SettingsTheme.accent : SettingsTheme.textDisabled
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: model.ntcEnabled ? "Yes" : "No"
                }
            }
        }
    }

    // * CAN MESSAGE VIEWER
    SettingsSection {
        id: canSection

        Layout.fillWidth: true
        collapsed: true
        collapsible: true
        title: "CAN Messages"

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            StyledSwitch {
                id: canCaptureToggle

                checked: Diagnostics.canCaptureEnabled

                onCheckedChanged: Diagnostics.canCaptureEnabled = checked
            }

            Text {
                color: canCaptureToggle.checked ? SettingsTheme.success : SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: canCaptureToggle.checked ? "Capturing" : "Stopped"
            }

            Item {
                Layout.fillWidth: true
            }

            StyledTextField {
                Layout.preferredWidth: 140
                inputMethodHints: Qt.ImhNoPredictiveText
                placeholderText: "Filter CAN ID (hex)"
                text: Diagnostics.canIdFilter

                onTextChanged: Diagnostics.canIdFilter = text
            }

            StyledButton {
                primary: false
                text: "Clear"

                onClicked: Diagnostics.clearCanFrameBuffer()
            }

            StyledButton {
                primary: false
                text: "Reset Errors"

                onClicked: Diagnostics.resetCanErrors()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            Text {
                Layout.preferredWidth: 80
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "ID"
            }

            Text {
                Layout.preferredWidth: 30
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Len"
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Payload (hex)"
            }

            Text {
                Layout.preferredWidth: 80
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "ASCII"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            color: SettingsTheme.border
            height: SettingsTheme.borderWidth
        }

        ListView {
            id: canFrameList

            Layout.fillWidth: true
            Layout.preferredHeight: 300
            clip: true
            model: Diagnostics.canFrameBuffer
            spacing: 1

            ScrollBar.vertical: ScrollBar {
                policy: canFrameList.contentHeight > canFrameList.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
            }
            delegate: Rectangle {
                required property int index
                required property var modelData

                color: index % 2 === 0 ? SettingsTheme.surface : SettingsTheme.background
                height: 28
                width: canFrameList.width

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4
                    spacing: SettingsTheme.contentSpacing

                    Text {
                        Layout.preferredWidth: 80
                        color: SettingsTheme.accent
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontCaption
                        text: modelData.id
                    }

                    Text {
                        Layout.preferredWidth: 30
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontCaption
                        text: modelData.length
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontCaption
                        text: modelData.payload
                    }

                    Text {
                        Layout.preferredWidth: 80
                        color: SettingsTheme.textDisabled
                        font.family: SettingsTheme.fontFamilyMono
                        font.pixelSize: SettingsTheme.fontCaption
                        text: modelData.ascii
                    }
                }
            }
        }
    }

    // * DEBUG TOOLS
    SettingsSection {
        Layout.fillWidth: true
        title: "Debug Tools"

        SettingsRow {
            description: "Force all arc gauges to 100% fill for alignment verification"
            label: "Full Arc Sweep"

            StyledSwitch {
                checked: {
                    var v = AppSettings.getValue("debug/arcFullSweep", false);
                    return v === true || v === "true";
                }

                onCheckedChanged: AppSettings.setValue("debug/arcFullSweep", checked)
            }
        }
    }
}
