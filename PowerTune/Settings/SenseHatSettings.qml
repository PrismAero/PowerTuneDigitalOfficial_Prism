// Copyright (c) Kai Wyborny. All rights reserved.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    anchors.fill: parent
    color: "#1a1a2e"

    Component.onCompleted: {
        accelsens.checked = AppSettings.getValue("sensehat/accel", false)
        gyrosense.checked = AppSettings.getValue("sensehat/gyro", false)
        compass.checked = AppSettings.getValue("sensehat/compass", false)
        tempsense.checked = AppSettings.getValue("sensehat/temp", false)
        pressuresens.checked = AppSettings.getValue("sensehat/pressure", false)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // * Sensehat Sensors Section
        SettingsSection {
            title: "Sensehat Sensors"
            Layout.fillWidth: true

            Text {
                text: "Enable or disable individual sensors from the Raspberry Pi Sensehat"
                font.pixelSize: 14
                font.family: "Lato"
                color: "#707070"
                font.italic: true
            }

            GridLayout {
                columns: 2
                rowSpacing: 12
                columnSpacing: 24
                Layout.fillWidth: true

                // * Accelerometer
                Rectangle {
                    Layout.preferredWidth: 360
                    Layout.preferredHeight: 64
                    color: accelsens.checked ? "#1A2D2D" : "#1E1E1E"
                    radius: 8
                    border.color: accelsens.checked ? "#009688" : "#3D3D3D"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: accelsens.checked ? "#009688" : "#2D2D2D"

                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "speed"
                                iconSize: 20
                                iconColor: "#FFFFFF"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: Translator.translate("Accelerometer", Settings.language)
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                font.family: "Lato"
                                color: "#FFFFFF"
                            }
                            Text {
                                text: "Motion detection"
                                font.pixelSize: 14
                                font.family: "Lato"
                                color: "#707070"
                            }
                        }

                        StyledSwitch {
                            id: accelsens
                            onCheckedChanged: AppSettings.setValue("sensehat/accel", checked)
                            onClicked: { if (accelsens.checked) Sens.Accel() }
                        }
                    }
                }

                // * Gyro Sensor
                Rectangle {
                    Layout.preferredWidth: 360
                    Layout.preferredHeight: 64
                    color: gyrosense.checked ? "#1A2D2D" : "#1E1E1E"
                    radius: 8
                    border.color: gyrosense.checked ? "#009688" : "#3D3D3D"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: gyrosense.checked ? "#009688" : "#2D2D2D"

                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "sync"
                                iconSize: 20
                                iconColor: "#FFFFFF"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: Translator.translate("Gyro Sensor", Settings.language)
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                font.family: "Lato"
                                color: "#FFFFFF"
                            }
                            Text {
                                text: "Rotation detection"
                                font.pixelSize: 14
                                font.family: "Lato"
                                color: "#707070"
                            }
                        }

                        StyledSwitch {
                            id: gyrosense
                            onCheckedChanged: AppSettings.setValue("sensehat/gyro", checked)
                            onClicked: { if (gyrosense.checked) Sens.Gyro() }
                        }
                    }
                }

                // * Compass
                Rectangle {
                    Layout.preferredWidth: 360
                    Layout.preferredHeight: 64
                    color: compass.checked ? "#1A2D2D" : "#1E1E1E"
                    radius: 8
                    border.color: compass.checked ? "#009688" : "#3D3D3D"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: compass.checked ? "#009688" : "#2D2D2D"

                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "explore"
                                iconSize: 20
                                iconColor: "#FFFFFF"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: Translator.translate("Compass", Settings.language)
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                font.family: "Lato"
                                color: "#FFFFFF"
                            }
                            Text {
                                text: "Heading direction"
                                font.pixelSize: 14
                                font.family: "Lato"
                                color: "#707070"
                            }
                        }

                        StyledSwitch {
                            id: compass
                            onCheckedChanged: AppSettings.setValue("sensehat/compass", checked)
                            onClicked: { if (compass.checked) Sens.Comp() }
                        }
                    }
                }

                // * Pressure Sensor
                Rectangle {
                    Layout.preferredWidth: 360
                    Layout.preferredHeight: 64
                    color: pressuresens.checked ? "#1A2D2D" : "#1E1E1E"
                    radius: 8
                    border.color: pressuresens.checked ? "#009688" : "#3D3D3D"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: pressuresens.checked ? "#009688" : "#2D2D2D"

                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "speed"
                                iconSize: 20
                                iconColor: "#FFFFFF"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: Translator.translate("Pressure Sensor", Settings.language)
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                font.family: "Lato"
                                color: "#FFFFFF"
                            }
                            Text {
                                text: "Atmospheric pressure"
                                font.pixelSize: 14
                                font.family: "Lato"
                                color: "#707070"
                            }
                        }

                        StyledSwitch {
                            id: pressuresens
                            onCheckedChanged: AppSettings.setValue("sensehat/pressure", checked)
                            onClicked: { if (pressuresens.checked) Sens.Pressure() }
                        }
                    }
                }

                // * Temperature Sensor
                Rectangle {
                    Layout.preferredWidth: 360
                    Layout.preferredHeight: 64
                    color: tempsense.checked ? "#1A2D2D" : "#1E1E1E"
                    radius: 8
                    border.color: tempsense.checked ? "#009688" : "#3D3D3D"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: tempsense.checked ? "#009688" : "#2D2D2D"

                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "thermostat"
                                iconSize: 20
                                iconColor: "#FFFFFF"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: Translator.translate("Temperature Sensor", Settings.language)
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                font.family: "Lato"
                                color: "#FFFFFF"
                            }
                            Text {
                                text: "Ambient temperature"
                                font.pixelSize: 14
                                font.family: "Lato"
                                color: "#707070"
                            }
                        }

                        StyledSwitch {
                            id: tempsense
                            onCheckedChanged: AppSettings.setValue("sensehat/temp", checked)
                            onClicked: { if (tempsense.checked) Sens.Temperature() }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
