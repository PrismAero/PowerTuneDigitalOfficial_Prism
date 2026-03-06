/*
Gauge Needle that moves from -90 degrees to 270 degrees which pulls a red Tail 
modified code from 
https://github.com/alex-adam/Tesla 
*/
import QtQuick 2.15

Item {
    id: root

    property real value : 0

    onValueChanged: {zeiger.rotation = Math.min(Math.max(-250, root.value*3.5 - 90), 180); root.currentValue = zeiger.rotation -270} //130 minrotation, -30 maxrotation
    width: parent.width;
    height: parent.height

    Rectangle {
        id: zeiger
        rotation: -90 //siehe minrotation
        width: parent.width / 85
        height: parent.width / 2.2
        transformOrigin: Item.Bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter

        smooth: true
        antialiasing: true
        color: "white"
        onRotationChanged: {root.currentValue = zeiger.rotation -270; trailEffect.update()}

            Behavior on rotation {
                NumberAnimation{
                    duration: 5
                    easing.type: Easing.OutCirc
                }
            }
    }

      property color secondaryColor: zeiger.color

      property real centerWidth: width / 2
      property real centerHeight: height / 2
      property real radius: Math.min(root.width, root.height) / 2.08

      property real minimumValue: -360
      property real maximumValue: 0
      property real currentValue: -360

      property real angle:(currentValue - minimumValue) / (maximumValue - minimumValue) * 2 * Math.PI
      property real angleOffset: Math.PI  //to start at 0mph

    ShaderEffect {
        id: trailEffect
        anchors.fill: parent
        blending: true

        property real startAngle: root.angleOffset
        property real sweepAngle: root.angle
        property real outerRadius: root.radius / Math.max(root.width, root.height)
        property real arcWidth: 150.0 / Math.max(root.width, root.height)

        property color color0: "transparent"
        property color color1: "#f22900"
        property color color2: "#e96448"
        property color color3: "#ffffff"

        property real stop0: 0.33
        property real stop1: 0.45
        property real stop2: 0.46
        property real stop3: 0.50

        vertexShader: "
            uniform highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying highp vec2 coord;
            void main() {
                coord = qt_MultiTexCoord0;
                gl_Position = qt_Matrix * qt_Vertex;
            }
        "

        fragmentShader: "
            varying highp vec2 coord;
            uniform lowp float qt_Opacity;
            uniform highp float startAngle;
            uniform highp float sweepAngle;
            uniform highp float outerRadius;
            uniform highp float arcWidth;
            uniform lowp vec4 color0;
            uniform lowp vec4 color1;
            uniform lowp vec4 color2;
            uniform lowp vec4 color3;
            uniform highp float stop0;
            uniform highp float stop1;
            uniform highp float stop2;
            uniform highp float stop3;

            void main() {
                highp vec2 uv = coord - vec2(0.5);
                highp float dist = length(uv);
                highp float halfOuter = outerRadius * 0.5;

                highp float innerEdge = halfOuter - arcWidth * 0.5;
                highp float outerEdge = halfOuter + arcWidth * 0.5;

                if (dist < innerEdge || dist > outerEdge) {
                    gl_FragColor = vec4(0.0);
                    return;
                }

                highp float ang = atan(uv.y, uv.x);
                highp float endAngle = startAngle + sweepAngle;

                highp float normStart = startAngle - floor(startAngle / (2.0 * 3.14159265)) * 2.0 * 3.14159265;
                highp float normEnd = endAngle - floor(endAngle / (2.0 * 3.14159265)) * 2.0 * 3.14159265;
                highp float normAng = ang - floor(ang / (2.0 * 3.14159265)) * 2.0 * 3.14159265;

                bool inArc = false;
                if (sweepAngle >= 0.0) {
                    if (normStart <= normEnd) {
                        inArc = (normAng >= normStart && normAng <= normEnd);
                    } else {
                        inArc = (normAng >= normStart || normAng <= normEnd);
                    }
                } else {
                    if (normEnd <= normStart) {
                        inArc = (normAng <= normStart && normAng >= normEnd);
                    } else {
                        inArc = (normAng <= normStart || normAng >= normEnd);
                    }
                }

                if (!inArc) {
                    gl_FragColor = vec4(0.0);
                    return;
                }

                highp float radialT = dist / 0.5;

                lowp vec4 col;
                if (radialT < stop0) {
                    col = color0;
                } else if (radialT < stop1) {
                    highp float t = (radialT - stop0) / (stop1 - stop0);
                    col = mix(color0, color1, t);
                } else if (radialT < stop2) {
                    highp float t = (radialT - stop1) / (stop2 - stop1);
                    col = mix(color1, color2, t);
                } else if (radialT < stop3) {
                    highp float t = (radialT - stop2) / (stop3 - stop2);
                    col = mix(color2, color3, t);
                } else {
                    col = color3;
                }

                gl_FragColor = col * qt_Opacity;
            }
        "
    }
}
