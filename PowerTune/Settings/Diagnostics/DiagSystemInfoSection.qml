import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

RowLayout {
    id: root

    readonly property int _statusLabelWidth: 100
    readonly property int _statusRowHeight: 22
    readonly property int _statusRowSpacing: 2

    Layout.fillWidth: true
    spacing: SettingsTheme.sectionSpacing

    SettingsSection {
        Layout.fillWidth: true
        title: "System Information"

        ColumnLayout {
            Layout.fillWidth: true
            spacing: root._statusRowSpacing

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
