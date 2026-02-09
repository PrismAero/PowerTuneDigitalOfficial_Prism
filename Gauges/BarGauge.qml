import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Controls 2.15
import "qrc:/Gauges/Qt6Compat"
import "qrc:/Translator.js" as Translator

//first try of full parameterized gauge

Rectangle {
            // Make the complete Rectangle draggable
            Drag.active: dragArea.drag.active


              MouseArea {
                  // Mouse area in which the item can be dragged
                  id: dragArea
                  anchors.fill: parent
                  drag.target: parent
                   }

                  id: barGauge

                  property alias title: titleText.text
                  property alias type: gauge.value
                  property alias gaugetype: gauge.orientation
                  property string information: "Bar gauge"

                  //color: (hand.callValue >= hand.handRaiseXBB) ? hand.handFoldColor : hand.handCallColor

                  width: (gauge.orientation == Qt.Horizontal) ? 260 : 85
                  height: (gauge.orientation == Qt.Vertical) ? 260 : 85
                  color: "transparent"

                  Gauge {
                      id: gauge
                      anchors.fill: parent
                      anchors.margins: 10
                      orientation : Qt.Vertical
                      minorTickmarkCount: 6
                      tickmarkStepSize : 70
                      //labelStepSize: 50
                      minimumValue: 0
                      maximumValue: 300

                      //value: Dashboard.MAP
                      Behavior on value {
                          NumberAnimation {
                              duration: 5
                          }
                      }
                      Text {
                          id: titleText
                          font.pixelSize: parent.width * (20 / parent.width)
                          anchors.top : parent.top
                          font.bold: true
                          font.family: "Eurostile"
                          color: "white"
                          anchors.horizontalCenter: parent.horizontalCenter
                      }
                        style: GaugeStyle {
                          valueBar: Rectangle {
                             implicitWidth:  20

                              color: Qt.rgba(gauge.value / gauge.maximumValue, 0, 1 - gauge.value / gauge.maximumValue, 1)
                          }

                        }

                  }
    }

