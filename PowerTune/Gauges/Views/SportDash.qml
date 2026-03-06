import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import PowerTune.Gauges.Core 1.0
import PowerTune.Gauges.Styles 1.0
import PowerTune.Utils 1.0
Item {
    anchors.fill:parent
    //Rectangle in which the rev counter resides
    Rectangle {
        color: "transparent"
        id: main
        height: parent.height / 1.2
        width: height
        anchors.centerIn: parent

        // Paint Tickmarks and Labels on the Rev counter
        CircularGauge {
            id: revcounter
            height: parent.height
            width: height
            value: Engine.rpm/1000
            anchors.verticalCenter: parent.verticalCenter
            maximumValue: 10

            style:NormalGaugeStyle{
                labelStepSize: 1
                labelInset: toPixels(0.21)
                minimumValueAngle: -180
                maximumValueAngle: 90
                innertext :Vehicle.speed
                tickmarkLabel:  Text {
                    font.pixelSize: styleData.value >= Engine.rpm/1000+0.5 || styleData.value <= Engine.rpm/1000-0.5  ?  revcounter.height /11 : (styleData.value-Engine.rpm/1000)+revcounter.height /7
                    text: styleData.value
                    font.bold : styleData.value >= Engine.rpm/1000+0.5 || styleData.value <= Engine.rpm/1000-0.5  ? false : true
                    color: styleData.value <= Engine.rpm/1000 ? "white" : "grey"
                    antialiasing: true
                }
                Shape {
                    anchors.fill: parent
                    antialiasing: true
                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: "blue"
                        strokeWidth: outerRadius
                        PathAngleArc {
                            centerX: outerRadius
                            centerY: outerRadius
                            radiusX: outerRadius + outerRadius / 2
                            radiusY: outerRadius + outerRadius / 2
                            startAngle: valueToAngle(revcounter.maximumValue) - 90
                            sweepAngle: (valueToAngle(revcounter.value + 1) - 90) - (valueToAngle(revcounter.maximumValue) - 90)
                        }
                    }
                }
            }

        }

    }
}
