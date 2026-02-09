import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import PowerTune.Settings 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    anchors.fill: parent
    color: "#121212"

    Item {
        id: sensehatsettings
        Settings {
            property alias accelswitch: accelsens.checked
            property alias gyrowitch: gyrosense.checked
            property alias compassswitch: compass.checked
            property alias tempswitch: tempsense.checked
            property alias pressureswitch: pressuresens.checked
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 16
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: root.width - 32
            spacing: 20

            // * Sensehat Sensors Section
            SettingsSection {
                title: "Sensehat Sensors"
                Layout.fillWidth: true

                Text {
                    text: "Enable or disable individual sensors from the Raspberry Pi Sensehat"
                    font.pixelSize: 16
                    font.family: "Lato"
                    color: "#707070"
                    font.italic: true
                }

                GridLayout {
                    columns: 2
                    rowSpacing: 16
                    columnSpacing: 40
                    Layout.fillWidth: true

                    // * Accelerometer
                    Rectangle {
                        Layout.preferredWidth: 350
                        Layout.preferredHeight: 80
                        color: accelsens.checked ? "#1A2D2D" : "#1E1E1E"
                        radius: 8
                        border.color: accelsens.checked ? "#009688" : "#3D3D3D"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Rectangle {
                                width: 48
                                height: 48
                                radius: 24
                                color: accelsens.checked ? "#009688" : "#2D2D2D"

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    icon: "speed"
                                    iconSize: 24
                                    iconColor: "#FFFFFF"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: Translator.translate("Accelerometer", Dashboard.language)
                                    font.pixelSize: 20
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

                            Switch {
                                id: accelsens
                                onClicked: { if (accelsens.checked) Sens.Accel() }
                            }
                        }
                    }

                    // * Gyro Sensor
                    Rectangle {
                        Layout.preferredWidth: 350
                        Layout.preferredHeight: 80
                        color: gyrosense.checked ? "#1A2D2D" : "#1E1E1E"
                        radius: 8
                        border.color: gyrosense.checked ? "#009688" : "#3D3D3D"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Rectangle {
                                width: 48
                                height: 48
                                radius: 24
                                color: gyrosense.checked ? "#009688" : "#2D2D2D"

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    icon: "sync"
                                    iconSize: 24
                                    iconColor: "#FFFFFF"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: Translator.translate("Gyro Sensor", Dashboard.language)
                                    font.pixelSize: 20
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

                            Switch {
                                id: gyrosense
                                onClicked: { if (gyrosense.checked) Sens.Gyro() }
                            }
                        }
                    }

                    // * Compass
                    Rectangle {
                        Layout.preferredWidth: 350
                        Layout.preferredHeight: 80
                        color: compass.checked ? "#1A2D2D" : "#1E1E1E"
                        radius: 8
                        border.color: compass.checked ? "#009688" : "#3D3D3D"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Rectangle {
                                width: 48
                                height: 48
                                radius: 24
                                color: compass.checked ? "#009688" : "#2D2D2D"

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    icon: "explore"
                                    iconSize: 24
                                    iconColor: "#FFFFFF"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: Translator.translate("Compass", Dashboard.language)
                                    font.pixelSize: 20
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

                            Switch {
                                id: compass
                                onClicked: { if (compass.checked) Sens.Comp() }
                            }
                        }
                    }

                    // * Pressure Sensor
                    Rectangle {
                        Layout.preferredWidth: 350
                        Layout.preferredHeight: 80
                        color: pressuresens.checked ? "#1A2D2D" : "#1E1E1E"
                        radius: 8
                        border.color: pressuresens.checked ? "#009688" : "#3D3D3D"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Rectangle {
                                width: 48
                                height: 48
                                radius: 24
                                color: pressuresens.checked ? "#009688" : "#2D2D2D"

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    icon: "speed"
                                    iconSize: 24
                                    iconColor: "#FFFFFF"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: Translator.translate("Pressure Sensor", Dashboard.language)
                                    font.pixelSize: 20
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

                            Switch {
                                id: pressuresens
                                onClicked: { if (pressuresens.checked) Sens.Pressure() }
                            }
                        }
                    }

                    // * Temperature Sensor
                    Rectangle {
                        Layout.preferredWidth: 350
                        Layout.preferredHeight: 80
                        color: tempsense.checked ? "#1A2D2D" : "#1E1E1E"
                        radius: 8
                        border.color: tempsense.checked ? "#009688" : "#3D3D3D"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Rectangle {
                                width: 48
                                height: 48
                                radius: 24
                                color: tempsense.checked ? "#009688" : "#2D2D2D"

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    icon: "thermostat"
                                    iconSize: 24
                                    iconColor: "#FFFFFF"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: Translator.translate("Temperature Sensor", Dashboard.language)
                                    font.pixelSize: 20
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

                            Switch {
                                id: tempsense
                                onClicked: { if (tempsense.checked) Sens.Temperature() }
                            }
                        }
                    }
                }
            }
        }
    }
}
