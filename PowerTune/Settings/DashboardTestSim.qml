import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.UI 1.0

// * DashboardTestSim - UDP test-data simulator for exercising dashboard gauges
// Sends UDP datagrams on localhost:45454 with format "ident,value" per enabled
// channel. Supports manual per-channel sliders, automated sweep test, and
// quick presets (idle, cruise, redline, cold start).

SettingsPage {
    id: root

    // -- Sweep phase name lookup --
    function sweepPhaseName(phase) {
        switch (phase) {
        case 0: return "Idle"
        case 1: return "Ramp Up"
        case 2: return "Shift 1"
        case 3: return "Ramp Down 1"
        case 4: return "Ramp Up 2"
        case 5: return "Shift 2"
        case 6: return "Ramp Down 2"
        case 7: return "Temp Ramp"
        case 8: return "Wind Down"
        case 9: return "Done"
        default: return "Unknown"
        }
    }

    // -- Preset definitions (14 channels by index) --
    // Channel order: RPM, Speed, Gear, WaterTemp, OilPres, TPS, AFR,
    //                Boost, Battery, FuelPres, IntakeTemp, Load, FuelPump, CoolFan
    function applyPreset(values) {
        var count = TestSim.channelCount()
        for (var i = 0; i < count && i < values.length; i++) {
            TestSim.setChannelValue(i, values[i])
        }
    }

    function formatValue(value, step) {
        if (step >= 1) return value.toFixed(0)
        if (step >= 0.1) return value.toFixed(1)
        return value.toFixed(2)
    }

    // -- Simulation Control Section --
    SettingsSection {
        title: "Simulation Control"
        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.controlGap

            // Status indicator dot
            Rectangle {
                width: SettingsTheme.statusDotSize
                height: SettingsTheme.statusDotSize
                radius: SettingsTheme.statusDotSize / 2
                color: TestSim.running ? SettingsTheme.success : SettingsTheme.textDisabled
                Layout.alignment: Qt.AlignVCenter

                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
                text: TestSim.running ? "Running" : "Stopped"
                font.pixelSize: SettingsTheme.fontLabel
                font.family: SettingsTheme.fontFamily
                font.weight: Font.DemiBold
                color: TestSim.running ? SettingsTheme.success : SettingsTheme.textSecondary
                Layout.alignment: Qt.AlignVCenter

                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Item { Layout.fillWidth: true }

            // Sweep status
            Text {
                visible: TestSim.sweepLooping
                text: "SWEEP: " + root.sweepPhaseName(TestSim.sweepState)
                font.pixelSize: SettingsTheme.fontCaption
                font.family: SettingsTheme.fontFamily
                font.weight: Font.Bold
                color: SettingsTheme.warning
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Control buttons row
        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.controlGap

            StyledButton {
                text: TestSim.running ? "Stop" : "Start"
                primary: !TestSim.running
                danger: TestSim.running
                Layout.preferredWidth: 120
                onClicked: TestSim.running = !TestSim.running
            }

            StyledButton {
                text: TestSim.sweepLooping ? "Stop Sweep" : "Sweep Test"
                primary: !TestSim.sweepLooping
                danger: TestSim.sweepLooping
                Layout.preferredWidth: 140
                onClicked: {
                    if (TestSim.sweepLooping)
                        TestSim.stopSweepTest()
                    else
                        TestSim.startSweepTest()
                }
            }

            Item { Layout.preferredWidth: SettingsTheme.controlGap }

            // Interval control
            Text {
                text: "Interval"
                font.pixelSize: SettingsTheme.fontCaption
                font.family: SettingsTheme.fontFamily
                color: SettingsTheme.textSecondary
                Layout.alignment: Qt.AlignVCenter
            }

            Slider {
                id: intervalSlider
                Layout.preferredWidth: 200
                Layout.preferredHeight: SettingsTheme.controlHeight
                from: 20; to: 500; stepSize: 10
                value: TestSim.intervalMs
                onMoved: TestSim.intervalMs = value

                background: Rectangle {
                    x: intervalSlider.leftPadding
                    y: intervalSlider.topPadding + intervalSlider.availableHeight / 2 - height / 2
                    width: intervalSlider.availableWidth
                    height: 6
                    radius: 3
                    color: SettingsTheme.controlBg

                    Rectangle {
                        width: intervalSlider.visualPosition * parent.width
                        height: parent.height
                        radius: 3
                        color: SettingsTheme.accent
                    }
                }

                handle: Rectangle {
                    x: intervalSlider.leftPadding + intervalSlider.visualPosition * (intervalSlider.availableWidth - width)
                    y: intervalSlider.topPadding + intervalSlider.availableHeight / 2 - height / 2
                    width: 24
                    height: 24
                    radius: SettingsTheme.radiusSmall
                    color: intervalSlider.pressed ? SettingsTheme.accentPressed : SettingsTheme.accent

                    Behavior on color { ColorAnimation { duration: 100 } }
                }
            }

            Text {
                text: TestSim.intervalMs + " ms"
                font.pixelSize: SettingsTheme.fontCaption
                font.family: SettingsTheme.fontFamily
                font.weight: Font.DemiBold
                color: SettingsTheme.accent
                Layout.preferredWidth: 60
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    // -- Two-column layout: Presets (left) + Channel Sliders (right) --
    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: SettingsTheme.sectionSpacing

        // -- Left Column: Presets --
        SettingsSection {
            title: "Presets"
            Layout.preferredWidth: 280
            Layout.alignment: Qt.AlignTop

            // Preset buttons
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: SettingsTheme.contentSpacing
                rowSpacing: SettingsTheme.contentSpacing

                StyledButton {
                    text: "Idle"
                    Layout.fillWidth: true
                    onClicked: root.applyPreset([800, 0, 0, 180, 40, 0, 14.7, 0, 13.8, 43, 90, 15, 1, 0])
                }

                StyledButton {
                    text: "Cruise"
                    Layout.fillWidth: true
                    onClicked: root.applyPreset([2500, 65, 4, 195, 55, 25, 14.7, 50, 14.2, 43, 100, 40, 1, 0])
                }

                StyledButton {
                    text: "Redline"
                    Layout.fillWidth: true
                    danger: true
                    onClicked: root.applyPreset([7000, 160, 3, 220, 70, 100, 11.5, 200, 14.4, 58, 130, 100, 1, 1])
                }

                StyledButton {
                    text: "Cold Start"
                    Layout.fillWidth: true
                    onClicked: root.applyPreset([1200, 0, 0, 80, 25, 5, 12.0, 0, 12.2, 40, 40, 20, 1, 0])
                }
            }

            // Utility controls
            Rectangle {
                Layout.fillWidth: true
                height: SettingsTheme.borderWidth
                color: SettingsTheme.border
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.contentSpacing

                StyledButton {
                    text: "Reset All"
                    primary: false
                    Layout.fillWidth: true
                    onClicked: {
                        var count = TestSim.channelCount()
                        for (var i = 0; i < count; i++) {
                            TestSim.setChannelValue(i, TestSim.channelMin(i))
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: SettingsTheme.contentSpacing

                Text {
                    text: "Enable All"
                    font.pixelSize: SettingsTheme.fontCaption
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.textSecondary
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                StyledSwitch {
                    id: enableAllSwitch
                    checked: {
                        var count = TestSim.channelCount()
                        for (var i = 0; i < count; i++) {
                            if (!TestSim.channelEnabled(i))
                                return false
                        }
                        return true
                    }
                    onToggled: {
                        var count = TestSim.channelCount()
                        for (var i = 0; i < count; i++) {
                            TestSim.setChannelEnabled(i, checked)
                        }
                    }

                    Connections {
                        target: TestSim
                        function onChannelsChanged() {
                            var count = TestSim.channelCount()
                            var allOn = true
                            for (var i = 0; i < count; i++) {
                                if (!TestSim.channelEnabled(i)) {
                                    allOn = false
                                    break
                                }
                            }
                            enableAllSwitch.checked = allOn
                        }
                    }
                }
            }
        }

        // -- Right Column: Channel Sliders --
        SettingsSection {
            title: "Channel Sliders"
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: SettingsTheme.sectionSpacing
                rowSpacing: 4

                Repeater {
                    model: TestSim.channelCount()

                    Rectangle {
                        id: channelRow
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        radius: SettingsTheme.radiusSmall
                        color: TestSim.channelEnabled(index) ? SettingsTheme.surfaceElevated : Qt.darker(SettingsTheme.surface, 1.3)
                        border.color: TestSim.channelEnabled(index) ? SettingsTheme.border : "transparent"
                        border.width: SettingsTheme.borderWidth
                        opacity: TestSim.channelEnabled(index) ? 1.0 : 0.5

                        property int chIdx: index

                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 8
                            spacing: 6

                            StyledSwitch {
                                checked: TestSim.channelEnabled(channelRow.chIdx)
                                onToggled: TestSim.setChannelEnabled(channelRow.chIdx, checked)
                                Layout.preferredWidth: SettingsTheme.switchTrackWidth + 4
                                Layout.alignment: Qt.AlignVCenter

                                Connections {
                                    target: TestSim
                                    function onChannelsChanged() {
                                        checked = TestSim.channelEnabled(channelRow.chIdx)
                                    }
                                }
                            }

                            Text {
                                text: TestSim.channelName(channelRow.chIdx)
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                font.weight: Font.DemiBold
                                color: SettingsTheme.textPrimary
                                elide: Text.ElideRight
                                Layout.preferredWidth: 110
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Slider {
                                id: chSlider
                                Layout.fillWidth: true
                                Layout.preferredHeight: SettingsTheme.controlHeight
                                from: TestSim.channelMin(channelRow.chIdx)
                                to: TestSim.channelMax(channelRow.chIdx)
                                stepSize: TestSim.channelStep(channelRow.chIdx)
                                value: TestSim.channelValue(channelRow.chIdx)
                                enabled: TestSim.channelEnabled(channelRow.chIdx)
                                onMoved: TestSim.setChannelValue(channelRow.chIdx, value)

                                background: Rectangle {
                                    x: chSlider.leftPadding
                                    y: chSlider.topPadding + chSlider.availableHeight / 2 - height / 2
                                    width: chSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: SettingsTheme.controlBg

                                    Rectangle {
                                        width: chSlider.visualPosition * parent.width
                                        height: parent.height
                                        radius: 3
                                        color: chSlider.enabled ? SettingsTheme.accent : SettingsTheme.textDisabled
                                    }
                                }

                                handle: Rectangle {
                                    x: chSlider.leftPadding + chSlider.visualPosition * (chSlider.availableWidth - width)
                                    y: chSlider.topPadding + chSlider.availableHeight / 2 - height / 2
                                    width: 24
                                    height: 24
                                    radius: SettingsTheme.radiusSmall
                                    color: chSlider.pressed
                                           ? SettingsTheme.accentPressed
                                           : (chSlider.enabled ? SettingsTheme.accent : SettingsTheme.textDisabled)
                                    visible: chSlider.enabled

                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }

                                Connections {
                                    target: TestSim
                                    function onChannelsChanged() {
                                        chSlider.value = TestSim.channelValue(channelRow.chIdx)
                                    }
                                }
                            }

                            Text {
                                text: root.formatValue(TestSim.channelValue(channelRow.chIdx),
                                                       TestSim.channelStep(channelRow.chIdx))
                                font.pixelSize: SettingsTheme.fontStatus
                                font.family: SettingsTheme.fontFamilyMono
                                font.weight: Font.Bold
                                color: SettingsTheme.accent
                                horizontalAlignment: Text.AlignRight
                                Layout.preferredWidth: 56
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: TestSim.channelUnit(channelRow.chIdx)
                                font.pixelSize: SettingsTheme.fontCaption
                                font.family: SettingsTheme.fontFamily
                                color: SettingsTheme.textSecondary
                                Layout.preferredWidth: 30
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
