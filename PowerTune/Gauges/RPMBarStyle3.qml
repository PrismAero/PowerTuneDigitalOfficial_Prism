import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges 1.0
import PowerTune.Utils 1.0


Item {
    id: userDash
    anchors.fill: parent

      Image
      {
        id:groove1
        source:"qrc:/Resources/graphics/fueltechempty.png"
        width: parent.width
        height: parent.width /4
        anchors.top:parent.top
        anchors.left:parent.left
        smooth: true

        Item{
              id: displayWindow1
              height: parent.height
              width: (userDash.width*(Dashboard.rpm)/Dashboard.maxRPM)  //(parent.width*(Dashboard.rpm)/Dashboard.maxRPM)
              clip: true

                anchors.bottom: parent.bottom
                anchors.left: parent.left

              Image
              {
                id:speedarcfill
                anchors.top:parent.top
                anchors.left:parent.left
                width: groove1.width
                height: groove1.height
                source:"qrc:/Resources/graphics/fueltechfill.png"
                smooth: true
                z: 1
              }
            }

      PathInterpolator {
        id: motionPath
        property int value

           path: Path {
           startX: 0; startY: parent.width /4.2
           PathLine { x: parent.width; y: parent.height }
         }
        progress: Dashboard.rpm / Dashboard.maxRPM
      }
}
//
        ShiftLights{ }


        Text {
            id: rpmNumber
            x: 0
            y: userDash.width / 18.6 // 43
            font.pixelSize:  70
            font.bold: true
            color: "white"
            text: Dashboard.rpm
            horizontalAlignment: Text.AlignLeft
            font.letterSpacing: 3
            font.wordSpacing: 0
            Component.onCompleted: {
                if(userDash.width == 800){
                    rpmNumber.font.pixelSize = 70
                }else{
                    rpmNumber.font.pixelSize = 140
                }
            }
        }
}
