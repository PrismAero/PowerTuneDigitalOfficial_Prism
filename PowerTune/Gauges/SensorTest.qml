import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges 1.0
import PowerTune.Utils 1.0

Item {
    id: sensorwindow
    width: parent.width
    height: parent.height
Rectangle {
    anchors.fill: parent
    color: "grey"

    // TODO: PieMenu was removed in Qt6 - needs custom implementation or replacement
    // PieMenu {
    //     id: pieMenu
    //
    //     MenuItem {
    //         text: "Action 1"
    //         onTriggered: print("Action 1")
    //     }
    //     MenuItem {
    //         text: "Action 2"
    //         onTriggered: print("Action 2")
    //     }
    //     MenuItem {
    //         text: "Action 3"
    //         onTriggered: print("Action 3")
    //     }
    // }

    Grid {
        rows: 9
        columns: 2
        spacing: 5
        anchors.left: parent.left

        Text { text: "Accel X: "
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"
        }
        Text { text: Vehicle.accelx
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"
        }
        Text { text: "Accel Y: "
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"}
        Text { text: Vehicle.accely
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"}
        Text { text: "Accel Z: "
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"}
        Text { text: Vehicle.accelz
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"}
        Text { text: "Ambien Temp: "
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"}
        Text { text: Vehicle.ambitemp
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"}
        Text { text: "Ambient Pressure: "
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"}
        Text { text: Vehicle.ambipress
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"}
        Text { text: "Azimuth: "
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"}
        Text { text: Vehicle.compass
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"}
        Text { text: "Gyro X: "
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"
        }
        Text { text: Vehicle.gyrox
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"
        }
        Text { text: "Gyro y: "
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"
        }
        Text { text: Vehicle.gyroy
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"
        }
        Text { text: "Gyro Z: "
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"
        }
        Text { text: Vehicle.gyroz
            font.pixelSize: sensorwindow.width /20
            font.bold: true
            font.family: "Eurostile"
        }

    }
}
}


