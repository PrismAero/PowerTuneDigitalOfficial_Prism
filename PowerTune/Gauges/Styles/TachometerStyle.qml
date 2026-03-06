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
import PowerTune.Utils 1.0

DashboardGaugeStyle {
    id: tachometerStyle
    minimumValueAngle: -180
    maximumValueAngle: 90
    tickmarkStepSize: 1
    labelStepSize: 1
    needleLength: toPixels(0.05)
    needleBaseWidth: toPixels(0.08)
    needleTipWidth: toPixels(0.03)

    // outer tickmarks in red from 8 - 10
    tickmark: Rectangle {
        implicitWidth: toPixels(0.03)
        antialiasing: true
        implicitHeight: toPixels(0.08)
        color: styleData.index === 8 || styleData.index === 9 ||styleData.index === 10 ? Qt.rgba(0.5, 0, 0, 1) : "#c8c8c8"
    }
   // outer numbers in red from 8 - 10
    minorTickmark: null

    tickmarkLabel: Text {
        font.pixelSize: Math.max(6, toPixels(0.12))
        text: styleData.value
        color: styleData.index === 8 ||styleData.index === 9 || styleData.index === 10 ? Qt.rgba(0.5, 0, 0, 1) : "#c8c8c8"
        antialiasing: true
    }

    background: Item {
        id: warningArcBg
        property real angleRange: tachometerStyle.maximumValueAngle - tachometerStyle.minimumValueAngle
        property real arcStartAngle: tachometerStyle.maximumValueAngle - 85
        property real arcLineWidth: tachometerStyle.toPixels(0.08)
        property real arcRadius: tachometerStyle.outerRadius - tachometerStyle.tickmarkInset - arcLineWidth / 2
        property real arcBegin: arcStartAngle - angleRange / 4 + angleRange * 0.015
        property real arcSweep: (arcStartAngle - angleRange * 0.015) - arcBegin

        Shape {
            anchors.fill: parent
            antialiasing: true
            ShapePath {
                fillColor: "transparent"
                strokeColor: Qt.rgba(0.5, 0, 0, 1)
                strokeWidth: warningArcBg.arcLineWidth
                PathAngleArc {
                    centerX: tachometerStyle.outerRadius
                    centerY: tachometerStyle.outerRadius
                    radiusX: warningArcBg.arcRadius
                    radiusY: warningArcBg.arcRadius
                    startAngle: warningArcBg.arcBegin
                    sweepAngle: warningArcBg.arcSweep
                }
            }
        }
    }
}
