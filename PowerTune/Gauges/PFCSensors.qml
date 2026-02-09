import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import PowerTune.Gauges 1.0
import PowerTune.Utils 1.0



Rectangle {
    id: sensorwindow
    anchors.centerIn: parent
    width: parent.width
    height: parent.height
    color:"transparent"

    // Sensor Status ON/OFF
    Row {
        anchors.centerIn: parent
        //Calculate the total pixels of the parent item and divide it by (32/1280) which is 6 pixel spacing / total screen pixels of 7"
        spacing: (parent.width + parent.height) * (32 / 1280)
        Grid {
            rows: 8
            columns: 6
            spacing: parent.width /160

            //ROW 1
            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Sensor.SensorString1)

            }
            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:{ (Sensor.sens1 > "5") ? "red": "green"; }
                text: (Sensor.sens1).toFixed(2) + " V   "
            }

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString1)
            }

            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag1 == "1") ? true: false; }
            }

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString2)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag2 == "1") ? true: false; }
            }

            // ROW 2

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Sensor.SensorString2)
            }
            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:{ (Sensor.sens2 > "5") ? "red": "green"; }
                text: (Sensor.sens2).toFixed(2) + " V   "
            }

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString3)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag3 == "1") ? true: false; }

            }

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString4)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag4 == "1") ? true: false; }
            }
            // ROW 3

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Sensor.SensorString3)
            }
            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:{ (Sensor.sens3 > "5") ? "red": "green"; }
                text: (Sensor.sens3).toFixed(2) + " V   "
            }
            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString5)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag5 == "1") ? true: false; }
            }

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString6)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag6 == "1") ? true: false; }

            }

            // ROW 4

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Sensor.SensorString4)
            }
            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:{ (Sensor.sens4 > "5") ? "red": "green"; }
                text: (Sensor.sens4).toFixed(2) + " V   "
            }

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString7)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag7 == "1") ? true: false; }
            }

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString8)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag8 == "1") ? true: false; }
            }
            // ROW 5

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Sensor.SensorString5)
            }
            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:{ (Sensor.sens5 > "5") ? "red": "green"; }
                text: (Sensor.sens5).toFixed(2) + " V   "
            }

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString9)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag9 == "1") ? true: false; }
            }


            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString10)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag10 == "1") ? true: false; }
            }

            // ROW 6


            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Sensor.SensorString6)
            }
            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:{ (Sensor.sens6 > "5") ? "red": "green"; }
                text: (Sensor.sens6).toFixed(2) + " V   "
            }

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString11)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag11 == "1") ? true: false; }
            }


            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString12)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag12 == "1") ? true: false; }
            }

            // ROW 7


            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Sensor.SensorString7)
            }
            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:{ (Sensor.sens7 > "5") ? "red": "green"; }
                text: (Sensor.sens7).toFixed(2) + " V   "
            }

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString13)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag13 == "1") ? true: false; }
            }



            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString14)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag14 == "1") ? true: false; }
            }


            // ROW 8

            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Sensor.SensorString8)
            }
            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:{ (Sensor.sens8 > "5") ? "red": "green"; }
                text: (Sensor.sens8).toFixed(2) + " V   "
            }


            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString15)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag15 == "1") ? true: false; }
            }



            Text {
                font.pixelSize: sensorwindow.width * 0.045
                color:"white"
                text: qsTr(Flags.FlagString16)
            }
            StatusIndicator {
                height: sensorwindow.width * 0.045
                width: height
                color: "green"
                active: { (Flags.Flag16 == "1") ? true: false; }

            }


        }
    }
}
