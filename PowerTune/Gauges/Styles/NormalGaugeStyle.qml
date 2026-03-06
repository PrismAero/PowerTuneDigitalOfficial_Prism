/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.15
import QtQuick.Shapes 1.15
import PowerTune.Gauges.Core 1.0
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

CircularGaugeStyle {
    tickmarkInset: toPixels(0.04)
    minorTickmarkInset: tickmarkInset
    tickmarkStepSize: 1
    labelStepSize: 20
    labelInset: toPixels(0.23)

    property real xCenter: outerRadius
    property real yCenter: outerRadius
    property int innertext
    property real needleLength: outerRadius - tickmarkInset * 1.25
    property real needleTipWidth: toPixels(0.02)
    property real needleBaseWidth: toPixels(0.06)
    property bool halfGauge: false

    function toPixels(percentage) {
        return percentage * outerRadius;
    }

    function degToRad(degrees) {
        return degrees * (Math.PI / 180);
    }

    function radToDeg(radians) {
        return radians * (180 / Math.PI);
    }

    background: Item {
        clip: halfGauge

        Rectangle {
            id: bgCircle
            anchors.fill: parent
            radius: width / 2
            color: "black"
        }

        Shape {
            id: outerRing
            anchors.fill: parent
            antialiasing: true
            ShapePath {
                fillColor: "transparent"
                strokeColor: "black"
                strokeWidth: tickmarkInset
                PathAngleArc {
                    centerX: xCenter
                    centerY: yCenter
                    radiusX: outerRadius - tickmarkInset / 2
                    radiusY: outerRadius - tickmarkInset / 2
                    startAngle: 0
                    sweepAngle: 360
                }
            }
        }

        Shape {
            id: innerRing
            anchors.fill: parent
            antialiasing: true
            ShapePath {
                fillColor: "transparent"
                strokeColor: "#222"
                strokeWidth: tickmarkInset / 2
                PathAngleArc {
                    centerX: xCenter
                    centerY: yCenter
                    radiusX: outerRadius - tickmarkInset / 4
                    radiusY: outerRadius - tickmarkInset / 4
                    startAngle: 0
                    sweepAngle: 360
                }
            }
        }

        Shape {
            id: gradientOverlay
            anchors.fill: parent
            antialiasing: true
            ShapePath {
                strokeColor: "transparent"
                strokeWidth: 0
                fillGradient: RadialGradient {
                    centerX: xCenter
                    centerY: yCenter
                    centerRadius: outerRadius - tickmarkInset
                    focalX: xCenter
                    focalY: yCenter
                    focalRadius: outerRadius * 0.8
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
                    GradientStop { position: 0.7; color: Qt.rgba(1, 1, 1, 0.13) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 1) }
                }
                PathAngleArc {
                    centerX: xCenter
                    centerY: yCenter
                    radiusX: outerRadius - tickmarkInset
                    radiusY: outerRadius - tickmarkInset
                    startAngle: 0
                    sweepAngle: 360
                }
            }
        }

        Text {
            id: speedText
            font.pixelSize: toPixels(0.3)
            color: GaugeTheme.textPrimary
            text: innertext
            horizontalAlignment: Text.AlignRight
            anchors.centerIn: parent
        }
    }

    needle: Item {
        implicitWidth: needleBaseWidth
        implicitHeight: needleLength
        antialiasing: true

        Rectangle {
            width: parent.width / 2
            height: parent.height
            anchors.right: parent.horizontalCenter
            color: GaugeTheme.needleSecondary
            antialiasing: true
        }
        Rectangle {
            width: parent.width / 2
            height: parent.height
            anchors.left: parent.horizontalCenter
            color: GaugeTheme.needlePrimary
            antialiasing: true
        }
    }

    foreground: null
}
