import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent

    readonly property color bgDark: "#111122"
    readonly property color panelBg: "#1a1a36"
    readonly property color panelBorder: "#2a2a50"
    readonly property color accent: "#009688"
    readonly property color accentDim: "#00695C"
    readonly property color txtPrimary: "#FFFFFF"
    readonly property color txtSecondary: "#8888AA"
    readonly property color greenOn: "#00c853"
    readonly property color redOff: "#ff1744"
    readonly property color sweepOrange: "#FF6F00"

    Rectangle {
        anchors.fill: parent
        color: bgDark
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            radius: 8
            color: panelBg
            border.color: panelBorder
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Rectangle {
                    width: 14; height: 14; radius: 7
                    color: TestSim.running ? greenOn : "#444"
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: "Dashboard Test Simulator"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: txtPrimary
                    Layout.fillWidth: true
                }

                Text {
                    visible: TestSim.sweepLooping
                    text: "SWEEP ACTIVE"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: sweepOrange
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: "Interval:"
                    font.pixelSize: 14
                    color: txtSecondary
                    Layout.alignment: Qt.AlignVCenter
                }

                Slider {
                    id: intervalSlider
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 36
                    from: 20; to: 500; stepSize: 10
                    value: TestSim.intervalMs
                    onMoved: TestSim.intervalMs = value
                }

                Text {
                    text: TestSim.intervalMs + "ms"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: accent
                    Layout.preferredWidth: 50
                    Layout.alignment: Qt.AlignVCenter
                }

                Button {
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 38
                    onClicked: TestSim.running = !TestSim.running
                    background: Rectangle {
                        radius: 6
                        color: TestSim.running ? redOff : accent
                    }
                    contentItem: Text {
                        text: TestSim.running ? "Stop" : "Start"
                        color: txtPrimary
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    Layout.preferredWidth: 130
                    Layout.preferredHeight: 38
                    onClicked: {
                        if (TestSim.sweepLooping)
                            TestSim.stopSweepTest()
                        else
                            TestSim.startSweepTest()
                    }
                    background: Rectangle {
                        radius: 6
                        color: TestSim.sweepLooping ? redOff : sweepOrange
                    }
                    contentItem: Text {
                        text: TestSim.sweepLooping ? "Stop Sweep" : "Sweep Test"
                        color: txtPrimary
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            columnSpacing: 8
            rowSpacing: 6

            Repeater {
                model: TestSim.channelCount()

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    radius: 6
                    color: TestSim.channelEnabled(index) ? panelBg : Qt.darker(panelBg, 1.5)
                    border.color: TestSim.channelEnabled(index) ? panelBorder : Qt.darker(panelBorder, 1.4)
                    border.width: 1
                    opacity: TestSim.channelEnabled(index) ? 1.0 : 0.45

                    property int chIdx: index

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Switch {
                            checked: TestSim.channelEnabled(chIdx)
                            onToggled: TestSim.setChannelEnabled(chIdx, checked)
                            Layout.preferredWidth: 44
                            Layout.preferredHeight: 28
                            scale: 0.8
                        }

                        Text {
                            text: TestSim.channelName(chIdx)
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: txtPrimary
                            elide: Text.ElideRight
                            Layout.preferredWidth: 120
                        }

                        Slider {
                            id: chSlider
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            from: TestSim.channelMin(chIdx)
                            to: TestSim.channelMax(chIdx)
                            stepSize: TestSim.channelStep(chIdx)
                            value: TestSim.channelValue(chIdx)
                            enabled: TestSim.channelEnabled(chIdx)
                            onMoved: TestSim.setChannelValue(chIdx, value)

                            Connections {
                                target: TestSim
                                function onChannelsChanged() {
                                    chSlider.value = TestSim.channelValue(chIdx)
                                }
                            }
                        }

                        Text {
                            text: {
                                var v = TestSim.channelValue(chIdx)
                                var s = TestSim.channelStep(chIdx)
                                if (s >= 1) return v.toFixed(0)
                                if (s >= 0.1) return v.toFixed(1)
                                return v.toFixed(2)
                            }
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: accent
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 50
                        }

                        Text {
                            text: TestSim.channelUnit(chIdx)
                            font.pixelSize: 12
                            color: txtSecondary
                            Layout.preferredWidth: 32
                        }
                    }
                }
            }
        }
    }
}
